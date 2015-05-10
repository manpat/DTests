DENJ=`pwd`/../denj
SRC=$(DENJ)/*/*.d

build: *.d
	dmd $^ -ofbuild -I$(DENJ) $(SRC)

run: build
	@./build