module main;

import std.stdio;
import testing.classes;
import testing.funcs;
import derelict.util.exception;
import derelict.sdl2.sdl;

void set(Thing t, int x){
	t.x = x;
}

int get(Thing t){
	return t.x;
}

bool handleDerelictsProblems(string libName, string symbolName) {
	writeln("Failed to load ", symbolName, ", ignoring this.");
	return true;
}

void main(){
	writeln("Things ", fib!(0));
	writeln("Things ", fib!(1));
	writeln("Things ", fib!(2));
	writeln("Things ", fib!(3));
	writeln("Things ", fib!(4));
	writeln("Things ", fib!(5));
	writeln("Things ", fib!(6));
	writeln("Things ", fib!(7));
	writeln("Things ", fib!(8));
	writeln("Things ", fib!(9));
	writeln();

	scope (exit) writeln("Scope Exit");
	scope (success) writeln("Scope Success");
	scope (failure) writeln("Scope Fail");

	IThing thing = new Thing1();
	thing.S();
	thing = new Thing2();
	thing.S(); 

	auto oldthing = thing;

	thing = new Thing(3);
	thing.S();

	Thing t = cast(Thing) thing;
	Thing t2 = new Thing(4);
	t2.S();

	destroy(oldthing);

	writeln("t + t2 = ", t + t2);

	t.set(5);
	writeln("t + t2 = ", t + t2);

	writeln(t.get);

	simdTest();

	int asmTest(int x){
		asm {
			mov EAX, x;
			imul EAX, 2;
		}
	}

	writeln("asmTest: ", asmTest(3));

	try{
		Derelict_SetMissingSymbolCallback(&handleDerelictsProblems);
		DerelictSDL2.load();

		if(SDL_Init(SDL_INIT_EVERYTHING) < 0){
			writeln("SDL Init failed");
			throw(new Exception("Shit"));
		}

		SDL_Window* win = SDL_CreateWindow("Shit", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, SDL_WINDOW_SHOWN);
		if(!win){
			writeln("Window create failed");

			SDL_Quit();
		}

		bool running = true;
		while(running){
			SDL_Event e;
			while(SDL_PollEvent(&e)){
				switch(e.type){
					case SDL_KEYDOWN:
						running = false;
						break;
					default:
						break;
				}
			}

			SDL_GL_SwapWindow(win);
		}

		SDL_DestroyWindow(win);
		SDL_Quit();
	}catch(Exception e){
		writeln("Fuck: ", e.msg);
	}
}