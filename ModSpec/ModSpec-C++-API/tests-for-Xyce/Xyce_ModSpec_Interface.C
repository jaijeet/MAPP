#include "Xyce_ModSpec_Interface.h"

Xyce_ModSpec_Interface::Xyce_ModSpec_Interface(string so_name): soName(so_name) {

	// dlopen soName, create a ModSpec element, and get a pointer to it.
	elSoPtr = new dynloaded_ModSpec_Element(soName);
	ModSpecElPtr = elSoPtr->ModSpecElPtr;
	NILp = ModSpecElPtr->NILp;
	eeNILp = dynamic_cast<eeNIL_with_common_add_ons *> (NILp);

	setup_n_l_lv_m_numExtIntVars();

	// fprintf(stdout, "n = %d, l = %d, l_v = %d, m = %d for %s\n", n, l, l_v, m, soName.c_str());
	// fprintf(stdout, "numExtVars = %d, numIntVars = %d for %s\n", numExtVars, numIntVars, soName.c_str());

	// set up the A_* matrices
	// spMatrix A_E(0,0), A_I(0,0), A_Xi(0,0), A_Zi(0,0), A_Xv(0,0), A_Zv(0,0);
	setup_A_EIXiZiXvZv(); // A_E A_I A_Xi A_Zi A_Xv A_Zv
	
	// convert all nonzero entries of the incidence matrices to 1 (for stamps)
	spMatrix A_E_stamp = to_stamp(A_E);
	spMatrix A_I_stamp = to_stamp(A_I);
	spMatrix A_Zi_stamp = to_stamp(A_Zi);
	spMatrix A_Xi_stamp = to_stamp(A_Xi);
	spMatrix A_Xv_stamp = to_stamp(A_Xv);
	spMatrix A_Zv_stamp = to_stamp(A_Zv);

	// set up vecE, vecI, vecY - all set to zeros for the stamp
	// WARNING: the stamp is obtained through AD via LFAD; it could
	// be wrong if there are if conditions down the line on the entries of vecE
	// vecI and vecY in the device code.
	vector<double> vecE;
	for (int i=0; i < this->n+1; i++) vecE.push_back(0);
	vector<double> vecI;
	for (int i=0; i < this->n-this->l-this->l_v; i++) vecI.push_back(0);
	vector<double> vecY;
	for (int i=0; i < this->m; i++) vecY.push_back(0);
	vector<double> vecSto;

	// compute the jacobian stamp matrices
	// spMatrix jacStamp_f, jacStamp_q;
	int stampsonly = 1; // compute stamps only using LFAD for AD; not DFAD
	compute_jac_fq(vecE, vecI, vecY, vecSto, false, false, stampsonly);

	// compute Xyce's jacStampF/Q matrices
	setup_Xyce_jacStamps();

	// set up typed parameter lists using default parm values from ModSpec
	vector<untyped> parmvals = ModSpecElPtr->parmdefaults();
	setup_typedParmLists(parmvals);
}

Xyce_ModSpec_Interface::~Xyce_ModSpec_Interface() {
	delete elSoPtr;
}

void Xyce_ModSpec_Interface::setup_n_l_lv_m_numExtIntVars() {
	// /* outputs */ n, l, l_v, m, numExtVars, numIntVars

	vector<string> NodeNames = NILp->NodeNames();
	numExtVars   = NodeNames.size(); // length, including the reference node
					    // JR: this tells the parser to expect three nodes: 
					    // 	yModSpec_Device oof n1 n2 n3
					    // JR: this is used by "topology"
	// set up n
	vector<string> IOnames = ModSpecElPtr->IOnames();
	int twon = IOnames.size();
	div_t q = div(twon, 2);
	if (0 != q.rem) {
		// fprintf(stderr, "error: length(IOnames) is not even\n");
	} else {
		n = twon/2;
	}

	vector<string> IOtypes = NILp->IOtypes();
	vector<string> ExplicitOutputNames = ModSpecElPtr->ExplicitOutputNames();
	// set up l
	l = ExplicitOutputNames.size();

	vector<string> EOtypes = eeNILp->ExplicitOutputTypes();
	// find all v-type ExplicitOutputs; the number of these is l_v
	l_v = 0;
	/* not needed
	vector<string>::iterator vsIter; // std::find returns this type
		// see http://www.cprogramming.com/tutorial/stl/iterators.html
	*/
	for (int i=0; i < l; i++) {
		if (0 == strcmp(EOtypes[i].c_str(), "v")) {
			l_v++;
		}
	}
	// l_v is now set up

	vector<string> InternalUnkNames = ModSpecElPtr->InternalUnkNames();
	m = InternalUnkNames.size();

	numIntVars   = n+m-l+l_v ; // JR: declare numbers of Internal vars/unks for Xyce.

	vector<string> LimitedVarNames = ModSpecElPtr->LimitedVarNames();
	nl = LimitedVarNames.size();
	////////////////////////////////////////////////////////////////
}

