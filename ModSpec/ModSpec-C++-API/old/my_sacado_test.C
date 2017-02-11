#include <math.h>	
#include <Sacado.hpp>
#include <cstdio>		// nicer than streams in some respects
#include <stdlib.h>
#include <vector>
#include <boost/numeric/ublas/matrix_sparse.hpp>
#include <boost/numeric/ublas/io.hpp>

using std::printf;
using namespace std;

// typedef Sacado::Fad::DFad<double>   gdouble;  // FAD with # of ind. vars given later

typedef Sacado::Fad::DFad<double>   DFAD;  // FAD with # of ind. vars given later
typedef Sacado::LFad::LogicalSparse<double,bool> LFADsp;
typedef vector<DFAD> DFADvec;
typedef vector<LFADsp> LFADvec;

template <typename vecT>
  vecT myfunc(vecT& vecX) {
	vecT vecY;
	vecY.resize(2);

	vecY[0] = vecX[0]*vecX[2] + sin(pow(vecX[2],3));
	vecY[1] = cos(vecX[1]) + exp(1e-4*vecY[0]);
	return vecY;
}

main() {
	DFAD a, b, c; // independent variables
	DFAD d, e;

	a = 1; a.diff(0,3); // 0,3 => 1st indep var (of 3)
	b = 2; b.diff(1,3); // 1,3 => 2ndt indep var (of 3)
	c = 3; c.diff(2,3); 

	d = a*c + sin(c*c*c);
	e = cos(b) + exp(1e-4*d);

	fprintf(stdout, "d.val=%g, e.val=%g\n", d.val(), d.val());
	fprintf(stdout, "dd_da=%g, dd_db=%g, dd_dc=%g\n", d.dx(0), d.dx(1), d.dx(2));
	fprintf(stdout, "de_da=%g, de_db=%g, de_dc=%g\n", e.dx(0), e.dx(1), e.dx(2));

	DFADvec vecX, vecY;
	vecX.resize(3);

	vecX[0] = 1; vecX[0].diff(0,3); // a
	vecX[1] = 2; vecX[1].diff(1,3); // b
	vecX[2] = 3; vecX[2].diff(2,3); // c

	// vecY = myfunc<DFADvec>(vecX);
	vecY = myfunc(vecX); // oddly, this also works!


	fprintf(stdout, "vecY.vals=[%g; %g]\n", vecY[0].val(), vecY[1].val());
	fprintf(stdout, "vecY[0].derivs=[%g;%g;%g]\n", vecY[0].dx(0), 
					vecY[0].dx(1), vecY[0].dx(2));
	fprintf(stdout, "vecY[1].derivs=[%g;%g;%g]\n", vecY[1].dx(0), 
					vecY[1].dx(1), vecY[1].dx(2));

	using namespace boost::numeric::ublas;
    	mapped_matrix<double> jac(2, 3);
    	//mapped_matrix<double> jac(2, 3, 2 * 3);
    		for (unsigned i = 0; i < jac.size1(); ++i) 
        		for (unsigned j = 0; j < jac.size2(); ++j)
            			jac(i, j) = vecY[i].dx(j);
    	std::cout << jac << endl;

	LFADvec vecX2, vecY2;
	vecX2.resize(3);

	vecX2[0] = 1; vecX2[0].diff(0,3); // a
	vecX2[1] = 2; vecX2[1].diff(1,3); // b
	vecX2[2] = 3; vecX2[2].diff(2,3); // c

	vecY2 = myfunc(vecX2);
	fprintf(stdout, "vecY2.vals=[%g; %g]\n", vecY2[0].val(), vecY2[1].val());
	fprintf(stdout, "vecY2[0].derivs=[%d;%d;%d]\n", vecY2[0].dx(0), 
					vecY2[0].dx(1), vecY2[0].dx(2));
	fprintf(stdout, "vecY2[1].derivs=[%d;%d;%d]\n", vecY2[1].dx(0), 
					vecY2[1].dx(1), vecY2[1].dx(2));
}
