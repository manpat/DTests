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
	uint begin, savedbegin;
	bool dirty;

	Particle[] particles;
	private Attractor[] attractors;

	Attribute posAttr, colAttr;

	Shader computeShader;

	this(uint _numParticles){
		numParticles = _numParticles;
		computeShader = new Shader("shaders/compute.glsl", "compute");

		particlePosVBO = new VertexArray!Particle(GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW);
		attractorPosVBO = new VertexArray!Attractor(GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW);

		auto shader = GetShader("draw");
		posAttr = shader.GetAttribute("position");
		colAttr = shader.GetAttribute("color");

		particles = new Particle[numParticles];
		foreach(ref p; particles){
			p.pos = vec4(0, 0, 0, 0);
			p.vel = vec4(0, 0, 0, 0);
			//p.col = vec4(0, 1, 0, 1);
		}
		particlePosVBO.Load(particles);
		attractorPosVBO.Load([]);

		begin = savedbegin = 0;
		dirty = true;
	}

	void Draw(){
		particlePosVBO.Bind!(vec4, "pos")(posAttr);
		particlePosVBO.Bind!(vec4, "col")(colAttr);

		glDrawArrays(GL_POINTS, 0, numParticles);

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
			dirty = false;
			particlePosVBO.Bind();

			if(begin > savedbegin){
				glBufferSubData(GL_ARRAY_BUFFER, savedbegin * Particle.sizeof, (begin - savedbegin) * Particle.sizeof, &particles[savedbegin]);
			}else{
				glBufferSubData(GL_ARRAY_BUFFER, savedbegin * Particle.sizeof, (numParticles - savedbegin) * Particle.sizeof, &particles[savedbegin%numParticles]);
				glBufferSubData(GL_ARRAY_BUFFER, 0, begin * Particle.sizeof, particles.ptr);
			}

			particlePosVBO.Unbind();

			savedbegin = begin;
		}

		computeShader.Use();
		computeShader.SetUniform("dt", cast(float) dt);

		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, particlePosVBO.raw);
		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, attractorPosVBO.raw);

		glDispatchCompute(particlePosVBO.length/10000, 100, 100);

		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, 0);
		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, 0);
	}

	void AddAttractor(vec3 _pos, float str = 1f){
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

	void ClearParticles(){
		foreach(ref p; particles){
			p.vel = vec4(0,0,0,0);
		}

		particlePosVBO.Load(particles);
	}
}

struct Particle{
	vec4 pos;
	vec4 vel;
	vec4 col;
}

struct Attractor{
	vec4 pos;
	float strength = 1f;
	float[3] _;
}