void Xyce_ModSpec_Interface::setup_A_EIXiZiXvZv() {
	// /* outputs */ A_E, A_I, A_Zi, A_Xi, A_Xv, A_Zv
	
	// set up the "incidence matrices" A_E, A_I, A_Zi, A_Xi, A_Xv, A_Zv
	
	// set up sparse matrices A_E and A_I; also the names of the vecI unknowns
	// A_E: the node-voltage-to-branch-voltage incidence matrix. Size: size(vecX) x (n+1)
	// A_I: A_I node-voltage-to-branch-current incidence matrix. Size: size(vecX) x size(vecI)=(n-l+l_v)
        // vecX = A_E * vecE + A_I * vecI
	// recall that:
	// 	vecX is the vector of otherIOs, comprising branch voltages and branch currents.
	// 	vecE is the vector of node voltages, in the same order as NILp->NodeNames().
     	// 	vecI are the (n-l+l_v) current unknowns in the OtherIOs
	// 	A_E relates only to the branch voltages.
	// 	A_I relates only to the branch currents.
	vector<string> otherIOnames = ModSpecElPtr->OtherIONames();
	vector<string> otherIOtypes = eeNILp->OtherIOtypes();
	// vector<string> otherIOnodenames = eeNILp->OtherIONodeNames();
	vector<int> otherIOnodeIndices = eeNILp->OtherIONodeIndices();
	int refnodeIndex = eeNILp->RefNodeIndex();
	
	int a = otherIOtypes.size();
	int b = n+1;
	A_E.resize(a, b, false);
	A_I.resize(otherIOtypes.size(), n-l+l_v, false);
	vector<string> vecInames; // names of the vecI unknowns
	int vecIidx = 0;
	for (int i=0; i < otherIOtypes.size(); i++) {
		if (0 == strcmp(otherIOtypes[i].c_str(), "v")) {
			int nodeidx = otherIOnodeIndices[i];
			A_E(i, nodeidx) = 1;
			A_E(i, refnodeIndex) = -1;
		} else { // type "i"
			A_I(i,vecIidx) = 1;
			vecIidx++;
			vecInames.push_back(otherIOnames[i]);
		}
	}

	// fprintf(stdout, "\n-----------------------------------------------\n");
	// fprintf(stdout, "vecX = A_E*vecE + A_I*vecI: \n");
	// fprintf(stdout, "\tvecXnames (otherIOnames): "); print_vector_of_strings(otherIOnames);
	// fprintf(stdout, "\tvecEnames (NodeNames): "); print_vector_of_strings(NILp->NodeNames());
	// fprintf(stdout, "\tvecInames: "); print_vector_of_strings(vecInames);
	
	// cout << "A_E = " << A_E << endl;
	// cout << "A_I = " << A_I << endl;

	// now set up sparse matrices A_Zi and A_Xi. 
	// Recall that these are to express the KCL contributions for all nodes:
     	//	KCLs +=  A_Zi * vecZ(vecX, vecY, vecU) + A_Xi * vecX
	//	(the KCLs are in exactly the same order as NodeNames, we don't need to keep track of their names separately)
       	// A_Zi: each column of A_Zi corresponding to a branch current ExplicitOutput has a 1 for the row corresponding
        //       to its node, and a -1 for the reference node. Columns corresponding to voltage ExplicitOutputs
	//       are identically zero.
        // A_Xi: each column of A_Xi corresponding to a branch current otherIO has a 1 for the row corresponding
        //       to its node, and a -1 for the reference node. Columns corresponding to branch voltage otherIOs
	//       are identically zero.
	vector<string> EOnames = ModSpecElPtr->ExplicitOutputNames();
	vector<string> EOtypes = eeNILp->ExplicitOutputTypes();
	vector<int> EOnodeIndices = eeNILp->ExplicitOutputNodeIndices();

	A_Xi.resize(n+1, otherIOnames.size(), false);
	A_Zi.resize(n+1, EOnames.size(), false);
	// do A_Xi
	for (int i=0; i < otherIOnames.size(); i++) {
		if (0 == strcmp(otherIOtypes[i].c_str(), "i")) {
			int nodeidx = otherIOnodeIndices[i];
			A_Xi(nodeidx, i) = 1;
			A_Xi(refnodeIndex, i) = -1;
		}
	}
	// do A_Zi
	for (int i=0; i < EOnames.size(); i++) {
		if (0 == strcmp(EOtypes[i].c_str(), "i")) {
			int nodeidx = EOnodeIndices[i];
			A_Zi(nodeidx, i) = 1;
			A_Zi(refnodeIndex, i) = -1;
		}
	}

	// fprintf(stdout, "\n-----------------------------------------------\n");
	// fprintf(stdout, "KCLs +=  A_Zi * vecZ(vecX, vecY, vecU) + A_Xi * vecX\n");
	// fprintf(stdout, "\tKCLnames (NodeNames): "); print_vector_of_strings(NILp->NodeNames());
	// fprintf(stdout, "\tvecXnames (otherIOnames): "); print_vector_of_strings(otherIOnames);
	// fprintf(stdout, "\tvecZnames (explicitOutputNames): "); print_vector_of_strings(EOnames);
	
	// cout << "A_Zi = " << A_Zi << endl;
	// cout << "A_Xi = " << A_Xi << endl;

	// now set up sparse matrices A_Xv and A_Zv. 
	// Recall that these are for the KVL equations for the voltage explicitoutputs:
        // - KVLs are are l_v KVL equations for the voltage ExplicitOutputs
        // - KVLs = A_Xv * vecE + A_Zv * vecZ(vecX, vecY, vecU);
	//   - vecE is the vector of node voltages, in the same order as NILp->NodeNames().
	//   - vecZ is the vector of ExplicitOutputs
        //   - A_Xv: each row of A_Xv (there are l_v of them) corresponds to a voltage ExplicitOutput.
        //   	       there should be a 1 in the column corresponding to its node, and a -1 in the col
        //           corresponding to refNode.
        //   - A_Zv: each row of A_Zv should have a single -1, corresponding to the location of the voltage
        //   	       ExplicitOutput in vecZ.

	A_Xv.resize(l_v, NILp->NodeNames().size(), false);
	A_Zv.resize(l_v, EOnames.size(), false);
	vector<string> KVLnames; // names of the KVLs
	int KVLidx = 0;
	// run through all the explicitoutputs of type v, set up A_Xv and A_Zv. Also set up the names of the KVL equations.
	for (int i=0; i < EOnames.size(); i++) {
		if (0 == strcmp(EOtypes[i].c_str(), "v")) {
			int nodeidx = EOnodeIndices[i];
			A_Xv(KVLidx, nodeidx) = 1;
			A_Xv(KVLidx, refnodeIndex) = -1;
			A_Zv(KVLidx, i) = -1;
			KVLnames.push_back(EOnames[i]);
			KVLidx++;
		}
	}

	// fprintf(stdout, "\n-----------------------------------------------\n");
	// fprintf(stdout, "KVLs = A_Xv * vecE + A_Zv * vecZ(vecX, vecY, vecU)\n");
	// fprintf(stdout, "\tKVLnames: "); print_vector_of_strings(KVLnames);
	// fprintf(stdout, "\tvecE (NodeNames): "); print_vector_of_strings(NILp->NodeNames());
	// fprintf(stdout, "\tvecZnames (explicitOutputNames): "); print_vector_of_strings(EOnames);
	
	// cout << "A_Xv = " << A_Xv << endl;
	// cout << "A_Zv = " << A_Zv << endl;
}

