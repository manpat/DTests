#type vertex
#version 420

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform bool isPicking;

in vec3 position;
in vec3 normal;
in vec3 color;
in vec3 offset;
in uint flags;

out vec4 vpos;
out vec3 vnorm;
out vec3 vcol;

void main(){
	vcol = color;

	vec4 p = vec4(position + offset, 1f);
	uint b = bitfieldExtract(flags, 2, 2);
	uint water = bitfieldExtract(flags, 0, 1);

	if(b > 0) {
		p.y += 0.2f * b;
		
		if(!isPicking)
			vcol += 0.7f;	
	}
	if(water > 0) {
		p.y -= 0.4f;
		
		if(!isPicking)
			vcol = vec3(0.3, 0.3, 1);	
	}

	if(!isPicking && bitfieldExtract(flags, 1, 1) > 0){
		vcol += vec3(0.2f);
	}

	vpos = p;
	vnorm = normal;
	gl_Position = projectionMatrix * viewMatrix * modelMatrix * p;
}

#type fragment
#version 420

uniform bool isPicking;

in vec4 vpos;
in vec3 vnorm;
in vec3 vcol;

out vec4 color;

void main(){
	if(isPicking){
		color = vec4(vcol.xyz, 1f);
	}else{
		vec3 ldir = normalize(vec3(-0.5,-1,-0.2));
		float d = dot(-ldir, normalize(vnorm));
		d = clamp(d, 0f, 2f);

		vec3 col = vcol.xyz + 0.1f;
		float fog = clamp(-vpos.y/35f, 0f, 1f);
		vec3 fogCol = vec3(0.3f, 0.7f, 1f);

		color = vec4(mix(col*d, fogCol, fog), 1f);
	}
}