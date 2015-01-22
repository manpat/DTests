import std.random;
import std.stdio;
import std.conv;
import std.math;

import shader;
import cruft;

import vertexarray;
import camera;
import sphere;
import input;
import roam;
import hud;
import gl;

import ship;

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		auto shader = new Shader("shaders/passthrough.glsl", "draw");
		auto posAttr = shader.GetAttribute("position");

		InitHUD();
		InitInput();

		auto camera = new Camera;
		//auto ship = new Ship(vec3(0, 0, 1000000));
		auto sphere = new Sphere(6);

		float aspect = 8f/6f;
		mat4 projectionMatrix = projection(60f, aspect, 0.1, 500);
		shader.SetUniform("projectionMatrix", projectionMatrix);

		double dt = 0f;

		double t = 0f;
		bool running = true;
		bool emit = false;

		enum framecap = 100;
		uint framecount = 0;
		double frameaccum = 0;
		double fps = 0;

		glPointSize(3);
		//glLineWidth(3);

		enum queryType = GL_PRIMITIVES_GENERATED;

		GLuint primitivesQuery;
		GLint numprimitives;
		glGenQueries(1, &primitivesQuery);

		bool doCheckMouseMove = true;

		while(running){
			SDL_Event e;
			CheckInputEvents(&e);

			if(GetKey(SDLK_ESCAPE)){
				running = false;
			}

			auto pt = SDL_GetTicks()/1000f;
			dt = pt - t;
			t = pt;

			frameaccum += dt;
			framecount++;
			if(frameaccum >= 0.25f){
				fps = cast(double)framecount / frameaccum;
				frameaccum = 0;
				framecount = 0;
			}

			shader.Use();

			//ship.Update(dt);
			camera.Update();

			shader.SetUniform!float("time", t);
			shader.SetUniform("projectionMatrix", projectionMatrix);

			glClearColor(0f, 0f, 0f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			glBeginQuery(queryType, primitivesQuery);

			posAttr.Enable();
			MatrixStack.Push();
				MatrixStack.top = MatrixStack.top * mat4.rotation(t*0.2f, 0f, 1f, 0f);

				sphere.Draw(posAttr);

			MatrixStack.Pop();
			posAttr.Disable();

			glEndQuery(queryType);
			glGetQueryObjectiv(primitivesQuery, GL_QUERY_RESULT, &numprimitives);

			glClear(GL_DEPTH_BUFFER_BIT);

			PrintHUD!(GUIAnchor.Left)(to!string(numprimitives) ~ " tris", vec2(-0.98, 0.9));
			PrintHUD!(GUIAnchor.Left)(to!string(fps) ~ " fps", vec2(-0.98, 0.83));

			Swap();
		}

	}catch(Exception e){
		writeln("Fuck: ", e.msg);
	}
}

mat4 projection(float fov, float a, float n, float f){
	float D2R = PI/180f;
	float ys = 1f / tan(D2R * fov / 2);
	float xs = ys / a;
	float fn = 1f / (f-n);

	return mat4(xs, 0, 0, 0,
				0, ys, 0, 0,
				0, 0, -(f+n)*fn,-2*f*n*fn,
				0, 0, -1, 0);
}


//auto verts = new VertexArray!vec3();
//verts.Load([
//	vec3(-1, -1, -1), // 0
//	vec3(-1,  1, -1),
//	vec3( 1,  1, -1),
//	vec3( 1, -1, -1),

//	vec3(-1, -1,  1), // 4
//	vec3( 1, -1,  1),
//	vec3( 1,  1,  1),
//	vec3(-1,  1,  1),

//	vec3(-1, -1, -1), // 8
//	vec3(-1, -1,  1),
//	vec3(-1,  1,  1),
//	vec3(-1,  1, -1),

//	vec3( 1, -1, -1), // 12
//	vec3( 1,  1, -1),
//	vec3( 1,  1,  1),
//	vec3( 1, -1,  1),

//	vec3(-1, -1, -1), // 16
//	vec3( 1, -1, -1),
//	vec3( 1, -1,  1),
//	vec3(-1, -1,  1),

//	vec3(-1,  1, -1), // 20
//	vec3(-1,  1,  1),
//	vec3( 1,  1,  1),
//	vec3( 1,  1, -1),
//]);

//auto indices = new VertexArray!uint(GL_ELEMENT_ARRAY_BUFFER);
//indices.Load([
//	0, 1, 2,
//	0, 2, 3,

//	4, 5, 6,
//	4, 6, 7,

//	8, 9, 10,
//	8, 10, 11,

//	12, 13, 14,
//	12, 14, 15,

//	16, 17, 18,
//	16, 18, 19,

//	20, 21, 22,
//	20, 22, 23

//]);