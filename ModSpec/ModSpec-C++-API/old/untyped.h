#ifndef UNTYPED_H
#define UNTYPED_H
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include "eString.h"

using namespace std;

enum {T_UNDEF, T_DOUBLE, T_INT, T_STRING};

class untyped {
	protected:
		unsigned int type; // one of T_UNDEF, T_DOUBLE, T_INT, T_STRING
		union {
			double dval;
			int    ival;
		};
		eString sval;
	public:
		untyped() {
			type = T_UNDEF;
		};

		untyped(const int i) { // should also be used for untyped = int
			type = T_INT;
			ival = i;
		};

		untyped(const double d) { // should also be used for untyped = double
			type = T_DOUBLE;
			dval = d;
		};

		untyped(const eString s) {// should also be used for untyped = string
			type = T_STRING;
			sval = s;
		};


		// copy constructor: used for untyped(untyped)
		untyped(const untyped& a) {
			type = a.type;
			switch(a.type) {
			 case T_DOUBLE:
			 	dval = a.dval;
				break;
			 case T_INT:
			 	ival = a.ival;
				break;
			 case T_STRING:
			 	sval = a.sval;
				break;
			 default: 
			 	;
			};
		};
		
		// destructor
		~untyped(){};
		
		// operator=: untypedL = untypedR
		// returns reference to untypedL, allowing, eg, A = (B = C), equiv to A = B = C.
		untyped& operator=(const untyped& a) {
			type = a.type;
			switch(a.type) {
			 case T_DOUBLE:
			 	dval = a.dval;
				break;
			 case T_INT:
			 	ival = a.ival;
				break;
			 case T_STRING:
			 	sval = a.sval;
				break;
			 default: 
			 	;
			};
		};

		// operator=: untypedL = int
		untyped& operator=(const int i) {
			type = T_INT;
			ival = i;
		};

		// operator=: untypedL = double
		untyped& operator=(const double d) {
			type = T_DOUBLE;
			dval = d;
		};
		
		// operator=: untypedL = string
		untyped& operator=(const eString& s) {
			type = T_STRING;
			sval = s;
		};
		
		
		// trying to overload operator= for int=untyped, double=untyped, etc

		/* doesn't seem to work: "must be a nonstatic member function"
		friend string& operator=(string& lhs, untyped& rhs) {
			if (T_STRING == rhs.type) {
				lhs = rhs.sval;
			} else {
				fprintf(stderr, "error in string=untyped: RHS type not string, returning empty string.\n");
				lhs = "";
			}
			return lhs;
		}

		friend int& operator=(int& lhs, untyped& rhs) {
			if (T_INT == rhs.type) {
				lhs = rhs.ival;
			} else {
				fprintf(stderr, "error in int=untyped: RHS type not int, returning zero.\n");
				lhs = 0;
			}
			return lhs;
		}
		*/
		
		// overloading cast operators to do int = untyped
		
		operator int() {
			if (T_INT == type) {
				return ival;
			} else {
				fprintf(stderr, "error in int=untyped: RHS type not int, returning zero.\n");
				return 0;
			}
		}

		operator double() {
			if (T_DOUBLE == type) {
				return dval;
			} else {
				fprintf(stderr, "error in double=untyped: RHS type not double, returning zero.\n");
				return 0.0;
			}
		}

		operator eString() {
			if (T_STRING == type) {
				return sval;
			} else {
				fprintf(stderr, "error in eString=untyped: RHS type not eString, returning "".\n");
				return eString();
			}
		}

		/*
		operator string() {
			if (T_STRING == type) {
				return sval;
			} else {
				fprintf(stderr, "error in eString=untyped: RHS type not eString, returning "".\n");
				return string();
			}
		}
		*/

		/*
		template <class T> operator basic_string<T>() const {
			if (T_STRING == type) {
				return sval;
			} else {
				fprintf(stderr, "error in string=untyped: RHS type not string, returning "".\n");
				return string("");
			}
		}
		*/

		// printing
		friend ostream& operator<<(ostream& str, const untyped &a) {
			switch(a.type) {
			 case T_DOUBLE:
				str << a.dval;
				break;
			 case T_INT:
				str << a.ival;
				break;
			 case T_STRING:
				str << "'" << a.sval << "'";
				break;
			 default: 
			 	str << "{}";
			};
			return str;
		}
		

		void print(FILE* FH=stdout) {
			switch(type) {
			 case T_DOUBLE:
			 	fprintf(FH, "%g", dval);
				break;
			 case T_INT:
			 	fprintf(FH, "%d", ival);
				break;
			 case T_STRING:
			 	fprintf(FH, "'%s'", sval.c_str());
				break;
			 default: 
			 	fprintf(FH, "{}");
			};
		}
};
#endif
