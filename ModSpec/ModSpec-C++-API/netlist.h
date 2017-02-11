#ifndef NETLIST_H
#define NETLIST_H

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
#include "ModSpec_Element.h"

using namespace std; // needed to disambiguate std::vector from boost::numeric::ublas::vector

class netlistElement {
	public:
		netlistElement(){};
		netlistElement( string name,
						vector<string>& nodes,
						vector<untyped>& parms,
						ModSpec_Element* ModSpecPtr)
					: name(name),
                      nodes(nodes),
                      parms(parms),
                      ModSpecPtr(ModSpecPtr) {};
		virtual ~netlistElement() {
			delete ModSpecPtr;
		}

	public:
		string name;
		vector<string> nodes;
		vector<untyped> parms;
		ModSpec_Element * ModSpecPtr;

	public:
		/*
		// no function fields right now
		virtual string name() = 0;
		*/
};

class netlist { // this is an abstract base class that defines netlist
	public:
		netlist(){};
		virtual ~netlist() {
			for (vector<netlistElement * >::iterator it = elements.begin(); it != elements.end(); ++it) {
				delete *it;
			}
		}

	public:
		string name;
		vector<string> node_names;
		vector<netlistElement * > elements;

	public:
		/*
		// no function fields right now
		virtual vector<string> getNodeNames = 0;
		virtual void setNodeNames(vector<string>& node_names) = 0;

		virtual string getName = 0;
		virtual void setName(string name) = 0;


		friend void add_element() = 0;
		add_element(MOD, string elname, vector<string>& nodes, parms, uinfo);
		*/

};

// the types of the class factories, used for enabling dlopen 
// typedef netlist *create_t();
// typedef void destroy_t(netlist*);

#endif // NETLIST_H
