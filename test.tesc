#version 430

// number of CPs in patch
layout (vertices = 3) out;

// from VS (use empty modifier [] so we can say anything)
in vec3 vPosition[];

in VS_OUT {
    vec3 FragPos;
    vec2 TexCoords;
    vec3 TangentLightPos;
    vec3 TangentViewPos;
    vec3 TangentFragPos;
} tc_in[];

// to evluation shader. will be used to guide positioning of generated points
out vec3 evaluationpoint_wor[];

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
 
void main () {
  tc_out[gl_InvocationID].FragPos = tc_in[gl_InvocationID].FragPos;
	tc_out[gl_InvocationID].TexCoords = tc_in[gl_InvocationID].TexCoords;
	tc_out[gl_InvocationID].TangentLightPos = tc_in[gl_InvocationID].TangentLightPos;
	tc_out[gl_InvocationID].TangentViewPos = tc_in[gl_InvocationID].TangentViewPos;
  tc_out[gl_InvocationID].TangentFragPos = tc_in[gl_InvocationID].TangentFragPos;

  evaluationpoint_wor[gl_InvocationID] = vPosition[gl_InvocationID];
 
  // Calculate the tessellation levels
  gl_TessLevelInner[0] = tessLevelInner; // number of nested primitives to generate
  gl_TessLevelOuter[0] = tessLevelOuter; // times to subdivide first side
  gl_TessLevelOuter[1] = tessLevelOuter; // times to subdivide second side
  gl_TessLevelOuter[2] = tessLevelOuter; // times to subdivide third side
}