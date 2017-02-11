#ifndef UNTYPED_H
#define UNTYPED_H
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include <iostream>
// #include <type_traits>
#include "eString.h"

using namespace std;

enum untyped_TYPE {T_UNDEF, T_DOUBLE, T_INT, T_STRING};

class untyped {
	protected:
		untyped_TYPE _type; // one of T_UNDEF, T_DOUBLE, T_INT, T_STRING
		union {
			double dval;
			int    ival;
		};
		eString sval; // 2012/12/13: Tom/Rich: look in N_UTIL_PARAM for ideas for doing this better
	public:
		friend class eString;


		untyped() {
			_type = T_UNDEF;
		};

		untyped(const int i) { // should also be used for untyped = int
			_type = T_INT;
			ival = i;
		};

		untyped(const double d) { // should also be used for untyped = double
			_type = T_DOUBLE;
			dval = d;
		};

		untyped(const eString& s) {// should also be used for untyped = eString
			_type = T_STRING;
			sval = s;
		}

		untyped(const string& s) {// should also be used for untyped = string
			_type = T_STRING;
			sval = s;
		}

		untyped(const char* s) {// 
			// fprintf(stderr, "INFO: in untyped::untyped(const char* s)\n");
			_type = T_STRING;
			sval = s;
		}

		untyped(char* s) {// 
			// fprintf(stderr, "INFO: in untyped::untyped(char* s)\n");
			_type = T_STRING;
			sval = s;
		}
		// but there is a problem with the above two: untyped(char *)
		// try:
		// untyped oof("n") or untyped oof = "n"
		// during runtime, it comes up with the error
		// 	EROR: eString = untyped&: untyped arg is of type INT, value 110

		// copy constructor: used for untyped(untyped)
		untyped(const untyped& a);
		
		// destructor
		~untyped(){};
		
		// operator=: untypedL = untypedR
		// returns reference to untypedL, allowing, eg, A = (B = C), equiv to A = B = C.
		untyped& operator=(const untyped& a);

		// operator=: untyped = int
		untyped& operator=(const int i) {
			_type = T_INT;
			ival = i;
		};

		// operator=: untyped = double
		untyped& operator=(const double d) {
			_type = T_DOUBLE;
			dval = d;
		};
		
		// operator=: untyped = string
		untyped& operator=(const eString& s) {
			_type = T_STRING;
			sval = s;
		};

		untyped& operator=(const char* s) {
			_type = T_STRING;
			sval = s;
		}

				
		
		// trying to overload operator= for int=untyped, double=untyped, etc

		/* doesn't seem to work: "must be a nonstatic member function"
		friend string& operator=(string& lhs, untyped& rhs) {
			if (T_STRING == rhs._type) {
				lhs = rhs.sval;
			} else {
				fprintf(stderr, "error in string=untyped: RHS type not string, returning empty string.\n");
				lhs = "";
			}
			return lhs;
		}

		friend int& operator=(int& lhs, untyped& rhs) {
			if (T_INT == rhs._type) {
				lhs = rhs.ival;
			} else {
				fprintf(stderr, "error in int=untyped: RHS type not int, returning zero.\n");
				lhs = 0;
			}
			return lhs;
		}
		*/
		
		// overloading cast operators to do int = untyped
		
		/*
		template <typename T> operator T() {
			if (is_same<T, int>::value) {
				if (T_INT == _type) {
					return ival;
				} else {
					fprintf(stderr, "error in int=untyped: RHS type not int, returning zero.\n");
					return 0;
				}
			} else if (is_same<T, double>::value) {
				if (T_DOUBLE == _type) {
					return dval;
				} else {
					fprintf(stderr, "error in double=untyped: RHS type not double, returning zero.\n");
					return 0.0;
				}
			}
		}
		*/

/*
http://stackoverflow.com/questions/4603717/stopping-function-implicit-conversion:

Try using templates to get the desired effect:

template <class T>
void foo(const T& t);

template <>
void foo<int>(const int& t)
{

}

int main(){
  foo(9); // will compile
  foo(9.0); // will not compile
  return 0;
}
*/

		// template <typename T> operator T();
		operator int() const {
			if (T_INT == _type) {
				return ival;
			} else if (T_DOUBLE == _type) {
				int oof = dval;
				if (dval != oof) {
					fprintf(stderr, "warning in int=untyped: RHS type is double, int(double) returned.\n");
				}
				return oof;
			} else {
				fprintf(stderr, "error in int=untyped: RHS type not int or double, returning zero.\n");
				return 0;
			}
		}

		operator double() const {
			if (T_DOUBLE == _type) {
				return dval;
			} else if (T_INT == _type) {
				return ival;
			} else {
				fprintf(stderr, "error in double=untyped: RHS type not double, returning zero.\n");
				return 0.0;
			}
		}

		operator string() {
			if (T_STRING == _type) {
				return sval;
			} else {
				fprintf(stderr, "error in string=untyped: RHS type not string, returning empty string.\n");
				return string("");
			}
		}

		operator const char*() {
			if (T_STRING == _type) {
				return sval.c_str();
			} else {
				fprintf(stderr, "error in const char*=untyped: RHS type not string, returning "".\n");
				return "";
			}
		}

		operator eString() const {
			if (T_STRING == _type) {
				return sval;
			} else {
				fprintf(stderr, "error in eString=untyped: RHS type not eString, returning "".\n");
				return eString();
			}
		}

		/*
		operator string() {
			if (T_STRING == _type) {
				return sval;
			} else {
				fprintf(stderr, "error in eString=untyped: RHS type not eString, returning "".\n");
				return string();
			}
		}
		*/

		/*
		template <class T> operator basic_string<T>() const {
			if (T_STRING == _type) {
				return sval;
			} else {
				fprintf(stderr, "error in string=untyped: RHS type not string, returning "".\n");
				return string("");
			}
		}
		*/

		// printing
		friend ostream& operator<<(ostream& str, const untyped &a);

		void print(FILE* FH=stdout);

		// access to type
		untyped_TYPE type() const {
			return _type;
		}
};
#endif
