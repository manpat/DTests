module bmp;

import std.bitmanip;
import std.stdio;

struct Color{
	ubyte[4] data;

	this(ubyte[4] _d){
		this.data[] = _d[];
	}
}

struct BMPHeader {
	char[2] magic = "BM";
	uint size;
	uint reserved = 0;
	uint offset; // starting address of bitmap data

	this(uint _size, uint _offset){
		this.size = _size;
		this.offset = _offset;
	}

	ubyte[] toRawData(){
		auto data = new ubyte[14];
		data[0..2] = cast(ubyte[]) magic[0..2];
		data[2..6] = nativeToLittleEndian(size);
		data[6..10] = nativeToLittleEndian(reserved);
		data[10..14] = nativeToLittleEndian(offset);

		return data;
	}
}

// BITMAPINFOHEADER
struct DIBHeader {
	uint headerSize = 40;
	int width;
	int height;
	short numColorPlanes = 1;
	short bpp;
	uint compressionMethod = 0; // BI_RGB
	uint dataSize = 0;
	int horizontalResolution = 1000; // px/m
	int verticalResolution = 1000; // px/m
	uint numColorsInColorPalette = 0;
	uint numImportantColorsUsed = 0;

	this(int _width, int _height, short _bpp = 32){
		this.width = _width;
		this.height = _height;
		this.bpp = _bpp;
		this.dataSize = _width * _height * 4;
	}

	ubyte[] toRawData(){
		auto data = new ubyte[40];
		data[0..4] = nativeToLittleEndian(headerSize);
		data[4..8] = nativeToLittleEndian(width);
		data[8..12] = nativeToLittleEndian(height);
		data[12..14] = nativeToLittleEndian(numColorPlanes);
		data[14..16] = nativeToLittleEndian(bpp);
		data[16..20] = nativeToLittleEndian(compressionMethod);
		data[20..24] = nativeToLittleEndian(dataSize);
		data[24..28] = nativeToLittleEndian(horizontalResolution);
		data[28..32] = nativeToLittleEndian(verticalResolution);
		data[32..36] = nativeToLittleEndian(numColorsInColorPalette);
		data[36..40] = nativeToLittleEndian(numImportantColorsUsed);

		return data;
	}
}

class BMP {
	BMPHeader bmpHeader;
	DIBHeader dibHeader;
	ubyte[] data;

	this(int width, int height, short bpp = 32){
		const headerSize = 54;

		dibHeader = DIBHeader(width, height, bpp);
		data = new ubyte[dibHeader.dataSize];

		bmpHeader = BMPHeader(headerSize + data.sizeof, headerSize);

		writeln(headerSize, " ", BMPHeader.sizeof, " ", DIBHeader.sizeof);
	}

	uint getWidth(){
		return dibHeader.width;
	}
	uint getHeight(){
		return dibHeader.height;
	}

	void setPixel(int x, int y, Color c){
		uint idx = ((dibHeader.height - y - 1) * dibHeader.width + x) * 4;
		data[idx..idx+4] = c.data[0..4];
	}

	ubyte[] toRawData(){
		ubyte[] raw = bmpHeader.toRawData();
		raw ~= dibHeader.toRawData();
		raw ~= data;

		return raw;
	}
}