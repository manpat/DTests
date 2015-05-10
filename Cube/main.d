module main;

import denj.system.common;
import denj.system.window;
import denj.system.input;
import denj.graphics.common;
import denj.graphics.errorchecking;
import denj.graphics;
import denj.utility;
import denj.math;

void main(){
	try{
		Window.Init(800, 600, "A Cube");
		Input.Init();
		Renderer.Init(GLContextSettings(3, 2));

		auto sh = ShaderProgram.LoadFromFile("shader.shader");
		sh.Use();

		glFrontFace(GL_CW);
		glEnable(GL_CULL_FACE);

		auto vbo = new Buffer();
		auto ibo = new Buffer(BufferType.Index);
		vbo.Upload([
			vec3(-1,-1,-1),
			vec3( 1,-1,-1),
			vec3( 1, 1,-1),
			vec3(-1, 1,-1),

			vec3(-1,-1, 1),
			vec3(-1, 1, 1),
			vec3( 1, 1, 1),
			vec3( 1,-1, 1),
		]);

		ibo.Upload(cast(ubyte[]) [
			4, 5, 6,
			4, 6, 7,

			1, 2, 3,
			1, 3, 0,

			3, 6, 5,
			3, 2, 6,

			0, 3, 5,
			0, 5, 4,

			1, 7, 6,
			1, 6, 2,

			0, 7, 1,
			0, 4, 7,
		]);

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

			Renderer.SetAttribute(0, vbo);

			auto rot = mat4(
				cos(t*PI*2f/7f), 0, sin(t*PI*2f/7f), 0,
				0, 1, 0, 0,
				-sin(t*PI*2f/7f), 0, cos(t*PI*2f/7f), 0,
				0, 0, 0, 1,
			) * mat4(
				1, 0, 0, 0, 
				0, cos(t*PI*2f/5f), -sin(t*PI*2f/5f), 0,
				0, sin(t*PI*2f/5f), cos(t*PI*2f/5f), 0,
				0, 0, 0, 1,
			);

			sh.SetUniform("modelview", mat4.Translation(vec3(0,0,-2f)) * mat4.Scale(0.5f + sin(t*PI*2f*0f)*0.04f) * rot);

			sh.SetUniform("c", vec3(1,0,0));
			if(showVertices) Renderer.Draw(GL_POINTS);

			ibo.Bind();
			sh.SetUniform("c", vec3(0,1,1));
			Renderer.Draw(GL_TRIANGLES, 0*6, 6);
			sh.SetUniform("c", vec3(1,0,1));
			Renderer.Draw(GL_TRIANGLES, 1*6, 6);
			sh.SetUniform("c", vec3(1,1,0));
			Renderer.Draw(GL_TRIANGLES, 2*6, 6);

			sh.SetUniform("c", vec3(1,0,0));
			Renderer.Draw(GL_TRIANGLES, 3*6, 6);
			sh.SetUniform("c", vec3(0,1,0));
			Renderer.Draw(GL_TRIANGLES, 4*6, 6);
			sh.SetUniform("c", vec3(0,0,1));
			Renderer.Draw(GL_TRIANGLES, 5*6, 6);

			ibo.Unbind();
			vbo.Unbind();

			Window.FrameEnd();
			Window.Swap();
			SDL_Delay(10);
		}
		
	}catch(Exception e){
		LogF("%s:%s: error: %s", e.file, e.line, e.msg);
	}
}