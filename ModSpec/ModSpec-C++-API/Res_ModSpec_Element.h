#ifndef RES_MODSPEC_ELEMENT_H
#define RES_MODSPEC_ELEMENT_H
#include "ModSpec_Element.h"

class Res_ModSpec_Element_with_sacado_Jacobians: public ModSpec_Element_with_Jacobians {
	public: 
		Res_ModSpec_Element_with_sacado_Jacobians();
		~Res_ModSpec_Element_with_sacado_Jacobians() {};
	protected:
		// the main fqei function is templated, for use in generating Jacobians via AD
		// this, and the constructor, are the only functions that need specialization for any
		// new device. 
		template <typename TOUT, typename TX, typename TY, typename TU>
			vector<TOUT> fqei_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU, char eORi, char fORq);

		// All the functions below can stay exactly identical for any other device. They can't be moved
		// to ModSpec_Element.h yet because C++ does not support inheriting virtual template functions.
		// They are included from ModSpec_Element_common_includes.h
		#include "ModSpec_Element_common_includes.h"
};
#endif