spMatrix Xyce_ModSpec_Interface::to_stamp(const spMatrix& A) {
	// find the locations of the non-zeros of A and make them 1
	spMatrix tmp(A.size1(), A.size2());
	for (row_iterator_const it1 = A.begin1(); it1 != A.end1(); it1++) {
	  for (col_iterator_const it2 = it1.begin(); it2 != it1.end(); it2++) {
	  	tmp(it2.index1(),it2.index2()) = 1; // *it2;
	  }
	}
	return tmp;
}

void Xyce_ModSpec_Interface::compute_fq(/* inputs */ vector<double>& vecE, vector<double>& vecI, vector<double>& vecY,
	vector<double>& vecLimOld, bool do_init, bool do_limiting) {
	// /* outputs */ vector<double> this->f, vector<double> this->q
	
	// set up vecX, vecY and vecU [vecE; vecI; vecY];
	// vecX
	vector<double> vecX; 
	vecX = add( prod(this->A_E, vecE) , prod(this->A_I, vecI) );
	// vecY is already set up above
	vector<double> vecU;
	// FIXME: need to worry about setting up vecU, later.
	
    if (do_init && ModSpecElPtr->support_initlimiting()) {
		// set up initial guess
		// vecLimOld = ModSpecElPtr->initGuess(vecU);
		// vecLimNew = ModSpecElPtr->limiting(vecX, vecY, vecLimOld, vecU); 
		vecLimNew = vecLimOld; 
	} else if (do_limiting && ModSpecElPtr->support_initlimiting()) {
		// set up vecLimNew after limiting function
		vecLimNew = ModSpecElPtr->limiting(vecX, vecY, vecLimOld, vecU); 
	}
	
	vector<double> vecZf;
	vector<double> vecZq;
	vector<double> vecWf;
	vector<double> vecWq;
    if ((do_init || do_limiting) && ModSpecElPtr->support_initlimiting()) {
		vecZf = ModSpecElPtr->fe(vecX, vecY, vecLimNew, vecU);
		vecZq = ModSpecElPtr->qe(vecX, vecY, vecLimNew);
		vecWf = ModSpecElPtr->fi(vecX, vecY, vecLimNew, vecU);
		vecWq = ModSpecElPtr->qi(vecX, vecY, vecLimNew);

		// do limiting correction here, previously it was in loadDAEFvector, loadDAEQvector.
		spMatrix dfe_dvecLim = ModSpecElPtr->dfe_dvecLim(vecX, vecY, vecLimNew, vecU);
		spMatrix dqe_dvecLim = ModSpecElPtr->dqe_dvecLim(vecX, vecY, vecLimNew);
		spMatrix dfi_dvecLim = ModSpecElPtr->dfi_dvecLim(vecX, vecY, vecLimNew, vecU);
		spMatrix dqi_dvecLim = ModSpecElPtr->dqi_dvecLim(vecX, vecY, vecLimNew);

		vector<double> vecLimOrig = ModSpecElPtr->vecXYtoLimitedVars(vecX, vecY);
		vector<double> vecLimDiff = subtract(vecLimOrig, vecLimNew);

		vecZf =  add( vecZf, prod(dfe_dvecLim, vecLimDiff) );
		vecZq =  add( vecZq, prod(dqe_dvecLim, vecLimDiff) );
		vecWf =  add( vecWf, prod(dfi_dvecLim, vecLimDiff) );
		vecWq =  add( vecWq, prod(dqi_dvecLim, vecLimDiff) );
	} else {
		vecZf = ModSpecElPtr->fe(vecX, vecY, vecU);
		vecZq = ModSpecElPtr->qe(vecX, vecY);
		vecWf = ModSpecElPtr->fi(vecX, vecY, vecU);
		vecWq = ModSpecElPtr->qi(vecX, vecY);
	}
	
	// next, set up KCLs and KVLs from the above
	// KCLcontribsF/Q and KVLsF/Q are class members
	// KCLs
	vector<double> KCLcontribsF =  add( prod(this->A_Zi, vecZf) , prod(this->A_Xi, vecX) );
	vector<double> KCLcontribsQ =  prod(this->A_Zi, vecZq);
	// KVLs
	vector<double> KVLsF = add( prod(this->A_Xv, vecE) , prod(this->A_Zv, vecZf) );
	vector<double> KVLsQ = prod(this->A_Zv, vecZq);
	// vecW is already set up above
	
	// store f and q in the class
	this->f.resize(this->n+1+this->n-this->l+this->l_v+this->m);
	this->q.resize(this->n+1+this->n-this->l+this->l_v+this->m);
	// KCLs
	for (int i=0; i < this->n+1; i++) {
		 this->f[i] = KCLcontribsF[i];
		 this->q[i] = KCLcontribsQ[i];
	}
	// KVLs
	for (int i=this->n+1; i < this->n+1+this->l_v; i++) {
		this->f[i] = KVLsF[i-(this->n+1)];
		this->q[i] = KVLsQ[i-(this->n+1)];
	}
	// vecW
	for (int i=this->n+1+this->l_v; i < this->n+1+this->n-this->l+this->l_v+this->m; i++) {
		this->f[i] = vecWf[i-(this->n+1+this->l_v)];
		this->q[i] = vecWq[i-(this->n+1+this->l_v)];
	}
}

