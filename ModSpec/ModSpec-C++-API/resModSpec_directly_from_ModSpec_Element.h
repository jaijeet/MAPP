#ifndef RESMODSPEC_DIRECTLY_FROM_MODSPEC_ELEMENT
#define RESMODSPEC_DIRECTLY_FROM_MODSPEC_ELEMENT

#include "ModSpec_Element.h"
#include "eeNIL.h"

class resModSpec_directly_from_ModSpec_Element : public ModSpec_Element {
	public:
		resModSpec_directly_from_ModSpec_Element();
		~resModSpec_directly_from_ModSpec_Element(){};

	private:
		vector<string> parm_names;
		vector<untyped> parm_defaultvals;
		vector<untyped> parm_vals; // used to store current values of parms

	private:
		int findparm(string& parm); // used by getparm and setparm

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
};

#endif // RESMODSPEC_DIRECTLY_FROM_MODSPEC_ELEMENT
