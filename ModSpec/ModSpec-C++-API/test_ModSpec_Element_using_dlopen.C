#include "dynloaded_ModSpec_Element.h"
#include <iostream>
#include <vector>
#include <dlfcn.h>
#include <time.h> // for setting random seed
#include "vector_print.h"
#include "eeNIL.h" // This script is EE-specific

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

main(int argc, char** argv) {
	using std::cout;
	using std::cerr;

	// fprintf(stdout, "argc=%d\n", argc);
	
	if (argc < 2) {
		fprintf(stderr, "Usage: %s <Some_ModSpec_Element.so>\nExample: %s ./Res_ModSpec_Element.so\n", argv[0], argv[0]);
		exit(1);
	}

	string soName = argv[1];
	
	// dlopen soName, create a ModSpec element, and get a pointer to it.
	dynloaded_ModSpec_Element elSo(soName);
	ModSpec_Element* ModSpecElPtr = elSo.ModSpecElPtr;

	ModSpec_Element &a = *ModSpecElPtr;

	fprintf(stdout, "testing %s\n", soName.c_str());

	string model_name = a.ModelName();
	fprintf(stdout, "ModelName: %s.\n", model_name.c_str());

	string element_name = a.ElementName();
	fprintf(stdout, "ElementName: %s.\n", element_name.c_str());

	vector<string> pnames = a.parmnames();
	fprintf(stdout, "parmnames: "); print_vector_of_strings(pnames);

	fprintf(stdout, "nparms: %d.\n", a.nparms());

	vector<untyped> goof = a.parmdefaults();
	fprintf(stdout, "parmdefaults: "); print_vector_of_untyped(pnames, goof);

	goof = a.getparms();
	fprintf(stdout, "getparms: "); print_vector_of_untyped(pnames, goof);

	vector<untyped> parms = goof; 
	if (parms.size() > 0) {
		untyped savedval = parms[0];
	
		parms[0] = 2000;
		fprintf(stdout, "setting parms[0] to 2000 using setparms()...\n");
		a.setparms(parms);
		goof = a.getparms();
		fprintf(stdout, "\t parms[0] is now "); cout << goof[0] << endl; 
		parms[0] = savedval;
		a.setparms(parms);
		goof = a.getparms();
		fprintf(stdout, "\t restored parms[0] to orig value, it is now "); cout << goof[0] << endl; 
	}

	vector<string> oof;
	oof = a.IOnames();
	fprintf(stdout, "IOnames: "); print_vector_of_strings(oof);

	oof = a.ExplicitOutputNames();
	fprintf(stdout, "ExplicitOutputNames: "); print_vector_of_strings(oof);

	oof = a.OtherIONames();
	fprintf(stdout, "OtherIONames: "); print_vector_of_strings(oof);

	oof = a.InternalUnkNames();
	fprintf(stdout, "InternalUnkNames: "); print_vector_of_strings(oof);

	oof = a.ImplicitEquationNames();
	fprintf(stdout, "ImplicitEquationNames: "); print_vector_of_strings(oof);

	oof = a.uNames();
	fprintf(stdout, "uNames: "); print_vector_of_strings(oof);

	// core functions

	vector<double> vecX, vecY, vecU, vecZf, vecZq, vecWf, vecWq;

	srand48((long)time(NULL));   // time is declared in time.h
	for (int i=0; i< a.OtherIONames().size(); i++)
		vecX.push_back(drand48());

	for (int i=0; i< a.InternalUnkNames().size(); i++)
		vecY.push_back(drand48());

	for (int i=0; i< a.uNames().size(); i++)
		vecU.push_back(drand48());

	vecZf = a.fe(vecX, vecY, vecU);
	vecZq = a.qe(vecX, vecY);
	vecWf = a.fi(vecX, vecY, vecU);
	vecWq = a.qi(vecX, vecY);

	fprintf(stdout, "vecX: "); print_vector_of_doubles(vecX);
	fprintf(stdout, "vecY: "); print_vector_of_doubles(vecY);
	fprintf(stdout, "vecU: "); print_vector_of_doubles(vecU);
	fprintf(stdout, "vecZf = fe(vecX, vecY, vecU): "); print_vector_of_doubles(vecZf);
	fprintf(stdout, "vecZq = qe(vecX, vecY, vecU "); print_vector_of_doubles(vecZq);
	fprintf(stdout, "vecWf = fi(vecX, vecY): "); print_vector_of_doubles(vecWf);
	fprintf(stdout, "vecWq = qi(vecX, vecY): "); print_vector_of_doubles(vecWq);
	
	// derivatives

	spMatrix dZ_dvecX_stamp = a.dfe_dvecX_stamp(vecX, vecY, vecU); 
	cout << "dZf_dvecX_stamp = " << dZ_dvecX_stamp << endl;
	spMatrix dZ_dvecX = a.dfe_dvecX(vecX, vecY, vecU); 
	cout << "dZf_dvecX = " << dZ_dvecX << endl;

	spMatrix dZ_dvecY_stamp = a.dfe_dvecY_stamp(vecX, vecY, vecU); 
	cout << "dZf_dvecY_stamp = " << dZ_dvecY_stamp << endl;
	spMatrix dZ_dvecY = a.dfe_dvecY(vecX, vecY, vecU); 
	cout << "dZf_dvecY = " << dZ_dvecY << endl;

	spMatrix dZ_dvecU_stamp = a.dfe_dvecU_stamp(vecX, vecY, vecU); 
	cout << "dZf_dvecU_stamp = " << dZ_dvecU_stamp << endl;
	spMatrix dZ_dvecU = a.dfe_dvecU(vecX, vecY, vecU); 
	cout << "dZf_dvecU = " << dZ_dvecU << endl;

	dZ_dvecX_stamp = a.dqe_dvecX_stamp(vecX, vecY); 
	cout << "dZq_dvecX_stamp = " << dZ_dvecX_stamp << endl;
	dZ_dvecX = a.dqe_dvecX(vecX, vecY); 
	cout << "dZq_dvecX = " << dZ_dvecX << endl;

	dZ_dvecY_stamp = a.dqe_dvecY_stamp(vecX, vecY); 
	cout << "dZq_dvecY_stamp = " << dZ_dvecY_stamp << endl;
	dZ_dvecY = a.dqe_dvecY(vecX, vecY); 
	cout << "dZq_dvecY = " << dZ_dvecY << endl;

	spMatrix dW_dvecX_stamp = a.dfi_dvecX_stamp(vecX, vecY, vecU); 
	cout << "dWf_dvecX_stamp = " << dW_dvecX_stamp << endl;
	spMatrix dW_dvecX = a.dfi_dvecX(vecX, vecY, vecU); 
	cout << "dWf_dvecX = " << dW_dvecX << endl;

	spMatrix dW_dvecY_stamp = a.dfi_dvecY_stamp(vecX, vecY, vecU); 
	cout << "dWf_dvecY_stamp = " << dW_dvecY_stamp << endl;
	spMatrix dW_dvecY = a.dfi_dvecY(vecX, vecY, vecU); 
	cout << "dWf_dvecY = " << dW_dvecY << endl;

	spMatrix dW_dvecU_stamp = a.dfi_dvecU_stamp(vecX, vecY, vecU); 
	cout << "dWf_dvecU_stamp = " << dW_dvecU_stamp << endl;
	spMatrix dW_dvecU = a.dfi_dvecU(vecX, vecY, vecU); 
	cout << "dWf_dvecU = " << dW_dvecU << endl;

	dW_dvecX_stamp = a.dqi_dvecX_stamp(vecX, vecY); 
	cout << "dWq_dvecX_stamp = " << dW_dvecX_stamp << endl;
	dW_dvecX = a.dqi_dvecX(vecX, vecY); 
	cout << "dWq_dvecX = " << dW_dvecX << endl;

	dW_dvecY_stamp = a.dqi_dvecY_stamp(vecX, vecY); 
	cout << "dWq_dvecY_stamp = " << dW_dvecY_stamp << endl;
	dW_dvecY = a.dqi_dvecY(vecX, vecY); 
	cout << "dWq_dvecY = " << dW_dvecY << endl;

	// test for eeNIL

	fprintf(stdout, "Tests for Network Interface Layer: \n\n");

	vector<string> NIL_NodeNames = a.NILp->NodeNames();
	fprintf(stdout, "NIL_NodeNames: "); print_vector_of_strings(NIL_NodeNames);

	vector<string> NIL_IOnames = a.NILp->IOnames();
	fprintf(stdout, "NIL_IOnames: "); print_vector_of_strings(NIL_IOnames);

	vector<string> NIL_IOtypes = a.NILp->IOtypes();
	fprintf(stdout, "NIL_IOtypes: "); print_vector_of_strings(NIL_IOtypes);

	vector<string> NIL_IONodeNames = a.NILp->IONodeNames();
	fprintf(stdout, "NIL_IONodeNames: "); print_vector_of_strings(NIL_IONodeNames);

    eeNIL_with_common_add_ons* eeNILp = dynamic_cast<eeNIL_with_common_add_ons *> (a.NILp);

	if (eeNILp) {
		fprintf(stdout, "Tests for eeNIL: \n\n");
		fprintf(stdout, "NIL_RefNodeName: %s.\n", eeNILp->RefNodeName().c_str());

		// some helper functions, may not be in eeNIL later
		fprintf(stdout, "Test a few eeNIL helper functions. They may not be in eeNIL later. \n\n");

		fprintf(stdout, "NIL_RefNodeIndex: %d.\n", eeNILp->RefNodeIndex());

		vector<string> NIL_ExplicitOutputTypes = eeNILp->ExplicitOutputTypes();
		fprintf(stdout, "NIL_ExplicitOutputTypes: "); print_vector_of_strings(NIL_ExplicitOutputTypes);
	}

	// test for initlimiting
	fprintf(stdout, "Tests for init/limiting-related fields: \n\n");
	bool support_initlimiting = a.support_initlimiting();

	if (support_initlimiting) {
		vector<double> vecLim;
		for (int i=0; i<a.LimitedVarNames().size(); i++)
			vecLim.push_back(drand48());

		fprintf(stdout, "vecLim: "); print_vector_of_doubles(vecLim);

		vector<double> vecLimInit = a.initGuess(vecU); 
		fprintf(stdout, "vecLimInit=initGuess(vecU) "); print_vector_of_doubles(vecLimInit);

		vector<double> vecLimNew = a.limiting(vecX, vecY, vecLim, vecU); 
		fprintf(stdout, "vecLimNew=limiting(vecX, vecY, vecLimOld) "); print_vector_of_doubles(vecLimNew);

		spMatrix vecXY_to_limited_vars_matrix = a.vecXYtoLimitedVarsMatrix(); 
		cout << "vecXY_to_limited_vars_matrix = " << vecXY_to_limited_vars_matrix << endl;

		vector<double> vecLimOrig = a.vecXYtoLimitedVars(vecX, vecY); 
		fprintf(stdout, "vecLimOrig=vecXYtoLimitedVars(vecX, vecY) "); print_vector_of_doubles(vecLimOrig);

		spMatrix dLimNew_dvecX_stamp = a.dlimiting_dvecX_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dLimNew_dvecX_stamp = " << dLimNew_dvecX_stamp << endl;
		spMatrix dLimNew_dvecX = a.dlimiting_dvecX_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dLimNew_dvecX = " << dLimNew_dvecX_stamp << endl;

		spMatrix dLimNew_dvecY_stamp = a.dlimiting_dvecY_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dLimNew_dvecY_stamp = " << dLimNew_dvecY_stamp << endl;
		spMatrix dLimNew_dvecY = a.dlimiting_dvecY_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dLimNew_dvecY = " << dLimNew_dvecY_stamp << endl;

		vecZf = a.fe(vecX, vecY, vecLim, vecU);
		vecZq = a.qe(vecX, vecY, vecLim);
		vecWf = a.fi(vecX, vecY, vecLim, vecU);
		vecWq = a.qi(vecX, vecY, vecLim);

		fprintf(stdout, "vecZf = fe(vecX, vecY, vecLim, vecU): "); print_vector_of_doubles(vecZf);
		fprintf(stdout, "vecZq = qe(vecX, vecY, vecLim, vecU "); print_vector_of_doubles(vecZq);
		fprintf(stdout, "vecWf = fi(vecX, vecY, vecLim): "); print_vector_of_doubles(vecWf);
		fprintf(stdout, "vecWq = qi(vecX, vecY, vecLim): "); print_vector_of_doubles(vecWq);
		
		spMatrix dZ_dvecX_stamp = a.dfe_dvecX_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dZf_dvecX_stamp = " << dZ_dvecX_stamp << endl;
		spMatrix dZ_dvecX = a.dfe_dvecX(vecX, vecY, vecLim, vecU); 
		cout << "dZf_dvecX = " << dZ_dvecX << endl;

		spMatrix dZ_dvecY_stamp = a.dfe_dvecY_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dZf_dvecY_stamp = " << dZ_dvecY_stamp << endl;
		spMatrix dZ_dvecY = a.dfe_dvecY(vecX, vecY, vecLim, vecU); 
		cout << "dZf_dvecY = " << dZ_dvecY << endl;

		spMatrix dZ_dvecLim_stamp = a.dfe_dvecLim_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dZf_dvecLim_stamp = " << dZ_dvecLim_stamp << endl;
		spMatrix dZ_dvecLim = a.dfe_dvecLim(vecX, vecY, vecLim, vecU); 
		cout << "dZf_dvecLim = " << dZ_dvecLim << endl;

		spMatrix dZ_dvecU_stamp = a.dfe_dvecU_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dZf_dvecU_stamp = " << dZ_dvecU_stamp << endl;
		spMatrix dZ_dvecU = a.dfe_dvecU(vecX, vecY, vecLim, vecU); 
		cout << "dZf_dvecU = " << dZ_dvecU << endl;

		dZ_dvecX_stamp = a.dqe_dvecX_stamp(vecX, vecY, vecLim); 
		cout << "dZq_dvecX_stamp = " << dZ_dvecX_stamp << endl;
		dZ_dvecX = a.dqe_dvecX(vecX, vecY, vecLim); 
		cout << "dZq_dvecX = " << dZ_dvecX << endl;

		dZ_dvecY_stamp = a.dqe_dvecY_stamp(vecX, vecY, vecLim); 
		cout << "dZq_dvecY_stamp = " << dZ_dvecY_stamp << endl;
		dZ_dvecY = a.dqe_dvecY(vecX, vecY, vecLim); 
		cout << "dZq_dvecY = " << dZ_dvecY << endl;

		dZ_dvecLim_stamp = a.dqe_dvecLim_stamp(vecX, vecY, vecLim); 
		cout << "dZq_dvecLim_stamp = " << dZ_dvecLim_stamp << endl;
		dZ_dvecLim = a.dqe_dvecLim(vecX, vecY, vecLim); 
		cout << "dZq_dvecLim = " << dZ_dvecLim << endl;

		spMatrix dW_dvecX_stamp = a.dfi_dvecX_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dWf_dvecX_stamp = " << dW_dvecX_stamp << endl;
		spMatrix dW_dvecX = a.dfi_dvecX(vecX, vecY, vecLim, vecU); 
		cout << "dWf_dvecX = " << dW_dvecX << endl;

		spMatrix dW_dvecY_stamp = a.dfi_dvecY_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dWf_dvecY_stamp = " << dW_dvecY_stamp << endl;
		spMatrix dW_dvecY = a.dfi_dvecY(vecX, vecY, vecLim, vecU); 
		cout << "dWf_dvecY = " << dW_dvecY << endl;

		spMatrix dW_dvecLim_stamp = a.dfi_dvecLim_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dWf_dvecLim_stamp = " << dW_dvecLim_stamp << endl;
		spMatrix dW_dvecLim = a.dfi_dvecLim(vecX, vecY, vecLim, vecU); 
		cout << "dWf_dvecLim = " << dW_dvecLim << endl;

		spMatrix dW_dvecU_stamp = a.dfi_dvecU_stamp(vecX, vecY, vecLim, vecU); 
		cout << "dWf_dvecU_stamp = " << dW_dvecU_stamp << endl;
		spMatrix dW_dvecU = a.dfi_dvecU(vecX, vecY, vecLim, vecU); 
		cout << "dWf_dvecU = " << dW_dvecU << endl;

		dW_dvecX_stamp = a.dqi_dvecX_stamp(vecX, vecY, vecLim); 
		cout << "dWq_dvecX_stamp = " << dW_dvecX_stamp << endl;
		dW_dvecX = a.dqi_dvecX(vecX, vecY, vecLim); 
		cout << "dWq_dvecX = " << dW_dvecX << endl;

		dW_dvecY_stamp = a.dqi_dvecY_stamp(vecX, vecY, vecLim); 
		cout << "dWq_dvecY_stamp = " << dW_dvecY_stamp << endl;
		dW_dvecY = a.dqi_dvecY(vecX, vecY, vecLim); 
		cout << "dWq_dvecY = " << dW_dvecY << endl;

		dW_dvecLim_stamp = a.dqi_dvecLim_stamp(vecX, vecY, vecLim); 
		cout << "dWq_dvecLim_stamp = " << dW_dvecLim_stamp << endl;
		dW_dvecLim = a.dqi_dvecLim(vecX, vecY, vecLim); 
		cout << "dWq_dvecLim = " << dW_dvecLim << endl;
	}
	else {
		fprintf(stdout, "This model doesn't support init/limiting. \n\n");
	}
}
