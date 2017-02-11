#ifndef MVS_MODSPEC_ELEMENT_H
#define MVS_MODSPEC_ELEMENT_H
#include "ModSpec_Element.h"
#include "smoothingfuncs.h"

class MVS_ModSpec_Element: public ModSpec_Element_with_Jacobians {
    public: 
        MVS_ModSpec_Element();
        ~MVS_ModSpec_Element(){};
    protected:
        // the main fqei function is templated, for use in generating Jacobians via AD
        // this, and the constructor, are the only functions that need specialization for any
        // new device. 
        template <typename TOUT, typename TX, typename TY, typename TU>
            vector<TOUT> fqei_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU, char eORi, char fORq);

        // parameters
        double version; //  MVS model version = 1.0.1
        int    type;    //  type of transistor. nFET type=1; pFET type=-1
        double W;       //  Transistor width [cm]
        double Lgdr;    //  Physical gate length [cm]. //   This is the designed gate length for litho printing.
        double dLg;     //  Overlap length including both source and drain sides [cm]  
        double Cg;      //  Gate-to-channel areal capacitance at the virtual source [F/cm^2]
        double etov;    //  Equivalent thickness of dielectric at S/D-G overlap [cm]
        double delta;   //  Drain-induced-barrier-lowering (DIBL) [V/V]
        double n0;      //  Subthreshold swing factor [unit-less] {typically between 1.0 and 2.0}
        double Rs0;     //  Access resistance on s-terminal [Ohms-micron]
        double Rd0;     //  Access resistance on d-terminal [Ohms-micron] 
                        //  Generally, Rs0 = Rd0 for symmetric source and drain
        double Cif;     //  Inner fringing S or D capacitance [F/cm] 
        double Cof;     //  Outer fringing S or D capacitance [F/cm] 
        double vxo;     //  Virtual source injection velocity [cm/s]
        double mu;      //  Low-field mobility [cm^2/V.s]
        double beta;    //  Saturation factor. Typ. nFET=1.8, pFET=1.6
        double Tjun;    //  Junction temperature [K]
        double phib;    //  ~abs(2*phif)>0 [V]
        double gamma;   //  Body factor  [sqrt(V)]
        double Vt0;     //  Strong inversion threshold voltage [V] 
        double alpha;   //  Empirical parameter for threshold voltage shift between strong and weak inversion.
        double mc;      //  Choose an appropriate value between 0.01 to 10 
                        //  For, values outside of this range,convergence or accuracy of results is not guaranteed
        int CTM_select; //  If CTM_select = 1, then classic DD-NVSAT model is used
                        //  For CTM_select other than 1,blended DD-NVSAT and ballistic charge transport model is used
        double CC;      //  Fitting parameter to adjust Vg-dependent inner fringe capacitances(Not used in this version)
        double nd;      //  Punch-through factor [1/V]

        double smoothing;  // smoothing parameter for smoothing funcs
        double expMaxslope;// max slope for safeexp
		// TODO: not used

        template <typename TOUT>
            void MVS_core_model(/* outputs */ TOUT& iddi, TOUT& idisi, TOUT& isis, TOUT& qgb, TOUT& qdib, TOUT& qsib,
								/* inputs */  TOUT vd, TOUT vg, TOUT vs, TOUT vb, TOUT vdi, TOUT vsi);

        // All the functions below can stay exactly identical for any other device. They can't be moved
        // to ModSpec_Element.h yet because C++ does not support inheriting virtual template functions.
        // They are included from ModSpec_Element_common_includes.h
        #include "ModSpec_Element_common_includes.h"
};
#endif
