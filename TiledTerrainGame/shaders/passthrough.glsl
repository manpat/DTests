#type vertex
#version 420

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;

in vec3 position;

void main(){
	gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1f);
}

#type fragment
#version 420

out vec4 color;

void main(){
	color = vec4(1f);
}