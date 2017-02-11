#ifndef EE_MODEL_INITLIMITING
#define EE_MODEL_INITLIMITING

#include "ee_model.h"
#include "ublas_matrix_std_vector_ops.h" // defines prod(), add(), subtract() for vector<double>

class ee_model_initlimiting : public ee_model { // this is a still an abstract base class
	public:
		ee_model_initlimiting(){};
		virtual ~ee_model_initlimiting(){};

	protected:
		vector<string> limited_var_names;
		spMatrix vecXY_to_limited_vars_matrix;

	public:
		// core model functions with init/limiting
		virtual vector<double> fe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual vector<double> fi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual vector<double> qe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;
		virtual vector<double> qi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;

		// jacobian stamps with init/limiting
		// ddvecX functions
		virtual spMatrix dfe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dqe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;
		virtual spMatrix dqi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;

		// ddvecY functions
		virtual spMatrix dfe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dqe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;
		virtual spMatrix dqi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;
		
		// ddvecU functions
		virtual spMatrix dfe_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		
		// ddvecLim functions
		virtual spMatrix dfe_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dqe_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;
		virtual spMatrix dqi_dvecLim_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;
		
		// derivatives with init/limiting
		// ddvecX functions
		virtual spMatrix dfe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dqe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;
		virtual spMatrix dqi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;

		// ddvecY functions
		virtual spMatrix dfe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dqe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;
		virtual spMatrix dqi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;
		
		// ddvecU functions
		virtual spMatrix dfe_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;

