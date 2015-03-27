module network.base;

import std.stdio;
import std.socket;
import std.datetime : dur;
import network.packet;
import network.serialize;

class NetworkNode {
	Socket sock = null;
	private bool isServer = false;

	Address DiscoverLocal(ushort port){
		auto discoverSock = new UdpSocket(AddressFamily.INET);
		scope(exit) discoverSock.close();
		discoverSock.bind(new InternetAddress("localhost", 0));
		discoverSock.setOption(SocketOptionLevel.SOCKET, SocketOption.BROADCAST, 1);
		discoverSock.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!"msecs"(1000));

		Address serverAddr = null;

		discoverSock.sendTo(new Packet(PingPacket()).data, new InternetAddress("255.255.255.255", port));
		char[128] b;
		if(discoverSock.receiveFrom(b, serverAddr) > 0) {
			return serverAddr;
		}

		return null;
	}

	void InitServer(ushort port){
		sock = new UdpSocket(AddressFamily.INET);
		sock.bind(new InternetAddress(InternetAddress.ADDR_ANY, port));	
		sock.setOption(SocketOptionLevel.SOCKET, SocketOption.BROADCAST, 1);
		sock.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!"msecs"(30));
		//sock.blocking = false;
		isServer = true;
	}

	void InitClient(){
		sock = new UdpSocket(AddressFamily.INET);
		sock.bind(new InternetAddress(InternetAddress.ADDR_ANY, InternetAddress.PORT_ANY));
		sock.blocking = false;
	}

	bool IsServer(){
		return isServer;
	}

	size_t Send(Packet p, Address a){
		return sock.sendTo(p.data, a);
	}

	size_t Receive(ref Packet p){
		//p.data = new void[1<<10];
		return sock.receiveFrom(p.data, p.from);
	}
}