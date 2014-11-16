#type vertex
#version 150

uniform float time;

in vec2 position;
in vec3 color;

out vec3 vcol;

vec2 rotate(vec2 v, float th){
	float cs = cos(th);
	float sn = sin(th);

	vec2 r;
	r.x = v.x * cs - v.y * sn;
	r.y = v.x * sn + v.y * cs;
	return r;
}

void main(){
	const vec2 offset = vec2(0f, 1f);
	vec2 opos = position + offset;
	gl_Position = vec4(rotate(opos, sin(time/2f)*0.05f*opos.y) - offset, 
		 0, 1);
	vcol = color;
}

#type fragment
#version 150

uniform float time;

in vec3 vcol;
out vec4 color;

void main(){
	color = vec4(vcol, 1); //vec4(sin(time)*0.4f + 0.6f, 0.8, 0.6, 1);
}
