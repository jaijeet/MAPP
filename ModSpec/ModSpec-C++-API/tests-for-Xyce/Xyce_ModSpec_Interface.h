#ifndef XYCE_MODSPEC_INTERFACE_H
#define XYCE_MODSPEC_INTERFACE_H
#include "dynloaded_ModSpec_Element.h"
#include "vector_print.h"
#include "ublas_matrix_std_vector_ops.h" // defines prod(), add(), subtract() for vector<double>
#include "eeNIL.h"

namespace XMI_local {
	// virtual base class for enabling callback to N_LAS_Matrix::returnRawEntryPointer();
  	class _rREPclassGeneric {
		public:
			virtual double* returnRawEntryPointer(int i, int j)=0;
	};
};

class Xyce_ModSpec_Interface {
	public:
		Xyce_ModSpec_Interface(string so_name);
		~Xyce_ModSpec_Interface();

		// // // // // // //
		// data
		string soName; // the ModSpec .so file's name
		dynloaded_ModSpec_Element* elSoPtr;
		ModSpec_Element* ModSpecElPtr;
		NetworkInterfaceLayer* NILp;
		eeNIL_with_common_add_ons* eeNILp;

		// unk/eqn counts
		int n; // ModSpec's n - half the number of IOs
		int l; // ModSpec's l - ExplicitIOs
		int l_v; // ModSpec's l_v - number of ExplicitIOs of type 'v'
		int m; // ModSpec's m - number of InternalUnks
		int numExtVars; // Xyce's numExtVars
		int numIntVars; // Xyce's numIntVars
		int nl; // ModSpec's nlimitedvars

		// "incidence matrices" = see Xyce_ModSpec_Notes.txt
		spMatrix A_E;
		spMatrix A_I;
		spMatrix A_Xi;
		spMatrix A_Zi;
		spMatrix A_Xv;
		spMatrix A_Zv;
		
		// F and Q Jacobian stamps 
		spMatrix jacStamp_f;
		spMatrix jacStamp_q;

		// Xyce's F and Q Jacobian stamps 
		vector<vector<int> > jacStamp_Xyce_f;
		vector<vector<int> > jacStamp_Xyce_q;

		// Xyce's Jacobian stamp
		vector<vector<int> > jacStamp_Xyce_fq;

		// parameter name and value lists
		// in Xyce Instance constructor, simply call addPar on
		// each of these elements
		vector<double> doubleParms;  // Eric: this might not work with CompositeParms
		// double* doubleParms; // Eric: this might - but not clear yet
		vector<string> doubleParmNames;
		// string* doubleParmNames
		vector<int> intParms; 
		vector<string> intParmNames;
		vector<string> stringParms;
		vector<string> stringParmNames;

		// unk/eqn indices to LID maps
		vector<int> unkidx_to_LID_map;
		vector<int> eqnidx_to_LID_map;

		// matrices to store pointers to Jacobian entries
		// (these are set up outside this class)
		spMatrix_doubleptr dFdxMat_ptrs;
		spMatrix_doubleptr dQdxMat_ptrs;

		// f/q/Jf/Jq: computed and cached
		vector<double> f;
		vector<double> q;
		spMatrix jac_f;
		spMatrix jac_q;
        // vecLimNew: computed and cached
		vector<double> vecLimNew;

		// // // // // // //
		// methods (see comments/descriptions in .C file)
		void compute_fq(/* inputs */ vector<double>& vecE, vector<double>& vecI, vector<double>& vecY,
			vector<double>& vecSto, bool do_init=0, bool do_limiting=0);
		void compute_jac_fq(/* inputs */ vector<double>& vecE, vector<double>& vecI, vector<double>& vecY,
			vector<double>& vecSto, bool do_init=false, bool do_limiting=false, bool stampsonly=false);
		void setup_typedParmLists(const vector<untyped>& parmvals); // 2012/12/14: probably don't need these any more
		void set_ModSpec_parms_from_typedParmLists();
		void setup_eqnunkidx_to_LID_maps(const vector<int>& extLIDVec, const vector<int>& intLIDVec);
		void vecEIY_from_solVec(/* outputs */ vector<double>& vecE, vector<double>& vecI, vector<double>& vecY,
		                        /* inputs */ double* solVec);
		
	public:
		void setup_dFQdxMat_ptrs(XMI_local::_rREPclassGeneric& rREP_F, XMI_local::_rREPclassGeneric& rREP_Q);
	protected:
		// // // // // // //
		// methods (see comments/descriptions in .C file)
		void setup_n_l_lv_m_numExtIntVars();
		void setup_A_EIXiZiXvZv();
		spMatrix to_stamp(const spMatrix& A);
		void setup_Xyce_jacStamps();
};
#endif
