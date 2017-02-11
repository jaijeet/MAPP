#include "simpleDiodeModSpec_directly_from_ModSpec_Element.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>

using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

simpleDiodeModSpec_directly_from_ModSpec_Element::simpleDiodeModSpec_directly_from_ModSpec_Element()
		: ModSpec_Element(),
		  vecXY_to_limited_vars_matrix_stamp(1, 2),
		  vecXY_to_limited_vars_matrix(1, 2),
		  vecX_to_limited_vars_matrix_stamp(1, 1),
		  vecX_to_limited_vars_matrix(1, 1),
		  vecY_to_limited_vars_matrix_stamp(1, 1),
		  vecY_to_limited_vars_matrix(1, 1),
		  Vt_str("Vt"),
		  Is_str("Is"),
		  R_str("R"),
		  nvecX(1),
		  nvecY(1),
		  nvecZ(1),
		  nvecW(1),
		  nvecLim(1) {
	parm_names += "Vt", "Is", "R";
	parm_defaultvals += 0.026, 1e-12, 1.0;
	parm_vals = parm_defaultvals;


	vector<string> node_names;
	node_names += "p", "n";
	string refnode_name = "n";
	vector<string> explicit_output_names;
	explicit_output_names += "ipn";
	NILp = new eeNIL_with_common_add_ons(node_names, refnode_name, explicit_output_names);

	// nvecX = OtherIONames().size();
	// nvecY = InternalUnkNames().size();
	// nvecZ = ExplicitOutputNames().size();
	// nvecW = ImplicitEquationNames().size();
	// nvecLim = LimitedVarNames().size();

	vecXY_to_limited_vars_matrix_stamp(0, 1) = 1.0;
	vecXY_to_limited_vars_matrix(0, 1) = 1.0;

	vecX_to_limited_vars_matrix_stamp = subslice(vecXY_to_limited_vars_matrix_stamp, 0, 1, nvecLim, 0, 1, nvecX);
	vecX_to_limited_vars_matrix = subslice(vecXY_to_limited_vars_matrix, 0, 1, nvecLim, 0, 1, nvecX);
	vecY_to_limited_vars_matrix_stamp = subslice(vecXY_to_limited_vars_matrix_stamp, 0, 1, nvecLim, nvecX, 1, nvecY);
	vecY_to_limited_vars_matrix = subslice(vecXY_to_limited_vars_matrix, 0, 1, nvecLim, nvecX, 1, nvecY);
}

string simpleDiodeModSpec_directly_from_ModSpec_Element::ModelName() {
	string model_name = "simple diode";
	return model_name;
};

string simpleDiodeModSpec_directly_from_ModSpec_Element::ElementName() {
	string element_name = "";
	return element_name;
};

vector<string> simpleDiodeModSpec_directly_from_ModSpec_Element::parmnames() {
	return parm_names;
};
vector<string> simpleDiodeModSpec_directly_from_ModSpec_Element::paramnames() {
	return parm_names;
};

vector<untyped> simpleDiodeModSpec_directly_from_ModSpec_Element::parmdefaults() {
	return parm_defaultvals;
};
vector<untyped> simpleDiodeModSpec_directly_from_ModSpec_Element::paramdefaults() {
	return parm_defaultvals;
};

int simpleDiodeModSpec_directly_from_ModSpec_Element::nparms() {
	return 3;
};
int simpleDiodeModSpec_directly_from_ModSpec_Element::nparams() {
	return 3;
};

vector<untyped> simpleDiodeModSpec_directly_from_ModSpec_Element::getparms() {
	return parm_vals;
}; 
vector<untyped> simpleDiodeModSpec_directly_from_ModSpec_Element::getparams() {
	return parm_vals;
}; 

int simpleDiodeModSpec_directly_from_ModSpec_Element::findparm(string& parm) { // used by getparm and setparm
	int retval = -1;
	// find index of parm in parm_names
	vector<string>::iterator vsIter; // std::find returns this type
		// see http://www.cprogramming.com/tutorial/stl/iterators.html
	vsIter = find(parm_names.begin(), parm_names.end(), parm);
	if (vsIter != parm_names.end()) {
		// found; set it
		retval = vsIter - parm_names.begin();
	} else {
		fprintf(stderr, "parameter %s not found in parm_names\n", parm.c_str());
	}

	return retval;
}

