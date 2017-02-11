#include "MVS_1_0_1_ModSpec.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
MVS_1_0_1_ModSpec::MVS_1_0_1_ModSpec() {
	// model_name
	model_name = "MVS_1_0_1";

	// element_name
	element_name = "undefined"; // TODO: should get is from outside

	// parm_names
    parm_names += 
        "version", //  MVS model version = 1.0.1
        "type",    //  type of transistor. nFET type=1; pFET type=-1
        "W",       //  Transistor width [cm]
        "Lgdr",    //  Physical gate length [cm]. //   This is the designed gate length for litho printing.
        "dLg",     //  Overlap length including both source and drain sides [cm]  
        "Cg",      //  Gate-to-channel areal capacitance at the virtual source [F/cm^2]
        "etov",    //  Equivalent thickness of dielectric at S/D-G overlap [cm]
        "delta",   //  Drain-induced-barrier-lowering (DIBL) [V/V]
        "n0",      //  Subthreshold swing factor [unit-less] {typically between 1.0 and 2.0}
        "Rs0",     //  Access resistance on s-terminal [Ohms-micron]
        "Rd0",     //  Access resistance on d-terminal [Ohms-micron]
                   //  Generally, Rs0 = Rd0 for symmetric source and drain
        "Cif",     //  Inner fringing S or D capacitance [F/cm] 
        "Cof",     //  Outer fringing S or D capacitance [F/cm] 
        "vxo",     //  Virtual source injection velocity [cm/s]
        "mu",      //  Low-field mobility [cm^2/V.s]
        "beta",    //  Saturation factor. Typ. nFET=1.8, pFET=1.6
        "Tjun",    //  Junction temperature [K]
        "phib",    //  ~abs(2*phif)>0 [V]
        "gamma",   //  Body factor  [sqrt(V)]
        "Vt0",     //  Strong inversion threshold voltage [V] 
        "alpha",   //  Empirical parameter for threshold voltage shift between strong and weak inversion.
        "mc",      //  Choose an appropriate value between 0.01 to 10
                   //  For, values outside of this range,convergence or accuracy of results is not guaranteed
        "CTM_select",  //  If CTM_select = 1, then classic DD-NVSAT model is used
                       //  For CTM_select other than 1,blended DD-NVSAT and ballistic charge transport model is used
        "CC",      //  Fitting parameter to adjust Vg-dependent inner fringe capacitances(Not used in this version)
        "nd",      //  Punch-through factor [1/V]
        "smoothing",   // smoothing parameter for smoothing funcs
        "expMaxslope"; // max slope for safeexp
	
	// parm_defaultvals
    parm_defaultvals += 
        1.01,    //  MVS model version = 1.0.1
        1,       //  type of transistor. nFET type=1; pFET type=-1
        1e-4,    //  Transistor width [cm]
        80e-7,   //  Physical gate length [cm]. //   This is the designed gate length for litho printing.
        10.5e-7, //  Overlap length including both source and drain sides [cm]  
        2.2e-6,  //  Gate-to-channel areal capacitance at the virtual source [F/cm^2]
        1.3e-3,  //  Equivalent thickness of dielectric at S/D-G overlap [cm]
        0.10,    //  Drain-induced-barrier-lowering (DIBL) [V/V]
        1.5,     //  Subthreshold swing factor [unit-less] {typically between 1.0 and 2.0}
        100.0,   //  Access resistance on s-terminal [Ohms-micron]
        100.0,   //  Access resistance on d-terminal [Ohms-micron]
                 //  Generally, Rs0 = Rd0 for symmetric source and drain
        1e-12,   //  Inner fringing S or D capacitance [F/cm] 
        2e-13,   //  Outer fringing S or D capacitance [F/cm] 
        0.765e7, //  Virtual source injection velocity [cm/s]
        200.0,   //  Low-field mobility [cm^2/V.s]
        1.7,     //  Saturation factor. Typ. nFET=1.8, pFET=1.6
        298.0,   //  Junction temperature [K]
        1.2,     //  ~abs(2*phif)>0 [V]
        0.0,     //  Body factor  [sqrt(V)]
        0.486,   //  Strong inversion threshold voltage [V] 
        3.5,     //  Empirical parameter for threshold voltage shift between strong and weak inversion.
        0.2,     //  Choose an appropriate value between 0.01 to 10
                 //  For, values outside of this range,convergence or accuracy of results is not guaranteed
        1,       //  If CTM_select = 1, then classic DD-NVSAT model is used
                 //  For CTM_select other than 1,blended DD-NVSAT and ballistic charge transport model is used
        0.0,     //  Fitting parameter to adjust Vg-dependent inner fringe capacitances(Not used in this version)
        0.0,     //  Punch-through factor [1/V]
        1e-20,   // smoothing
        1e50;    // expMaxslope

	// parm_vals
	parm_vals = parm_defaultvals;

	// node_names
    node_names += "d", "g", "s", "b";
	
	// refnode_name
    refnode_name = "b";
	
	// explicit_output_names
    explicit_output_names += "idb", "igb", "isb";

    // internal_unk_names:
    internal_unk_names += "vdib", "vsib";

    // implicit_equation_names
    implicit_equation_names += "KCL_di", "KCL_si";

	// init/limiting
	limited_var_names += "vdiblim", "vgblim", "vsiblim";
	vecXY_to_limited_vars_matrix.resize(3, 5, false);
	vecXY_to_limited_vars_matrix(0, 3) = 1.0;
	vecXY_to_limited_vars_matrix(1, 1) = 1.0;
	vecXY_to_limited_vars_matrix(2, 4) = 1.0;
	// MOD.vecXY_to_limitedvars_matrix = [ 0 0 0 1 0
	// 									   0 1 0 0 0
	// 									   0 0 0 0 1];

	// the following function sets up refnode_index, io_names, otherio_names, io_types
	// io_nodenames, otherio_types, otherio_nodenames, otherio_nodeindices, explicit_output_types,
	// explicit_output_nodenames, and explicit_output_nodeindices.  It uses node_names, refnode_name and 
	// explicit_output_names - make sure these are set up correctly before calling it.
	setup_ios_otherios_types_nodenames_indices();
}

