#include "Diode_ModSpec_Element.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
Diode_ModSpec_Element_with_sacado_Jacobians::Diode_ModSpec_Element_with_sacado_Jacobians()
  		:ModSpec_Element_with_Jacobians() {
	
	// parm_names[0] = "Vt";
	// parm_names[1] = "Is";
	this->parm_names.push_back("Vt");
	this->parm_names.push_back("Is");
	
	// parm_descriptions[0] = "thermal voltage";
	// parm_descriptions[0] = "saturation current";
	this->parm_descriptions.push_back("thermal voltage");
	this->parm_descriptions.push_back("saturation current");
	//
	// parm_units[0] = "V";
	// parm_units[0] = "A";
	this->parm_units.push_back("V");
	this->parm_units.push_back("A");
	
	// parm_defaultvals
	this->parm_defaultvals.push_back(0.026);
	this->parm_defaultvals.push_back(1.0e-12);

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
  vector<TOUT> Diode_ModSpec_Element_with_sacado_Jacobians::fqei_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU, 
  char eORi, char fORq) {
	vector<TOUT> fqout;

	// inputs: vecX = vpn, vecY = [], vecU = []
	// outputs:
	TX vpn = vecX[0];
	double Vt = this->parm_vals[0];
	double Is = this->parm_vals[1];
	if (eORi == 'e') { // e => return vecZf = ipn
		if (fORq == 'f') { // f
			TOUT ipn = Is * (exp(vpn/Vt) - 1);
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
// may not be needed any more, since Diode_ModSpec_Element is no longer templated as a class
/*
void junk() {
	Diode_ModSpec_Element oof;
	Diode_ModSpec_Element_with_sacado_Jacobians poof;
}
*/

// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element_with_Jacobians* create() {
    return new Diode_ModSpec_Element_with_sacado_Jacobians;
}

extern "C" void destroy(ModSpec_Element_with_Jacobians* p) {
    delete p;
}
