#ifndef DAEAPI_H
#define DAEAPI_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <algorithm>
#include <sstream>
#include "untyped.h"
#include <vector> // std::vector
#include "sacado_typedefs.h"
#include "boost_ublas_includes_typedefs.h" // definition spMatrix == boost::numeric::ublas::mapped_matrix

using namespace std; // needed to disambiguate std::vector from boost::numeric::ublas::vector

class DAEAPI { // this is an abstract base class that defines DAEAPI
	public:
		DAEAPI(){};
		virtual ~DAEAPI() {}; 

	public:
		virtual void print() = 0; // TODO: support is incompelete now

	public:
		virtual string daename() = 0;
		virtual string uniqID() = 0;
		virtual string version() = 0;

		virtual int nparms() = 0;
		virtual vector<string> parmnames() = 0;
		virtual vector<untyped> parmdefaults() = 0;

		virtual vector<untyped> getparms() = 0;
		virtual untyped getparm(string& parm) = 0;

		virtual void setparms(vector<untyped>& a) = 0;
		virtual void setparm(string& parm, untyped& val) = 0;

		virtual int nunks() = 0;
		virtual int neqns() = 0;
		virtual int ninputs() = 0;
		virtual int noutputs() = 0;
		virtual int nNoiseSources() = 0;

		virtual vector<string> unknames() = 0;
		virtual vector<string> eqnnames() = 0;
		virtual vector<string> inputnames() = 0;
		virtual vector<string> outputnames() = 0;
		virtual vector<string> NoiseSourcenames() = 0;

		virtual vector<double> f(vector<double>& x, vector<double>& u) = 0;
		virtual vector<double> q(vector<double>& x) = 0;

		virtual spMatrix df_dx(vector<double>& x, vector<double>& u) = 0;
		virtual spMatrix df_du(vector<double>& x, vector<double>& u) = 0;
		virtual spMatrix dq_dx(vector<double>& x) = 0;

		// TODO
		// virtual vector<double> uQSS() = 0;
		// virtual vector<double> utransient() = 0;
		// virtual vector<double> uLTISSS() = 0;
		// virtual vector<double> uHB() = 0;

		// TODO
		// virtual void set_uQSS() = 0;
		// virtual vector<double> set_utransient() = 0;
		// virtual vector<double> set_uLTISSS() = 0;
		// virtual vector<double> set_uHB() = 0;

		virtual spMatrix C() = 0;
		virtual spMatrix D() = 0;

	public:
		// init/limiting flag, default is false
		virtual bool support_initlimiting() {
			return false;
		};

	public:
		// extra function fields related to init/limiting, default is no limited variables.
		virtual vector<string> limitedvarnames() {
			return vector<string>();
		}

		virtual int nlimitedvars() {
			return 0;
		}

		virtual spMatrix xTOxlimMatrix() {
			spMatrix J_OUT(nlimitedvars(), nunks());
			return J_OUT;
		}

		virtual vector<double> NRinitGuess(vector<double>& u) {
			vector<double> init_guess(nlimitedvars());
			return init_guess; // all zeros
		}

		virtual vector<double> NRlimiting(vector<double>& x, vector<double>& xlimOld, vector<double>& u) {
			return xlimOld; // no limiting
		}

		virtual spMatrix dNRlimiting_dx(vector<double>& x, vector<double>& xlimOld, vector<double>& u) {
		// for use in an obsolete NR method that is not working, shouldn't be used anywhere now
			spMatrix J_OUT(nlimitedvars(), nunks());
			return J_OUT;
		}

		virtual spMatrix dNRlimiting_du(vector<double>& x, vector<double>& xlimOld, vector<double>& u) {
		// for use in an obsolete NR method that is not working, shouldn't be used anywhere now
			spMatrix J_OUT(nlimitedvars(), ninputs());
			return J_OUT;
		}

	public:
		// core model functions with init/limiting
		virtual vector<double> f(vector<double>& x, vector<double>& xlim, vector<double>& u) {
			return f(x, u); 
		}
		virtual vector<double> q(vector<double>& x, vector<double>& xlim) {
			return q(x); 
		}

		virtual spMatrix df_dx(vector<double>& x, vector<double>& xlim, vector<double>& u) {
			return df_dx(x, u); 
		}
		virtual spMatrix df_dxlim(vector<double>& x, vector<double>& xlim, vector<double>& u) {
			spMatrix J_OUT(neqns(), nlimitedvars());
			return J_OUT;
		}
		virtual spMatrix df_du(vector<double>& x, vector<double>& xlim, vector<double>& u) {
			return df_du(x, u); 
		}
		virtual spMatrix dq_dx(vector<double>& x, vector<double>& xlim) {
			return dq_dx(x); 
		}
		virtual spMatrix dq_dxlim(vector<double>& x, vector<double>& xlim) {
			spMatrix J_OUT(neqns(), nlimitedvars());
			return J_OUT;
		}
};

// the types of the class factories, used for enabling dlopen 
// typedef DAEAPI *create_t();
// typedef void destroy_t(DAEAPI*);

#endif // DAEAPI_H
