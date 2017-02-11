#include "DAAV6_ModSpec_Element.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

/* 
 * the device: Dimitri Antoniadis' Virtual Source model, DAAV6 version.
 *
 * topology:
 * - the external nodes are d, g, s, b
 * - there are 2 internal nodes: di and si
 *
 * unknowns:
 * 	n = 3, 2n = 6
 * 	NIL.NodeNames = "d", "g", "s", "b"
 * 	NIL.RefNodeName = "b"
 * 	[IOnames = "vdb", "vgb", "vsb", "idb", "igb", "isb"]
 * 	l = 3
 * 	ExplicitIOnames = "idb", "igb", "isb"
 * 		=> vecZ = [idb; igb; isb];
 * 	[OtherIOnames = "vdb", "vgb", "vsb"]
 * 	FIXME: HERE HERE HERE
 * 		=> vecX = [vn1n3; in2n3]
 * 	m = 0
 * 	ImplicitEquationNames = {}
 * 		=> vecW = []
 *
 * equations:
 * 	ExplicitOutputs:
 *
 * parameters:
*/

// constructor
DAAV6_ModSpec_Element::DAAV6_ModSpec_Element(): ModSpec_Element_with_Jacobians() {
	// parm_names
	this->parm_names += 
		"tipe",   	 // 'n' or 'p'
		"W",      	 // Width [cm]
		"Lg",	   	 // Gate length [cm]
		"dLg",    	 // dLg=L_g-L_c (default 0.3xLg_nom)
		"Cg",     	 // Gate cap [F/cm^2]
		"delta",  	 // DIBL [V/V]
		"S",      	 // Subthreshold swing [V/decade] OBSOLETE?
		"Ioff",   	 // Adjusted from Transfer Id-Vg OBSOLETE?
		"Vdd",    	 // Vd [V] corresponding to Ioff OBSOLETE?
		"Vgoff",  	 // Vg [V] corresponding to Ioff (typ. 0V) OBSOLETE?
		"Rs",     	 // Rs [ohm-micron] 
		"Rd",     	 // Rd [ohm-micron] 
		"vxo",    	 // Virtual source velocity [cm/s]
		"mu",     	 // Mobility [cm^2/V.s]
		"beta",   	 // Saturation factor. Typ. nFET=1.8, pFET=1.4
		"phit",   	 // kT/q assuming T=27 C.                      
		"gamma",  	 // Body factor  [sqrt(V)]
		"phib",   	 // =abs(2*phin)>0 [V]
		"smoothing",  	 // smoothing parameter for smoothing funcs
		"expMaxslope";  // max slope for safeexp
	
	// parm_types += "double", "double", "double";

	// parm_defaultvals.push_back(n);
	this->parm_defaultvals += 
		"n", 	   // NFET - can  also be 'p' for PFET
		1.0e-4,    // W: Width [cm]
		35e-7,     // Lg: Gate length [cm]
		0.3*35e-7, // dLg=L_g-L_c (default {0.3,0.25}xLg_nom) {n,p}
		1.83e-6,   // Cg: Gate cap [F/cm^2] (p: 1.70e-6)
		0.120,     // delta: DIBL [V/V] (p: 0.155)
		0.100,     // S: Subthreshold swing [V/decade]
		100e-9,    // Ioff: Adjusted from Transfer Id-Vg
		1.2,       // Vdd: Vd [V] corresponding to Ioff
		0.0,         // Vgoff: Vg [V] corresponding to Ioff (typ. 0V)
		80.0,        // Rs [ohm-micron] (p: 130)
		80.0,        // Rd [ohm-micron] (assume Rs=Rd) (p: 130)
		1.4e7,     // vxo: Virtual source velocity [cm/s] (p: 0.85e7)
		250.0,       // mu: Mobility [cm^2/V.s] (p: 140)
		1.8,       // beta: Saturation factor. Typ. nFET=1.8, pFET=1.4
		0.0256,    // phit: kT/q assuming T=27 C.                     
		0.1,       // gamma
		0.9,       // phib
		1e-20,     // smoothing
		1e50;      // expMaxslope

	// parm_vals
	this->parm_vals = parm_defaultvals;

	// cout << "DAAV6_ModSpec_Element constructor: this->parm_vals[0] is " <<  this->parm_vals[0] << endl;

	/*
	untyped test1 = "n";
	untyped test2("n");
	*/

	this->node_names += "d", "g", "s", "b";
	
	this->refnode_name = "b";
	// io_names; will set up in base class constructor, should
	// be: {'vdb', 'vgb', 'vsb', 'idb', 'igb', 'isb'}
	
	this->explicit_output_names += "idb", "igb", "isb";

	// the following function sets up refnode_index, io_names, otherio_names, io_types
	// io_nodenames, otherio_types, otherio_nodenames, otherio_nodeindices, explicit_output_types,
	// explicit_output_nodenames, and explicit_output_nodeindices.  It uses node_names, refnode_name and 
	// explicit_output_names - make sure these are set up correctly before calling it.
	setup_ios_otherios_types_nodenames_indices(); 
	
	// internal_unk_names:
	this->internal_unk_names += "vdi_b", "vsi_b";

	// implicit_equation_names
	this->implicit_equation_names += "di_KCL", "si_KCL";

	// u_names: empty (set up in base class)
}
//
// fqei_tmpl
template <typename TOUT, typename TX, typename TY, typename TU>
  vector<TOUT> DAAV6_ModSpec_Element::fqei_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU, char eORi, char fORq) {
	vector<TOUT> fqout;

	// inputs: 
	// 	vecX = vdb, vgb, vsb
	// 	vecY = vdi_b, vsi_b
	// outputs:
	// 	vecZ = idb, igb, isb
	// 	vecW = di_KCL, si_KCL

	// set up vecX inputs
	// This is ugly, because we need to hand-code the name order.
	// Ideally, the variable names should be set up automatically according
	// to parm_names; but that would have to be done during runtime, this is
	// probably not possible in C++.
	TX vdb = vecX[0];
	TX vgb = vecX[1];
	TX vsb = vecX[2];

	// set up vecY inputs
	// Similarly, this is ugly
	TY vdi_b = vecY[0];
	TY vsi_b = vecY[1];

	// set up parameters
	// This is ugly because we need to hand-code the parameter types and names. We need
	// some automated way of defining the type using a vector of strings of types.
	// Or, use untyped throughout, and overload all untyped operators - but that will
	// incur runtime overhead.

	// for convenience in passing parameter values to other member functions, 
	// we have made all the parameters protected members of the class. They are
	// being set up here.
	// cout << "DAAV6_ModSpec_Element fqei_tmpl: this->parm_vals[0] is " <<  this->parm_vals[0] << endl;
	tipe   	    = this->parm_vals[0];  // 'n' or 'p'
		// THERE'S STILL A PROBLEM ABOVE
		// ERROR: eString = untyped&: untyped arg is of type INT, value 2000
	W      	    = this->parm_vals[1];  // Width [cm]
	Lg	    = this->parm_vals[2];  // Gate length [cm]
	dLg    	    = this->parm_vals[3];  // dLg=L_g-L_c (default 0.3xLg_nom)
	Cg     	    = this->parm_vals[4];  // Gate cap [F/cm^2]
	delta  	    = this->parm_vals[5];  // DIBL [V/V]
	S      	    = this->parm_vals[6];  // Subthreshold swing [V/decade] OBSOLETE?
	Ioff   	    = this->parm_vals[7];  // Adjusted from Transfer Id-Vg OBSOLETE?
	Vdd    	    = this->parm_vals[8];  // Vd [V] corresponding to Ioff OBSOLETE?
	Vgoff  	    = this->parm_vals[9];  // Vg [V] corresponding to Ioff (typ. 0V) OBSOLETE?
	Rs     	    = this->parm_vals[10]; // Rs [ohm-micron] 
	Rd     	    = this->parm_vals[11]; // Rd [ohm-micron] 
	vxo    	    = this->parm_vals[12]; // Virtual source velocity [cm/s]
	mu     	    = this->parm_vals[13]; // Mobility [cm^2/V.s]
	beta   	    = this->parm_vals[14]; // Saturation factor. Typ. nFET=1.8, pFET=1.4
	phit   	    = this->parm_vals[15]; // kT/q assuming T=27 C.                      
	gamma  	    = this->parm_vals[16]; // Body factor  [sqrt(V)]
	phib   	    = this->parm_vals[17]; // =abs(2*phin)>0 [V]
	smoothing   = this->parm_vals[18]; // smoothing parameter for smoothing funcs
	expMaxslope = this->parm_vals[19]; // max slope for safeexp


	///////////////////////////////////////////
	
	int typemult = (tipe == "n"? 1 : -1);  // 1 if n-type device, -1 if p-type

	// DAAV6 was written originally using node voltages, not branch voltages
	// re-using that code, so defining node voltages
	double vb = 0; // internal reference, arbitrary value
	TOUT vd = vdb + vb;
	TOUT vg = vgb + vb;
	TOUT vs = vsb + vb;
	TOUT vdi = vdi_b + vb;
	TOUT vsi = vsi_b + vb;

	TOUT corevd = typemult*vdi;
	TOUT corevg = typemult*vg;
	TOUT corevs = typemult*vsi;
	TOUT corevb = typemult*vb;

	if (eORi == 'e') { // e => return vecZ
		if (fORq == 'f') { // f
			TOUT ig = 0; 
			// idb (vd - vdi)/Rd
			TOUT fqout1 = (vd - vdi)/Rd;
			// igb
			TOUT fqout2 = typemult*ig;
			// isb (vs - vsi)/Rs
			TOUT fqout3 = (vs - vsi)/Rs;

			fqout += fqout1, fqout2, fqout3;
		} else { // q 
			// [qdi,qg,qsi,qb] = daaV6_core_model_Qs(corevd, corevg, corevs, corevb, mparms);
			TOUT qdi, qg, qsi, qb;
			this->daaV6_core_model_Qs(/* outputs */ qdi, qg, qsi, qb, 
						  /* inputs */  corevd, corevg, corevs, corevb);
			// qb not used because it is redundant: qb = (-qdi-qg-qsi)
			// idb 
			TOUT fqout1 = 0*qg; // no d/dt term in idb contribution
			// igb
			TOUT fqout2 = typemult*qg;
			// isb
			TOUT fqout3 = 0*qg;  // no d/dt term in isb contribution

			fqout += fqout1, fqout2, fqout3;
		}
	} else { // eORi = 'i' => return vecW
		if (fORq == 'f') { // f
			TOUT ig = 0;
			TOUT ib = 0; 
			TOUT idsi = this->daaV6_core_model_Iy(corevd, corevg, corevs, corevb);
			// di_KCL: (vdi - vd)/Rd + idsi
			TOUT fqout1 = (vdi-vd)/Rd + typemult*idsi;
			// si_KCL: (vsi - vs)/Rs - idsi - ig - ib
			TOUT fqout2 = (vsi-vs)/Rs - typemult*(idsi+ig+ib);

			fqout += fqout1, fqout2;
		} else { // q
			// [qdi,qg,qsi,qb] = daaV6_core_model_Qs(corevd, corevg, corevs, corevb, mparms);
			TOUT qdi, qg, qsi, qb;
			this->daaV6_core_model_Qs(/* outputs */ qdi, qg, qsi, qb, 
						  /* inputs */  corevd, corevg, corevs, corevb);
			// qb not used because it is redundant: qb = (-qdi-qg-qsi)
			// di_KCL: d/dt terms
			TOUT fqout1 = typemult*qdi;
			// si_KQL: d/dt terms
			TOUT fqout2 = typemult*qsi;

			fqout += fqout1, fqout2;
		}
	}
	return fqout;
}

