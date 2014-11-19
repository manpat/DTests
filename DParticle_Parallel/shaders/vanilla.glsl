#type vertex
#version 150

uniform float time;

in vec3 position;
in vec3 color;

out vec3 vcol;

void main(){
	gl_Position = vec4(position, 1);
	vcol = color;
}

#type fragment
#version 150

uniform float time;

in vec3 vcol;
out vec4 color;

void main(){
	// color = vec4(vcol, 1); 
	color = vec4(1); 
}