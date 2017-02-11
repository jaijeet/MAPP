#include "smoothingfuncs.h"
template <typename T> T smoothabs(T x, double smoothing) {
	// function out = smoothabs(x,smoothing)
	//    smoothabs(x) = sqrt( x.*x + smoothing ) - smoothing is the offset from 0
	//    old: smoothabs(x) = smoothing*log( e^(x/smoothing) + e^(-x/smoothing) )
	//    old: out = smoothing*log( exp(x/smoothing) + exp(-x/smoothing) );
	// 
	// author: J. Roychowdhury, 10/2008. Translated to C++: 2012/08/11
	// 
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	return sqrt(x*x + smoothing);
}

double smoothabs(double x, double smoothing) {
	return smoothabs<double>(x, smoothing);
}

LFADsp smoothabs(LFADsp x, double smoothing) {
	return smoothabs<LFADsp>(x, smoothing);
}

DFAD smoothabs(DFAD x, double smoothing) {
	return smoothabs<DFAD>(x, smoothing);
}
