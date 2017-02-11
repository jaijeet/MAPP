#ifndef EE_MODEL
#define EE_MODEL

#include "ModSpec_Element.h"
#include "eeNIL.h"

class ee_model : public ModSpec_Element { // this is a still an abstract base class
	public:
		ee_model(){};
		virtual ~ee_model(){};
		
	protected:
		string model_name;
		string element_name;

		vector<string> parm_names;
		vector<untyped> parm_defaultvals;
		vector<untyped> parm_vals; // used to store current values of parms

		// TODO:
		// vector<string> parm_descriptions; // longer description of each parameter
		// vector<string> parm_units; // single-word string used to denote the units

		vector<string> node_names; // NIL quantity
		string refnode_name; 	   // NIL quantity

		vector<string> io_names;
		vector<string> explicit_output_names;
		vector<string> otherio_names;
		vector<string> internal_unk_names;
		vector<string> implicit_equation_names;
		vector<string> u_names;

		// the following function sets up refnode_index, io_names, otherio_names, io_types
		// io_nodenames, otherio_types, otherio_nodenames, otherio_nodeindices, explicit_output_types,
		// explicit_output_nodenames, and explicit_output_nodeindices.  It uses node_names, refnode_name and 
		// explicit_output_names - make sure these are set up correctly before calling it.
		void setup_ios_otherios_types_nodenames_indices() {
			// set up a list of non-refnode node names
			vector<string> nonref_nodenames = node_names;
			int nnodes = node_names.size(); // of which one is the reference node
			for (int i=0; i<nnodes; i++) {
				if (0 == strcmp(refnode_name.c_str(), node_names[i].c_str())) {
					nonref_nodenames.erase(nonref_nodenames.begin() + i);
					break;
				}
			}

			// set up io_names from node_names and refnode_name
			vector<string> io_types;
			vector<string> io_nodenames;
			// stringstream sstrV, sstrI;
			for (int i=0; i<nnodes-1; i++) {
				string nname = nonref_nodenames[i];
				io_names.push_back("v" + nname + refnode_name);
				io_types.push_back("v");
				io_nodenames.push_back(nname);
			}
			// separate loop for the is, since they come after all the vs
			for (int i=0; i<nnodes-1; i++) {
				string nname = nonref_nodenames[i];
				io_names.push_back("i" + nname + refnode_name);
				io_types.push_back("i");
				io_nodenames.push_back(nname);
			}

			// set up otherio_names by excluding explicit_output_names from io_names
			int neos = explicit_output_names.size();
			otherio_names = io_names;
			vector<string>::iterator vsIter; // std::find returns this type
				// see http://www.cprogramming.com/tutorial/stl/iterators.html
			for (int i=0; i<neos; i++) {
				vsIter = find(otherio_names.begin(), otherio_names.end(), explicit_output_names[i]);
				if (vsIter != otherio_names.end()) {
					// found; delete it
					otherio_names.erase(vsIter);
				} else {
					fprintf(stderr, "explicit output %s not found in IOnames\n", explicit_output_names[i].c_str());
				}
			}

			// fprintf(stdout, "node_names: \n"); print_vector_of_strings(node_names);
			// fprintf(stdout, "explicit_output_names: \n"); print_vector_of_strings(explicit_output_names);
			NILp = new eeNIL_with_common_add_ons(node_names, refnode_name, explicit_output_names);
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

	public:
		virtual string ModelName() {
			return model_name;
		}

		virtual string ElementName() {
			return element_name;
		}

		virtual vector<string> parmnames() {
			return parm_names;
		}
		virtual vector<string> paramnames() {
			return parm_names;
		}

		virtual vector<untyped> parmdefaults() {
			return parm_defaultvals;
		}
		virtual vector<untyped> paramdefaults() {
			return parm_defaultvals;
		}
		virtual int nparms() {
			return parm_names.size();
		}
		virtual int nparams() {
			return parm_names.size();
		}

		// TODO:
		// virtual vector<string> parmdescriptions() {
		// 	return parm_descriptions;
		// }
		// virtual vector<string> paramdescriptions() {
		// 	return parm_descriptions;
		// }
		//
		// virtual vector<string> parmunits() {
		// 	return parm_units;
		// }
		// virtual vector<string> paramunits() {
		// 	return parm_units;
		// }

		virtual vector<untyped> getparms() {
			return parm_vals;
		} 
		virtual vector<untyped> getparams() {
			return parm_vals;
		} 

		virtual untyped getparm(string& parm) {
			untyped retval;
			int idx = findparm(parm);
			retval = parm_vals[idx];
            return retval;
		}
		virtual untyped getparam(string& parm) {
			return getparm(parm);
		}

		virtual void setparms(vector<untyped>& a) { // simplest incarnation, needs updates
			parm_vals = a;
		}
		virtual void setparams(vector<untyped>& a) { // simplest incarnation, needs updates
			parm_vals = a;
		}

		virtual void setparm(string& parm, untyped& val) {
			int idx = findparm(parm);
			parm_vals[idx] = val;
		}
		virtual void setparam(string& parm, untyped& val) {
			setparm(parm, val);
		}

		virtual vector<string> IOnames() { 
			return io_names;
		}

		virtual vector<string> ExplicitOutputNames() {
			return explicit_output_names;
		}

		virtual vector<string> OtherIONames() { 
			return otherio_names;
		}

		virtual vector<string> InternalUnkNames() {
			return internal_unk_names;
		}

		virtual vector<string> ImplicitEquationNames() {
			return implicit_equation_names;
		}

		virtual vector<string> uNames() {
			return u_names;
		}
};

#endif // EE_MODEL
