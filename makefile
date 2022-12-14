build: WorldCupStats.l
	flex++  --outfile program.cpp WorldCupStats.l
	g++ program.cpp -lfl -o WorldCupStats

clean:
	rm WorldCupStats
	rm program.cpp