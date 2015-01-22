OUTPUTNAME=`pwd | egrep -o "\w+$$"`
COMPILER=dmd
MODE=#debug
DIRS=
LIBS=
FLAGS=

ifeq ($(MODE),debug)
FLAGS=-gc
endif

# $(OUTPUTNAME).build: compileasm 
$(OUTPUTNAME).build: *.d #*/*.d 
	dmd $(FLAGS) $^ -of$(OUTPUTNAME).build
	rm $(OUTPUTNAME).o

compileasm: *.s
	nasm -f elf test.s
	gcc -m32 *.o -o $(OUTPUTNAME).build
	rm *.o

ifeq ($(MODE),debug)
run: 
	gnome-terminal -e "gdb ./$(OUTPUTNAME).build"

else
run: 
	bash -c "ulimit -d 1024 -t 1 && ./$(OUTPUTNAME).build testwrite"
	bash -c "ulimit -d 1024 -t 1 && ./testwrite.build"

endif