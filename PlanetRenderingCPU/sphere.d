module sphere;

import vertexarray;
import shader;
import gl;

class Sphere {
	private VertexArray!vec3 pos;

	this(uint subdivisionLevel){
		pos = new VertexArray!vec3;

		enum v = (1.0 + sqrt(5.0)) / 2.0;
		auto startverts = [
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

		auto startindices = [
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

		foreach(idx; startindices) {
			verts ~= startverts[idx];
		}

		foreach(i; 0..subdivisionLevel){
			verts = Subdivide(verts);
		}

		foreach(ref vert; verts){
			vert = vert.normalized;
		}

		pos.Load(verts);
	}

	private vec3[] Subdivide(vec3[] verts){
		vec3[] output;
		
		foreach(triid; 0..verts.length/3){
			auto v0 = verts[triid*3 + 0];
			auto v1 = verts[triid*3 + 1];
			auto v2 = verts[triid*3 + 2];

			auto v01 = (v0 + v1)*0.5f;
			auto v02 = (v0 + v2)*0.5f;
			auto v12 = (v1 + v2)*0.5f;

			output ~= v0;
			output ~= v01;
			output ~= v02;

			output ~= v01;
			output ~= v1;
			output ~= v12;

			output ~= v02;
			output ~= v12;
			output ~= v2;

			output ~= v01;
			output ~= v12;
			output ~= v02;
		}

		return output;
	}

	void Draw(Attribute posAttr){
		pos.Bind(posAttr);

		glPatchParameteri(GL_PATCH_VERTICES, 3);
		glDrawArrays(GL_PATCHES, 0, pos.length);

		pos.Unbind();
	}
}