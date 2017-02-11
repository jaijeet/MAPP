#include "dynloaded_ModSpec_Element.h"
#include <iostream>
#include <fstream>

using namespace std;

void write_Xyce_plugin_from_template(const string& infile, const string& outfile, ModSpec_Element * MODp, const string& model_name);
void substitute_keyword(ofstream& fout, const string& keyword, int n_indent, ModSpec_Element * MODp, const string& model_name);

main(int argc, char** argv) {

	// fprintf(stdout, "argc=%d\n", argc);
	
	if (argc < 2) {
		fprintf(stderr, "Usage: %s <Some_ModSpec_Element.so>\nExample: %s ./Res_ModSpec_Element.so\n", argv[0], argv[0]);
		exit(1);
	}

	string soName = argv[1];
	
	// dlopen soName, create a ModSpec element, and get a pointer to it.
	dynloaded_ModSpec_Element elSo(soName);
	ModSpec_Element* MODp = elSo.ModSpecElPtr;

	fprintf(stdout, "Reading %s ... \n", soName.c_str());

	// get model name, write a file based on it.
	string ModSpec_model_name = MODp->ModelName();
	fprintf(stdout, "ModSpec's model name: %s.\n", ModSpec_model_name.c_str());
	// substitute special characters in ModSpec_model_name with underscore.
	for (int i = 0; i < ModSpec_model_name.length(); i++)
	{
		if (!(isalnum(ModSpec_model_name[i]) || ModSpec_model_name[i] == '_')) {
			// special character, not digit, not letter, not underscore.
			ModSpec_model_name[i] = '_';
		}
	}
	string model_name = "ModSpec_" + ModSpec_model_name;
	fprintf(stdout, "Xyce's model name: %s.\n", model_name.c_str());

	// string basedirname = ""; // TODO: use configure system
	// string dirname = basedirname + ""; // TODO
	string dirname = "./";

	string infile;
	string outfile;

	// .h
	infile = dirname + "N_DEV_ModSpec.h_template";
	outfile = dirname + "N_DEV_" + model_name + ".h";

	fprintf(stdout, "Writing %s ... \n", outfile.c_str());
	write_Xyce_plugin_from_template(infile, outfile, MODp, model_name);

	// .C
	infile = dirname + "N_DEV_ModSpec.C_template";
	outfile = dirname + "N_DEV_" + model_name + ".C";

	fprintf(stdout, "Writing %s ... \n", outfile.c_str());
	write_Xyce_plugin_from_template(infile, outfile, MODp, model_name);

	// bootstrap.C
	infile = dirname + "N_DEV_ModSpec_bootstrap.C_template";
	outfile = dirname + "N_DEV_" + model_name + "_bootstrap.C";

	fprintf(stdout, "Writing %s ... \n", outfile.c_str());
	write_Xyce_plugin_from_template(infile, outfile, MODp, model_name);

	fprintf(stdout, "done.\n");

	fprintf(stdout, "\n");
	fprintf(stdout, "Some instructions on using the generated files in Xyce:\n");
	fprintf(stdout, "1. If you haven't done so already, compile and install Xyce_ModSpec_Interface.\n");
	fprintf(stdout, "   [TODO].\n");
	fprintf(stdout, "2. Put the three generated files under the user_plugin directory.\n");
	fprintf(stdout, "3. Append the following lines to Makefile.am.\n");
	fprintf(stdout, "   [TODO].\n");
}

void write_Xyce_plugin_from_template(const string& infile, const string& outfile, ModSpec_Element * MODp, const string& model_name) {
	
	ifstream fin (infile.c_str());
	ofstream fout (outfile.c_str());

	// some basic checks TODO: check whether fout exists.
	if (!fin.is_open()) {
		cout << "Unable to open file: " << infile.c_str();
		return;
	}
	if (!fout.is_open()) {
		cout << "Unable to write file: " << outfile.c_str();
		return;
	}

	enum STATES
	{
		NORMAL = 0,
		PREKEYWORD,
		KEYWORD
	};

	/* Here we don't use any Finite State Machine table, because the state
	   transition is simple.

	   Start at NORMAL.

	   When at NORMAL, unless we see a '@' and jump to PREKEYWORD, stay at
	   NORMAL. In the meanwhile, record indentation: if char == '\r', clear
	   n_indent; if char == '\t', add 4; else, add 1.
	  
	   When at PREKEYWORD, if we see '{', jump to KEYWORD; else, jump back to
	   NORMAL, print '@'.
	  
	   When at KEYWORD, if we see '}', return to NORMAL, and do the real work,
	   then clear keyword; else if (isalnum(ch) || ch == '_'), append
	   char to keyword; else, it is special char, error, break, close,
	   return.
	*/
	// Assumptions on keywords
	//  - at most one @ per line.
	//  - @{key}, key doesn't contain '{', '}', or '@'.
	//  - key can be viewed as a string, and we can use strcmp on it.

	char ch;
	int n_indent = 0;
    string keyword;
	int current_state = NORMAL;

	while (fin.get(ch))
	{
		switch(current_state) {
		case NORMAL :
			if (ch == '@') {
				current_state = PREKEYWORD;
			} else {
				fout << ch;
				switch(ch) {
				case '\n' :
					n_indent = 0;
					break;
				case '\t' :
					n_indent += 4;
					break;
				default :
					n_indent++;
				}
			}
			break;
		case PREKEYWORD :
			if (ch == '{') {
				current_state = KEYWORD;
				keyword = "";
			} else {
				current_state = NORMAL;
				fout << '@';
			}
			break;
		case KEYWORD :
			if (ch == '}') {
				current_state = NORMAL;
				// do the real work, with n_indent and keyword
				// cout << n_indent << "  " << keyword << endl;
				substitute_keyword(fout, keyword, n_indent, MODp, model_name);
			} else if (isalnum(ch) || ch == '_') {
				keyword += ch;
			} else {
				// error
				cout << "Error: Invalid template file " << infile.c_str() <<
						" --- keyword contains special characters : " << ch << endl;
				fin.close();
				fout.close();
				return;
			}
		}
	}

	fin.close();
	fout.close();

}

