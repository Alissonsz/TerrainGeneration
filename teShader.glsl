#version 430 core

layout(triangles, equal_spacing, ccw) in;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

uniform vec3 lightPos;
uniform vec3 viewPos;

in VS_OUT
{
    vec3 FragPos;
    vec2 TexCoords;
    vec3 TangentLightPos;
    vec3 TangentViewPos;
    vec3 TangentFragPos;
} te_in[];

out vec3 tcNormal[];
out vec3 tcBitang[];
out vec3 tcTang[];
out vec3 tcPosition[];

out vec3 tePosition;
out vec3 teNormal;
out vec3 teBitang;
out vec3 teTang;

out VS_OUT
{
    vec3 FragPos;
    vec2 TexCoords;
    vec3 TangentLightPos;
    vec3 TangentViewPos;
    vec3 TangentFragPos;
} te_out;


void main(){
    vec3 tcPos0 = (tcPosition[0]);
    vec3 tcPos1 = (tcPosition[1]);
    vec3 tcPos2 = (tcPosition[2]);

    vec3 p0 = gl_TessCoord.x * tcPos0;
    vec3 p1 = gl_TessCoord.y * tcPos1;
    vec3 p2 = gl_TessCoord.z * tcPos2;
    tePosition = (p0 + p1 + p2);

    vec3 t0 = gl_TessCoord.x * tcTang[0];
    vec3 t1 = gl_TessCoord.y * tcTang[1];
    vec3 t2 = gl_TessCoord.z * tcTang[2];
    teTang = (t0 + t1 + t2);

    vec3 b0 = gl_TessCoord.x * tcBitang[0];
    vec3 b1 = gl_TessCoord.y * tcBitang[1];
    vec3 b2 = gl_TessCoord.z * tcBitang[2];
    teBitang = (b0 + b1 + b2);

    vec3 n0 = gl_TessCoord.x * tcNormal[0];
    vec3 n1 = gl_TessCoord.y * tcNormal[1];
    vec3 n2 = gl_TessCoord.z * tcNormal[2];
    teNormal = (n0 + n1 + n2);

    te_out.FragPos =  gl_TessCoord[0] * te_in[0].FragPos
                    + gl_TessCoord[1] * te_in[1].FragPos
	           	    + gl_TessCoord[2] * te_in[2].FragPos;

	te_out.TexCoords  = gl_TessCoord[0] * te_in[0].TexCoords
                      + gl_TessCoord[1] * te_in[1].TexCoords
	                  + gl_TessCoord[2] * te_in[2].TexCoords;

    te_out.TangentLightPos =  gl_TessCoord[0] * te_in[0].TangentLightPos
                            + gl_TessCoord[1] * te_in[1].TangentLightPos
	           	            + gl_TessCoord[2] * te_in[2].TangentLightPos;

    te_out.TangentViewPos   = gl_TessCoord[0] * te_in[0].TangentViewPos
                            + gl_TessCoord[1] * te_in[1].TangentViewPos
	           	            + gl_TessCoord[2] * te_in[2].TangentViewPos;

    te_out.TangentFragPos   =  gl_TessCoord[0] * te_in[0].TangentFragPos
                            + gl_TessCoord[1] * te_in[1].TangentFragPos
	           	            + gl_TessCoord[2] * te_in[2].TangentFragPos;
/*
    mat3 TBN = transpose(mat3(teTang, teBitang, teNormal));

    te_out.TangentLightPos = TBN * lightPos;
    te_out.TangentViewPos  = TBN * viewPos;
    te_out.TangentFragPos  = TBN * te_out.FragPos;*/

    gl_Position = projection * view * model * vec4(tePosition, 1.0);
}
