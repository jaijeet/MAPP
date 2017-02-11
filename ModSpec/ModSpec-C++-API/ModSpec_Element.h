#ifndef MODSPEC_ELEMENT
#define MODSPEC_ELEMENT

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <algorithm>
#include <sstream>
#include "untyped.h"
#include <vector> // std::vector
#include "sacado_typedefs.h"
#include "boost_ublas_includes_typedefs.h" // definition spMatrix == boost::numeric::ublas::mapped_matrix
#include "NetworkInterfaceLayer.h"

using namespace std; // needed to disambiguate std::vector from boost::numeric::ublas::vector

class ModSpec_Element { // this is an abstract base class that defines ModSpec API
	public:
		ModSpec_Element(){};
		virtual ~ModSpec_Element() {
			delete NILp;
		};
		
		// TODO:
		// 1. copy constructor
		// 2. operator=
		// 3. other operators?

		virtual string ModelName() = 0;
		virtual string ElementName() = 0; // TODO: called .name in the MATLAB version

		virtual vector<string> parmnames() = 0;
		virtual vector<string> paramnames() = 0;

		virtual vector<untyped> parmdefaults() = 0;
		virtual vector<untyped> paramdefaults() = 0;

		virtual int nparms() = 0;
		virtual int nparams() = 0;

		// TODO:
		// virtual vector<string> parmdescriptions() = 0;
		// virtual vector<string> paramdescriptions() = 0;
		// virtual vector<string> parmunits() = 0;
		// virtual vector<string> paramunits() = 0;

		virtual vector<untyped> getparms() = 0;
		virtual vector<untyped> getparams() = 0;
		virtual untyped getparm(string& parm) = 0;
		virtual untyped getparam(string& parm) = 0;

		virtual void setparms(vector<untyped>& a) = 0;
		virtual void setparams(vector<untyped>& a) = 0;
		virtual void setparm(string& parm, untyped& val) = 0;
		virtual void setparam(string& parm, untyped& val) = 0;

		virtual vector<string> IOnames() = 0;
		virtual vector<string> ExplicitOutputNames() = 0;
		virtual vector<string> OtherIONames() = 0;
		virtual vector<string> InternalUnkNames() = 0;
		virtual vector<string> ImplicitEquationNames() = 0;
		virtual vector<string> uNames() = 0;

	public:
        NetworkInterfaceLayer* NILp;
        // NetworkInterfaceLayer NIL;

	public:
		// core model functions
		virtual vector<double> fe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual vector<double> fi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual vector<double> qe(vector<double>& vecX, vector<double>& vecY) = 0;
		virtual vector<double> qi(vector<double>& vecX, vector<double>& vecY) = 0;

