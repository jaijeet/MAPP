#include "MNA_DAE.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>

using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
MNA_DAE::MNA_DAE(cktnetlist * incktPtr) {
	/////////////////////////////////////////////////////////////////////////
	// Step 0: set up cktnetlistPtr, dae_name, uniq_ID, dae_version, initial
	//         values for unk_names, eqn_names, etc.
	/////////////////////////////////////////////////////////////////////////
	/* OBSOLETE:
		// cktPtr = new cktnetlist(*incktPtr); // make a copy.

		// Note: compared with doing everything "in place" on the input cktnetlist,
		// this requires more memory. However, in MAPP the same cktnetlist may be
		// used by several equation engines. Since equation engines modify
		// cktnetlist during setparms for the evaluation of f/q, they shouldn't
		// share the same cktnetlist. It would be safer if each of them keeps a
		// copy of cktnetlist.

		// More notes: actually, keeping a copy of cktnetlist may not be the way to
		// go. We need more information set up for f/q evaluations.
		// A data structure, namely MNA_cktdata should be created based on cktnetlist.
		// It can be a vector of pointers to MNA_elementdata objects.
		// Each object should contain:
		//     .ModSpecPtr
		//     .A_X, nvecX-by-nunks matrix
		//     .A_Y, nvecY-by-nunks matrix
		//     .A_U, nvecU-by-ninputs matrix
		//     .A_fX, neqns-by-nve matrix
		//     .A_Z, neqns-by-nvecZ matrix
		//     .A_W, neqns-by-nvecW matrix
	*/
	// Change of mind: don't make copies, just use a pointer to cktnetlist,
	// then store extra data in MNA_circuitdata.
 	cktnetlistPtr = incktPtr;
	separatorString = ":::";

	dae_name = "MNA DAE for " + cktnetlistPtr->name;
	uniq_ID = "undefined"; // TODO
	dae_version = "undefined"; // TODO

	for (int i = 0; i < cktnetlistPtr->node_names.size(); i++) {
		unk_names += "e_" + cktnetlistPtr->node_names[i]; // names of node voltage unknowns
		eqn_names += "KCL_" + cktnetlistPtr->node_names[i]; // names of KCL equations for the nodes
	}
	int n_unks = unk_names.size(); 
	// int neqns = eqn_names.size(); 
	int n_eqns = n_unks;
	int n_inputs = 0;
	int n_limited_vars = 0;

	// now set up:
    //		element_names
	//		parm_names;
	//		parm_defaultvals;
	//
	//		unk_names;
	//		eqn_names;
	//		input_names;
	//		output_names;
	//		NoiseSource_names;
	//
	//		limited_var_names;
	//		x_to_xlim_matrix;
	//
	//		Cmat;
	//		Dmat;

	// set up the "incidence matrices" A_X, etc.

	// - a vector of pointers cannot be conveniently dereferenced to a vector of numbers;
	// - creating a subvector from a vector and a list/vector of indices is not convenient either;
	// - std::valarray seems to offer more intuitive API for this:
	//       http://stackoverflow.com/questions/30469063/extract-a-subvector-from-a-vector-without-copy
	//       std::valarray<int> orig = { 0,1,2,3,4,5,6,7,8,9 };
	//       std::valarray<size_t> index = { 3,5,6,8 };
	//       orig[index] = -1;
	//   but valarray is almost obsolete now.

	//////////////////////////////////////////////////////////////////////////
	// Step 1: first loop through devices
	//////////////////////////////////////////////////////////////////////////
	for (int i = 0; i < cktnetlistPtr->elements.size(); i++) {
		//////////////////////////////////////////////////////////////////////
		// Step 1.0: gather element information, set up element_names, set up
		//           device's initial parameters
		netlistElement * el = cktnetlistPtr->elements[i];
		string elname = el->name;
		ModSpec_Element * elModel = el->ModSpecPtr;
		vector<string> elNodes = el->nodes;
		vector<untyped> elParms = el->parms;
		string prefix = elname + separatorString;

		eeNIL_with_common_add_ons* elNIL = dynamic_cast<eeNIL_with_common_add_ons *> (elModel->NILp); // MNA is EE specific

		// set up a list of all element names to help find the index
		element_names += elname;

		// set device parameters
		elModel->setparms(elParms);

		//////////////////////////////////////////////////////////////////////
		// Step 1.1: look at nodes and refnode, set up their indices

		// At this step, we set up:
		// int refnode_idx_in_x: the index of the refnode of the device in x.
		// 			Ground node index is represented as -1.
		// vector<int> node_indices_in_x: the indices of the (non-ref) nodes of the device in x.
		// 			Ground node index is represented as -1.

		// set up nodes_indices_in_x 
        vector<string> nodenames_internal = elNIL->NodeNames();

        if (elNodes.size() != nodenames_internal.size()) {
			fprintf(stderr, "error: length of device %s's internal node list different from that of its external node connections\n", elname.c_str());
		}

		vector<int> node_indices_in_x;
		for (int j = 0; j < elNodes.size(); j++) {
            string node = elNodes[j];
            int idx = findstring(node, cktnetlistPtr->node_names);
            if (idx >= 0)  { // found
				node_indices_in_x += idx;
			}
			else if (0 == node.compare(cktnetlistPtr->ground_node_name)) {
				// is ground node
				node_indices_in_x += -1;
			}
            else {
				fprintf(stderr, "error: node %s not found exactly once amongst circuit nodes\n", node.c_str());
            }
		}

		// set up refnode_idx_in_x 
		string refnode = elNIL->RefNodeName();
		int refnode_idx_in_nodes = findstring(refnode, nodenames_internal);
		if (refnode_idx_in_nodes < 0) {
			fprintf(stderr, "error: reference node %s for device %s not found amongst device's node list\n", refnode.c_str(), elname.c_str());
		}
		int refnode_idx_in_x = findstring(elNodes[refnode_idx_in_nodes], cktnetlistPtr->node_names); 
		if (refnode_idx_in_x >= 0) {
			// This is the normal case and we don't have to do anything
		}
		else if (0 == elNodes[refnode_idx_in_nodes].compare(cktnetlistPtr->ground_node_name)) {
			refnode_idx_in_x = -1; // explicitly set it as -1
		}
		else {
			fprintf(stderr, "error: reference node %s of device %s not found exactly once in circuit nodes\n", refnode.c_str(), elname.c_str());
		}
		// done with refnode_idx_in_x, delete refnode_idx from node_indices:
		node_indices_in_x.erase(node_indices_in_x.begin() + refnode_idx_in_nodes); // TODO: make sure

		//////////////////////////////////////////////////////////////////////
		// Step 1.2: look at vecX, set up A_X, append to unk_names if needed
		vector<string> oioNames = elModel->OtherIONames();
		int n_oios = oioNames.size();
		vector<string> oioTypes = elNIL->OtherIOtypes();
		vector<int> oioNodeIndices = elNIL->OtherIONodeIndices();

		spMatrix A_X (n_oios, n_unks);
		for (int j = 0; j < n_oios; j++) {
            if (0 == oioTypes[j].compare("i")) {
				oioNames[j].insert(0, prefix);
				unk_names += oioNames[j];
				n_unks++;
				// A_X.resize(n_oios, n_unks);
				A_X = resize(A_X, n_oios, n_unks);
				A_X(j, n_unks-1) = 1.0;

				// KCL-p += ipn;
				// KCL-n -= ipn; // ipn is unk_names[n_unks-1]
				// A_fx.resize(n_eqns, n_unks);
				A_fx = resize(A_fx, n_eqns, n_unks);
				int pid = node_indices_in_x[oioNodeIndices[j]];
				if (pid >= 0) {
					A_fx(pid, n_unks-1) += +1.0;
				}
				int nid = refnode_idx_in_x;
				if (nid >= 0) {
					A_fx(nid, n_unks-1) += -1.0;
				}
			} else { // 0 == oioTypes[j].compare("v")
				// vpn = e_p - e_n;
				int pid = node_indices_in_x[oioNodeIndices[j]];
				if (pid >= 0) {
					A_X(j, pid) += +1.0;
				}
				int nid = refnode_idx_in_x;
				if (nid >= 0) {
					A_X(j, nid) += -1.0;
				}
			}
		}

		//////////////////////////////////////////////////////////////////////
		// Step 1.3: look at vecY, set up A_Y, append to unk_names
        vector<string> intUnkNames = elModel->InternalUnkNames();
		int n_intUnks = intUnkNames.size();
		n_unks += n_intUnks;
		spMatrix A_Y (n_intUnks, n_unks);
		for (int j = 0; j < n_intUnks; j++) {
			intUnkNames[j].insert(0, prefix); // TODO: make sure
			unk_names += intUnkNames[j];
			A_Y(j, n_unks - n_intUnks + j) = 1.0;
		}

		//////////////////////////////////////////////////////////////////////
		// Step 1.4: look at vecLim, set up A_Lim, append to limited_var_names
		spMatrix A_Lim;
        if (elModel->support_initlimiting()) {
			vector<string> limitedVarNames = elModel->LimitedVarNames();
			int n_limitedVars = limitedVarNames.size();
			n_limited_vars += n_limitedVars;
			A_Lim.resize(n_limitedVars, n_limited_vars);
			for (int j = 0; j < n_limitedVars; j++) {
				limitedVarNames[j].insert(0, prefix);
				limited_var_names += limitedVarNames[j];
				A_Lim(j, n_limited_vars - n_limitedVars + j) = 1.0;
			}
		}

		//////////////////////////////////////////////////////////////////////
		// Step 1.5: look at vecU, set up A_U, append to input_names
		vector<string> UNames = elModel->uNames();
		int n_Us = UNames.size();
		n_inputs += n_Us;
		spMatrix A_U (n_Us, n_inputs);
		for (int j = 0; j < n_Us; j++) {
			UNames[j].insert(0, prefix);
			input_names += UNames[j];
			A_U(j, n_inputs - n_Us + j) = 1.0;
		}

		//////////////////////////////////////////////////////////////////////
		// Step 1.6: look at vecZ, set up A_Z, A_fx, append to eqn_names if needed
		vector<string> eoNames = elModel->ExplicitOutputNames();
		int n_eos = eoNames.size();
		vector<string> eoTypes = elNIL->ExplicitOutputTypes();
		vector<int> eoNodeIndices = elNIL->ExplicitOutputNodeIndices();

		spMatrix A_Z (n_eqns, n_eos);
		for (int j = 0; j < n_eos; j++) {
            if (0 == eoTypes[j].compare("i")) {
				// KCL_p += ipn;
				// KCL_n -= ipn;
				int pid = node_indices_in_x[oioNodeIndices[j]];
				if (pid >= 0) {
					A_Z(pid, j) += +1.0;
				}
				int nid = refnode_idx_in_x;
				if (nid >= 0) {
					A_Z(nid, j) += -1.0;
				}
			} else { // 0 == eoTypes[j].compare("v")
				eoNames[j].insert(0, prefix);
				eqn_names += eoNames[j];
				// vpn - e_p + e_n = 0
				n_eqns++;
				// A_Z.resize(n_eqns, n_eos);
				A_Z = resize(A_Z, n_eqns, n_eos);
				A_Z(n_eqns-1, j) = 1.0;

				// A_fx.resize(n_eqns, n_unks);
				A_fx = resize(A_fx, n_eqns, n_unks);
				int pid = node_indices_in_x[oioNodeIndices[j]];
				if (pid >= 0) {
					A_fx(n_eqns-1, pid) += -1.0;
				}
				int nid = refnode_idx_in_x;
				if (nid >= 0) {
					A_fx(n_eqns-1, nid) += +1.0;
				}
			}
		}

		//////////////////////////////////////////////////////////////////////
		// Step 1.7: look at vecW, set up A_W, append to eqn_names
		vector<string> implicitEqnNames = elModel->ImplicitEquationNames();
		int n_implicitEqns = implicitEqnNames.size();
		n_eqns += n_implicitEqns;
		spMatrix A_W (n_eqns, n_implicitEqns);
		for (int j = 0; j < n_implicitEqns; j++) {
			implicitEqnNames[j].insert(0, prefix);
			eqn_names += implicitEqnNames[j];
			A_W(n_eqns - n_implicitEqns + j, j) = 1.0;
		}

		//////////////////////////////////////////////////////////////////////
		// Step 1.8: update MNA_elementdata

		MNA_elementdata * eldata = new MNA_elementdata(A_X, A_Y, A_Lim, A_U, A_Z, A_W);
		MNA_circuitdata += eldata;
	} // end of first loop through devices

	///////////////////////////////////////////////////////////////////////////
	// Step 2: second loop through devices, resizing all MNA_circuitdata index
	//         matrices
	///////////////////////////////////////////////////////////////////////////
	int nx = n_unks;
	int nu = n_inputs;
	int nxlim = n_limited_vars;
	int nfq = n_eqns;
	for (int i = 0; i < cktnetlistPtr->elements.size(); i++) {
		int nvecX = cktnetlistPtr->elements[i]->ModSpecPtr->OtherIONames().size();
		int nvecY = cktnetlistPtr->elements[i]->ModSpecPtr->InternalUnkNames().size();
		int nvecU = cktnetlistPtr->elements[i]->ModSpecPtr->uNames().size();
		int nvecZ = cktnetlistPtr->elements[i]->ModSpecPtr->ExplicitOutputNames().size();
		int nvecW = cktnetlistPtr->elements[i]->ModSpecPtr->ImplicitEquationNames().size();
		int nvecLim = cktnetlistPtr->elements[i]->ModSpecPtr->LimitedVarNames().size();

		// MNA_circuitdata[i]->A_X.resize(nvecX, nx);
		// MNA_circuitdata[i]->A_X.resize(nvecX, nx);
		// MNA_circuitdata[i]->A_Y.resize(nvecY, nx);
		// MNA_circuitdata[i]->A_Lim.resize(nvecLim, nxlim);
		// MNA_circuitdata[i]->A_U.resize(nvecU, nu);
		// MNA_circuitdata[i]->A_Z.resize(nfq, nvecZ);
		// MNA_circuitdata[i]->A_W.resize(nfq, nvecW);

		MNA_circuitdata[i]->A_X = resize(MNA_circuitdata[i]->A_X, nvecX, nx);
		MNA_circuitdata[i]->A_Y = resize(MNA_circuitdata[i]->A_Y, nvecY, nx);
		MNA_circuitdata[i]->A_Lim = resize(MNA_circuitdata[i]->A_Lim, nvecLim, nxlim);
		MNA_circuitdata[i]->A_U = resize(MNA_circuitdata[i]->A_U, nvecU, nu);
		MNA_circuitdata[i]->A_Z = resize(MNA_circuitdata[i]->A_Z, nfq, nvecZ);
		MNA_circuitdata[i]->A_W = resize(MNA_circuitdata[i]->A_W, nfq, nvecW);

		if (0) {
			cout << "ELement: " << cktnetlistPtr->elements[i]->name << endl;
			cout << "A_X: " << MNA_circuitdata[i]->A_X << endl;
			cout << "A_Y: " << MNA_circuitdata[i]->A_Y << endl;
			cout << "A_Lim: " << MNA_circuitdata[i]->A_Lim << endl;
			cout << "A_U: " << MNA_circuitdata[i]->A_U << endl;
			cout << "A_Z: " << MNA_circuitdata[i]->A_Z << endl;
			cout << "A_W: " << MNA_circuitdata[i]->A_W << endl;
		}
	} // end of second loop through devices

	// A_fx.resize(nfq, nx);
	A_fx = resize(A_fx, nfq, nx);

	///////////////////////////////////////////////////////////////////////////
	// Step 3: a small third loop through devices, set up x_to_xlim_matrix
	///////////////////////////////////////////////////////////////////////////
	x_to_xlim_matrix.resize(n_limited_vars, n_unks);
	for (int i = 0; i < cktnetlistPtr->elements.size(); i++) {
		ModSpec_Element * elModel = cktnetlistPtr->elements[i]->ModSpecPtr;
		if (elModel->support_initlimiting()) {
            spMatrix vecXY_to_vecLim = elModel->vecXYtoLimitedVarsMatrix();
			spMatrix A_X = MNA_circuitdata[i]->A_X;
			spMatrix A_Y = MNA_circuitdata[i]->A_Y;
			spMatrix A_Lim = MNA_circuitdata[i]->A_Lim;
			int nvecLim = elModel->LimitedVarNames().size();
			int nvecX = elModel->OtherIONames().size();
			int nvecY = elModel->InternalUnkNames().size();
			// x_to_xlim_matrix += A_Lim.'*vecXY_to_vecLim*[A_X;A_Y];
			spMatrix vecX_to_vecLim = subslice(vecXY_to_vecLim, 0, 1, nvecLim, 0, 1, nvecX);
			spMatrix vecY_to_vecLim = subslice(vecXY_to_vecLim, 0, 1, nvecLim, nvecX, 1, nvecY);
			spMatrix oof1 = prod(vecX_to_vecLim, A_X);
			spMatrix oof2 = prod(vecY_to_vecLim, A_Y);
			spMatrix oof3 = oof1 + oof2;
			x_to_xlim_matrix += prod(trans(A_Lim), oof3);
		}
	} // end of third loop through devices
}

