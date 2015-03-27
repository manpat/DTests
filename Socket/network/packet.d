module network.packet;

import std.socket;
import std.traits;
import std.stdio;

import network.serialize;

struct header{
	ubyte type = 0;
}

template GetHeader(T){
	alias UDA = Tuple!(__traits(getAttributes, T));

	static if(!TupleContains!(header, UDA)){
		enum GetHeader = header(0);
	}else{
		enum GetHeader = TupleGet!(header, UDA);
	}
}

class Packet {
	void[] data;
	Address from;

	this(){
	}
	this(void[] _data){
		data = _data;
	}
	this(T)(auto ref T _data){
		data = [GetHeader!T.type];
		data ~= _data.serialize!T;

		pragma(msg, "fuck ", GetHeader!T);
	}

	T as(T)(){
		assert(T.sizeof <= data.length);

		auto type = (cast(char[])data)[0];
		data = data[1..$];
		assert(type == GetHeader!T.type);

		return data.deserialize!T;
	}

	@property size_t length(){
		return data.length;
	}
}

@header(1) struct PingPacket{
	char[4] str = "ping";
}