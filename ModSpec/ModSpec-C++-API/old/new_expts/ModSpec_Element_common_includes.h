	public:
		
		// fqei for ModSpec_Element - it was a pure virtual there
		vector<double> fqei(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char eORi, char fORq) {
			return fqei_tmpl<double,double,double,double>(vecX, vecY, vecU, eORi, fORq);
		}

		// jacobian stamps
		// ddX functions
		spMatrix dfe_dX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			return dfqei_dXYU<LFADsp>(vecX, vecY, vecU, 'f', 'e', 'X');
		}
		spMatrix dfi_dX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			return dfqei_dXYU<LFADsp>(vecX, vecY, vecU, 'f', 'i', 'X');
		}
		spMatrix dqe_dX_stamp(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecU; // not used by q
			return dfqei_dXYU<LFADsp>(vecX, vecY, vecU, 'q', 'e', 'X');
		}
		spMatrix dqi_dX_stamp(vector<double>& vecX, vector<double>& vecY){
			vector<double> vecU; // not used by q
			return dfqei_dXYU<LFADsp>(vecX, vecY, vecU, 'q', 'i', 'X');
		}

		// ddY functions
		spMatrix dfe_dY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU){
			return dfqei_dXYU<LFADsp>(vecX, vecY, vecU, 'f', 'e', 'Y');
		}
		spMatrix dfi_dY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU){
			return dfqei_dXYU<LFADsp>(vecX, vecY, vecU, 'f', 'i', 'Y');
		}
		spMatrix dqe_dY_stamp(vector<double>& vecX, vector<double>& vecY){
			vector<double> vecU; // not used by q
			return dfqei_dXYU<LFADsp>(vecX, vecY, vecU, 'q', 'e', 'Y');
		}
		spMatrix dqi_dY_stamp(vector<double>& vecX, vector<double>& vecY){
			vector<double> vecU; // not used by q
			return dfqei_dXYU<LFADsp>(vecX, vecY, vecU, 'q', 'i', 'U');
		}
		
		// ddU functions
		spMatrix dfe_dU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU){
			return dfqei_dXYU<LFADsp>(vecX, vecY, vecU, 'f', 'e', 'U');
		}
		spMatrix dfi_dU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU){
			return dfqei_dXYU<LFADsp>(vecX, vecY, vecU, 'f', 'i', 'U');
		}
		
		// numerical jacobians
		// ddX functions
		spMatrix dfe_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU){
			return dfqei_dXYU<DFAD>(vecX, vecY, vecU, 'f', 'e', 'X');
		}
		spMatrix dfi_dX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU){
			return dfqei_dXYU<DFAD>(vecX, vecY, vecU, 'f', 'i', 'X');
		}
		spMatrix dqe_dX(vector<double>& vecX, vector<double>& vecY){
			vector<double> vecU; // not used by q
			return dfqei_dXYU<DFAD>(vecX, vecY, vecU, 'q', 'e', 'X');
		}
		spMatrix dqi_dX(vector<double>& vecX, vector<double>& vecY){
			vector<double> vecU; // not used by q
			return dfqei_dXYU<DFAD>(vecX, vecY, vecU, 'q', 'i', 'X');
		}

		// ddY functions
		spMatrix dfe_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU){
			return dfqei_dXYU<DFAD>(vecX, vecY, vecU, 'f', 'e', 'Y');
		}
		spMatrix dfi_dY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU){
			return dfqei_dXYU<DFAD>(vecX, vecY, vecU, 'f', 'i', 'Y');
		}
		spMatrix dqe_dY(vector<double>& vecX, vector<double>& vecY){
			vector<double> vecU; // not used by q
			return dfqei_dXYU<DFAD>(vecX, vecY, vecU, 'q', 'e', 'Y');
		}
		spMatrix dqi_dY(vector<double>& vecX, vector<double>& vecY){
			vector<double> vecU; // not used by q
			return dfqei_dXYU<DFAD>(vecX, vecY, vecU, 'q', 'i', 'Y');
		}
		
		// ddU functions
		spMatrix dfe_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU){
			return dfqei_dXYU<DFAD>(vecX, vecY, vecU, 'f', 'e', 'U');
		}
		spMatrix dfi_dU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU){
			return dfqei_dXYU<DFAD>(vecX, vecY, vecU, 'f', 'i', 'U');
		}
	protected:
		// sacado-based AD function used to derive all the _stamp and d_?d_? public functions below
		// it calls fqei_tmpl
		template <typename FADT>
  			spMatrix dfqei_dXYU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU, char fORq, char eORi, 
					    char XYorU) {
				// set parms of ddY_stamp_element to current values of parameters


				vector<double> the_input;
				switch (XYorU) {
					case 'X':
						the_input = vecX;
						break;
					case 'Y':
						the_input = vecY;
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
					FADTin[i] = the_input[i]; FADTin[i].diff(i, lenIn);
				}

				// call the function
				switch (XYorU) {
					case 'X':
						FADTout = fqei_tmpl<FADT,FADT,double,double>(FADTin, vecY, vecU, eORi, fORq);
						break;
					case 'Y':
						FADTout = fqei_tmpl<FADT,double,FADT,double>(vecX, FADTin, vecU, eORi, fORq);
						break;
					case 'U':
						FADTout = fqei_tmpl<FADT,double,double,FADT>(vecX, vecY, FADTin, eORi, fORq);
						break;
					default:
						// fprintf(error)
						break;
				};


				// extract the Jacobian into dfe_dX
				unsigned int lenOUT = FADTout.size();

				spMatrix J_OUT(lenOUT, lenIn);
				for (unsigned int i=0; i<lenOUT; i++) {
					for (unsigned int j=0; j<lenIn; j++) {
						J_OUT(i,j) = FADTout[i].dx(j);
					}
				}
				return J_OUT;
			}