// destructor
MNA_DAE::~MNA_DAE() {
	for (int i = 0; i <  MNA_circuitdata.size(); i++) {
		delete MNA_circuitdata[i];
	}
}

// printing routine for debug
void MNA_DAE::print() {
	cout << "printing : xTOxlimMatrix()" << endl;
	cout << "  " << xTOxlimMatrix() << endl;
	cout << endl;
	cout << "printing MNA_circuitdata[i]: " << endl;
	cout << "  A_fx: " << A_fx << endl;
	for (int i = 0; i < cktnetlistPtr->elements.size(); i++) {
		netlistElement * el = cktnetlistPtr->elements[i];
		ModSpec_Element * elModel = el->ModSpecPtr;
		string elName = cktnetlistPtr->elements[i]->name;
		printf("  MNA_elementdata for %s: \n", elName.c_str());
		cout << "    A_X: " << MNA_circuitdata[i]->A_X << endl;
		cout << "    A_Y: " << MNA_circuitdata[i]->A_Y << endl;
		cout << "    A_U: " << MNA_circuitdata[i]->A_U << endl;
		cout << "    A_Lim: " << MNA_circuitdata[i]->A_Lim << endl;
		cout << "    A_Z: " << MNA_circuitdata[i]->A_Z << endl;
		cout << "    A_W: " << MNA_circuitdata[i]->A_W << endl;
	} // end of loop through devices
}