		// ddvecLim functions
		virtual spMatrix dfe_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dfi_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim, vector<double>& vecU) = 0;
		virtual spMatrix dqe_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;
		virtual spMatrix dqi_dvecLim(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLim) = 0;

		// core model functions
		virtual vector<double> fe(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			return fe(vecX, vecY, vecLim, vecU);
		}
		virtual vector<double> fi(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			return fi(vecX, vecY, vecLim, vecU);
		}
		virtual vector<double> qe(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			return qe(vecX, vecY, vecLim);
		}
		virtual vector<double> qi(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			return qi(vecX, vecY, vecLim);
		}

	public:
		// jacobian stamps of core functions
		// ddX functions
		virtual spMatrix dfe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dfe_dvecX_stamp(vecX, vecY, vecLim, vecU) + prod(dfe_dvecLim_stamp(vecX, vecY, vecLim, vecU), vecXtoLimitedVarsMatrix_stamp());
			return to_stamp( Jout );
		}
		virtual spMatrix dfi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dfi_dvecX_stamp(vecX, vecY, vecLim, vecU) + prod(dfi_dvecLim_stamp(vecX, vecY, vecLim, vecU), vecXtoLimitedVarsMatrix_stamp());
			return to_stamp( Jout );
		}
		virtual spMatrix dqe_dvecX_stamp(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dqe_dvecX_stamp(vecX, vecY, vecLim) + prod(dqe_dvecLim_stamp(vecX, vecY, vecLim), vecXtoLimitedVarsMatrix_stamp());
			return to_stamp( Jout );
		}
		virtual spMatrix dqi_dvecX_stamp(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dqi_dvecX_stamp(vecX, vecY, vecLim) + prod(dqi_dvecLim_stamp(vecX, vecY, vecLim), vecXtoLimitedVarsMatrix_stamp());
			return to_stamp( Jout );
		}

		// ddY functions
		virtual spMatrix dfe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dfe_dvecY_stamp(vecX, vecY, vecLim, vecU) + prod(dfe_dvecLim_stamp(vecX, vecY, vecLim, vecU), vecYtoLimitedVarsMatrix_stamp());
			return to_stamp( Jout );
		}
		virtual spMatrix dfi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dfi_dvecY_stamp(vecX, vecY, vecLim, vecU) + prod(dfi_dvecLim_stamp(vecX, vecY, vecLim, vecU), vecYtoLimitedVarsMatrix_stamp());
			return to_stamp( Jout );
		}
		virtual spMatrix dqe_dvecY_stamp(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dqe_dvecY_stamp(vecX, vecY, vecLim) + prod(dqe_dvecLim_stamp(vecX, vecY, vecLim), vecYtoLimitedVarsMatrix_stamp());
			return to_stamp( Jout );
		}
		virtual spMatrix dqi_dvecY_stamp(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dqi_dvecY_stamp(vecX, vecY, vecLim) + prod(dqi_dvecLim_stamp(vecX, vecY, vecLim), vecYtoLimitedVarsMatrix_stamp());
			return to_stamp( Jout );
		}
		
		// ddU functions
		virtual spMatrix dfe_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			return dfe_dvecU_stamp(vecX, vecY, vecLim, vecU);
		}
		virtual spMatrix dfi_dvecU_stamp(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			return dfi_dvecU_stamp(vecX, vecY, vecLim, vecU);
		}
		
		// derivatives of core functions
		// ddX functions
		virtual spMatrix dfe_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dfe_dvecX(vecX, vecY, vecLim, vecU) + prod(dfe_dvecLim(vecX, vecY, vecLim, vecU),  vecXtoLimitedVarsMatrix());
			return Jout;
		}
		virtual spMatrix dfi_dvecX(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dfi_dvecX(vecX, vecY, vecLim, vecU) + prod(dfi_dvecLim(vecX, vecY, vecLim, vecU),  vecXtoLimitedVarsMatrix());
			return Jout;
		}
		virtual spMatrix dqe_dvecX(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dqe_dvecX(vecX, vecY, vecLim) + prod(dqe_dvecLim(vecX, vecY, vecLim),  vecXtoLimitedVarsMatrix());
			return Jout;
		}
		virtual spMatrix dqi_dvecX(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dqi_dvecX(vecX, vecY, vecLim) + prod(dqi_dvecLim(vecX, vecY, vecLim),  vecXtoLimitedVarsMatrix());
			return Jout;
		}

		// ddY functions
		virtual spMatrix dfe_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dfe_dvecY(vecX, vecY, vecLim, vecU) + prod(dfe_dvecLim(vecX, vecY, vecLim, vecU),  vecYtoLimitedVarsMatrix());
			return Jout;
		}
		virtual spMatrix dfi_dvecY(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dfi_dvecY(vecX, vecY, vecLim, vecU) + prod(dfi_dvecLim(vecX, vecY, vecLim, vecU),  vecYtoLimitedVarsMatrix());
			return Jout;
		}
		virtual spMatrix dqe_dvecY(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dqe_dvecY(vecX, vecY, vecLim) + prod(dqe_dvecLim(vecX, vecY, vecLim),  vecYtoLimitedVarsMatrix());
			return Jout;
		}
		virtual spMatrix dqi_dvecY(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			spMatrix Jout = dqi_dvecY(vecX, vecY, vecLim) + prod(dqi_dvecLim(vecX, vecY, vecLim),  vecYtoLimitedVarsMatrix());
			return Jout;
		}
		
		// ddU functions
		virtual spMatrix dfe_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			return dfe_dvecU(vecX, vecY, vecLim, vecU);
		}
		virtual spMatrix dfi_dvecU(vector<double>& vecX, vector<double>& vecY, vector<double>& vecU) {
			vector<double> vecLim = add(prod(vecXtoLimitedVarsMatrix(), vecX), prod(vecYtoLimitedVarsMatrix(), vecY));
			return dfi_dvecU(vecX, vecY, vecLim, vecU);
		}


	public:
		// init/limiting flag, default is false
		virtual bool support_initlimiting() {
			return true;
		};

	public:
		// extra function fields related to init/limiting, default is no limited variables.
		virtual vector<string> LimitedVarNames() {
			return limited_var_names;
		}

		virtual spMatrix vecXYtoLimitedVarsMatrix_stamp() {
			return to_stamp( vecXY_to_limited_vars_matrix );
		}
		virtual spMatrix vecXYtoLimitedVarsMatrix() {
			return vecXY_to_limited_vars_matrix;
		}

		// this function is redundant, but quite useful
		virtual vector<double> vecXYtoLimitedVars(vector<double>& vecX, vector<double>& vecY) {
			vector<double> vecXY = vecX; 
			vecXY.insert(vecXY.end(), vecY.begin(), vecY.end()); // vecXY = [vecX; vecY];
			spMatrix vecXY_to_limited_vars_matrix = vecXYtoLimitedVarsMatrix();
			return prod(vecXY_to_limited_vars_matrix, vecXY); 
		}

		// TODO: not the way to do it
		virtual spMatrix vecXtoLimitedVarsMatrix_stamp() {
			double nvecX = OtherIONames().size();
			double nvecLim = LimitedVarNames().size();
			return to_stamp( subslice(vecXY_to_limited_vars_matrix, 0, 1, nvecLim, 0, 1, nvecX) );
		}
		virtual spMatrix vecXtoLimitedVarsMatrix() {
			double nvecX = OtherIONames().size();
			double nvecLim = LimitedVarNames().size();
			return subslice(vecXY_to_limited_vars_matrix, 0, 1, nvecLim, 0, 1, nvecX);
		}
		virtual spMatrix vecYtoLimitedVarsMatrix_stamp() {
			double nvecX = OtherIONames().size();
			double nvecY = InternalUnkNames().size();
			double nvecLim = LimitedVarNames().size();
			return to_stamp( subslice(vecXY_to_limited_vars_matrix, 0, 1, nvecLim, nvecX, 1, nvecY) );
		}
		virtual spMatrix vecYtoLimitedVarsMatrix() {
			double nvecX = OtherIONames().size();
			double nvecY = InternalUnkNames().size();
			double nvecLim = LimitedVarNames().size();
			return subslice(vecXY_to_limited_vars_matrix, 0, 1, nvecLim, nvecX, 1, nvecY);
		}

	public:
		virtual vector<double> initGuess(vector<double>& vecU) {
			double nvecLim = LimitedVarNames().size();
			vector<double> init_guess(nvecLim);
			return init_guess;
		}

		virtual vector<double> limiting(vector<double>& vecX, vector<double>& vecY, vector<double>& vecLimOld, vector<double>& vecU) {
			return vecXYtoLimitedVars(vecX, vecY);
		}

	protected:
		spMatrix to_stamp(const spMatrix& A) {
			// find the locations of the non-zeros of A and make them 1
			spMatrix tmp(A.size1(), A.size2());
			for (row_iterator_const it1 = A.begin1(); it1 != A.end1(); it1++) {
			  for (col_iterator_const it2 = it1.begin(); it2 != it1.end(); it2++) {
				tmp(it2.index1(),it2.index2()) = 1; // *it2;
			  }
			}
			return tmp;
		}
};

#endif // EE_MODEL_INITLIMITING
