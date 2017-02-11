% Model exerciser for daa_mosfet


clear all
clc
% Drain Bias
Vd = (0:0.01:0.4)';
Vs = 0*ones(length(Vd),1);
Vg = 0.6*ones(length(Vs),1);
Vb=Vs;
bias_data=[Vd,Vg,Vb,Vs];
T=27;                       % Temperature in degrees C
phit = 8.617e-5*(273+T);    % kT/q
tipe =1;                    % *** nFET: type=1  pFET: type=-1

%% UNCOMMENT following 4 lines for 32-nm data
% W=1e-4;                     % *** Width [cm]
% Lgdr = 32e-7;               % *** Gate length [cm]
% dLg= 9e-7;                  % *** dLg=Lgdr-L_c *1e-7 (default 0.3xLg_nom)
% Cg=2.57e-6;                 % *** Gate capacitance in F/cm^2
 
%%% UNCOMMENT following 4 lines for 45-nm data
W=1e-4;                     % *** Width [cm]
Lgdr = 45e-7;               % *** Gate length [cm]
dLg= 7.56e-7;               % *** dLg=Lgdr-L_c *1e-7 (default 0.3xLg_nom)
Cg=2.55e-6;                 % *** Gate capacitance in F/cm^2

%% optim_params must be either chosen to be optim_params_32 or optim_params_45 depending on the experimental data used.
optim_params_32=dlmread('coeff_op_final_32nm.txt');
optim_params_45=dlmread('coeff_op_final_45nm.txt');

%% UNCOMMENT appropriate file from the following two lines
%optim_params = optim_params_32; % change to optim_params_45 for 45 nm
optim_params = optim_params_45; % change to optim_params_45 for 45 nm


