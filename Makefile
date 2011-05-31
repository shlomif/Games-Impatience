all:

test:
	prove -l t/*.t

runtest:
	runprove -l t/*.t