void Xyce_ModSpec_Interface::compute_jac_fq(/* inputs */ vector<double>& vecE, vector<double>& vecI, vector<double>& vecY,
	vector<double>& vecLimOld, bool do_init, bool do_limiting, bool stampsonly) {

	vector<double> vecX = add( prod(this->A_E , vecE) , prod(this->A_I , vecI) );
	// vecY is already available from above
	vector<double> vecU;
	// FIXME: need to worry about setting up vecU, later.

    if (do_init && ModSpecElPtr->support_initlimiting()) {
		// set up initial guess
		// vecLimOld = ModSpecElPtr->initGuess(vecU);
		// vecLimNew = ModSpecElPtr->limiting(vecX, vecY, vecLimOld, vecU); 
		vecLimNew = vecLimOld; 
	} else if (do_limiting && ModSpecElPtr->support_initlimiting()) {
		// set up vecLimNew after limiting function
		vecLimNew = ModSpecElPtr->limiting(vecX, vecY, vecLimOld, vecU); 
	}

	// set up all the components of the f/q Jacobian matrices
	//	            vecE            vecI            vecY
	//	            (n+1)          (n-l+l_v)         (m)
	//	        ---------------------------------------------
	// KCLs (n+1)   | dKCLs_dvecE     dKCLs_dvecI     dKCLs_dvecY
	// KVLs (l_v)   | dKVLs_dvecE     dKVLs_dvecI     dKVLs_dvecY
	// vecW (n-l+m) | dvecW_dvecE     dvecW_dvecI     dvecW_dvecY
	//

	// set up dvecZ_dvecX_f/q, dvecZ_dvecY_f/q, dvecW_dvecX_f/q, dvecW_dvecY_f/q
	spMatrix dvecZf_dvecX;
	spMatrix dvecZf_dvecY;
	spMatrix dvecZq_dvecX;
	spMatrix dvecZq_dvecY;
	spMatrix dvecWf_dvecX;
	spMatrix dvecWf_dvecY;
	spMatrix dvecWq_dvecX;
	spMatrix dvecWq_dvecY;

	// local versions of the incidence matrices. Note that these are all class members
	spMatrix A_E;
	spMatrix A_I;
	spMatrix A_Zi;
	spMatrix A_Xi;
	spMatrix A_Xv;
	spMatrix A_Zv;

	if (1 == stampsonly) {
		// convert all nonzero entries of the incidence matrices to 1 (for stamps)
		A_E = to_stamp(this->A_E);
		A_I = to_stamp(this->A_I);
		A_Zi = to_stamp(this->A_Zi);
		A_Xi = to_stamp(this->A_Xi);
		A_Xv = to_stamp(this->A_Xv);
		A_Zv = to_stamp(this->A_Zv);
	} else {
		A_E = this->A_E;
		A_I = this->A_I;
		A_Zi = this->A_Zi;
		A_Xi = this->A_Xi;
		A_Xv = this->A_Xv;
		A_Zv = this->A_Zv;
	}

    if ((do_init || do_limiting) && ModSpecElPtr->support_initlimiting()) {
		if (1 == stampsonly) {
			// Notes: can be made more compact, since theoretically stamps won't change with init/limiting
			spMatrix vecXY_to_limited_vars_matrix_stamp = ModSpecElPtr->vecXYtoLimitedVarsMatrix_stamp();
			double nvecX = ModSpecElPtr->OtherIONames().size();
			double nvecY = ModSpecElPtr->InternalUnkNames().size();
			double nvecLim = ModSpecElPtr->LimitedVarNames().size();
			spMatrix vecXtoLimitedVarsMatrix_stamp = subslice(vecXY_to_limited_vars_matrix_stamp, 0, 1, nvecLim, 0, 1, nvecX);
			spMatrix vecYtoLimitedVarsMatrix_stamp = subslice(vecXY_to_limited_vars_matrix_stamp, 0, 1, nvecLim, nvecX, 1, nvecY);

			dvecZf_dvecX = ModSpecElPtr->dfe_dvecX_stamp(vecX, vecY, vecLimNew, vecU) + 
				prod(ModSpecElPtr->dfe_dvecLim_stamp(vecX, vecY, vecLimNew, vecU), vecXtoLimitedVarsMatrix_stamp);
			dvecZf_dvecY = ModSpecElPtr->dfe_dvecY_stamp(vecX, vecY, vecLimNew, vecU) +
				prod(ModSpecElPtr->dfe_dvecLim_stamp(vecX, vecY, vecLimNew, vecU), vecYtoLimitedVarsMatrix_stamp);
			dvecZq_dvecX = ModSpecElPtr->dqe_dvecX_stamp(vecX, vecY, vecLimNew) +
				prod(ModSpecElPtr->dqe_dvecLim_stamp(vecX, vecY, vecLimNew), vecXtoLimitedVarsMatrix_stamp);
			dvecZq_dvecY = ModSpecElPtr->dqe_dvecY_stamp(vecX, vecY, vecLimNew) +
				prod(ModSpecElPtr->dqe_dvecLim_stamp(vecX, vecY, vecLimNew), vecYtoLimitedVarsMatrix_stamp);
			dvecWf_dvecX = ModSpecElPtr->dfi_dvecX_stamp(vecX, vecY, vecLimNew, vecU) +
				prod(ModSpecElPtr->dfi_dvecLim_stamp(vecX, vecY, vecLimNew, vecU), vecXtoLimitedVarsMatrix_stamp);
			dvecWf_dvecY = ModSpecElPtr->dfi_dvecY_stamp(vecX, vecY, vecLimNew, vecU) +
				prod(ModSpecElPtr->dfi_dvecLim_stamp(vecX, vecY, vecLimNew, vecU), vecYtoLimitedVarsMatrix_stamp);
			dvecWq_dvecX = ModSpecElPtr->dqi_dvecX_stamp(vecX, vecY, vecLimNew) +
				prod(ModSpecElPtr->dqi_dvecLim_stamp(vecX, vecY, vecLimNew), vecXtoLimitedVarsMatrix_stamp);
			dvecWq_dvecY = ModSpecElPtr->dqi_dvecY_stamp(vecX, vecY, vecLimNew) +
				prod(ModSpecElPtr->dqi_dvecLim_stamp(vecX, vecY, vecLimNew), vecYtoLimitedVarsMatrix_stamp);
		} else {
			spMatrix vecXY_to_limited_vars_matrix = ModSpecElPtr->vecXYtoLimitedVarsMatrix();
			double nvecX = ModSpecElPtr->OtherIONames().size();
			double nvecY = ModSpecElPtr->InternalUnkNames().size();
			double nvecLim = ModSpecElPtr->LimitedVarNames().size();
			spMatrix vecXtoLimitedVarsMatrix = subslice(vecXY_to_limited_vars_matrix, 0, 1, nvecLim, 0, 1, nvecX);
			spMatrix vecYtoLimitedVarsMatrix = subslice(vecXY_to_limited_vars_matrix, 0, 1, nvecLim, nvecX, 1, nvecY);

			dvecZf_dvecX = ModSpecElPtr->dfe_dvecX(vecX, vecY, vecLimNew, vecU) + 
				prod(ModSpecElPtr->dfe_dvecLim(vecX, vecY, vecLimNew, vecU), vecXtoLimitedVarsMatrix);
			dvecZf_dvecY = ModSpecElPtr->dfe_dvecY(vecX, vecY, vecLimNew, vecU) +
				prod(ModSpecElPtr->dfe_dvecLim(vecX, vecY, vecLimNew, vecU), vecYtoLimitedVarsMatrix);
			dvecZq_dvecX = ModSpecElPtr->dqe_dvecX(vecX, vecY, vecLimNew) +
				prod(ModSpecElPtr->dqe_dvecLim(vecX, vecY, vecLimNew), vecXtoLimitedVarsMatrix);
			dvecZq_dvecY = ModSpecElPtr->dqe_dvecY(vecX, vecY, vecLimNew) +
				prod(ModSpecElPtr->dqe_dvecLim(vecX, vecY, vecLimNew), vecYtoLimitedVarsMatrix);
			dvecWf_dvecX = ModSpecElPtr->dfi_dvecX(vecX, vecY, vecLimNew, vecU) +
				prod(ModSpecElPtr->dfi_dvecLim(vecX, vecY, vecLimNew, vecU), vecXtoLimitedVarsMatrix);
			dvecWf_dvecY = ModSpecElPtr->dfi_dvecY(vecX, vecY, vecLimNew, vecU) +
				prod(ModSpecElPtr->dfi_dvecLim(vecX, vecY, vecLimNew, vecU), vecYtoLimitedVarsMatrix);
			dvecWq_dvecX = ModSpecElPtr->dqi_dvecX(vecX, vecY, vecLimNew) +
				prod(ModSpecElPtr->dqi_dvecLim(vecX, vecY, vecLimNew), vecXtoLimitedVarsMatrix);
			dvecWq_dvecY = ModSpecElPtr->dqi_dvecY(vecX, vecY, vecLimNew) +
				prod(ModSpecElPtr->dqi_dvecLim(vecX, vecY, vecLimNew), vecYtoLimitedVarsMatrix);
		}
	} else {
		if (1 == stampsonly) {
			dvecZf_dvecX = ModSpecElPtr->dfe_dvecX_stamp(vecX, vecY, vecU);
			dvecZf_dvecY = ModSpecElPtr->dfe_dvecY_stamp(vecX, vecY, vecU);
			dvecZq_dvecX = ModSpecElPtr->dqe_dvecX_stamp(vecX, vecY);
			dvecZq_dvecY = ModSpecElPtr->dqe_dvecY_stamp(vecX, vecY);
			dvecWf_dvecX = ModSpecElPtr->dfi_dvecX_stamp(vecX, vecY, vecU);
			dvecWf_dvecY = ModSpecElPtr->dfi_dvecY_stamp(vecX, vecY, vecU);
			dvecWq_dvecX = ModSpecElPtr->dqi_dvecX_stamp(vecX, vecY);
			dvecWq_dvecY = ModSpecElPtr->dqi_dvecY_stamp(vecX, vecY);
		} else {
			dvecZf_dvecX = ModSpecElPtr->dfe_dvecX(vecX, vecY, vecU);
			dvecZf_dvecY = ModSpecElPtr->dfe_dvecY(vecX, vecY, vecU);
			dvecZq_dvecX = ModSpecElPtr->dqe_dvecX(vecX, vecY);
			dvecZq_dvecY = ModSpecElPtr->dqe_dvecY(vecX, vecY);
			dvecWf_dvecX = ModSpecElPtr->dfi_dvecX(vecX, vecY, vecU);
			dvecWf_dvecY = ModSpecElPtr->dfi_dvecY(vecX, vecY, vecU);
			dvecWq_dvecX = ModSpecElPtr->dqi_dvecX(vecX, vecY);
			dvecWq_dvecY = ModSpecElPtr->dqi_dvecY(vecX, vecY);
		}
	}

	// set up dKCLs_dvecE
        // - dKCLs_dvecE += A_Xi * dvecX_dvecE + A_Zi * dvecZ_dvecX * dvecX_dvecE = A_Xi * A_E + A_Zi * dvecZ_dvecX * A_E
	//  - (vecY, vecU do not depend on vecE)
	spMatrix oof = prod(A_Zi, dvecZf_dvecX);
	spMatrix dKCLs_dvecE_f = prod(A_Xi,A_E)+prod(oof, A_E); //A_Xi*A_E+A_Zi*dvecZf_dvecX*A_E;
	oof = prod(A_Zi, dvecZq_dvecX);
	spMatrix dKCLs_dvecE_q = prod(oof, A_E); // A_Zi * dvecZq_dvecX * A_E;

	// set up dKCLs_dvecI
        // - dKCLs_dvecI += A_Xi * dvecX_dvecI + A_Zi * dvecZ_dvecX * dvecX_dvecI = A_Xi * A_I + A_Zi * dvecZ_dvecX * A_I
	//   - (vecY, vecU do not depend on vecI)
	oof = prod(A_Zi, dvecZf_dvecX);
	spMatrix dKCLs_dvecI_f = prod(A_Xi,A_I) + prod(oof, A_I); // A_Xi*A_I + A_Zi * dvecZf_dvecX * A_I;
	oof = prod(A_Zi, dvecZq_dvecX);
	spMatrix dKCLs_dvecI_q = prod(oof, A_I); // A_Zi * dvecZq_dvecX * A_I;

	// set up dKCLs_dvecY
	// - dKCLs_dvecY += A_Zi * dvecZ_dvecY
	spMatrix dKCLs_dvecY_f = prod(A_Zi, dvecZf_dvecY); // A_Zi * dvecZf_dvecY;
	spMatrix dKCLs_dvecY_q = prod(A_Zi, dvecZq_dvecY); // A_Zi * dvecZq_dvecY;

	// set up dKVLs_dvecE
        // - dKVLs_dvecE = A_Xv + A_Zv * dvecZ_dvecX * dvecX_dvecE = A_Xv + A_Zv * dvecZ_dvecX * A_E
	oof = prod(A_Zv, dvecZf_dvecX);
	spMatrix dKVLs_dvecE_f = A_Xv + prod(oof, A_E); // A_Xv + A_Zv * dvecZf_dvecX * A_E;
	oof = prod(A_Zv, dvecZq_dvecX);
	spMatrix dKVLs_dvecE_q = prod(oof, A_E);        //        A_Zv * dvecZq_dvecX * A_E;

	// set up dKVLs_dvecI
        // - dKVLs_dvecI = A_Zv * dvecZ_dvecX * dvecX_dvecI = A_Zv * dvecZ_dvecX * A_I
	oof = prod(A_Zv, dvecZf_dvecX);
	spMatrix dKVLs_dvecI_f = prod(oof, A_I); // A_Zv * dvecZf_dvecX * A_I;
	oof = prod(A_Zv, dvecZq_dvecX);
	spMatrix dKVLs_dvecI_q = prod(oof, A_I); // A_Zv * dvecZq_dvecX * A_I;

	// set up dKVLs_dvecY
        // - dKVLs_dvecY = A_Zv * dvecZ_dvecY
	spMatrix dKVLs_dvecY_f = prod(A_Zv, dvecZf_dvecY); // A_Zv * dvecZf_dvecY;
	spMatrix dKVLs_dvecY_q = prod(A_Zv, dvecZq_dvecY); // A_Zv * dvecZq_dvecY;

	// set up dvecW_dvecE
        // - dvecW_dvecE = dvecW_dvecX * dvecX_dvecE = dvecW_dvecX * A_E
	spMatrix dvecW_dvecE_f = prod(dvecWf_dvecX, A_E); // dvecWf_dvecX * A_E;
	spMatrix dvecW_dvecE_q = prod(dvecWq_dvecX, A_E); // dvecWq_dvecX * A_E;

	// set up dvecW_dvecI
        // - dvecW_dvecI = dvecW_dvecX * dvecX_dvecI = dvecW_dvecX * A_I
	spMatrix dvecW_dvecI_f = prod(dvecWf_dvecX, A_I); // dvecWf_dvecX * A_I;
	spMatrix dvecW_dvecI_q = prod(dvecWq_dvecX, A_I); // dvecWq_dvecX * A_I;
	
	// dvecW_dvecY is already available:
	// - dvecWf_dvecY
	// - dvecWq_dvecY

	// accessing submatrices: see http://www.boost.org/doc/libs/1_43_0/libs/numeric/ublas/doc/operations_overview.htm#sub
	using namespace boost::numeric::ublas;
	
	// indices of eqns for jac setup
	boost::numeric::ublas::range KCLindices(0, n+1);
	boost::numeric::ublas::range KVLindices(n+1, n+1+l_v);
	boost::numeric::ublas::range vecWindices(n+1+l_v, n+1+l_v+n-l+m);

	// indices of unks for jac setup
	boost::numeric::ublas::range vecEindices(0, n+1);
	boost::numeric::ublas::range vecIindices(n+1, n+1+n-l+l_v);
	boost::numeric::ublas::range vecYindices(n+1+n-l+l_v, n+1+n-l+l_v+m);

	if ((jac_f.size1() != n+1+l_v+n-l+m) || (jac_f.size2() != n+1+l_v+n-l+m))
		jac_f.resize(n+1+l_v+n-l+m, n+1+n-l+l_v+m, false);
	if ((jac_q.size1() != n+1+l_v+n-l+m) || (jac_q.size2() != n+1+l_v+n-l+m))
		jac_q.resize(n+1+l_v+n-l+m, n+1+n-l+l_v+m, false);

	// add dKCLs_dvecE
	project(jac_f, KCLindices, vecEindices) = dKCLs_dvecE_f;
	project(jac_q, KCLindices, vecEindices) = dKCLs_dvecE_q;
	
	// add dKCLs_dvecI
	project(jac_f, KCLindices, vecIindices) = dKCLs_dvecI_f;
	project(jac_q, KCLindices, vecIindices) = dKCLs_dvecI_q;
	
	// add dKCLs_dvecY
	project(jac_f, KCLindices, vecYindices) = dKCLs_dvecY_f;
	project(jac_q, KCLindices, vecYindices) = dKCLs_dvecY_q;
	
	// add dKVLs_dvecE
	project(jac_f, KVLindices, vecEindices) = dKVLs_dvecE_f;
	project(jac_q, KVLindices, vecEindices) = dKVLs_dvecE_q;
	
	// add dKVLs_dvecI
	project(jac_f, KVLindices, vecIindices) = dKVLs_dvecI_f;
	project(jac_q, KVLindices, vecIindices) = dKVLs_dvecI_q;

	// add dKVLs_dvecY
	project(jac_f, KVLindices, vecYindices) = dKVLs_dvecY_f;
	project(jac_q, KVLindices, vecYindices) = dKVLs_dvecY_q;

	// add dvecW_dvecE
	project(jac_f, vecWindices, vecEindices) = dvecW_dvecE_f;
	project(jac_q, vecWindices, vecEindices) = dvecW_dvecE_q;

	// add dvecW_dvecI
	project(jac_f, vecWindices, vecIindices) = dvecW_dvecI_f;
	project(jac_q, vecWindices, vecIindices) = dvecW_dvecI_q;

	// add dvecW_dvecY
	project(jac_f, vecWindices, vecYindices) = dvecWf_dvecY;
	project(jac_q, vecWindices, vecYindices) = dvecWq_dvecY;

	// fprintf(stdout, "\njac_f = "); cout << jac_f << endl;
	// fprintf(stdout, "jac_q = "); cout << jac_q << endl;

	jacStamp_f = jac_f;
	jacStamp_q = jac_q;

	/*
	// show the locations of the non-zeros of jac_f/q
	fprintf(stdout, "\njac_f fill-in locations:\n");
	for (row_iterator_const it1 = jac_f.begin1(); it1 != jac_f.end1(); it1++) {
	  const spVector& the_row = row(jac_f, it1.index1());
	  cout << "\trow " << it1.index1() << " (" << the_row.nnz() << " " << (1==the_row.nnz()?"nonzero":"nonzeros") << "): ";
	  for (col_iterator_const it2 = it1.begin(); it2 != it1.end(); it2++)
	  for (spVector::const_iterator it2 = the_row.begin(); it2 != the_row.end(); it2++) {
	        std::cout << "(" << it1.index1() << "," << it2.index() << ")=";
			std::cout << *it2 << "; ";
	  }
	  cout << endl;
	}

	fprintf(stdout, "\njac_q fill-in locations:\n");
	for (row_iterator_const it1 = jac_q.begin1(); it1 != jac_q.end1(); it1++) {
	  const spVector& the_row = row(jac_f, it1.index1());
	  cout << "\trow " << it1.index1() << " (" << the_row.nnz() << " " << (1==the_row.nnz()?"nonzero":"nonzeros") << "): ";
	  for (col_iterator_const it2 = it1.begin(); it2 != it1.end(); it2++)
	  for (spVector::const_iterator it2 = the_row.begin(); it2 != the_row.end(); it2++) {
	        std::cout << "(" << it1.index1() << "," << it2.index() << ")=";
			std::cout << *it2 << "; ";
	  }
	  cout << endl;
	}
	*/
}