template <typename TOUT>
	void DAAV6_ModSpec_Element::daaV6_core_model(/* outputs */ TOUT& Iy, TOUT& Qy, TOUT& Qg, TOUT& Qx, TOUT& Qb,
				     	      /* inputs  */ TOUT Vy, TOUT Vg, TOUT Vx, TOUT Vb, int docurrents, int docharges) {
	// parameter tipe is not used here, but applied in ./daaV6_{f,q,df,dq}func.m

	// from Dimitri's NFET_I_V_Q_2 - these depend only on the parameters
	double n = S/(2.3*phit);
	double Qref=Cg*n*phit;

	double Vt, Vt0;
	this->VT(/* outputs */ Vt, Vt0,
		 /* inputs  */ W,Ioff,Vgoff,Vdd,S,delta,vxo,Qref,phit);

	// from Dimitri's IDC2n_smoothed.m
	double alpha = 3.5;

	// charges are O(fF) = 10^-15, so need to scale smoothing for those
	// smoothabs(0) for charge quantities = sqrt(smoothing*qsmoothingfactor)
	// qsmoothingfactor = 10^-16;
	// but all smoothing seems to be applied to voltage quantities, so
	// there should be no need for this.

        TOUT Vgg=smoothmax((Vg-Vx),(Vg-Vy),smoothing); 
        TOUT Vbb=smoothmax((Vb-Vx),(Vb-Vy),smoothing);
        TOUT Vd=smoothabs(Vy-Vx,smoothing); 		 
        TOUT dir=smoothsign(Vy-Vx,smoothing);        
        TOUT Vt0b=Vt0+gamma*(safesqrt(phib-Vbb,smoothing)-sqrt(phib));

        TOUT FF=1/(1+safeexp((Vgg-(Vt0b-Vd*delta-alpha/2*phit))/(alpha*phit),expMaxslope));
        TOUT eta=(Vgg-(Vt0b-Vd*delta-FF*alpha*phit))/(n*phit);
        TOUT Qinv = Qref*safelog(1+safeexp(eta,expMaxslope),smoothing);
        TOUT Vdsats=vxo*(Lg-dLg)/mu;
        TOUT Vdsat=Vdsats*(1-FF)+phit*FF;
        // Fsat=(Vd./Vdsat)./((1+(Vd./Vdsat).^beta).^(1/beta)); FIXME: ^ is not C++
        TOUT Fsat=(Vd/Vdsat)/(pow(1+pow(Vd/Vdsat,beta),1/beta));

        Iy = dir*W*Qinv*vxo*Fsat; // docurrents == 1 (always happens)
 
	if (1 == docharges) {
            Qx=-W*(Lg-dLg)*Qinv*((1+dir)+(1-dir)*(1-Fsat))/4;
            Qy=-W*(Lg-dLg)*Qinv*((1-dir)+(1+dir)*(1-Fsat))/4;

            TOUT psis=phib+alpha*phit+phit*safelog(safelog(1+exp(eta),smoothing),smoothing); 
            //psis=phib;  %Alternative approximation if above is troublesome!
            Qb=-W*Cg*Lg*gamma*(safesqrt(psis-Vbb,smoothing) +
            	safesqrt(psis-(Vbb-(Vd*(1-Fsat)+Vdsat*Fsat)),smoothing))/2;
            Qg=-(Qx+Qy+Qb);
	} else {
	    Qx = 0; Qy = 0; Qb = 0; Qg = 0;
	}
}

