#ifndef ESTRING_H
#define ESTRING_H
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include <iostream>

using namespace std;

// eString: extended std::string class
// 	mainly to allow overloading of string::operator=
//

class eString: public string {
	public:
		eString(const eString& oof): string(oof) {};
		eString(const string& oof): string(oof) {};
		eString(const char* oof): string(oof) {};
		eString(): string() {};

		// we don't actually need to define
		// eString::operator=(untyped&)! For some reason
		// casting untyped to eString now works, whereas
		// it did not for untyped to string
		/*
		eString& operator=(const untyped& u) {
			*this = u;
			return *this;
		}

		including anything that needs untyped won't work if 
		you don't split both untyped.h and eString.h into separate .h and .C
		files.
		*/

};
#endif
