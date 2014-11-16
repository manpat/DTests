module tree;

import std.math;
import std.random;

import gl;
import shader;
import vector;
import vertexarray;

private V Interp(V)(V s, V e, float a){
	return s*(1f-a) + e*a;
}

class Tree {
	Branch root;
	VertexArray!vec2 branchBO;
	VertexArray!vec3 colorBO;

	Attribute posAttr;
	Attribute colAttr;

	this(uint depth){
		auto shader = GetActiveShader();
		posAttr = shader.GetAttribute("position");
		colAttr = shader.GetAttribute("color");

		root = new Branch(depth, 0.5f);

		branchBO = new VertexArray!vec2();
		branchBO.Load([]);

		colorBO = new VertexArray!vec3();
		colorBO.Load([]);
	}
	~this(){
		destroy(root);
	}

	void Compile(){
		vec2[] lines;
		vec3[] colors;
		root.Compile(lines, colors, vec2(0, -1), vec2(0, 1), 0f);

		std.stdio.writeln(std.conv.to!string((lines.length * vec2.sizeof + colors.length * vec3.sizeof) / 1000000f) ~ "M" );

		branchBO.Load(lines);
		colorBO.Load(colors);
	}

	void Draw(){
		colorBO.Bind(colAttr);
		branchBO.Bind(posAttr);
		glDrawArrays(GL_LINES, 0, branchBO.length);
		branchBO.Unbind();
	}
}

class Branch {
	uint level;

	float length;
	float angle;
	float distAlongParent;

	Branch[] childBranches;

	this(uint depth, float _length = 0.4f, float _angle = 0f, float _dist = 0.8f){
		level = depth;
		length = _length;
		angle = _angle;
		distAlongParent = _dist;

		if(depth > 0){
			const angleDiff = PI/5f - 0.25f/depth;
			childBranches ~= new Branch(depth-1, length*0.7f, uniform(-angleDiff, angleDiff)/2f, 1f);

			foreach(i; 0..uniform(1, 5)){
				childBranches ~= new Branch(depth-1, length*uniform(0.5f, 0.8f), uniform(-angleDiff, angleDiff), 
					uniform(distAlongParent/1.5f, distAlongParent));
			}
		}
	}

	~this(){
		foreach(b; childBranches){
			destroy(b);
		}
	}

	void Compile(ref vec2[] lines, ref vec3[] colors, vec2 start, vec2 up, float parentLength){
		auto branchpoint = start + up * parentLength * distAlongParent;
		auto dir = up.rotate(angle);

		lines ~= [
			branchpoint, branchpoint + dir * length,
		];

		vec3 brown = vec3(0.5f, 0.1f, 0f);
		vec3 col1 = vec3(0.8f, 0.5f, 0.1f);
		vec3 col2 = vec3(1f, 0.2f, 0.4f);

		if(level == 0){
			colors ~= [
				col2, Interp(col2, col1, uniform(0f, 1f))
			];
		}else{
			colors ~= [
				Interp(col2, brown, (level+1)/6f), Interp(col2, brown, level/6f)
			];
		}

		foreach(b; childBranches){
			b.Compile(lines, colors, branchpoint, dir, length);
		}
	}
}

class Leaf {

}