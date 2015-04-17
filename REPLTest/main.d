module main;

import std.stdio;
import std.conv;
import std.string;

import llvm.Ext;
import llvm.c.Core;
import llvm.c.ExecutionEngine;
import llvm.c.Target;
import llvm.c.BitWriter;
import llvm.c.transforms.Scalar;

void main(){
	LLVMModuleRef mod = LLVMModuleCreateWithName("The main module");
	LLVMBuilderRef builder = LLVMCreateBuilder();

	LLVMInitializeNativeTarget();
	LLVMLinkInJIT();

	LLVMExecutionEngineRef engine;

	char* msg = null;
	if(LLVMCreateExecutionEngineForModule(&engine, mod, &msg) == 1){
		writeln(fromStringz(msg));
		LLVMDisposeMessage(msg);
		return;
	}

	auto type = LLVMDoubleType();
	auto i32Type = LLVMInt32Type();
	auto i8pType = LLVMPointerType(LLVMInt8Type(), 0);

	auto printfType = LLVMFunctionType(i32Type, [i8pType].ptr, 1, true);
	auto printfFunc = LLVMAddFunction(mod, "printf".toStringz, printfType);
	LLVMSetLinkage(printfFunc, LLVMLinkage.External);

	auto ftype = LLVMFunctionType(i32Type, null/*[LLVMVoidType()].ptr*/, 0, 0);
	auto func = LLVMAddFunction(mod, "main".toStringz, ftype);

	auto bb = LLVMAppendBasicBlock(func, "entry");
	LLVMPositionBuilderAtEnd(builder, bb);

	LLVMBuildCall(builder, printfFunc, 
		[LLVMBuildGlobalStringPtr(builder, "Lol\n".toStringz, "".toStringz)].ptr, 
		1, "printfcall".toStringz);

	LLVMBuildRet(builder, LLVMConstIntOfString(i32Type, "0", 10));

	LLVMDumpModule(mod);
	LLVMWriteBitcodeToFile(mod, "output.bc\0".dup.ptr);

	//auto res = LLVMRunFunction(engine, func, 1, [LLVMCreateGenericValueOfFloat(floatType, 5.0)].ptr);
	//writeln(LLVMGenericValueToFloat(floatType, res));
	writeln("Compilation done\n");
}