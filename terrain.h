typedef struct terrainNode_t terrainNode_t;
struct terrainNode_t {
	float origin[3];
	float width;
	float height;
	int type; // 1, 2, 3, 4 -- the child # relative to its parent. (0 == root)

	// Tessellation scale
	float tscale_negx; // negative x edge
	float tscale_posx; // Positive x edge
	float tscale_posy; // Positive y edge
	float tscale_negy; // Negative y edge
	float tscale_negz; // Negative z edge
	float tscale_posz; // Positive z edge

	terrainNode_t *p; // Parent
	terrainNode_t *c1; // Children
	terrainNode_t *c2;
	terrainNode_t *c3;
	terrainNode_t *c4;

	terrainNode_t *n; // Neighbor to north
	terrainNode_t *s; // Neighbor to south
	terrainNode_t *e; // Neighbor to east
	terrainNode_t *w; // Neighbor to west
};


// The size of a patch in meters at which point to
// stop subdividing a terrain patch once it's width is
// less than the cutoff
#define VMB_TERRAIN_REC_CUTOFF 200

void terrain_init();
void terrain_shutdown();
void terrain_render();
void terrain_createTree(float x, float y, float z, float width, float height);
