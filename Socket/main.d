import std.conv;
import std.stdio;
import std.format;
import std.socket;
import std.random;

import std.traits;

import network.base;
import network.packet;
import network.serialize;

void Log(T)(T s){
	std.file.append("log", to!string(s) ~ "\n");
	writeln(s);
}

@header(2) struct TestPacket {
	short id;
	char[8] str;
	@dontserialize ulong num;
}

void main(){
	try{
		std.file.write("log", "");
		alias T = TestPacket;

		auto t = T(0x0102, "1234   ", 0x1234_5678_9ABC_DEF0);
		Log("original     [%(%2X, %)]".format(toVoid(t)));

		auto ser = serialize!T(t);
		Log("serialized   [%(%2X, %)]".format(ser));

		auto deser = deserialize!T(ser);
		Log("deserialized [%(%2X, %)]".format(toVoid(deser)));

		Log("\n");
		//Log(deser.id);
		//Log(deser.str);

		auto net = new NetworkNode();
		Address server = net.DiscoverLocal(1337);

		if(!server){
			writeln("Type ip to attempt to connect to server\n or press enter to start a server");
			auto inp = readln();
			if(inp.length > 1){
				net.InitClient();
				//server = parseAddress("58.174.163.10", "1337");
				server = parseAddress(inp[0..$-1], 1337);

			}else{
				net.InitServer(1337);
			}

		}else{
			net.InitClient();
		}

		enum netFail = cast(ulong) -1;
		if(net.IsServer()) {
			Log("Server");

			auto ra = net.sock.localAddress;
			writeln("Bound as server on ", ra.toAddrString, ":", ra.toPortString);

			auto pack = new Packet(new char[1<<10]);

			while(true){
				auto br = net.Receive(pack);
				auto buf = cast(char[]) pack.data;

				if(br > 0 && br != netFail) {
					if(buf[0] == GetHeader!PingPacket.type){
						buf[2] = 'o';
						net.Send(pack, pack.from);

					}else if(buf[0] == GetHeader!TestPacket.type){
						net.Send(pack, pack.from);
						writeln("Bytes received: ", br, " ", pack.data[0..br], " from ", pack.from.toAddrString(), ":", pack.from.toPortString());

						auto testPacket = pack.as!TestPacket;
						writeln(testPacket.id, " ", testPacket.str);
					}else{
						writeln("Unknown packet header: ", buf[0]);
					}
				}
			}
		}else{
			Log("Bound as client");

			TestPacket testPacket;
			testPacket.id = cast(short) uniform(1, 20);
			testPacket.num = uniform(10000, 99999);
			testPacket.str[] = ' ';

			auto str = to!string(testPacket.num);
			testPacket.str[0..str.length] = str;

			auto pack = new Packet(testPacket);
			auto bs = net.Send(pack, server);

			if(bs == netFail){
				writeln("Packet send failed");
				writeln(lastSocketError());
			}else{
				writeln("Bytes sent: ", bs);

				auto br = net.Receive(pack);
				if(br > 0 && br != netFail){
					auto ping = pack.as!PingPacket;
					writeln(ping.str);
				}
			}
		}

	}catch(Exception e){
		import std.string;

		Log("%s:%s: %s".format(e.file, e.line, e.msg));
	}

	writeln("\n\nPress enter to continue...");
	readln();
}