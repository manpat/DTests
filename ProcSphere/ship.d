module ship;

import std.math;
import camera;
import main : GetKey, GetMouseDelta;
import gl;

class Ship{
	enum Acceleration = 5.0;
	enum BoostMult = 20.0;

	enum {
		PitchSensitivity = 5.0,
		RollSensitivity = 4.0,
		YawRate = 1.0/8.0,
	}

	vec3 pos;
	vec3 vel;
	vec3 acc;

	quat rot;

	this(vec3 _pos = vec3()){
		pos = _pos;
		vel = vec3(0,0,0);
		acc = vec3(0,0,0);

		rot.make_identity();
	}

	void Update(double dt){
		Camera cam = Camera.main;

		UpdateInput(dt);
		UpdatePhysics(dt);

		cam.SetPosition(-pos);
		cam.SetRotation(rot);
	}

	private void UpdateInput(double dt){
		auto md = GetMouseDelta();
		md.x *= RollSensitivity * abs(md.x);
		md.y *= PitchSensitivity * abs(md.y);

		auto mrot = vec3(-md.y, 0, md.x);

		bool boost = GetKey(SDLK_LSHIFT);
		bool dblboost = GetKey(SDLK_TAB);

		float naccmag = Acceleration;
		if(boost) naccmag *= BoostMult;
		if(dblboost) naccmag *= BoostMult*BoostMult;

		acc = vec3(0, 0, 0);

		if(GetKey(SDLK_w)){
			acc += naccmag * vec3(0, 0,-1);
		}
		if(GetKey(SDLK_s)){
			acc += naccmag * vec3(0, 0, 1);
		}

		if(GetKey(SDLK_q)){
			acc += naccmag * vec3(-1, 0, 0);
		}
		if(GetKey(SDLK_e)){
			acc += naccmag * vec3( 1, 0, 0);
		}

		if(GetKey(SDLK_r)){
			acc += naccmag * vec3(0, 1, 0);
		}
		if(GetKey(SDLK_f)){
			acc += naccmag * vec3(0,-1, 0);
		}

		if(GetKey(SDLK_a)){
			mrot.y -= YawRate * dt;
		}
		if(GetKey(SDLK_d)){
			mrot.y += YawRate * dt;
		}

		acc = acc*rot.to_matrix!(3,3); // Local to world space

		if(GetKey(SDLK_SPACE)){
			acc = -vel*3f;
		}
		if(GetKey(SDLK_x)){
			acc = -vel*20f;
		}

		rot.rotate_axis(mrot.magnitude, mrot.normalized);
	}

	private void UpdatePhysics(double dt){
		vel += acc * dt;
		pos += vel * dt;
	}
}