// fq/init/limiting-related internal functions
vector<double> MNA_DAE::fq(vector<double>& x, vector<double>& xlim, vector<double>& u, char fORq) {
	// f += A_fx * x;
	//		vecX = A_X * x;
	//		vecY = A_Y * x;
	//		vecLim = A_Lim * xlim;
	//		vecU = A_U * u;
	//
	//		f/q += A_Z * vecZ;
	//		f/q += A_W * vecW;
	vector<double> out(neqns());
	for (int i = 0; i < cktnetlistPtr->elements.size(); i++) {
		netlistElement * el = cktnetlistPtr->elements[i];
		ModSpec_Element * elModel = el->ModSpecPtr;
		spMatrix A_X = MNA_circuitdata[i]->A_X;
		spMatrix A_Y = MNA_circuitdata[i]->A_Y;
		spMatrix A_U = MNA_circuitdata[i]->A_U;
		spMatrix A_Lim = MNA_circuitdata[i]->A_Lim;
		spMatrix A_Z = MNA_circuitdata[i]->A_Z;
		spMatrix A_W = MNA_circuitdata[i]->A_W;
		vector<double> vecX = prod(A_X, x);
		vector<double> vecY = prod(A_Y, x);
		vector<double> vecU;
		if (fORq == 'f') {
			vecU = prod(A_U, u);
		}
		vector<double> vecZ;
		vector<double> vecW;
		if (fORq == 'f') {
			if (elModel->support_initlimiting()) {
				vector<double> vecLim = prod(A_Lim, xlim);
				vecZ = elModel->fe(vecX, vecY, vecLim, vecU);
				vecW = elModel->fi(vecX, vecY, vecLim, vecU);
			} else {
				vecZ = elModel->fe(vecX, vecY, vecU);
				vecW = elModel->fi(vecX, vecY, vecU);
			}
		} else {
			if (elModel->support_initlimiting()) {
				vector<double> vecLim = prod(A_Lim, xlim);
				vecZ = elModel->qe(vecX, vecY, vecLim);
				vecW = elModel->qi(vecX, vecY, vecLim);
			} else {
				vecZ = elModel->qe(vecX, vecY);
				vecW = elModel->qi(vecX, vecY);
			}
		}
		out = add(out, prod(A_Z, vecZ));
		out = add(out, prod(A_W, vecW));
	} // end of loop through devices
	if (fORq == 'f') {
		out = add(out, prod(A_fx, x));
	}
	return out;
}
spMatrix MNA_DAE::dfq(vector<double>& x, vector<double>& xlim, vector<double>& u, char fORq, char xlORu) {
	// dfq_dx
	//   dfq_dx += A_fx
	//   for each element
	//   dfq_dx += A_Z * dfqe_dvecX * A_X
	//   dfq_dx += A_Z * dfqe_dvecY * A_Y
	//   dfq_dx += A_W * dfqi_dvecX * A_X
	//   dfq_dx += A_W * dfqi_dvecY * A_Y
	// dfq_du
	//   for each element
	//   dfq_du += A_Z * dfqe_dvecU * A_U
	//   dfq_du += A_W * dfqi_dvecU * A_U
	// dfq_dxlim
	//   for each element
	//   dfq_dxlim += A_Z * dfqe_dvecLim * A_Lim
	//   dfq_dxlim += A_W * dfqi_dvecLim * A_Lim

	int nvars;
	if (xlORu == 'x') {
		nvars = nunks();
	} else if (xlORu == 'u') {
		nvars = ninputs();
	} else { // xlORu == 'l'
		nvars = nlimitedvars();
	}
	spMatrix Jout (neqns(), nvars);

	for (int i = 0; i < cktnetlistPtr->elements.size(); i++) {
		netlistElement * el = cktnetlistPtr->elements[i];
		ModSpec_Element * elModel = el->ModSpecPtr;
		spMatrix A_X = MNA_circuitdata[i]->A_X;
		spMatrix A_Y = MNA_circuitdata[i]->A_Y;
		spMatrix A_U = MNA_circuitdata[i]->A_U;
		spMatrix A_Lim = MNA_circuitdata[i]->A_Lim;
		spMatrix A_Z = MNA_circuitdata[i]->A_Z;
		spMatrix A_W = MNA_circuitdata[i]->A_W;
		vector<double> vecX = prod(A_X, x);
		vector<double> vecY = prod(A_Y, x);
		vector<double> vecU;
		if (fORq == 'f') {
			vecU = prod(A_U, u);
		}
		if (fORq == 'f') {
			if (xlORu == 'x') {
				if (elModel->support_initlimiting()) {
					vector<double> vecLim = prod(A_Lim, xlim);
					spMatrix dvecZ_dvecX = elModel->dfe_dvecX(vecX, vecY, vecLim, vecU);
					spMatrix dvecW_dvecX = elModel->dfi_dvecX(vecX, vecY, vecLim, vecU);
					spMatrix dvecZ_dvecY = elModel->dfe_dvecY(vecX, vecY, vecLim, vecU);
					spMatrix dvecW_dvecY = elModel->dfi_dvecY(vecX, vecY, vecLim, vecU);
					spMatrix oof1 = prod(A_Z, dvecZ_dvecX);
					Jout += prod(oof1, A_X);
					// Jout += prod(prod(A_Z, dvecZ_dvecX), A_X);
					spMatrix oof2 = prod(A_Z, dvecZ_dvecY);
					Jout += prod(oof2, A_Y);
					// Jout += prod(prod(A_Z, dvecZ_dvecY), A_Y);
					spMatrix oof3 = prod(A_W, dvecW_dvecX);
					Jout += prod(oof3, A_X);
					// Jout += prod(prod(A_W, dvecW_dvecX), A_X);
					spMatrix oof4 = prod(A_W, dvecW_dvecY);
					Jout += prod(oof4, A_Y);
					// Jout += prod(prod(A_W, dvecW_dvecY), A_Y);
				} else {
					spMatrix dvecZ_dvecX = elModel->dfe_dvecX(vecX, vecY, vecU);
					spMatrix dvecW_dvecX = elModel->dfi_dvecX(vecX, vecY, vecU);
					spMatrix dvecZ_dvecY = elModel->dfe_dvecY(vecX, vecY, vecU);
					spMatrix dvecW_dvecY = elModel->dfi_dvecY(vecX, vecY, vecU);
					spMatrix oof1 = prod(A_Z, dvecZ_dvecX);
					Jout += prod(oof1, A_X);
					spMatrix oof2 = prod(A_Z, dvecZ_dvecY);
					Jout += prod(oof2, A_Y);
					spMatrix oof3 = prod(A_W, dvecW_dvecX);
					Jout += prod(oof3, A_X);
					spMatrix oof4 = prod(A_W, dvecW_dvecY);
					Jout += prod(oof4, A_Y);
				}
			} else if (xlORu == 'u') {
				if (elModel->support_initlimiting()) {
					vector<double> vecLim = prod(A_Lim, xlim);
					spMatrix dvecZ_dvecU = elModel->dfe_dvecU(vecX, vecY, vecLim, vecU);
					spMatrix dvecW_dvecU = elModel->dfi_dvecU(vecX, vecY, vecLim, vecU);
					spMatrix oof1 = prod(A_Z, dvecZ_dvecU);
					Jout += prod(oof1, A_U);
					spMatrix oof2 = prod(A_W, dvecW_dvecU);
					Jout += prod(oof2, A_U);
				} else {
					spMatrix dvecZ_dvecU = elModel->dfe_dvecU(vecX, vecY, vecU);
					spMatrix dvecW_dvecU = elModel->dfi_dvecU(vecX, vecY, vecU);
					spMatrix oof1 = prod(A_Z, dvecZ_dvecU);
					Jout += prod(oof1, A_U);
					spMatrix oof2 = prod(A_W, dvecW_dvecU);
					Jout += prod(oof2, A_U);
				}
			} else {
				if (elModel->support_initlimiting()) {
					vector<double> vecLim = prod(A_Lim, xlim);
					spMatrix dvecZ_dvecLim = elModel->dfe_dvecLim(vecX, vecY, vecLim, vecU);
					spMatrix dvecW_dvecLim = elModel->dfi_dvecLim(vecX, vecY, vecLim, vecU);
					spMatrix oof1 = prod(A_Z, dvecZ_dvecLim);
					Jout += prod(oof1, A_Lim);
					spMatrix oof2 = prod(A_W, dvecW_dvecLim);
					Jout += prod(oof2, A_Lim);
				}
			}
		} else { // fORq == 'q'
			if (xlORu == 'x') {
				if (elModel->support_initlimiting()) {
					vector<double> vecLim = prod(A_Lim, xlim);
					spMatrix dvecZ_dvecX = elModel->dqe_dvecX(vecX, vecY, vecLim);
					spMatrix dvecW_dvecX = elModel->dqi_dvecX(vecX, vecY, vecLim);
					spMatrix dvecZ_dvecY = elModel->dqe_dvecY(vecX, vecY, vecLim);
					spMatrix dvecW_dvecY = elModel->dqi_dvecY(vecX, vecY, vecLim);
					spMatrix oof1 = prod(A_Z, dvecZ_dvecX);
					Jout += prod(oof1, A_X);
					spMatrix oof2 = prod(A_Z, dvecZ_dvecY);
					Jout += prod(oof2, A_Y);
					spMatrix oof3 = prod(A_W, dvecW_dvecX);
					Jout += prod(oof3, A_X);
					spMatrix oof4 = prod(A_W, dvecW_dvecY);
					Jout += prod(oof4, A_Y);
				} else {
					spMatrix dvecZ_dvecX = elModel->dqe_dvecX(vecX, vecY);
					spMatrix dvecW_dvecX = elModel->dqi_dvecX(vecX, vecY);
					spMatrix dvecZ_dvecY = elModel->dqe_dvecY(vecX, vecY);
					spMatrix dvecW_dvecY = elModel->dqi_dvecY(vecX, vecY);
					spMatrix oof1 = prod(A_Z, dvecZ_dvecX);
					Jout += prod(oof1, A_X);
					spMatrix oof2 = prod(A_Z, dvecZ_dvecY);
					Jout += prod(oof2, A_Y);
					spMatrix oof3 = prod(A_W, dvecW_dvecX);
					Jout += prod(oof3, A_X);
					spMatrix oof4 = prod(A_W, dvecW_dvecY);
					Jout += prod(oof4, A_Y);
				}
			} else if (xlORu == 'u') { // error
			} else { // xlORu == 'l'
				if (elModel->support_initlimiting()) {
					vector<double> vecLim = prod(A_Lim, xlim);
					spMatrix dvecZ_dvecLim = elModel->dqe_dvecLim(vecX, vecY, vecLim);
					spMatrix dvecW_dvecLim = elModel->dqi_dvecLim(vecX, vecY, vecLim);
					spMatrix oof1 = prod(A_Z, dvecZ_dvecLim);
					Jout += prod(oof1, A_Lim);
					spMatrix oof2 = prod(A_W, dvecW_dvecLim);
					Jout += prod(oof2, A_Lim);
				}
			}
		} // end of f/q
	} // end of loop through devices
	if (fORq == 'f' && xlORu == 'x') {
		Jout += A_fx;
	}
	return Jout;
}

