import std.stdio;
import std.conv;
import std.math;
import std.random;

import cruft;
import shader;

import model;
import vertexarray;
import camera;
import hud;
import gl;

import ship;

private bool[int] keys;
private auto dlt = vec2(0,0);

bool GetKey(int k){
	return keys.get(k, false);
}

vec2 GetMouseDelta(){
	return dlt;
}

struct Planet {
	Icosahedron model;
	double yearRate; // in cycles per second
	vec3 center = vec3(0,0,0);
	float orbitRadius = 0f;
	double orbitPeriod = double.max; // in seconds

	vec3 color = vec3(1,1,1);
}

void main(){
	try{
		InitCruft();
		scope(exit) DeinitCruft();

		auto shader = new Shader("shaders/vanilla.glsl", "draw");
		auto posAttr = shader.GetAttribute("position");

		InitHUD();

		auto cspeed1 = new HUDRadial!(GUIAnchor.Left)(0.25f, 0.02f, 2*PI, 100);
		cspeed1.col = vec4(0.5, 1, 0, 0.9);

		auto cspeed2 = new HUDRadial!(GUIAnchor.Left)(0.28f, 0.02f, 2*PI, 100);
		cspeed2.col = vec4(1, 1, 0, 0.9);

		auto cspeed3 = new HUDRadial!(GUIAnchor.Left)(0.31f, 0.02f, 2*PI, 100);
		cspeed3.col = vec4(0.6, 0.4, 0.6, 0.9);

		auto glog = new HUDRadial!(GUIAnchor.Left)(0.33f, 0.02f, 2*PI, 100);
		glog.col = vec4(1, 0, 0, 0.9);

		auto camera = new Camera;
		auto ship = new Ship(vec3(0, 0, 40000));

		static zero = vec3(0,0,0);

		auto planets = [
			//Planet(new Icosahedron(3, 500000), 0.002, vec3(600000.0, -500000.0, -400000), 0, double.max, vec3(1, 0.7, 0.2)),
			Planet(new Icosahedron(3, 100000), 0.002, vec3(0, -5000.0, -300000), 0, double.max, vec3(1, 0.7, 0.2)),

			Planet(new Icosahedron(1, 3000), 1.0/(365.24*60.0*60.0*100_000.0), zero, 0, double.max, vec3(0.1, 0.5, 0.3)),
			Planet(new Icosahedron(1, 800), -0.1, zero, 25000f, 4000f, vec3(0.7, 0.7, 0.7)),

			Planet(new Icosahedron(1, 6000), 0.1, vec3(0, -5000.0, -300000), 200000f, 120f, vec3(1, 0.4, 0.1)),
			Planet(new Icosahedron(1, 4000), 0.1, vec3(0, -5000.0, -300000), 199000f, 300f, vec3(0.6, 0.2, 0.0)),
			Planet(new Icosahedron(1, 800), 0.4, vec3(0, -5000.0, -300000), 196000f, 80f, vec3(0.3, 0.1, 0.0)),
			Planet(new Icosahedron(1, 700), 0.4, vec3(0, -5000.0, -300000), 110000f, 20f, vec3(0.3, 0.1, 0.0)),
			Planet(new Icosahedron(1, 900), 0.4, vec3(0, -5000.0, -300000), 120000f, 50f, vec3(0.3, 0.1, 0.0)),

			Planet(new Icosahedron(1, 9000), -0.01, vec3(0, -5000.0, -300000), 250000f, -800f, vec3(0.2, 0.5, 0.9)),
		];

		float aspect = 8f/6f;
		mat4 projectionMatrix = projection(60f, aspect, 0.1, 1000000);
		shader.SetUniform("projectionMatrix", projectionMatrix);

		double dt = 0f;

		double t = 0f;
		bool running = true;
		bool emit = false;

		enum framecap = 100;
		uint framecount = 0;
		double frameaccum = 0;

		glPointSize(3);
		//glLineWidth(3);

		int tessLevel = 1;
		shader.SetUniform("tessLevel", tessLevel);

		float speed = 1f;

		GLuint sampleQuery;
		GLint numsamples;
		glGenQueries(1, &sampleQuery);

		bool doCheckMouseMove = true;

		while(running){
			auto m = vec2(0,0);

			SDL_Event e;
			while(SDL_PollEvent(&e)){
				switch(e.type){
					case SDL_KEYDOWN:
						if(e.key.keysym.sym == SDLK_ESCAPE){
							running = false;
						}else if(e.key.keysym.sym == SDLK_RIGHTBRACKET){
							tessLevel += 1;
							shader.SetUniform("tessLevel", tessLevel);
						}else if(e.key.keysym.sym == SDLK_LEFTBRACKET){
							tessLevel = max(1, tessLevel-1);
							shader.SetUniform("tessLevel", tessLevel);
						}else if(e.key.keysym.sym == SDLK_RETURN){
							shader.Load();
							posAttr = shader.GetAttribute("position");
							shader.SetUniform("projectionMatrix", projectionMatrix);
							shader.SetUniform("tessLevel", tessLevel);
						}
						keys[e.key.keysym.sym] = true;
						break;

					case SDL_KEYUP:
						keys[e.key.keysym.sym] = false;
						break;

					case SDL_MOUSEMOTION:{
						if(doCheckMouseMove){
							m = vec2(e.motion.x, e.motion.y);
							m.x = (m.x / 800f) * 2f - 1f;
							m.y = (-m.y / 600f) * 2f + 1f;
							WarpToCenter();
						}
						
						doCheckMouseMove = !doCheckMouseMove;
						break;
					}

					default:
						break;
				}
			}

			if(doCheckMouseMove){
				dlt = m;
			}

			auto pt = SDL_GetTicks()/1000f;
			dt = pt - t;
			t = pt;

			frameaccum += dt;
			framecount++;
			if(framecount >= framecap){
				double fps = cast(double)framecount / frameaccum;
				writeln("FPS: " ~ to!string(fps));
				writeln("samples: " ~ to!string(numsamples) ~ "  (" ~ to!string(fps/cast(double)numsamples) ~ ")");
				stdout.flush();
				frameaccum = 0;
				framecount = 0;

				writeln(camera.eyepos);
			}

			shader.Use();

			ship.Update(dt);
			camera.Update();

			shader.SetUniform!float("time", t);
			shader.SetUniform("projectionMatrix", projectionMatrix);
			shader.SetUniform("sunpos", vec3(0, 0.0, 100000));

			glClearColor(0f, 0f, 0f, 1f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			glBeginQuery(GL_SAMPLES_PASSED, sampleQuery);

			posAttr.Enable();

			MatrixStack.Push();
				foreach(planet; planets){
					MatrixStack.Push();

					MatrixStack.top = MatrixStack.top *
						mat4.translation(planet.center.x, planet.center.y, planet.center.z) * // Orbit center

						mat4.rotation(2.0*PI/planet.orbitPeriod * t, 0f, 1f, 0f) * // Orbit
						mat4.translation(0, 0, planet.orbitRadius) * // Orbit radius

						mat4.rotation(2.0*PI*planet.yearRate * t, 0f, 1f, 0f); // Year

					shader.SetUniform("planetcol", planet.color);

					planet.model.Render(posAttr);

					MatrixStack.Pop();
				}

			MatrixStack.Pop();

			posAttr.Disable();

			enum LightSpeedo10 = 2.9e+5; // C/10
			enum LightSpeedo100 = LightSpeedo10/10.0; // C/100
			enum LightSpeedo1000 = LightSpeedo100/10.0; // C/1000
			enum EarthG = 9.8;

			static float ch = 36f/800f;

			PrintHUD!(GUIAnchor.Center)(to!string(ship.vel.magnitude.round) ~ "m/s", vec2(0, -ch*3f));
			//PrintHUD!(GUIAnchor.Right)(to!string((ship.acc.magnitude/EarthG).round) ~ "G", vec2(-0.04f, -ch/2f));
			//PrintHUD!(GUIAnchor.Center)(to!string(ship.pos.magnitude.round - 1200), vec2(0, -ch*3f));

			EnableHUDAttributes();

			cspeed3.value = ship.vel.magnitude/LightSpeedo10;
			cspeed3.Render();

			cspeed2.value = ship.vel.magnitude/LightSpeedo100;
			cspeed2.Render();

			cspeed1.value = ship.vel.magnitude/LightSpeedo1000;
			cspeed1.Render();

			glog.value = log(ship.acc.magnitude/EarthG)/(log(10f) * 5f);
			glog.Render();

			DisableHUDAttributes();

			glEndQuery(GL_SAMPLES_PASSED);
			glGetQueryObjectiv(sampleQuery, GL_QUERY_RESULT, &numsamples);

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