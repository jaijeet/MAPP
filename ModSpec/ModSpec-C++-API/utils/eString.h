#ifndef ESTRING_H
#define ESTRING_H
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include <iostream>

using namespace std;

class untyped;

// eString: extended std::string class
// 	mainly to allow overloading of string::operator= such
// 	that string = untyped is possible.
//

class eString: public string {
	public:
		eString(const eString& oof): string(oof) {};
		eString(const string& oof): string(oof) {};
		eString(const untyped& oof) {*this=oof;}
		eString(const char* oof): string(oof) {};
		eString(): string() {};

		eString& operator=(const untyped& u);

		eString& operator=(const eString& u) {
			string::operator=(u);
		}
		eString& operator=(const string& u) {
			string::operator=(u);
		}
		eString& operator=(const char* s) {
			string::operator=(s);
		}

		// we don't actually need to define
		// eString::operator=(untyped&)! For some reason
		// casting untyped to eString now works, whereas
		// it did not for untyped to string
		/*
		eString& operator=(const untyped& u) {
			*this = u;
			return *this;
		}

		including anything that needs untyped won't work if you don't
		split both untyped.h and eString.h into separate .h and .C
		files.
		*/

};
#endif