void Xyce_ModSpec_Interface::setup_Xyce_jacStamps() {
	// /* outputs */ vector<vector<int> >& jacStamp_Xyce_f, vector<vector<int> >& jacStamp_Xyce_q, 
	//  /* inputs */ spMatrix& jacStamp_f, spMatrix& jacStamp_q
	
	// sets up Xyce's jacstamps (jacStamp_Xyce_f and jacStamp_Xyce_q) from jacStamp_f and jacStamp_q
    	// vector<vector<int> > jacStamp_Xyce_f;
    	// vector<vector<int> > jacStamp_Xyce_q;

	// jacStamp_Xyce_f
	jacStamp_Xyce_f.resize(jacStamp_f.size1());
	for (int i=0; i < jacStamp_f.size1(); i++) {
		const spVector& the_row = row(jacStamp_f, i);
		int nnzs = the_row.nnz();
		if (nnzs > 0) {
			jacStamp_Xyce_f[i].resize(nnzs, false);
			int j = 0;
	  		for (spVector::const_iterator it2 = the_row.begin(); it2 != the_row.end(); it2++) {
				jacStamp_Xyce_f[i][j]= it2.index();
				j++;
			}
		}
	}

	// jacStamp_Xyce_q
	jacStamp_Xyce_q.resize(jacStamp_q.size1());
	for (int i=0; i < jacStamp_q.size1(); i++) {
		const spVector& the_row = row(jacStamp_q, i);
		int nnzs = the_row.nnz();
		if (nnzs > 0) {
			jacStamp_Xyce_q[i].resize(nnzs, false);
			int j = 0;
	  		for (spVector::const_iterator it2 = the_row.begin(); it2 != the_row.end(); it2++) {
				jacStamp_Xyce_q[i][j]= it2.index();
				j++;
			}
		}
	}


	// jacStamp_Xyce_fq
	spMatrix jacStamp_fq = jacStamp_f + jacStamp_q;
	jacStamp_Xyce_fq.resize(jacStamp_fq.size1());
	for (int i=0; i < jacStamp_fq.size1(); i++) {
		const spVector& the_row = row(jacStamp_fq, i);
		int nnzs = the_row.nnz();
		if (nnzs > 0) {
			jacStamp_Xyce_fq[i].resize(nnzs, false);
			int j = 0;
	  		for (spVector::const_iterator it2 = the_row.begin(); it2 != the_row.end(); it2++) {
				jacStamp_Xyce_fq[i][j]= it2.index();
				j++;
			}
		}
	}

	/*
	// print jacStamp_Xyce_f
	fprintf(stdout, "\njacStamp_Xyce_f:\n");
	for (int i=0; i < jacStamp_Xyce_f.size(); i++) {
	  const vector<int>& the_row = jacStamp_Xyce_f[i];
	  fprintf(stdout, "\trow %d (%d %s):", i, (int) the_row.size(), (1==the_row.size()?"nonzero":"nonzeros") );
	  for (int j=0; j < the_row.size(); j++) {
	  	fprintf(stdout, " (%d)=%d;", j, the_row[j]);
	  }
	  fprintf(stdout, "\n");
	}
	
	// print jacStamp_Xyce_q
	fprintf(stdout, "\njacStamp_Xyce_q:\n");
	for (int i=0; i < jacStamp_Xyce_q.size(); i++) {
	  const vector<int>& the_row = jacStamp_Xyce_q[i];
	  fprintf(stdout, "\trow %d (%d %s):", i, (int) the_row.size(), (1==the_row.size()?"nonzero":"nonzeros") );
	  for (int j=0; j < the_row.size(); j++) {
	  	fprintf(stdout, " (%d)=%d;", j, the_row[j]);
	  }
	  fprintf(stdout, "\n");
	}

	// print jacStamp_Xyce_fq
	fprintf(stdout, "\njacStamp_Xyce_fq:\n");
	for (int i=0; i < jacStamp_Xyce_fq.size(); i++) {
	  const vector<int>& the_row = jacStamp_Xyce_fq[i];
	  fprintf(stdout, "\trow %d (%d %s):", i, (int) the_row.size(), (1==the_row.size()?"nonzero":"nonzeros") );
	  for (int j=0; j < the_row.size(); j++) {
	  	fprintf(stdout, " (%d)=%d;", j, the_row[j]);
	  }
	  fprintf(stdout, "\n");
	}
	*/
}

