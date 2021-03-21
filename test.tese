#version 430
 
// triangles, quads, or isolines
layout (triangles, equal_spacing, ccw) in;
in vec3 evaluationpoint_wor[];

in TC_OUT
{
    vec3 FragPos;
    vec2 TexCoords;
    vec3 TangentLightPos;
    vec3 TangentViewPos;
    vec3 TangentFragPos;
} te_in[];

out TE_OUT
{
    vec3 FragPos;
    vec2 TexCoords;
    vec3 TangentLightPos;
    vec3 TangentViewPos;
    vec3 TangentFragPos;
} te_out;
 
// could use a displacement map here

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 lightPos;
uniform vec3 viewPos;
 
// gl_TessCoord is location within the patch
// (barycentric for triangles, UV for quads)
 
void main () {
  te_out.FragPos =  gl_TessCoord[0] * te_in[0].FragPos
                    + gl_TessCoord[1] * te_in[1].FragPos
	           	      + gl_TessCoord[2] * te_in[2].FragPos;

	te_out.TexCoords = gl_TessCoord[0] * te_in[0].TexCoords
	           	    + gl_TessCoord[1] * te_in[1].TexCoords
	                + gl_TessCoord[2] * te_in[2].TexCoords;

  te_out.TangentLightPos = lightPos;
  te_out.TangentViewPos  = viewPos;
  te_out.TangentFragPos  = te_out.FragPos;

  vec3 p0 = gl_TessCoord.x * evaluationpoint_wor[0]; // x is one corner
  vec3 p1 = gl_TessCoord.y * evaluationpoint_wor[1]; // y is the 2nd corner
  vec3 p2 = gl_TessCoord.z * evaluationpoint_wor[2]; // z is the 3rd corner (ignore when using quads)
  vec3 pos = (p0 + p1 + p2);
  gl_Position = projection * view * model * vec4 (pos, 1.0);
}