void substitute_keyword(ofstream& fout, const string& keyword, int n_indent, ModSpec_Element * MODp, const string& model_name) {
	//availabel keywords:
	// model_name
	// nNodes
	// declare_parms
	//			double version;
	// addPar_parms
	// 			p.addPar("version",     1.01,    &@{model_name}::Instance::version)
	// 			  .setUnit(U_NONE)
	// 			  .setDescription("None");
	// set_parms
	// 			parms[0]	= version;
	// addInternalNodes 
	//			addInternalNode(symbol_table, this->intLIDVec[0], getName(), "di");
	//			addInternalNode(symbol_table, this->intLIDVec[1], getName(), "si");
	if (keyword.compare("model_name") == 0) {
		fout << model_name;
	} else if (keyword.compare("nNodes") == 0) {
		fout << MODp->NILp->NodeNames().size();
	} else if (keyword.compare("declare_parms") == 0) {
		vector<string> pnames = MODp->parmnames();
		vector<untyped> pvals = MODp->parmdefaults();
		for (int i=0; i< pnames.size(); i++) {
			if (i != 0) {
				fout << endl << string(n_indent, ' ' ).c_str();
			}
			untyped u = pvals[i];
			untyped_TYPE _type = u.type();
			switch(_type) {
			case T_DOUBLE:
				fout << "double ";
				break;
			case T_INT:
				fout << "int ";
				break;
			case T_STRING:
				fout << "std::string ";
				break;
			default: ;
				// TODO: error
			}
			fout << pnames[i].c_str() << ';';
		}
	} else if (keyword.compare("addPar_parms") == 0) {
		vector<string> pnames = MODp->parmnames();
		vector<untyped> pvals = MODp->parmdefaults();
		for (int i=0; i< pnames.size(); i++) {
			if (i != 0) {
				fout << endl << string(n_indent, ' ' ).c_str();
			}
			fout << "p.addPar(\"" << pnames[i] <<"\", ";
			untyped u = pvals[i];
			untyped_TYPE _type = u.type();
			eString oof;
			switch(_type) {
			case T_DOUBLE:
				fout << "double(" << double(pvals[i]) << ")";
				break;
			case T_INT:
				fout << pvals[i];
				break;
			case T_STRING:
				oof = u;
				fout << oof.c_str(); // TODO: double check
				break;
			default: ;
				// TODO: error
			}
			fout << ", &" << model_name << "::Instance::" << pnames[i] << ")" << endl; // ugly
			fout << string(n_indent, ' ' ).c_str() << " .setUnit(U_NONE)" << endl;
			fout << string(n_indent, ' ' ).c_str() << " .setDescription(\"None\");";
		}
	} else if (keyword.compare("set_parms") == 0) {
		vector<string> pnames = MODp->parmnames();
		for (int i=0; i< pnames.size(); i++) {
			if (i != 0) {
				fout << endl << string(n_indent, ' ' ).c_str();
			}
			fout << "parms[" << i << "] = " << pnames[i].c_str() << ';';
		}
	} else if (keyword.compare("addInternalNodes") == 0) {
		vector<string> InternalUnkNames = MODp->InternalUnkNames();
		for (int i=0; i< InternalUnkNames.size(); i++) {
			if (i != 0) {
				fout << endl << string(n_indent, ' ' ).c_str();
			}
			fout << "addInternalNode(symbol_table, this->intLIDVec[" << i
				<< "], getName(), \"" << InternalUnkNames[i] <<  "\");";
		}
	} else {
		// TODO: error
	}
	return;
}
