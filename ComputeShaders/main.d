import std.stdio;
import std.conv;
import std.math;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import cruft;
import shader;

import vertexarray;
import vector;

struct Test{
	vec4 da;
	vec4 d2;
	bool d3;
	int[3] _;
}

uint testssbo, fssbo;
uint numElements;

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		auto shader = new Shader("shaders/test.glsl");

		Test[] test = [
			Test(vec4(0f, 0f, 0f, 0f), vec4(0f, 0f, 0f, 0f)),
			Test(vec4(0f, 0f, 0f, 0f), vec4(0f, 0f, 0f, 0f)),
			Test(vec4(0f, 0f, 0f, 0f), vec4(0f, 0f, 0f, 0f)),
		];

		float[] fdata = [
			2f, 5f, 7f,
		];

		numElements = cast(uint) fdata.length;

		glGenBuffers(1, &fssbo);
		glBindBuffer(GL_ARRAY_BUFFER, fssbo);
		glBufferData(GL_ARRAY_BUFFER, float.sizeof * fdata.length, fdata.ptr, GL_STATIC_DRAW);

		glGenBuffers(1, &testssbo);
		glBindBuffer(GL_ARRAY_BUFFER, testssbo);
		glBufferData(GL_ARRAY_BUFFER, Test.sizeof * test.length, test.ptr, GL_STATIC_DRAW);

		glBindBuffer(GL_ARRAY_BUFFER, 0);

		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, fssbo);
		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, testssbo);

		foreach(i; 0..4){
			glDispatchCompute(numElements, 2, 1);
			InspectBuffers();
		}

	}catch(Exception e){
		writeln("Fuck: ", e.msg);
	}
}

void InspectBuffers(){
	{
		glBindBuffer(GL_ARRAY_BUFFER, fssbo);
		scope(exit) glUnmapBuffer(GL_ARRAY_BUFFER);
		
		float[] data = (cast(float*) glMapBuffer(GL_ARRAY_BUFFER, GL_READ_ONLY))[0..numElements];

		foreach(f; data){
			writeln(f);
		}
	}
	{
		glBindBuffer(GL_ARRAY_BUFFER, testssbo);
		scope(exit) glUnmapBuffer(GL_ARRAY_BUFFER);
		
		Test[] data = (cast(Test*) glMapBuffer(GL_ARRAY_BUFFER, GL_READ_ONLY))[0..numElements];

		foreach(f; data){
			writeln(f);
		}
	}
	writeln("");
}