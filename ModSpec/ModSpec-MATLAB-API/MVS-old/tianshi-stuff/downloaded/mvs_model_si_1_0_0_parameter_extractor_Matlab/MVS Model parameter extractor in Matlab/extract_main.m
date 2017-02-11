%% this is the main optimization file that will call both the transfer and output files.
%% UNCOMMENT flag has been added to select appropriate experimental data sets.

% input parameters
clear all
clc
T=27;                       % Temperature in degrees C
phit = 8.617e-5*(273+T);    % kT/q
tipe =1;                    % *** nFET: type=1  pFET: type=-1

%% UNCOMMENT following 4 lines for 32-nm data
% W=1e-4;                     % *** Width [cm]
% Lgdr = 32e-7;                 % *** Gate length [cm]
% dLg= 9e-7;                  % *** dLg=L_g-L_c *1e-7 (default 0.3xLg_nom)
% Cg=2.57e-6;                 %*** Gate capacitance in F/cm2
 
%% UNCOMMENT following 4 lines for 45-nm data
W=1e-4;                     % *** Width [cm]
Lgdr = 45e-7;                 % *** Gate length [cm]
dLg= 7.56e-7;               % *** dLg=L_g-L_c *1e-7 (default 0.3xLg_nom)
Cg=2.55e-6;                 % *** Gate capacitance in F/cm^2


