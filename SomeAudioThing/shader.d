module shader;

import std.stdio;
import std.file;
import gl;

private Shader activeShader;
private Shader[string] loadedShaders;

Shader GetActiveShader(){
	return activeShader;
}

Shader GetShader(string name){
	return loadedShaders[name];
}

class Shader{
private: 
	GLuint _program = 0;
	string fname;

public:
	this(string fname, string name = ""){
		scope(failure) writeln("Shader init failed");

		this.fname = fname;

		Load();

		loadedShaders[name] = this;
	}

	~this(){
		if(activeShader == this) {
			glUseProgram(0);
			activeShader = null;
		}
		glDeleteProgram(_program);
	}

	void Load(){
		scope(failure) writeln("Shader load failed");

		GLuint[] sh = LoadShadersFromFile(fname);

		if(_program){
			if(activeShader == this)
				glUseProgram(0);

			glDeleteProgram(_program);
		}

		_program = glCreateProgram();
		foreach(s; sh){
			glAttachShader(_program, s);
		}

		glBindFragDataLocation(_program, 0, "color");

		glLinkProgram(_program);
		foreach(s; sh){
			glDeleteShader(s);
		}

		if(!activeShader || activeShader == this){
			glUseProgram(_program);
			activeShader = this;
		}

		this.fname = fname;
	}

	private GLuint LoadShaderFromFile(string name, GLuint type){
		if(!exists(name)) throw new Exception(name~" doesn't exist");
		char[] f = readText!(char[])(name);

		return LoadShaderFromString(f, type);
	}
	private GLuint[] LoadShadersFromFile(string name){
		import std.algorithm, std.string, std.conv;
		immutable shaderTypeString = "#type";
		alias idx_t = size_t;

		if(!exists(name)) throw new Exception(name~" doesn't exist");
		char[] f = readText!(char[])(name);
		ulong numSegments = count(f, shaderTypeString);

		auto shaders = new uint[numSegments];

		idx_t findEndOfLine(idx_t startpos){
			auto end = f.indexOf("\n", startpos);
			if(end == -1) return f.length;
			return end;
		}
		idx_t findNextSegmentOrEnd(idx_t startpos){
			auto end = f.indexOf(shaderTypeString, startpos);
			if(end == -1) return f.length;
			return end;
		}

		uint getShaderType(idx_t startpos){
			auto begin = f.indexOf(shaderTypeString, startpos);
			begin += shaderTypeString.length+1; // + space
			auto end = findEndOfLine(begin);

			char[] typeString = f[begin..end];
			switch(typeString){
				case "vertex":
					return GL_VERTEX_SHADER;

				case "tesscontrol":
					return GL_TESS_CONTROL_SHADER;

				case "geometry":
					return GL_GEOMETRY_SHADER;

				case "tesseval":
					return GL_TESS_EVALUATION_SHADER;

				case "fragment":
					return GL_FRAGMENT_SHADER;

				case "compute":
					return GL_COMPUTE_SHADER;

				default:
					writeln("Unknown shader type: " ~ typeString);
			}

			return 0;
		}

		idx_t idx = 0;
		foreach(i; 0..numSegments){
			uint type = getShaderType(idx);
			if(type == 0) continue;

			idx = findEndOfLine(idx);
			idx_t nextIdx = findNextSegmentOrEnd(idx);
			char[] src = f[idx..nextIdx];

			shaders[i] = LoadShaderFromString(src, type);

			idx = nextIdx;
		}

		return shaders;
	}

	private GLuint LoadShaderFromString(char[] src, GLuint type){
		import std.string : toStringz;

		auto sh = glCreateShader(type);
		scope(failure) glDeleteShader(sh);

		auto _zsrc = src.toStringz;
		glShaderSource(sh, 1, &_zsrc, null);
		glCompileShader(sh);

		GLint status;
		glGetShaderiv(sh, GL_COMPILE_STATUS, &status);
		if(status == GL_FALSE){
			char[] buffer = new char[512];
			glGetShaderInfoLog(sh, 512, null, buffer.ptr);

			writeln(buffer);
			throw new Exception("Shader compile fail");
		}

		return sh;
	}

	private GLint GetAttributeLoc(string attr){
		import std.string : toStringz;
		return glGetAttribLocation(_program, attr.toStringz);
	}
	private GLint GetUniformLoc(string attr){
		import std.string : toStringz;
		return glGetUniformLocation(_program, attr.toStringz);
	}

	Attribute GetAttribute(string attr){
		return new Attribute(GetAttributeLoc(attr));
	}

	void Use(){
		glUseProgram(_program);
		activeShader = this;
	}

	void SetUniform(T)(string name, T dat){
		SetUniform(GetUniformLoc(name), dat);
	}

	void SetUniform(T)(uint name, T dat){
		static if(is(T : Matrix!(DT, D, D), DT, uint D)){
			mixin("glUniformMatrix"~to!string(D)~"fv")(name, 1, GL_TRUE, dat.value_ptr);

		}else static if(is(T : Vector!(DT, D), DT, uint D)){
			mixin("glUniform"~to!string(D)~"fv")(name, 1, dat.value_ptr);

		}else static if(is(T == float)){
			glUniform1f(name, dat);
		}else static if(is(T == double)){
			glUniform1d(name, dat);
		}else static if(is(T == int)){
			glUniform1i(name, dat);
		}else static if(is(T == uint)){
			glUniform1ui(name, dat);
		}else{
			assert(false, "SetUniform not supported for type " ~ T.stringof);
		}

		// Obviously not complete
	}
}

class Attribute {
	GLint loc = 0;

	this(GLint _loc){
		loc = _loc;
	}

	void Enable(){
		glEnableVertexAttribArray(loc);
	}
	void Disable(){
		glDisableVertexAttribArray(loc);
	}
}