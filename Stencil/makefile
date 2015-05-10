DENJ=`pwd`/../denj
SRC=$(DENJ)/*/*.d

Stencil.build: *.d
	dmd $^ -ofStencil.build -I$(DENJ) $(SRC)

run: Stencil.build
	@./Stencil.build