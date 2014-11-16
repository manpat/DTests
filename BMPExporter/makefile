OUTPUTNAME=bmp
COMPILER=dmd

$(OUTPUTNAME).build: *.d
	$(COMPILER) $^ -of$(OUTPUTNAME).build
	rm *.o

run: $(OUTPUTNAME).build
	@./$(OUTPUTNAME).build