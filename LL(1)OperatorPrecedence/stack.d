module stack;

import std.container;

struct Stack(T){
	Array!(T) elements;

	void push(T e){
		elements.insertBack(e);
	}

	void pop(){
		if(!elements.empty)
			elements.removeBack();
	}

	void swap(){
		auto e = elements[$-2];
		elements[$-2] = elements[$-1];
		elements[$-1] = e;
	}

	void popUnder(){
		swap();
		pop();
	}

	@property T top(){
		return elements.back;
	}
	@property T first(){
		return elements.front;
	}
	@property T under(){
		if(elements.length < 2) return null;

		return elements[$-2];
	}

	@property ulong size(){
		return elements.length;
	}

	@property bool empty(){
		return elements.empty;
	}

	ref T opIndex(long i){
		return elements[$-i-1];
	}
}