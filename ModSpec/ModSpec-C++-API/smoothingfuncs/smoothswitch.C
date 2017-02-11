#include "smoothingfuncs.h"
template <typename Tout, typename T1, typename T2, typename T3> Tout smoothswitch(T1 a, T2 b, T3 x, double smoothing) {
	// function out = smoothswitch(a,b,x,smoothing)
	//  	smoothly switch between a (x<0) and b (x>0)
	//  	// example: out = smoothswitch(-5,3,-0.5:0.01:0.5,0.1)
	// 
	// CAVEAT EMPTOR: MAKE SURE you check monotonicity and slope properties wrt x 
	// 		if a or b is a function of x
	// 
	// 
	// author: J. Roychowdhury, 10/2008. Translated to C++: 2012/08/11.
	// 
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//  Author: J. Roychowdhury.
	//  Copyright (C) 2011-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Tout oof = smoothstep(x,smoothing);
	return a*(1-oof) + b*oof;
}

double smoothswitch(double a, double b, double x, double smoothing) {
	return smoothswitch<double,double,double,double>(a, b, x, smoothing);
}
LFADsp smoothswitch(LFADsp a, LFADsp b, LFADsp x, double smoothing) {
	return smoothswitch<LFADsp,LFADsp,LFADsp,LFADsp>(a, b, x, smoothing);
}
LFADsp smoothswitch(double a, LFADsp b, LFADsp x, double smoothing) {
	return smoothswitch<LFADsp,double,LFADsp,LFADsp>(a, b, x, smoothing);
}
LFADsp smoothswitch(LFADsp a, double b, LFADsp x, double smoothing) {
	return smoothswitch<LFADsp,LFADsp,double,LFADsp>(a, b, x, smoothing);
}
LFADsp smoothswitch(LFADsp a, LFADsp b, double x, double smoothing) {
	return smoothswitch<LFADsp,LFADsp,LFADsp,double>(a, b, x, smoothing);
}
LFADsp smoothswitch(LFADsp a, double b, double x, double smoothing) {
	return smoothswitch<LFADsp,LFADsp,double,double>(a, b, x, smoothing);
}
LFADsp smoothswitch(double a, LFADsp b, double x, double smoothing) {
	return smoothswitch<LFADsp,double,LFADsp,double>(a, b, x, smoothing);
}
LFADsp smoothswitch(double a, double b, LFADsp x, double smoothing) {
	return smoothswitch<LFADsp,double,double,LFADsp>(a, b, x, smoothing);
}
DFAD smoothswitch(DFAD a, DFAD b, DFAD x, double smoothing) {
	return smoothswitch<DFAD,DFAD,DFAD,DFAD>(a, b, x, smoothing);
}
DFAD smoothswitch(double a, DFAD b, DFAD x, double smoothing) {
	return smoothswitch<DFAD,double,DFAD,DFAD>(a, b, x, smoothing);
}
DFAD smoothswitch(DFAD a, double b, DFAD x, double smoothing) {
	return smoothswitch<DFAD,DFAD,double,DFAD>(a, b, x, smoothing);
}
DFAD smoothswitch(DFAD a, DFAD b, double x, double smoothing) {
	return smoothswitch<DFAD,DFAD,DFAD,double>(a, b, x, smoothing);
}
DFAD smoothswitch(DFAD a, double b, double x, double smoothing) {
	return smoothswitch<DFAD,DFAD,double,double>(a, b, x, smoothing);
}
DFAD smoothswitch(double a, DFAD b, double x, double smoothing) {
	return smoothswitch<DFAD,double,DFAD,double>(a, b, x, smoothing);
}
DFAD smoothswitch(double a, double b, DFAD x, double smoothing) {
	return smoothswitch<DFAD,double,double,DFAD>(a, b, x, smoothing);
}