void Xyce_ModSpec_Interface::setup_typedParmLists(const vector<untyped>& parmvals) {
	/* sets up:
	vector<double> this->doubleParms; 
	vector<string> this->doubleParmNames;
	vector<int>    this->intParms; 
	vector<string> this->intParmNames;
	vector<string> this->stringParms;
	vector<string> this->stringParmNames;
	*/

	vector<string> parm_names = ModSpecElPtr->parmnames();

	for (int i=0; i < parmvals.size(); i++) {
		string pname = parm_names[i];
		untyped pval = parmvals[i];

		switch (pval.type()) {
			case T_INT: 
				intParms.push_back((int) pval);
				intParmNames.push_back(pname);
				// Xyce addPar call goes here
				break;
			case T_DOUBLE: 
				doubleParms.push_back((double) pval);
				doubleParmNames.push_back(pname);
				// Xyce addPar call goes here
				break;
			case T_STRING: 
				stringParms.push_back((eString) pval);
				stringParmNames.push_back(pname);
				// Xyce addPar call goes here
				break;
			default:
				// fprintf(stderr, "ERROR: parameter %s is of type T_UNDEF\n", pname.c_str());
				exit(1);
		};
	}

	// fprintf(stdout, "\nintParms: "); print_vector_of_ints(intParmNames, intParms);
	// fprintf(stdout, "doubleParms: "); print_vector_of_doubles(doubleParmNames, doubleParms);
	// fprintf(stdout, "stringParms: "); print_vector_of_strings(stringParmNames, stringParms);
	// fprintf(stdout, "\n");
}

