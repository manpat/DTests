module main;

pragma(lib, "DerelictSDL2");
pragma(lib, "DerelictGL3");
pragma(lib, "DerelictUtil");
pragma(lib, "dl");

import std.stdio;
import std.file;
import derelict.util.exception;
import derelict.sdl2.sdl;
import derelict.opengl3.gl;

enum {
	Width = 800,
	Height = 600
}

auto vsrc = 
`#version 330

in vec2 pos;
out vec2 uv;
void main(){
	gl_Position = vec4(pos, 0, 1);
	uv = pos;
}`.dup ~ '\0';


void main(){
	try{
		// Init
		DerelictSDL2.missingSymbolCallback = (string) => ShouldThrow.No;
		DerelictSDL2.load();
		DerelictGL3.load();

		if(SDL_Init(SDL_INIT_EVERYTHING) < 0) "SDL Init failed".except;
		scope(exit) SDL_Quit();

		// Open window
		alias SDLCenter = Times!(SDL_WINDOWPOS_CENTERED, 2);
		auto wflags = SDL_WINDOW_BORDERLESS*0 | SDL_WINDOW_OPENGL;
		auto win = SDL_CreateWindow("", SDLCenter, Width, Height, wflags);
		scope(exit) SDL_DestroyWindow(win);
		if(!win) "Window create failed".except;

		// Set OpenGL attributes
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

		// Set up OpenGL context
		auto glctx = SDL_GL_CreateContext(win);
		scope(exit) SDL_GL_DeleteContext(glctx);
		if(!glctx) "GL context creation failed".except; 
		DerelictGL3.reload();
		cgl!glFrontFace(GL_CW);

		// Set up GL VAO
		GLuint vao = 0;
		cgl!glGenVertexArrays(1, &vao);
		scope(exit) cgl!glDeleteVertexArrays(1, &vao);
		cgl!glBindVertexArray(vao);

		// New shader
		auto program = CompileProgram();
		scope(exit) cgl!glDeleteProgram(program);

		// Set up triangle
		GLuint vbo = 0;
		cgl!glGenBuffers(1, &vbo);
		scope(exit) cgl!glDeleteBuffers(1, &vbo);

		auto data = [
			-1f, 1f,
			 1f, 1f,
			-1f,-1f,

			 1f, 1f,
			 1f,-1f,
			-1f,-1f,
		];

		cgl!glBindBuffer(GL_ARRAY_BUFFER, vbo);
		cgl!glBufferData(GL_ARRAY_BUFFER, float.sizeof*data.length, data.ptr, GL_STATIC_DRAW);
		cgl!glVertexAttribPointer(/*attrib*/0, 2, GL_FLOAT, GL_FALSE, 0, null);
		cgl!glBindBuffer(GL_ARRAY_BUFFER, 0);

		//cgl!glBindVertexBuffer(/*binding*/0, vbo, 0, float.sizeof*2);
		//cgl!glVertexAttribFormat(/*attrib*/ 0, 2, GL_FLOAT, GL_FALSE, 0);
		//cgl!glVertexAttribBinding(/*attrib*/ 0, /*binding*/0);

		float time = 0f;

		// Start loop
		SDL_Event e;
		runLoop: while(true){
			while(SDL_PollEvent(&e)){
				switch(e.type){
					case SDL_KEYDOWN:{
						if(e.key.keysym.sym == SDLK_ESCAPE) break runLoop;
						if(e.key.keysym.sym == SDLK_r) program = CompileProgram();
						break;
					}

					default:
				}
			}
			
			time += 0.1f;
			auto timeLoc = cgl!glGetUniformLocation(program, "time");
			cgl!glUniform1f(timeLoc, time);

			alias grey = Times!(0.2f, 3);
			glClearColor(grey, 1f);

			cgl!glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			cgl!glEnableVertexAttribArray(0);
			cgl!glBindBuffer(GL_ARRAY_BUFFER, vbo);
			cgl!glDrawArrays(GL_TRIANGLES, 0, 6);

			SDL_GL_SwapWindow(win);
		}
		
	}catch(Exception e){
		import std.file;
		import std.string;

		write("exception.log", "%s:%s: %s".format(e.file, e.line, e.msg));
		writeln(e.file, ":", e.line, ": ", e.msg);
	}
}

