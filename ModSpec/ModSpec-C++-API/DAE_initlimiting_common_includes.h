// these are common routines that are #included within the class definition of every hand-coded DAE.
// Ideally, these would be defined as virtual functions of the base class DAEAPI, but
// this is not possible currently because C++ does not allow inheritance of virtual templated functions.
	public:
		
		vector<double> f(vector<double>& x, vector<double>& xlim, vector<double>& u) {
			return f_tmpl<double,double,double,double>(x, xlim, u);
		}

		vector<double> q(vector<double>& x, vector<double>& xlim) {
			return q_tmpl<double,double,double>(x, xlim);
		}

		// numerical jacobians
		spMatrix df_dx(vector<double>& x, vector<double>& xlim, vector<double>& u){
			return dfq_dxlu<DFAD>(x, xlim, u, 'f', 'x');
		}
		spMatrix df_dxlim(vector<double>& x, vector<double>& xlim, vector<double>& u){
			return dfq_dxlu<DFAD>(x, xlim, u, 'f', 'l');
		}
		spMatrix df_du(vector<double>& x, vector<double>& xlim, vector<double>& u){
			return dfq_dxlu<DFAD>(x, xlim, u, 'f', 'u');
		}
		spMatrix dq_dx(vector<double>& x, vector<double>& xlim){
			vector<double> u; // not used by q
			return dfq_dxlu<DFAD>(x, xlim, u, 'q', 'x');
		}
		spMatrix dq_dxlim(vector<double>& x, vector<double>& xlim){
			vector<double> u; // not used by q
			return dfq_dxlu<DFAD>(x, xlim, u, 'q', 'l');
		}

	protected:
		// sacado-based AD function used to derive all the _stamp and d_?d_? public functions below
		template <typename FADT>
  			spMatrix dfq_dxlu(vector<double>& x, vector<double>& xlim, vector<double>& u, char fORq, char xlORu) {
				vector<double> the_input;
				switch (xlORu) {
					case 'x':
						the_input = x;
						break;
					case 'l':
						the_input = xlim;
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
					switch (xlORu) {
						case 'x':
							FADTout = f_tmpl<FADT,FADT,double,double>(FADTin, xlim, u);
							break;
						case 'l':
							FADTout = f_tmpl<FADT,double,FADT,double>(x, FADTin, u);
							break;
						case 'u':
							FADTout = f_tmpl<FADT,double,double,FADT>(x, xlim, FADTin);
							break;
						default:
							// fprintf(error)
							break;
					};
				} else {
					// q
					switch (xlORu) {
						case 'x':
							FADTout = q_tmpl<FADT,FADT,double>(FADTin, xlim);
							break;
						case 'l':
							FADTout = q_tmpl<FADT,double,FADT>(x, FADTin);
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
