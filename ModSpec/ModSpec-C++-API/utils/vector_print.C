#include "vector_print.h"

void print_vector_of_strings(const vector<string>& arg) {
	fprintf(stdout, "{");
	for (int i=0; i< arg.size(); i++) {
		fprintf(stdout, "'%s'", arg[i].c_str());
		if (i < arg.size()-1) {
			fprintf(stdout, ", ");
		}
	}
	fprintf(stdout, "}\n");
	fflush(stdout);
}

void print_vector_of_strings(const vector<string>& names, const vector<string>& arg) {
	fprintf(stdout, "{");
	for (int i=0; i< arg.size(); i++) {
		fprintf(stdout, "%s='%s'", names[i].c_str(), arg[i].c_str());
		if (i < arg.size()-1) {
			fprintf(stdout, ", ");
		}
	}
	fprintf(stdout, "}\n");
	fflush(stdout);
}

void print_vector_of_doubles(const vector<double>& arg) {
	fprintf(stdout, "{");
	for (int i=0; i< arg.size(); i++) {
		fprintf(stdout, "%g", arg[i]);
		if (i < arg.size()-1) {
			fprintf(stdout, ",");
		}
	}
	fprintf(stdout, "}\n");
	fflush(stdout);
}

void print_vector_of_doubles(const vector<string>& names, const vector<double>& arg) {
	fprintf(stdout, "{");
	for (int i=0; i< arg.size(); i++) {
		fprintf(stdout, "%s=%g", names[i].c_str(), arg[i]);
		if (i < arg.size()-1) {
			fprintf(stdout, ", ");
		}
	}
	fprintf(stdout, "}\n");
	fflush(stdout);
}

void print_vector_of_ints(const vector<int>& arg) {
	fprintf(stdout, "{");
	for (int i=0; i< arg.size(); i++) {
		fprintf(stdout, "%d", arg[i]);
		if (i < arg.size()-1) {
			fprintf(stdout, ",");
		}
	}
	fprintf(stdout, "}\n");
	fflush(stdout);
}

void print_vector_of_ints(const vector<string>& names, const vector<int>& arg) {
	fprintf(stdout, "{");
	for (int i=0; i< arg.size(); i++) {
		fprintf(stdout, "%s=%d", names[i].c_str(), arg[i]);
		if (i < arg.size()-1) {
			fprintf(stdout, ", ");
		}
	}
	fprintf(stdout, "}\n");
	fflush(stdout);
}

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
			fprintf(stdout, ", ");
		}
	}
	fprintf(stdout, "}\n");
	fflush(stdout);
}

void print_vector_of_untyped(const vector<string>& names, const vector<untyped>& arg) {
	fprintf(stdout, "{");
	for (int i=0; i< arg.size(); i++) {
		untyped u = arg[i];
		untyped_TYPE _type = u.type();
		eString oof;
		switch(_type){
			case T_DOUBLE:
				fprintf(stdout, "%s=%g", names[i].c_str(), double(arg[i]));
				break;
			case T_INT:
				fprintf(stdout, "%s=%d", names[i].c_str(), (int) arg[i]);
				break;
			case T_STRING:
				oof = u;
				fprintf(stdout, "%s='%s'", names[i].c_str(), oof.c_str());
				break;
			default:
				fprintf(stdout, "error: unknown type for %dth entry of vector<untyped>", i);
		}
		if (i < arg.size()-1) {
			fprintf(stdout, ", ");
		}
	}
	fprintf(stdout, "}\n");
	fflush(stdout);
}
