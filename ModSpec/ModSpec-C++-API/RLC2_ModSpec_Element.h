#ifndef RLC2_MODSPEC_ELEMENT_H
#define RLC2_MODSPEC_ELEMENT_H
#include "ModSpec_Element.h"

class RLC2_ModSpec_Element: public ModSpec_Element_with_Jacobians {
	public: 
		RLC2_ModSpec_Element();
		~RLC2_ModSpec_Element() {};
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
