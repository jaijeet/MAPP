#include "smoothingfuncs.h"
template <typename T> T safesqrt(T x, double smoothing) {
	// function out = safesqrt(x,smoothing)
	//    safesqrt(x,smoothing) = sqrt(smoothclip(x,smoothing))
	// 
	// author: J. Roychowdhury, 10/2008. Translated to C++: 2012/08/11.
	//  
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	return sqrt(smoothclip(x,smoothing) + 1e-16);
}

double safesqrt(double x, double smoothing) {
	return safesqrt<double>(x, smoothing);
}

LFADsp safesqrt(LFADsp x, double smoothing) {
	return safesqrt<LFADsp>(x, smoothing);
}

DFAD safesqrt(DFAD x, double smoothing) {
	return safesqrt<DFAD>(x, smoothing);
}
