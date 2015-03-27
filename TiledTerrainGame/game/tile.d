module game.tile;

import gl;

struct Tile {
	uint id = 0;
	vec3 position = vec3(0,0,0);
	vec3 color = vec3(1,1,1);
	private uint flags = 0;

	@property{
		bool isWater(){
			return getflag(0);
		}
		void isWater(bool v){
			setflag(0, v);
		}
	}

	void setflag(uint bit, bool v){
		auto mask = 1<<bit;

		if(v){
			flags |= mask;
		}else{
			flags &= ~mask;
		}
	}

	bool getflag(uint bit){
		return (flags & 1<<bit) != 0;
	}

	void toggleflag(uint bit){
		flags ^= 1<<bit;
	}
}