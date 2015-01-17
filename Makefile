FUSEFLAGS = $(shell pkg-config fuse --cflags)
FUSELIBS = $(shell pkg-config fuse --libs)
CXXFLAGS = $(FUSEFLAGS) -O2 -Wall

blokusfs: blokusfs.o board.o opening.o piece.o
	$(CXX) $(CXXFLAGS) -o $@ $^ $(FUSELIBS)

piece.cpp: piece.rb
	ruby piece.rb >$@

blokusfs.o: blokusfs.cpp board.h opening.h
board.o: board.cpp piece.h opening.h board.h
opening.o: opening.cpp opening.h
piece.o: piece.cpp piece.h

clean:
	rm -f *.o blokusfs
