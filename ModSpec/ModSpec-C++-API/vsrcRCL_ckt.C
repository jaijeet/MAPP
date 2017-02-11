#include "vsrcRCL_ckt.h"

// needed to disambiguate std::vector from boost::numeric::ublas::vector
// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>

using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
vsrcRCL_ckt::vsrcRCL_ckt() {
	name = "vsrcRCL circuit";
	node_names += "1", "2", "3";
	ground_node_name = "0";

	string res_name = "R1";
	vector<string> res_nodes; res_nodes += "1", "2";
	vector<untyped> res_parms; res_parms += 1000.0;
	ModSpec_Element* res_MOD = new resModSpec(); res_MOD->setparms(res_parms);
	netlistElement * res_el = new netlistElement(res_name, res_nodes, res_parms, res_MOD);
	elements.push_back(res_el);

	string cap_name = "C1";
	vector<string> cap_nodes; cap_nodes += "3", "2";
	vector<untyped> cap_parms; cap_parms += 1.0e-8;
	ModSpec_Element* cap_MOD = new capModSpec(); cap_MOD->setparms(cap_parms);
	netlistElement * cap_el = new netlistElement(cap_name, cap_nodes, cap_parms, cap_MOD);
	elements.push_back(cap_el);

	string ind_name = "L1";
	vector<string> ind_nodes; ind_nodes += "3", "0";
	vector<untyped> ind_parms; ind_parms += 0.03;
	ModSpec_Element* ind_MOD = new indModSpec(); ind_MOD->setparms(ind_parms);
	netlistElement * ind_el = new netlistElement(ind_name, ind_nodes, ind_parms, ind_MOD);
	elements.push_back(ind_el);

	string vsrc_name = "V1";
	vector<string> vsrc_nodes; vsrc_nodes += "1", "0";
	vector<untyped> vsrc_parms; vsrc_parms += 1000.0;
	ModSpec_Element* vsrc_MOD = new vsrcModSpec(); vsrc_MOD->setparms(vsrc_parms);
	netlistElement * vsrc_el = new netlistElement(vsrc_name, vsrc_nodes, vsrc_parms, vsrc_MOD);
	elements.push_back(vsrc_el);
}

// destructor
vsrcRCL_ckt::~vsrcRCL_ckt() {
	// TODO: is default good enough? No memory leaks?
}
