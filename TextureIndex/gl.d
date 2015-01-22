module gl;

public{
	import derelict.opengl3.gl3;
	import derelict.sdl2.sdl;
	import derelict.sdl2.ttf;
	import gl3n.linalg;
}

void cgl(alias func, string file = __FILE__, size_t line = __LINE__, T...)(T t){
	func(t);

	auto e = CheckGLError();
	if(e){
		throw new Exception(func.stringof ~ " " ~ e, file, line);
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