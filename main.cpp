#define STB_IMAGE_IMPLEMENTATION
#include <iostream>
#include <iomanip> 
#include <vector>
#include <math.h>
#include "stb_image.h"

unsigned char* heightMap;
int width, height, nrChannels;

double getEntropy(int topLeftX, int topLeftY, const int offset){
    std::vector<float> probs(256, 0);

    for(int i = topLeftY; i < topLeftY + offset; i++){
        for(int j = topLeftX; j < topLeftX + offset; j++){
            int curIndex = ((i * (width-1) + j) * 3);
            probs[heightMap[curIndex]]++;
        }
    }
    float entropy = 0;
    float entropySum = 0;
    int setSize = (offset * offset);
    for(int i = 0; i < 256; i++){
        if(probs[i] == 0) continue;
        entropySum += ((float(probs[i]/setSize)) * log2(float(probs[i]/setSize)));
        std::cout << entropySum << std::endl;
    }
    entropy = entropySum * -1;

    return entropy;
    
}

int main(){
    
    //stbi_set_flip_vertically_on_load(true); // tell stb_image.h to flip loaded texture's on the y-axis.
    heightMap = stbi_load("heightmap.jpg", &width, &height, &nrChannels, 0);

    //std::cout << width << " " << height << " " << nrChannels << std::endl;
    std::cout << getEntropy(0, 0, 512) << std::endl;

    return 0;
}