untyped simpleDiodeModSpec_directly_from_ModSpec_Element::getparm(string& parm) {
	untyped retval;
	int idx = findparm(parm);
	retval = parm_vals[idx];
	return retval;
}
untyped simpleDiodeModSpec_directly_from_ModSpec_Element::getparam(string& parm) {
	return getparm(parm);
}

void simpleDiodeModSpec_directly_from_ModSpec_Element::setparms(vector<untyped>& a) {
	parm_vals = a;
}
void simpleDiodeModSpec_directly_from_ModSpec_Element::setparams(vector<untyped>& a) {
	parm_vals = a;
}

void simpleDiodeModSpec_directly_from_ModSpec_Element::setparm(string& parm, untyped& val) {
	int idx = findparm(parm);
	parm_vals[idx] = val;
}
void simpleDiodeModSpec_directly_from_ModSpec_Element::setparam(string& parm, untyped& val) {
	setparm(parm, val);
}

vector<string> simpleDiodeModSpec_directly_from_ModSpec_Element::IOnames() { 
	vector<string> io_names;
	io_names += "vpn", "ipn";
	return io_names;
};

vector<string> simpleDiodeModSpec_directly_from_ModSpec_Element::ExplicitOutputNames() {
	vector<string> explicit_output_names;
	explicit_output_names += "ipn";
	return explicit_output_names;
};

vector<string> simpleDiodeModSpec_directly_from_ModSpec_Element::OtherIONames() { 
	vector<string> otherio_names;
	otherio_names += "vpn";
	return otherio_names;
};

vector<string> simpleDiodeModSpec_directly_from_ModSpec_Element::InternalUnkNames() {
	vector<string> internal_unk_names;
	internal_unk_names += "vin";
	return internal_unk_names;
};

vector<string> simpleDiodeModSpec_directly_from_ModSpec_Element::ImplicitEquationNames() {
	vector<string> implicit_equation_names;
	implicit_equation_names += "KCL-i";
	return implicit_equation_names;
};

vector<string> simpleDiodeModSpec_directly_from_ModSpec_Element::uNames() {
	vector<string> u_names; // empty
	return u_names;
};

vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::fe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	return fe(vecX, vecY, vecLim, vecU);
}

vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::qe(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecLim = vecY;
	return qe(vecX, vecY, vecLim);
}

vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::fi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	return fi(vecX, vecY, vecLim, vecU);
}

vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::qi(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecLim = vecY;
	return qi(vecX, vecY, vecLim);
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dfe_dvecX_stamp(vecX, vecY, vecLim, vecU) + prod(dfe_dvecLim_stamp(vecX, vecY, vecLim, vecU), vecX_to_limited_vars_matrix_stamp);
	return to_stamp( Jout );
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dfe_dvecX(vecX, vecY, vecLim, vecU) + prod(dfe_dvecLim(vecX, vecY, vecLim, vecU),  vecX_to_limited_vars_matrix);
	return Jout;
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dqe_dvecX_stamp(vecX, vecY, vecLim) + prod(dqe_dvecLim_stamp(vecX, vecY, vecLim), vecX_to_limited_vars_matrix_stamp);
	return to_stamp( Jout );
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqe_dvecX(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dqe_dvecX(vecX, vecY, vecLim) + prod(dqe_dvecLim(vecX, vecY, vecLim), vecX_to_limited_vars_matrix);
	return Jout;
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dfi_dvecX_stamp(vecX, vecY, vecLim, vecU) + prod(dfi_dvecLim_stamp(vecX, vecY, vecLim, vecU), vecX_to_limited_vars_matrix_stamp);
	return to_stamp( Jout );
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dfi_dvecX(vecX, vecY, vecLim, vecU) + prod(dfi_dvecLim(vecX, vecY, vecLim, vecU), vecX_to_limited_vars_matrix);
	return Jout;
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dqi_dvecX_stamp(vecX, vecY, vecLim) + prod(dqi_dvecLim_stamp(vecX, vecY, vecLim), vecX_to_limited_vars_matrix_stamp);
	return to_stamp( Jout );
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqi_dvecX(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dqi_dvecX(vecX, vecY, vecLim) + prod(dqi_dvecLim(vecX, vecY, vecLim), vecX_to_limited_vars_matrix);
	return Jout;
}
		
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dfe_dvecY_stamp(vecX, vecY, vecLim, vecU) + prod(dfe_dvecLim_stamp(vecX, vecY, vecLim, vecU), vecY_to_limited_vars_matrix_stamp);
	return to_stamp( Jout );
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dfe_dvecY(vecX, vecY, vecLim, vecU) + prod(dfe_dvecLim(vecX, vecY, vecLim, vecU), vecY_to_limited_vars_matrix);
	return Jout;
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dqe_dvecY_stamp(vecX, vecY, vecLim) + prod(dqe_dvecLim_stamp(vecX, vecY, vecLim), vecY_to_limited_vars_matrix_stamp);
	return to_stamp( Jout );
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqe_dvecY(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dqe_dvecY(vecX, vecY, vecLim) + prod(dqe_dvecLim(vecX, vecY, vecLim), vecY_to_limited_vars_matrix);
	return Jout;
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dfi_dvecY_stamp(vecX, vecY, vecLim, vecU) + prod(dfi_dvecLim_stamp(vecX, vecY, vecLim, vecU), vecY_to_limited_vars_matrix_stamp);
	return to_stamp( Jout );
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dfi_dvecY(vecX, vecY, vecLim, vecU) + prod(dfi_dvecLim(vecX, vecY, vecLim, vecU), vecY_to_limited_vars_matrix);
	return Jout;
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dqi_dvecY_stamp(vecX, vecY, vecLim) + prod(dqi_dvecLim_stamp(vecX, vecY, vecLim), vecY_to_limited_vars_matrix_stamp);
	return to_stamp( Jout );
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqi_dvecY(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecLim = vecY;
	spMatrix Jout = dqi_dvecY(vecX, vecY, vecLim) + prod(dqi_dvecLim(vecX, vecY, vecLim), vecY_to_limited_vars_matrix);
	return Jout;
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	return dfe_dvecU_stamp(vecX, vecY, vecLim, vecU);
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	return dfe_dvecU(vecX, vecY, vecLim, vecU);
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	return dfi_dvecU_stamp(vecX, vecY, vecLim, vecU);
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> vecLim = vecY;
	return dfi_dvecU(vecX, vecY, vecLim, vecU);
}

// init/limiting flag
bool simpleDiodeModSpec_directly_from_ModSpec_Element::support_initlimiting() {
	return true;
};

// extra function fields related to init/limiting, default is no limited variables.
vector<string> simpleDiodeModSpec_directly_from_ModSpec_Element::LimitedVarNames() {
	vector<string> limited_var_names;
	limited_var_names += "vinlim";
	return limited_var_names;
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::vecXYtoLimitedVarsMatrix_stamp() {
	spMatrix J_OUT(1, 2);
	J_OUT(0, 1) = 1.0;
	return J_OUT;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::vecXYtoLimitedVarsMatrix() {
	spMatrix J_OUT(1, 2);
	J_OUT(0, 1) = 1.0;
	return J_OUT;
}
vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::vecXYtoLimitedVars(vector<double>& vecX, vector<double>& vecY) {
	return vecY;
}

vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::initGuess(vector<double>& vecU) {
	Vt = getparm(Vt_str);
	Is = getparm(Is_str);
	double Vcrit = Vt * log( Vt / (sqrt(2)*Is));
	vector<double> vecLimInit;
	vecLimInit += Vcrit;
	return vecLimInit;
}

vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::limiting(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU) {
	Vt = getparm(Vt_str);
	Is = getparm(Is_str);
	double Vcrit = Vt * log( Vt / (sqrt(2)*Is));

	double vin = vecY[0];
	double vinlimOld = vecLimOld[0];

	double vinlimNew = pnjlim(vin, vinlimOld, Vt, Vcrit);

	vector<double> vecLimNew;
	vecLimNew += vinlimNew;
	return vecLimNew;
}

// Use default virtual methods:
// spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dlimiting_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU);
// spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dlimiting_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU);
// spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dlimiting_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU);
// spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dlimiting_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU);

// core model functions with init/limiting
vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::fe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	double vpn = vecX[0];
	double vin = vecY[0];

	R = getparm(R_str);

	vector<double> out;
	out += (vpn - vin)/R;
	return out; 
}
vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::fi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	double vpn = vecX[0];
	double vin = vecY[0];
	double vinlim = vecLim[0];

	Vt = getparm(Vt_str);
	Is = getparm(Is_str);
	R = getparm(R_str);

	vector<double> out;
	out += - diode_Id(vinlim, Is, Vt) + (vpn - vin)/R;
	return out; 
}
vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::qe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	vector<double> out;
	out += 0;
	return out; 
}
vector<double> simpleDiodeModSpec_directly_from_ModSpec_Element::qi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	vector<double> out;
	out += 0;
	return out; 
}

// jacobian stamps with init/limiting
// ddvecX functions
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 1);
	Jout(0, 0) = 1.0;
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	R = getparm(R_str);
	spMatrix Jout(1, 1);
	Jout(0, 0) = 1/R;
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 1);
	Jout(0, 0) = 1.0;
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	R = getparm(R_str);
	spMatrix Jout(1, 1);
	Jout(0, 0) = 1/R;
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}

