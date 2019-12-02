#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <typeinfo>
#include <cmath>

#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include <SOIL/stb_image_aug.h>
#include <SOIL/SOIL.h>
#include "simplex.h"
#include "LoadShaders.hpp"
//#include "controls.hpp"
//#include "vectormath/vectormath.h"

#define QTDTEXTURAS 5


const char* projectTitle = "Terrain";

using namespace glm;
using namespace std;

GLFWwindow* window;
float amp;
glm::vec3 lightPos;
GLuint programGeomID;
GLuint programTessID;
GLuint activeShader;

vector<unsigned short> indices;
vector<GLfloat> vertices;
vector<GLfloat> texcoord;

bool enablePolygon, enableCull,  noise=false;

static GLuint indexSize = 40.0;
static GLfloat meshSize = 160.0;

static GLsizei IndexCount;
static float TessLevelInner;
static float TessLevelOuter;

const char* filenames[QTDTEXTURAS] = {"container.jpg",
                                    "agua.jpg",
                                    "grama.jpg",
                                    "snow.jpg",
                                    "snowT.jpg"};

GLuint allTextures[QTDTEXTURAS];
float deltaTime = 0.0f;
float lastFrame = 0.0f;
bool firstMouse = true;


float px, py, pz;
int enableTess = 1, modeMouse=0, CPUnoise = 0;
int width, height, nrChannels;

GLuint MatrixID, ModelMatrixID, ViewMatrixID, ProjectionMatrixID,
    cameraPosIDX, cameraPosIDY, cameraPosIDZ, ampValue, octavesValue,
    lacunarityValue, LightID, TessLevelInnerID, TessLevelOuterID, TextureID,
    TextureID2, groundID, waterID, grassID, iceID, mountainID, enableTessID,
    VertexArrayID, vertexbuffer, elementbuffer, texturebuffer, pos2ID, noiseID;

int initGL();
int init();
void createBuffer();
void bindBuffer();
void deleteBuffers();
void clearVectors();
void createVerticesIndexes();
void disableVertexAttribs();
void createProgram();
void deleteProgram();
void createTextures();
void setUnifLoc();
void setUnif();
void draw();
void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset);
void swapBuffers();

/*

float noised(vec2 x) {
	vec2 i = floor(x);
	vec2 f = fract(x);

	// Four corners in 2D of a tile
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

vec3 noised3(vec2 x)
{
    vec2 f = fract(x);
    vec2 u = f*f*(3.0-2.0*f);

    // texel fetch version
    vec2 p = vec2(floor(x));
    float a = hash(p+vec2(0,0));
	float b = hash(p+vec2(1,0));
	float c = hash(p+vec2(0,1));
	float d = hash(p+vec2(1,1));

	return vec3(a+(b-a)*u.x+(c-a)*u.y+(a-b-c+d)*u.x*u.y,
				6.0*f*(1.0-f)*(vec2(b-a,c-a)+(a-b-c+d)*u.yx));
}

const mat2 m2 = mat2(0.8,-0.6,0.6,0.8);
const mat2 m22 = mat2(0.8*2.f,-0.6*2.f,0.6*2.f,0.8*2.f);

float fbm(vec2 p){
    float f = 0.0;
    f += 0.5000*noised( p ); p = m22*p*4.04;
    f += 0.2500*noised( p ); p = m22*p*4.06;
    f += 0.1250*noised( p ); p = m22*p*4.02;
    f += 0.0625*noised( p );

    return f/0.9375;
}

vec3 no(vec2 p)
{
    vec2 f=p-floor(p);
    vec2 u=f*f*f*(f*(f*6-15)+10);
    float a = hash(floor(p)+vec2(0,0));
	float b = hash(floor(p)+vec2(1,0));
	float c = hash(floor(p)+vec2(0,1));
	float d = hash(floor(p)+vec2(1,1));
    return vec3(a+(b-a)*u.x+(c-a)*u.y+(a-b-c+d)*u.x*u.y,30*f*f*(f*(f-2)+1)*(vec2(b-a,c-a)+(a-b-c+d)*u.yx));
}

float f(vec2 p){
    float o = 16.f;
    vec2 d =vec2(0.f,0.f);
    float a=0.f;
    float b=3.f;
    for(int i = 0;i<o;i++)
    {
        vec3 n=no(.25*p);
        d+=n.yz;
        a+=(b*=.5)*n.x/(1+dot(d,d));
        p=(m2*p);
    }
    return a;
}




mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float hash( float n )
{
    return fract(sin(n)*43758.5453123);
}


float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}




vec3 noised( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    vec2 u = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0;

    float a = hash(n+  0.0);
    float b = hash(n+  1.0);
    float c = hash(n+ 57.0);
    float d = hash(n+ 58.0);
	return vec3(a+(b-a)*u.x+(c-a)*u.y+(a-b-c+d)*u.x*u.y,
				30.0*f*f*(f*(f-2.0)+1.0)*(vec2(b-a,c-a)+(a-b-c+d)*u.yx));

}

float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0;

    float res = mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                    mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);

    return res;
}

float fbm( vec3 p )
{
    float f = 0.0;

    f += 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );

    return f/0.9375;
}

mat2 m2 = mat2(1.6,-1.2,1.2,1.6);

float fbm( vec2 p )
{
    float f = 0.0;

    f += 0.5000*noise( p ); p = m2*p*2.02;
    f += 0.2500*noise( p ); p = m2*p*2.03;
    f += 0.1250*noise( p ); p = m2*p*2.01;
    f += 0.0625*noise( p );

    return f/0.9375;
}

*/
