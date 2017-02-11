%% optimization script for transfer data set.
% written on July 08, 2013
% Author: Shaloo Rakheja, MIT
%% UNCOMMENT flag has been added to select appropriate experimental data sets.

function [coeff_op_tran] = optimize_transfer(coeff_init)
clear Id_data
clear bias_data
clear Vg* Vy* 

%% read data set
%% UNCOMMENT appropriate file from the following two lines
%IdVg = abs(dlmread('idvg_Intel_32_nFET_09.txt'));
IdVg = abs(dlmread('idvg_Intel_45_nFET_12.txt'));

Vgpre=IdVg(1:end,1);
IdVg_loVd=IdVg(1:end,2);
IdVg_hiVd=IdVg(1:end,3);
Vy_data=[0.05*ones(1,length(Vgpre))';1.0*ones(1,length(Vgpre))'];
Vg_data=[Vgpre;Vgpre];
Id_data(:,1)=[IdVg_loVd;IdVg_hiVd];
bias_data(:,1)=Vy_data;
bias_data(:,2)=Vg_data;
Vb=0;
bias_data(:,3)=Vb;
Vx=0;
bias_data(:,4)=Vx;

%% now we run optimization. Make a matrix of initial guess
options = optimset('Display','iter','TolFun',1e-11);

lb=[1;1;0;1;0;0.1;50;0.2]; % lower bound constraints
ub=[500;500;0.5;2;0.5;10;1000;0.8]; % upper bound constraints

% Optimization routine 
[coeff_op_tran,resnorm,residual,exitflag] = lsqcurvefit(@daa_mosfet,coeff_init,bias_data,log10(Id_data),lb,ub,options); 

end
