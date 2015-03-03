OUTPUTNAME=`pwd | egrep -o "\w+$$"`
COMPILER=dmd

$(OUTPUTNAME).build: *.d */*.d
	$(COMPILER) $^ -of$(OUTPUTNAME).build
	rm $(OUTPUTNAME).o

run: 
	@./$(OUTPUTNAME).build