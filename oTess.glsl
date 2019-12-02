//
//Tessellationcontrolshader.
//

//SetGLSLversion.Minimumversionthatsupportstessellationis4.0.
#version 400
//Specifynumbersofverticesout.
layout(vertices = 4 )out;

//Getsinvertexpositionfromthevertexshader.
in vec4 vPosition[];
//Sendsvertexpositionouttothetessellationevaluationsshader.
out vec4 tcPosition[];
//Uniforms.
//uniform float tessellationLevel;
uniform float scaleXY;
uniform float scaleZ;
//UniformcameraPositionusedwithdistancecalculations.
uniform vec3 cameraPosition;


//UniformtessellationMapandnormalMap.
uniform sampler2D tessellationMap;
uniform sampler2D normalMap;

//GetID.
#define ID glInvocationID
//
//NormalFromTexturetakesinthecolourvaluefromnormalmapandsubtract0.5,
//sincethenormalMapzerostartson0,5,thenwegetthevaluesfrom-0,5to0,5.
//Totheendwenormalizethevector.
//
vec3 NormalFromTexture(vec3 normal)
{
    normal.x = normal.x - 0.5f;
    normal.y = normal.y - 0.5f;
    normal.z = normal.z - 0.5f;
    normal   = normalize(normal);
    return normal;
};
//
//DistanceFactor
//
float DistanceFactor(float factor)
{
    int limit=50;

    if(factor > limit){
        factor = 0.f;
    }
    else{
        factor = (50.f-factor)/10.f;
    }
    return factor;
};
//
//vertexstructcontainsnormalanddistancetoavertexfromcameraPosition.
//
struct vertex
{
    vec3 vertexNormal;
    float distance;
};

//
//normalTessFactor
//

float normalTessFactor(vertex [6] array)
{
    //calculatetheanglesbetweenoppositecorners.
    float testangle     = acos( dot(array[0].vertexNormal, array[3].vertexNormal) );
    float testangle90   = acos( dot(array[2].vertexNormal, array[1].vertexNormal) );
    float testangle2    = acos( dot(array[0].vertexNormal, array[5].vertexNormal) );
    float testangle902  = acos( dot(array[1].vertexNormal, array[4].vertexNormal) );

    float factor=0;

    if(testangle > 0.90f || testangle90 > 0.90f || testangle2 > 0.90f || testangle902 > 0.90f) //usesradians
        return testangle + testangle90 + testangle2+ testangle902;

    return 0;

};

//
//Main.

