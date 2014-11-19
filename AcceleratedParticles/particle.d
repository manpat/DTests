module particle;

import gl;
import vector;
import shader;
import vertexarray;

import std.random;

class ParticleSystem{
	VertexArray!Particle particlePosVBO;
	VertexArray!Attractor attractorPosVBO;
	uint numParticles;
	uint begin;
	bool dirty;

	Particle[] particles;
	private Attractor[] attractors;

	Attribute posAttr, colAttr;

	Shader computeShader;

	this(uint _numParticles){
		numParticles = _numParticles;
		computeShader = new Shader("shaders/compute.glsl", "compute");

		particlePosVBO = new VertexArray!Particle(GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW);
		particlePosVBO.Load([]);

		attractorPosVBO = new VertexArray!Attractor(GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW);
		attractorPosVBO.Load([]);

		auto shader = GetShader("draw");
		posAttr = shader.GetAttribute("position");
		colAttr = shader.GetAttribute("color");

		auto gen = Random(unpredictableSeed()); 

		particles = new Particle[numParticles];
		foreach(ref p; particles){
			p.pos = vec4(0, 0, 0, 0);
			p.vel = vec4(0, 0, 0, 0);
			//p.col = vec4(0, 1, 0, 1);
		}
		begin = 0;
		dirty = true;
		//Upload();
	}

	void Draw(){
		particlePosVBO.Bind!(vec4, "pos")(posAttr);
		particlePosVBO.Bind!(vec4, "col")(colAttr);

		glDrawArrays(GL_POINTS, 0, particlePosVBO.length);

		particlePosVBO.Unbind();
	}

	private Particle* FindFreeParticle(){
		if(begin == numParticles) begin = 0;

		return &particles[begin++];
	}

	void Emit(vec3 pos, vec3 vel){
		Particle* p = FindFreeParticle();
		if(p != null){
			p.pos.values[0..3] = pos.values[0..3];
			p.pos.w = 0f;
			p.vel.values[0..3] = vel.values[0..3];
			p.vel.w = 1f;

			dirty = true;
		}
	}

	void Update(double dt){
		if(dirty) {
			particlePosVBO.Load(particles);
			dirty = false;
		}

		computeShader.Use();
		computeShader.SetUniform("dt", dt);

		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, particlePosVBO.raw);
		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, attractorPosVBO.raw);

		glDispatchCompute(particlePosVBO.length/10000, 1000, 10);

		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, 0);

		glBindBuffer(GL_ARRAY_BUFFER, particlePosVBO.raw);
		particles = (cast(Particle*)glMapBuffer(GL_ARRAY_BUFFER, GL_READ_ONLY))[0..particlePosVBO.length];
		glUnmapBuffer(GL_ARRAY_BUFFER);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	void Upload(){
	}

	void AddAttractor(vec3 _pos, double str = 1f){
		vec4 pos;
		pos.values[0..3] = _pos.values;
		pos.w = 0f;
		attractors ~= Attractor(pos, str);
		attractorPosVBO.Load(attractors);
	}

	void ClearAttractors(){
		attractors = [];
		attractorPosVBO.Load(attractors);
	}
}

struct Particle{
	vec4 pos;
	vec4 vel;
	vec4 col;
}

struct Attractor{
	vec4 pos;
	double strength = 1f;
	double[3] _;
}