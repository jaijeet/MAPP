#ifndef DAAV6_MODSPEC_ELEMENT_H
#define DAAV6_MODSPEC_ELEMENT_H
#include "ModSpec_Element.h"
#include "smoothingfuncs.h"

class DAAV6_ModSpec_Element: public ModSpec_Element_with_Jacobians {
	public: 
		DAAV6_ModSpec_Element();
		~DAAV6_ModSpec_Element(){};
	protected:
		// the main fqei function is templated, for use in generating Jacobians via AD
		// this, and the constructor, are the only functions that need specialization for any
		// new device. 
		template <typename TOUT, typename TX, typename TY, typename TU>
			vector<TOUT> fqei_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU, char eORi, char fORq);

		// parameters
		eString tipe;  	   // 'n' or 'p'
		double W;      	   // Width [cm]
		double Lg;	   // Gate length [cm]
		double dLg;    	   // dLg=L_g-L_c (default 0.3xLg_nom)
		double Cg;     	   // Gate cap [F/cm^2]
		double delta;  	   // DIBL [V/V]
		double S;      	   // Subthreshold swing [V/decade] OBSOLETE?
		double Ioff;   	   // Adjusted from Transfer Id-Vg OBSOLETE?
		double Vdd;    	   // Vd [V] corresponding to Ioff OBSOLETE?
		double Vgoff;  	   // Vg [V] corresponding to Ioff (typ. 0V) OBSOLETE?
		double Rs;     	   // Rs [ohm-micron] 
		double Rd;     	   // Rd [ohm-micron] 
		double vxo;    	   // Virtual source velocity [cm/s]
		double mu;     	   // Mobility [cm^2/V.s]
		double beta;   	   // Saturation factor. Typ. nFET=1.8, pFET=1.4
		double phit;   	   // kT/q assuming T=27 C.                      
		double gamma;  	   // Body factor  [sqrt(V)]
		double phib;   	   // =abs(2*phin)>0 [V]
		double smoothing;  // smoothing parameter for smoothing funcs
		double expMaxslope;// max slope for safeexp

		void VT(/* outputs */ double& Vt, double& Vt0,
		        /* inputs  */ double W, double Ioff, double Vgoff, double Vdd, double S, double delta, double vxo, double Qref, 
		 		      double phit);

		template <typename TOUT>
			void daaV6_core_model(/* outputs */ TOUT& Iy, TOUT& Qy, TOUT& Qg, TOUT& Qx, TOUT& Qb,
				     	      /* inputs  */ TOUT Vy, TOUT Vg, TOUT Vx, TOUT Vb, int docurrents, int docharges);

		template <typename TOUT>
			void daaV6_core_model_Qs(/* outputs */ TOUT& qdi, TOUT& qg, TOUT& qsi, TOUT& qb, 
						 /* inputs  */ TOUT Vy, TOUT Vg, TOUT Vx, TOUT Vb) {
				int docharges = 1;
				int docurrents = 0;

				TOUT dummy;
				daaV6_core_model(dummy, qdi, qg, qsi, qb,
						 Vy, Vg, Vx, Vb, docurrents, docharges);
		}

		template <typename TOUT>
			TOUT daaV6_core_model_Iy(TOUT Vy, TOUT Vg, TOUT Vx, TOUT Vb) {
				int docharges = 0;
				int docurrents = 1;

				TOUT idsi, dummy1, dummy2, dummy3, dummy4;
				daaV6_core_model(idsi, dummy1, dummy2, dummy3, dummy4,
						 Vy, Vg, Vx, Vb, docurrents, docharges);
				return idsi;
		}

		// All the functions below can stay exactly identical for any other device. They can't be moved
		// to ModSpec_Element.h yet because C++ does not support inheriting virtual template functions.
		// They are included from ModSpec_Element_common_includes.h
		#include "ModSpec_Element_common_includes.h"
};
#endif
