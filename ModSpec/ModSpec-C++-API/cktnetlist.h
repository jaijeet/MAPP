#ifndef CKTNETLIST_H
#define CKTNETLIST_H

#include "netlist.h"

using namespace std; // needed to disambiguate std::vector from boost::numeric::ublas::vector

class cktnetlist : public netlist {
	public:
		cktnetlist(){};
		virtual ~cktnetlist(){};
		
	public:
		string ground_node_name;
};

#endif // CKTNETLIST_H