void except(size_t line = __LINE__, string file = __FILE__)(string s){
	throw new Exception(s, file, line);
}

template Tuple(T...){
	enum Tuple = T;
}

template Times(alias T, int i){
	static if(i > 1){
		enum Times = Tuple!(T, Times!(T, i-1));
	}else{
		enum Times = T;
	}
}

import std.traits;

ReturnType!func cgl(alias func, string file = __FILE__, size_t line = __LINE__)(ParameterTypeTuple!func t){
	static if(!is(ReturnType!func == void)){
		auto ret = func(t);
	}else{
		func(t);
	}

	if(auto e = CheckGLError()){
		throw new Exception(func.stringof ~ " " ~ e, file, line);
	}

	static if(!is(ReturnType!func == void)){
		return ret;
	}
}

ReturnType!func cgle(alias func, string file = __FILE__, size_t line = __LINE__, ET)(ET extrainfo, ParameterTypeTuple!func t){
	static if(!is(ReturnType!func == void)){
		auto ret = func(t);
	}else{
		func(t);
	}

	if(auto e = CheckGLError()){
		throw new Exception(func.stringof ~ " " ~ e ~ " " ~ to!string(extrainfo), file, line);
	}

	static if(!is(ReturnType!func == void)){
		return ret;
	}
}

private string CheckGLError(){
	GLuint error = glGetError();
	switch(error){
		case GL_INVALID_ENUM:
			return "InvalidEnum";

		case GL_INVALID_VALUE:
			return "InvalidValue";

		case GL_INVALID_OPERATION:
			return "InvalidOperation";

		case GL_INVALID_FRAMEBUFFER_OPERATION:
			return "InvalidFramebufferOperation";

		case GL_OUT_OF_MEMORY:
			return "OutOfMemory";

		case GL_NO_ERROR:
			return null;

		default:
			return "Unhandled GL Error";
	}
}

GLuint CompileProgram(){
	cgl!glUseProgram(0);
	auto program = cgl!glCreateProgram();

	auto vsh = cgl!glCreateShader(GL_VERTEX_SHADER);
	auto vsrcp = vsrc.ptr;
	cgl!glShaderSource(vsh, 1, &vsrcp, null);
	cgl!glCompileShader(vsh);
	GLint status;
	cgl!glGetShaderiv(vsh, GL_COMPILE_STATUS, &status);
	if(status == GL_FALSE){
		char[] buffer = new char[512];
		glGetShaderInfoLog(vsh, 512, null, buffer.ptr);

		writeln(buffer);
		throw new Exception("Shader compile fail");
	}

	auto fsh = cgl!glCreateShader(GL_FRAGMENT_SHADER);
	auto fsrc = readText("shader.glsl") ~ '\0';
	auto fsrcp = fsrc.ptr;
	cgl!glShaderSource(fsh, 1, &fsrcp, null);
	cgl!glCompileShader(fsh);
	cgl!glGetShaderiv(fsh, GL_COMPILE_STATUS, &status);
	if(status == GL_FALSE){
		char[] buffer = new char[512];
		glGetShaderInfoLog(fsh, 512, null, buffer.ptr);

		writeln(buffer);
		throw new Exception("Shader compile fail");
	}

	cgl!glAttachShader(program, vsh);
	cgl!glAttachShader(program, fsh);
	cgl!glBindFragDataLocation(program, 0, "color");
	cgl!glLinkProgram(program);
	cgl!glDeleteShader(vsh);
	cgl!glDeleteShader(fsh);

	cgl!glUseProgram(program);

	cgl!glUniform1f(cgl!glGetUniformLocation(program, "aspect"), 8f/6f);

	return program;
}