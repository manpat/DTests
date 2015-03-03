module game.tilemanager;

import game.tile;

import std.stdio;
import vertexarray;
import shader;
import gl;

alias ubvec3 = Vector!(ubyte, 3);

ubvec3 idToColor(uint id){
	ubvec3 color;
	color.r = id & 0xff;
	color.g = (id >> 8) & 0xff;
	color.b = (id >> 16) & 0xff;

	return color;
}

uint colorToId(ubvec3 c){
	uint id = 0;
	id |= c.r;
	id |= c.g << 8;
	id |= c.b << 16;
	return id;
}

class TileManager {
	Tile[] map;
	uint width, height;

	VertexArray!vec3 tileQuad;
	VertexArray!Tile instData;
	VertexArray!ubvec3 idArray;

	this(uint _w, uint _h){
		width = _w;
		height = _h;
		float tilesep = 0f;

		map = new Tile[width*height];
		uint id = 0;
		foreach(y; 0 .. height)
			foreach(x; 0 .. width){
				int c = y * width + x;

				map[c].position = vec3(
					x*(2f + tilesep) - width + 1f - tilesep*width/2f, 
					0, 
					y*(2f + tilesep) - height + 1f - tilesep*height/2f);

				float a = ((x+y+1)%2)*0.3;
				//map[c].color = vec3((x+y)%2 + a, x%2 + a, y%2 + a).normalized * 1.2f;
				map[c].color = vec3(0.3f);
				map[c].id = 1 + c;
			}

		instData = new VertexArray!Tile();
		instData.Load(map); // Update tile data

		idArray = new VertexArray!ubvec3();
		auto ids = new ubvec3[width*height];

		foreach(i; 0..width*height){
			ids[i] = idToColor(map[i].id);
		} 
		idArray.Load(ids);

		tileQuad = new VertexArray!vec3();
		tileQuad.Load([
			vec3(-1, 0,-1),
			vec3( 1, 0, 1),
			vec3(-1, 0, 1),
			
			vec3(-1, 0,-1),
			vec3( 1, 0,-1),
			vec3( 1, 0, 1),
		]);
	}

	Tile* GetTile(uint x, uint y){
		uint i = x + y * width;
		if(i < width*height) return &map[i];

		return null;
	}
	Tile* GetTileByID(uint id){
		// ids start at 1
		if(id > 0 && id <= width*height) return &map[id-1];

		return null;
	}

	void Render(){
		auto sh = GetActiveShader();
		auto posAttr = sh.GetAttribute("position");
		auto colAttr = sh.GetAttribute("color");
		auto offAttr = sh.GetAttribute("offset");
		auto flagsAttr = sh.GetAttribute("flags");

		instData.Load(map); // Update tile data

		tileQuad.Bind(posAttr);
		instData.Bind!(vec3, "position")(offAttr);
		instData.Bind!(vec3, "color")(colAttr);
		instData.Bind!(uint, "flags")(flagsAttr);
		colAttr.SetDivisor(1);
		offAttr.SetDivisor(1);
		flagsAttr.SetDivisor(1);

		glPointSize(4);
		cgl!glDrawArraysInstanced(GL_TRIANGLES, 0, tileQuad.length, instData.length);
		//cgl!glDrawArraysInstanced(GL_POINTS, 0, tileQuad.length, instData.length);

		colAttr.SetDivisor(0);
		offAttr.SetDivisor(0);
		flagsAttr.SetDivisor(0);
		instData.Unbind();
		tileQuad.Unbind();
	}

	Tile* PickTile(uint x, uint y){
		auto sh = GetActiveShader();
		auto posAttr = sh.GetAttribute("position");
		auto colAttr = sh.GetAttribute("color");
		auto offAttr = sh.GetAttribute("offset");
		auto flagsAttr = sh.GetAttribute("flags");

		posAttr.Enable();
		colAttr.Enable();
		offAttr.Enable();
		flagsAttr.Enable();

		tileQuad.Bind(posAttr);
		idArray.Bind(colAttr);
		instData.Bind!(vec3, "position")(offAttr);
		instData.Bind!(uint, "flags")(flagsAttr);

		colAttr.SetDivisor(1);
		offAttr.SetDivisor(1);
		flagsAttr.SetDivisor(1);
		sh.SetUniform("isPicking", true);

		glClearColor(0f, 0f, 0f, 1f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		cgl!glDrawArraysInstanced(GL_TRIANGLES, 0, tileQuad.length, instData.length);

		sh.SetUniform("isPicking", false);

		colAttr.SetDivisor(0);
		offAttr.SetDivisor(0);
		flagsAttr.SetDivisor(0);
		instData.Unbind();
		tileQuad.Unbind();
		idArray.Unbind();

		posAttr.Disable();
		colAttr.Disable();
		offAttr.Disable();
		flagsAttr.Disable();

		ubvec3 pickcol;
		glReadPixels(x, y, 1, 1, GL_RGB, GL_UNSIGNED_BYTE, cast(ubyte*) &pickcol);

		auto id = colorToId(pickcol);

		return GetTileByID(id);
	}
}