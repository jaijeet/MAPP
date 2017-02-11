#include "ublas_matrix_std_vector_ops.h"

main() {
	spMatrix A(3,4);
	vector<double> b(4);

	A(0,0) = 1;
	A(1,1) = 1;
	A(2,2) = 1;
	A(0,3) = 1;

	b[0] = 1;
	b[1] = 2;
	b[2] = 3;
	b[3] = 4;

	vector<double> d = prod(A, b);

	cout << "A=" << A << endl;
	fprintf(stdout, "b="); print_vector_of_doubles(b);
	fprintf(stdout, "prod(A,b)="); print_vector_of_doubles(d);

	d = add(b,b);
	fprintf(stdout, "\nplus(b,b)="); print_vector_of_doubles(d);

	d = subtract(b,b);
	fprintf(stdout, "\nminus(b,b)="); print_vector_of_doubles(d);
}
