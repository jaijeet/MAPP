#include "ublas_matrix_std_vector_ops.h"
vector<double> prod(const spMatrix& A, const vector<double>& b) {
	int n_rows = A.size1();
	int n_cols = A.size2();
	if (b.size() != n_cols) {
		// cout << "b.size(): " << b.size() << endl;
		// cout << "n_cols: " << n_cols << endl;
		fprintf(stderr, "ERROR in prod(spMatrix& A, vector<double>& b): A.size2() != b.size()\n");
		exit(1);
	}
	vector<double> out(n_rows);
	for (row_iterator_const it1 = A.begin1(); it1 != A.end1(); it1++) {
	  out[it1.index1()] = 0;
	  for (col_iterator_const it2 = it1.begin(); it2 != it1.end(); it2++)
	    {
	  	out[it1.index1()] += (*it2) * b[it2.index2()];
		// std::cout << "(" << it2.index1() << "," << it2.index2() << ") = ";
		// std::cout << *it2 << std::endl;
	    }
	}
	return out;
}

vector<double> add(const vector<double>& a, const vector<double>& b) {
	if (a.size() != b.size()) {
		fprintf(stderr, "ERROR in plus(vector<double>& a, vector<double>& b): a.size() != b.size()\n");
		exit(1);
	}
	vector<double> out(a.size());
	for (int i=0; i<a.size(); i++) {
		out[i] = a[i]+b[i];
	}
	return out;
}

vector<double> subtract(const vector<double>& a, const vector<double>& b) {
	if (a.size() != b.size()) {
		fprintf(stderr, "ERROR in minus(vector<double>& a, vector<double>& b): a.size() != b.size()\n");
		exit(1);
	}
	vector<double> out(a.size());
	for (int i=0; i<a.size(); i++) {
		out[i] = a[i]-b[i];
	}
	return out;
}

spMatrix resize(const spMatrix& A, int size1, int size2) {
// work around for a boost::ublas::resize "bug".
// some descriptions of the ublas::mapped_matrix::resize bug
// http://comments.gmane.org/gmane.comp.lib.boost.devel/78084
// http://boost.2283326.n4.nabble.com/compressed-vector-resize-is-not-fully-implemented-does-not-preserve-data-td2709093.html
	spMatrix B(size1, size2);
	int n_rows = A.size1();
	int n_cols = A.size2();
	for (row_iterator_const it1 = A.begin1(); it1 != A.end1(); it1++) {
	  for (col_iterator_const it2 = it1.begin(); it2 != it1.end(); it2++)
	  	B(it1.index1(), it2.index2()) = (*it2);
	}
	return B;
}

