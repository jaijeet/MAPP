#ifndef DAE_INITLIMITING_WITH_COMMON_ADD_ONS_H
#define DAE_INITLIMITING_WITH_COMMON_ADD_ONS_H

#include "DAE_with_common_add_ons.h"
#include "ublas_matrix_std_vector_ops.h" // defines prod(), add(), subtract() for vector<double>

class  DAE_initlimiting_with_common_add_ons : public DAE_with_common_add_ons { // this is still an abstract base class
	public:
		DAE_initlimiting_with_common_add_ons(){};
		virtual ~DAE_initlimiting_with_common_add_ons(){}; 

	protected:
		vector<string> limited_var_names;
		spMatrix x_to_xlim_matrix;

	public:
		// extra function fields related to init/limiting, default is no limited variables.
		virtual bool support_initlimiting() {
			return true;
		};

		virtual vector<string> limitedvarnames() {
			return limited_var_names;
		}

		virtual int nlimitedvars() {
			return limited_var_names.size();
		}

		virtual spMatrix xTOxlimMatrix() {
			return x_to_xlim_matrix;
		}

	public:
		virtual vector<double> f(vector<double>& x, vector<double>& xlim, vector<double>& u) = 0;
		virtual vector<double> q(vector<double>& x, vector<double>& xlim) = 0;
		virtual spMatrix df_dx(vector<double>& x, vector<double>& xlim, vector<double>& u) = 0;
		virtual spMatrix df_dxlim(vector<double>& x, vector<double>& xlim, vector<double>& u) = 0;
		virtual spMatrix df_du(vector<double>& x, vector<double>& xlim, vector<double>& u) = 0;
		virtual spMatrix dq_dx(vector<double>& x, vector<double>& xlim) = 0;
		virtual spMatrix dq_dxlim(vector<double>& x, vector<double>& xlim) = 0;

	public:
		// core model functions with init/limiting
		virtual vector<double> f(vector<double>& x, vector<double>& u) {
			vector<double> xlim = prod(xTOxlimMatrix(), x);
			return f(x, xlim, u); 
		}
		virtual vector<double> q(vector<double>& x) {
			vector<double> xlim = prod(xTOxlimMatrix(), x);
			return q(x, xlim); 
		}

		virtual spMatrix df_dx(vector<double>& x, vector<double>& u) {
			vector<double> xlim = prod(xTOxlimMatrix(), x);
			spMatrix Jout = df_dx(x, xlim, u) + prod(df_dxlim(x, xlim, u), xTOxlimMatrix());
			return Jout;
		}
		virtual spMatrix df_du(vector<double>& x, vector<double>& u) {
			vector<double> xlim = prod(xTOxlimMatrix(), x);
			spMatrix Jout = df_dx(x, xlim, u);
			return Jout;
		}
		virtual spMatrix dq_dx(vector<double>& x) {
			vector<double> xlim = prod(xTOxlimMatrix(), x);
			spMatrix Jout = dq_dx(x, xlim) + prod(dq_dxlim(x, xlim), xTOxlimMatrix());
			return Jout;
		}
};

#endif // DAE_INITLIMITING_WITH_COMMON_ADD_ONS_H