template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
  vector<TOUT> MVS_1_0_1_ModSpec::fe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim, vector<TU>& vecU) {
    TX vdb = vecX[0];
    TX vgb = vecX[1];
    TX vsb = vecX[2];

    TY vdib = vecY[0];
    TY vsib = vecY[1];

    TLIM vdiblim = vecLim[0];
    TLIM vgblim = vecLim[1];
    TLIM vsiblim = vecLim[2];

    TOUT vb = 0.0; // internal reference, arbitrary value
    TOUT vd = vdb + vb;
    TOUT vg = vgblim + vb;
    TOUT vs = vsb + vb;
    TOUT vdi = vdiblim + vb;
    TOUT vsi = vsiblim + vb;
    TOUT iddi, idisi, isis, qgb, qdib, qsib;
    MVS_core_model(/* outputs */ iddi, idisi, isis, qgb, qdib, qsib,
                  /* inputs */  vd, vg, vs, vb, vdi, vsi);
	vector<TOUT> out;

	// idb
	TOUT out1 = iddi;
	// igb
	TOUT out2 = 0*iddi;
	// isb
	TOUT out3 = -isis;
	out += out1, out2, out3;
	return out; 
}

template <typename TOUT, typename TX, typename TY, typename TLIM>
  vector<TOUT> MVS_1_0_1_ModSpec::qe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim) {
	// TODO: code is duplicated everywhere for fqei
    TX vdb = vecX[0];
    TX vgb = vecX[1];
    TX vsb = vecX[2];

    TY vdib = vecY[0];
    TY vsib = vecY[1];

    TLIM vdiblim = vecLim[0];
    TLIM vgblim = vecLim[1];
    TLIM vsiblim = vecLim[2];

    TOUT vb = 0.0; // internal reference, arbitrary value
    TOUT vd = vdb + vb;
    TOUT vg = vgblim + vb;
    TOUT vs = vsb + vb;
    TOUT vdi = vdiblim + vb;
    TOUT vsi = vsiblim + vb;
    TOUT iddi, idisi, isis, qgb, qdib, qsib;
    MVS_core_model(/* outputs */ iddi, idisi, isis, qgb, qdib, qsib,
                  /* inputs */  vd, vg, vs, vb, vdi, vsi);
	vector<TOUT> out;

	// idb 
	TOUT out1 = 0*qgb; // no d/dt term in idb contribution
	// igb
	TOUT out2 = qgb;
	// isb
	TOUT out3 = 0*qgb;  // no d/dt term in isb contribution
	out += out1, out2, out3;
	return out; 
}

