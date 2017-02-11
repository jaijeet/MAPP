#include "EbersMoll_BJT_ModSpec.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
EbersMoll_BJT_ModSpec::EbersMoll_BJT_ModSpec() {
	// model_name
	model_name = "Ebers Moll BJT";

	// element_name
	element_name = "undefined"; // TODO: should get is from outside

	// parm_names
	parm_names += "tipe", "Isf", "IsR", "VtF", "VtR", "alphaF", "alphaR", "Rshunt";

	// parm_defaultvals
	parm_defaultvals += 1, 1e-12, 1e-12, 0.025, 0.025, 0.99, 0.5, 1e8;

	// parm_vals
	parm_vals = parm_defaultvals;

	// - 'tipe'(type of the BJT): 1 for NPN, -1 for PNP
	// - 'IsF' (Is of forward diode): 1e-12
	// - 'IsR' (Is of reverse diode): 1e-12
	// - 'VtF' (Vt = kT/q of forward diode: 0.025
	// - 'VtR' (Vt = kT/q of reverse diode: 0.025
	// - 'alphaF' (forward alpha): 0.99
	// - 'alphaR' (reverse alpha): 0.5
	// - 'Rshunt' (shunt resistance): 1e8
	
	// node_names
	node_names += "c", "b", "e";
	
	// refnode_name
	refnode_name = "e";
	
	// explicit_output_names
	explicit_output_names += "ice", "ibe";

	// init/limiting
	limited_var_names += "vcelim", "vbelim";
	// [vcelim; vbelim] = eye(2) * [vce; vbe] when no init/limiting.
	vecXY_to_limited_vars_matrix.resize(2, 2, false);
	vecXY_to_limited_vars_matrix(0, 0) = 1.0;
	vecXY_to_limited_vars_matrix(1, 1) = 1.0;

	// the following function sets up refnode_index, io_names, otherio_names, io_types
	// io_nodenames, otherio_types, otherio_nodenames, otherio_nodeindices, explicit_output_types,
	// explicit_output_nodenames, and explicit_output_nodeindices.  It uses node_names, refnode_name and 
	// explicit_output_names - make sure these are set up correctly before calling it.
	setup_ios_otherios_types_nodenames_indices();
}

template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
  vector<TOUT> EbersMoll_BJT_ModSpec::fe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim, vector<TU>& vecU) {
	TX vce = vecX[0];
	TX vbe = vecX[1];
	TLIM vcelim = vecLim[0];
	TLIM vbelim = vecLim[1];

	int tipe = this->parm_vals[0];
	double IsF = this->parm_vals[1];
	double IsR = this->parm_vals[2];
	double VtF = this->parm_vals[3];
	double VtR = this->parm_vals[4];
	double alphaF = this->parm_vals[5];
	double alphaR = this->parm_vals[6];
	double Rshunt = this->parm_vals[7];

	vector<TOUT> out;

	// forward means C--B--E, reverse means E--B--C
	TOUT reverse_diode_i;
	TOUT forward_diode_i;
	if (1 == tipe) {
		reverse_diode_i = diode_Id<TOUT>(vbelim-vcelim, IsR, VtR);
		forward_diode_i = diode_Id<TOUT>(vbelim, IsF, VtF);
		// ice
		out += forward_diode_i*alphaF - reverse_diode_i + vce/Rshunt;
		// ibe
		out += forward_diode_i*(1-alphaF) + reverse_diode_i*(1-alphaR);
	} else if (1 == tipe) {
		reverse_diode_i = diode_Id<TOUT>(vcelim-vbelim, IsR, VtR);
		forward_diode_i = diode_Id<TOUT>(-vbelim, IsF, VtF);
		// ice
		out += - forward_diode_i*alphaF + reverse_diode_i + vce/Rshunt;
		// ibe
		out += - forward_diode_i*(1-alphaF) - reverse_diode_i*(1-alphaR);
	} else {
		fprintf(stderr, "EbersMoll_BJT_ModSpec: unsupported value for parameter ''tipe''. It should be either 1 (NPN) or -1 (PNP).\n");
		exit(1);
	}
	return out; 
}

