CC = fpc
CFAGS = -Cg

main : main.pp wafc
	$(CC) main
test : test.pp wafc
	$(CC) test
wafc : wafc.pp
	$(CC) $(CFLAGS) wafc
clean:
	rm wafc.ppu wafc.o main.o main
ctest:
	rm wafc.ppu wafc.o test.o test
