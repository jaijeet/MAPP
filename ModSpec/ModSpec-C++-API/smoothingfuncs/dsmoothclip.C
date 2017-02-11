#include "smoothingfuncs.h"
template <typename T> T dsmoothclip(T x, double smoothing) {
	// function out = dsmoothclip(x,smoothing)
	//    d/dx smoothclip(x,smoothing)
	// 
	// author: J. Roychowdhury, 10/2008. Translated to C++: 2012/08/11.
	// 
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	return 0.5*(dsmoothabs(x,smoothing) + 1);
}

double dsmoothclip(double x, double smoothing) {
	return dsmoothclip<double>(x, smoothing);
}

LFADsp dsmoothclip(LFADsp x, double smoothing) {
	return dsmoothclip<LFADsp>(x, smoothing);
}

DFAD dsmoothclip(DFAD x, double smoothing) {
	return dsmoothclip<DFAD>(x, smoothing);
}
