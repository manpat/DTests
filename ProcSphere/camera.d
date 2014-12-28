module camera;

import gl;
import shader;

class Camera {
static public Camera main;

private:
	quat rotation;
	vec3 position; 

public:
	this(){
		main = this;

		rotation.make_identity();
		position = vec3(0, 0, -3);
	}

	void Rotate(vec3 rot){
		auto m = rot.magnitude;
		rot.normalize;

		rotation.rotate_axis(m, rot);
	}

	void Translate(vec3 offset){
		//position += rotation*offset*rotation.inverse;
		position += offset*rotation.to_matrix!(3,3);
	}

	void SetPosition(vec3 _p){
		position = _p;
	}

	void Update(){
		auto s = GetActiveShader();
		s.SetUniform("viewMatrix", matrix());
		s.SetUniform("eyepos", -position);
	}

	@property auto matrix(){
		mat4 r = mat4.identity();
		r.translate(position.x, position.y, position.z);
		r = rotation.to_matrix!(4,4) * r;
		return r;
	}

	@property auto eyepos(){
		return position;
	}
}

class MatrixStack {
private:
	static mat4[] stack;
	static mat4 current;
	static ulong stackDepth;
	static ulong stackSize;

public:
	static this(){
		stackSize = 32;
		stackDepth = 0;

		stack.length = stackSize;
		current.make_identity;
	}

	static void Push(){
		stack[stackDepth] = current;
		stackDepth++;

		if(stackDepth == stackSize){
			stackSize *= 2;
			stack.length = stackSize;
		}
	}

	static void Pop(){
		if(stackDepth == 0) throw new Exception("Tried to pop empty matrix stack");
		stackDepth--;
		current = stack[stackDepth];

		Update();
	}

	static void SetIdentity(){
		current.make_identity;
		Update();
	}

	static @property {
		mat4 top(){
			return current;
		}

		void top(mat4 n){
			current = n;
			Update();
		}
	} 

	static void Update(){
		auto s = GetActiveShader();
		s.SetUniform("modelMatrix", current);
	}
}