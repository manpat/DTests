module camera;

import gl;

class Camera {
private:
	quat rotation;
	vec3 position; 
	vec3 scale;

public:
	this(){
		rotation.make_identity();
		position = vec3(0, 0, -5);
	}

	void Rotate(vec3 rot){
		auto m = rot.magnitude;
		rot.normalize;

		rotation.rotate_axis(m, rot);
	}

	void Translate(vec3 offset){
		position += offset;
	}

	void SetScale(vec3 _s){
		scale = _s;
	}

	@property auto matrix(){
		mat4 r = mat4.identity();
		r = r * rotation.to_matrix!(4,4);
		r.translate(position.x, position.y, position.z);
		//mat4 r = rotation.to_matrix!(4,4);

		r.scale(scale.x, scale.y, scale.z);
		return r;
	}
}