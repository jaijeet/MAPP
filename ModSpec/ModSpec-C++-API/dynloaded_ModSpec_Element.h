#ifndef DYNLOADED_MODSPEC_ELEMENT_H
#define DYNLOADED_MODSPEC_ELEMENT_H

#include "ModSpec_Element.h"
#include <iostream>
#include <dlfcn.h>

class dynloaded_ModSpec_Element {
	protected:
		string soName;
		void* ModSpec_Element_so;
		create_t* create_ModSpec_Element;
		destroy_t* destroy_ModSpec_Element;
	public:
		ModSpec_Element* ModSpecElPtr;
		dynloaded_ModSpec_Element(string SONAME): soName(SONAME) { // constructor
			// load the .so library and create a ModSpec object
			this->ModSpec_Element_so = dlopen(soName.c_str(), RTLD_LAZY);
			if (!ModSpec_Element_so) {
			    cerr << "Cannot load library: " << dlerror() << '\n';
			    exit(1);
			}

			// reset errors
			dlerror();

			// load the symbols
			this->create_ModSpec_Element = (create_t*) dlsym(ModSpec_Element_so, "create");
			const char* dlsym_error = dlerror();
			if (dlsym_error) {
			    cerr << "Cannot load symbol create: " << dlsym_error << '\n';
			    exit(1);
			}

			destroy_ModSpec_Element = (destroy_t*) dlsym(ModSpec_Element_so, "destroy");
			dlsym_error = dlerror();
			if (dlsym_error) {
			    cerr << "Cannot load symbol destroy: " << dlsym_error << '\n';
			    exit(1);
			}

			// now obtained via DLopen: a ModSpec Element
			// create an instance of the class
			this->ModSpecElPtr = create_ModSpec_Element();
			// END load .so library and create ModSpec object
			////////////////////////////////////////////////////////////////
		};

		~dynloaded_ModSpec_Element(){
			// destroy the element
			destroy_ModSpec_Element(ModSpecElPtr);

			// unload the so library
			dlclose(ModSpec_Element_so);
		};
};
#endif // DYNLOADED_MODSPEC_ELEMENT_H
