#version 430 core
#extension GL_EXT_gpu_shader4 : enable
#define F3 0.333333333
#define G3 0.166666667

layout(triangles, equal_spacing, ccw) in;

uniform mat4 P;
uniform mat4 VM;
uniform mat4 M;
uniform mat4 MVP;
uniform vec3 viewPos;
uniform float lac;
uniform sampler2D neve;

//uniform bool noised;

in vec3 tcPosition[];
in vec4 tcColor[];
in vec2 tcTexCoord[];
in vec3 tcNormal[];

out vec3 f00Position;
out vec4 f00Color;
out vec2 f00TexCoord;
out vec3 f00Normal;

out vec3 f00EyeVector;
out float f00HeightScale;
out float f00HBase;

float hash(float n) { return fract(sin(n) * 1e4); }
float hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

float noise(vec3 x) {
	const vec3 step = vec3(110, 241, 171);

	vec3 i = floor(x);
	vec3 f = fract(x);

	// For performance, compute the base input to a 1D hash from the integer part of the argument and the
	// incremental change to the 1D based on the 3D -> 1D wrapping
    float n = dot(i, step);

	vec3 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
               mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);
}

const mat3 m3  = mat3( 0.00,  0.80,  0.60,
                      -0.80,  0.36, -0.48,
                      -0.60, -0.48,  0.64 );

float fbm( vec3 p ){
    float f = 0.0;
    f += 0.5000*noise( p ); p = m3*p*2.02;
    f += 0.2500*noise( p ); p = m3*p*2.03;
    f += 0.1250*noise( p ); p = m3*p*2.01;
    f += 0.0625*noise( p );

    return f/0.9375;
}

float ridgedNoise(in vec3 p, int octaves, float H, float gain, float amplitude, float frequency, float persistence, float offset){
  float total = 0.f;
  float exponent = pow(amplitude, -H);
  for(int i=0;i<octaves;i++)
  {
    total += offset-(((1.0 - abs(noise(p * frequency))) * 2.0 - 1.0) * amplitude*exponent);
    frequency	*= gain;
    amplitude *= gain;
  }
  return total;
}

void main(){
    vec4 pc;
    f00HeightScale = 2.f;

    vec2 t0 = gl_TessCoord.x * tcTexCoord[0];
    vec2 t1 = gl_TessCoord.y * tcTexCoord[1];
    vec2 t2 = gl_TessCoord.z * tcTexCoord[2];
    f00TexCoord = (t0 + t1 + t2);
    vec4 heightNormal = texture(neve, f00TexCoord);

    f00Normal = normalize(heightNormal.gba * 2f - 1f);

    vec3 p0 = gl_TessCoord.x * tcPosition[0];
    vec3 p1 = gl_TessCoord.y * tcPosition[1];
    vec3 p2 = gl_TessCoord.z * tcPosition[2];
    pc = vec4(p0 + p1 + p2, 1.f);

    float teNoise;
    teNoise = fbm(pc.xyz);
    //pc.y += teNoise; // adding height procedurally
    pc.y = f00HeightScale * heightNormal.r;
    f00HBase = heightNormal.r;

    f00EyeVector = normalize(viewPos - vec3(M * pc));

    vec4 c0 = gl_TessCoord.x * tcColor[0];
    vec4 c1 = gl_TessCoord.y * tcColor[1];
    vec4 c2 = gl_TessCoord.z * tcColor[2];
    f00Color = (c0 + c1 + c2);

    f00Position = pc.xyz;
    gl_Position = pc;



//    vec4 pc; ************************
//    vec4 heightNormal = texture(uHeightmap, uvc); //***********************************
//	  pc.y = uHeightScale * heightNormal.r;*************************
//	teEyeVector = normalize(uEyeWorldPosition - vec3(uModelMatrix * pc)); **************************
//	teNormal = normalize(heightNormal.gba * 2f - 1f); // Normal vector (in world space) *****************************
//	teHBase = heightNormal.r; *********************************
//
//	// Eye vector (in world space)
//
//	teUvCoordinates = uvc;
//
//
//	incUV = 1.0 / (gl_TessLevelInner[0] * (uSubdivisionCount + 1));

}
