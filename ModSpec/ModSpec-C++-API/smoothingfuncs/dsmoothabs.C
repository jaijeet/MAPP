#include "smoothingfuncs.h"
template <typename T> T dsmoothabs(T x, double smoothing) {
	// function out = dsmoothabs(x,smoothing)
	//  d/dx smoothabs(x,smoothing)
	// 
	// author: J. Roychowdhury, 10/2008.
	// 
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	// OLD: out = smoothing*log( exp(x/smoothing) + exp(-x/smoothing) );
	// OLD: dout = 1.0 ./( exp(x/smoothing) + exp(-x/smoothing) ) .* ...
	// OLD: 	(exp(x/smoothing) - exp(-x/smoothing));
	// out = sqrt(x.*x + smoothing);
	return x/sqrt(x*x + smoothing); //  = x./smoothabs(x,smoothing);
}


double dsmoothabs(double x, double smoothing) {
	return dsmoothabs<double>(x, smoothing);
}

LFADsp dsmoothabs(LFADsp x, double smoothing) {
	return dsmoothabs<LFADsp>(x, smoothing);
}

DFAD dsmoothabs(DFAD x, double smoothing) {
	return dsmoothabs<DFAD>(x, smoothing);
}
