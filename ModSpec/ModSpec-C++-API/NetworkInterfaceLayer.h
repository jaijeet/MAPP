#ifndef NETWORKINTERFACELAYER
#define NETWORKINTERFACELAYER

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <algorithm>
#include <sstream>
#include "untyped.h"
#include <vector> // std::vector
#include "boost_ublas_includes_typedefs.h" // definition spMatrix == boost::numeric::ublas::mapped_matrix

using namespace std; // needed to disambiguate std::vector from boost::numeric::ublas::vector

class NetworkInterfaceLayer { // this is a pure abstract base class that defines API functions in network interface layer
	public:
		NetworkInterfaceLayer(){};
		~NetworkInterfaceLayer(){};
		
		// TODO:
		// 1. copy constructor
		// 2. operator=
		// 3. other operators?

	public:
		virtual vector<string> NodeNames() = 0;
		virtual vector<string> IOnames() = 0;
		virtual vector<string> IONodeNames() = 0;
		virtual vector<string> IOtypes() = 0;
};

#endif // NETWORKINTERFACELAYER
