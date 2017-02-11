#include "Res_ModSpec_Element.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
Res_ModSpec_Element_with_sacado_Jacobians::Res_ModSpec_Element_with_sacado_Jacobians()
  		:ModSpec_Element_with_Jacobians() {
	
	// parm_names[0] = "R";
	this->parm_names.push_back("R");
	
	// parm_descriptions[0] = "resistance";
	this->parm_descriptions.push_back("resistance");
	//
	// parm_units[0] = "ohm";
	this->parm_units.push_back("ohm");
	
	/* type now subsumed within untyped class
	// parm_types[0] = "double";
	this->parm_types.push_back("double");
	*/

	// parm_defaultvals
	this->parm_defaultvals.push_back(1000);

	// parm_vals
	this->parm_vals = this->parm_defaultvals;

	//node_names[0] = "p";
	//node_names[1] = "n";
	this->node_names.push_back("p");
	this->node_names.push_back("n");
	
	this->refnode_name = "n";
	// ??? parm_vals;
	// ??? parm_defaultvals;
	// io_names; set up in base class constructor, should
	// be {'vpn', 'ipn'}
	
	// explicit_output_names[0] = "ipn";
	this->explicit_output_names.push_back("ipn");
	
	// the following function sets up refnode_index, io_names, otherio_names, io_types
	// io_nodenames, otherio_types, otherio_nodenames, otherio_nodeindices, explicit_output_types,
	// explicit_output_nodenames, and explicit_output_nodeindices.  It uses node_names, refnode_name and 
	// explicit_output_names - make sure these are set up correctly before calling it.
	this->setup_ios_otherios_types_nodenames_indices();

	// otherio_names: should be "vpn"
	// internal_unk_names should be empty: set up in base class
	// implicit_equation_names should be empty: set up in base class
	// u_names should be empty: set up in base class
}

// fqei_tmpl
template <typename TOUT, typename TX, typename TY, typename TU>
  vector<TOUT> Res_ModSpec_Element_with_sacado_Jacobians::fqei_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU, 
  char eORi, char fORq) {
	vector<TOUT> fqout;

	// inputs: vecX = vpn, vecY = [], vecU = []
	// outputs:
	TX vpn = vecX[0];
	double R = this->parm_vals[0];
	if (eORi == 'e') { // e => return vecZf = ipn
		if (fORq == 'f') { // f
			TOUT ipn = vpn/R;
			fqout.push_back(ipn);
		} else { // q => return vecZq = 0
			fqout.push_back(0);
		}
	} else { // i => return vecW = []
		// do nothing: return empty fqout
	}
	return fqout;
}

// this gets the compiler to instantiate specific templates, only then will they be found at link time.
// see http://azimbabu.blogspot.com/2010/01/compilation-and-linking-issues-for-c.html
// may not be needed any more, since Res_ModSpec_Element is no longer templated as a class
/*
void junk() {
	Res_ModSpec_Element oof;
	Res_ModSpec_Element_with_sacado_Jacobians poof;
}
*/

// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element_with_Jacobians* create() {
    return new Res_ModSpec_Element_with_sacado_Jacobians;
}

extern "C" void destroy(ModSpec_Element_with_Jacobians* p) {
    delete p;
}
