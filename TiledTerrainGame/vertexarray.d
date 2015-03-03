module vertexarray;

import shader;
import gl;

class VertexArray(DataType = vec3){
	private GLuint vbo;
	private GLuint bufferType = GL_ARRAY_BUFFER;
	private GLuint memoryMode = GL_STATIC_DRAW;
	private uint _length = 0;

	this(GLuint _bufferType = GL_ARRAY_BUFFER, GLuint _memMode = GL_STATIC_DRAW){
		glGenBuffers(1, &vbo);
		bufferType = _bufferType;
		memoryMode = _memMode;
	}

	~this(){
		glDeleteBuffers(1, &vbo);
	}

	void Bind(){
		cgl!glBindBuffer(bufferType, vbo);
	}

	void Bind(Attribute attr){
		Bind();

		static if(is(DataType : Vector!(ET, Dim), uint Dim, ET)){
			static if(is(ET == float)){
				cgl!glVertexAttribPointer(attr.loc, Dim, GL_FLOAT, GL_FALSE, 0, null);
			}else static if(is(ET == double)){
				cgl!glVertexAttribPointer(attr.loc, Dim, GL_DOUBLE, GL_FALSE, 0, null);
			}else static if(is(ET == ubyte)){
				cgl!glVertexAttribPointer(attr.loc, Dim, GL_UNSIGNED_BYTE, GL_TRUE, 0, null);
			}

		}else static if(is(DataType == float)){
			cgl!glVertexAttribPointer(attr.loc, 1, GL_FLOAT, GL_FALSE, 0, null);
		}else static if(is(DataType == double)){
			cgl!glVertexAttribPointer(attr.loc, 1, GL_DOUBLE, GL_FALSE, 0, null);
		}else static if(is(DataType == int)){
			cgl!glVertexAttribPointer(attr.loc, 1, GL_INT, GL_FALSE, 0, null);
		}else static if(is(DataType == short)){
			cgl!glVertexAttribPointer(attr.loc, 1, GL_SHORT, GL_FALSE, 0, null);
		}else static if(is(DataType == byte)){
			cgl!glVertexAttribPointer(attr.loc, 1, GL_BYTE, GL_FALSE, 0, null);

		}else static if(is(DataType == uint)){
			cgl!glVertexAttribPointer(attr.loc, 1, GL_UNSIGNED_INT, GL_FALSE, 0, null);
		}else static if(is(DataType == ushort)){
			cgl!glVertexAttribPointer(attr.loc, 1, GL_UNSIGNED_SHORT, GL_FALSE, 0, null);
		}else static if(is(DataType == ubyte)){
			cgl!glVertexAttribPointer(attr.loc, 1, GL_UNSIGNED_BYTE, GL_FALSE, 0, null);
		}else{
			assert(false, "Automatic binding of type " ~ DataType.stringof ~ " not implemented");
		}
	}

	void Bind(T, string VName)(Attribute attr){
		static if(is(T : Vector!(ET, D), uint D, ET)){
			enum NumElems = D;
			alias Ty = ET;

		}else{
			enum NumElems = 1;
			alias Ty = T;
		}

		static if(is(Ty == float)){
			enum Width = GL_FLOAT;
		}else static if(is(Ty == double)){
			enum Width = GL_DOUBLE;
		}else static if(is(Ty == int)){
			enum Width = GL_INT;
		}else static if(is(Ty == short)){
			enum Width = GL_SHORT;
		}else static if(is(Ty == byte)){
			enum Width = GL_BYTE;

		}else static if(is(Ty == uint)){
			enum Width = GL_UNSIGNED_INT;
		}else static if(is(Ty == ushort)){
			enum Width = GL_UNSIGNED_SHORT;
		}else static if(is(Ty == ubyte)){
			enum Width = GL_UNSIGNED_BYTE;
		}else{
			assert(false, "Binding of type " ~ T.stringof ~ " not implemented");
		}

		Bind();

		// HACK: Change this. Add an option to normalise to float?
		static if(is(Ty == uint)){
			cgl!glVertexAttribIPointer(attr.loc, NumElems, Width, DataType.sizeof, 
				cast(void*) mixin("DataType." ~ VName ~ ".offsetof"));

		}else{
			cgl!glVertexAttribPointer(attr.loc, NumElems, Width, GL_FALSE, DataType.sizeof, 
				cast(void*) mixin("DataType." ~ VName ~ ".offsetof"));
		}
	}

	void Unbind(){
		cgl!glBindBuffer(bufferType, 0);
	}

	void Load(DataType[] data){
		Bind();

		cgl!glBufferData(bufferType, DataType.sizeof * data.length, data.ptr, memoryMode);
		_length = cast(uint) data.length;

		Unbind();
	}

	uint length(){
		return _length;
	}

	uint raw(){
		return vbo;
	} 
}