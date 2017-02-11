#include "Res_ModSpec_Element.h"

// constructor
template <typename TOUT, typename TX, typename TY, typename TU>
  Res_ModSpec_Element_with_templated_fqei<TOUT,TX,TY,TU>::Res_ModSpec_Element_with_templated_fqei()
  		:ModSpec_Element_with_templated_fqei<TOUT,TX,TY,TU>() {
	// parm_names[0] = "R";
	this->parm_names.push_back("R");
	
	// parm_descriptions[0] = "resistance";
	this->parm_descriptions.push_back("resistance");
	//
	// parm_units[0] = "ohm";
	this->parm_units.push_back("ohm");
	
	/* type now subsumed within untyped class
	// parm_types[0] = "double";
	this->parm_types.push_back("double");
	*/

	// parm_defaultvals
	this->parm_defaultvals.push_back(1000);

	// parm_vals
	this->parm_vals = this->parm_defaultvals;

	//node_names[0] = "p";
	//node_names[1] = "n";
	this->node_names.push_back("p");
	this->node_names.push_back("n");
	
	this->refnode_name = "n";
	// ??? parm_vals;
	// ??? parm_defaultvals;
	// io_names; set up in base class constructor, should
	// be {'vpn', 'ipn'}
	
	// io_types[0] = "v";
	// io_types[1] = "i";
	this->io_types.push_back("v");
	this->io_types.push_back("i");

	// io_nodenames[0] = "p";
	// io_nodenames[1] = "p";
	this->io_nodenames.push_back("p");
	this->io_nodenames.push_back("p");

	// explicit_output_names[0] = "ipn";
	this->explicit_output_names.push_back("ipn");
	
	// otherio_names: set up in base class constructor,
	// should be "vpn"
	// internal_unk_names should be empty: set up in base class
	// implicit_equation_names should be empty: set up in base class
	// u_names should be empty: set up in base class
	//
	this->setup_ios_otherios();
}

// fqei
template <typename TOUT, typename TX, typename TY, typename TU>
  vector<TOUT> Res_ModSpec_Element_with_templated_fqei<TOUT,TX,TY,TU>::fqei(vector<TX>& vecX, vector<TY>& vecY, vector<TU>& vecU, char eORi, char fORq) {
	vector<TOUT> fqout;

	// inputs: vecX = vpn, vecY = [], vecU = []
	// outputs:
	TX vpn = vecX[0];
	double R = this->parm_vals[0];
	if (eORi == 'e') { // e => return vecZf = ipn
		if (fORq == 'f') { // f
			TOUT ipn = vpn/R;
			fqout.push_back(ipn);
		} else { // q => return vecZq = 0
			fqout.push_back(0);
		}
	} else { // i => return vecW = []
		// do nothing: return empty fqout
	}
	return fqout;
}

// this gets the compiler to instantiate specific templates, only then will they be found at link time.
// see http://azimbabu.blogspot.com/2010/01/compilation-and-linking-issues-for-c.html
void junk() {
	Res_ModSpec_Element oof;
	Res_ModSpec_Element_with_sacado_Jacobians poof;
}

