#version 430 core
//layout (location = 0) in vec3 aPos;
//layout (location = 1) in vec3 aNormal;

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aTexCoords;
layout (location = 3) in vec3 aTangent;
layout (location = 4) in vec3 aBitangent;

out VS_OUT {
    vec3 FragPos;
    vec2 TexCoords;
    vec3 TangentLightPos;
    vec3 TangentViewPos;
    vec3 TangentFragPos;
} vs_out;

out vec3 vPos;
out vec3 vTang;
out vec3 vBitang;
out vec3 vNormal;
out vec3 vPosition;

//out vec3 ourColor;
uniform sampler2D texture1;
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

uniform vec3 lightPos;
uniform vec3 viewPos;

void main(){
    vec4 curV;
    curV = model * vec4(aPos, 1.0);
    
    float texX, texY;
    texX = (curV.x + 15) / 30;
    texY = (curV.z + 15) / 30;

    vs_out.FragPos = vec3(curV);

    vs_out.TexCoords = vec2(texX, texY);

    vec3 T = normalize(mat3(model) * aTangent);
    vec3 B = normalize(mat3(model) * aBitangent);
    vec3 N = normalize(mat3(model) * aNormal);
    mat3 TBN = transpose(mat3(T, B, N));

    vs_out.TangentLightPos = TBN * lightPos;
    vs_out.TangentViewPos  = TBN * viewPos;
    vs_out.TangentFragPos  = TBN * vec3(curV);

    vPosition = vec3(aPos.x, 1.f, aPos.z);
    
    // gl_Position = /*projection * view * model **/ vec4(aPos.x, 1.f, aPos.z, 1.0);
}
