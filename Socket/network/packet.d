module network.packet;

import std.socket;
import std.stdio;

class Packet {
	void[] data;
	Address from;

	this(){
	}
	this(void[] _data){
		data = _data;
	}
	this(T)(ref T _data){
		data[] = (cast(void*)&_data)[0.._data.sizeof];
	}

	@property size_t length(){
		return data.length;
	}
}