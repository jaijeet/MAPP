#include "eString.h"
#include "untyped.h"

eString& eString::operator=(const untyped& u) {
	if (T_STRING == u._type) {
		*this = u.sval;
	} else {
		if (T_INT == u._type) {
			fprintf(stderr, "ERROR: eString = untyped&: untyped arg is of type INT, value %d\n", u.ival);
		}
		if (T_DOUBLE == u._type) {
			fprintf(stderr, "ERROR: eString = untyped&: untyped arg is of type DOUBLE, value %g\n", u.dval);
		}
		if (T_UNDEF == u._type) {
			fprintf(stderr, "ERROR: eString = untyped&: untyped arg is of type T_UNDEF\n");
		}
		fprintf(stderr, "\teString = untyped&: untyped not of type string, setting to empty string.\n");
		string& oof = *this;
		oof = "";
	}
	return *this;
}

