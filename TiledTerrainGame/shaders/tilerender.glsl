#type vertex
#version 420

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform bool isPicking;

in vec3 position;
in vec3 color;
in vec3 offset;
in uint flags;

out vec3 vcol;

void main(){
	vcol = color;

	vec4 p = vec4(position + offset, 1f);
	uint b = bitfieldExtract(flags, 0, 2);

	if(b > 0) {
		p.y += 0.2f * b;
		
		if(!isPicking)
			vcol += 0.7f;	
	}

	if(!isPicking && bitfieldExtract(flags, 2, 1) > 0){
		vcol += vec3(0.2f, -0.2f, 0.2f);
	}

	gl_Position = projectionMatrix * viewMatrix * modelMatrix * p;
}

#type fragment
#version 420

in vec3 vcol;
out vec4 color;

void main(){
	color = vec4(vcol, 1f);
}