module ast;

import std.stdio;

enum Type {
	Identifier,
	Literal,
	Assignment,
	Operation,
}

class Node {
	Type type;

	Node first;
	Node second;
	Node third;
}

class Identifier : Node {
	char[] name;

	this(char[] _name){
		type = Type.Identifier;
		name = _name;
	}
}

class Literal : Node {
	char[] text;

	this(char[] _text){
		type = Type.Literal;
		text = _text;
	}
}

class Assignment : Node {
	this(Node id, Node expr){
		type = Type.Assignment;
		first = id;
		second = expr;
	}
}

class Operation : Node {
	char[] op;

	this(Node left, Node right, char[] _op){
		type = Type.Operation;
		first = left;
		second = right;
		op = _op;
	}
}