template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
  vector<TOUT> MVS_1_0_1_ModSpec::fi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim, vector<TU>& vecU) {
    TX vdb = vecX[0];
    TX vgb = vecX[1];
    TX vsb = vecX[2];

    TY vdib = vecY[0];
    TY vsib = vecY[1];

    TLIM vdiblim = vecLim[0];
    TLIM vgblim = vecLim[1];
    TLIM vsiblim = vecLim[2];

    TOUT vb = 0.0; // internal reference, arbitrary value
    TOUT vd = vdb + vb;
    TOUT vg = vgblim + vb;
    TOUT vs = vsb + vb;
    TOUT vdi = vdiblim + vb;
    TOUT vsi = vsiblim + vb;
    TOUT iddi, idisi, isis, qgb, qdib, qsib;
    MVS_core_model(/* outputs */ iddi, idisi, isis, qgb, qdib, qsib,
                  /* inputs */  vd, vg, vs, vb, vdi, vsi);
	vector<TOUT> out;

	TOUT ig = 0;
	TOUT ib = 0; 
	// KCL_di
	TOUT out1 = -iddi + idisi;
	// KCL_si
	TOUT out2 = isis - (idisi+ig+ib);
	out += out1, out2;
	return out; 
}

template <typename TOUT, typename TX, typename TY, typename TLIM>
  vector<TOUT> MVS_1_0_1_ModSpec::qi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim) {
    TX vdb = vecX[0];
    TX vgb = vecX[1];
    TX vsb = vecX[2];

    TY vdib = vecY[0];
    TY vsib = vecY[1];

    TLIM vdiblim = vecLim[0];
    TLIM vgblim = vecLim[1];
    TLIM vsiblim = vecLim[2];

    TOUT vb = 0.0; // internal reference, arbitrary value
    TOUT vd = vdb + vb;
    TOUT vg = vgblim + vb;
    TOUT vs = vsb + vb;
    TOUT vdi = vdiblim + vb;
    TOUT vsi = vsiblim + vb;
    TOUT iddi, idisi, isis, qgb, qdib, qsib;
    MVS_core_model(/* outputs */ iddi, idisi, isis, qgb, qdib, qsib,
                  /* inputs */  vd, vg, vs, vb, vdi, vsi);
	vector<TOUT> out;

	// KCL_di
	TOUT out1 = qdib;
	// KCL_si
	TOUT out2 = qsib;
	out += out1, out2;
	return out; 
}

vector<double> MVS_1_0_1_ModSpec::initGuess(vector<double>& vecU) {
	double type    = parm_vals[1]; //  type of transistor. nFET type=1; pFET type=-1
	double Vt0     = parm_vals[19]; //  Strong inversion threshold voltage [V] 
	vector<double> vecLimInit;
	vecLimInit += 0.0, type * Vt0, -1.0;
	return vecLimInit;
}

template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
  vector<TOUT> MVS_1_0_1_ModSpec::limiting_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLimOld, vector<TU>& vecU) {
	double type    = parm_vals[1]; //  type of transistor. nFET type=1; pFET type=-1
	double Vt0     = parm_vals[19]; //  Strong inversion threshold voltage [V] 

    TY vdb = vecY[0]; // vdib
    TX vgb = vecX[1];
    TY vsb = vecY[1]; // vsib

    TLIM vdbold = vecLimOld[0];
    TLIM vgbold = vecLimOld[1];
    TLIM vsbold = vecLimOld[2];

    // adpated from spice3f5 code in mos6
    TOUT vgs = vgb - vsb;
    TOUT vgd = vgb - vdb;
	TOUT vds = vgs - vgd;
    TOUT vbs = -vsb;
    TOUT vbd = -vdb;
    TOUT vdsold = vdbold - vsbold;
    TOUT vgsold = vgbold - vsbold;
    TOUT vgdold = vgbold - vdbold;
    TOUT vbsold = -vsbold;
    TOUT vbdold = -vdbold;

    double vt = 0.026; // thermal voltage TODO: derive via kT/q, take T as parm
    double vcrit = 0.6145; // TODO: vcrit is hard-coded here should get them somehow from parms

    if (vdsold >= 0) {
        vgs = fetlim<TOUT>(vgs, vgsold, type*Vt0);
        vds = vgs - vgd;
        vds = limvds<TOUT>(vds, vdsold);
        vgd = vgs - vds;
    } else {
        vgd = fetlim<TOUT>(vgd, vgdold, type*Vt0);
        vds = vgs - vgd;
        vds = -limvds<TOUT>(-vds, -vdsold);
        vgs = vgd + vds;
    }

    if (vds >= 0) {
        vbs = pnjlim<TOUT>(vbsold, vbs, vt, vcrit);
        vbd = vbs - vds;
    } else {
        vbd = pnjlim<TOUT>(vbdold, vbd, vt, vcrit);
        vbs = vbd + vds;
    }

	vector<TOUT> vecLimNew;
	vecLimNew += -vbd, vgs-vbs, -vbs;
	return vecLimNew;
}

