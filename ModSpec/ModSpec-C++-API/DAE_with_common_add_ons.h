#ifndef DAE_WITH_COMMON_ADD_ONS_H
#define DAE_WITH_COMMON_ADD_ONS_H

#include "DAEAPI.h"

class  DAE_with_common_add_ons : public DAEAPI { // this is still an abstract base class
	public:
		DAE_with_common_add_ons(){};
		virtual ~DAE_with_common_add_ons(){}; 

	protected:
		string dae_name;
		string uniq_ID;
		string dae_version;

		vector<string> parm_names;
		vector<untyped> parm_defaultvals;
		vector<untyped> parm_vals; // used to store current values of parms

		vector<string> unk_names;
		vector<string> eqn_names;
		vector<string> input_names;
		vector<string> output_names;
		vector<string> NoiseSource_names;

		spMatrix Cmat;
		spMatrix Dmat;

	public:
		virtual string daename() {
			return dae_name;
		}

		virtual string uniqID() {
			return uniq_ID;
		}

		virtual string version() {
			return dae_version;
		}

		virtual int nparms() {
			return parm_names.size();
		}

		virtual vector<string> parmnames() {
			return parm_names;
		}

		virtual vector<untyped> parmdefaults() {
			return parm_defaultvals;
		}

		virtual vector<untyped> getparms() {
			return parm_vals;
		} 

		virtual untyped getparm(string& parm) {
			untyped retval;
			int idx = findparm(parm);
			retval = parm_vals[idx];
            return retval;
		}

		virtual void setparms(vector<untyped>& a) { // simplest incarnation, needs updates
			parm_vals = a;
		}

		virtual void setparm(string& parm, untyped& val) {
			int idx = findparm(parm);
			parm_vals[idx] = val;
		}

		virtual int nunks() {
			return unk_names.size();
		}

		virtual int neqns() {
			return eqn_names.size();
		}

		virtual int ninputs() {
			return input_names.size();
		}

		virtual int noutputs() {
			return output_names.size();
		}

		virtual int nNoiseSources() {
			return NoiseSource_names.size();
		}

		virtual vector<string> unknames() {
			return unk_names;
		}

		virtual vector<string> eqnnames() {
			return eqn_names;
		}

		virtual vector<string> inputnames() {
			return input_names;
		}

		virtual vector<string> outputnames() {
			return output_names;
		}

		virtual vector<string> NoiseSourcenames() {
			return NoiseSource_names;
		}

		virtual spMatrix C() {
			return Cmat;
		}

		virtual spMatrix D() {
			return Dmat;
		}

		int findparm(string& parm) { // 
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
};

#endif // DAE_WITH_COMMON_ADD_ONS_H
