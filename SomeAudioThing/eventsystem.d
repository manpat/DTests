module eventsystem;

import gl;

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