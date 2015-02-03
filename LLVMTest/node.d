module node;

import std.string;
import main : Context;
import llvm.c.Core;

alias Type = LLVMTypeRef;
alias Value = LLVMValueRef;

interface Node {
	Value GenerateCode(Context);
}

Value[string] symbolTable;
Type[string] typeTable;

class FunctionNode : Node {
	this(string _name, string _retType, string[] _argTypes, bool _vararg = false){
		name = _name;
		retType = _retType;
		argTypes = _argTypes;
		vararg = _vararg;
	}

	Value GenerateCode(Context c){
		auto retT = typeTable[retType];
		auto argT = new Type[argTypes.length];

		foreach(i; 0..argTypes.length){
			argT[i] = typeTable[argTypes[i]];
		}

		auto ftype = LLVMFunctionType(retT, argT.ptr, cast(uint) argT.length, vararg?1:0);
		auto func = LLVMAddFunction(c.mod, name.toStringz, ftype);

		symbolTable[name] = func;

		if(bodyList && bodyList.length > 0){
			auto bb = LLVMAppendBasicBlock(func, "entry");
			LLVMPositionBuilderAtEnd(c.builder, bb);

			foreach(n; bodyList){
				n.GenerateCode(c);
			}
		}

		return func;
	}

	void SetBody(Node[] list){
		bodyList = list;
	}

	private {
		string name;
		string retType;
		string[] argTypes;
		Node[] bodyList;
		bool vararg;
	}
}

class ExternNode : Node {
	this(string _name, string _retType, string[] _argTypes, bool _vararg = false){
		name = _name;
		retType = _retType;
		argTypes = _argTypes;
		vararg = _vararg;
	}

	Value GenerateCode(Context c){
		auto retT = typeTable[retType];
		auto argT = new Type[argTypes.length];

		foreach(i; 0..argTypes.length){
			argT[i] = typeTable[argTypes[i]];
		}

		auto ftype = LLVMFunctionType(retT, argT.ptr, cast(uint) argT.length, vararg?1:0);
		auto func = LLVMAddFunction(c.mod, name.toStringz, ftype);
		LLVMSetLinkage(func, LLVMLinkage.External);

		symbolTable[name] = func;

		return func;
	}

	private {
		string name;
		string retType;
		string[] argTypes;
		bool vararg;
	}
}

class CallNode : Node {
	this(string _fn, Node[] _args){
		fn = _fn;
		args = _args;
	}

	Value GenerateCode(Context c){
		auto as = new Value[args.length];
		foreach(i; 0..as.length){
			as[i] = args[i].GenerateCode(c);
		}

		auto f = symbolTable[fn];
		return LLVMBuildCall(c.builder, f, as.ptr, cast(uint) as.length, (fn~"call").toStringz);
	}

	private {
		string fn;
		Node[] args;
	}
}

class ReturnNode : Node {
	this(Node n = null){
		node = n;
	}

	Value GenerateCode(Context c){
		if(node){
			auto ret = node.GenerateCode(c);
			return LLVMBuildRet(c.builder, ret);
		}

		return LLVMBuildRetVoid(c.builder);
	}

	private {
		Node node;
	}
}

class ConstNode(T) : Node {
	this(string tname, T _value){
		value = _value;
		typeName = tname;
	}

	Value GenerateCode(Context c){
		auto type = typeTable[typeName];

		static if(is(T == int)){
			return LLVMConstInt(type, value, 0);
		}else static if(is(T == float)){
			return LLVMConstReal(type, value);
		}else static if(is(T == string)){
			//return LLVMConstString(cast(const(char)*) value.dup.ptr, cast(uint) value.length, false);
			return LLVMBuildGlobalStringPtr(c.builder, value.toStringz, "".toStringz);
		}
	}

	private {
		string typeName;
		T value;
	}
}

class CastNode : Node {
	this(Node _toCast, string _toWhat){
		toCast = _toCast;
		toWhat = _toWhat;
	}

	Value GenerateCode(Context c){
		return LLVMBuildFPCast(c.builder, toCast.GenerateCode(c), typeTable[toWhat], "cast".toStringz);
	}

	private {
		Node toCast;
		string toWhat;
	}
}

class FloatAddNode : Node{
	this(Node _lhs, Node _rhs){
		lhs = _lhs;
		rhs = _rhs;
	}

	Value GenerateCode(Context c){
		auto l = lhs.GenerateCode(c);
		auto r = rhs.GenerateCode(c);

		return LLVMBuildFAdd(c.builder, l, r, "faddtmp".toStringz);
	}

	private {
		Node lhs, rhs;
	}
}

class GetFunctionParamNode : Node {
	this(uint _paramNo){
		paramNo = _paramNo;
	}

	Value GenerateCode(Context c){
	    Value func = LLVMGetBasicBlockParent(LLVMGetInsertBlock(c.builder));

	    return LLVMGetParam(func, paramNo);
	}

	private uint paramNo;
}

class ComputeOnceNode : Node {
	this(Node _n){
		n = _n;
	}

	Value GenerateCode(Context c){
		if(!v){
			v = n.GenerateCode(c);
		}
		return v;
	}

	private {
		Node n;
		Value v;
	}
}