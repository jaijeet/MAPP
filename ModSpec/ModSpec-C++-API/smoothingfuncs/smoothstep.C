#include "smoothingfuncs.h"
template <typename T> T smoothstep(T x, double smoothing) {
	// function out = smoothstep(x,smoothing)
	//  	step(x) = d/dx clip(x)
	//  	example: out = smoothstep(-0.5:0.01:0.5,0.1)
	// 
	// author: J. Roychowdhury, 10/2008. Translated to C++: 2012/08/11.
	// 
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	return dsmoothclip(x,smoothing);
}


double smoothstep(double x, double smoothing) {
	return smoothstep<double>(x, smoothing);
}

LFADsp smoothstep(LFADsp x, double smoothing) {
	return smoothstep<LFADsp>(x, smoothing);
}

DFAD smoothstep(DFAD x, double smoothing) {
	return smoothstep<DFAD>(x, smoothing);
}
