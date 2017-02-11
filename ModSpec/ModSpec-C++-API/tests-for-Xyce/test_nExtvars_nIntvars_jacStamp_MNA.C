#include "Xyce_ModSpec_Interface.h"

main(int argc, char** argv) {
	// get name of .so file from command line argument
	if (argc < 2) {
		fprintf(stderr, "Usage: %s <Some_ModSpec_Element.so>\nExample: %s ../Res_ModSpec_Element.so\n", argv[0], argv[0]);
		exit(1);
	}
	string soName = argv[1];

	Xyce_ModSpec_Interface XM_interface(soName);

	/*
	// test of spMatrix_doubleptr
	spMatrix_doubleptr oof2(5,5);
	double a, b, c;
	oof2(0,0) = &a;
	oof2(4,4) = &b;
	oof2(2,3) = &c;

	*(oof2(0,0)) = 1;
	*(oof2(4,4)) = 2;
	*(oof2(2,3)) = 3;

	fprintf(stdout, "a=%g, b=%g, c=%g\n", a, b, c);


	// testing Boolean data type in C++
	bool goof1 = true;
	bool goof2 = false;
	bool goof3 = goof1 + goof2;
	bool goof4 = goof1*goof2;
	fprintf(stdout, "goof1=%d, goof2=%d, goof3=%d, goof4=%d\n", goof1, goof2, goof3, goof4);
	*/
}
