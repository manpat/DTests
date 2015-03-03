OUTPUTNAME=`pwd | egrep -o "\w+$$"`
COMPILER=dmd

$(OUTPUTNAME).build: *.d */*.d
	$(COMPILER) $^ -of$(OUTPUTNAME).build

run:
	gnome-terminal -e "./$(OUTPUTNAME).build"
	# ./$(OUTPUTNAME).build