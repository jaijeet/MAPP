#include "Res_ModSpec_Element.h"
#include <iostream>
#include <vector>

void print_vector_of_strings(const vector<string>& arg) {
	fprintf(stdout, "{");
	for (int i=0; i< arg.size(); i++) {
		fprintf(stdout, "%s", arg[i].c_str());
		if (i < arg.size()-1) {
			fprintf(stdout, ",");
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
	Res_ModSpec_Element_with_sacado_Jacobians a;
	//Res_ModSpec_Element a;

	vector<string> oof = a.parmnames();
	fprintf(stdout, "parmnames: "); print_vector_of_strings(oof);

	/*
	oof = a.parmtypes();
	fprintf(stdout, "parmtypes: "); print_vector_of_strings(oof);
	*/

	vector<untyped> goof = a.parmdefaults();
	fprintf(stdout, "parmdefaults: "); print_vector_of_untyped(goof);

	vector<untyped> parms; parms.push_back(2000);
	a.setparms(parms);

	goof = a.getparms();
	fprintf(stdout, "getparms: "); print_vector_of_untyped(goof);

	oof = a.NIL_NodeNames();
	fprintf(stdout, "NIL_NodeNames: "); print_vector_of_strings(oof);


	string poof = a.NIL_RefNodeName();
	fprintf(stdout, "NIL_RefNodeName: %s\n", poof.c_str());

	oof = a.IOnames();
	fprintf(stdout, "IOnames: "); print_vector_of_strings(oof);

	oof = a.NIL_IOtypes();
	fprintf(stdout, "NIL_IOtypes: "); print_vector_of_strings(oof);

	oof = a.NIL_IONodeNames();
	fprintf(stdout, "NIL_IONodeNames: "); print_vector_of_strings(oof);

	oof = a.ExplicitOutputNames();
	fprintf(stdout, "ExplicitOutputNames: "); print_vector_of_strings(oof);

	oof = a.OtherIOnames();
	fprintf(stdout, "OtherIOnames: "); print_vector_of_strings(oof);

	oof = a.InternalUnkNames();
	fprintf(stdout, "InternalUnkNames: "); print_vector_of_strings(oof);

	oof = a.ImplicitEquationNames();
	fprintf(stdout, "ImplicitEquationNames: "); print_vector_of_strings(oof);

	oof = a.Unames();
	fprintf(stdout, "Unames: "); print_vector_of_strings(oof);

	double vpn = 2.0;
	vector<double> vecX, vecY, vecU, vecZf, vecZq, vecWf, vecWq;

	vecX.push_back(vpn);

	vecZf = a.fe(vecX, vecY, vecU);
	vecZq = a.qe(vecX, vecY);
	vecWf = a.fi(vecX, vecY, vecU);
	vecWq = a.qi(vecX, vecY);

	fprintf(stdout, "vecX: "); print_vector_of_doubles(vecX);
	fprintf(stdout, "vecY: "); print_vector_of_doubles(vecY);
	fprintf(stdout, "vecY: "); print_vector_of_doubles(vecU);
	fprintf(stdout, "vecZf = fe(...): "); print_vector_of_doubles(vecZf);
	fprintf(stdout, "vecZq = qe(...): "); print_vector_of_doubles(vecZq);
	fprintf(stdout, "vecWf = fi(...): "); print_vector_of_doubles(vecWf);
	fprintf(stdout, "vecWq = qi(...): "); print_vector_of_doubles(vecWq);
	
	// derivatives

	spMatrix dZ_dX = a.dfe_dX(vecX, vecY, vecU); 
	cout << "dZf_dX = " << dZ_dX << endl;

	spMatrix dZ_dY = a.dfe_dY(vecX, vecY, vecU); 
	cout << "dZf_dY = " << dZ_dY << endl;

	spMatrix dZ_dU = a.dfe_dU(vecX, vecY, vecU); 
	cout << "dZf_dU = " << dZ_dU << endl;

	dZ_dX = a.dqe_dX(vecX, vecY); 
	cout << "dZq_dX = " << dZ_dX << endl;

	dZ_dY = a.dqe_dY(vecX, vecY); 
	cout << "dZq_dY = " << dZ_dY << endl;

	//

	spMatrix dW_dX = a.dfi_dX(vecX, vecY, vecU); 
	cout << "dWf_dX = " << dW_dX << endl;

	spMatrix dW_dY = a.dfi_dY(vecX, vecY, vecU); 
	cout << "dWf_dY = " << dW_dY << endl;

	spMatrix dW_dU = a.dfi_dU(vecX, vecY, vecU); 
	cout << "dWf_dU = " << dW_dU << endl;

	dW_dX = a.dqi_dX(vecX, vecY); 
	cout << "dWq_dX = " << dW_dX << endl;

	dW_dY = a.dqi_dY(vecX, vecY); 
	cout << "dWq_dY = " << dW_dY << endl;

}
