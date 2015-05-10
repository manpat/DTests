module main;

pragma(lib, "DerelictASSIMP3");

import denj.system.common;
import denj.system.window;
import denj.system.input;
import denj.graphics.common;
import denj.graphics.errorchecking;
import denj.graphics;
import denj.utility;
import denj.math;

import derelict.assimp3.assimp;

struct Mesh {
	Buffer vbo;
	Buffer nbo;
	Buffer ibo;
}

void main(){
	try{
		Window.Init(800, 600, "Modelloading");
		Input.Init();
		Renderer.Init(GLContextSettings(3, 2));

		DerelictASSIMP3.load();

		auto sh = ShaderProgram.LoadFromFile("shader.shader");
		sh.Use();

		glFrontFace(GL_CCW);
		glEnable(GL_CULL_FACE);
		glEnable(GL_DEPTH_TEST);

		auto mesh = LoadMesh("test.obj");
		// auto mesh = LoadMesh("test.ply");

		mat4 projection;
		{ // TODO: Move to matrix math module
			enum fovy = 80f * PI / 180f;
			enum aspect = 8f/6f;

			enum n = 0.1f;
			enum f = 50f;

			enum r = 1f/tan(fovy/2f);
			enum t = r*aspect;
			projection = mat4(
				r, 0,   0,   0,
				0,   t, 0,   0,
				0,   0,   -(f+n)/(f-n), -2*f*n/(f-n),
				0,   0,   -1,   0,
			);
		}
		sh.SetUniform("projection", projection);

		glPointSize(5f);

		float t = 0f;
		bool showFaces = true;
		bool showVertices = true;
		while(Window.IsOpen()){
			t += 0.02f;
			Window.FrameBegin();

			cgl!glClearColor(0.05, 0.05, 0.05, 1f);
			cgl!glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

			if(Input.GetKeyDown(SDLK_ESCAPE)){
				Window.Close(); break;
			}

			if(Input.GetKeyDown(SDLK_f)){
				showFaces ^= true;
				glPolygonMode(GL_FRONT_AND_BACK, showFaces?GL_FILL:GL_LINE);
			}

			if(Input.GetKeyDown(SDLK_v)){
				showVertices ^= true;
			}

			Renderer.SetAttribute(0, mesh.vbo);
			Renderer.SetAttribute(1, mesh.nbo);

			mat4 rot; 

			if(fmod(t/3f, 3f) <= 1f){
				rot = mat4.XRotation(t*PI*2f/3f) .RotateY(t*PI*2f/3f);
			}else if(fmod(t/3f, 3f) <= 2f){
				rot = mat4.YRotation(t*PI*2f/3f) .RotateZ(t*PI*2f/3f);
			}else{
				rot = mat4.ZRotation(t*PI*2f/3f) .RotateX(t*PI*2f/3f);
			}

			sh.SetUniform("modelview", mat4.Translation(vec3(0,0,-2f)) * mat4.Scale(0.4f) * rot);
			sh.SetUniform("c", vec3(1,0,0));
			if(showVertices) Renderer.Draw(GL_POINTS);

			mesh.ibo.Bind();
			sh.SetUniform("c", vec3(1,1,1));
			Renderer.Draw(GL_TRIANGLES);

			mesh.ibo.Unbind();
			sh.SetUniform("modelview", mat4.Translation(vec3(0,0,-2f)) * rot * mat4.Translation(vec3(1f,0,-1f)*0.6f) * mat4.Scale(0.1f) * rot);
			sh.SetUniform("c", vec3(1,0,0));
			if(showVertices) Renderer.Draw(GL_POINTS);

			mesh.ibo.Bind();
			sh.SetUniform("c", vec3(0,1,1));
			Renderer.Draw(GL_TRIANGLES);

			mesh.ibo.Unbind();
			sh.SetUniform("modelview", mat4.Translation(vec3(0,0,-2f)) * mat4.Translation(vec3(0f,0.5f,1f)*0.8f).RotateY(t*PI).RotateX(t) * mat4.Scale(0.1f) * rot);
			sh.SetUniform("c", vec3(1,0,0));
			if(showVertices) Renderer.Draw(GL_POINTS);

			mesh.ibo.Bind();
			sh.SetUniform("c", vec3(1,1,0));
			Renderer.Draw(GL_TRIANGLES);

			mesh.vbo.Unbind();
			mesh.nbo.Unbind();
			mesh.ibo.Unbind();

			Window.Swap();
			Window.FrameEnd();
			SDL_Delay(10);
		}
		
	}catch(Exception e){
		LogF("%s:%s: error: %s", e.file, e.line, e.msg);
	}
}

import std.string;

Mesh* LoadMesh(string filename){
	auto ret = new Mesh;

	ret.vbo = new Buffer();
	ret.nbo = new Buffer();
	ret.ibo = new Buffer(BufferType.Index);

	auto scene = aiImportFile(filename.toStringz, 
		aiProcess_Triangulate
		| aiProcess_GenNormals
		| aiProcess_JoinIdenticalVertices
		| aiProcess_SortByPType);

	if(!scene) {
		Log(aiGetErrorString().fromStringz);
		"Model load failed".Except;
	}

	assert(scene.mNumMeshes > 0);
	auto mesh = scene.mMeshes[0];

	vec3[] verts;
	vec3[] norms;
	uint[] indices;
	verts.length = mesh.mNumVertices;
	norms.length = mesh.mNumVertices;
	indices.length = mesh.mNumFaces*3;

	Log("Num verts: ", verts.length);
	Log("Num idxs: ", indices.length);

	foreach(i; 0..mesh.mNumVertices){
		auto v = &mesh.mVertices[i];
		verts[i] = vec3(v.x, v.y, v.z);
	}

	if(mesh.mNormals){
		foreach(i; 0..mesh.mNumVertices){
			auto n = &mesh.mNormals[i];
			norms[i] = vec3(n.x, n.y, n.z);
		}
	}else{
		Log("No normals");
		norms[] = vec3.one;
	}

	foreach(i; 0..mesh.mNumFaces){
		auto f = &mesh.mFaces[i];
		assert(f.mNumIndices == 3);

		indices[i*3+0] = f.mIndices[0];
		indices[i*3+1] = f.mIndices[1];
		indices[i*3+2] = f.mIndices[2];
	}

	ret.vbo.Upload(verts);
	ret.nbo.Upload(norms);
	ret.ibo.Upload(indices);

	return ret;
}