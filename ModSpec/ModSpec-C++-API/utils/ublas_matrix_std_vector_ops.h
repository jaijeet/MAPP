#include <stdlib.h>
#include <vector> // std::vector
#include "boost_ublas_includes_typedefs.h" // spMatrix, iterators
#include "vector_print.h"

using namespace std;

vector<double> prod(const spMatrix& A, const vector<double>& b);
vector<double> add(const vector<double>& a, const vector<double>& b);
vector<double> subtract(const vector<double>& a, const vector<double>& b);

spMatrix resize(const spMatrix& A, int size1, int size2); // work around for a boost::ublas::resize "bug".