vector<double> MNA_DAE::init_limiting(vector<double>& x, vector<double>& xlimOld, vector<double>& u, char iORl) {
//  - init limiting dlimiting calculation:
//  1. get vecX, vecY, vecLim, vecU from x and u and xlim
//  2. calculate vecLimInit, vecLimNew
//  3. contribution to out: 
//  vecLimTOxlim = A_Lim.' // TODO: simplification made
//     out = vecLimTOxlim * vecLim
//  4. derivatives --> dlimiting_dx
//     dout += vecLimTOxlim * dlimiting_dvecX * xTOvecX
//     dout += vecLimTOxlim * dlimiting_dvecY * xTOvecY

	vector<double> out(nlimitedvars());
	for (int i = 0; i < cktnetlistPtr->elements.size(); i++) {
		netlistElement * el = cktnetlistPtr->elements[i];
		ModSpec_Element * elModel = el->ModSpecPtr;
		spMatrix A_X = MNA_circuitdata[i]->A_X;
		spMatrix A_Y = MNA_circuitdata[i]->A_Y;
		spMatrix A_U = MNA_circuitdata[i]->A_U;
		spMatrix A_Lim = MNA_circuitdata[i]->A_Lim;
		spMatrix A_Z = MNA_circuitdata[i]->A_Z;
		spMatrix A_W = MNA_circuitdata[i]->A_W;
		if (elModel->support_initlimiting()) {
			if (iORl == 'i') {
				vector<double> vecU = prod(A_U, u);
				vector<double> vecLimInit = elModel->initGuess(vecU);
				out = add(out, prod(trans(A_Lim), vecLimInit));
			} else { //iORl == 'l'
				vector<double> vecX = prod(A_X, x);
				vector<double> vecY = prod(A_Y, x);
				vector<double> vecU = prod(A_U, u);
				vector<double> vecLimOld = prod(A_Lim, xlimOld);

				vector<double> vecLimNew = elModel->limiting(vecX, vecY, vecLimOld, vecU);
				out = add(out, prod(trans(A_Lim), vecLimNew));
			}
		}
	} // end of loop through devices
	return out;
}
spMatrix MNA_DAE::dlimiting(vector<double>& x, vector<double>& xlimOld, vector<double>& u, char xORu) {
	int nvars;
	if (xORu == 'x') {
		nvars = nunks();
	} else { // xORu == 'u'
		nvars = ninputs();
	}
	spMatrix Jout (nlimitedvars(), nvars);
	for (int i = 0; i < cktnetlistPtr->elements.size(); i++) {
		netlistElement * el = cktnetlistPtr->elements[i];
		ModSpec_Element * elModel = el->ModSpecPtr;
		spMatrix A_X = MNA_circuitdata[i]->A_X;
		spMatrix A_Y = MNA_circuitdata[i]->A_Y;
		spMatrix A_U = MNA_circuitdata[i]->A_U;
		spMatrix A_Lim = MNA_circuitdata[i]->A_Lim;
		spMatrix A_Z = MNA_circuitdata[i]->A_Z;
		spMatrix A_W = MNA_circuitdata[i]->A_W;
		if (elModel->support_initlimiting()) {
			if (xORu == 'x') {
				vector<double> vecX = prod(A_X, x);
				vector<double> vecY = prod(A_Y, x);
				vector<double> vecU = prod(A_U, u);
				vector<double> vecLimOld = prod(A_Lim, xlimOld);
				spMatrix dlimiting_dvecX = elModel->dlimiting_dvecX(vecX, vecY, vecLimOld, vecU);
				spMatrix dlimiting_dvecY = elModel->dlimiting_dvecY(vecX, vecY, vecLimOld, vecU);
				spMatrix oof1 = prod(trans(A_Lim), dlimiting_dvecX);
				Jout += prod(oof1, A_X);
				spMatrix oof2 = prod(trans(A_Lim), dlimiting_dvecY);
				Jout += prod(oof2, A_Y);
			} else { // xORu == 'u'
				vector<double> vecX = prod(A_X, x);
				vector<double> vecY = prod(A_Y, x);
				vector<double> vecU = prod(A_U, u);
				vector<double> vecLimOld = prod(A_Lim, xlimOld);
				// spMatrix dlimiting_dvecU = elModel->dlimiting_dvecU(vecX, vecY, vecLimOld, vecU); // TODO: important, ModSpec_Element doesn't have dlimiting_dvecU yet. Should fix both Matlab and C++ versions for this.
				spMatrix dlimiting_dvecU(vecLimOld.size(), vecU.size());
				spMatrix oof1 = prod(trans(A_Lim), dlimiting_dvecU);
				Jout += prod(oof1, A_U);
			}
		}
	} // end of loop through devices
	return Jout;
}

