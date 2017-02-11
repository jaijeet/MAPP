#ifndef MODSPEC_ELEMENT_WITH_COMMON_ADD_ONS
#define MODSPEC_ELEMENT_WITH_COMMON_ADD_ONS

#include "ModSpec_Element.h"

class ModSpec_Element_with_common_add_ons : public ModSpec_Element { // this is a still an abstract base class
	protected:
		string name;

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

		vector<string> io_types;     // NIL quantity
		vector<string> io_nodenames; // NIL quantity
		vector<string> otherio_types;     // NIL quantity
		vector<string> otherio_nodenames; // NIL quantity
		vector<int> otherio_nodeindices; // NIL quantity
		vector<string> explicit_output_types; // NIL quantity
		vector<string> explicit_output_nodenames; // NIL quantity
		vector<int> explicit_output_nodeindices; // NIL quantity

		// the following function sets up refnode_index, io_names, otherio_names, io_types
		// io_nodenames, otherio_types, otherio_nodenames, otherio_nodeindices, explicit_output_types,
		// explicit_output_nodenames, and explicit_output_nodeindices.  It uses node_names, refnode_name and 
		// explicit_output_names - make sure these are set up correctly before calling it.
		void setup_ios_otherios_types_nodenames_indices(){
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
			// stringstream sstrV, sstrI;
			for (int i=0; i<nnodes-1; i++) {
				string nname = nonref_nodenames[i];
				/*
				sprintf((char*) sstrV, "v%s%s", nname.c_str(), refnode_name.c_str());
				sprintf(sstrI, "i%s%s", nname.c_str(), refnode_name.c_str());
				*/
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
			
			// go through explicit_output_names and set up explicit_output_types and explicit_output_nodenames
			for (int i=0; i < explicit_output_names.size(); i++) {
				string eoname = explicit_output_names[i];
				// find the index of eoname in io_names. It should be unique.
				// this is a horrible linear complexity way of doing it, but don't know how to do it with
				// constant complexity in a few lines.
				int idx; for (idx = 0; (idx < io_names.size()) && (io_names[idx] != eoname); idx++);
				if (idx == io_names.size()) {
					fprintf(stdout, "error: explicit output %s not found in io_names\n", eoname.c_str());
					exit(1);
				}
				explicit_output_types.push_back(io_types[idx]);
				explicit_output_nodenames.push_back(io_nodenames[idx]);

				// now find the index of the node in the node_names list - in the same inefficient way
				int idx2; for (idx2 = 0; (idx2 < node_names.size()) && (node_names[idx2] != io_nodenames[idx]); idx2++);
				if (idx2 == node_names.size()) {
					fprintf(stdout, "error: node name %s not found in node_names\n", io_nodenames[idx].c_str());
					exit(1);
				}
				explicit_output_nodeindices.push_back(idx2);
			}
			
			// go through otherio_names and set up otherio_types, otherio_nodenames and otherio_nodeindices
			for (int i=0; i < otherio_names.size(); i++) {
				string oioname = otherio_names[i];
				// find the index of oioname in io_names. It should be unique.
				// this is a horrible linear complexity way of doing it, but don't know how to do it with
				// constant complexity in a few lines.
				int idx; for (idx = 0; (idx < io_names.size()) && (io_names[idx] != oioname); idx++);
				if (idx == io_names.size()) {
					fprintf(stdout, "error: otherio %s not found in io_names\n", oioname.c_str());
					exit(1);
				}
				otherio_types.push_back(io_types[idx]);
				otherio_nodenames.push_back(io_nodenames[idx]);
				
				// now find the index of the node in the node_names list - in the same inefficient way
				int idx2; for (idx2 = 0; (idx2 < node_names.size()) && (node_names[idx2] != io_nodenames[idx]); idx2++);
				if (idx2 == node_names.size()) {
					fprintf(stdout, "error: node name %s not found in node_names\n", io_nodenames[idx].c_str());
					exit(1);
				}
				otherio_nodeindices.push_back(idx2);
			}

			// set up refnode_index - same horrible inefficient way
			int idx2; for (idx2 = 0; (idx2 < node_names.size()) && (node_names[idx2] != refnode_name); idx2++);
			if (idx2 == node_names.size()) {
				fprintf(stdout, "error: reference node %s not found in node_names\n", refnode_name.c_str());
				exit(1);
			}
			refnode_index = idx2;
		}; 

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
		ModSpec_with_common_add_ons(){};
		// TODO: ModSpec_with_common_add_ons(string& name) : name(name) {}; // alternative constructor
		~ModSpec_with_common_add_ons(){};
		
		// TODO:
		// 1. copy constructor
		// 2. operator=
		// 3. other operators?

		virtual vector<string> parmnames() {
			return parm_names;
		};
		virtual vector<string> paramnames() {
			return parm_names;
		};

		virtual vector<untyped> parmdefaults() {
			return parm_defaultvals;
		};
		virtual vector<untyped> paramdefaults() {
			return parm_defaultvals;
		};

		// TODO:
		// virtual vector<string> parmdescriptions() {
		// 	return parm_descriptions;
		// };
		// virtual vector<string> paramdescriptions() {
		// 	return parm_descriptions;
		// };
		//
		// virtual vector<string> parmunits() {
		// 	return parm_units;
		// };
		// virtual vector<string> paramunits() {
		// 	return parm_units;
		// };

		virtual vector<untyped> getparms() {
			return parm_vals;
		}; 
		virtual vector<untyped> getparams() {
			return parm_vals;
		}; 

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
			setparm(string& parm, untyped& val);
		}

		virtual vector<string> IOnames() { 
			return io_names;
		};

		virtual vector<string> ExplicitOutputNames() {
			return explicit_output_names;
		};

		virtual vector<string> OtherIOnames() { 
			return otherio_names;
		};

		virtual vector<string> InternalUnkNames() {
			return internal_unk_names;
		};

		virtual vector<string> ImplicitEquationNames() {
			return implicit_equation_names;
		};

		virtual vector<string> Unames() {
			return u_names;
		};

		/*
			virtual vector<string> NIL_NodeNames() {
				return node_names;
			}; 
			virtual string NIL_RefNodeName() {
				// helper data: the index (into NIL_NodeNames) of the reference node
				return refnode_name;
			};
			virtual int NIL_RefNodeIndex() {
				return refnode_index;
			};
			virtual vector<string> NIL_IOtypes() {
				return io_types;
			};
			virtual vector<string> NIL_IONodeNames() {
				return io_nodenames;
			};
			virtual vector<string> NIL_ExplicitOutputTypes() {
				// helper data: types of the explicit outputs
				return explicit_output_types;
			};
			virtual vector<string> NIL_ExplicitOutputNodeNames() {
				// helper data: the node name corresponding to each explicit output
				return explicit_output_nodenames;
			};
			virtual vector<int> NIL_ExplicitOutputNodeIndices() {
				// helper data: the index (into NIL_NodeNames) of the node name corresponding to each explicit output
				return explicit_output_nodeindices;
			};
			virtual vector<string> NIL_OtherIOtypes() {
				// helper data: types of the otherIOs
				return otherio_types;
			};
			virtual vector<string> NIL_OtherIONodeNames() {
				// helper data: the node name corresponding to each otherIO
				return otherio_nodenames;
			};
			virtual vector<int> NIL_OtherIONodeIndices() {
				// helper data: the index (into NIL_NodeNames) of the node name corresponding to each otherIO
				return otherio_nodeindices;
			};
		*/
};


#endif // MODSPEC_WITH_COMMON_ADD_ONS
