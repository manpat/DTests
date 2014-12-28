OUTPUTNAME=dquaternions
COMPILER=dmd

$(OUTPUTNAME).build: *.d #*/*.d
	$(COMPILER) $^ $(DIRS) $(LIBS) -of$(OUTPUTNAME).build

run: $(OUTPUTNAME).build
	./$(OUTPUTNAME).build