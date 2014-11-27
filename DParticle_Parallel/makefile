OUTPUTNAME=dparticle
COMPILER=wine dmd
DIRS=#-L-L/home/patrick/Development/libraries/D/derelict3/lib/dmd
LIBS=-ldl#-L-lDerelictSDL2 -L-lDerelictUtil -L-lDerelictGL3 -L-ldl

$(OUTPUTNAME).build: *.d #*/*.d
	$(COMPILER) $^ $(DIRS) $(LIBS) -of$(OUTPUTNAME).build.exe

run: $(OUTPUTNAME).build
	@vblank_mode=0 optirun ./$(OUTPUTNAME).build.exe