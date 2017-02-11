#include "isrcModSpec.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
isrcModSpec::isrcModSpec() {
	// model_name
	model_name = "Current source";

	// element_name
	element_name = "undefined"; // TODO: should get is from outside

	// node_names
	node_names += "p", "n";
	
	// refnode_name
	refnode_name = "n";
	
	// explicit_output_names
	explicit_output_names += "ipn";
	
	// u_names
	u_names += "I";
	
	// the following function sets up refnode_index, io_names, otherio_names, io_types
	// io_nodenames, otherio_types, otherio_nodenames, otherio_nodeindices, explicit_output_types,
	// explicit_output_nodenames, and explicit_output_nodeindices.  It uses node_names, refnode_name and 
	// explicit_output_names - make sure these are set up correctly before calling it.
	setup_ios_otherios_types_nodenames_indices();
}

template <typename TOUT, typename TX, typename TY, typename TU>
  vector<TOUT> isrcModSpec::fe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU) {
	vector<TOUT> out;
	TU I = vecU[0];
	TOUT ipn = I;
	out.push_back(ipn);
	return out;
}

template <typename TOUT, typename TX, typename TY>
  vector<TOUT> isrcModSpec::qe_tmpl(vector<TX>& vecX, vector<TY>& vecY) {
	vector<TOUT> out;
	out.push_back(0);
	return out;
}

template <typename TOUT, typename TX, typename TY, typename TU>
  vector<TOUT> isrcModSpec::fi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU) {
	vector<TOUT> out;
	return out;
}

template <typename TOUT, typename TX, typename TY>
  vector<TOUT> isrcModSpec::qi_tmpl(vector<TX>& vecX, vector<TY>& vecY) {
	vector<TOUT> out;
	return out;
}


// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element* create() {
    return new isrcModSpec;
}

extern "C" void destroy(ModSpec_Element* p) {
    delete p;
}