// DAEAPI fields with common add_ons 
string MNA_DAE::daename() {
	return dae_name;
}

string MNA_DAE::uniqID() {
	return uniq_ID;
}

string MNA_DAE::version() {
	return dae_version;
}

int MNA_DAE::nparms() {
	return parm_names.size();
}

vector<string> MNA_DAE::parmnames() {
	return parm_names;
}

vector<untyped> MNA_DAE::parmdefaults() {
	return parm_defaultvals;
}

vector<untyped> MNA_DAE::getparms() { // TODO
	vector<untyped> parm_vals;
	return parm_vals;
} 

untyped MNA_DAE::getparm(string& parm) { // TODO
	untyped retval;
	// int idx = findparm(parm);
	// retval = parm_vals[idx];
	return retval;
}

void MNA_DAE::setparms(vector<untyped>& a) { // TODO
	// parm_vals = a;
}

void MNA_DAE::setparm(string& parm, untyped& val) { // TODO
	// int idx = findparm(parm);
	// parm_vals[idx] = val;
}

int MNA_DAE::nunks() {
	return unk_names.size();
}

int MNA_DAE::neqns() {
	return eqn_names.size();
}

int MNA_DAE::ninputs() {
	return input_names.size();
}

int MNA_DAE::noutputs() {
	return output_names.size();
}

