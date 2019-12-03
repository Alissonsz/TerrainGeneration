//#include <stdio.h>
//#include "GL/glus.h"
//#include "terrain.h"
//
//terrainNode_t *terrainTree;
//terrainNode_t *terrainTreeTail;
//int numTerrainNodes = 0;
//
//#define MAX_TERRAIN_NODES 500
//
//extern float camPos[4];
//
///**
//* Allocates a new node in the terrain quadtree with the specified parameters.
//*/
//terrainNode_t* createNode(terrainNode_t *parent, int type, float x, float y, float z, float width, float height)
//{
//	if (numTerrainNodes >= MAX_TERRAIN_NODES)
//		return NULL;
//	numTerrainNodes++;
//
//	terrainTreeTail++;
//	terrainTreeTail->type = type;
//	terrainTreeTail->origin[0] = x;
//	terrainTreeTail->origin[1] = y;
//	terrainTreeTail->origin[2] = z;
//	terrainTreeTail->width = width;
//	terrainTreeTail->height = height;
//	terrainTreeTail->tscale_negx = 1.0;
//	terrainTreeTail->tscale_negz = 1.0;
//	terrainTreeTail->tscale_posx = 1.0;
//	terrainTreeTail->tscale_posz = 1.0;
//	terrainTreeTail->p = parent;
//	terrainTreeTail->n = NULL;
//	terrainTreeTail->s = NULL;
//	terrainTreeTail->e = NULL;
//	terrainTreeTail->w = NULL;
//	return terrainTreeTail;
//}
//
///**
//* Resets the terrain quadtree.
//*/
//void terrain_clearTree()
//{
//	terrainTreeTail = terrainTree;
//	memset(terrainTree, 0, MAX_TERRAIN_NODES * sizeof(terrainNode_t));
//	numTerrainNodes = 0;
//}
//
///**
//* Determines whether a node should be subdivided based on its distance to the camera.
//* Returns true if the node should be subdivided.
//*/
//GLboolean checkDivide(terrainNode_t *node)
//{
//	// Distance from current origin to camera
//	float d = abs(sqrt(pow(camPos[0] - node->origin[0], 2.0) + pow(camPos[1] - node->origin[1], 2.0)+ pow(camPos[2] - node->origin[2], 2.0)));
//
//	// Check base case:
//	// Distance to camera is greater than twice the length of the diagonal
//	// from current origin to corner of current square.
//	// OR
//	// Max recursion level has been hit
//	if (d > 2.0 * sqrt(pow(0.5 * node->width, 2.0) + pow(0.5 * node->height, 2.0)) || node->width < VMB_TERRAIN_REC_CUTOFF)
//	{
//		return GL_FALSE;
//	}
//
//	return GL_TRUE;
//}
//
///**
//* Returns true if node is sub-divided. False otherwise.
//*/
//GLboolean terrain_divideNode(terrainNode_t *node)
//{
//	// Subdivide
//	float w_new = 0.5 * node->width;
//	float h_new = 0.5 * node->height;
//
//	// Create the child nodes
//	node->c1 = createNode(node, 1, node->origin[0] - 0.5 * w_new, node->origin[1], node->origin[2] - 0.5 * h_new, w_new, h_new);
//	node->c2 = createNode(node, 2, node->origin[0] + 0.5 * w_new, node->origin[1], node->origin[2] - 0.5 * h_new, w_new, h_new);
//	node->c3 = createNode(node, 3, node->origin[0] + 0.5 * w_new, node->origin[1], node->origin[2] + 0.5 * h_new, w_new, h_new);
//	node->c4 = createNode(node, 4, node->origin[0] - 0.5 * w_new, node->origin[1], node->origin[2] + 0.5 * h_new, w_new, h_new);
//
//	// Assign neighbors
//	if (node->type == 1)
//	{
//		node->e = node->p->c2;
//		node->n = node->p->c4;
//	}
//	else if (node->type == 2)
//	{
//		node->w = node->p->c1;
//		node->n = node->p->c3;
//	}
//	else if (node->type == 3)
//	{
//		node->s = node->p->c2;
//		node->w = node->p->c4;
//	}
//	else if (node->type == 4)
//	{
//		node->s = node->p->c1;
//		node->e = node->p->c3;
//	}
//
//	// Check if each of these four child nodes will be subdivided.
//	GLboolean div1, div2, div3, div4;
//	div1 = checkDivide(node->c1);
//	div2 = checkDivide(node->c2);
//	div3 = checkDivide(node->c3);
//	div4 = checkDivide(node->c4);
//
//	if (div1)
//		terrain_divideNode(node->c1);
//	if (div2)
//		terrain_divideNode(node->c2);
//	if (div3)
//		terrain_divideNode(node->c3);
//	if (div4)
//		terrain_divideNode(node->c4);
//}
//
///**
//* Builds a terrain quadtree based on specified parameters and current camera position.
//*/
//void terrain_createTree(float x, float y, float z, float width, float height)
//{
//	terrain_clearTree();
//
//	terrainTree->type = 0; // Root node
//	terrainTree->origin[0] = x;
//	terrainTree->origin[1] = y;
//	terrainTree->origin[2] = z;
//	terrainTree->width = width;
//	terrainTree->height = height;
//	terrainTree->tscale_negx = 1.0;
//	terrainTree->tscale_negz = 1.0;
//	terrainTree->tscale_posx = 1.0;
//	terrainTree->tscale_posz = 1.0;
//	terrainTree->p = NULL;
//	terrainTree->n = NULL;
//	terrainTree->s = NULL;
//	terrainTree->e = NULL;
//	terrainTree->w = NULL;
//
//	// Recursively subdivide the terrain
//	terrain_divideNode(terrainTree);
//}
//
///**
//* Reserves memory for the terrrain quadtree and initializes the data structure.
//*/
//void terrain_init()
//{
//	terrainTree = (terrainNode_t*)malloc(MAX_TERRAIN_NODES * sizeof(terrainNode_t));
//	terrain_clearTree();
//}
//
///**
//* Frees memory for the terrain quadtree.
//*/
//void terrain_shutdown()
//{
//	free(terrainTree);
//	terrainTree = NULL;
//	terrainTreeTail = NULL;
//}
//
///**
//* Search for a node in the tree.
//* x, z == the point we are searching for (trying to find the node with an origin closest to that point)
//* n = the current node we are testing
//*/
//terrainNode_t *find(terrainNode_t* n, float x, float z)
//{
//	if (n->origin[0] == x && n->origin[2] == z)
//		return n;
//
//	if (n->c1 == NULL && n->c2 == NULL && n->c3 == NULL && n->c4 == NULL)
//		return n;
//
//	if (n->origin[0] >= x && n->origin[2] >= z && n->c1)
//		return find(n->c1, x, z);
//	else if (n->origin[0] <= x && n->origin[2] >= z && n->c2)
//		return find(n->c2, x, z);
//	else if (n->origin[0] <= x && n->origin[2] <= z && n->c3)
//		return find(n->c3, x, z);
//	else if (n->origin[0] >= x && n->origin[2] <= z && n->c4)
//		return find(n->c4, x, z);
//
//	return n;
//}
//
///**
//* Calculate the tessellation scale factor for a node depending on the neighboring patches.
//*/
//void calcTessScale(terrainNode_t *node)
//{
//	terrainNode_t *t;
//
//	// Positive Z (north)
//	t = find(terrainTree, node->origin[0], node->origin[2] + 1 + node->width / 2.0);
//	if (t->width > node->width)
//		node->tscale_posz = 2.0;
//
//	// Positive X (east)
//	t = find(terrainTree, node->origin[0] + 1 + node->width / 2.0, node->origin[2]);
//	if (t->width > node->width)
//		node->tscale_posx = 2.0;
//
//	// Negative Z (south)
//	t = find(terrainTree, node->origin[0], node->origin[2] - 1 - node->width / 2.0);
//	if (t->width > node->width)
//		node->tscale_negz = 2.0;
//
//	// Negative X (west)
//	t = find(terrainTree, node->origin[0] - 1 - node->width / 2.0, node->origin[2]);
//	if (t->width > node->width)
//		node->tscale_negx = 2.0;
//}
//
///**
//* Pushes a node (patch) to the GPU to be drawn.
//* note: height parameter is here but not used. currently only dealing with square terrains (width is used only)
//*/
//void terrain_renderNode(terrainNode_t *node)
//{
//	// Calculate the tess scale factor
//	calcTessScale(node);
//
//	// Setup matrices
//	glusMatrix4x4Identityf(g_mvMatrix);
//	glusMatrix4x4Identityf(g_mMatrix);
//	glusMatrix4x4Translatef(g_mMatrix, node->origin[0], node->origin[1], node->origin[2]);
//	glusMatrix4x4Multiplyf(g_mvMatrix, g_vMatrix, g_mMatrix);
//
//	GLuint matrix = glGetUniformLocation(g_program.program, "mMatrix");
//	glUniformMatrix4fv(matrix, 1, GL_FALSE, g_mMatrix);
//	matrix = glGetUniformLocation(g_program.program, "mvMatrix");
//	glUniformMatrix4fv(matrix, 1, GL_FALSE, g_mvMatrix);
//
//	// Calc normal matrix
//	glusMatrix4x4ExtractMatrix3x3f(g_nMatrix, g_mvMatrix);
//	glusMatrix3x3Transposef(g_nMatrix);
//	glusMatrix3x3Inversef(g_nMatrix);
//
//	matrix = glGetUniformLocation(g_program.program, "nMatrix");
//	glUniformMatrix3fv(matrix, 1, GL_FALSE, g_nMatrix);
//
//	// Send the size of the patch to the GPU
//	GLuint temp = glGetUniformLocation(g_program.program, "tileScale");
//	glUniform1f(temp, 0.5 * node->width);
//
//	// Send patch neighbor edge tess scale factors
//	temp = glGetUniformLocation(g_program.program, "tscale_negx");
//	glUniform1f(temp, node->tscale_negx);
//	temp = glGetUniformLocation(g_program.program, "tscale_negz");
//	glUniform1f(temp, node->tscale_negz);
//	temp = glGetUniformLocation(g_program.program, "tscale_posx");
//	glUniform1f(temp, node->tscale_posx);
//	temp = glGetUniformLocation(g_program.program, "tscale_posz");
//	glUniform1f(temp, node->tscale_posz);
//
//	// Do it
//	glDrawElements(GL_PATCHES, 4, GL_UNSIGNED_INT, 0);
//}
//
//int maxRenderDepth = 1;
//int renderDepth = 0;
//
///**
//* Traverses the terrain quadtree to draw nodes with no children.
//*/
//void terrain_renderRecursive(terrainNode_t *node)
//{
//	//if (renderDepth >= maxRenderDepth)
//	//	return;
//
//	// If all children are null, render this node
//	if (!node->c1 && !node->c2 && !node->c3 && !node->c4)
//	{
//		terrain_renderNode(node);
//		renderDepth++;
//		return;
//	}
//
//	// Otherwise, recruse to the children.
//	// Note: we're checking if the child exists. Theoretically, with our algorithm,
//	// either all the children are null or all the children are not null.
//	// There shouldn't be any other cases, but we check here for safety.
//	if (node->c1)
//		terrain_renderRecursive(node->c1);
//	if (node->c2)
//		terrain_renderRecursive(node->c2);
//	if (node->c3)
//		terrain_renderRecursive(node->c3);
//	if (node->c4)
//		terrain_renderRecursive(node->c4);
//}
//
///**
//* Draw the terrrain.
//*/
//void terrain_render()
//{
//	renderDepth = 0;
//
//	terrain_renderRecursive(terrainTree);
//}
