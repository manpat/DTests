module hud.bar;

import std.math;
import hud.stuff;
import vertexarray;
import shader;
import gl;

class HUDBar (GUIAnchor anchor = GUIAnchor.Left) {
	private {
		VertexArray!vec2 vertices;

		float _value = 1f;
		uint numSegments;
	}

	vec2 pos = vec2(0, 0);
	vec4 col = vec4(1,1,1,1);

	this(float width = 1f, uint _numSegments = 9){
		numSegments = _numSegments;
		vertices = new VertexArray!vec2;

		vec2[] verts;
		auto separation = 0.005f;
		auto seglen = width/numSegments;
		auto segheight = 0.05f;

		static if(anchor == GUIAnchor.Left){
			auto offset = vec2(0, 0);

		}else static if(anchor == GUIAnchor.Center){
			auto offset = vec2(-width/2f, 0);

		}else static if(anchor == GUIAnchor.Right){
			auto offset = vec2(-width, 0);
		}

		foreach(i; 0..numSegments){
			auto xbeg = i*seglen + separation/2f;
			auto xend = (i+1)*seglen - separation/2f;

			auto v0 = vec2(xbeg, segheight/2f) + offset;
			auto v1 = vec2(xend, segheight/2f) + offset;
			auto v2 = vec2(xbeg,-segheight/2f) + offset;
			auto v3 = vec2(xend,-segheight/2f) + offset;

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
		auto ns = cast(float) numSegments + 0.5;

		static if(anchor == GUIAnchor.Left){
			auto start = 0;

		}else static if(anchor == GUIAnchor.Center){
			auto start = (ns - activeSegments)/2f;

		}else static if(anchor == GUIAnchor.Right){
			auto start = ns - activeSegments;
		}

		auto vstart = 6 * cast(int) floor(start);
		auto vseg = 6 * cast(int) floor(activeSegments);

		glDrawArrays(GL_TRIANGLES, vstart, vseg);

		vertices.Unbind();
	}
}