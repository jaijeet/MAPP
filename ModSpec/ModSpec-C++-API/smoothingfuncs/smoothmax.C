#include "smoothingfuncs.h"
template <typename Tout, typename T1, typename T2> Tout smoothmax(T1 a, T2 b, double smoothing) {
	// function out = smoothmax(a, b, smoothing)
	//   max(a, b) = 0.5*(a + b + abs(a-b))
	//   // both a and b can be vectors
	//   //   a will be reshaped into a col vector, b into a row vector
	//   //   out = smoothmax( a*row_of_1s, col_of_1s*b ) % outer product matrix
	// 
	// author: J. Roychowdhury, 10/2008. Translated to C++: 2012/08/11.
	// 
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	// la = length(a);
	// a = reshape(a, [], 1)*ones(1, length(b)); % col vector * row_of_1s
	// b = ones(la,1)*reshape(b, 1, []); % col of 1s * row vector
	
	Tout out;
	out = 0.5*(a + b + smoothabs(a-b,smoothing));
	return out;
}

double smoothmax(double a, double b, double smoothing) {
	return smoothmax<double,double,double>(a, b, smoothing);
}

LFADsp smoothmax(LFADsp a, LFADsp b, double smoothing) {
	return smoothmax<LFADsp,LFADsp,LFADsp>(a, b, smoothing);
}

LFADsp smoothmax(LFADsp a, double b, double smoothing) {
	return smoothmax<LFADsp,LFADsp,double>(a, b, smoothing);
}

LFADsp smoothmax(double a, LFADsp b, double smoothing) {
	return smoothmax<LFADsp,double,LFADsp>(a, b, smoothing);
}

DFAD smoothmax(DFAD a, DFAD b, double smoothing) {
	return smoothmax<DFAD,DFAD,DFAD>(a, b, smoothing);
}

DFAD smoothmax(DFAD a, double b, double smoothing) {
	return smoothmax<DFAD,DFAD,double>(a, b, smoothing);
}

DFAD smoothmax(double a, DFAD b, double smoothing) {
	return smoothmax<DFAD,double,DFAD>(a, b, smoothing);
}
