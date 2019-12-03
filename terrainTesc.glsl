#version 430 core

layout(vertices = 3) out;

in vec3 vPosition[];
in vec4 vColor[];
in vec2 vTexCoord[];
in vec3 vNormal[];

out vec3 tcNormal[];
out vec3 tcPosition[];
out vec4 tcColor[];
out vec2 tcTexCoord[];

uniform vec3 viewPos;

uniform int tess;

uniform float dx;
uniform float dy;
uniform mat4 V;
uniform float dz;
uniform float radius;
uniform float mesh;

#define ID gl_InvocationID
bool newMet = false;

float LOD(vec3 posV, vec3 cam){
  float dist = distance(posV, cam);
  if(newMet){
    float T = 4*mesh/(0.5*dist);
    if(T > 64)
        return 64.f;
    else if(T < 1)
        return 1.f;
    return T;
  }
  else{
    if(dist<=50) return 32.0;
    else if(dist>50 && dist<=100) return 16.0;
    else if(dist>100 && dist<=200) return 8.0;
    else if(dist>200 && dist<=300) return 4.0;
    else if(dist>300 && dist<=400) return 2.0;
    else if(dist>400) return 1.0;
  }
}

void main(){
  float TessLevelInner = 1;
  float e0, e1, e2;
  vec3 d0, d1, d2;

  e0 = e1 = e2 = 1;
   tcTexCoord[ID]  = vTexCoord[ID];
  tcPosition[ID]  = vPosition[ID];
  tcColor[ID]     = vColor[ID];
  tcNormal[ID]     = vNormal[ID];


  if (ID == 0) {
    vec3 v0 = gl_in[0].gl_Position.xyz;
    vec3 v1 = gl_in[1].gl_Position.xyz;
    vec3 v2 = gl_in[2].gl_Position.xyz;

    vec3 bTriangulo = (v0 + v1 + v2)/3;

    if(tess==1){
      TessLevelInner = LOD(bTriangulo, viewPos);

      d0=v1+(v2-v1)/2;
      d1=v0+(v2-v0)/2;
      d2=v0+(v1-v0)/2;

      e0=LOD(d0,viewPos);
      e1=LOD(d1,viewPos);
      e2=LOD(d2,viewPos);
    }
    else if(tess == 0){
      TessLevelInner = 1;
    }
    else if(tess == 2){
      TessLevelInner = 2;
    }

    gl_TessLevelInner[0] = TessLevelInner;
    gl_TessLevelOuter[0] = e0;
    gl_TessLevelOuter[1] = e1;
    gl_TessLevelOuter[2] = e2;
  }
  //if(TessLevelInner == 8.0 /*|| TessLevelOuter == 8.0*/){
    //tcColor[ID] == vec4(1.0, 1.0, 1.0, 1.0);
  //}

}

