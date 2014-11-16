OUTPUTNAME=test
COMPILER=dmd
DIRS=-L-L/home/patrick/Development/libraries/D/derelict3/lib/dmd
LIBS=-L-lDerelictSDL2 -L-lDerelictUtil -L-ldl

$(OUTPUTNAME).build: *.d */*.d
	$(COMPILER) $^ $(DIRS) $(LIBS) -D -of$(OUTPUTNAME).build

run: $(OUTPUTNAME).build
	@./$(OUTPUTNAME).build