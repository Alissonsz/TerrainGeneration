#include "Util.hpp"
#include "camera.h"

double previousTime = glfwGetTime();
int frameCount = 0;

Camera camera(glm::vec3(75.0f, 15.0f, 75.0f));

int main(int argv, char** argc){
    init();

    createBuffer();

    createProgram();
    createVerticesIndexes();
    bindBuffer();

    createTextures();

    activeShader = programTessID;
    do{

        float currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        // Clear the screen

        camera.pressButtons();
        setUnif();
        draw();
        disableVertexAttribs();

        swapBuffers();
    }

    while( glfwGetKey(window, GLFW_KEY_ESCAPE ) != GLFW_PRESS &&
        glfwWindowShouldClose(window) == 0 );

    deleteBuffers();
    deleteProgram();

    glfwTerminate();

    return 0;
}

int initGL(){
    glfwInit();
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

	window = glfwCreateWindow( WIDTH, HEIGHT, projectTitle, NULL, NULL);
	if( window == NULL ){
    cout << "Failed to open GLFW window. If you have an Intel GPU, they are not 3.3 compatible. Try the 2.1 version of the tutorials.\n";
		glfwTerminate();
		return -1;
	}
	glfwMakeContextCurrent(window);

	glewExperimental = true;
	if (glewInit() != GLEW_OK) {
		cout<<"Failed to initialize GLEW\n";
		glfwTerminate();
		return -1;
	}

	return 0;
}

int init(){
    initGL();

    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    glfwSetCursorPosCallback(window, mouse_callback);
    glfwSetScrollCallback(window, scroll_callback);

    // tell GLFW to capture our mouse
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

    glfwPollEvents();
    glfwSetCursorPos(window, WIDTH/2, HEIGHT/2);

	glClearColor(0.7f, 0.7f, 0.9f, 1.0f);

    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);
}

void createBuffer(){
	glGenVertexArrays(1, &VertexArrayID);
    glGenBuffers(1, &vertexbuffer);
    glGenBuffers(1, &elementbuffer);
}

void bindBuffer(){
    glBindVertexArray(VertexArrayID);

    glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
    glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(GLfloat), vertices.data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementbuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(GLushort), &indices[0], GL_STATIC_DRAW);

    glGenBuffers(1, &texturebuffer);
    glBindBuffer(GL_ARRAY_BUFFER, texturebuffer);
    glBufferData(GL_ARRAY_BUFFER, texcoord.size() * sizeof(GLfloat), texcoord.data(), GL_STATIC_DRAW);
}

void deleteBuffers(){
    glDeleteVertexArrays(1, &VertexArrayID);
    glDeleteBuffers(1, &vertexbuffer);
    glDeleteBuffers(1, &elementbuffer);
    glDeleteBuffers(1, &texturebuffer);
}

void clearVectors(){
    indices.clear();
    vertices.clear();
    texcoord.clear();
}

void createVerticesIndexes(){
    float tamAmostra = meshSize / (float)indexSize;
    for (GLuint i = 0; i < indexSize ; i++){
		for (GLuint j = 0; j < indexSize ; j++) {
			indices.push_back( i*(indexSize+1)  + j);		// V0
			indices.push_back( i*(indexSize+1)  + (j+1));	// V3
			indices.push_back( (i+1)*(indexSize+1) 	+ j);		// V2

			indices.push_back( i*(indexSize+1) 	    + (j+1));		// V2
			indices.push_back( (i+1)*(indexSize+1) 	+ (j+1));		// V2
			indices.push_back( (i+1)*(indexSize+1)  + j);	// V1
		}
	}

  	for (GLfloat i = 1 ; i <= indexSize +1; i+=1.0){
		for (GLfloat j = 1 ; j <= indexSize +1; j+=1.0) {
      		glm::vec2 vert = vec2((float)(i*tamAmostra), (float)(j*tamAmostra));
      		float h=0;
	  			glm::vec3 v3 = vec3(vert.x, h, vert.y);
	  			h += Simplex::ridgedNoise(v3);


	      vertices.push_back(vert.x);
	      vertices.push_back(h);
	      vertices.push_back(vert.y);
	      texcoord.push_back((float)i);
	      texcoord.push_back((float)j);
		}
	}
}

void disableVertexAttribs(){
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
}

void createProgram(){
   // programTessID = LoadShaders( "terrainVert.glsl", "terrainFrag.glsl");
    //programTessID = LoadShaders( "terrainVert.glsl", "terrainTesc.glsl", "terrainTese.glsl", "terrainFrag.glsl");
    programTessID = LoadShaders( "terrainVert.glsl", "terrainTesc.glsl", "terrainTese.glsl", "terrainGeo.glsl","terrainFrag.glsl");
    cout<<programTessID<<endl;

//  programTessID = LoadShaders( "basinTerrain.glsl", "basicTerrainfrag.glsl");
    //programGeomID  = LoadShaders( "terrenofBm.vert", "Geodesic.geom", "Geodesic.frag");
}

