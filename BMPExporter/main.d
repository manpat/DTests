module main;

import std.stdio : writeln;
import std.file;
import std.math;
import bmp;

void fill(BMP bmp){
	uint w = bmp.getWidth();
	uint h = bmp.getHeight();

	int cx = w/2;
	int cy = h/2;

	for(int y = 0; y < h; y++){
		for(int x = 0; x < w; x++){
			float dx = (x-cx)/cast(float)w;
			float dy = (y-cy)/cast(float)w;

			dx *= dx;
			dy *= dy;

			float dist = sqrt(dx + dy);
			auto r = cast(ubyte)abs( 255 * (((-y ^ x) >> 3)) + cast(ubyte)(sin(dist*PI)*101*dist) ^ (x >> 1));
			auto g = cast(ubyte)abs( 255 * (((y ^ -x) >> 2)) + ~cast(ubyte)(sin(dist*PI)*101*dist) ^ (x >> 2));
			auto b = cast(ubyte)abs( 255 * (((-y ^ x) >> 1)) + cast(ubyte)(cos(dist*PI)*101*dist) ^ (x >> 3));

			bmp.setPixel(x, y, Color([r, g, b, 255]));
		}
	}
}

void main(){
	auto data = new BMP(1u<<12, 1u<<12);
	fill(data);

	const void[] buffer = data.toRawData();
	write("test", buffer);
	write("test.bmp", buffer);
	writeln("Data size: ", data.data.sizeof, " ", data.dibHeader.dataSize);
}