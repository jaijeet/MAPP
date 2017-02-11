#ifndef SIMPLEDIODEMODSPEC_DIRECTLY_FROM_MODSPEC_ELEMENT
#define SIMPLEDIODEMODSPEC_DIRECTLY_FROM_MODSPEC_ELEMENT

#include "ModSpec_Element.h"
#include "eeNIL.h"
#include "ublas_matrix_std_vector_ops.h" // defines prod(), add(), subtract() for vector<double>

class simpleDiodeModSpec_directly_from_ModSpec_Element : public ModSpec_Element {
	public:
		simpleDiodeModSpec_directly_from_ModSpec_Element();
		~simpleDiodeModSpec_directly_from_ModSpec_Element(){};

	private:
		vector<string> parm_names;
		vector<untyped> parm_defaultvals;
		vector<untyped> parm_vals; // used to store current values of parms

		int nvecX; // const
		int nvecY;
		int nvecZ;
		int nvecW;
		int nvecLim;
		
		double Is;
		double Vt;
		double R;

		string Vt_str;
		string Is_str;
		string R_str;

		spMatrix vecXY_to_limited_vars_matrix_stamp;
		spMatrix vecXY_to_limited_vars_matrix;
		spMatrix vecX_to_limited_vars_matrix_stamp;
		spMatrix vecX_to_limited_vars_matrix;
		spMatrix vecY_to_limited_vars_matrix_stamp;
		spMatrix vecY_to_limited_vars_matrix;

		double diode_Id(double Vd, double Is, double Vt);
		double diode_Gd(double Vd, double Is, double Vt);

		double pnjlim(double vnew, double vold, double vt, double vcrit);

	private:
		int findparm(string& parm); // used by getparm and setparm
		spMatrix to_stamp(const spMatrix& A);

	// override everything
	public:
		string ModelName();
		string ElementName();

		vector<string> parmnames();
		vector<string> paramnames();

		vector<untyped> parmdefaults();
		vector<untyped> paramdefaults();

		int nparms();
		int nparams();

		vector<untyped> getparms();
		vector<untyped> getparams();
		untyped getparm(string& parm);
		untyped getparam(string& parm);

		void setparms(vector<untyped>& a);
		void setparams(vector<untyped>& a);
		void setparm(string& parm, untyped& val);
		void setparam(string& parm, untyped& val);

		vector<string> IOnames();
		vector<string> ExplicitOutputNames();
		vector<string> OtherIONames();
		vector<string> InternalUnkNames();
		vector<string> ImplicitEquationNames();
		vector<string> uNames();

	public:
		// core model functions
		vector<double> fe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		vector<double> fi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		vector<double> qe(vector<double>& vecX, vector<double>& vecY);
		vector<double> qi(vector<double>& vecX, vector<double>& vecY);

	public:
		// jacobian stamps of core functions
		// ddX functions
		spMatrix dfe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dqe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY);
		spMatrix dqi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY);

		// ddY functions
		spMatrix dfe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dqe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY);
		spMatrix dqi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY);
		
		// ddU functions
		spMatrix dfe_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		
		// derivatives of core functions
		// ddX functions
		spMatrix dfe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dqe_dvecX(vector<double>& vecX, vector<double>& vecY);
		spMatrix dqi_dvecX(vector<double>& vecX, vector<double>& vecY);

		// ddY functions
		spMatrix dfe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dqe_dvecY(vector<double>& vecX, vector<double>& vecY);
		spMatrix dqi_dvecY(vector<double>& vecX, vector<double>& vecY);
		
		// ddU functions
		spMatrix dfe_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);

		// init/limiting flag
		bool support_initlimiting();

		// extra function fields related to init/limiting
		vector<string> LimitedVarNames();

		spMatrix vecXYtoLimitedVarsMatrix_stamp();
		spMatrix vecXYtoLimitedVarsMatrix();
		vector<double> vecXYtoLimitedVars(vector<double>& vecX, vector<double>& vecY);

		vector<double> initGuess(vector<double>& vecU);

		vector<double> limiting(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU);

		// core model functions with init/limiting
		vector<double> fe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		vector<double> fi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		vector<double> qe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
		vector<double> qi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);

		// jacobian stamps with init/limiting
		// ddvecX functions
		spMatrix dfe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dfi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dqe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
		spMatrix dqi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);

		// ddvecY functions
		spMatrix dfe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dfi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dqe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
		spMatrix dqi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
		
		// ddvecU functions
		spMatrix dfe_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dfi_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		
		// ddvecLim functions
		spMatrix dfe_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dfi_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dqe_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
		spMatrix dqi_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
		
		// derivatives with init/limiting
		// ddvecX functions
		spMatrix dfe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dfi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dqe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
		spMatrix dqi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);

		// ddvecY functions
		spMatrix dfe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dfi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dqe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
		spMatrix dqi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
		
		// ddvecU functions
		spMatrix dfe_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dfi_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);

		// ddvecLim functions
		spMatrix dfe_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dfi_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU);
		spMatrix dqe_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
		spMatrix dqi_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim);
};

#endif // SIMPLEDIODEMODSPEC_DIRECTLY_FROM_MODSPEC_ELEMENT
