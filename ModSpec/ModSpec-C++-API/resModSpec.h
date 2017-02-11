#ifndef RESMODSPEC
#define RESMODSPEC
#include "ee_model.h"

class resModSpec : public ee_model {
	public: 
		resModSpec();
		~resModSpec(){};
	protected:
		template <typename TOUT, typename TX, typename TY, typename TU>
		  vector<TOUT> fe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU);

		template <typename TOUT, typename TX, typename TY>
		  vector<TOUT> qe_tmpl(vector<TX>& vecX, vector<TY>& vecY);

		template <typename TOUT, typename TX, typename TY, typename TU>
		  vector<TOUT> fi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU);

		template <typename TOUT, typename TX, typename TY>
		  vector<TOUT> qi_tmpl(vector<TX>& vecX, vector<TY>& vecY);

		// All the functions below can stay exactly identical for any other device. They can't be moved
		// to ModSpec_Element.h yet because C++ does not support inheriting virtual template functions.
		// They are included from ModSpec_Element_common_includes.h
		#include "ModSpec_Element_common_includes.h"
		// TODO: move the templates above also to ModSpec_Element_common_includes.h
};
#endif
