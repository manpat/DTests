module gl;

public{
	import derelict.opengl3.gl3;
	import derelict.sdl2.sdl;
	import derelict.sdl2.ttf;
	import derelict.sdl2.image;
	import gl3n.linalg;
}

import std.traits;
import std.stdio;

private bool glErrorOccured = false;

ReturnType!func cgl(alias func, string file = __FILE__, size_t line = __LINE__)(ParameterTypeTuple!func t){
	glErrorOccured = false;

	static if(!is(ReturnType!func == void)){
		auto ret = func(t);
	}else{
		func(t);
	}

	if(glErrorOccured){
		throw new Exception(func.stringof ~ " is where the last error occured", file, line);

	}else if(auto e = CheckGLError()){
		throw new Exception(func.stringof ~ " " ~ e, file, line);
	}

	static if(!is(ReturnType!func == void)){
		return ret;
	}
}

ReturnType!func cgle(alias func, string file = __FILE__, size_t line = __LINE__, ET)(ET extrainfo, ParameterTypeTuple!func t){
	glErrorOccured = false;

	static if(!is(ReturnType!func == void)){
		auto ret = func(t);
	}else{
		func(t);
	}

	if(glErrorOccured){
		throw new Exception(func.stringof ~ " is where the last error occured with " ~ to!string(extrainfo), file, line);

	}else if(auto e = CheckGLError()){
		throw new Exception(func.stringof ~ " " ~ e ~ " " ~ to!string(extrainfo), file, line);
	}

	static if(!is(ReturnType!func == void)){
		return ret;
	}
}

extern(C) private void GLDebugFunc(GLenum source, GLenum type, GLuint id,
	GLenum severity, GLsizei length, const (GLchar)* message,
	GLvoid* userParam) nothrow{

	import std.string;

	try {
		auto _glErrorOccured = cast(bool*) userParam;
		if(_glErrorOccured) *_glErrorOccured = true;
		
		writeln(GLDebugEnumsToString(source, type, severity), "\t\tid: ", id, "\n\t", message.fromStringz);
	}catch(Exception e){

	}
}

void InitGLDebugging(){
	cgl!glEnable(GL_DEBUG_OUTPUT);
	cgl!glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);

	cgl!glDebugMessageCallback(&GLDebugFunc, cast(const(void)*) &glErrorOccured);
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

private string GLDebugEnumsToString(GLenum source, GLenum type, GLenum severity){
	string ret = "";

	switch(severity){
		case GL_DEBUG_SEVERITY_HIGH: ret ~= "[high]"; break;
		case GL_DEBUG_SEVERITY_MEDIUM: ret ~= "[medium]"; break;
		case GL_DEBUG_SEVERITY_LOW: ret ~= "[low]"; break;
		case GL_DEBUG_SEVERITY_NOTIFICATION: ret ~= "[notification]"; break;
		default: ret ~= "[unknown]";
	}

	ret ~= "\tsrc:";

	switch(source){
		case GL_DEBUG_SOURCE_API: ret ~= " API"; break;
		case GL_DEBUG_SOURCE_WINDOW_SYSTEM: ret ~= " WINDOW_SYSTEM"; break;
		case GL_DEBUG_SOURCE_SHADER_COMPILER: ret ~= " SHADER_COMPILER"; break;
		case GL_DEBUG_SOURCE_THIRD_PARTY: ret ~= " THIRD_PARTY"; break;
		case GL_DEBUG_SOURCE_APPLICATION: ret ~= " APPLICATION"; break;
		case GL_DEBUG_SOURCE_OTHER: ret ~= " OTHER"; break;
		default: ret ~= " unknown";
	}

	ret ~= "\ttype:";

	switch(type){
		case GL_DEBUG_TYPE_ERROR: ret ~= " error"; break;
		case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: ret ~= " deprecated behaviour"; break;
		case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: ret ~= " undefined behaviour"; break;
		case GL_DEBUG_TYPE_PORTABILITY: ret ~= " portability issue"; break;
		case GL_DEBUG_TYPE_PERFORMANCE: ret ~= " performance issue"; break;
		case GL_DEBUG_TYPE_MARKER: ret ~= " marker"; break;
		case GL_DEBUG_TYPE_PUSH_GROUP: ret ~= " push group"; break;
		case GL_DEBUG_TYPE_POP_GROUP: ret ~= " pop group"; break;
		case GL_DEBUG_TYPE_OTHER: ret ~= " other"; break;
		default: ret ~= " unknown";
	}

	return ret;
}