#include "untyped.h"

// copy constructor: used for untyped(untyped)
untyped::untyped(const untyped& a) {
	_type = a._type;
	switch(a._type) {
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
		fprintf(stderr, "warning: untyped::untyped(const untyped& a) called a._type=T_UNDEF\n");
	};
}
		
// operator=: untypedL = untypedR
// returns reference to untypedL, allowing, eg, A = (B = C), equiv to A = B = C.
untyped& untyped::operator=(const untyped& a) {
	_type = a._type;
	switch(a._type) {
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
		fprintf(stderr, "warning: untyped::untyped(const untyped& a) called a._type=T_UNDEF\n");
	};
}


// printing
ostream& operator<<(ostream& str, const untyped &a) {
	switch(a._type) {
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
		

void untyped::print(FILE* FH) {
	switch(_type) {
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
