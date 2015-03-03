module eventsystem;

import derelict.sdl2.sdl;

private {
	alias EventHandler = void delegate(SDL_Event*);

	EventHandler[] handlers;
}

void CheckEvents(){
	SDL_Event e;

	while(SDL_PollEvent(&e)){
		foreach(h; handlers){
			h(&e);
		}
	}
}

void HookEventHandler(EventHandler h){
	handlers ~= h;
}