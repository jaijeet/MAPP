#include "damped_pendulum_DAE.h"

// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>
using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
damped_pendulum_DAE::damped_pendulum_DAE() {
	// dae_name
	dae_name = "damped pendulum DAE";

	// uniq_ID
	uniq_ID = "undefined"; // TODO: should get is from outside

	// dae_version;
	dae_version = "undefined"; // TODO

	// unk_names
	unk_names += "theta", "omega";
	
	// eqn_names
	eqn_names += "thetadot", "omegadot";
	
	// output_names
	output_names += "theta";

	// parm_names
	parm_names += "damping", "g", "l", "mass";
	
	// parm_defaultvals
	parm_defaultvals += 0.1, 9.81, 1.0, 1.0;

	// parm_vals
	parm_vals = parm_defaultvals;

	// Cmat
	Cmat.resize(1, 2, false);
	Cmat(0, 0) = 1.0;

	// Dmat
	Dmat.resize(1, 0, false);
}

template <typename TOUT, typename TX, typename TU>
  vector<TOUT> damped_pendulum_DAE::f_tmpl(vector<TX>& x, vector<TU>& u) {
	TX theta = x[0];
	TX omega = x[1];
	double damping = parm_vals[0];
	double g = parm_vals[1];
	double l = parm_vals[2];
	double mass = parm_vals[3];

    TOUT thetadot = omega;
    TOUT omegadot = - g/l * sin(theta) + damping/mass * omega;

	vector<TOUT> out;
	out += thetadot, omegadot;
	return out;
}

template <typename TOUT, typename TX>
  vector<TOUT> damped_pendulum_DAE::q_tmpl(vector<TX>& x) {
	TX theta = x[0];
	TX omega = x[1];
	vector<TOUT> out;
	out += theta, omega;
	return out;
}

/*
// the "class factories" for accessing this device via dlopen
extern "C" ModSpec_Element* create() {
    return new damped_pendulum_DAE;
}

extern "C" void destroy(ModSpec_Element* p) {
    delete p;
}
*/
