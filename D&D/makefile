OUTPUTNAME=`pwd | egrep -o "\w+$$"`
COMPILER=dmd
DIRS=
LIBS=
FLAGS=

$(OUTPUTNAME).build: *.d #*/*.d
	$(COMPILER) $(FLAGS) $^ -of$(OUTPUTNAME).build
	rm $(OUTPUTNAME).o

run:
	bash -c "ulimit -d 1024 -t 1 && gnome-terminal -e ./$(OUTPUTNAME).build"
