OUTPUTNAME=`pwd | egrep -o "\w+$$"`
COMPILER=dmd
DIRS=-L-L/home/patrick/Development/libraries/D/derelictorg/lib -L-L/usr/local/lib \
	-I/usr/local/include/d/
LIBS=-L-lDerelictSDL2 -L-lDerelictUtil -L-ldl -L-lportaudio

$(OUTPUTNAME).build: *.d */*.d
	$(COMPILER) $^ $(DIRS) $(LIBS) -of$(OUTPUTNAME).build
	rm $(OUTPUTNAME).o

run: 
	@./$(OUTPUTNAME).build