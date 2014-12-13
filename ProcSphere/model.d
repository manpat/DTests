module model;

import gl;
import shader;
import vertexarray;
import camera;

class Icosahedron {
	VertexArray!vec3 vertices;
	//VertexArray!uint indices;
	enum v = (1.0 + sqrt(5.0)) / 2.0;
	float scale;

	this(int pretessellate = 1, float s = 1f){
		scale = s;

		vertices = new VertexArray!vec3();
		//indices = new VertexArray!uint(GL_ELEMENT_ARRAY_BUFFER);

		auto tv = [
			vec3(-1,  v,  0), // 0
			vec3( 1,  v,  0),
			vec3(-1, -v,  0),
			vec3( 1, -v,  0),
			vec3( 0, -1,  v), // 4
			vec3( 0,  1,  v),
			vec3( 0, -1, -v),
			vec3( 0,  1, -v),
			vec3( v,  0, -1), // 8
			vec3( v,  0,  1),
			vec3(-v,  0, -1),
			vec3(-v,  0,  1),
		];

		uint[] ti = [
			0, 11, 5,
			0, 5, 1,
			0, 1, 7,
			0, 7, 10,
			0, 10, 11,

			1, 5, 9,
			5, 11, 4,
			11, 10, 2,
			10, 7, 6,
			7, 1, 8,

			3, 9, 4,
			3, 4, 2,
			3, 2, 6,
			3, 6, 8,
			3, 8, 9,

			4, 9, 5,
			2, 4, 11,
			6, 2, 10,
			8, 6, 7,
			9, 8, 1,
		];

		vec3[] verts;

		foreach(i; ti){
			verts ~= tv[i];
		}

		tv = verts;
		foreach(j; 0..pretessellate){
			verts = [];

			foreach(i; 0..tv.length/3){
				auto v0 = tv[i*3 + 0];
				auto v1 = tv[i*3 + 1];
				auto v2 = tv[i*3 + 2];
				auto v01 = (v0 + v1);
				auto v12 = (v2 + v1);
				auto v20 = (v2 + v0);

				v01 = v01.normalized * (v01*0.5f).magnitude;
				v12 = v12.normalized * (v12*0.5f).magnitude;
				v20 = v20.normalized * (v20*0.5f).magnitude;

				verts ~= v0;
				verts ~= v01;
				verts ~= v20;

				verts ~= v1;
				verts ~= v12;
				verts ~= v01;

				verts ~= v2;
				verts ~= v20;
				verts ~= v12;

				verts ~= v01;
				verts ~= v12;
				verts ~= v20;
			}
			
			tv = verts;
		}

		vertices.Load(verts);
	}

	void Render(Attribute posAttr){
		vertices.Bind(posAttr);
		//indices.Bind();

		MatrixStack.Push();
		MatrixStack.top = 
			MatrixStack.top * mat4.scaling(scale, scale, scale);

		glPatchParameteri(GL_PATCH_VERTICES, 3);
		//glDrawElements(GL_PATCHES, indices.length, GL_UNSIGNED_INT, null);
		glDrawArrays(GL_PATCHES, 0, vertices.length);

		MatrixStack.Pop();

		vertices.Unbind();
		//indices.Unbind();
	}
}