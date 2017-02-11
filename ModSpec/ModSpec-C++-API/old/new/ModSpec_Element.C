#include "ModSpec_Element.h"


template <typename FADT>
  spMatrix sacado_Jacobian_functions<T_dX_stamp,T_dY_stamp,d_dZ_stamp,T_dX,T_dY,T_dZ>::d_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char forq, char eori) {
	// set parms of ddX_stamp_element to current values of parameters
	ELT<FADT,FADT,double,double> d_element;
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
  spMatrix sacado_Jacobian_functions<ELT>::d_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char forq, char eori) {
	// set parms of ddY_stamp_element to current values of parameters
	ELT<FADT,double,FADT,double> d_element;
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
  spMatrix sacado_Jacobian_functions<ELT>::df_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char eori) {
	// set parms of ddY_stamp_element to current values of parameters
	ELT<FADT,double,double,FADT> d_element;
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
spMatrix sacado_Jacobian_functions<ELT>::dfe_dX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dX<LFADsp>(vecX, vecY, vecU, 'f', 'e');
}

spMatrix sacado_Jacobian_functions<ELT>::dfi_dX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dX<LFADsp>(vecX, vecY, vecU, 'f', 'i');
}

spMatrix sacado_Jacobian_functions<ELT>::dqe_dX_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dX<LFADsp>(vecX, vecY, vecU, 'q', 'e');
}

spMatrix sacado_Jacobian_functions<ELT>::dqi_dX_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dX<LFADsp>(vecX, vecY, vecU, 'q', 'i');
}


// ddY stamp functions
spMatrix sacado_Jacobian_functions<ELT>::dfe_dY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dY<LFADsp>(vecX, vecY, vecU, 'f', 'e');
}

spMatrix sacado_Jacobian_functions<ELT>::dfi_dY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dY<LFADsp>(vecX, vecY, vecU, 'f', 'i');
}

spMatrix sacado_Jacobian_functions<ELT>::dqe_dY_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dY<LFADsp>(vecX, vecY, vecU, 'q', 'e');
}

spMatrix sacado_Jacobian_functions<ELT>::dqi_dY_stamp(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dY<LFADsp>(vecX, vecY, vecU, 'q', 'i');
}

// ddU stamp functions
spMatrix sacado_Jacobian_functions<ELT>::dfe_dU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return df_dU<LFADsp>(vecX, vecY, vecU, 'e');
}

spMatrix sacado_Jacobian_functions<ELT>::dfi_dU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return df_dU<LFADsp>(vecX, vecY, vecU, 'i');
}

		
// numerical jacobians
// ddX functions
spMatrix sacado_Jacobian_functions<ELT>::dfe_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dX<DFAD>(vecX, vecY, vecU, 'f', 'e');
}

spMatrix sacado_Jacobian_functions<ELT>::dfi_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dX<DFAD>(vecX, vecY, vecU, 'f', 'i');
}

spMatrix sacado_Jacobian_functions<ELT>::dqe_dX(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dX<DFAD>(vecX, vecY, vecU, 'q', 'e');
}

spMatrix sacado_Jacobian_functions<ELT>::dqi_dX(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dX<DFAD>(vecX, vecY, vecU, 'q', 'i');
}


// ddY functions
spMatrix sacado_Jacobian_functions<ELT>::dfe_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dY<DFAD>(vecX, vecY, vecU, 'f', 'e');
}

spMatrix sacado_Jacobian_functions<ELT>::dfi_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return d_dY<DFAD>(vecX, vecY, vecU, 'f', 'i');
}

spMatrix sacado_Jacobian_functions<ELT>::dqe_dY(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dY<DFAD>(vecX, vecY, vecU, 'q', 'e');
}

spMatrix sacado_Jacobian_functions<ELT>::dqi_dY(vector<double>& vecX, vector<double>& vecY) {
	vector<double> vecU; // not used by q
	return d_dY<DFAD>(vecX, vecY, vecU, 'q', 'i');
}
		
// ddU functions
spMatrix sacado_Jacobian_functions<ELT>::dfe_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return df_dU<DFAD>(vecX, vecY, vecU, 'e');
}

spMatrix sacado_Jacobian_functions<ELT>::dfi_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
	return df_dU<DFAD>(vecX, vecY, vecU, 'i');
}
