%% optimization script for output data set.
% written on July 08, 2013
% Author: Shaloo Rakheja, MIT
%% UNCOMMENT flag has been added to select appropriate experimental data sets.

function [coeff_op_out] = optimize_output(coeff_init)
clear Id_data
clear bias_data
clear Vy* Vg* Id_out

%% read data set
%% UNCOMMENT appropriate file from the following two lines
%IdVd=abs(dlmread('idvd_Intel_32_nFET_09.txt')); % first column is Vd, sec. col is Vg, third col. is Id
IdVd=abs(dlmread('idvd_Intel_45_nFET_12.txt')); % first column is Vd, sec. col is Vg, third col. is Id

Vy_data=IdVd(:,1);
Vg_data=IdVd(:,2);
Id_data = IdVd(:,end);
bias_data(:,1)=Vy_data;
bias_data(:,2)=Vg_data;
Vb=0;
bias_data(:,3)=Vb;
Vx=0;
bias_data(:,4)=Vx;

%% now we run optimization. Make a matrix of initial guess
options = optimset('Display','iter','TolFun',1e-11);
% Constraints            
lb=[1;1;0;1;0;0.1;50;0.2]; % lower bound constraints
ub=[500;500;0.5;2;0.5;10;1000;0.8]; % upper bound constraints
% Optimization routine 
[coeff_op_out,resnorm,residual,exitflag] = lsqcurvefit(@daa_mosfet,coeff_init,bias_data,log10(Id_data),lb,ub,options); 
end



