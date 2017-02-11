#ifndef RLC_MODSPEC_ELEMENT_H
#define RLC_MODSPEC_ELEMENT_H
#include "ModSpec_Element.h"

class RLC_ModSpec_Element: public ModSpec_Element_with_Jacobians {
	public: 
		RLC_ModSpec_Element();
		~RLC_ModSpec_Element() {};
		/*
		vector<string> ANTLR_parser_rule_for_element {
			vector<string> out;
			int len = 0;
			out.resize(len++);
			out[len] = "RLCNAME : ('y'|'Y') (LETTER | DIGIT | '_' )*;";

			out.resize(len++);
			out[len] = "RLCNAME  node node node model  param* terminator";
			return out;
		}
		vector<string> ANTLR_parser_actions_for_element {
		...
		}
		*/
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
