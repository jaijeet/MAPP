#include "smoothingfuncs.h"
template <typename T> T smoothclip(T x, double smoothing) {
	// function out = smoothclip(x,smoothing)
	//    clip(x) = (abs(x) + x)/2
	// 
	// author: J. Roychowdhury, 10/2008. Translated to C++: 2012/08/11.
	// 
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	return 0.5*(smoothabs(x,smoothing) + x);
}

double smoothclip(double x, double smoothing) {
	return smoothclip<double>(x, smoothing);
}

LFADsp smoothclip(LFADsp x, double smoothing) {
	return smoothclip<LFADsp>(x, smoothing);
}

DFAD smoothclip(DFAD x, double smoothing) {
	return smoothclip<DFAD>(x, smoothing);
}
