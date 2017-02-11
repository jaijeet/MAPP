#include "RLC2_ModSpec_Element.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

/* 
 * the device: a 3-terminal element with RLC elements inside it
 * the idea is to replicate the exact device I put into Xyce.
 *
 * topology:
 * - the external nodes are 1, 2, and 3. 3 is the reference node.
 * - between nodes 1 and 3, there is a capacitor C
 * - between nodes 2 and 3, there are a resistor R and an inductor L in series
 *
 * unknowns:
 * 	n = 2, 2n = 4
 * 	NIL.NodeNames = "n1", "n2"
 * 	NIL.RefNodeName = "n3"
 * 	[IOnames = "vn1n3", "vn2n3", "in1n3", "in2n3"]
 * 	l = 2
 * 	ExplicitIOnames = "in1n3", "vn2n3"
 * 		=> vecZ = [i13; v23];
 * 	[OtherIOnames = "vn1n3", "in2n3"]
 * 		=> vecX = [vn1n3; in2n3]
 * 	m = 0
 * 	ImplicitEquationNames = {}
 * 		=> vecW = []
 *
 * equations:
 * 	ExplicitOutputs:
 * 	i13 = d/dt (C*v13)
 * 	v23 = i23*R + d/dt [L*i23]
 *
 * parameters:
 * 	R, L and C.
*/

// constructor
RLC2_ModSpec_Element::RLC2_ModSpec_Element(): ModSpec_Element_with_Jacobians() {
	// parm_names
	parm_names += "R", "L", "C";
	
	// parm_types += "double", "double", "double";

	parm_defaultvals += 1000, 1e-9, 1e-9;

	// parm_vals
	parm_vals = parm_defaultvals;

	node_names += "n1", "n2", "n3";
	
	refnode_name = "n3";
	// io_names; set up in base class constructor, should
	// be {'vn1n3', 'vn2n3', 'in1n3', 'in2n3'}
	
	explicit_output_names += "in1n3", "vn2n3";

	// the following function sets up refnode_index, io_names, otherio_names, io_types
	// io_nodenames, otherio_types, otherio_nodenames, otherio_nodeindices, explicit_output_types,
	// explicit_output_nodenames, and explicit_output_nodeindices.  It uses node_names, refnode_name and 
	// explicit_output_names - make sure these are set up correctly before calling it.
	setup_ios_otherios_types_nodenames_indices(); 
	
	// internal_unk_names: empty
	// implicit_equation_names: empty
	// u_names should be empty (set up in base class)
}
//
// fqei_tmpl
template <typename TOUT, typename TX, typename TY, typename TU>
  vector<TOUT> RLC2_ModSpec_Element::fqei_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU, char eORi, char fORq) {
	vector<TOUT> fqout;

	// inputs: 
	// 	vecX = v13, i23
	// 	vecY = []
	// outputs:
	// 	vecZ = i13, v23
	// 	vecW = []
	// parms: R, L, C
	TX v13 = vecX[0];
	TX i23 = vecX[1];
	double R = this->parm_vals[0];
	double L = this->parm_vals[1];
	double C = this->parm_vals[2];

	// fe/qe:
	//	vecZ[0] = i13 = d/dt [C*v13]
	//	vecZ[1] = v23 = i23*R + d/dt [L*i23]

	// fi/qi
 	//	vecW = []

	if (eORi == 'e') { // e => return vecZf = ipn
		if (fORq == 'f') { // f
			fqout += 0, i23*R;
		} else { // q 
			// fqout.push_back(0);
			fqout += C*v13, L*i23;
		}
	} else { // eORi = 'i'
		if (fORq == 'f') { // f
		} else { // q
		}
	}
	return fqout;
}

// // // // // // // // // // // // // // // // // // // // //

// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element_with_Jacobians* create() {
    return new RLC2_ModSpec_Element;
}

extern "C" void destroy(ModSpec_Element_with_Jacobians* p) {
    delete p;
}
