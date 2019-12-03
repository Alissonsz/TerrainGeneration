#version 430 core

in vec3 fNormal;
in vec4 fColor;
in vec2 fTexCoord;
//in float vNoise;
in vec3 fPosition;
//in vec3 upNormal;
in vec3 tangentLightPos;
in vec3 tangentViewPos;
in vec3 tangentFragPos;

uniform sampler2D terra;
uniform sampler2D agua;
uniform sampler2D grama;
uniform sampler2D neve;
uniform sampler2D montanha;
uniform sampler2D texture1;
uniform sampler2D texture2;

uniform vec3 viewPos;
uniform int frag;
out vec4 fragColor;

 #define clamp01(x) clamp(x, 0.0, 1.0)

vec3 water = texture2D(agua, fTexCoord).xyz;
vec3 sand = texture2D(terra, fTexCoord).xyz;
vec3 grass = texture2D(grama, fTexCoord).xyz;
vec3 snow = texture2D(neve, fTexCoord).xyz;
vec3 rock = texture2D(montanha, fTexCoord).xyz;

vec3 lightColor = vec3(0.6,0.67,0.69);
vec3 diffuse = vec3(1.0f, 0.6f, 0.8f);
vec3 ambient = vec3(0.05f, 0.05f, 0.08f);
vec3 lightPos = vec3(1, 1.3, 1)*5;

float weightWater;
float weightStone;
float weightGrass;

vec3 fgNormal;

 vec3 heightblend(vec3 tex1, float height1, vec3 tex2, float height2)
{
    float heightBlendFactor = 1.f;
    float height_start = max(height1, height2 - 1) - heightBlendFactor;
    float level1 = max(height1 - height_start, 0);
    float level2 = max(height2 - height_start -1, 0);
    return ((tex1 * level1) + (tex2 * level2)) / (level1 + level2);
}

 vec3 surf(vec3 tex1, float h1, vec3 tex2, float h2)
{
    vec3 t1 = tex1;
    vec3 t2 = tex2;
    return heightblend (t1, h1, t2, h2);
}

#define clamp01(x) clamp(x, 0.0, 1.0)

vec2 parallaxBinarySearch(vec2 texCoords, vec3 viewDir){
    int binaryIter = 5;
    vec2 P = viewDir.xy * 0.3;

    vec2 prevCoords = texCoords;
    texCoords = texCoords + P;
    P = prevCoords;

    vec2 uvin = texCoords;
    vec2 uvout = P;

    vec2 currentCoords;
    float Hmax = 1.0f;
    float Hmin = 0.0f;

    for(int i=0; i<binaryIter; i++){
        float H = (Hmin + Hmax)/2; // middle
        currentCoords = uvin * H + uvout * (1 - H);
        float h = texture(texture1, currentCoords).r;

        if(H <= h) Hmin = H;
        else Hmax = H;
    }

    return currentCoords;
}

vec2 parallaxMapping(vec2 texCoords, vec3 viewDir){
    // number of depth layers
    const float numLayers = 60;
    // calculate the size of each layer
    float layerDepth = 1.0 / numLayers;
    // depth of current layer
    float currentLayerDepth = 0.0;
    // the amount to shift the texture coordinates per layer (from vector P)
    vec2 P = viewDir.xy * 0.3;


    vec2 deltaTexCoords = P / numLayers;
    vec2 prevCoords = texCoords;
    texCoords = texCoords + P;

    P = prevCoords;

    // get initial values
    vec2  currentTexCoords     = texCoords ;
    float currentDepthMapValue = 1 - texture(texture1, currentTexCoords).r;
    vec2 finalCoords;

    while(currentLayerDepth < currentDepthMapValue)
    {
        // shift texture coordinates along direction of P
        currentTexCoords -= deltaTexCoords;

        // get depthmap value at current texture coordinates

        currentDepthMapValue = 1 - texture(texture1, currentTexCoords).r;

        // get depth of next layer
        currentLayerDepth += layerDepth;

    }

    vec2 prevTexCoords = currentTexCoords + deltaTexCoords;

    // get depth after and before collision for linear interpolation
    float afterDepth  = currentDepthMapValue - currentLayerDepth;
    float beforeDepth = (1 - texture(texture1, prevTexCoords).r) - currentLayerDepth + layerDepth;

    // interpolation of texture coordinates
    float weight = afterDepth / (afterDepth - beforeDepth);
    vec2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

    return finalTexCoords;



}

void main(){
    vec3 X = dFdx(fPosition);
    vec3 Y = dFdy(fPosition);
    vec3 normal2 = normalize(cross(X,Y));
    //normal2 = normalize(cross(upNormal,normal2));
    //normal2 = normalize(cross(normal2,calcNormal(fPosition,fPosition.y)));
//    normal2 = normalize(cross(normal2,fNormal));
    if(fTexCoord.x > 1.0 || fTexCoord.y > 1.0 || fTexCoord.x < 0.0 || fTexCoord.y < 0.0) discard;
    float ambientStrength = 1;
    vec3 ambient = ambientStrength * lightColor;

    vec3 lightDir = normalize(lightPos - fPosition);

    float diff = max(dot(normal2, lightDir), 0);
    vec3 diffuse = diff * lightColor;

    float specularStrength = 0.01;

    vec3 viewDir = normalize(viewPos - fPosition);
    vec3 reflectDir = reflect(lightDir, fNormal);

    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 16);
    vec3 specular = specularStrength * spec * lightColor;
    vec3 result = (ambient + diffuse + specular);

    vec4 col;
    vec3 tmp;
    if(frag%2 == 0){
        bool parFlag = true;
        vec3 newPos;
        vec3 newNormal;

        vec2 texCoords = fTexCoord;

        vec3 viewDir = normalize(tangentViewPos - tangentFragPos);
        if(texCoords.x < 0.0 || texCoords.y < 0.0) discard;
        else if(parFlag)
            texCoords = parallaxMapping(fTexCoord, viewDir);
        else if(!parFlag)
            texCoords = parallaxBinarySearch(fTexCoord, viewDir);
        /*if(texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0)
            discard;*/


        newNormal = fNormal;//texture(texture1, vec2(texCoords.x, 0 + (1 - texCoords.y))).rgb;
        newNormal = normalize(newNormal);

        vec3 norm = newNormal;
        vec3 lightColor = texture(texture2, vec2(texCoords)).rgb;

        vec3 lightDir = normalize(tangentLightPos - tangentFragPos);
        float diff = max(dot(norm, -lightDir), 0.0);
        vec3 diffuse = diff * lightColor;

        float specularStrength = 0.8;

        vec3 reflectDir = reflect(-lightDir, norm);
        float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
        vec3 specular = specularStrength * spec * lightColor;


        float ambientStrength = 0.05;
        vec3 ambient = ambientStrength * lightColor;

        vec4 result = vec4(ambient + diffuse + specular, 1.0);
        col = result;
    }
    else{
        col = vec4(fTexCoord, 0.0f, 1.f);
    }
    fragColor = vec4(result, 1);
    fragColor = col;

}
