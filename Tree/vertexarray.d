module vertexarray;

import derelict.opengl3.gl3;
import shader;
import vector;

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
		glBindBuffer(bufferType, vbo);
	}

	void Bind(Attribute attr){
		Bind();

		static if(is(DataType : vec!D, uint D)){
			glVertexAttribPointer(attr.loc, D /*DataType.dimensions*/, GL_FLOAT, GL_FALSE, 0, null);

		}else static if(is(DataType == float)){
			glVertexAttribPointer(attr.loc, 1, GL_FLOAT, GL_FALSE, 0, null);
		}else static if(is(DataType == double)){
			glVertexAttribPointer(attr.loc, 1, GL_DOUBLE, GL_FALSE, 0, null);
		}else static if(is(DataType == int)){
			glVertexAttribPointer(attr.loc, 1, GL_INT, GL_FALSE, 0, null);
		}else static if(is(DataType == short)){
			glVertexAttribPointer(attr.loc, 1, GL_SHORT, GL_FALSE, 0, null);
		}else static if(is(DataType == byte)){
			glVertexAttribPointer(attr.loc, 1, GL_BYTE, GL_FALSE, 0, null);

		}else static if(is(DataType == uint)){
			glVertexAttribPointer(attr.loc, 1, GL_UNSIGNED_INT, GL_FALSE, 0, null);
		}else static if(is(DataType == ushort)){
			glVertexAttribPointer(attr.loc, 1, GL_UNSIGNED_SHORT, GL_FALSE, 0, null);
		}else static if(is(DataType == ubyte)){
			glVertexAttribPointer(attr.loc, 1, GL_UNSIGNED_BYTE, GL_FALSE, 0, null);
		}else{
			static assert(false, "Type " ~ DataType.stringof ~ " not implemented");
		}
	}

	void Unbind(){
		glBindBuffer(bufferType, 0);
	}

	void Load(DataType[] data){
		Bind();

		glBufferData(bufferType, DataType.sizeof * data.length, data.ptr, memoryMode);
		_length = cast(uint) data.length;

		Unbind();
	}

	uint length(){
		return _length;
	}
}