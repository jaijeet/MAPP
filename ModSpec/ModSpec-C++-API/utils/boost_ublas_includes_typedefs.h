#ifndef BOOST_UBLAS_INCLUDES_TYPEDEFS_H
#define BOOST_UBLAS_INCLUDES_TYPEDEFS_H

#include <math.h>	
#include <cstdio>		// nicer than streams in some respects
#include <stdlib.h>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/vector.hpp>
#include <boost/numeric/ublas/matrix_sparse.hpp>
#include <boost/numeric/ublas/matrix_proxy.hpp> // needed for project()
#include <boost/numeric/ublas/io.hpp>
#include <boost/numeric/ublas/storage.hpp>
// #include <vector>
// #include <boost/numeric/ublas/operation.hpp>

typedef boost::numeric::ublas::mapped_matrix<double> spMatrix;
typedef boost::numeric::ublas::mapped_vector<double> spVector;
typedef boost::numeric::ublas::mapped_matrix<double*> spMatrix_doubleptr;
typedef spMatrix::const_iterator1 row_iterator_const;
typedef spMatrix::const_iterator2 col_iterator_const;
typedef spMatrix::iterator1 row_iterator_mutable;
typedef spMatrix::iterator2 col_iterator_mutable;

#endif // BOOST_UBLAS_INCLUDES_TYPEDEFS_H
