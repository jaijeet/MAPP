#include "resModSpec_directly_from_ModSpec_Element.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

resModSpec_directly_from_ModSpec_Element::resModSpec_directly_from_ModSpec_Element()
		: ModSpec_Element() {

	parm_names += "R";
	parm_defaultvals += 1000.0;
	parm_vals = parm_defaultvals;

	vector<string> node_names;
	node_names += "p", "n";
	string refnode_name = "n";
	vector<string> explicit_output_names;
	explicit_output_names += "ipn";
	NILp = new eeNIL_with_common_add_ons(node_names, refnode_name, explicit_output_names);
}

string resModSpec_directly_from_ModSpec_Element::ModelName() {
	string model_name = "Resistor";
	return model_name;
}

string resModSpec_directly_from_ModSpec_Element::ElementName() {
	string element_name = "";
	return element_name;
}

vector<string> resModSpec_directly_from_ModSpec_Element::parmnames() {
	return parm_names;
}
vector<string> resModSpec_directly_from_ModSpec_Element::paramnames() {
	return parm_names;
}

vector<untyped> resModSpec_directly_from_ModSpec_Element::parmdefaults() {
	return parm_defaultvals;
}
vector<untyped> resModSpec_directly_from_ModSpec_Element::paramdefaults() {
	return parm_defaultvals;
}

int resModSpec_directly_from_ModSpec_Element::nparms() {
	return 1;
}
int resModSpec_directly_from_ModSpec_Element::nparams() {
	return 1;
}

vector<untyped> resModSpec_directly_from_ModSpec_Element::getparms() {
	return parm_vals;
} 
vector<untyped> resModSpec_directly_from_ModSpec_Element::getparams() {
	return parm_vals;
} 

int resModSpec_directly_from_ModSpec_Element::findparm(string& parm) { // used by getparm and setparm
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

untyped resModSpec_directly_from_ModSpec_Element::getparm(string& parm) {
	untyped retval;
	int idx = findparm(parm);
	retval = parm_vals[idx];
	return retval;
}
untyped resModSpec_directly_from_ModSpec_Element::getparam(string& parm) {
	return getparm(parm);
}

void resModSpec_directly_from_ModSpec_Element::setparms(vector<untyped>& a) {
	parm_vals = a;
}
void resModSpec_directly_from_ModSpec_Element::setparams(vector<untyped>& a) {
	parm_vals = a;
}

void resModSpec_directly_from_ModSpec_Element::setparm(string& parm, untyped& val) {
	int idx = findparm(parm);
	parm_vals[idx] = val;
}
void resModSpec_directly_from_ModSpec_Element::setparam(string& parm, untyped& val) {
	setparm(parm, val);
}

vector<string> resModSpec_directly_from_ModSpec_Element::IOnames() { 
	vector<string> io_names;
	io_names += "vpn", "ipn";
	return io_names;
}

vector<string> resModSpec_directly_from_ModSpec_Element::ExplicitOutputNames() {
	vector<string> explicit_output_names;
	explicit_output_names += "ipn";
	return explicit_output_names;
}

vector<string> resModSpec_directly_from_ModSpec_Element::OtherIONames() { 
	vector<string> otherio_names;
	otherio_names += "vpn";
	return otherio_names;
}

vector<string> resModSpec_directly_from_ModSpec_Element::InternalUnkNames() {
	vector<string> internal_unk_names; // empty
	return internal_unk_names;
}

vector<string> resModSpec_directly_from_ModSpec_Element::ImplicitEquationNames() {
	vector<string> implicit_equation_names; // empty
	return implicit_equation_names;
}

vector<string> resModSpec_directly_from_ModSpec_Element::uNames() {
	vector<string> u_names; // empty
	return u_names;
}

vector<double> resModSpec_directly_from_ModSpec_Element::fe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	double vpn = vecX[0];
	double R = this->parm_vals[0];

	vector<double> feout;
	feout += vpn / R;
	return feout;
}

vector<double> resModSpec_directly_from_ModSpec_Element::qe(vector<double>& vecX, vector<double>& vecY) {
	vector<double> qeout;
	qeout += 0.0;
	return qeout;
}

vector<double> resModSpec_directly_from_ModSpec_Element::fi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	vector<double> fiout;
	return fiout;
}

vector<double> resModSpec_directly_from_ModSpec_Element::qi(vector<double>& vecX, vector<double>& vecY) {
	vector<double> qiout;
	return qiout;
}

spMatrix resModSpec_directly_from_ModSpec_Element::dfe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(1, 1);
	J_OUT(0, 0) = 1.0;
	return J_OUT;
}
spMatrix resModSpec_directly_from_ModSpec_Element::dfe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	double R = this->parm_vals[0];
	spMatrix J_OUT(1, 1);
	J_OUT(0, 0) = 1.0 / R;
	return J_OUT;
}

spMatrix resModSpec_directly_from_ModSpec_Element::dqe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY) {
	spMatrix J_OUT(1, 1);
	return J_OUT;
}
spMatrix resModSpec_directly_from_ModSpec_Element::dqe_dvecX(vector<double>& vecX, vector<double>& vecY) {
	spMatrix J_OUT(1, 1);
	return J_OUT;
}

spMatrix resModSpec_directly_from_ModSpec_Element::dfi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(0, 1);
	return J_OUT;
}
spMatrix resModSpec_directly_from_ModSpec_Element::dfi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(0, 1);
	return J_OUT;
}

spMatrix resModSpec_directly_from_ModSpec_Element::dqi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY) {
	spMatrix J_OUT(0, 1);
	return J_OUT;
}
spMatrix resModSpec_directly_from_ModSpec_Element::dqi_dvecX(vector<double>& vecX, vector<double>& vecY) {
	spMatrix J_OUT(0, 1);
	return J_OUT;
}
		
spMatrix resModSpec_directly_from_ModSpec_Element::dfe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(1, 0);
	return J_OUT;
}
spMatrix resModSpec_directly_from_ModSpec_Element::dfe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(1, 0);
	return J_OUT;
}

spMatrix resModSpec_directly_from_ModSpec_Element::dqe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY) {
	spMatrix J_OUT(1, 0);
	return J_OUT;
}
spMatrix resModSpec_directly_from_ModSpec_Element::dqe_dvecY(vector<double>& vecX, vector<double>& vecY) {
	spMatrix J_OUT(1, 0);
	return J_OUT;
}

spMatrix resModSpec_directly_from_ModSpec_Element::dfi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(0, 0);
	return J_OUT;
}
spMatrix resModSpec_directly_from_ModSpec_Element::dfi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(0, 0);
	return J_OUT;
}

spMatrix resModSpec_directly_from_ModSpec_Element::dqi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY) {
	spMatrix J_OUT(0, 0);
	return J_OUT;
}
spMatrix resModSpec_directly_from_ModSpec_Element::dqi_dvecY(vector<double>& vecX, vector<double>& vecY) {
	spMatrix J_OUT(0, 0);
	return J_OUT;
}

spMatrix resModSpec_directly_from_ModSpec_Element::dfe_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(1, 0);
	return J_OUT;
}
spMatrix resModSpec_directly_from_ModSpec_Element::dfe_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(1, 0);
	return J_OUT;
}

spMatrix resModSpec_directly_from_ModSpec_Element::dfi_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(0, 0);
	return J_OUT;
}
spMatrix resModSpec_directly_from_ModSpec_Element::dfi_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	spMatrix J_OUT(0, 0);
	return J_OUT;
}


// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element* create() {
    return new resModSpec_directly_from_ModSpec_Element;
}

extern "C" void destroy(ModSpec_Element* p) {
    delete p;
}
