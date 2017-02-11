#include "smoothingfuncs.h"
template <typename T> T safelog(T x, double smoothing) {
	// function out = safelog(x,smoothing)
	//    safelog(x,smoothing) = log(smoothclip(x,smoothing))
	// 
	// author: J. Roychowdhury, 10/2008. Translated to C++: 2012/08/11
	// 
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	return log(smoothclip(x,smoothing) + 1e-16);
}

double safelog(double x, double smoothing) {
	return safelog<double>(x, smoothing);
}
LFADsp safelog(LFADsp x, double smoothing) {
	return safelog<LFADsp>(x, smoothing);
}
DFAD safelog(DFAD x, double smoothing) {
	return safelog<DFAD>(x, smoothing);
}
