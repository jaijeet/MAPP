#include <stdio.h>

void setup_mat_via_funcptr(double* (*func_ptr)(int, int)) {
	for (int i=0; i < 4; i++)
		for (int j=0; j < 4; j++)
			*((*func_ptr)(i,j)) = i*4+j;
}

namespace mynamespace {

	class _returnRawEntryPointer {
		public:
			static double** _matPtr;
			_returnRawEntryPointer(){};
			~_returnRawEntryPointer() {}
			static double* pointer_to(int i, int j) {return &(_matPtr[i][j]);}
	};

	double** _returnRawEntryPointer::_matPtr;

}

main() {

   int nr = 5, nc = 6;
   double** mat = new double*[nr];
   for (int i=0; i < nr; i++) mat[i] = new double[nc];


   // instantiate class instances for dFdxMatPtr and dQdxMatPtr
   mynamespace::_returnRawEntryPointer::_matPtr = mat;

   // set up a function pointer to its pointer_to() member function
   double* (*func_ptr)(int, int) = &mynamespace::_returnRawEntryPointer::pointer_to;

   // pass the above to another function that accesses the pointers 
   // and sets up the matrix

   setup_mat_via_funcptr(func_ptr);

   for (int i=0; i<nr; i++) {
	   for (int j=0; j<nc; j++) {
	   	fprintf(stdout, "%g \t", mat[i][j]);
	   }
	   fprintf(stdout, "\n");
   }
}