	public:
		// jacobian stamps of core functions
		// ddX functions
		virtual spMatrix dfe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual spMatrix dqe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY) = 0;
		virtual spMatrix dqi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY) = 0;

		// ddY functions
		virtual spMatrix dfe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual spMatrix dqe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY) = 0;
		virtual spMatrix dqi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY) = 0;
		
		// ddU functions
		virtual spMatrix dfe_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		
		// derivatives of core functions
		// ddX functions
		virtual spMatrix dfe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual spMatrix dqe_dvecX(vector<double>& vecX, vector<double>& vecY) = 0;
		virtual spMatrix dqi_dvecX(vector<double>& vecX, vector<double>& vecY) = 0;

		// ddY functions
		virtual spMatrix dfe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual spMatrix dqe_dvecY(vector<double>& vecX, vector<double>& vecY) = 0;
		virtual spMatrix dqi_dvecY(vector<double>& vecX, vector<double>& vecY) = 0;
		
		// ddU functions
		virtual spMatrix dfe_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) = 0;


	public:
		// init/limiting flag, default is false
		virtual bool support_initlimiting() {
			return false;
		};

	public:
		// extra function fields related to init/limiting, default is no limited variables.
		virtual vector<string> LimitedVarNames() {
			return vector<string>();
		}

		virtual spMatrix vecXYtoLimitedVarsMatrix_stamp() {
			int nvecX = OtherIONames().size();
			int nvecY = InternalUnkNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecLim, nvecX+nvecY);
			return J_OUT;
		}
		virtual spMatrix vecXYtoLimitedVarsMatrix() {
			int nvecX = OtherIONames().size();
			int nvecY = InternalUnkNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecLim, nvecX+nvecY);
			return J_OUT;
		}

		virtual vector<double> vecXYtoLimitedVars(vector<double>& vecX, vector<double>& vecY) {
			return vector<double>();
		}

		virtual vector<double> initGuess(vector<double>& vecU) {
			return vector<double>();
		}

		virtual vector<double> limiting(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU) {
			return vector<double>();
		}

		virtual spMatrix dlimiting_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU) {
		// for use in an obsolete NR method that is not working, shouldn't be used anywhere now
			int nvecX = OtherIONames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecLim, nvecX);
			return J_OUT;
		}
		virtual spMatrix dlimiting_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU) {
		// for use in an obsolete NR method that is not working, shouldn't be used anywhere now
			int nvecX = OtherIONames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecLim, nvecX);
			return J_OUT;
		}
		virtual spMatrix dlimiting_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU) {
		// for use in an obsolete NR method that is not working, shouldn't be used anywhere now
			int nvecY = InternalUnkNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecLim, nvecY);
			return J_OUT;
		}
		virtual spMatrix dlimiting_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU) {
		// for use in an obsolete NR method that is not working, shouldn't be used anywhere now
			int nvecY = InternalUnkNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecLim, nvecY);
			return J_OUT;
		}

	public:
		// core model functions with init/limiting
		virtual vector<double> fe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return fe(vecX, vecY, vecU);
		}
		virtual vector<double> fi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return fi(vecX, vecY, vecU);
		}
		virtual vector<double> qe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return qe(vecX, vecY);
		}
		virtual vector<double> qi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return qi(vecX, vecY);
		}

		// jacobian stamps with init/limiting
		// ddvecX functions
		virtual spMatrix dfe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfe_dvecX_stamp(vecX, vecY, vecU);
		}
		virtual spMatrix dfi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfi_dvecX_stamp(vecX, vecY, vecU);
		}
		virtual spMatrix dqe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return dqe_dvecX_stamp(vecX, vecY);
		}
		virtual spMatrix dqi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return dqi_dvecX_stamp(vecX, vecY);
		}

		// ddvecY functions
		virtual spMatrix dfe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfe_dvecY_stamp(vecX, vecY, vecU);
		}
		virtual spMatrix dfi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfi_dvecY_stamp(vecX, vecY, vecU);
		}
		virtual spMatrix dqe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return dqe_dvecY_stamp(vecX, vecY);
		}
		virtual spMatrix dqi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return dqi_dvecY_stamp(vecX, vecY);
		}
		
		// ddvecU functions
		virtual spMatrix dfe_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfe_dvecU_stamp(vecX, vecY, vecU);
		}
		virtual spMatrix dfi_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfi_dvecU_stamp(vecX, vecY, vecU);
		}
		
		// ddvecLim functions
		virtual spMatrix dfe_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			int nvecZ = ExplicitOutputNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecZ, nvecLim);
			return J_OUT;
		}
		virtual spMatrix dfi_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			int nvecW = ImplicitEquationNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecW, nvecLim);
			return J_OUT;
		}
		virtual spMatrix dqe_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			int nvecZ = ExplicitOutputNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecZ, nvecLim);
			return J_OUT;
		}
		virtual spMatrix dqi_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			int nvecW = ImplicitEquationNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecW, nvecLim);
			return J_OUT;
		}
		
		// derivatives with init/limiting
		// ddvecX functions
		virtual spMatrix dfe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfe_dvecX(vecX, vecY, vecU);
		}
		virtual spMatrix dfi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfi_dvecX(vecX, vecY, vecU);
		}
		virtual spMatrix dqe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return dqe_dvecX(vecX, vecY);
		}
		virtual spMatrix dqi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return dqi_dvecX(vecX, vecY);
		}

		// ddvecY functions
		virtual spMatrix dfe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfe_dvecY(vecX, vecY, vecU);
		}
		virtual spMatrix dfi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfi_dvecY(vecX, vecY, vecU);
		}
		virtual spMatrix dqe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return dqe_dvecY(vecX, vecY);
		}
		virtual spMatrix dqi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return dqi_dvecY(vecX, vecY);
		}
		
		// ddvecU functions
		virtual spMatrix dfe_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfe_dvecU(vecX, vecY, vecU);
		}
		virtual spMatrix dfi_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfi_dvecU(vecX, vecY, vecU);
		}

		// ddvecLim functions
		virtual spMatrix dfe_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			int nvecZ = ExplicitOutputNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecZ, nvecLim);
			return J_OUT;
		}
		virtual spMatrix dfi_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			int nvecW = ImplicitEquationNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecW, nvecLim);
			return J_OUT;
		}
		virtual spMatrix dqe_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			int nvecZ = ExplicitOutputNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecZ, nvecLim);
			return J_OUT;
		}
		virtual spMatrix dqi_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			int nvecW = ImplicitEquationNames().size();
			int nvecLim = LimitedVarNames().size();
			spMatrix J_OUT(nvecW, nvecLim);
			return J_OUT;
		}
};

// the types of the class factories, used for enabling dlopen 
typedef ModSpec_Element *create_t();
typedef void destroy_t(ModSpec_Element*);

#endif // MODSPEC_ELEMENT
