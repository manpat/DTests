module game.tile;

import gl;

struct Tile {
	uint id = 0;
	vec3 position = vec3(0,0,0);
	vec3 color = vec3(1,1,1);
	uint flags = 0;
}