/*

template <typename FADT>
  spMatrix Res_ModSpec_Element_with_sacado_Jacobians::d_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char forq, char eori) {
	// set parms of ddX_stamp_element to current values of parameters
	Res_ModSpec_Element_with_templated_fqei<FADT,FADT,double,double> d_element;
	d_element.setparms(parm_vals);

	vector<FADT> dvecX, dvecOUT;

	unsigned int lenX = vecX.size();

	// set values and indep vars of X in sequence
	dvecX.resize(lenX);
	for (unsigned int i=0; i<lenX; i++) {
		dvecX[i] = vecX[i]; dvecX[i].diff(i,lenX);
	}

	// call the function
	switch(forq) {
		case 'f':
			switch(eori) {
				case 'e':
					dvecOUT = d_element.fe(dvecX, vecY, vecU);
					break;
				case 'i':
					dvecOUT = d_element.fi(dvecX, vecY, vecU);
					break;
				default:
					fprintf(stderr, "d_dX: unknown value for eori; should be 'e' or 'i'\n");
			};
			break;
		case 'q':
			switch(eori) {
				case 'e':
					dvecOUT = d_element.qe(dvecX, vecY);
					break;
				case 'i':
					dvecOUT = d_element.qi(dvecX, vecY);
					break;
				default:
					fprintf(stderr, "d_dX: unknown value for eori; should be 'e' or 'i'\n");
			};
			break;
		default:
			fprintf(stderr, "d_dX: unknown value for forq; should be 'f' or 'q'\n");
	};
	
	// extract the Jacobian into dfe_dX
	unsigned int lenOUT = dvecOUT.size();

	spMatrix d_dX_OUT(lenOUT, lenX);
	for (unsigned int i=0; i<lenOUT; i++) {
		for (unsigned int j=0; j<lenX; j++) {
			d_dX_OUT(i,j) = dvecOUT[i].dx(j);
		}
	}
	return d_dX_OUT;
}

template <typename FADT>
  spMatrix Res_ModSpec_Element_with_sacado_Jacobians::d_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char forq, char eori) {
	// set parms of ddY_stamp_element to current values of parameters
	Res_ModSpec_Element_with_templated_fqei<FADT,double,FADT,double> d_element;
	d_element.setparms(parm_vals);

	vector<FADT> dvecY, dvecOUT;

	unsigned int lenY = vecY.size();

	// set indep vars of Y in sequence
	for (unsigned int i=0; i<lenY; i++) {
		dvecY[i] = vecY[i]; dvecY[i].diff(i,lenY);
	}


	// call the function
	switch(forq) {
		case 'f':
			switch(eori) {
				case 'e':
					dvecOUT = d_element.fe(vecX, dvecY, vecU);
					break;
				case 'i':
					dvecOUT = d_element.fi(vecX, dvecY, vecU);
					break;
				default:
					fprintf(stderr, "d_dY: unknown value for eori; should be 'e' or 'i'\n");
			};
			break;
		case 'q':
			switch(eori) {
				case 'e':
					dvecOUT = d_element.qe(vecX, dvecY);
					break;
				case 'i':
					dvecOUT = d_element.qi(vecX, dvecY);
					break;
				default:
					fprintf(stderr, "d_dY: unknown value for eori; should be 'e' or 'i'\n");
			};
			break;
		default:
			fprintf(stderr, "d_dY: unknown value for forq; should be 'f' or 'q'\n");
	};
	
	// extract the Jacobian into dfe_dX
	unsigned int lenOUT = dvecOUT.size();

	spMatrix d_dY_OUT(lenOUT,lenY);
	for (unsigned int i=0; i<lenOUT; i++) {
		for (unsigned int j=0; j<lenY; j++) {
			d_dY_OUT(i,j) = dvecOUT[i].dx(j);
		}
	}
	return d_dY_OUT;
}

template <typename FADT>
  spMatrix Res_ModSpec_Element_with_sacado_Jacobians::df_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char eori) {
	// set parms of ddY_stamp_element to current values of parameters
	Res_ModSpec_Element_with_templated_fqei<FADT,double,double,FADT> d_element;
	d_element.setparms(parm_vals);

	vector<FADT> dvecU, dvecOUT;

	unsigned int lenU = vecU.size();

	// set indep vars of Y in sequence
	for (unsigned int i=0; i<lenU; i++) {
		dvecU[i] = vecU[i]; dvecU[i].diff(i,lenU);
	}


	// call the function
	switch(eori) {
		case 'e':
			dvecOUT = d_element.fe(vecX, vecY, dvecU);
			break;
		case 'i':
			dvecOUT = d_element.fi(vecX, vecY, dvecU);
			break;
		default:
			fprintf(stderr, "df_dU: unknown value for eori; should be 'e' or 'i'\n");
	};
	
	// extract the Jacobian into dfe_dX
	unsigned int lenOUT = dvecOUT.size();

	spMatrix d_dU_OUT(lenOUT, lenU);
	for (unsigned int i=0; i<lenOUT; i++) {
		for (unsigned int j=0; j<lenU; j++) {
			d_dU_OUT(i,j) = dvecOUT[i].dx(j);
		}
	}
	return d_dU_OUT;
}

// ddX stamp functions
spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfe_dX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dX<LFADsp>(vecX, vecY, vecU, 'f', 'e');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfi_dX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dX<LFADsp>(vecX, vecY, vecU, 'f', 'i');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dqe_dX_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dX<LFADsp>(vecX, vecY, vecU, 'q', 'e');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dqi_dX_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dX<LFADsp>(vecX, vecY, vecU, 'q', 'i');
}


// ddY stamp functions
spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfe_dY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dY<LFADsp>(vecX, vecY, vecU, 'f', 'e');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfi_dY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dY<LFADsp>(vecX, vecY, vecU, 'f', 'i');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dqe_dY_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dY<LFADsp>(vecX, vecY, vecU, 'q', 'e');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dqi_dY_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dY<LFADsp>(vecX, vecY, vecU, 'q', 'i');
}

// ddU stamp functions
spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfe_dU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return df_dU<LFADsp>(vecX, vecY, vecU, 'e');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfi_dU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return df_dU<LFADsp>(vecX, vecY, vecU, 'i');
}

		
// numerical jacobians
// ddX functions
spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfe_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dX<DFAD>(vecX, vecY, vecU, 'f', 'e');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfi_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dX<DFAD>(vecX, vecY, vecU, 'f', 'i');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dqe_dX(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dX<DFAD>(vecX, vecY, vecU, 'q', 'e');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dqi_dX(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dX<DFAD>(vecX, vecY, vecU, 'q', 'i');
}


// ddY functions
spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfe_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dY<DFAD>(vecX, vecY, vecU, 'f', 'e');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfi_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dY<DFAD>(vecX, vecY, vecU, 'f', 'i');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dqe_dY(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dY<DFAD>(vecX, vecY, vecU, 'q', 'e');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dqi_dY(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dY<DFAD>(vecX, vecY, vecU, 'q', 'i');
}
		
// ddU functions
spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfe_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return df_dU<DFAD>(vecX, vecY, vecU, 'e');
}

spMatrix Res_ModSpec_Element_with_sacado_Jacobians::dfi_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return df_dU<DFAD>(vecX, vecY, vecU, 'i');
}
*/
