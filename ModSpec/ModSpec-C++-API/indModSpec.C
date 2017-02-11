#include "indModSpec.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
indModSpec::indModSpec() {
	// model_name
	model_name = "Inductor";

	// element_name
	element_name = "undefined"; // TODO: should get is from outside

	// parm_names
	parm_names += "L";
	
	// parm_defaultvals
	parm_defaultvals += 1.0e-9;

	// parm_vals
	parm_vals = parm_defaultvals;

	// node_names
	node_names += "p", "n";
	
	// refnode_name
	refnode_name = "n";
	
	// explicit_output_names
	explicit_output_names += "vpn";
	
	// the following function sets up refnode_index, io_names, otherio_names, io_types
	// io_nodenames, otherio_types, otherio_nodenames, otherio_nodeindices, explicit_output_types,
	// explicit_output_nodenames, and explicit_output_nodeindices.  It uses node_names, refnode_name and 
	// explicit_output_names - make sure these are set up correctly before calling it.
	setup_ios_otherios_types_nodenames_indices();
}

template <typename TOUT, typename TX, typename TY, typename TU>
  vector<TOUT> indModSpec::fe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU) {
	vector<TOUT> out;
	out.push_back(0);
	return out;
}

template <typename TOUT, typename TX, typename TY>
  vector<TOUT> indModSpec::qe_tmpl(vector<TX>& vecX, vector<TY>& vecY) {
	vector<TOUT> out;
	TX ipn = vecX[0];
	double L = this->parm_vals[0];
	out.push_back(L * ipn);
	return out;
}

template <typename TOUT, typename TX, typename TY, typename TU>
  vector<TOUT> indModSpec::fi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU) {
	vector<TOUT> out;
	return out;
}

template <typename TOUT, typename TX, typename TY>
  vector<TOUT> indModSpec::qi_tmpl(vector<TX>& vecX, vector<TY>& vecY) {
	vector<TOUT> out;
	return out;
}


/*
// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element* create() {
    return new indModSpec;
}

extern "C" void destroy(ModSpec_Element* p) {
    delete p;
}
*/
