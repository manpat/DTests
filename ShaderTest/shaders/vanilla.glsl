#type vertex
#version 150

uniform float time;

in vec2 position;
out vec2 pos;

void main(){
	gl_Position = vec4(position.xy, 0f, 1f);
	pos = position;
}

#type fragment
#version 150

uniform float time;

in vec2 pos;
out vec4 color;

float map(float a, float l, float u){
	return a * (u - l) + l;
}

float st01(float s = 1f){
	return sin(time * s)*0.5 + 0.5;
}

vec2 idk(vec2 p){
	float t = map(st01(0.1f), 0.0f, 0.15f) * 3.14159f;

	vec2 a = abs(p) * inverse( 
		mat2(0.3, -0.18, 
			-1.1,  0.13) 
		*
		mat2(cos(t),-sin(t),
			 sin(t), cos(t))
		);
	vec2 b = sin(a);
	vec2 c = fract(b) * inverse( mat2(1, 0.065, 0, 0.374) );

	return fract(c);
}

void main(){
	float t01 = sin(time)*0.5 + 0.5;

	vec2 y = idk(pos/2) * inverse(
		mat2(map(st01(1f/3f), 0.5f, 1f), map(st01(1f), -0.07, -0.05), 
			0, 1));

	y = fract(y);

	float f = y.x;

	color = vec4(f, f, f, 1f); 
}