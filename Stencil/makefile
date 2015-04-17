DENJ=`pwd`/../denj
SRC=$(DENJ)/*/*.d

build: *.d
	dmd $^ -ofStencil.build -I$(DENJ) $(SRC)

run: Stencil.build
	@./Stencil.build