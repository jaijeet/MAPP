#ifndef DAMPED_PENDULUM_DAE
#define DAMPED_PENDULUM_DAE
#include "DAE_with_common_add_ons.h"

class  damped_pendulum_DAE : public DAE_with_common_add_ons {
	public: 
		damped_pendulum_DAE();
		~damped_pendulum_DAE(){};
	protected:
		template <typename TOUT, typename TX, typename TU>
		  vector<TOUT> f_tmpl(vector<TX>& x, vector<TU>& u);

		template <typename TOUT, typename TX>
		  vector<TOUT> q_tmpl(vector<TX>& x);

		#include "DAE_common_includes.h"
		// TODO: move the templates above also to DAE_common_includes.h
};
#endif