int MNA_DAE::nNoiseSources() {
	return NoiseSource_names.size();
}

vector<string> MNA_DAE::unknames() {
	return unk_names;
}

vector<string> MNA_DAE::eqnnames() {
	return eqn_names;
}

vector<string> MNA_DAE::inputnames() {
	return input_names;
}

vector<string> MNA_DAE::outputnames() {
	return output_names;
}

vector<string> MNA_DAE::NoiseSourcenames() {
	return NoiseSource_names;
}

spMatrix MNA_DAE::C() {
	return Cmat;
}

spMatrix MNA_DAE::D() {
	return Dmat;
}

bool MNA_DAE::support_initlimiting() {
	return true;
};

vector<string> MNA_DAE::limitedvarnames() {
	return limited_var_names;
}

int MNA_DAE::nlimitedvars() {
	return limited_var_names.size();
}

spMatrix MNA_DAE::xTOxlimMatrix() {
	return x_to_xlim_matrix;
}

// DAEAPI core/init/limiting function fields 
vector<double> MNA_DAE::f(vector<double>& x, vector<double>& u) {
	vector<double> xlim = prod(xTOxlimMatrix(), x);
	return f(x, xlim, u); 
}

vector<double> MNA_DAE::q(vector<double>& x) {
	vector<double> xlim = prod(xTOxlimMatrix(), x);
	return q(x, xlim); 
}

