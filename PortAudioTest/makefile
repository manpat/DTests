OUTPUTNAME=portaudiotest
COMPILER=dmd
DIRS=-L-L/home/patrick/Development/libraries/D/derelict3/lib/dmd
LIBS=-L-lportaudio

$(OUTPUTNAME).build: *.d #*/*.d
	$(COMPILER) $^ $(DIRS) $(LIBS) -of$(OUTPUTNAME).build

run: $(OUTPUTNAME).build
	@./$(OUTPUTNAME).build