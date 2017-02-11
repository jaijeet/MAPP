#include "diodeModSpec.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
diodeModSpec::diodeModSpec() {
	// model_name
	model_name = "Diode";

	// element_name
	element_name = "undefined"; // TODO: should get is from outside

	// parm_names
	parm_names += "Vt", "Is", "R";
	
	// parm_defaultvals
	parm_defaultvals += 0.026, 1.0e-12, 1000.0;

	// parm_vals
	parm_vals = parm_defaultvals;

	// node_names
	node_names += "p", "n";
	
	// refnode_name
	refnode_name = "n";
	
	// explicit_output_names
	explicit_output_names += "ipn";

	// internal_unk_names
	internal_unk_names += "vin";

	// implicit_equation_names
	implicit_equation_names += "KCL_i";
	
	// init/limiting
	limited_var_names += "vinlim";
	vecXY_to_limited_vars_matrix.resize(1, 2, false);
	vecXY_to_limited_vars_matrix(0, 1) = 1.0;

	// the following function sets up refnode_index, io_names, otherio_names, io_types
	// io_nodenames, otherio_types, otherio_nodenames, otherio_nodeindices, explicit_output_types,
	// explicit_output_nodenames, and explicit_output_nodeindices.  It uses node_names, refnode_name and 
	// explicit_output_names - make sure these are set up correctly before calling it.
	setup_ios_otherios_types_nodenames_indices();
}

template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
  vector<TOUT> diodeModSpec::fe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim, vector<TU>& vecU) {
	TX vpn = vecX[0];
	TY vin = vecY[0];
	double R = this->parm_vals[2];
	vector<TOUT> out;
	out += (vpn - vin)/R;
	return out; 
}

template <typename TOUT, typename TX, typename TY, typename TLIM>
  vector<TOUT> diodeModSpec::qe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim) {
	vector<TOUT> out;
	out += 0;
	return out;
}

template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
  vector<TOUT> diodeModSpec::fi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim, vector<TU>& vecU) {
	TX vpn = vecX[0];
	TY vin = vecY[0];
	TLIM vinlim = vecLim[0];

	double Vt = this->parm_vals[0];
	double Is = this->parm_vals[1];
	double R = this->parm_vals[2];

	vector<TOUT> out;
	out += - Is * (exp(vinlim/Vt) - 1) + (vpn - vin)/R;
	return out; 
}

template <typename TOUT, typename TX, typename TY, typename TLIM>
  vector<TOUT> diodeModSpec::qi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim) {
	vector<TOUT> out;
	out += 0;
	return out;
}

vector<double> diodeModSpec::initGuess(vector<double>& vecU) {
	double Vt = this->parm_vals[0];
	double Is = this->parm_vals[1];
	double Vcrit = Vt * log( Vt / (sqrt(2)*Is));
	vector<double> vecLimInit;
	vecLimInit += Vcrit;
	return vecLimInit;
}

template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
  vector<TOUT> diodeModSpec::limiting_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLimOld, vector<TU>& vecU) {
	double Vt = this->parm_vals[0];
	double Is = this->parm_vals[1];
	double Vcrit = Vt * log( Vt / (sqrt(2)*Is));

	TY vin = vecY[0];
	TLIM vinlimOld = vecLimOld[0];

	TLIM vinlimNew = pnjlim<TY>(vin, vinlimOld, Vt, Vcrit);
	// TODO: TY, TLIM should be the same for pnjlim to work

	vector<TOUT> vecLimNew;
	vecLimNew += vinlimNew;
	return vecLimNew;
}

template <typename T>
  T diodeModSpec::pnjlim(T vnew, T vold, double vt, double vcrit) {
// from DEVpnjlim in devsup.c in ngspice-24
// TODO: create some kind of devsup for MAPP 
    T arg;

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
    return new diodeModSpec;
}

extern "C" void destroy(ModSpec_Element* p) {
    delete p;
}
