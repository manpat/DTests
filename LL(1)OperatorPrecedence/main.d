module main;

import std.conv;
import std.stdio;
import std.container;
import stack;

enum NodeType {
	Op2,
	Op1,
	Number,
	LeftParen,
	RightParen,
	End,
}

struct Node {
	this(NodeType _type){
		type = _type;
	}
	this(int _num){
		type = NodeType.Number;
		number = _num;
	}
	this(char _op){
		if(_op == '*' || _op == '/'){
			type = NodeType.Op2;
		}else if(_op == '+' || _op == '-'){
			type = NodeType.Op1;
		}else{
			throw new Exception("Unknown op " ~ _op);
		}
		op = _op;
	}

	static Node* End(){
		return new Node(NodeType.End);
	}
	static Node* Number(int _num){
		return new Node(_num);
	}
	static Node* Operation(char _op){
		return new Node(_op);
	}
	static Node* LeftParen(){
		return new Node(NodeType.LeftParen);
	}
	static Node* RightParen(){
		return new Node(NodeType.RightParen);
	}

	NodeType type;
	union{
		int number;
		char op;
	}

	Node* left = null;
	Node* right = null;

	string toString(){
		string s = "(";

		if(type == NodeType.Number) {
			return to!string(number);
		}else if(type == NodeType.Op2 || type == NodeType.Op1){
			s ~= "" ~ op;
		}else if(type == NodeType.End){
			s ~= "End)";
			return s;
		}else if(type == NodeType.LeftParen){
			s ~= "LeftParen)";
			return s;
		}else if(type == NodeType.RightParen){
			s ~= "RightParen)";
			return s;
		}

		if(left) s ~= " " ~ left.toString;
		else s ~= " ə";

		if(right) s ~= " " ~ right.toString;
		else s ~= " ə";


		s ~= ")";

		return s;
	}
}

alias NodeArray = Array!(Node*);
NodeArray nodeArray;

void main(){
	try{
		nodeArray.insertBack(Node.Number(1));
		nodeArray.insertBack(Node.Operation('+'));
		nodeArray.insertBack(Node.Number(2));
		nodeArray.insertBack(Node.Operation('*'));
		nodeArray.insertBack(Node.LeftParen());
		nodeArray.insertBack(Node.Number(3));
		nodeArray.insertBack(Node.Operation('-'));
		nodeArray.insertBack(Node.Number(4));
		nodeArray.insertBack(Node.RightParen());
		nodeArray.insertBack(Node.Operation('+'));
		nodeArray.insertBack(Node.Number(5));
		nodeArray.insertBack(Node.End());

		PrintStack();

		writeln("\n");
		writeln(*ParseProgram());
	}catch(Exception e){
		writeln("error: " ~ e.msg);
	}
}

void PrintStack(){
	foreach(e; nodeArray){
		writeln(*e);
	}
}

//////////////////////////////////////////////////////

Node* next;

void GetNext(){
	static uint pos = 0; 

	if(pos >= nodeArray.length) {
		next = null;
	}else{
		next = nodeArray[pos++];
	}
}

Node* Match(NodeType type){
	if(!next){
		if(type != NodeType.End){
			throw new Exception("Unexpected EOF");
		}
	}else{
		if(next.type != type){
			throw new Exception("Expected " ~ to!string(type) ~ ", got " ~ to!string(next.type));
		}else{
			auto c = next;
			GetNext();
			ParseFunc.writestuff("matched " ~ c.toString);

			return c;
		}
	}

	return null;
}

void InvalidNext(){
	throw new Exception("Unexpected symbol: " ~ next.toString);
}

struct ParseFunc{
	static uint tablvl = 0;
	string name;

	this(string f, Node* node = null){
		name = f;
		foreach(i; 0..tablvl){
			write("\t");
		}

		if(node){
			writeln(name ~ " " ~ node.toString ~ " {");
		}else{
			writeln(name ~ " {");
		}

		tablvl++;
	}
	~this(){
		tablvl--;
		foreach(i; 0..tablvl){
			write("\t");
		}
		writeln("}");
	}

	static void writenode(Node* thing){
		foreach(i; 0..tablvl){
			write("\t");
		}
		writeln("return " ~ thing.toString ~ ";");
	}

	static void writestuff(string thing){
		foreach(i; 0..tablvl){
			write("\t");
		}
		writeln(thing ~ ";");
	}
}


Node* ParseProgram(){
	GetNext();
	Node* node = null;

	if(next.type == NodeType.Number){
		node = ParseOp1(); 
		Match(NodeType.End);

	}else{
		InvalidNext();
	}

	return node;
}

Node* ParseOp1(){
	auto pf = ParseFunc("Op1");
	auto node = ParseOp2(); 

	if(next.type == NodeType.Op1){
		node = ParseOp1r(node);
	}

	ParseFunc.writenode(node);
	return node;
}

Node* ParseOp1r(Node* left){
	auto pf = ParseFunc("Op1r", left);
	auto node = Match(NodeType.Op1); 
	node.left = left;
	node.right = ParseOp2();

	if(next.type == NodeType.Op1){
		node = ParseOp1r(node);
	}
	
	ParseFunc.writenode(node);
	return node;
}

Node* ParseOp2(){
	auto pf = ParseFunc("Op2");
	auto node = ParseFinal();

	if(next.type == NodeType.Op2){
		node = ParseOp2r(node);
	}

	ParseFunc.writenode(node);
	return node;
}

Node* ParseOp2r(Node* left){
	auto pf = ParseFunc("Op2r", left);
	auto node = Match(NodeType.Op2);
	node.left = left;
	node.right = ParseFinal();

	if(next.type == NodeType.Op2){
		node = ParseOp2r(node);
	}

	ParseFunc.writenode(node);
	return node;
}

Node* ParseFinal(){
	auto pf = ParseFunc("Final");

	if(next.type == NodeType.Number){
		return Match(NodeType.Number);
	}

	Match(NodeType.LeftParen);
	auto node = ParseOp1();
	Match(NodeType.RightParen);

	ParseFunc.writenode(node);
	return node;
}