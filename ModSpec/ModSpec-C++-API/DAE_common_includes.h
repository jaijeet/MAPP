// these are common routines that are #included within the class definition of every hand-coded DAE.
// Ideally, these would be defined as virtual functions of the base class DAEAPI, but
// this is not possible currently because C++ does not allow inheritance of virtual templated functions.
	public:
		
		vector<double> f(vector<double>& x, vector<double>& u) {
			return f_tmpl<double,double,double>(x, u);
		}

		vector<double> q(vector<double>& x) {
			return q_tmpl<double,double>(x);
		}

		// numerical jacobians
		spMatrix df_dx(vector<double>& x, vector<double>& u){
			return dfq_dxu<DFAD>(x, u, 'f', 'x');
		}
		spMatrix df_du(vector<double>& x, vector<double>& u){
			return dfq_dxu<DFAD>(x, u, 'f', 'u');
		}
		spMatrix dq_dx(vector<double>& x){
			vector<double> u; // not used by q
			return dfq_dxu<DFAD>(x, u, 'q', 'x');
		}

	protected:
		// sacado-based AD function used to derive all the _stamp and d_?d_? public functions below
		template <typename FADT>
  			spMatrix dfq_dxu(vector<double>& x, vector<double>& u, char fORq, char xORu) {
				vector<double> the_input;
				switch (xORu) {
					case 'x':
						the_input = x;
						break;
					case 'u':
						the_input = u;
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
				if (fORq == 'f') {
					// f
					switch (xORu) {
						case 'x':
							FADTout = f_tmpl<FADT,FADT,double>(FADTin, u);
							break;
						case 'u':
							FADTout = f_tmpl<FADT,double,FADT>(x, FADTin);
							break;
						default:
							// fprintf(error)
							break;
					};
				} else {
					// q
					switch (xORu) {
						case 'x':
							FADTout = q_tmpl<FADT,FADT>(FADTin);
							break;
						default:
							// fprintf(error)
							break;
					};
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