spMatrix MNA_DAE::df_dx(vector<double>& x, vector<double>& u) {
	vector<double> xlim = prod(xTOxlimMatrix(), x);
	spMatrix Jout = df_dx(x, xlim, u) + prod(df_dxlim(x, xlim, u), xTOxlimMatrix());
	return Jout;
}

spMatrix MNA_DAE::df_du(vector<double>& x, vector<double>& u) {
	vector<double> xlim = prod(xTOxlimMatrix(), x);
	spMatrix Jout = df_du(x, xlim, u);
	return Jout;
}

spMatrix MNA_DAE::dq_dx(vector<double>& x) {
	vector<double> xlim = prod(xTOxlimMatrix(), x);
	spMatrix Jout = dq_dx(x, xlim) + prod(dq_dxlim(x, xlim), xTOxlimMatrix());
	return Jout;
}

vector<double> MNA_DAE::f(vector<double>& x, vector<double>& xlim, vector<double>& u) {
	return fq(x, xlim, u, 'f');
}

vector<double> MNA_DAE::q(vector<double>& x, vector<double>& xlim) {
	vector<double> u;
	return fq(x, xlim, u, 'q');
}

spMatrix MNA_DAE::df_dx(vector<double>& x, vector<double>& xlim, vector<double>& u) {
	return dfq(x, xlim, u, 'f', 'x');
}