//
void main(){
    //Passesthroughthevertexposition.
    tcPosition[ID]=vPosition[ID];

    //TestthatIDiszero.
    if(ID==0)
    {
        //
        //Tessellationbasedonnormals.
        //

        //Declarevertexstructforeachsideofthepatch.
        vertex [6] abvertices;
        vertex [6] advertices;
        vertex [6] dcvertices;
        vertex [6] bcvertices;

        /*
        //Vectorstomakeparallelpatchedgevectorsto
        comparenormals.        vec2left=vec2(-2,0);
        vec2right=vec2(2,0);
        vec2up=vec2(0,2);
        vec2down=vec2(0,-2);

        */
        //Vectorstomakeparallelpatchedgevectorstocomparenormals.
        vec2 left   = vec2(vPosition[0].xy - vPosition[1].xy);
        vec2 right  = vec2(vPosition[1].xy - vPosition[0].xy);
        vec2 up     = vec2(vPosition[1].xy - vPosition[2].xy);
        vec2 down   = vec2(vPosition[2].xy - vPosition[1].xy);
        //abVector.
        //SetnormalanddistancetothetwoverticesintheabVector.
        abvertices[0].vertexNormal = NormalFromTexture(texture(normalMap, vPosition[0].xy/scaleXY).xyz);
        abvertices[0].distance = distance(vPosition[0].xy, cameraPosition.xy);

        abvertices[1].vertexNormal = NormalFromTexture(texture(normalMap, vPosition[1].xy/scaleXY).xyz);
        abvertices[1].distance = distance(vPosition[1].xy, cameraPosition.xy);

        //Setnormalanddistancetothetwovertices(inthe abVector)addedtheleftvector.
        abvertices[2].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[0].xy + left)/scaleXY).xyz);
        abvertices[2].distance = distance(vPosition[0].xy + left, cameraPosition.xy);

        abvertices[3].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[1].xy + left)/scaleXY).xyz);
        abvertices[3].distance = distance(vPosition[1].xy + left, cameraPosition.xy);

        //Setnormalanddistancetothetwovertices(intheabVector)addedtherightvector.
        abvertices[4].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[0].xy + right)/scaleXY).xyz);
        abvertices[4].distance = distance(vPosition[0].xy + right, cameraPosition.xy);

        abvertices[5].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[1].xy + right)/scaleXY).xyz);
        abvertices[5].distance = distance(vPosition[1].xy + right, cameraPosition.xy);

        //adVector
        //SetnormalanddistancetothetwoverticesintheadVector.
        advertices[0].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[0].xy)/scaleXY).xyz);
        advertices[0].distance = distance(vPosition[0].xy, cameraPosition.xy);

        advertices[1].vertexNormal = NormalFromTexture(texture(normalMap, vPosition[3].xy/scaleXY).xyz);
        advertices[1].distance = distance(vPosition[3].xy, cameraPosition.xy);

        //Setnormalanddistancetothetwovertices(intheadVector)addedthedownvector.
        advertices[2].vertexNormal = NormalFromTexture(texture(normalMap, (vPosition[0].xy + down)/scaleXY).xyz);
        advertices[2].distance = distance(vPosition[0].xy + down, cameraPosition.xy);

        advertices[3].vertexNormal = NormalFromTexture(texture(normalMap, (vPosition[3].xy + down)/scaleXY).xyz);
        advertices[3].distance = distance(vPosition[3].xy + down, cameraPosition.xy);

        //Setnormalanddistancetothetwovertices(intheadVector)addedtheupvector.
        advertices[4].vertexNormal = NormalFromTexture(texture(normalMap, (vPosition[0].xy + up)/scaleXY).xyz);
        advertices[4].distance = distance(vPosition[0].xy + up, cameraPosition.xy);

        advertices[5].vertexNormal = NormalFromTexture(texture(normalMap, (vPosition[3].xy + up)/scaleXY).xyz);
        advertices[5].distance = distance(vPosition[3].xy + up, cameraPosition.xy);

        //dcVector.DothesametodcVectorasabVectorbecausetheyareparallel.
        dcvertices[0].vertexNormal = NormalFromTexture (texture(normalMap, (vPosition[3].xy/scaleXY).xyz) );
        dcvertices[0].distance = distance(vPosition[3].xy, cameraPosition.xy);

        dcvertices[1].vertexNormal = NormalFromTexture (texture(normalMap, (vPosition[2].xy)/scaleXY).xyz );
        dcvertices[1].distance = distance(vPosition[2].xy, cameraPosition.xy);

        dcvertices[2].vertexNormal = NormalFromTexture(texture(normalMap, (vPosition[3].xy+left)/scaleXY).xyz);
        dcvertices[2].distance = distance(vPosition[3].xy + left, cameraPosition.xy);

        dcvertices[3].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[2].xy+left)/scaleXY).xyz);
        dcvertices[3].distance = distance( vPosition[2].xy + left, cameraPosition.xy);

        dcvertices[4].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[3].xy+right)/scaleXY).xyz);
        dcvertices[4].distance = distance( vPosition[3].xy + right, cameraPosition.xy);

        dcvertices[5].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[2].xy+right)/scaleXY).xyz);
        dcvertices[5].distance = distance( vPosition[2].xy + right,cameraPosition.xy);

        //bcVector.DothesametobcVectorasadVectorbecausetheyareparallel.
        bcvertices[0].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[1].xy)/scaleXY).xyz);
        bcvertices[0].distance = distance( vPosition[1].xy ,cameraPosition.xy);
        bcvertices[1].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[2].xy)/scaleXY).xyz);
        bcvertices[1].distance = distance( vPosition[2].xy,cameraPosition.xy);

        bcvertices[2].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[1].xy+down)/scaleXY).xyz);
        bcvertices[2].distance = distance( vPosition[1].xy+down,cameraPosition.xy);

        bcvertices[3].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[2].xy+down)/scaleXY).xyz);
        bcvertices[3].distance = distance( vPosition[2].xy+down,cameraPosition.xy);

        bcvertices[4].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[1].xy+up)/scaleXY).xyz);

        bcvertices[4].distance = distance( vPosition[1].xy+up,cameraPosition.xy);

        bcvertices[5].vertexNormal = NormalFromTexture(texture(normalMap,(vPosition[2].xy+up)/scaleXY).xyz);
        bcvertices[5].distance = distance( vPosition[2].xy+up,cameraPosition.xy);

        //SendthearraystothenormalTessFactor.
        float abNormalTessellation = normalTessFactor(abvertices);
        float adNormalTessellation = normalTessFactor(advertices);
        float dcNormalTessellation = normalTessFactor(dcvertices);
        float bcNormalTessellation = normalTessFactor(bcvertices);

        //Calculatetheaveragetotheinnertessellation.
        float innerNormalTessellation = (abNormalTessellation + adNormalTessellation + dcNormalTessellation + bcNormalTessellation)/4;
        //
        //Distance
        //
        //calculatethepositiontotheedgesofthepatch.

        //Usethecoordinatefromtheterrain.
        vec3 abMidPos = vec3(vPosition[0].xyz+((vPosition[1].xyz - vPosition[0].xyz)/2));
        vec3 adMidPos = vec3(vPosition[0].xyz+((vPosition[3].xyz - vPosition[0].xyz)/2));
        vec3 dcMidPos = vec3(vPosition[3].xyz+((vPosition[2].xyz - vPosition[3].xyz)/2));
        vec3 bcMidPos = vec3(vPosition[1].xyz+((vPosition[2].xyz - vPosition[1].xyz)/2));

        //GettessellationfactorbysendingittoDistanceFactor.
        float abDistanceTessellation = DistanceFactor(distance(abMidPos,cameraPosition.xyz));
        float adDistanceTessellation = DistanceFactor(distance(adMidPos,cameraPosition.xyz));
        float dcDistanceTessellation = DistanceFactor(distance(dcMidPos,cameraPosition.xyz));
        float bcDistanceTessellation = DistanceFactor(distance(bcMidPos,cameraPosition.xyz));

        //Calculatetheaveragetotheinnertessellation.
        float innerDistanceTessellation = (abDistanceTessellation + adDistanceTessellation+
        dcDistanceTessellation + bcDistanceTessellation)/4;
        //

        //TessellationMap
        //
        //Thesecoordinatesisscaledtobeusedonthe        texture.
        vec2 abMidTexPos = vec2((vPosition[0].xy + ((vPosition[1].xy - vPosition[0].xy)/2))/scaleXY);
        vec2 adMidTexPos = vec2((vPosition[0].xy + ((vPosition[3].xy - vPosition[0].xy)/2))/scaleXY);
        vec2 dcMidTexPos = vec2((vPosition[3].xy + ((vPosition[2].xy - vPosition[3].xy)/2))/scaleXY);
        vec2 bcMidTexPos = vec2((vPosition[1].xy + ((vPosition[2].xy - vPosition[1].xy)/2))/scaleXY);
        float abTextureTessellation = texture(tessellationMap, abMidTexPos).r;
        float adTextureTessellation = texture(tessellationMap, adMidTexPos).r;
        float dcTextureTessellation = texture(tessellationMap, dcMidTexPos).r;
        float bcTextureTessellation = texture(tessellationMap, bcMidTexPos).r;

        //Calculatetheaveragetotheinnertessellation.
        float innerTextureTessellation = (abTextureTessellation + adTextureTessellation
                                          + dcTextureTessellation + bcTextureTessellation)/4;


        //Tessellationwithallthefactors.

        float normalTessellationWeight      = 5;
        float textureTessellationWeight     = 5;
        float distanceTessellationWeight    = 5;
        float constantTessellationWeight    = 1;
        glTessLevelInner[0] = 1 + (( constantTessellationWeight + innerNormalTessellation*normalTessellationWeight +
                                    innerTextureTessellation*textureTessellationWeight + innerDistanceTessellation*distanceTessellationWeight)/
                                 (constantTessellationWeight + normalTessellationWeight + textureTessellationWeight +
                                  distanceTessellationWeight))*tessellationLevel;
        glTessLevelInner[1] = 1 + (( constantTessellationWeight + innerNormalTessellation*normalTessellationWeight +
                                     innerTextureTessellation*textureTessellationWeight + innerDistanceTessellation*distanceTessellationWeight)/
                                 (constantTessellationWeight + normalTessellationWeight + textureTessellationWeight +
                                  distanceTessellationWeight))*tessellationLevel;


        glTessLevelOuter[0] = 1 + (( constantTessellationWeight + abNormalTessellation*normalTessellationWeight +
                                    abTextureTessellation*textureTessellationWeight + abDistanceTessellation*distanceTessellationWeight)/
                                   (constantTessellationWeight + normalTessellationWeight + textureTessellationWeight + distanceTessellationWeight))*tessellationLevel;

        glTessLevelOuter[1] = 1 + ((constantTessellationWeight + adNormalTessellation*normalTessellationWeight +
                                    adTextureTessellation*textureTessellationWeight + adDistanceTessellation*distanceTessellationWeight)/
                                   (constantTessellationWeight + normalTessellationWeight + textureTessellationWeight + distanceTessellationWeight))*tessellationLevel;

        glTessLevelOuter[2] = 1 + ((constantTessellationWeight + dcNormalTessellation*normalTessellationWeight +
                                    dcTextureTessellation*textureTessellationWeight + dcDistanceTessellation*distanceTessellationWeight)/
                                  (constantTessellationWeight + normalTessellationWeight + textureTessellationWeight + distanceTessellationWeight))*tessellationLevel;

        glTessLevelOuter[3] = 1 + ((constantTessellationWeight + bcNormalTessellation*normalTessellationWeight +
                                    bcTextureTessellation*textureTessellationWeight + bcDistanceTessellation*distanceTessellationWeight )/
                                   (constantTessellationWeight + normalTessellationWeight + textureTessellationWeight + distanceTessellationWeight))*tessellationLevel;

        /*
        //Tessellationwithdistance.
        glTessLevelInner[0]=tessellationLevel*
        innerDistanceTessellation+1;
        glTessLevelInner[1]=tessellationLevel*
        innerDistanceTessellation+1;
        glTessLevelOuter[0]=tessellationLevel*
        abDistanceTessellation+1;
        glTessLevelOuter[1]=tessellationLevel*
        adDistanceTessellation+1;
        glTessLevelOuter[2]=tessellationLevel*
        dcDistanceTessellation+1;
        glTessLevelOuter[3]=tessellationLevel*
        bcDistanceTessellation+1;
        */
        /*
        //TessellationwithNormal.
        glTessLevelInner[0]=tessellationLevel*
        innerNormalTessellation+1;
        glTessLevelInner[1]=tessellationLevel*
        innerNormalTessellation+1;

        glTessLevelOuter[0]=tessellationLevel*
        abNormalTessellation+1;
        glTessLevelOuter[1]=tessellationLevel*
        adNormalTessellation+1;
        glTessLevelOuter[2]=tessellationLevel*
        dcNormalTessellation+1;
        glTessLevelOuter[3]=tessellationLevel*
        bcNormalTessellation+1;
        */

        /*
        //TessellationwithTessellationMap.
        glTessLevelInner[0]=tessellationLevel*
        innerTextureTessellation+1;
        glTessLevelInner[1]=tessellationLevel*
        innerTextureTessellation+1;
        glTessLevelOuter[0]=tessellationLevel*
        abTextureTessellation+1;
        glTessLevelOuter[1]=tessellationLevel*
        adTextureTessellation+1;
        glTessLevelOuter[2]=tessellationLevel*
        dcTextureTessellation+1;
        glTessLevelOuter[3]=tessellationLevel*
        bcTextureTessellation+1;
        */
        /*
        //NoTessellation.
        glTessLevelInner[0]=tessellationLevel+1;
        glTessLevelInner[1]=tessellationLevel+1;
        glTessLevelOuter[0]=tessellationLevel+1;
        glTessLevelOuter[1]=tessellationLevel+1;
        glTessLevelOuter[2]=tessellationLevel+1;
        glTessLevelOuter[3]=tessellationLevel+1;
        */
    }
}
