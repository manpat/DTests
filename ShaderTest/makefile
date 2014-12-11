OUTPUTNAME=dshaderfun
COMPILER=dmd
DIRS=-L-L/home/patrick/Development/libraries/D/derelictorg/lib
LIBS=-L-lDerelictSDL2 -L-lDerelictUtil -L-lDerelictGL3 -L-ldl

$(OUTPUTNAME).build: *.d #*/*.d
	$(COMPILER) $^ $(DIRS) $(LIBS) -of$(OUTPUTNAME).build

run: $(OUTPUTNAME).build
	#@vblank_mode=0 
	primusrun ./$(OUTPUTNAME).build