spMatrix MNA_DAE::df_dxlim(vector<double>& x, vector<double>& xlim, vector<double>& u) {
	return dfq(x, xlim, u, 'f', 'l');
}

spMatrix MNA_DAE::df_du(vector<double>& x, vector<double>& xlim, vector<double>& u) {
	return dfq(x, xlim, u, 'f', 'u');
}

spMatrix MNA_DAE::dq_dx(vector<double>& x, vector<double>& xlim) {
	vector<double> u;
	return dfq(x, xlim, u, 'q', 'x');
}

spMatrix MNA_DAE::dq_dxlim(vector<double>& x, vector<double>& xlim) {
	vector<double> u;
	return dfq(x, xlim, u, 'q', 'l');
}

vector<double> MNA_DAE::NRinitGuess(vector<double>& u) {
	vector<double> x;
	vector<double> xlimOld;
	return init_limiting(x, xlimOld, u, 'i');
}

vector<double> MNA_DAE::NRlimiting(vector<double>& x, vector<double>& xlimOld, vector<double>& u) {
	return init_limiting(x, xlimOld, u, 'l');
}

spMatrix MNA_DAE::dNRlimiting_dx(vector<double>& x, vector<double>& xlimOld, vector<double>& u) {
// for use in an obsolete NR method that is not working, shouldn't be used anywhere now
	return dlimiting(x, xlimOld, u, 'x');
}

spMatrix MNA_DAE::dNRlimiting_du(vector<double>& x, vector<double>& xlimOld, vector<double>& u) {
// for use in an obsolete NR method that is not working, shouldn't be used anywhere now
	return dlimiting(x, xlimOld, u, 'u');
}

// Internal utility functions below

int MNA_DAE::findstring(string& str, vector<string>& strarray) {
	int retval = -1;
	// find index of str in strarray
	vector<string>::iterator vsIter; // std::find returns this type
		// see http://www.cprogramming.com/tutorial/stl/iterators.html

	vsIter = find(strarray.begin(), strarray.end(), str);
	if (vsIter != strarray.end()) {
		// found; set it
		retval = vsIter - strarray.begin();
	} else {
		// fprintf(stderr, "str %s not found in strarray\n", str.c_str());
	}

	return retval;
}

void MNA_DAE::vecstrcat(string& str, vector<string>& strarray) {
// not used any more
	for (int i = 0; i < strarray.size(); i++) {
		strarray[i].insert(0, str); // TODO: make sure
	}
	return;
}

void MNA_DAE::vecstrcat(vector<string>& strarray, string& str) {
// not used any more
	for (int i = 0; i < strarray.size(); i++) {
		strarray[i] += str;
	}
	return;
}