template <typename TOUT>
    void MVS_1_0_1_ModSpec::MVS_core_model( /* outputs */ TOUT& iddi, TOUT& idisi, TOUT& isis, TOUT& qgb, TOUT& qdib, TOUT& qsib,
        /* inputs */  TOUT vd, TOUT vg, TOUT vs, TOUT vb, TOUT vdi, TOUT vsi) {
    // from mvs_model_si_1_0_1.va

    #define SMALL_VALUE (1e-10)
    #define LARGE_VALUE (40)  
    #define P_Q         (1.6021918e-19)   // from constants.vams
    #define P_K         (1.3806503e-23)   // from constants.vams 

	double version = parm_vals[0]; //  MVS model version = 1.0.1
	double type    = parm_vals[1]; //  type of transistor. nFET type=1; pFET type=-1
	double W       = parm_vals[2]; //  Transistor width [cm]
	double Lgdr    = parm_vals[3]; //  Physical gate length [cm]. //   This is the designed gate length for litho printing.
	double dLg     = parm_vals[4]; //  Overlap length including both source and drain sides [cm]  
	double Cg      = parm_vals[5]; //  Gate-to-channel areal capacitance at the virtual source [F/cm^2]
	double etov    = parm_vals[6]; //  Equivalent thickness of dielectric at S/D-G overlap [cm]
	double delta   = parm_vals[7]; //  Drain-induced-barrier-lowering (DIBL) [V/V]
	double n0      = parm_vals[8]; //  Subthreshold swing factor [unit-less] {typically between 1.0 and 2.0}
	double Rs0     = parm_vals[9]; //  Access resistance on s-terminal [Ohms-micron]
	double Rd0     = parm_vals[10]; //  Access resistance on d-terminal [Ohms-micron]
	double Cif     = parm_vals[11]; //  Inner fringing S or D capacitance [F/cm] 
	double Cof     = parm_vals[12]; //  Outer fringing S or D capacitance [F/cm] 
	double vxo     = parm_vals[13]; //  Virtual source injection velocity [cm/s]
	double mu      = parm_vals[14]; //  Low-field mobility [cm^2/V.s]
	double beta    = parm_vals[15]; //  Saturation factor. Typ. nFET=1.8, pFET=1.6
	double Tjun    = parm_vals[16]; //  Junction temperature [K]
	double phib    = parm_vals[17]; //  ~abs(2*phif)>0 [V]
	double gamma   = parm_vals[18]; //  Body factor  [sqrt(V)]
	double Vt0     = parm_vals[19]; //  Strong inversion threshold voltage [V] 
	double alpha   = parm_vals[20]; //  Empirical parameter for threshold voltage shift between strong and weak inversion.
	double mc      = parm_vals[21]; //  Choose an appropriate value between 0.01 to 10
	double CTM_select  = parm_vals[22]; //  If CTM_select = 1, then classic DD-NVSAT model is used
	double CC      = parm_vals[23]; //  Fitting parameter to adjust Vg-dependent inner fringe capacitances(Not used in this version)
	double nd      = parm_vals[24]; //  Punch-through factor [1/V]
	double smoothing   = parm_vals[25]; // smoothing parameter for smoothing funcs
	double expMaxslope = parm_vals[26]; // max slope for safeexp

    //Voltage definitions
    TOUT Vgsraw = type * ( vg - vsi );
    TOUT Vgdraw = type * ( vg - vdi );
	TOUT Vds, Vgs, Vbs, Vdsi, Vgsi, Vbsi;
	int dir;
    if (Vgsraw >= Vgdraw) {
        Vds  = type * ( vd - vs ); 
        Vgs  = type * ( vg - vs );
        Vbs  = type * ( vb - vs );
        Vdsi = type * ( vdi - vsi );
        Vgsi = Vgsraw;
        Vbsi = type * ( vb - vsi );
        dir = 1;
    }
    else {
        Vds  = type * ( vs - vd );
        Vgs  = type * ( vg - vd );
        Vbs  = type * ( vb - vd );
        Vdsi = type * ( vsi - vdi );
        Vgsi = Vgdraw;
        Vbsi = type * ( vb - vdi );
        dir = -1;
    }

    //Parasitic element definition
    double Rs = 1e-4/ W * Rs0;     // s-terminal resistance [ohms]
    double Rd = Rs;                // d-terminal resistance [ohms] For symmetric source and drain Rd = Rs. 
    //double Rd = 1e-4/ W * Rd0;   // d-terminal resistance [ohms] {Uncomment for asymmetric source and drain resistance.}
    double Cofs = ( 0.345e-12/ etov ) * dLg/ 2.0 + Cof; // s-terminal outer fringing cap [F/cm]
    double Cofd = ( 0.345e-12/ etov ) * dLg/ 2.0 + Cof; // d-terminal outer fringing cap [F/cm]
    double Leff = Lgdr - dLg;  // Effective channel length [cm]. After subtracting overlap lengths on s and d side 
    
    // double phit = $vt(Tjun);   // Thermal voltage, kT/q [V]                
    double phit = P_K * Tjun / P_Q;   // Thermal voltage, kT/q [V]                
    double me    = (9.1e-31) * mc;    // Carrier mass [Kg]
    TOUT   n     = n0 + nd * Vds;     // Total subthreshold swing factor taking punchthrough into account [unit-less]
    TOUT   nphit = n * phit;          // Product of n and phit [used as one variable]
    TOUT   aphit = alpha * phit;      // Product of alpha and phit [used as one variable]

    //Correct Vgsi and Vbsi
    //Vcorr is computed using external Vbs and Vgs but internal Vdsi, Qinv and Qinv_corr are computed with uncorrected Vgs, Vbs and corrected Vgs, Vbs respectively.    
    TOUT Vtpcorr = Vt0 + gamma * (sqrt(abs(phib - Vbs))- sqrt(phib))- Vdsi * delta;  // Calculated from extrinsic Vbs
    TOUT eVgpre  = exp(( Vgs - Vtpcorr )/ ( aphit * 1.5 ));     // Calculated from extrinsic Vgs
    TOUT FFpre   = 1.0/ ( 1.0 + eVgpre );                       // Only used to compute the correction factor
    TOUT ab      = 2 * ( 1 - 0.99 * FFpre ) * phit;  
    TOUT Vcorr   = ( 1.0 + 2.0 * delta ) * ( ab/ 2.0 ) * ( exp( -Vdsi/ ab ));   // Correction to intrinsic Vgs
    TOUT Vgscorr = Vgsi + Vcorr;    // Intrinsic Vgs corrected (to be used for charge and current computation)
    TOUT Vbscorr = Vbsi + Vcorr;    // Intrinsic Vgs corrected (to be used for charge and current computation)
    TOUT Vt0bs   = Vt0 + gamma * (sqrt( abs( phib - Vbscorr)) - sqrt( phib ));  // Computed from corrected intrinsic Vbs
    TOUT Vt0bs0  = Vt0 + gamma * (sqrt( abs( phib - Vbsi)) - sqrt( phib ));     // Computed from uncorrected intrinsic Vbs
    TOUT Vtp     = Vt0bs - Vdsi * delta - 0.5 * aphit;  // Computed from corrected intrinsic Vbs and intrinsic Vds
    TOUT Vtp0    = Vt0bs0 - Vdsi * delta - 0.5 * aphit; // Computed from uncorrected intrinsic Vbs and intrinsic Vds
    TOUT eVg     = exp(( Vgscorr - Vtp )/ ( aphit ));   // Compute eVg factor from corrected intrinsic Vgs
    TOUT FF      = 1.0/ ( 1.0 + eVg );
    TOUT eVg0    = exp(( Vgsi - Vtp0 )/ ( aphit ));     // Compute eVg factor from uncorrected intrinsic Vgs
    TOUT FF0     = 1.0/ ( 1.0 + eVg0 );
    TOUT Qref    = Cg * nphit;    
    TOUT eta     = ( Vgscorr - ( Vt0bs - Vdsi * delta - FF * aphit ))/ ( nphit );     // Compute eta factor from corrected intrinsic Vgs and intrinsic Vds
    TOUT eta0    = ( Vgsi - ( Vt0bs0 - Vdsi * delta - FFpre * aphit ))/ ( nphit );    // Compute eta0 factor from uncorrected intrinsic Vgs and internal Vds. 
    // Using FF instead of FF0 in eta0 gives smoother capacitances.

    //Charge at VS in saturation (Qinv)
	TOUT Qinv_corr;
    if (eta  <= LARGE_VALUE) {
        Qinv_corr = Qref * log( 1.0 + exp(eta) );
    }
    else {
        Qinv_corr = Qref * eta;
    }
	TOUT Qinv; 
    if (eta0 <= LARGE_VALUE) {
        Qinv = Qref * log( 1.0 + exp(eta0) ); // Compute charge w/ uncorrected intrinsic Vgs for use later on in charge partitioning
    }
    else {
        Qinv = Qref * eta0;
    }

    //Transport equations
    double vx0        = vxo;    
    double Vdsats     = vx0 * Leff/ mu;                            
    TOUT   Vdsat      = Vdsats * ( 1.0 - FF ) + phit * FF;  // Saturation drain voltage for current
    TOUT   Vdratio    = abs( Vdsi/ Vdsat);
    TOUT   Vdbeta     = pow( Vdratio, beta);
    TOUT   Vdbetabeta = pow( 1.0 + Vdbeta, 1.0/ beta);
    TOUT   Fsat       = Vdratio / Vdbetabeta;  // Transition function from linear to saturation. 
                                        // Fsat = 1 when Vds>>Vdsat; Fsat= Vds when Vds<<Vdsat

    //Total drain current                                         
    TOUT Id = Qinv_corr * vx0 * Fsat * W;        

    //Calculation of intrinsic charge partitioning factors (qs and qd)
    TOUT Vgt = Qinv/ Cg;   // Use charge computed from uncorrected intrinsic Vgs

    // Approximate solution for psis is weak inversion
	TOUT a;
	TOUT psis; 
    if (gamma == 0) {
        a = 1.0;
        if (eta0 <= LARGE_VALUE) {
            psis = phib + phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 ))));
        }
        else {
            psis = phib + phit * ( 1.0 + log( eta0 ));
        } 
    }
    else {
        if (eta0 <= LARGE_VALUE) {
            psis = phib + ( 1.0 - gamma )/ ( 1.0 + gamma ) * phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 ))));
        }
        else {
            psis = phib + ( 1.0 - gamma )/ ( 1.0 + gamma ) * phit * ( 1.0 + log( eta0 ));
        }
        a = 1.0 + gamma/ ( 2.0 * sqrt( abs( psis - ( Vbsi ))));
    }        
    TOUT Vgta   = Vgt/ a;   // Vdsat in strong inversion
    TOUT Vdsatq = sqrt( FF0 * aphit * aphit + Vgta * Vgta);   // Vdsat approx. to extend to weak inversion; 
                                        // The multiplier of phit has strong effect on Cgd discontinuity at Vd=0.

    // Modified Fsat for calculation of charge partitioning
    //DD-NVSAT charge
    TOUT Fsatq = abs( Vdsi/ Vdsatq )/ ( pow( 1.0 + pow( abs( Vdsi/ Vdsatq ), beta ), 1.0/ beta ));
    TOUT x     = 1.0 - Fsatq;
    TOUT den   = 15 * ( 1 + x ) * ( 1 + x );
    TOUT qsc   = Qinv *(6 + 12 * x + 8 * x * x + 4 * x * x * x)/ den;
    TOUT qdc   = Qinv *(4 + 8 * x + 12 * x * x + 6 * x * x * x)/ den;
    TOUT qi    = qsc + qdc;     // Charge in the channel 

    //QB charge    
    TOUT kq  = 0.0;
    double tol = ( SMALL_VALUE * vxo/ 100.0 ) * ( SMALL_VALUE * vxo/ 100.0 ) * me/ ( 2 * P_Q );

	TOUT kq2, kq4, qsb, qdb;
	kq2 = ( 2.0 * P_Q/ me * Vdsi )/ ( vx0 * vx0 ) * 10000.0;
	kq4 = kq2 * kq2;
	qsb = Qinv * ( 0.5 - kq2/ 24.0 + kq4/ 80.0 );
	qdb = Qinv * ( 0.5 - 0.125 * kq2 + kq4/ 16.0 );
    
    // Flag for classic or ballistic charge partitioning:
	TOUT qs, qd;
    if (CTM_select == 1) { // Ballistic blended with classic DD-NVSAT
        qs = qsc;         // Calculation of "ballistic" channel charge partitioning factors, qsb and qdb.
        qd = qdc;         // Here it is assumed that the potential increases parabolically from the
    }                      // virtual source point, where Qinv_corr is known to Vds-dvd at the drain.
    else {                 // Hence carrier velocity increases linearly by kq (below) depending on the
        qs = qsc * ( 1 - Fsatq * Fsatq ) + qsb * Fsatq * Fsatq;  // efecive ballistic mass of the carriers.
        qd = qdc * ( 1 - Fsatq * Fsatq ) + qdb * Fsatq * Fsatq;                
    }
                                
    //Body charge based on approximate surface potential (psis) calculation with delta=0 using psis=phib in Qb gives continuous Cgs, Cgd, Cdd in SI, while Cdd is smooth anyway.
    TOUT Qb = -type * W * Leff * ( Cg * gamma * sqrt( abs( psis - Vbsi )) + ( a - 1.0 )/ ( 1.0 * a ) * Qinv * ( 1.0 - qi ));

    //DIBL effect on drain charge calculation.
    //Calculate dQinv at virtual source due to DIBL only. Then:Correct the qd factor to reflect this channel charge change due to Vd
    //Vt0bs0 and FF=FF0 causes least discontinuity in Cgs and Cgd but produces a spike in Cdd at Vds=0 (in weak inversion.  But bad in strong inversion)
    TOUT etai = ( Vgsi - ( Vt0bs0 - FF * aphit ))/ ( nphit );
	TOUT Qinvi;
    if (etai <= LARGE_VALUE) {
        Qinvi = Qref * log( 1.0 + exp( etai ));
    }
    else {
        Qinvi = Qref * etai;
    }
    TOUT dQinv     = Qinv - Qinvi;
    TOUT dibl_corr = ( 1.0 - FF0 ) * ( 1.0 - Fsatq ) * qi * dQinv;
    qd        = qd - dibl_corr;
         
    //Inversion charge partitioning to terminals s and d
    TOUT Qinvs = type * Leff * (( 1 + dir ) * qs + ( 1 - dir ) * qd)/ 2.0;
    TOUT Qinvd = type * Leff * (( 1 - dir ) * qs + ( 1 + dir ) * qd)/ 2.0;

    //Outer fringing capacitance
    TOUT Qsov = Cofs * ( vg - vsi );
    TOUT Qdov = Cofd * ( vg - vdi );


    //Inner fringing capacitance
    TOUT Vt0x   = Vt0 + gamma * ( sqrt( abs( phib - type * ( vb - vsi ))) - sqrt(phib));
    TOUT Vt0y   = Vt0 + gamma * ( sqrt( abs( phib - type * ( vb - vdi ))) - sqrt(phib));
    TOUT Fs_arg = ( Vgsraw - ( Vt0x - Vdsi * delta * Fsat ) + aphit * 0.5 )/ ( 1.1 * nphit );
	TOUT Fs, FFx;
    if (Fs_arg <= LARGE_VALUE) {
        Fs  = 1.0 + exp( Fs_arg );
        FFx = Vgsraw - nphit * log( Fs );
    }
    else {
        Fs  = 0.0;    //    Not used
        FFx = Vgsraw - nphit * Fs_arg;
    }
    TOUT Fd_arg = ( Vgdraw - ( Vt0y - Vdsi * delta * Fsat ) + aphit * 0.5 )/ ( 1.1 * nphit );
	TOUT Fd, FFy;
    if (Fd_arg <= LARGE_VALUE) {
        Fd  = 1.0 + exp( Fd_arg );
        FFy = Vgdraw - nphit * log( Fd );
    }
    else {
        Fd  = 0.0;    //    Not used
        FFy = Vgdraw - nphit * Fd_arg;
    } 
    TOUT Qsif = type * ( Cif + CC * Vgsraw ) * FFx;
    TOUT Qdif = type * ( Cif + CC * Vgdraw ) * FFy;
    
    //Partitioned charge
    qsib = -W * ( Qinvs + Qsov + Qsif );   //     s-terminal charge
    qdib = -W * ( Qinvd + Qdov + Qdif );   //     d-terminal charge
    qgb  = -( qsib + qdib + Qb );              //     g-terminal charge

    //Sub-circuit initialization
    idisi = type * dir * Id;
    iddi  = ( vd - vdi )/ Rd;
    isis  = ( vsi - vs )/ Rs;
}

