#type vertex
#version 420

in vec2 pos;
in vec2 uv;

out vec2 vuv;

void main(){
	gl_Position = vec4(pos, 0f, 1f);
	vuv = uv;
}

#type fragment
#version 420

in vec2 vuv;
out vec4 color;

void main(){
	color = vec4(vuv, 0f, 1f);
}