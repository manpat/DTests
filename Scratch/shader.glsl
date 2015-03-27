#version 330

uniform float aspect;
uniform float time;

in vec2 uv;
out vec4 color;

float intersectSphere(vec3 ro, vec3 rd, vec3 center, float r, out vec3 norm){
	norm = vec3(0);

	vec3 off = ro - center;

	float b = 2f * dot(off,rd);
	float c = dot(off, off) - r*r;
	float h = b*b - 4f*c;
	if(h < 0f) return -1f;

	float t = (-b - sqrt(h))/2f;
	norm = normalize(off+rd*t);

	return t;
}

float intersectPlaneX(vec3 ro, vec3 rd){
	return -ro.x/rd.x;
}
float intersectPlaneY(vec3 ro, vec3 rd){
	return -ro.y/rd.y;
}
float intersectPlaneZ(vec3 ro, vec3 rd){
	return -ro.z/rd.z;
}

float scene(vec3 ro, vec3 rd, out float dist, out vec3 norm){
	float minDistance = 999999999f;
	float id = -1f;
	float tpla = intersectPlaneY(ro-vec3(0f, -4f, 0f), rd);
	float tpla2 = intersectPlaneX(ro-vec3(-10f, 0f, 0), rd);
	norm = vec3(0);
	dist = -1f;

	float inc = (3.1415*2f)/12f;
	float sphsize = 1.2f;

	for(float a = 0f; a < 3.1415*2f; a += inc){
		vec3 n;

		float tsph = intersectSphere(
			ro, 
			rd, 
			vec3(sin(a), sin(time*0.1f + a*3f)*0.1f + 0.2f, cos(a))*(9f + (0.1f*sin(time+a))), 
			sphsize + sin(time*0.1f + a)*0.3f, n );

		if(tsph>0f && tsph < minDistance){
			minDistance = tsph;
			norm = n;
			id = 1f;
		}
	}	

	for(float a = 0f; a < 3.1415*2f; a += inc){
		vec3 n;

		float tsph = intersectSphere(
			ro, 
			rd, 
			vec3(sin(a+time*0.04f), sin(-time*0.1f + a*3f)*0.1f - 0.2f, cos(a+time*0.04f))*(9f + (0.1f*sin(time+a))), 
			sphsize + sin(time*0.1f - a)*0.3f, n );

		if(tsph>0f && tsph < minDistance){
			minDistance = tsph;
			norm = n;
			id = 1f;
		}
	}

	for(float a = 0f; a < 3.1415*2f; a += inc){
		vec3 n;
		float timeDilate = 0.05;
		float r = 50f;

		float tsph = intersectSphere(
			ro, 
			rd, 
			vec3(sin(a+time*timeDilate)*r, 1f + sin(time+a), cos(a+time*timeDilate)*r),
			8f, n );

		if(tsph>0f && tsph < minDistance){
			minDistance = tsph;
			norm = n;
			id = 5f;
		}
	}	

	vec3 n;

	float tsph = intersectSphere(
		ro, 
		rd, 
		vec3(0, 1f + sin(time*0.1f)*2f, 0f), 
		7f, n );

	if(tsph>0f && tsph < minDistance){
		minDistance = tsph;
		norm = n;
		id = 3f;
	}

	if(tpla>0f && tpla < minDistance){
		minDistance = tpla;
		norm = vec3(0, 1, 0);
		id = 2f;
	}

	// if(tpla2>0f && tpla2 < minDistance){
	// 	minDistance = tpla2;
	// 	norm = vec3(0, 1, 0);
	// 	id = 4f;
	// }

	if(id > 0f){
		dist = minDistance;
	}

	return id;
}

void main(){
	float a = time*0.02f;
	vec3 ro = vec3(sin(a), 0f, cos(a))*15f;
	// vec3 ro = vec3(0, 0, 4f);
	// vec3 rd = normalize(vec3(uv * vec2(aspect, 1f), -1f));

	float c = cos(-a);
	float s = sin(-a);
	float x = uv.x * aspect;
	float y = -1f;

	vec3 rd = normalize(vec3(x*c - y*s, uv.y, x*s + y*c)); 
	vec3 ord = rd;

	float t = -1f;
	vec3 norm = vec3(0,0,0);
	int reflections = 5;
	float colorMult = 1f;
	vec3 col = vec3(0);

	for(int i = 0; i < reflections; i++){
		vec3 albedo = vec3(0);
		float mult = 1f;
		float id = scene(ro, rd, t, norm);

		ro = ro+rd*t;

		if(length(norm) > 0f){
			rd = reflect(rd, norm);
		}
		
		if(id > 3.5f){
			albedo = vec3(0);
			mult = 0.8f;
			// rd = vec3(0, 1, 0);
			// rd.y *= sign(norm.y);

		}else if(id > 2.5f){
			albedo = vec3(-0.1);
			mult = 0.5f;

		}else if(id > 1.5f){
			albedo = vec3(1, 0, 0);
			mult = 0.2f;

		}else if(id > 0.5f){
			albedo = vec3(0, 0.5, 0);
			mult = 0.3f;

		}else{
			col += vec3(2f - length(uv * vec2(aspect, 1f))) * vec3(1f, 0f, 1f) * 0.2f * colorMult;
			break;
		}
		// mult = 0.6f;

		float skim = dot(-ord, norm);
		col = mix(col, albedo, skim*skim*colorMult);
		colorMult *= mult;
	}
	
	color = vec4(col, 1);
}