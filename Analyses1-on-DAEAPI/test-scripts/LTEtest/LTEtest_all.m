%Changelog:
%---------
%2014/02/07: Jian Yao <jianyao@berkeley.edu>: demo for MAPP meeting 2014/02/06 
%

close all;
clc;
clear;

%parameter: initial time-step

%test1   
%LTEtest_RCline_transient(5e-5);                  %TRAP and BE
%LTEtest_RCline_transient(5e-3);

%test2
LTEtest_UltraSimplePLL_transient(1e-9/40);        	 %BE

%test3
%LTEtest_MNAEqnEngine_vsrcRC_DC_AC_tran(10e-4);   	 %TRAP
%LTEtest_MNAEqnEngine_vsrcRC_DC_AC_tran(10e-5); 

%test4
%LTEtest_SHdiffpair_ckt_DCop_AC_transient(1e-5); 	 %GEAR2
%LTEtest_SHdiffpair_ckt_DCop_AC_transient(1e-3); 

%test5
%LTEtest_inverter_transient(10e-4); 		  	 %GEAR2 and BE
%LTEtest_inverter_transient(1e-4); 
