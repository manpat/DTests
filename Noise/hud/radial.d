module hud.radial;

import std.math;
import hud.stuff;
import vertexarray;
import shader;
import gl;

class HUDRadial(GUIAnchor anchor = GUIAnchor.Left) {
	private {
		VertexArray!vec2 vertices;

		float _value = 1f;
		uint numSegments;
	}

	vec2 pos = vec2(0, 0);
	vec4 col = vec4(1,1,1,1);

	this(float outerradius = 1f, float segthickness = 0.1f, float rads = 3*PI/2, uint _numSegments = 9){
		numSegments = _numSegments;
		vertices = new VertexArray!vec2;

		vec2[] verts;
		auto separation = 0.02f;
		auto segrad = -rads/numSegments;

		auto radbeg = (rads + PI)/2;

		foreach(i; 0..numSegments){
			auto abeg = i*segrad - separation/2f + radbeg;
			auto aend = (i+1)*segrad + separation/2f + radbeg;

			auto v0 = vec2(cos(abeg), sin(abeg))*outerradius;
			auto v1 = vec2(cos(aend), sin(aend))*outerradius;
			auto v2 = vec2(cos(abeg), sin(abeg))*(outerradius - segthickness);
			auto v3 = vec2(cos(aend), sin(aend))*(outerradius - segthickness);

			verts ~= v0;
			verts ~= v2;
			verts ~= v1;

			verts ~= v1;
			verts ~= v2;
			verts ~= v3;
		}
		vertices.Load(verts);
	}

	@property {
		void value(float _v){
			_value = clamp(_v, 0f, 1f);
		}

		float value(){
			return _value;
		}
	}

	void Render(){
		vertices.Bind(GetHUDPosAttr());
		SetHUDPos(pos);
		SetHUDCol(col);

		auto activeSegments = round(numSegments * value);
		auto ns = cast(float) numSegments;

		static if(anchor == GUIAnchor.Left){
			float start = 0;

		}else static if(anchor == GUIAnchor.Center){
			float start = (ns - activeSegments + 0.75f)/2f;

		}else static if(anchor == GUIAnchor.Right){
			float start = ns - activeSegments;
		}

		auto vstart = 6 * cast(int) floor(start);
		auto vseg = 6 * cast(int) floor(activeSegments);

		glDrawArrays(GL_TRIANGLES, vstart, vseg);

		vertices.Unbind();
	}
}