// ddvecY functions
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	R = getparm(R_str);
	spMatrix Jout(1, 1);
	Jout(0, 0) = -1/R;
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 1);
	Jout(0, 0) = 1.0;
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 1);
	Jout(0, 0) = 1.0;
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	R = getparm(R_str);
	spMatrix Jout(1, 1);
	Jout(0, 0) = -1/R;
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}

// ddvecU functions
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 0);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 0);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 0);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 0);
	return Jout;
}

// ddvecLim functions
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfe_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	spMatrix Jout(1, 1);
	Jout(0, 0) = 1.0;
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dfi_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
	double vinlim = vecLim[0];

	Vt = getparm(Vt_str);
	Is = getparm(Is_str);

	spMatrix Jout(1, 1);
	Jout(0, 0) = - diode_Gd(vinlim, Is, Vt);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqe_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqe_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqi_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}
spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::dqi_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
	spMatrix Jout(1, 1);
	return Jout;
}

spMatrix simpleDiodeModSpec_directly_from_ModSpec_Element::to_stamp(const spMatrix& A) {
	// find the locations of the non-zeros of A and make them 1
	spMatrix tmp(A.size1(), A.size2());
	for (row_iterator_const it1 = A.begin1(); it1 != A.end1(); it1++) {
	  for (col_iterator_const it2 = it1.begin(); it2 != it1.end(); it2++) {
	  	tmp(it2.index1(),it2.index2()) = 1; // *it2;
	  }
	}
	return tmp;
}

double simpleDiodeModSpec_directly_from_ModSpec_Element::diode_Id(double Vd, double Is, double Vt) {
	return Is * (exp(Vd/Vt) - 1);
}

double simpleDiodeModSpec_directly_from_ModSpec_Element::diode_Gd(double Vd, double Is, double Vt) {
	return Is/Vt*exp(Vd/Vt);
}

double simpleDiodeModSpec_directly_from_ModSpec_Element::pnjlim(double vnew, double vold, double vt, double vcrit) {
// from DEVpnjlim in devsup.c in ngspice-24
    double arg;

    if((vnew > vcrit) && (fabs(vnew - vold) > (vt + vt))) {
        if(vold > 0) {
            arg = (vnew - vold) / vt; 
            if(arg > 0) {
                vnew = vold + vt * (2+log(arg-2));
            } else {
                vnew = vold - vt * (2+log(2-arg));
            }
        } else {
            vnew = vt *log(vnew/vt);
        }
        // *icheck = 1;
    } else {
       if (vnew < 0) {
           if (vold > 0) {
               arg = -1*vold-1;
           } else {
               arg = 2*vold-1;
           }
           if (vnew < arg) {
              vnew = arg;
              // *icheck = 1;
           } else {
              // *icheck = 0;
           };
        } else {
           // *icheck = 0;
        }
    }   
    return(vnew);
}

// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element* create() {
    return new simpleDiodeModSpec_directly_from_ModSpec_Element;
}

extern "C" void destroy(ModSpec_Element* p) {
    delete p;
}