template <typename T>
  T MVS_1_0_1_ModSpec::pnjlim(T vnew, T vold, double vt, double vcrit) {
// from DEVpnjlim in devsup.c in ngspice-24
// TODO: create some kind of devsup for MAPP 
    T arg;

    if((vnew > vcrit) && (fabs(vnew - vold) > (vt + vt))) {
        if(vold > 0) {
            arg = (vnew - vold) / vt; 
            if(arg > 0) {
                vnew = vold + vt * (2+log(arg-2));
            } else {
                vnew = vold - vt * (2+log(2-arg));
            }
        } else {
            vnew = vt *log(vnew/vt);
        }
        // *icheck = 1;
    } else {
       if (vnew < 0) {
           if (vold > 0) {
               arg = -1*vold-1;
           } else {
               arg = 2*vold-1;
           }
           if (vnew < arg) {
              vnew = arg;
              // *icheck = 1;
           } else {
              // *icheck = 0;
           };
        } else {
           // *icheck = 0;
        }
    }   
    return(vnew);
}

template <typename T>
  T MVS_1_0_1_ModSpec::limvds(T vnew, T vold) {
// from DEVlimvds in devsup.c in ngspice-24

    if(vold >= 3.5) {
        if(vnew > vold) {
            vnew = min(vnew,(3.0 * vold) +2.0);
        } else {
            if (vnew < 3.5) {
                vnew = max(vnew,2.0);
            }
        }
    } else {
        if(vnew > vold) {
            vnew = min(vnew,4.0);
        } else {
            vnew = max(vnew,-.5);
        }
    }
    return vnew;
}

