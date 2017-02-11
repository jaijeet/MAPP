#include "RLC_ModSpec_Element.h"

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
 * - between nodes 1 and 2, there is a resistor R
 * - between nodes 2 and 3, there are a capacitor C and an inductor L in series
 *
 * unknowns:
 * 	n = 2, 2n = 4
 * 	NIL.NodeNames = "n1", "n2"
 * 	NIL.RefNodeName = "n3"
 * 	[IOnames = "vn1n3", "vn2n3", "in1n3", "in2n3"]
 * 	l = 2
 * 	ExplicitIOnames = "in1n3", "in2n3"
 * 		=> vecZ = [i13; i23];
 * 	[OtherIOnames = "vn1n3", "vn2n3"]
 * 		=> vecX = [vn1n3; vn2n3]
 * 	m = 2
 * 	InternalUnkNames = "vL", "iL" (vL is the drop across the inductor)
 * 		=> vecY = [vL; iL]
 * 	ImplicitEquationNames = "LBCR", "intKCL"
 * 		=> vecW = [LBCR_residual, intKCL_residual]
 *
 * equations:
 * 	ExplicitOutputs vecZ:
 * 	i13 = (v13-v23)/R = (e1-e2)/R
 * 	i23 = -(v13-v23)/R + d/dt [C (e2-e3-vL)]
 *
 * 	ImplicitEquations vecW:
 * 	LBCR: L diL/dt - vL = 0
 * 	intKCL: - d/dt[C (e2-e3-vL)] + iL = 0
 *
 * parameters:
 * 	R, L and C.
*/

// constructor
RLC_ModSpec_Element::RLC_ModSpec_Element(): ModSpec_Element_with_Jacobians() {
	// parm_names
	/*
	parm_names.push_back("R");
	parm_names.push_back("L");
	parm_names.push_back("C");
	*/
	parm_names += "R", "L", "C";
	
	// parm_types
	/*
	parm_types.push_back("double");
	parm_types.push_back("double");
	parm_types.push_back("double");
	*/
	// parm_types += "double", "double", "double";

	// parm_defaultvals
	/*
	parm_defaultvals.push_back(1000); // R
	parm_defaultvals.push_back(1e-9); // L
	parm_defaultvals.push_back(1e-9); // C
	*/
	parm_defaultvals += 1000, 1e-9, 1e-9;

	// parm_vals
	parm_vals = parm_defaultvals;

	// node_names
	/*
	node_names.push_back("n1");
	node_names.push_back("n2");
	node_names.push_back("n3");
	*/
	node_names += "n1", "n2", "n3";
	
	refnode_name = "n3";
	// io_names; set up in base class constructor, should
	// be {'vn1n3', 'vn2n3', 'in1n3', 'in2n3'}
	
	// explicit_output_names
	/*
	explicit_output_names.push_back("in1n3");
	explicit_output_names.push_back("in2n3");
	*/
	explicit_output_names += "in1n3", "in2n3";

	// the following function sets up io_names, otherio_names, io_types
	// io_nodenames, otherio_types, otherio_nodenames, explicit_output_types
	// and explicit_output_nodenames.  It uses node_names, refnode_name and 
	// explicit_output_names - make sure these are set up correctly
	// before calling it.
	setup_ios_otherios_types_nodenames_indices(); 
	
	// internal_unk_names
	internal_unk_names += "vL", "iL";
	
	// implicit_equation_names
	implicit_equation_names += "LBCR", "intKCL";
	
	// u_names should be empty (set up in base class)
}
//
// fqei_tmpl
template <typename TOUT, typename TX, typename TY, typename TU>
  vector<TOUT> RLC_ModSpec_Element::fqei_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU, char eORi, char fORq) {
	vector<TOUT> fqout;

	// inputs: 
	// 	vecX = v13, v23
	// 	vecY = vL, iL
	// outputs:
	// 	vecZ = i13, i23
	// 	vecW = LBCR_residual, intKCL_residual
	// parms: R, L, C
	TX v13 = vecX[0];
	TX v23 = vecX[1];
	TY vL = vecY[0];
	TY iL = vecY[1];
	double R = this->parm_vals[0];
	double L = this->parm_vals[1];
	double C = this->parm_vals[2];

	// fe/qe:
	//	vecZ[0] = i13 = (v13-v23)/R
	//	vecZ[1] = i23 = -(v13-v23)/R + d/dt [C (v23-vL)]

	// fi/qi
 	//	vecW[0] = LBCR: L diL/dt - vL = 0
	//	vecW[1] = intKCL: - d/dt[C (v23-vL)] + iL = 0

	if (eORi == 'e') { // e => return vecZf = ipn
		if (fORq == 'f') { // f
			TOUT i13 = (v13-v23)/R;
			fqout += i13, -i13;
		} else { // q 
			TOUT q13 = 0;
			TOUT q23 = C*(v23-vL);
			// fqout.push_back(0);
			fqout += q13, q23;
		}
	} else { // eORi = 'i'
		if (fORq == 'f') { // f
			TOUT LBCR_residual = -vL;
			TOUT intKCL_residual = iL;
			fqout += LBCR_residual, intKCL_residual;
		} else { // q
			TOUT LBCR_residual = L*iL;
			TOUT intKCL_residual = -C*(v23-vL);
			fqout += LBCR_residual, intKCL_residual;
		}
	}
	return fqout;
}



// // // // // // // // // // // // // // // // // // // // //

// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element_with_Jacobians* create() {
    return new RLC_ModSpec_Element;
}

extern "C" void destroy(ModSpec_Element_with_Jacobians* p) {
    delete p;
}
