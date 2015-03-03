module input;

import std.stdio;
import std.math;
import std.string;
import cruft : Width, Height;
import gl;

private {
	bool[int] keys;
	auto dlt = vec2(0,0);
	void delegate(uint button, uint x, uint y) clickdel;
}

void CheckInputEvents(SDL_Event* e){
	dlt = vec2(0,0);

	while(SDL_PollEvent(e)){
		switch(e.type){
			case SDL_KEYDOWN:
				keys[e.key.keysym.sym] = true;
				break;

			case SDL_KEYUP:
				keys[e.key.keysym.sym] = false;
				break;

			case SDL_MOUSEMOTION:{
				dlt = vec2(e.motion.x, e.motion.y);
				dlt.x = ( dlt.x / Width) * 2f - 1f;
				dlt.y = (-dlt.y / Height) * 2f + 1f;
				break;
			}

			case SDL_MOUSEBUTTONDOWN:
			//case SDL_MOUSEBUTTONUP:
			{
				auto m = e.button;
				if(clickdel) clickdel(m.button, m.x, Height-m.y);
				break;
			}

			default:
				break;
		}
	}
}

bool GetKey(int k){
	return keys.get(k, false);
}

vec2 GetMouseDelta(){
	return dlt;
}

void SetMouseClickDelegate(void delegate(uint button, uint x, uint y) del){
	clickdel = del;
}