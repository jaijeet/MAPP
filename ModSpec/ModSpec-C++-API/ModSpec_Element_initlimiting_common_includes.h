// these are common routines that are #included within the class definition of every ModSpec device.
// Ideally, these would be defined as virtual functions of the base class ModSpec_Element, but
// this is not possible currently because C++ does not allow inheritance of virtual templated functions.
	public:
		vector<double> fe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return fe_tmpl<double,double,double,double,double>(vecX, vecY, vecLim, vecU);
		}
		vector<double> qe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return qe_tmpl<double,double,double,double>(vecX, vecY, vecLim);
		}
		vector<double> fi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return fi_tmpl<double,double,double,double,double>(vecX, vecY, vecLim, vecU);
		}
		vector<double> qi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			return qi_tmpl<double,double,double,double>(vecX, vecY, vecLim);
		}

		// jacobian stamps
		// ddvecX functions
		spMatrix dfe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'f', 'e', 'X');
		}
		spMatrix dfi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) {
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'f', 'i', 'X');
		}
		spMatrix dqe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) {
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'q', 'e', 'X');
		}
		spMatrix dqi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'q', 'i', 'X');
		}

		// ddvecY functions
		spMatrix dfe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'f', 'e', 'Y');
		}
		spMatrix dfi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'f', 'i', 'Y');
		}
		spMatrix dqe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'q', 'e', 'Y');
		}
		spMatrix dqi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'q', 'i', 'Y');
		}
		
		// ddvecLim functions
		spMatrix dfe_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'f', 'e', 'L');
		}
		spMatrix dfi_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'f', 'i', 'L');
		}
		spMatrix dqe_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'q', 'e', 'L');
		}
		spMatrix dqi_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'q', 'i', 'L');
		}
		
		// ddvecU functions
		spMatrix dfe_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'f', 'e', 'U');
		}
		spMatrix dfi_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<LFADsp>(vecX, vecY, vecLim, vecU, 'f', 'i', 'U');
		}
		
		// numerical jacobians
		// ddvecX functions
		spMatrix dfe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'f', 'e', 'X');
		}
		spMatrix dfi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'f', 'i', 'X');
		}
		spMatrix dqe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'q', 'e', 'X');
		}
		spMatrix dqi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'q', 'i', 'X');
		}

		// ddvecY functions
		spMatrix dfe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'f', 'e', 'Y');
		}
		spMatrix dfi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'f', 'i', 'Y');
		}
		spMatrix dqe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'q', 'e', 'Y');
		}
		spMatrix dqi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'q', 'i', 'Y');
		}
		
		// ddvecLim functions
		spMatrix dfe_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'f', 'e', 'L');
		}
		spMatrix dfi_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'f', 'i', 'L');
		}
		spMatrix dqe_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'q', 'e', 'L');
		}
		spMatrix dqi_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim){
			vector<double> vecU; // not used by q
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'q', 'i', 'L');
		}
		
		// ddvecU functions
		spMatrix dfe_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'f', 'e', 'U');
		}
		spMatrix dfi_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU){
			return dfqei_dvecXYLU<DFAD>(vecX, vecY, vecLim, vecU, 'f', 'i', 'U');
		}

		// limiting function (and its derivatives) // Note: derivatives are not supported yet since they are not used anywhere right now; 
		vector<double> limiting(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU){
			return limiting_tmpl<double,double,double,double,double>(vecX, vecY, vecLimOld, vecU);
		}

	protected:
		// sacado-based AD function used to derive all the _stamp and d_?d_? public functions below
		// it calls fqei_tmpl
		template <typename FADT>
  			spMatrix dfqei_dvecXYLU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU, char fORq, char eORi, 
					    char XYLorU) {

				vector<double> the_input;
				switch (XYLorU) {
					case 'X':
						the_input = vecX;
						break;
					case 'Y':
						the_input = vecY;
						break;
					case 'L':
						the_input = vecLim;
						break;
					case 'U':
						the_input = vecU;
						break;
					default:
						// fprintf(error)
						break;
				};

				vector<FADT> FADTin, FADTout;
				//
				unsigned int lenIn = the_input.size();

				FADTin.resize(lenIn);

				// set values and indep vars of FADTin in sequence
				for (unsigned int i=0; i<lenIn; i++) {
					FADTin[i] = the_input[i]; FADTin[i].diff(i, lenIn); // .diff is like indep_index for gdouble
				}

				// call the function
				if (eORi == 'e') {
					if (fORq == 'f') {
						// fe
						switch (XYLorU) {
							case 'X':
								FADTout = fe_tmpl<FADT,FADT,double,double,double>(FADTin, vecY, vecLim, vecU);
								break;
							case 'Y':
								FADTout = fe_tmpl<FADT,double,FADT,double,double>(vecX, FADTin, vecLim, vecU);
								break;
							case 'L':
								FADTout = fe_tmpl<FADT,double,double,FADT,double>(vecX, vecY, FADTin, vecU);
								break;
							case 'U':
								FADTout = fe_tmpl<FADT,double,double,double,FADT>(vecX, vecY, vecLim, FADTin);
								break;
							default:
								// fprintf(error)
								break;
						};
					} else {
						// qe
						switch (XYLorU) {
							case 'X':
								FADTout = qe_tmpl<FADT,FADT,double,double>(FADTin, vecY, vecLim);
								break;
							case 'Y':
								FADTout = qe_tmpl<FADT,double,FADT,double>(vecX, FADTin, vecLim);
								break;
							case 'L':
								FADTout = qe_tmpl<FADT,double,double,FADT>(vecX, vecY, FADTin);
								break;
							default:
								// fprintf(error)
								break;
						};
					}
				} else {
					if (fORq == 'f') {
						// fi
						switch (XYLorU) {
							case 'X':
								FADTout = fi_tmpl<FADT,FADT,double,double,double>(FADTin, vecY, vecLim, vecU);
								break;
							case 'Y':
								FADTout = fi_tmpl<FADT,double,FADT,double,double>(vecX, FADTin, vecLim, vecU);
								break;
							case 'L':
								FADTout = fi_tmpl<FADT,double,double,FADT,double>(vecX, vecY, FADTin, vecU);
								break;
							case 'U':
								FADTout = fi_tmpl<FADT,double,double,double,FADT>(vecX, vecY, vecLim, FADTin);
								break;
							default:
								// fprintf(error)
								break;
						};
					} else {
						// qi
						switch (XYLorU) {
							case 'X':
								FADTout = qi_tmpl<FADT,FADT,double>(FADTin, vecY, vecLim);
								break;
							case 'Y':
								FADTout = qi_tmpl<FADT,double,FADT,double>(vecX, FADTin, vecLim);
								break;
							case 'L':
								FADTout = qi_tmpl<FADT,double,double,FADT>(vecX, vecY, FADTin);
								break;
							default:
								// fprintf(error)
								break;
						};
					}
				}

				// extract the Jacobian
				unsigned int lenOUT = FADTout.size();

				// output derivatives as an spMatrix (boost::...::mapped_matrix)
				spMatrix J_OUT(lenOUT, lenIn);
				for (unsigned int i=0; i<lenOUT; i++) {
					for (unsigned int j=0; j<lenIn; j++) {
						J_OUT(i,j) = FADTout[i].dx(j);
					}
				}
				return J_OUT;
			}
