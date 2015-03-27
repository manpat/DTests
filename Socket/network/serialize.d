module network.serialize;

import std.traits;
import std.stdio;
import std.conv;

version(Windows){
	static if (__VERSION__ >= 2067)
		import core.sys.windows.winsock2 : ntohs, htons, ntohl, htonl;
	else
		import std.c.windows.winsock : ntohs, htons, ntohl, htonl;
}else{
	version(Posix) import core.sys.posix.netdb  : ntohs, htons, ntohl, htonl;
}

void[] toVoid(T)(auto ref T data){
	return (cast(void*)&data)[0..T.sizeof];
}

template Tuple(T...){
	alias Tuple = T;
}

template TupleContains(Needle, T...){
	static if(T.length == 0){
		enum TupleContains = false;
	}else static if(__traits(isSame, T[0], Needle)){
		enum TupleContains = true;
	}else static if(is(typeof(T[0]) == Needle)){
		enum TupleContains = true;
	}else{
		enum TupleContains = TupleContains!(Needle, T[1..$]);
	}
}

template TupleGet(Needle, T...){
	static if(T.length == 0){
		pragma(msg, Needle, " not in tuple");
		static assert(0);
	}else static if(__traits(isSame, T[0], Needle)){
		enum TupleGet = T[0];
	}else static if(is(typeof(T[0]) == Needle)){
		enum TupleGet = T[0];
	}else{
		enum TupleGet = TupleGet!(Needle, T[1..$]);
	}
}

private template SerializableType(T){
	enum SerializableType = !isSomeFunction!T && !is(T == void);
}

enum dontserialize;

void[] serialize(T, UDA...)(ref T data){
	void[] ret;

	static if(is(T == void[])){
		ret ~= data[];

	}else static if(is(T == U[], U)){
		assert(data.length < ushort.max, "Array too long for udp packet");

		auto len = cast(ushort) data.length; // 65k values is a lot for udp;
		ret ~= serialize!ushort(len);
		foreach(ref u; data){
			ret ~= serialize!U(u);
		}

	}else static if(is(T == U[N], U, ulong N)){
		static assert(N < ushort.max, "Array too long for udp packet");

		foreach(ref u; data){
			ret ~= serialize!U(u);
		}

	}else static if(is(T : bool)){
		ret ~= [data?0:1];

	}else static if(is(T : byte)){
		ret ~= [data];

	}else static if(is(T : short)){
		auto d = htons(data);
		ret ~= toVoid(d);

	}else static if(is(T : int)){
		auto d = htonl(data);
		ret ~= toVoid(d);

	}else static if(is(T : long)){
		union DAT {
			ulong d;
			uint[2] d2;
		};

		auto dat = DAT(data);

		pragma(msg, "Serialization of 64-bit values not portable");

		// This should be compiled conditionally based on host endianness
		auto d1 = htonl(dat.d2[0]);
		auto d2 = htonl(dat.d2[1]);

		auto d = toVoid(d2) ~ toVoid(d1);
		ret ~= d;

	}else static if(is(T == struct)){
		alias sUDA = Tuple!(__traits(getAttributes, T));

		foreach(i, mT; typeof(T.tupleof)){
			alias mUDA = Tuple!(__traits(getAttributes, T.tupleof[i]));
			pragma(msg, mT, " ", T.tupleof[i].stringof, " ", mUDA);

			static if(SerializableType!mT && !TupleContains!(dontserialize, mUDA)){
				ret ~= serialize!(mT, mUDA)(data.tupleof[i]);
			}
		}

	}else{
		static assert(0, "serialize not implemented for type " ~ T.stringof);
	}

	return ret;
}

T deserialize(T)(void[] data){
	T ret;

	static if(is(T == struct)){
		//alias sUDA = Tuple!(__traits(getAttributes, T));

		//static if(TupleContains!(header, sUDA)){
		//	alias head = TupleGet!(header, sUDA);

		//	auto type = deserialize!ubyte(data);
		//	data = data[1..$];
		//	if(type != head.type) throw new Exception("Packet type mismatch " ~ to!string(type));
		//}

		foreach(i, mT; typeof(T.tupleof)){
			alias UDA = Tuple!(__traits(getAttributes, T.tupleof[i]));

			static if(SerializableType!mT && !TupleContains!(dontserialize, UDA)){
				ret.tupleof[i] = deserialize!mT(data);

				if(mT.sizeof <= data.length)
					data = data[mT.sizeof..$];
			}
		}

	}else static if(is(T == U[], U)){
		auto len = deserialize!ushort(data);
		data = data[2..$];
		foreach(i; 0..len){
			ret ~= deserialize!U(data);

			if(U.sizeof <= data.length)
				data = data[U.sizeof..$];
		}

	}else static if(is(T == U[N], U, ulong N)){
		static assert(N < ushort.max, "Array too long for udp packet");

		foreach(i; 0..N){
			ret[i] = deserialize!U(data[i * U.sizeof .. (i+1) * U.sizeof]);
		}

	}else static if(is(T : byte)){
		ret = (cast(byte[]) data)[0];

	}else static if(is(T : short)){
		auto uData = cast(T*) data.ptr;
		ret = ntohs(uData[0]);

	}else static if(is(T : int)){
		auto uData = cast(T*) data.ptr;
		ret = ntohl(uData[0]);

	}else static if(is(T : long)){
		union DAT {
			uint[2] d;
			ulong d2;
		};
		auto uData = cast(uint*) data.ptr;
		auto dat = DAT([uData[1], uData[0]]);

		dat.d[0] = ntohl(dat.d[0]);
		dat.d[1] = ntohl(dat.d[1]);

		ret = dat.d2;

	}else{
		static assert(0, "deserialize not implemented for type " ~ T.stringof);
	}

	return ret;
}