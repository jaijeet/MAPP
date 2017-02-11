#include "Xyce_ModSpec_Interface.h"

main(int argc, char** argv) {
	// get name of .so file from command line argument
	if (argc < 2) {
		fprintf(stderr, "Usage: %s <Some_ModSpec_Element.so>\nExample: %s ../Res_ModSpec_Element.so\n", argv[0], argv[0]);
		exit(1);
	}
	string soName = argv[1];

	Xyce_ModSpec_Interface XM_interface(soName);
	ModSpec_Element* ModSpecElPtr=XM_interface.ModSpecElPtr;

	// see notes in [XyceSVN]/Xyce/trunk/xyce-expts/Xyce-src-DeviceModelPKG-BERKELEY/src/Xyce_ModSpec_Notes.txt
	// to understand what's being done here
	
	vector<untyped> parmvals = ModSpecElPtr->getparms();
	vector<string> parm_names = ModSpecElPtr->parmnames();
	
	// now set all intParms to 10, all doubleParms to 20, and all stringparms to "30"
	for (int i=0; i < XM_interface.intParms.size(); i++) XM_interface.intParms[i] = 10;
	for (int i=0; i < XM_interface.doubleParms.size(); i++) XM_interface.doubleParms[i] = 20;
	for (int i=0; i < XM_interface.stringParms.size(); i++) XM_interface.stringParms[i] = "30";

	fprintf(stdout, "parms (before setparms()):\n\t"); print_vector_of_untyped(parm_names, parmvals);
	XM_interface.set_ModSpec_parms_from_typedParmLists();
	fprintf(stdout, "parms (after setparms()/set_ModSpec_parms_from_typedParmLists followed by getparms()):\n\t"); 
		print_vector_of_untyped(parm_names, ModSpecElPtr->getparms());
}
