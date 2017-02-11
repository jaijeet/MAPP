#include "Xyce_ModSpec_Interface.h"
// #include "boost_ublas_typedefs.h"

// using namespace boost::numeric::ublas;

#define UBLAS boost::numeric::ublas

main() {

spMatrix A;
vector<double> b;
vector<double> c;

c = prod(A, b);
A = prod(A, A);

b = b + c;

// std::vector<double> d = c;
// axpy_prod(A, b, c);

/*
      vector<double> x(2);
      x(0) = 1; x(1) = 2;
 
      matrix<double> A(2,2);
      A(0,0) = 0; A(0,1) = 1;
      A(1,0) = 2; A(1,1) = 3;
 
      vector<double> y = prod(A, x);
 
      std::cout << y << std::endl;
      return 0;
*/
}
