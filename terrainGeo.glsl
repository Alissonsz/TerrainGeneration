#version 430

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

in vec4 f00Color[];
in vec2 f00TexCoord[];
in vec3 f00Position[];
in vec3 f00Normal[];
in float f00Factor[];
in float f00Height[];

uniform vec3 viewPos;
uniform mat4 MVP;
uniform mat4 M;
uniform mat4 V;
uniform mat4 N;
uniform sampler2D texture1;
uniform int frag;

out float fFactor;
out vec3 fNormal;
out vec4 fColor;
out vec2 fTexCoord;
out vec3 fPosition;
out float fHeight;
out vec3 tangent, bitangent;
out vec3 tangentLightPos;
out vec3 tangentViewPos;
out vec3 tangentFragPos;

vec3 lightPos = vec3(90.5, 20.3, -30.5)*1;

void main( void )
{

    vec3 edge01 = gl_in[1].gl_Position.xyz - gl_in[0].gl_Position.xyz;
    vec3 edge02 = gl_in[2].gl_Position.xyz - gl_in[0].gl_Position.xyz;

    vec3 e1 = gl_in[1].gl_Position.xyz - gl_in[0].gl_Position.xyz;
    vec3 e2 = gl_in[2].gl_Position.xyz - gl_in[0].gl_Position.xyz;

    float x1 = f00TexCoord[1].x - f00TexCoord[0].x;
    float x2 = f00TexCoord[2].x - f00TexCoord[0].x;

    float y1 = f00TexCoord[1].y - f00TexCoord[0].y;
    float y2 = f00TexCoord[2].y - f00TexCoord[0].y;

    float r = 1.f / (x1*y2 - x2*y1);

    vec3 tang = (e1*y2 - e2*y1)*r;
    vec3 bitanf = (e2*x1 - e1*x2)*r;
    vec3 normal = normalize(cross(edge01, edge02));

    vec3 T = normalize(mat3(M) * tang);
    vec3 B = normalize(mat3(M) * bitanf);
    vec3 N = normalize(mat3(M) * normal);
    mat3 TBN = transpose(mat3(T, B, N));


    tangentLightPos = TBN * lightPos;
    tangentViewPos  = TBN * viewPos;

    for( int i=0; i < gl_in.length( ); i++ )
    {

        fColor = f00Color[i];
        fTexCoord = f00TexCoord[i];
        fPosition = f00Position[i];
        if(frag%2 != 0.f)
          fPosition.y = f00Position[i].y + f00Height[i];
        fFactor = f00Factor[i];
        fHeight = f00Height[i];
        gl_Position = MVP * vec4(fPosition, 1.f);
        fNormal = normal;

        vec3 fragPos = vec3(M * vec4(f00Position[i], 1.0));
        tangentFragPos  = TBN * fragPos;
        tangentLightPos = TBN * lightPos;
        tangentViewPos  = TBN * viewPos;

        EmitVertex();


        //normalize(cross(gl_in[i+2].gl_Position.xyz - gl_in[i].gl_Position.xyz, gl_in[i+1].gl_Position.xyz - gl_in[i].gl_Position.xyz));
    }

//    vec2 deltaUV1 = teTexCoord[1] - teTexCoord[0];
//    vec2 deltaUV2 = teTexCoord[2] - teTexCoord[0];
//
//    float f = 1.0f / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);
//
//    tangent.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
//    tangent.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
//    tangent.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);
//    tangent = normalize(tangent);
//
////    bitangent.x = f * (-deltaUV2.x * edge1.x + deltaUV1.x * edge2.x);
////    bitangent.y = f * (-deltaUV2.x * edge1.y + deltaUV1.x * edge2.y);
////    bitangent.z = f * (-deltaUV2.x * edge1.z + deltaUV1.x * edge2.z);
////    bitangent1 = glm::normalize(bitangent1);
//
//    bitangent = cross(fNormal, tangent);
//    vec3 T = normalize(mat3(M) * tangent);
//    vec3 B = normalize(mat3(M) * bitangent);
//    vec3 N1 = normalize(mat3(M) * fNormal);
//    mat3 TBN = transpose(mat3(T, B, N1));
//
//    TangentLightPos = TBN * lightPos;
//    TangentViewPos  = TBN * viewPos;
//    TangentFragPos  = TBN * fragPos;

    EndPrimitive( );
}
