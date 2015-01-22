module ship;

import std.stdio;
import std.math;
import camera;
import input;
import gl;

class Ship{
	enum Acceleration = 5.0;
	enum BoostMult = 20.0;

	enum {
		PitchSensitivity = 2.0,
		YawSensitivity = 1.4,
		RollSensitivity = 2.0,
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

		if(JoystickActive()){
			UpdateInputJ(dt);
		}else{
			UpdateInputMK(dt);
		}
		UpdatePhysics(dt);

		cam.SetPosition(-pos);
		cam.SetRotation(rot);
	}

	private void UpdateInputJ(double dt){
		auto jrot = vec3(-GetAxis(Axis.RightY), GetAxis(Axis.LeftX), GetAxis(Axis.RightX));

		jrot.x *= PitchSensitivity * abs(jrot.x) * dt;
		jrot.y *= YawSensitivity * abs(jrot.y) * dt;
		jrot.z *= RollSensitivity * abs(jrot.z) * dt;

		float boost = GetAxis(Axis.RightTrigger);
		float dblboost = GetAxis(Axis.LeftTrigger);

		float naccmag = Acceleration;
		naccmag *= 1f + boost * BoostMult;
		naccmag *= 1f + dblboost * BoostMult*BoostMult;

		acc = vec3(0, 0, GetAxis(Axis.LeftY)) * naccmag;
		acc = acc*rot.to_matrix!(3,3); // Local to world space

		rot.rotate_axis(jrot.magnitude, jrot.normalized);

		if(GetButton(Button.LeftShoulder)){
			acc = -vel*3f;
		}
		if(GetButton(Button.RightShoulder)){
			acc = -vel*20f;
		}
	}

	private void UpdateInputMK(double dt){
		auto md = GetMouseDelta();
		md.x *= RollSensitivity * abs(md.x);
		md.y *= PitchSensitivity * abs(md.y);

		auto mrot = vec3(-md.y, 0, md.x) * dt;

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