template <typename TOUT, typename TX, typename TY, typename TLIM>
  vector<TOUT> EbersMoll_BJT_ModSpec::qe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim) {
	vector<TOUT> out;
	out += 0, 0;
	return out;
}

template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
  vector<TOUT> EbersMoll_BJT_ModSpec::fi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim, vector<TU>& vecU) {
	vector<TOUT> out;
	return out; 
}

template <typename TOUT, typename TX, typename TY, typename TLIM>
  vector<TOUT> EbersMoll_BJT_ModSpec::qi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim) {
	vector<TOUT> out;
	return out;
}

vector<double> EbersMoll_BJT_ModSpec::initGuess(vector<double>& vecU) {
	int tipe = this->parm_vals[0];
	double IsF = this->parm_vals[1];
	double IsR = this->parm_vals[2];
	double VtF = this->parm_vals[3];
	double VtR = this->parm_vals[4];
	double alphaF = this->parm_vals[5];
	double alphaR = this->parm_vals[6];
	double Rshunt = this->parm_vals[7];

    double vcritF = VtF*log(VtF/(sqrt(2)*IsF));
    double vcritR = VtR*log(VtR/(sqrt(2)*IsR));

	double vbc;
	double vbe;
	if (1 == tipe) {
		vbc = vcritR;
		vbe = vcritF;
	} else if (1 == tipe) {
		vbc = -vcritR;
		vbe = -vcritF;
	} else {
		fprintf(stderr, "EbersMoll_BJT_ModSpec: unsupported value for parameter ''tipe''. It should be either 1 (NPN) or -1 (PNP).\n");
		exit(1);
	}
	vector<double> vecLimInit;
	vecLimInit += vbe - vbc, vbe;
	return vecLimInit;
}

template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
  vector<TOUT> EbersMoll_BJT_ModSpec::limiting_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLimOld, vector<TU>& vecU) {
	int tipe = this->parm_vals[0];
	double IsF = this->parm_vals[1];
	double IsR = this->parm_vals[2];
	double VtF = this->parm_vals[3];
	double VtR = this->parm_vals[4];
	double alphaF = this->parm_vals[5];
	double alphaR = this->parm_vals[6];
	double Rshunt = this->parm_vals[7];

    double vcritF = VtF*log(VtF/(sqrt(2)*IsF));
    double vcritR = VtR*log(VtR/(sqrt(2)*IsR));

	TLIM vceold = vecLimOld[0];
	TLIM vbeold = vecLimOld[2];

    TX vce = vecX[0];
    TX vbe = vecX[1];

    TLIM vbcold = vbeold - vceold;
    TX vbc = vbe - vce;

	TLIM vbcnew;
	TLIM vbenew;
	if (1 == tipe) {
		vbcnew = pnjlim<TOUT>(vbcold, vbc, VtR, vcritR);
		vbenew = pnjlim<TOUT>(vbeold, vbe, VtF, vcritF);
	} else if (1 == tipe) {
		vbcnew = -pnjlim<TOUT>(-vbcold, -vbc, VtR, vcritR);
		vbenew = -pnjlim<TOUT>(-vbeold, -vbe, VtF, vcritF);
	} else {
		fprintf(stderr, "EbersMoll_BJT_ModSpec: unsupported value for parameter ''tipe''. It should be either 1 (NPN) or -1 (PNP).\n");
		exit(1);
	}
	// TODO: TX, TLIM should be the same for pnjlim to work

	vector<TOUT> vecLimNew;
	vecLimNew += vbenew - vbcnew, vbenew;
	return vecLimNew;
}

template <typename T>
  T EbersMoll_BJT_ModSpec::pnjlim(T vnew, T vold, double vt, double vcrit) {
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

template <typename T>
  T EbersMoll_BJT_ModSpec::diode_Id(T vd, double Is, double Vt) {
	return Is*(exp(vd/Vt) - 1.0);
}

// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element* create() {
    return new EbersMoll_BJT_ModSpec;
}

extern "C" void destroy(ModSpec_Element* p) {
    delete p;
}
