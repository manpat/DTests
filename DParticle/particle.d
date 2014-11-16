module particle;

import gl;
import vector;
import shader;
import vertexarray;

import std.random;

class ParticleSystem{
	VertexArray!Particle particlePosVBO;
	uint numParticles;

	Particle[] particles;
	Attractor[] attractors;

	Attribute posAttr;

	this(uint _numParticles){
		numParticles = _numParticles;

		particlePosVBO = new VertexArray!Particle(GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW);
		particlePosVBO.Load([]);

		auto shader = GetActiveShader();
		posAttr = shader.GetAttribute("position");

		auto gen = Random(unpredictableSeed()); 

		particles = new Particle[numParticles];
		foreach(ref p; particles){
			p.pos = vec3();
			p.vel = vec3();
			p.alive = false;
		}
		Upload();
	}

	void Draw(){
		particlePosVBO.Bind!(vec3, "pos")(posAttr);

		glDrawArrays(GL_POINTS, 0, particlePosVBO.length);

		particlePosVBO.Unbind();
	}

	private Particle* FindFreeParticle(){
		foreach(i; 0..numParticles){
			if(!particles[i].alive){
				return &particles[i];
			}
		}

		return null;
	}

	void Emit(vec3 pos, vec3 vel){
		Particle* p = FindFreeParticle();
		if(p != null){
			p.alive = true;
			p.pos = pos;
			p.vel = vel;
		}
	}

	void Update(double dt){
		foreach(ref p; particles){
			if(!p.alive) continue;

			auto acc = vec3(0,0,0);

			foreach(ref a; attractors){
				auto diff = p.pos - a.pos;
				auto dir = diff.normalised;
				double d = diff.magnitude;
				double force = 1f/(d);

				acc = acc + dir * force * a.strength;
			}

			p.vel = p.vel + acc * dt;
			p.pos = p.pos + p.vel * dt;

			if(p.pos.magnitude > 3f){
				p.alive = false;
			}
		}
	}

	void Upload(){
		particlePosVBO.Load(particles);
	}
}

struct Particle{
	vec3 pos;
	vec3 vel;
	bool alive;
}

struct Attractor{
	vec3 pos;
	double strength = 1f;
}