#include "eString.h"
#include "untyped.h"
#include <iostream>
#include <vector>

void print_vector_of_untyped(const vector<untyped>& arg) {
	fprintf(stdout, "{");
	for (int i=0; i< arg.size(); i++) {
		untyped u = arg[i];
		untyped_TYPE _type = u.type();
		eString oof;
		switch(_type){
			case T_DOUBLE:
				fprintf(stdout, "%g", double(arg[i]));
				break;
			case T_INT:
				fprintf(stdout, "%d", (int) arg[i]);
				break;
			case T_STRING:
				oof = u;
				fprintf(stdout, "'%s'", oof.c_str());
				break;
			default:
				fprintf(stdout, "error: unknown type for %dth entry of vector<untyped>", i);
		}
		if (i < arg.size()-1) {
			fprintf(stdout, ",");
		}
	}
	fprintf(stdout, "}\n");
	fflush(stdout);
}

main() {
	double d(5.3);
	int i(-2);
	eString s1("a string");

	untyped u;

	u = d;
	u.print(); fprintf(stdout,"\n");
	cout << u << endl;
	u = i;
	u.print(); fprintf(stdout,"\n");
	cout << u << endl;
	u = s1;
	u.print(); fprintf(stdout,"\n");
	cout << u << endl;

	vector<untyped> oof;
	oof.push_back(d);
	oof.push_back(i);
	oof.push_back(s1);

	cout << oof[0] << endl << oof[1] << endl << oof[2] << endl;

	vector<untyped> poof(oof);

	poof = oof;

	cout << poof[0] << endl << poof[1] << endl << poof[2] << endl;

	untyped u2 = poof[2];
	s1 = poof[2];

	fprintf(stdout, "poof: "); print_vector_of_untyped(poof);

	untyped_TYPE _type = poof[0].type();

	int j;
	j = u;

	double d2;
	d2 = u;

	eString s2;
	// eString = untyped
	s2 = (eString) u; // works fine 
	// string = untyped, followed by eString = string
	// s2 = (string) u; // used to work fine, but does not any more?
	// eString = untyped
	s2 = u; // also works with eString; did not with string
	cout << s2 << endl;

	string s3;
	// s3 = u; // still doesn't work
	s3 = (eString) u; // but this does, through the casting operator

	/*
	char goof;

	goof = u;
	*/


	// Trying to reproduce problem from DAAV6
	 untyped test1 = "n";
	 untyped test2("n");
	 untyped test3(string("nn"));

	 cout << "untyped test1 = \"n\": " << test1 << endl;
	 cout << "untyped test2(\"n\"): " << test2 << endl;
	 cout << "untyped test3(string(\"nn\")): " << test3 << endl;
}