% fixed irrespective of technology node.
beta=1.8;                   % *** Saturation factor. Typ. nFET=1.8, pFET=1.6
alpha=3.5;                  % *** Charge Vt trasistion factor (don't change this mostly between 3.0 and 4.0)


% following parameters are not used for optimization routine at all. But
% they must be provided since they are used as inputs and will be used for
% computation of charges and capacitances
IdA=7.73E-08;               % *** Desired Id at Vg=VgA and Vd=VdA: Must be well in sub-threshold
VdA=0.05;                   % *** Vd [V] corresponding to IdA
VgA=0.1;                    % *** Vg [V] corresponding to IdA 
                            % *** Above values overriden if Vt0 is specified directly

etov = 1e4*1.3e-7;          % *** Equivalent thickness of dielectric at S/D-G overlap [cm]
Cif = 0*1e-12;              % *** Inner fringing S or D capacitance [F/cm] 
Cof = 0*1e-12;              % *** Outer fringing S or D capacitance [F/cm]

rv=1.0;                     % *** Ratio vxo(strong inversion)/vxo(weak inversion)
                            % *** Set rv=1 for constant vxo (zeta irrelevant but do not set zeta=0)
zeta=1;                     % *** Parameter determines transtion Vg for vxo 


phib=1.2;                   % *** ~abs(2*phif) [V]
gamma=0.0;                  % *** Body factor  [sqrt(V)]
mc=0.2;                     % *** Choose an appropriate value between 0.01
                            % *** to 10. For, values outside of this range,
                            % *** convergence or accuracy of results is not
                            % *** guaranteed.
                            
CTM_select = 1;             % *** if CTM_select = 1, then classic DD-NVSAT
                            % *** model is used; for CTM_select other than
                            % *** 1,blended DD-NVSAT and ballistic charge
                            % *** transport model is used. 

%%% define global inputs
global input_parms
input_parms =[tipe;W;Lgdr;dLg;gamma;phib;Cg;Cif;Cof;etov;mc;phit;beta;alpha;CTM_select]; % set of input parameters


Rs0=optim_params(1);     % *** Access resistance for terminal "x" [ohm-micron] (Typically Rs)  
Rd0=optim_params(1);     % *** Access resistance for terminal "y" (Typically assume Rs=Rd)
delta=optim_params(3);   % *** DIBL [V/V] 
n0 = optim_params(4);    % *** subthreshold swing factor [unit-less]
nd=optim_params(5);      % *** Factor allowing for modest punchthrough.  
                         % *** Normally, nd=0.  If some punchtrhough 0<nd<0.4

vxo = optim_params(6);   % *** Virtual source velocity [cm/s]    
mu = optim_params(7);    % *** Mobility [cm^2/V.s]
Vt0 = optim_params(8);   % Threshold voltage [V]

coeff=[Rs0; Rd0; delta; n0; nd; vxo; mu;Vt0];

[Idlog,Id,Qs,Qd,Qg,Qb,Vdsi]=daa_mosfet(coeff,bias_data);

figure (1)
hold on
plot((Vd),(Id),'k')
xlabel('Vds (V)')
ylabel('Ids (A)')

figure (2)
plot(Vd,Qs,Vd,Qd,'r',Vd,Qg,'k')
xlabel('Qs(blue), Qd(red), Qg(black) (C)')
%% Calculation of various current and charge derivates vs. Vd
%% computation of Cbd, Cgd, Csd, Cdd, Cgg, Csg, Cdg, Cgs, Cds, Cgb
%%computation of gm and gd
dv = 1e-5;
bias_data1=[Vd-dv,Vg,Vb,Vs];
bias_data2=[Vd+dv,Vg,Vb,Vs];
[Idlog1,Id1,Qs1,Qd1,Qg1,Qb1]=daa_mosfet(coeff,bias_data1);
[Idlog2,Id2,Qs2,Qd2,Qg2,Qb2]=daa_mosfet(coeff,bias_data2);

Cbd=-(Qb2-Qb1)/(2*dv);
Cgd=-(Qg2-Qg1)/(2*dv);
Csd=-(Qs2-Qs1)/(2*dv);
Cdd=(Qd2-Qd1)/(2*dv); 
Gd=(Id2-Id1)/(2*dv);

bias_data3=[Vd,Vg-dv,Vb,Vs];
bias_data4=[Vd,Vg+dv,Vb,Vs];
[Idlog3,Id3,Qs3,Qd3,Qg3,Qb3]=daa_mosfet(coeff,bias_data3);
[Idlog4,Id4,Qs4,Qd4,Qg4,Qb4]=daa_mosfet(coeff,bias_data4);

Cgg=(Qg4-Qg3)/(2*dv);
Csg=-(Qs4-Qs3)/(2*dv);
Cdg=-(Qd4-Qd3)/(2*dv);
Gm=(Id4-Id3)/(2*dv);

bias_data5=[Vd,Vg,Vb,Vs-dv];
bias_data6=[Vd,Vg,Vb,Vs+dv];
[Idlog5,Id5,Qs5,Qd5,Qg5,Qb5]=daa_mosfet(coeff,bias_data5);
[Idlog6,Id6,Qs6,Qd6,Qg6,Qb6]=daa_mosfet(coeff,bias_data6);
Cgs=-(Qg6-Qg5)/(2*dv);
Cds=-(Qd6-Qd5)/(2*dv);

bias_data7=[Vd,Vg,Vb-dv,Vs];
bias_data8=[Vd,Vg,Vb+dv,Vs];
[Idlog7,Id7,Qs7,Qd7,Qg7,Qb7]=daa_mosfet(coeff,bias_data7);
[Idlog8,Id8,Qs8,Qd8,Qg8,Qb8]=daa_mosfet(coeff,bias_data8);
Cgb=-(Qg8-Qg7)/(2*dv);

% plotting w.r.t. Vd
figure (3)
plot(Vd, Gd, Vd, Gm,'k')
xlabel('Vd(V)')
ylabel('Gd (blue), Gm (red)')

figure (4)
plot(Vd,Cgd, 'g', Vd, Cgs, 'r', Vd, -Cbd, 'c', Vd, Cdd, 'k', Vd, Cgg, 'm', Vd, Cgb, 'k--')
xlabel('Vd (V)');
ylabel('Cdd(black), Cgs(red), Cgd(green), -Cbd(cyan) Cgg (magenta), Cgb (dashed) [F]');

figure (5)
plot(Vd, Cds, 'r', Vd, Cdd, 'g')
xlabel('Vd (V)');
ylabel('Cds (red) Cdd (green)');


%Calculation of various current and charge derivates vs. Vg
clear bias_data*
Vg = (0:0.01:1)';
Vd = 0.05*ones(length(Vg),1);
Vs = 0*ones(length(Vg),1);
Vb = 0*ones(length(Vg),1);
bias_data=[Vd,Vg,Vb,Vs];

dv = 1e-5;
bias_data1=[Vd-dv,Vg,Vb,Vs];
bias_data2=[Vd+dv,Vg,Vb,Vs];
[Idlog1,Id1,Qs1,Qd1,Qg1,Qb1]=daa_mosfet(coeff,bias_data1);
[Idlog2,Id2,Qs2,Qd2,Qg2,Qb2]=daa_mosfet(coeff,bias_data2);
Cgd = -(Qg2-Qg1)./(2*dv);
Csd = -(Qs2-Qs1)./(2*dv);
Cbd = -(Qb2-Qb1)./(2*dv);


bias_data3=[Vd,Vg,Vb,Vs-dv];
bias_data4=[Vd,Vg,Vb,Vs+dv];
[Idlog3,Id3,Qs3,Qd3,Qg3,Qb3]=daa_mosfet(coeff,bias_data1);
[Idlog4,Id4,Qs4,Qd4,Qg4,Qb4]=daa_mosfet(coeff,bias_data2);
Cgs = -(Qg4-Qg3)./(2*dv);
Cds = -(Qd4-Qd3)./(2*dv);
Cbs = -(Qb4-Qb3)./(2*dv);

% plotting with respect to Vg
figure (6)
plot(Vg,Cgd, Vg, Cgs, 'k', Vg, Cds, 'g', Vg, Cbs, 'c', Vg, Cbd, 'm')
xlabel('Vg(V)')
ylabel('Cgd (blue), Cgs (black), Cds (green), Cbs (cyan), Cbd (mag)')









 
