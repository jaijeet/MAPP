#include "MVS_9_stage_ring_oscillator_ckt.h"

// needed to disambiguate std::vector from boost::numeric::ublas::vector
// the following includes/usings needed for boost::assign
// which provides: vector<T> oof; oof += 1, 2, 3, 4; (!)
// see http://www.boost.org/doc/libs/1_39_0/libs/assign/doc/index.html
#include <boost/assign/std/vector.hpp> // for 'operator+=()'
#include <boost/assert.hpp>

using namespace std;
using namespace boost::assign; // bring 'operator+=()' into scope

// constructor
MVS_9_stage_ring_oscillator_ckt::MVS_9_stage_ring_oscillator_ckt() {
	name = "MVS 9-stage ring oscillator";
	node_names += "1", "2", "3", "4", "5", "6", "7", "8", "9", "vdd";
	ground_node_name = "0";

	string vsrc_name = "Vdd";
	vector<string> vsrc_nodes; vsrc_nodes += "vdd", "0";
	ModSpec_Element* vsrc_MOD = new vsrcModSpec();
	vector<untyped> vsrc_parms = vsrc_MOD->getparms();
	// vsrc_MOD->setparms(vsrc_parms);
	netlistElement * vsrc_el = new netlistElement(vsrc_name, vsrc_nodes, vsrc_parms, vsrc_MOD);
	elements.push_back(vsrc_el);

	for (int i = 0; i < 9; i++) {

		/*
		subcktnetlist = add_element(subcktnetlist, MVS_MOD, 'PMOS', {'vdd', 'in', 'out', 'vdd'}, ...
		{{'Type', -1}, {'W', 1.0e-4}, {'Lgdr', 32e-7}, {'dLg', 8e-7}, {'Cg', 2.57e-6}, ...
		{'Beta', 1.8}, {'Alpha', 3.5}, {'Tjun', 300}, {'Cif', 1.38e-12}, {'Cof', 1.47e-12}, ...
		{'phib', 1.2}, {'Gamma', 0.1}, {'mc', 0.2}, {'CTM_select', 1}, {'Rs0', 100}, ...
		{'Rd0', 100}, {'n0', 1.68}, {'nd', 0.1}, {'vxo', 7542204}, {'Mu', 165}, {'Vt0', 0.5535}, {'delta', 0.15}});

		subcktnetlist = add_element(subcktnetlist, MVS_MOD, 'NMOS', {'out', 'in', 'gnd', 'gnd'}, ...
		{{'Type', 1}, {'W', 1e-4}, {'Lgdr', 32e-7}, {'dLg', 9e-7}, {'Cg', 2.57e-6}, ...
		{'Beta', 1.8}, {'Alpha', 3.5}, {'Tjun', 300}, {'Cif', 1.38e-12}, {'Cof', 1.47e-12}, ...
		{'phib', 1.2}, {'Gamma', 0.1}, {'mc', 0.2}, {'CTM_select', 1}, {'Rs0', 100}, ...
		{'Rd0', 100}, {'n0', 1.68}, {'nd', 0.1}, {'vxo', 1.2e7}, {'Mu', 200}, {'Vt0', 0.4}, {'delta', 0.15}});

		subcktnetlist = add_element(subcktnetlist, cap_MOD, 'CL', {'out', 'gnd'}, {{'C', 3e-15}}, {});
		*/

		int idx = i+1;
		string parm;
		untyped parmval;

		string NMOS_name = "MN" + to_string(idx);
		vector<string> NMOS_nodes;
		if (9 == idx) {
			NMOS_nodes += "1", to_string(idx), "0", "0";
		} else {
			NMOS_nodes += to_string(idx+1), to_string(idx), "0", "0";
		}
		ModSpec_Element* NMOS_MOD = new MVS_1_0_1_ModSpec();
			parm = "type"; parmval = 1; NMOS_MOD->setparm(parm, parmval);
			parm = "W"; parmval = 1e-4; NMOS_MOD->setparm(parm, parmval);
			parm = "Lgdr"; parmval = 32e-7; NMOS_MOD->setparm(parm, parmval);
			parm = "dLg"; parmval = 9e-7; NMOS_MOD->setparm(parm, parmval);
			parm = "Cg"; parmval = 2.57e-6; NMOS_MOD->setparm(parm, parmval);
			parm = "beta"; parmval = 1.8; NMOS_MOD->setparm(parm, parmval);
			parm = "alpha"; parmval = 3.5; NMOS_MOD->setparm(parm, parmval);
			parm = "Tjun"; parmval = 300; NMOS_MOD->setparm(parm, parmval);
			parm = "Cif"; parmval = 1.38e-12; NMOS_MOD->setparm(parm, parmval);
			parm = "Cof"; parmval = 1.47e-12; NMOS_MOD->setparm(parm, parmval);
			parm = "phib"; parmval = 1.2; NMOS_MOD->setparm(parm, parmval);
			parm = "gamma"; parmval = 0.1; NMOS_MOD->setparm(parm, parmval);
			parm = "mc"; parmval = 0.2; NMOS_MOD->setparm(parm, parmval);
			parm = "CTM_select"; parmval = 1; NMOS_MOD->setparm(parm, parmval);
			parm = "Rs0"; parmval = 100; NMOS_MOD->setparm(parm, parmval);
			parm = "Rd0"; parmval = 100; NMOS_MOD->setparm(parm, parmval);
			parm = "n0"; parmval = 1.68; NMOS_MOD->setparm(parm, parmval);
			parm = "nd"; parmval = 0.1; NMOS_MOD->setparm(parm, parmval);
			parm = "vxo"; parmval = 1.2e7; NMOS_MOD->setparm(parm, parmval);
			parm = "mu"; parmval = 200; NMOS_MOD->setparm(parm, parmval);
			parm = "Vt0"; parmval = 0.4; NMOS_MOD->setparm(parm, parmval);
			parm = "delta"; parmval = 0.15; NMOS_MOD->setparm(parm, parmval);
		vector<untyped> NMOS_parms = NMOS_MOD->getparms();
		netlistElement * NMOS_el = new netlistElement(NMOS_name, NMOS_nodes, NMOS_parms, NMOS_MOD);
		elements.push_back(NMOS_el);

		string PMOS_name = "MP" + to_string(idx);
		vector<string> PMOS_nodes;
		if (9 == idx) {
			PMOS_nodes += "1", to_string(idx), "vdd", "vdd";
		} else {
			PMOS_nodes += to_string(idx+1), to_string(idx), "vdd", "vdd";
		}
		ModSpec_Element* PMOS_MOD = new MVS_1_0_1_ModSpec();
			parm = "type"; parmval = -1; PMOS_MOD->setparm(parm, parmval);
			parm = "W"; parmval = 1.0e-4; PMOS_MOD->setparm(parm, parmval);
			parm = "Lgdr"; parmval = 32e-7; PMOS_MOD->setparm(parm, parmval);
			parm = "dLg"; parmval = 8e-7; PMOS_MOD->setparm(parm, parmval);
			parm = "Cg"; parmval = 2.57e-6; PMOS_MOD->setparm(parm, parmval);
			parm = "beta"; parmval = 1.8; PMOS_MOD->setparm(parm, parmval);
			parm = "alpha"; parmval = 3.5; PMOS_MOD->setparm(parm, parmval);
			parm = "Tjun"; parmval = 300; PMOS_MOD->setparm(parm, parmval);
			parm = "Cif"; parmval = 1.38e-12; PMOS_MOD->setparm(parm, parmval);
			parm = "Cof"; parmval = 1.47e-12; PMOS_MOD->setparm(parm, parmval);
			parm = "phib"; parmval = 1.2; PMOS_MOD->setparm(parm, parmval);
			parm = "gamma"; parmval = 0.1; PMOS_MOD->setparm(parm, parmval);
			parm = "mc"; parmval = 0.2; PMOS_MOD->setparm(parm, parmval);
			parm = "CTM_select"; parmval = 1; PMOS_MOD->setparm(parm, parmval);
			parm = "Rs0"; parmval = 100; PMOS_MOD->setparm(parm, parmval);
			parm = "Rd0"; parmval = 100; PMOS_MOD->setparm(parm, parmval);
			parm = "n0"; parmval = 1.68; PMOS_MOD->setparm(parm, parmval);
			parm = "nd"; parmval = 0.1; PMOS_MOD->setparm(parm, parmval);
			parm = "vxo"; parmval = 7542204; PMOS_MOD->setparm(parm, parmval);
			parm = "mu"; parmval = 165; PMOS_MOD->setparm(parm, parmval);
			parm = "Vt0"; parmval = 0.5535; PMOS_MOD->setparm(parm, parmval);
			parm = "delta"; parmval = 0.15; PMOS_MOD->setparm(parm, parmval);
		vector<untyped> PMOS_parms = PMOS_MOD->getparms();
		netlistElement * PMOS_el = new netlistElement(PMOS_name, PMOS_nodes, PMOS_parms, PMOS_MOD);
		elements.push_back(PMOS_el);

		string cap_name = "C" + to_string(idx);
		vector<string> cap_nodes;
		cap_nodes += to_string(idx), "0";
		ModSpec_Element* cap_MOD = new capModSpec();
			parm = "C"; parmval = 3e-15; cap_MOD->setparm(parm, parmval);
		vector<untyped> cap_parms = cap_MOD->getparms();
		netlistElement * cap_el = new netlistElement(cap_name, cap_nodes, cap_parms, cap_MOD);
		elements.push_back(cap_el);
	}
}

// destructor
MVS_9_stage_ring_oscillator_ckt::~MVS_9_stage_ring_oscillator_ckt() {
	// TODO: is default good enough? No memory leaks?
}