void DAAV6_ModSpec_Element::VT(/* outputs */ double& Vt, double& Vt0,
		               /* inputs  */ double W, double Ioff, double Vgoff, double Vdd, double S, 
			       		     double delta, double vxo, double Qref, double phit) {
	// [Vt, Vt0] = VT(W,Ioff,Vgoff,Vdd,S,delta,vxo,Qref,phit)
	//  this function is copied exactly from Dimitri's file VT.m
	//  Author: Dimitri Antoniadis <daa@mtl.mit.edu> - circa December 2008
	//  Calculate Vt(Vd=Vdd)from Ioff at Vg=Vgoff and Vd=Vdd.
	//  Then calculate Vt0=Vt(Vd=0) by accounting for DIBL.
	//  The Vdd value must be larger than ~3*phit.
	//  It is assumed that Vgoff is in the weak inversion
	Vt = Vgoff + S/2.3*log((W*vxo * Qref)/Ioff);
	double dVt=1;
	double alpha=3.5;
	// note: involves a loop, below
	while (fabs(dVt/Vt)>1e-3) {
	    	double FF=1/(1+exp((Vgoff-(Vt-alpha/2*phit))/(alpha*phit)));
	    	double Vtx=Vgoff+FF*alpha*phit-S/2.3*log(exp(Ioff/(W*vxo*Qref))-1);
	    	dVt=Vtx-Vt;
	    	Vt=Vtx;
	}
	Vt0=Vt+Vdd*delta;
}

// // // // // // // // // // // // // // // // // // // // //

// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element_with_Jacobians* create() {
    return new DAAV6_ModSpec_Element;
}

extern "C" void destroy(ModSpec_Element_with_Jacobians* p) {
    delete p;
}