void Xyce_ModSpec_Interface::set_ModSpec_parms_from_typedParmLists() {
	// set up parms from intParms, doubleParms and stringParms
	// and call ModSpec's setparms to set these internally
	vector<untyped> parms;
	int iIdx=0, dIdx=0, sIdx=0;
	
	vector<untyped> parm_defaults = ModSpecElPtr->parmdefaults();

	for (int i=0; i < parm_defaults.size(); i++) {
		untyped pval = parm_defaults[i];

		switch (pval.type()) {
			case T_INT: 
				parms.push_back(intParms[iIdx++]);
				break;
			case T_DOUBLE: 
				parms.push_back(doubleParms[dIdx++]);
				break;
			case T_STRING: 
				parms.push_back(stringParms[sIdx++]);
				break;
			default:
				vector<string> parm_names = ModSpecElPtr->parmnames();
				// fprintf(stderr, "ERROR: parameter %s is of type T_UNDEF\n", parm_names[i].c_str());
				exit(1);
		};
	}
	// call ModSpec's setparms() on this
	ModSpecElPtr->setparms(parms);
}

void Xyce_ModSpec_Interface::setup_eqnunkidx_to_LID_maps(const vector<int>& extLIDVec, const vector<int>& intLIDVec) {
  // set up a mapping from the indices of the unknowns in [vecE; vecI; vecY] to the corresponding LID
  for (int i = 0; i < this->jacStamp_Xyce_f.size(); i++) {
  	// vector<int> unkidx_to_LID_map; member of the class
  	// vector<int> eqnidx_to_LID_map; member of the class
	if (i < numExtVars) { // i < numExtVars => this is a node/KCL LID
		this->unkidx_to_LID_map.push_back(extLIDVec[i]);
		this->eqnidx_to_LID_map.push_back(extLIDVec[i]);
	} else { // i >= numExtVars => this is an internal unk/equation LID
		this->unkidx_to_LID_map.push_back(intLIDVec[i-numExtVars]);
		this->eqnidx_to_LID_map.push_back(intLIDVec[i-numExtVars]);
	}
  }
}

