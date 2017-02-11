#ifndef EENIL
#define EENIL

#include "NetworkInterfaceLayer.h"

using namespace std; // needed to disambiguate std::vector from boost::numeric::ublas::vector

class eeNIL : public NetworkInterfaceLayer { // this is a pure abstract base class that defines eeNIL
	public:
		eeNIL(){};
		~eeNIL(){};
		
		// TODO:
		// 1. copy constructor
		// 2. operator=
		// 3. other operators?

	public:
		virtual string RefNodeName() = 0;
};

class eeNIL_with_common_add_ons : public eeNIL {
	public:
		eeNIL_with_common_add_ons(){};

		eeNIL_with_common_add_ons(
			vector<string>& node_names,
			string& refnode_name, 
			vector<string>& explicit_output_names) :
				node_names(node_names),
				refnode_name(refnode_name)
		{
			// the code below in the constructor should set up:
			// 		io_names;
			// 		io_types;
			// 		io_nodenames;
			// 		refnode_index;
			// 		explicit_output_types;
			// 		explicit_output_nodenames;
			// 		explicit_output_nodeindices;
			// 		// otherio_names;
			// 		otherio_types;
			// 		otherio_nodenames;
			// 		otherio_nodeindices;

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
			vector<string> otherio_names = io_names;
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
		~eeNIL_with_common_add_ons(){};

		
		// TODO:
		// 1. copy constructor
		// 2. operator=
		// 3. other operators?

	public:
        // override functions in NetworkInterfaceLayer
		virtual vector<string> NodeNames() {
			return node_names;
		}; 
		virtual vector<string> IOnames() {
			return io_names;
		};
		virtual vector<string> IOtypes() {
			return io_types;
		};
		virtual vector<string> IONodeNames() {
			return io_nodenames;
		};

        // functions specific to EE
		virtual string RefNodeName() {
			return refnode_name;
		};

	public:
        // extra helper functions specific to EE. I will get rid of them gradually.
		virtual int RefNodeIndex() {
			return refnode_index;
		};
		virtual vector<string> ExplicitOutputTypes() {
			return explicit_output_types;
		};
		virtual vector<string> ExplicitOutputNodeNames() {
			return explicit_output_nodenames;
		};
		virtual vector<int> ExplicitOutputNodeIndices() {
			return explicit_output_nodeindices;
		};
		virtual vector<string> OtherIOtypes() {
			return otherio_types;
		};
		virtual vector<string> OtherIONodeNames() {
			return otherio_nodenames;
		};
		virtual vector<int> OtherIONodeIndices() {
			return otherio_nodeindices;
		};

	private:
		vector<string> node_names;
		vector<string> io_names;
		vector<string> io_types;
		vector<string> io_nodenames;

	private:
		string refnode_name;

	private:
		int refnode_index;
		vector<string> explicit_output_types;
		vector<string> explicit_output_nodenames;
		vector<int> explicit_output_nodeindices;
		vector<string> otherio_types;
		vector<string> otherio_nodenames;
		vector<int> otherio_nodeindices;
};

#endif // EENIL
