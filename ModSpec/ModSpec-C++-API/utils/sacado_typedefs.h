#ifndef SACADO_TYPEDEFS_H
#define SACADO_TYPEDEFS_H

#include <math.h>	
#include <Sacado.hpp>
#include <cstdio>		// nicer than streams in some respects
#include <stdlib.h>
#include <vector> // std::vector

typedef Sacado::Fad::DFad<double>   DFAD;  // FAD with # of ind. vars given later
typedef Sacado::LFad::LogicalSparse<double,bool> LFADsp;
typedef vector<DFAD> DFADvec;
typedef vector<LFADsp> LFADvec;

#endif // SACADO_TYPEDEFS_H
