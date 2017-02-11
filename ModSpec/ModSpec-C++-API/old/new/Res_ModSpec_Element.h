#ifndef RES_MODSPEC_ELEMENT_H
#define RES_MODSPEC_ELEMENT_H
#include "ModSpec_Element.h"
#include "sacado.h" // defines DFAD, LFADsp, DFADvec, LFADvec, spMatrix

template <typename TOUT, typename TX, typename TY, typename TU>
  class Res_ModSpec_Element_with_templated_fqei: public ModSpec_Element_with_templated_fqei<TOUT,TX,TY,TU> {
	public:
		Res_ModSpec_Element_with_templated_fqei<TOUT,TX,TY,TU>(); // constructor
		~Res_ModSpec_Element_with_templated_fqei<TOUT,TX,TY,TU>() {}; // destructor

	protected:
		vector<TOUT> fqei(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU, char eORi, char fORq);
};

typedef Res_ModSpec_Element_with_templated_fqei<double,double,double,double> Res_ModSpec_Element;

class Res_ModSpec_Element_with_sacado_Jacobians: public Res_ModSpec_Element, public sacado_Jacobian_functions {
};

/*

// to get the sparsity pattern of dd?
typedef Res_ModSpec_Element_with_templated_fqei<LFADsp,LFADsp,double,double> Res_ModSpec_Element_for_ddX_stamp; // for dfqei_dX
typedef Res_ModSpec_Element_with_templated_fqei<LFADsp,double,LFADsp,double> Res_ModSpec_Element_for_ddY_stamp; // for dfqei_dY
typedef Res_ModSpec_Element_with_templated_fqei<LFADsp,double,double,LFADsp> Res_ModSpec_Element_for_ddU_stamp; // for dfqei_dU

// to get numerical values for dd?
typedef Res_ModSpec_Element_with_templated_fqei<DFAD,DFAD,double,double> Res_ModSpec_Element_for_ddX; // for dfqei_dX
typedef Res_ModSpec_Element_with_templated_fqei<DFAD,double,DFADvec,double> Res_ModSpec_Element_for_ddY; // for dfqei_dY
typedef Res_ModSpec_Element_with_templated_fqei<DFAD,double,double,DFAD> Res_ModSpec_Element_for_ddU; // for dfqei_dU

class Res_ModSpec_Element_with_sacado_Jacobians: public Res_ModSpec_Element {
	protected:
		Res_ModSpec_Element_for_ddX_stamp ddX_stamp_element;
		Res_ModSpec_Element_for_ddY_stamp ddY_stamp_element;
		Res_ModSpec_Element_for_ddU_stamp ddU_stamp_element;

		Res_ModSpec_Element_for_ddX ddX_element;
		Res_ModSpec_Element_for_ddY ddY_element;
		Res_ModSpec_Element_for_ddU ddU_element;

	public:
		// jacobian stamps
		// ddX functions
		spMatrix dfe_dX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dqe_dX_stamp(vector<double>& vecX, vector<double>& vecY);
		spMatrix dqi_dX_stamp(vector<double>& vecX, vector<double>& vecY);

		// ddY functions
		spMatrix dfe_dY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dqe_dY_stamp(vector<double>& vecX, vector<double>& vecY);
		spMatrix dqi_dY_stamp(vector<double>& vecX, vector<double>& vecY);
		
		// ddU functions
		spMatrix dfe_dU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		
		// numerical jacobians
		// ddX functions
		spMatrix dfe_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dqe_dX(vector<double>& vecX, vector<double>& vecY);
		spMatrix dqi_dX(vector<double>& vecX, vector<double>& vecY);

		// ddY functions
		spMatrix dfe_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dqe_dY(vector<double>& vecX, vector<double>& vecY);
		spMatrix dqi_dY(vector<double>& vecX, vector<double>& vecY);
		
		// ddU functions
		spMatrix dfe_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);
		spMatrix dfi_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU);

	protected:
		template <typename FADT>
			spMatrix d_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char forq, char eori);

		template <typename FADT>
			spMatrix d_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char forq, char eori);

		template <typename FADT>
			spMatrix df_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char eori);
*/
};
#endif
