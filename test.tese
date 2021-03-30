#version 430
 
// triangles, quads, or isolines
layout (triangles, equal_spacing, ccw) in;
in vec3 evaluationpoint_wor[];
in vec2 tcTexCoord[];

uniform sampler2D texture1;

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
    vec3 color;
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

  te_out.TangentFragPos  = gl_TessCoord[0] * te_in[0].TangentFragPos
                         + gl_TessCoord[1] * te_in[1].TangentFragPos
                         + gl_TessCoord[2] * te_in[2].TangentFragPos;

  te_out.TangentViewPos  = gl_TessCoord[0] * te_in[0].TangentViewPos
                         + gl_TessCoord[1] * te_in[1].TangentViewPos
                         + gl_TessCoord[2] * te_in[2].TangentViewPos;

  te_out.TangentLightPos  = gl_TessCoord[0] * te_in[0].TangentLightPos
                          + gl_TessCoord[1] * te_in[1].TangentLightPos
                          + gl_TessCoord[2] * te_in[2].TangentLightPos;

  vec2 t0 = gl_TessCoord.x * tcTexCoord[0];
  vec2 t1 = gl_TessCoord.y * tcTexCoord[1];
  vec2 t2 = gl_TessCoord.z * tcTexCoord[2];
  vec2 f00TexCoord = (t0 + t1 + t2);

  vec3 p0 = gl_TessCoord.x * evaluationpoint_wor[0]; // x is one corner
  vec3 p1 = gl_TessCoord.y * evaluationpoint_wor[1]; // y is the 2nd corner
  vec3 p2 = gl_TessCoord.z * evaluationpoint_wor[2]; // z is the 3rd corner (ignore when using quads)
  vec3 pos = (p0 + p1 + p2);

  te_out.color = texture(texture1, f00TexCoord).rgb;

  gl_Position = projection * view * model * vec4 (pos.x, te_out.color.r, pos.z, 1.0);
}