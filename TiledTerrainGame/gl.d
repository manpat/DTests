module gl;

public{
	import derelict.opengl3.gl3;
	import derelict.sdl2.sdl;
	import derelict.sdl2.ttf;
	import derelict.sdl2.image;
	import gl3n.linalg;
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