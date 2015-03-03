import std.conv;
import std.stdio;
import std.socket;
import std.datetime;

import network.base;
import network.packet;

void Log(T)(T s){
	std.file.append("log", s ~ "\n");
}

void main(){
	try{
		std.file.write("log", "");

		auto net = new NetworkNode();
		bool serverExists = net.DiscoverLocal(1337);

		if(!serverExists){
			net.InitServer(1337);
		}else{
			net.InitClient();
		}

		if(net.IsServer()) {
			Log("Server");

			auto ra = net.sock.localAddress;
			writeln("Bound as server on ", ra.toAddrString, ":", ra.toPortString);

			auto pack = new Packet(new char[1<<10]);

			while(true){
				long br = net.Receive(pack);
				auto buf = cast(char[]) pack.data;

				if(br > 0) {
					import std.string : find;
					if(buf[0..br].find("dickwad").length > 0) break;

					net.Send(pack, pack.from);
					writeln("Bytes received: ", br, " ", buf[0..br], " from ", pack.from.toAddrString(), ":", pack.from.toPortString());
				}
			}
		}else{
			writeln("Bound as client");
			Log("Client");

			net.Send(new Packet("Hello dickweed".dup), net.serverAddr);
			return;
		}


	}catch(Exception e){
		import std.string;

		Log("%s:%s: %s".format(e.file, e.line, e.msg));
		return;
	}

	Log("All good");
}