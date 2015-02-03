OUTPUTNAME=`pwd | egrep -o "\w+$$"`

DIRS=-I/home/patrick/Development/libraries/D/bindings/llvm-3.0/ \
	-L-L/home/patrick/Development/libraries/D/bindings/llvm-3.0/ -L-L/usr/local/lib \
	-I/usr/local/include/d/

LIBS=`llvm-config --libs | sed 's/-l/-L-l/g'`
OBJS=-L/home/patrick/Development/libraries/D/bindings/llvm-3.0/llvmExt.o \
	-L/home/patrick/Development/libraries/D/bindings/llvm-3.0/llvmTarget.o 

OTHER=/home/patrick/Development/libraries/D/bindings/llvm-3.0/llvm/Ext.d

$(OUTPUTNAME).build: *.d #*/*.d
	dmd $^ $(OTHER) -of$(OUTPUTNAME).build $(DIRS) $(OBJS) $(LIBS) -L-lstdc++ -L-ldl 

run:
	./$(OUTPUTNAME).build
	lli output.bc
	# llc output.bc
	rm output.bc
	# gcc output.s -o output
	# ./output