beta=1.8;                   % *** Saturation factor. Typ. nFET=1.8, pFET=1.6
alpha=3.5;                  % *** Charge Vt trasistion factor (don't change this mostly between 3.0 and 4.0)

% following parameters are not used for optimization routine at all. But
% they must be provided since they are used as inputs.
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
gamma=0.2;                  % *** Body factor  [sqrt(V)]
mc=0.2;                     % *** Carrier effective mass, raltive to m_0. 
                            % *** Choose an appropriate value between 0.01
                            % *** to 10. For, values outside of this range,
                            % *** convergence or accuracy of results is not
                            % *** guaranteed.
                            
CTM_select = 1;             % *** Parameter to select charge-transport model 
                            % *** if CTM_select = 1, then classic DD-NVSAT
                            % *** model is used; for CTM_select other than
                            % *** 1,blended DD-NVSAT and ballistic charge
                            % *** transport model is used.

%%% define global inputs
global input_parms
input_parms =[tipe;W;Lgdr;dLg;gamma;phib;Cg;Cif;Cof;etov;mc;phit;beta;alpha;CTM_select]; % set of input parameters
%%%% *********

% intial guess for parameters (a total of 7 parameters that need to be fitted since we assume Rs0 = Rd0.)
% the condition Rs0 = Rd0 has been hard-coded in the model file. If Rs0 and Rd0
% are different, then the model file must be appropritaely tweaked.

Rs0=100;                     % *** Access resistance for terminal "x" [ohm-micron] (Typically Rs)  
Rd0=100;                     % *** Access resistance for terminal "y" (Typically assume Rs=Rd)


delta=0.15;                 % *** DIBL [V/V] 
S0=0.1;                     % *** Subthreshold swing at T=27 C and Vd=VdA [V/decade]
phit = 8.617e-5*(273+T);    % kT/q
S=S0*(T+273)/300;
n = S/(log(10)*phit);
nd=0;                       % *** Factor allowing for modest punchthrough.  
                            % *** Normally, nd=0.  If some punchtrhough 0<nd<0.4
n0=n-nd*VdA;                % Intrinsic swing n-factor at T

vxo=1.2;                    % *** Virtual source velocity [cm/s]    
mu=200;                     % *** Mobility [cm^2/V.s]

%Vt0 = VT_new_SR(W,Lg,dLg,IdA,VgA,VdA,Cg,delta,n0,nd,vxo,rv,zeta,mu,phit,alpha,beta); %% initial computation of Vt0 (overwritten)
Vt0 = 0.4; % hardcoded Vt0. will be optimized in the process

coeff_init=[Rs0; Rd0; delta; n0; nd; vxo; mu;Vt0]; % matrix of coefficients to be optimized. 7 coefficients. Rd0 is dummy.

[coeff_op_tran] = optimize_transfer(coeff_init); % first iteration
[coeff_op_out] = optimize_output(coeff_op_tran); % first iteration 

iter=10; % this can be changed to a suitable iteration. optimized params from transfer are fed as initial guesses into output chars.
for len_iter=2:iter
[coeff_op_out(:,len_iter)] = optimize_output(coeff_op_tran(:,len_iter-1));
[coeff_op_tran(:,len_iter)] = optimize_transfer(coeff_op_out(:,len_iter-1));
end
coeff_op_avg = (coeff_op_out+coeff_op_tran)/2; % there may be a bit of discrepancy between the transfer and output and therfore, final optimized params are taken as average.
coeff_op_final = mean(coeff_op_avg(:,end-8:end),2); 
%%% ########################################################


% writing optimized coefficients in the output_text.txt file.
format long e
row_dim = length(coeff_init);
col_dim = iter;
format_string = cell(col_dim,1);
for nC = 1:col_dim
    format_string{nC} = ['%12.4f'];
end

%% UNCOMMENT following line for 32-nm data
%outfile_name = 'output_text_32nm.txt'; %% change name of file for different results.

%% UNCOMMENT following line for 45-nm data
outfile_name = 'output_text_45nm.txt'; %% change name of file for different results.

fileID = fopen(outfile_name, 'w');
fprintf(fileID, 'coeff_op_tran');
fprintf(fileID, '\n');

%Coeff_op_tran
row_labels_tran = cell(row_dim,1);
row_labels_tran{1} = ['Rs0'];
row_labels_tran{2} = ['Rd0'];        % this parameter does not matter.
row_labels_tran{3} = ['DIBL'];
row_labels_tran{4} = ['n0'];
row_labels_tran{5} = ['nd'];
row_labels_tran{6} = ['vxo'];
row_labels_tran{7} = ['mu'];
row_labels_tran{8} = ['Vt0'];

for nA = 1:row_dim
    fprintf(fileID, '%8s\t', row_labels_tran{nA});
    fprintf(fileID, [format_string{:}, '\n'], coeff_op_tran(nA,:));
end
fprintf(fileID, '\n');

%Coeff_op_out
row_labels_out = cell(row_dim,1);
row_labels_out{1} = ['Rs0'];
row_labels_out{2} = ['Rd0'];  % this parameter does not matter.
row_labels_out{3} = ['DIBL'];
row_labels_out{4} = ['n0'];
row_labels_out{5} = ['nd'];
row_labels_out{6} = ['vxo'];
row_labels_out{7} = ['mu'];
row_labels_out{8} = ['Vt0'];

fprintf(fileID, 'coeff_op_out');
fprintf(fileID, '\n');
for nB = 1:row_dim
    fprintf(fileID, '%8s\t', row_labels_out{nB});
    fprintf(fileID, [format_string{:}, '\n'], coeff_op_out(nB,:));

end

%% average optimized coefficients
fprintf(fileID, '\n');
row_labels_avg = cell(row_dim,1);
row_labels_avg{1} = ['Rs0'];
row_labels_avg{2} = ['Rd0'];     % this parameter does not matter
row_labels_avg{3} = ['DIBL'];
row_labels_avg{4} = ['n0'];
row_labels_avg{5} = ['nd'];
row_labels_avg{6} = ['vxo'];
row_labels_avg{7} = ['mu'];
row_labels_avg{8} = ['Vt0'];

fprintf(fileID, 'coeff_op_avg');
fprintf(fileID, '\n');
for navg=1:row_dim
    fprintf(fileID, '%8s\t', row_labels_avg{navg});
    fprintf(fileID, [format_string{:}, '\n'], coeff_op_avg(navg,:));
end


fprintf(fileID, '\n');
row_labels_avg = cell(row_dim,1);
row_labels_avg{1} = ['Rs0'];
row_labels_avg{2} = ['Rd0'];     % this parameter does not matter
row_labels_avg{3} = ['DIBL'];
row_labels_avg{4} = ['n0'];
row_labels_avg{5} = ['nd'];
row_labels_avg{6} = ['vxo'];
row_labels_avg{7} = ['mu'];
row_labels_avg{8} = ['Vt0'];

fprintf(fileID, 'coeff_op_final');
fprintf(fileID, '\n');
for nfinal=1:row_dim
    fprintf(fileID, '%8s\t', row_labels_avg{nfinal});
    fprintf(fileID, [format_string{:}, '\n'], coeff_op_final(nfinal,:));
end

fprintf(fileID, '\n');
fclose(fileID);
%%% ########################################################
%%% end of file that contains data.

%% plotting output data
%%% Read output curve data for plotting
clear Id_data
clear bias_data
clear Vy* Vg* Id_out

%% UNCOMMENT following 5 lines for 32-nm node
% IdVd=abs(dlmread('idvd_Intel_32_nFET_09.txt')); % first column is Vd, second col. is Vg and 3rd col is Id.
% Vymin = 0.05;
% Vymax=1;
% Vystep=0.05;
% Vypre=Vymin:0.05:Vymax;

%% UNCOMMENT following 5 lines lines for 45-nm node
IdVd=abs(dlmread('idvd_Intel_45_nFET_12.txt')); % first column is Vd, second col. is Vg and 3rd col is Id.
Vymin = 0.1;
Vymax=1;
Vystep=0.1;
Vypre=Vymin:0.1:Vymax;

vv=length(Vypre);
Vy_data=IdVd(:,1);
Vg_data=IdVd(:,2);
Id_data = IdVd(:,end);
bias_data(:,1)=Vy_data;
bias_data(:,2)=Vg_data;
Vb=0;
bias_data(:,3)=Vb;
Vx=0;
bias_data(:,4)=Vx;

[Id_optim1] = daa_mosfet(coeff_op_final, bias_data);
ll = length(Id_optim1)/vv;
figure (1)
hold on
for len_vd = 1:ll
 plot(Vypre,(Id_data((len_vd-1)*vv+1:len_vd*vv)),'o')
 plot(Vypre,10.^(Id_optim1((len_vd-1)*vv+1:len_vd*vv))) 
  
end


%% plotting transfer
%% Read transfer curve data for plotting 
clear bias_data
clear Id_data

%% UNCOMMENT following line for 32-nm 
%IdVg=abs(dlmread('idvg_Intel_32_nFET_09.txt'));

%% UNCOMMENT following line for 45-nm
IdVg=abs(dlmread('idvg_Intel_45_nFET_12.txt')); % first column is Vg, second column is Id for Vd=0.05V, third column is Id for Vd=1.0V

Vgpre=IdVg(:,1);
IdVg_loVd=IdVg(:,2);
IdVg_hiVd=IdVg(:,3);
Vy_data=[0.05*ones(1,length(Vgpre))';1.0*ones(1,length(Vgpre))'];
Vg_data=[Vgpre;Vgpre];
bias_data(:,1)=Vy_data;
bias_data(:,2)=Vg_data;
Vb=0;
bias_data(:,3)=Vb;
Vx=0;
bias_data(:,4)=Vx;
Id_optim2=daa_mosfet(coeff_op_final, bias_data);
figure (2)
semilogy(Vgpre,IdVg_loVd,'b',Vgpre,IdVg_hiVd,'b')
hold on
semilogy(Vgpre,10.^(Id_optim2(1:length(Vgpre))),'r',Vgpre,10.^(Id_optim2(length(Vgpre)+1:end)),'r')