template <typename T>
  T MVS_1_0_1_ModSpec::fetlim(T vnew, T vold, double vto) {
// from DEVfetlim in devsup.c in ngspice-24
    T vtsthi;
    T vtstlo;
    double vtox;
    T delv;
    double vtemp;

    vtsthi = fabs(2.0*(vold-vto))+2.0;
    vtstlo = fabs(vold-vto)+1;
    vtox = vto + 3.5;
    delv = vnew-vold;

    if (vold >= vto) {
        if(vold >= vtox) {
            if(delv <= 0.0) {
                /* going off */
                if(vnew >= vtox) {
                    if(-delv >vtstlo) {
                        vnew =  vold - vtstlo;
                    }
                } else {
                    vnew = max(vnew,vto+2.0);
                }
            } else {
                /* staying on */
                if(delv >= vtsthi) {
                    vnew = vold + vtsthi;
                }
            }
        } else {
            /* middle region */
            if(delv <= 0.0) {
                /* decreasing */
                vnew = max(vnew,vto-.5);
            } else {
                /* increasing */
                vnew = min(vnew,vto+4.0);
            }
        }
    } else {
        /* off */
        if(delv <= 0.0) {
            if(-delv >vtsthi) {
                vnew = vold - vtsthi;
            }
        } else {
            vtemp = vto + .5;
            if(vnew <= vtemp) {
                if(delv >vtstlo) {
                    vnew = vold + vtstlo;
                }
            } else {
                vnew = vtemp;
            }
        }
    }
    return vnew;
}

// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element* create() {
    return new MVS_1_0_1_ModSpec;
}

extern "C" void destroy(ModSpec_Element* p) {
    delete p;
}