void deleteProgram(){
    glDeleteProgram(programTessID);
    glDeleteProgram(programGeomID);
}

void createTextures(){
    for(int i = 0; i < QTDTEXTURAS; i++){
        unsigned char* texturas;

        glGenTextures(1, &allTextures[i]);

        // all upcoming GL_TEXTURE_2D operations now have effect on this texture object
        // set the texture wrapping parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        // set texture filtering parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        // load image, create texture and generate mipmaps
        // The FileSystem::getPath(...) is part of the GitHub repository so we can find files on any IDE/platform; replace it with your own image path.
        texturas = SOIL_load_image(filenames[i], &width, &height, &nrChannels, SOIL_LOAD_RGB);
        if (texturas)
        {
            glActiveTexture(GL_TEXTURE0 + i);
            glBindTexture(GL_TEXTURE_2D, allTextures[i]);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, texturas);
            glGenerateMipmap(GL_TEXTURE_2D);
        }
        else
        {
            std::cout << "Failed to load texture" << filenames[i] << std::endl;
        }
        stbi_image_free(texturas);
    }
}

void setUnif(){
        glUseProgram(activeShader);
//    computeMatricesFromInputs(window);
    glm::mat4 MVP = camera.getProjectionMatrix(WIDTH, HEIGHT) * camera.getViewMatrix() * glm::mat4(1.0);
    float px = camera.Position.x; float py = camera.Position.y; float pz = camera.Position.z;

    glm::mat4 VM = camera.getViewMatrix();
    glm::mat4 M = glm::mat4(1.0);
    glm::mat4 V = VM * M;
    glm::mat4 N = glm::transpose(glm::inverse(V));
    glUniformMatrix4fv(glGetUniformLocation(activeShader, "MVP"), 1, GL_FALSE, &MVP[0][0]);
    glUniformMatrix4fv(glGetUniformLocation(activeShader, "V"), 1, GL_FALSE, &V[0][0]);
    glUniformMatrix4fv(glGetUniformLocation(activeShader, "M"), 1, GL_FALSE, &M[0][0]);
    glUniformMatrix4fv(glGetUniformLocation(activeShader, "N"), 1, GL_FALSE, &N[0][0]);

    glUniform3f(glGetUniformLocation(activeShader, "viewPos"), camera.Position.x, camera.Position.y, camera.Position.z);
    glUniform1i(glGetUniformLocation(activeShader, "terra"), 0);
    glUniform1i(glGetUniformLocation(activeShader, "agua"),  1);
    glUniform1i(glGetUniformLocation(activeShader, "grama"), 2);
    glUniform1i(glGetUniformLocation(activeShader, "neve"), 3);
    glUniform1i(glGetUniformLocation(activeShader, "montanha"), 4);
    glUniform1i(glGetUniformLocation(activeShader, "texture1"), 5);
    glUniform1i(glGetUniformLocation(activeShader, "texture2"), 6);
    glUniform1i(glGetUniformLocation(activeShader, "tess"), enableTess);
    glUniform1f(glGetUniformLocation(activeShader, "noised"), noise);
    glUniform1i(glGetUniformLocation(activeShader, "frag"), CPUnoise);
    glUniform1f(glGetUniformLocation(activeShader, "mesh"), meshSize);
}

void draw(){

	// Measure speed
    double currentTime = glfwGetTime();
    frameCount++;
    // If a second has passed.
    if ( currentTime - previousTime >= 1.0 )
    {
        // Display the frame count here any way you want.
        //cout<<frameCount<<endl;

        frameCount = 0;
        previousTime = currentTime;
    }

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //if(programTessID > 3)
    glPatchParameteri(GL_PATCH_VERTICES, 3);

    // 1rst attribute buffer : vertices
    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (void*)0);

    // color attribute
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));

    // texture coord attribute
    glEnableVertexAttribArray(2);
    glBindBuffer(GL_ARRAY_BUFFER, texturebuffer);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 0, (void*)0);

    // indexSize buffer
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementbuffer);
    //if(programTessID > 3){
        glDrawElements(GL_PATCHES, indices.size(), GL_UNSIGNED_SHORT, (void*)0);

    //}
   // else{
       // glDrawElements(GL_TRIANGLES, indices.size(), GL_UNSIGNED_SHORT, (void*)0);
    //}
}

void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    // make sure the viewport matches the new window dimensions; note that width and
    // height will be significantly larger than specified on retina displays.
    glViewport(0, 0, width, height);
}

void mouse_callback(GLFWwindow* window, double xpos, double ypos)
{
    if (firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }

    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos; // reversed since y-coordinates go from bottom to top

    lastX = xpos;
    lastY = ypos;

    camera.ProcessMouseMovement(xoffset, yoffset);
}

// glfw: whenever the mouse scroll wheel scrolls, this callback is called
// ----------------------------------------------------------------------
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
{
    camera.ProcessMouseScroll(yoffset);
}

void swapBuffers(){
    // Swap buffers
    glfwSwapBuffers(window);
    glfwPollEvents();
}
