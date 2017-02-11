#ifndef MNA_DAE_H
#define MNA_DAE_H

#include "DAEAPI.h"
#include "ublas_matrix_std_vector_ops.h" // defines prod(), add(), subtract() for vector<double>

#include "cktnetlist.h" // This class is specific to EE circuits
#include "eeNIL.h"

class MNA_DAE : public DAEAPI {
	public: 
		MNA_DAE(cktnetlist * incktPtr);
		virtual ~MNA_DAE();

	protected: // TODO: private? What can possibly inherit from MNA_DAE?
		string dae_name;
		string uniq_ID;
		string dae_version;

		vector<string> parm_names;
		vector<untyped> parm_defaultvals;

		vector<string> unk_names;
		vector<string> eqn_names;
		vector<string> input_names;
		vector<string> output_names;
		vector<string> NoiseSource_names;

		spMatrix Cmat;
		spMatrix Dmat;

	protected:
		vector<string> limited_var_names;
		spMatrix x_to_xlim_matrix;

	protected:
	class MNA_elementdata {
		public: 
			MNA_elementdata(){};
			// MNA_elementdata(vector<untyped>& parms) : parms(parms) {};
			MNA_elementdata(spMatrix& A_X, 
							spMatrix& A_Y,
							spMatrix& A_Lim,
							spMatrix& A_U,
							spMatrix& A_Z,
							spMatrix& A_W)
							 :	A_X (A_X), 
								A_Y (A_Y),
								A_Lim (A_Lim),
								A_U (A_U),
								A_Z (A_Z),
								A_W (A_W) {};
			~MNA_elementdata(){};
		public: 
			// vector<untyped> parms;
			spMatrix A_X;
			spMatrix A_Y;
			spMatrix A_Lim;
			spMatrix A_U;
			spMatrix A_Z;
			spMatrix A_W;
			// such that: 
			//		vecX = A_X * x;
			//		vecY = A_Y * x;
			//		vecLim = A_Lim * xlim;
			//		vecU = A_U * u;
			//		f/q += A_Z * vecZ;
			//		f/q += A_W * vecW;
	};

	protected:
		vector<MNA_elementdata * > MNA_circuitdata;
		spMatrix A_fx; // such that: f += A_fx * x;
		cktnetlist * cktnetlistPtr;

		vector<string> element_names;
		string separatorString;

	protected:
		virtual vector<double> fq(vector<double>& x, vector<double>& xlim, vector<double>& u, char fORq);
		virtual spMatrix dfq(vector<double>& x, vector<double>& xlim, vector<double>& u, char fORq, char xlORu);

		virtual vector<double> init_limiting(vector<double>& x, vector<double>& xlimOld, vector<double>& u, char iORl);
		virtual spMatrix dlimiting(vector<double>& x, vector<double>& xlimOld, vector<double>& u, char xORu);

	public:
		virtual void print();

	public:
		virtual string daename();
		virtual string uniqID();
		virtual string version();
		virtual int nparms();
		virtual vector<string> parmnames();
		virtual vector<untyped> parmdefaults();
		virtual vector<untyped> getparms();
		virtual untyped getparm(string& parm);
		virtual void setparms(vector<untyped>& a);
		virtual void setparm(string& parm, untyped& val);
		virtual int nunks();
		virtual int neqns();
		virtual int ninputs();
		virtual int noutputs();
		virtual int nNoiseSources();
		virtual vector<string> unknames();
		virtual vector<string> eqnnames();
		virtual vector<string> inputnames();
		virtual vector<string> outputnames();
		virtual vector<string> NoiseSourcenames();
		virtual spMatrix C();
		virtual spMatrix D();

	public:
		virtual bool support_initlimiting();
		virtual vector<string> limitedvarnames();
		virtual int nlimitedvars();
		virtual spMatrix xTOxlimMatrix();

	public:
		virtual vector<double> f(vector<double>& x, vector<double>& xlim, vector<double>& u);
		virtual vector<double> q(vector<double>& x, vector<double>& xlim);
		virtual spMatrix df_dx(vector<double>& x, vector<double>& xlim, vector<double>& u);
		virtual spMatrix df_dxlim(vector<double>& x, vector<double>& xlim, vector<double>& u);
		virtual spMatrix df_du(vector<double>& x, vector<double>& xlim, vector<double>& u);
		virtual spMatrix dq_dx(vector<double>& x, vector<double>& xlim);
		virtual spMatrix dq_dxlim(vector<double>& x, vector<double>& xlim);

	public:
		virtual vector<double> NRinitGuess(vector<double>& u);
		virtual vector<double> NRlimiting(vector<double>& x, vector<double>& xlimOld, vector<double>& u);
		virtual spMatrix dNRlimiting_dx(vector<double>& x, vector<double>& xlimOld, vector<double>& u);
		virtual spMatrix dNRlimiting_du(vector<double>& x, vector<double>& xlimOld, vector<double>& u);

	public:
		virtual vector<double> f(vector<double>& x, vector<double>& u);
		virtual vector<double> q(vector<double>& x);
		virtual spMatrix df_dx(vector<double>& x, vector<double>& u);
		virtual spMatrix df_du(vector<double>& x, vector<double>& u);
		virtual spMatrix dq_dx(vector<double>& x);

	protected:
		// internal functions
		int findstring(string& str, vector<string>& strarray);
		void vecstrcat(string& str, vector<string>& strarray);
		void vecstrcat(vector<string>& strarray, string& str);
};
#endif