void Xyce_ModSpec_Interface::vecEIY_from_solVec(/* outputs */ vector<double>& vecE, vector<double>& vecI, vector<double>& vecY,
		                        /* inputs */ double* solVec) {
  // recall solVec = [vecE; vecI; vecY];
  // vecE
  // note: this->numExtVars == n+1
  for (int i=0; i < this->numExtVars; i++) vecE.push_back(solVec[this->unkidx_to_LID_map[i]]);
  // vecI
  for (int i=this->n+1; i < this->n+1+this->n-this->l+this->l_v; i++) vecI.push_back(solVec[this->unkidx_to_LID_map[i]]);
  // vecY
  for (int i=this->n+1+this->n-this->l+this->l_v; i < this->n+1+this->n-this->l+this->l_v+this->m; i++) 
  	vecY.push_back(solVec[this->unkidx_to_LID_map[i]]);
}

void Xyce_ModSpec_Interface::setup_dFQdxMat_ptrs(XMI_local::_rREPclassGeneric& rREP_F, XMI_local::_rREPclassGeneric& rREP_Q) {
	// keep the pointers in an spMatrix_doubleptr with the same sparsity pattern as jacStamp_f/q
	// dFdX
	dFdxMat_ptrs.resize( jacStamp_Xyce_f.size(), jacStamp_Xyce_f.size() , false );
	for (int i = 0; i < jacStamp_Xyce_f.size(); i++) {
		for (int j = 0; j < jacStamp_Xyce_f[i].size(); j++) {
	      	dFdxMat_ptrs(i,jacStamp_Xyce_f[i][j]) = 
	      		rREP_F.returnRawEntryPointer(eqnidx_to_LID_map[i], unkidx_to_LID_map[jacStamp_Xyce_f[i][j]]);
	      }
	}
	// dQdX
	dQdxMat_ptrs.resize( jacStamp_Xyce_q.size(), jacStamp_Xyce_q.size() , false );
	for (int i = 0; i < jacStamp_Xyce_q.size(); i++) {
		for (int j = 0; j < jacStamp_Xyce_q[i].size(); j++) {
	      	dQdxMat_ptrs(i,jacStamp_Xyce_q[i][j]) = 
	      		rREP_Q.returnRawEntryPointer(eqnidx_to_LID_map[i], unkidx_to_LID_map[jacStamp_Xyce_q[i][j]]);
	      }
	}
}
