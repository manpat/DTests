OUTPUTNAME=`pwd | egrep -o "\w+$$"`
COMPILER=dmd
DIRS=-L-L/home/patrick/Development/libraries/D/derelictorg/lib -L-L/usr/local/lib \
	-I/usr/local/include/d/
LIBS=-L-lDerelictSDL2 -L-lDerelictUtil -L-lDerelictGL3 -L-ldl -L-lgl3n-dmd

$(OUTPUTNAME).build: *.d */*.d
	$(COMPILER) $^ $(DIRS) $(LIBS) -of$(OUTPUTNAME).build

run:
	@vblank_mode=0 primusrun ./$(OUTPUTNAME).build