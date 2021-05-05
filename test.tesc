#version 430

// number of CPs in patch
layout (vertices = 3) out;

uniform vec3 viewPos;
uniform sampler2D texture1;

// from VS (use empty modifier [] so we can say anything)
in vec3 vPosition[];
in vec2 vTexCoord[];

in VS_OUT {
    vec3 FragPos;
    vec2 TexCoords;
    vec3 TangentLightPos;
    vec3 TangentViewPos;
    vec3 TangentFragPos;
} tc_in[];

// to evluation shader. will be used to guide positioning of generated points
out vec3 evaluationpoint_wor[];
out vec2 tcTexCoord[];

bool newMet = false;

out TC_OUT
{
    vec3 FragPos;
    vec2 TexCoords;
    vec3 TangentLightPos;
    vec3 TangentViewPos;
    vec3 TangentFragPos;
} tc_out[];
 
uniform float tessLevelInner = 4.0; // controlled by keyboard buttons
uniform float tessLevelOuter = 4.0; // controlled by keyboard buttons

float LOD(vec3 posV, vec3 cam){
  float dist = distance(posV, cam);
 
  if(dist<=25) return 128.0;
  else if(dist>25 && dist<=50) return 64.0;
  else if(dist>50 && dist<=75) return 32.0;
  else if(dist>75 && dist<=100) return 16.0;
  else if(dist>100 && dist<=150) return 12.0;
  else if(dist>150 && dist<=200) return 8.0;
  else if(dist>200 && dist<=300) return 6.0;
  else if(dist>300 && dist<=400) return 4.0;
  else if(dist>400) return 1.0;
  
}
 
void main () {
  tc_out[gl_InvocationID].FragPos = tc_in[gl_InvocationID].FragPos;
	tc_out[gl_InvocationID].TexCoords = tc_in[gl_InvocationID].TexCoords;
	tc_out[gl_InvocationID].TangentLightPos = tc_in[gl_InvocationID].TangentLightPos;
	tc_out[gl_InvocationID].TangentViewPos = tc_in[gl_InvocationID].TangentViewPos;
  tc_out[gl_InvocationID].TangentFragPos = tc_in[gl_InvocationID].TangentFragPos;

  tcTexCoord[gl_InvocationID]  = vTexCoord[gl_InvocationID];

  evaluationpoint_wor[gl_InvocationID] = vPosition[gl_InvocationID];

  float TessLevelInner = 1;
  float e0, e1, e2;
  vec3 d0, d1, d2;

  e0 = e1 = e2 = 1;

  if (gl_InvocationID == 0) {
    vec3 v0 = gl_in[0].gl_Position.xyz;
    vec3 v1 = gl_in[1].gl_Position.xyz;
    vec3 v2 = gl_in[2].gl_Position.xyz;

    vec3 bTriangulo = (gl_in[0].gl_Position.xyz + gl_in[1].gl_Position.xyz + gl_in[2].gl_Position.xyz)/3;
    TessLevelInner = LOD(bTriangulo, viewPos);

    d0=v1+(v2-v1)/2;
    d1=v0+(v2-v0)/2;
    d2=v0+(v1-v0)/2;

    e0=LOD(d0,viewPos);
    e1=LOD(d1,viewPos);
    e2=LOD(d2,viewPos);
  }
 
  //Calculate the tessellation levels
  gl_TessLevelInner[0] = TessLevelInner; // number of nested primitives to generate
  gl_TessLevelOuter[0] = e0; // times to subdivide first side
  gl_TessLevelOuter[1] = e1; // times to subdivide second side
  gl_TessLevelOuter[2] = e2; // times to subdivide third side
  // gl_TessLevelInner[0] = tessLevelInner; // number of nested primitives to generate
  // gl_TessLevelOuter[0] = tessLevelOuter; // times to subdivide first side
  // gl_TessLevelOuter[1] = tessLevelOuter; // times to subdivide second side
  // gl_TessLevelOuter[2] = tessLevelOuter; // times to subdivide third side
}