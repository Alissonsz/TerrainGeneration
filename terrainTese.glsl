#version 430 core
#extension GL_EXT_gpu_shader4 : enable
#define F3 0.333333333
#define G3 0.166666667

layout(triangles, equal_spacing, ccw) in;

uniform mat4 P;
uniform mat4 V;
uniform mat4 MVP;
uniform int oct;
uniform float lac;
uniform sampler2D texture1;
uniform vec3 viewPos;
//uniform bool noised;

in vec3 tcPosition[];
in vec4 tcColor[];
in vec2 tcTexCoord[];
in vec3 tcNormal[];
in float tcFactor[];

out float f00Height;
out float f00Factor;
out vec3 f00Position;
out vec4 f00Color;
out vec2 f00TexCoord;
out vec3 f00Normal;

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

float ridgedNoise(in vec3 p, int octaves, float H, float gain, float amplitude, float frequency, float persistence, float offset)
{
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

uniform float mesh;

float LOD(float dist){
  float T = 4*mesh/(0.5*dist);
  if(T > 64)
      return 64.f;
  else if(T < 1)
      return 1.f;
  return T;
}

void main(){
  vec3 p0 = gl_TessCoord.x * tcPosition[0];
  vec3 p1 = gl_TessCoord.y * tcPosition[1];
  vec3 p2 = gl_TessCoord.z * tcPosition[2];
  f00Position = (p0 + p1 + p2);

  vec3 edge01 = tcPosition[1]-tcPosition[0];
  vec3 edge02 = tcPosition[2]-tcPosition[0];

  vec4 c0 = gl_TessCoord.x * tcColor[0];
  vec4 c1 = gl_TessCoord.y * tcColor[1];
  vec4 c2 = gl_TessCoord.z * tcColor[2];
  f00Color = (c0 + c1 + c2);

  vec2 t0 = gl_TessCoord.x * tcTexCoord[0];
  vec2 t1 = gl_TessCoord.y * tcTexCoord[1];
  vec2 t2 = gl_TessCoord.z * tcTexCoord[2];
  f00TexCoord = (t0 + t1 + t2);

  float f0 = gl_TessCoord.x * tcFactor[0];
  float f1 = gl_TessCoord.y * tcFactor[1];
  float f2 = gl_TessCoord.z * tcFactor[2];
  f00Factor = (f0 + f1 + f2);

  f00Factor = LOD(distance(viewPos, f00Position));


  vec4 heightNormal = texture(texture1, f00TexCoord);

  f00Height = fbm(f00Position.xyz*0.05) + heightNormal.r*22;

//  f00Position.y += f00Height;

  gl_Position = vec4(f00Position, 1.0);
}
