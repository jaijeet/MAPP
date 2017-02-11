#include "smoothingfuncs.h"
template <typename T> T safeexp(T x, double maxslope) {
	// function out = safeexp(x,maxslope)
	//    hacked exponential: becomes a line after slope hits maxslope
	//       (useful for controlling numerical overflow in N-R)
	// 
	// author: J. Roychowdhury, 10/2008. Translated to C++: 2012/08/11.
	// 
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	double breakpoint = log(maxslope);
	return exp(x*(x <= breakpoint))*(x <= breakpoint) + (x>breakpoint)*(maxslope + maxslope*(x-breakpoint));
	// ensures exp(large) is not computed at all
}

double safeexp(double x, double maxslope) {
	return safeexp<double>(x, maxslope);
}
LFADsp safeexp(LFADsp x, double maxslope) {
	return safeexp<LFADsp>(x, maxslope);
}
DFAD safeexp(DFAD x, double maxslope) {
	return safeexp<DFAD>(x, maxslope);
}
