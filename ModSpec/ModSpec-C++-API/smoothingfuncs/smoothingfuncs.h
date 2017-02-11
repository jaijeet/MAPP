#ifndef SMOOTHINGFUNCS_H
#define SMOOTHINGFUNCS_H

#include <math.h>
using namespace std;
#include "sacado_typedefs.h" // includes <vector> for std::vector


// templatized internally, at the expense of more function calls

// template <typename T> T safeexp(T x, double maxslope);
double safeexp(double x, double maxslope);
LFADsp safeexp(LFADsp x, double maxslope);
DFAD safeexp(DFAD x, double maxslope);


// template <typename T> T safelog(T x, double smoothing);
double safelog(double x, double smoothing);
LFADsp safelog(LFADsp x, double smoothing);
DFAD safelog(DFAD x, double smoothing);

// template <typename T> T smoothclip(T x, double smoothing);
double smoothclip(double x, double smoothing);
LFADsp smoothclip(LFADsp x, double smoothing);
DFAD smoothclip(DFAD x, double smoothing);

// template <typename T> T smoothabs(T x, double smoothing);
double smoothabs(double x, double smoothing);
LFADsp smoothabs(LFADsp x, double smoothing);
DFAD smoothabs(DFAD x, double smoothing);

// template <typename T> T safesqrt(T x, double smoothing);
double safesqrt(double x, double smoothing);
LFADsp safesqrt(LFADsp x, double smoothing);
DFAD safesqrt(DFAD x, double smoothing);

// template <typename Tout, typename T1, typename T2> Tout smoothmax(T1 a, T2 b, double smoothing);
double smoothmax(double a, double b, double smoothing);
LFADsp smoothmax(LFADsp a, LFADsp b, double smoothing);
LFADsp smoothmax(LFADsp a, double b, double smoothing);
LFADsp smoothmax(double a, LFADsp b, double smoothing);
DFAD smoothmax(DFAD a, DFAD b, double smoothing);
DFAD smoothmax(DFAD a, double b, double smoothing);
DFAD smoothmax(double a, DFAD b, double smoothing);


// template <typename Tout, typename T1, typename T2> Tout smoothmin(T1 a, T2 b, double smoothing);
double smoothmin(double a, double b, double smoothing);
LFADsp smoothmin(LFADsp a, LFADsp b, double smoothing);
LFADsp smoothmin(LFADsp a, double b, double smoothing);
LFADsp smoothmin(double a, LFADsp b, double smoothing);
DFAD smoothmin(DFAD a, DFAD b, double smoothing);
DFAD smoothmin(DFAD a, double b, double smoothing);
DFAD smoothmin(double a, DFAD b, double smoothing);


// template <typename T> T smoothsign(T x, double smoothing);
double smoothsign(double x, double smoothing);
LFADsp smoothsign(LFADsp x, double smoothing);
DFAD smoothsign(DFAD x, double smoothing);

// template <typename T> T smoothstep(T x, double smoothing);
double smoothstep(double x, double smoothing);
LFADsp smoothstep(LFADsp x, double smoothing);
DFAD smoothstep(DFAD x, double smoothing);

// template <typename Tout, typename T1, typename T2, typename T3> Tout smoothswitch(T1 a, T2 b, T3 x, double smoothing) {
double smoothswitch(double a, double b, double x, double smoothing);
LFADsp smoothswitch(LFADsp a, LFADsp b, LFADsp x, double smoothing);
LFADsp smoothswitch(double a, LFADsp b, LFADsp x, double smoothing);
LFADsp smoothswitch(LFADsp a, double b, LFADsp x, double smoothing);
LFADsp smoothswitch(LFADsp a, LFADsp b, double x, double smoothing);
LFADsp smoothswitch(LFADsp a, double b, double x, double smoothing);
LFADsp smoothswitch(double a, LFADsp b, double x, double smoothing);
LFADsp smoothswitch(double a, double b, LFADsp x, double smoothing);
DFAD smoothswitch(DFAD a, DFAD b, DFAD x, double smoothing);
DFAD smoothswitch(double a, DFAD b, DFAD x, double smoothing);
DFAD smoothswitch(DFAD a, double b, DFAD x, double smoothing);
DFAD smoothswitch(DFAD a, DFAD b, double x, double smoothing);
DFAD smoothswitch(DFAD a, double b, double x, double smoothing);
DFAD smoothswitch(double a, DFAD b, double x, double smoothing);
DFAD smoothswitch(double a, double b, DFAD x, double smoothing);

// template <typename T> T dsmoothclip(T x, double smoothing);
double dsmoothclip(double x, double smoothing);
LFADsp dsmoothclip(LFADsp x, double smoothing);
DFAD dsmoothclip(DFAD x, double smoothing);

// template <typename T> T dsmoothabs(T x, double smoothing);
double dsmoothabs(double x, double smoothing);
LFADsp dsmoothabs(LFADsp x, double smoothing);
DFAD dsmoothabs(DFAD x, double smoothing);
#endif
