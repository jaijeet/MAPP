#include "smoothingfuncs.h"
template <typename T> T smoothsign(T x, double smoothing) {
	// function out = smoothsign(x,smoothing)
	//  sign(x) = 2*step(x) - 1;
	// 
	// author: J. Roychowdhury, 10/2008. Translated to C++: 2012/08/11.
	// 
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	return 2*smoothstep(x,smoothing)-1;
}

double smoothsign(double x, double smoothing) {
	return smoothsign<double>(x, smoothing);
}

LFADsp smoothsign(LFADsp x, double smoothing) {
	return smoothsign<LFADsp>(x, smoothing);
}

DFAD smoothsign(DFAD x, double smoothing) {
	return smoothsign<DFAD>(x, smoothing);
}
