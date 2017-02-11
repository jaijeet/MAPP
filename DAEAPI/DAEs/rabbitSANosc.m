function DAE = rabbitSANosc(uniqIDstr) % DAEAPIv6.2+delta
%function DAE = rabbitSANosc(uniqIDstr) % DAEAPIv6.2+delta
% Action potential in the periphery and center of the rabbit sinoatrial (SA) node
%author: J. Roychowdhury, 2012/06/15
%	- based on code originally written by Xiaolue Lai, Aug 8, 2005.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The System:
%
% See "Mathematical models of action potentials in the periphery and center of the rabbit sinoatrial node",
% 	H. Zhang, A.V. Holden, I. Honjo, M.  Lei, T. Varghese and M.R. Boyett, 2000, 
% 	American Journal of Physiology, 279, H397-H421. PubMed ID: 10899081
%
% Code and information available at: http://models.cellml.org/exposure/01f6a47881da1925315d1d89d3a8d901
%
%
%===========================================================================================================
% CellML file:   zhang_SAN_model_2000_1D_capable.cml
% CellML model:  zhang_SAN_model_2000
% Date and time: 30/06/2005 at 11:05:50
%-------------------------------------------------------------------------------
% Conversion from CellML 1.0 to MATLAB (compute) was done using COR (0.9.31.75)
%    Copyright 2002-2005 Oxford Cardiac Electrophysiology Group
%    http://COR.physiol.ox.ac.uk/ - COR@physiol.ox.ac.uk
%    http://www.CellML.org/
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string, ID: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('rabbitSANosc');
	if nargin < 1
		DAE.uniqIDstr = '';
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, set up inputs, precompute stuff
	DAE.nameStr = sprintf('Zhang et. al. 2000 rabbit sinoatrial node cellular oscillator model');
	DAE.unknameList = strcat({'unk_'}, regexp(int2str(1:15), '\s*', 'split'));
	DAE.eqnnameList = strcat({'d/dt['}, DAE.unknameList, {']'});
	DAE.inputnameList = {};
	DAE.outputnameList = DAE.unknameList;

	DAE.parmnameList = {};
	DAE.parm_defaults = {};
	DAE.parms = DAE.parm_defaults;
	%
	DAE.uQSSvec = [];
	DAE.utfunc = @(t, args) [];
	DAE.utargs = [];
	DAE.uHBfunc = @(f, args) [];
	DAE.uHBargs = [];
	%
% f, q: 
	DAE.f_takes_inputs = 1;
	DAE.f = @f;
	DAE.q = @q;
	%
% df, dq
	DAE.df_dx = @df_dx_DAEAPI_auto; % use vecvalder
	DAE.dq_dx = @dq_dx;
	DAE.df_du = @df_du;
	%
% input-related functions
% output-related functions
	% what makes sense here for transient, LTISSS, etc.?
	DAE.C = @C;
	DAE.D = @D;
	%
% names
	%
% QSS initial guess support
	DAE.QSSinitGuess = @QSSinitGuess;
	%
% NR limiting support
	DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	%DAE.parmdefaults  = @parmdefaults;
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp;
	%DAE.dq_dp  = @dq_dp;
	% data: current values of parameters, can be changed by setparms
	%
% helper functions exposed by DAE
	DAE.internalfuncs = @internalfuncs;
	%
%
end
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(Y, u, DAE)
	%{
	% create variables of the same names as the unknowns and assign
	% them the values in x
	unknames = feval(DAE.unknames,DAE);
	for i = 1:feval(DAE.nunks,DAE)
		evalstr = sprintf('%s = x(i,1);', unknames{i});
		eval(evalstr);
	end

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = feval(DAE.parmnames, DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end
	%}

	% all Xiaolue's code
	calcium_background_current_g_b_Ca_Centre = 1.323e-5;   % microS
	calcium_background_current_g_b_Ca_Periphery = 4.29e-5;   % microS
	four_AP_sensitive_currents_g_sus_Centre = 0.000266;   % microS
	four_AP_sensitive_currents_g_sus_Periphery = 0.0114;   % microS
	four_AP_sensitive_currents_g_to_Centre = 0.004905;   % microS
	four_AP_sensitive_currents_g_to_Periphery = 0.0365;   % microS
	hyperpolarisation_activated_current_g_f_K_Centre = 0.000437;   % microS
	hyperpolarisation_activated_current_g_f_K_Periphery = 0.0055;   % microS
	hyperpolarisation_activated_current_g_f_Na_Centre = 0.000437;   % microS
	hyperpolarisation_activated_current_g_f_Na_Periphery = 0.0055;   % microS
	ionic_concentrations_Ca_i = 0.0001;   % millimolar
	ionic_concentrations_Ca_o = 2.0;   % millimolar
	ionic_concentrations_K_i = 140.0;   % millimolar
	ionic_concentrations_K_o = 5.4;   % millimolar
	ionic_concentrations_Na_i = 8.0;   % millimolar
	ionic_concentrations_Na_o = 140.0;   % millimolar
	L_type_Ca_channel_E_Ca_L = 46.4;   % millivolt
	L_type_Ca_channel_g_Ca_L_Centre = 0.0082;   % microS
	L_type_Ca_channel_g_Ca_L_Periphery = 0.0659;   % microS
	membrane_CmCentre = 2.0e-5;   % microF
	membrane_CmPeriphery = 6.5e-5;   % microF
	membrane_dCell = 0.0;   % dimensionless
	membrane_F = 96845.0;   % coulomb_per_mole
	membrane_R = 8314.0;   % millijoule_per_mole_kelvin
	membrane_T = 310.0;   % kelvin
	persistent_calcium_current_i_Ca_p_max_Centre = 0.0042;   % nanoA
	persistent_calcium_current_i_Ca_p_max_Periphery = 0.03339;   % nanoA
	potassium_background_current_g_b_K_Centre = 2.52e-5;   % microS
	potassium_background_current_g_b_K_Periphery = 8.19e-5;   % microS
	rapid_delayed_rectifying_potassium_current_g_K_r_Centre = 0.000738;   % microS
	rapid_delayed_rectifying_potassium_current_g_K_r_Periphery = 0.0208;   % microS
	rapid_delayed_rectifying_potassium_current_P_i_gate_tau_P_i = 0.006;   % second
	slow_delayed_rectifying_potassium_current_g_K_s_Centre = 0.000345;   % microS
	slow_delayed_rectifying_potassium_current_g_K_s_Periphery = 0.0104;   % microS
	sodium_background_current_g_b_Na_Centre = 5.8e-5;   % microS
	sodium_background_current_g_b_Na_Periphery = 0.000189;   % microS
	sodium_calcium_exchanger_d_NaCa = 0.0001;   % dimensionless
	sodium_calcium_exchanger_gamma_NaCa = 0.5;   % dimensionless
	sodium_calcium_exchanger_k_NaCa_Centre = 2.8e-6;   % nanoA
	sodium_calcium_exchanger_k_NaCa_Periphery = 8.8e-6;   % nanoA
	sodium_current_g_Na_Centre = 0.0;   % microS
	sodium_current_g_Na_Periphery = 3.7e-7;   % microS
	sodium_potassium_pump_i_p_max_Centre = 0.0478;   % nanoA
	sodium_potassium_pump_i_p_max_Periphery = 0.16;   % nanoA
	sodium_potassium_pump_K_m_K = 0.621;   % millimolar
	sodium_potassium_pump_K_m_Na = 5.64;   % millimolar
	T_type_Ca_channel_E_Ca_T = 45.0;   % millivolt
	T_type_Ca_channel_g_Ca_T_Centre = 0.0021;   % microS
	T_type_Ca_channel_g_Ca_T_Periphery = 0.00694;   % microS


%-------------------------------------------------------------------------------
% Computation
%-------------------------------------------------------------------------------

	membrane_FCell = 1.07*29.0*membrane_dCell/(30.0*(1.0+0.7745*exp(-(29.0*membrane_dCell-24.5)/1.95)));
	calcium_background_current_g_b_Ca = calcium_background_current_g_b_Ca_Centre+membrane_FCell*(calcium_background_current_g_b_Ca_Periphery-calcium_background_current_g_b_Ca_Centre);
	reversal_and_equilibrium_potentials_E_Ca = membrane_R*membrane_T/(2.0*membrane_F)*log(ionic_concentrations_Ca_o/ionic_concentrations_Ca_i);
	calcium_background_current_i_b_Ca = calcium_background_current_g_b_Ca*(Y(6)-reversal_and_equilibrium_potentials_E_Ca);
	four_AP_sensitive_currents_g_to = four_AP_sensitive_currents_g_to_Centre+membrane_FCell*(four_AP_sensitive_currents_g_to_Periphery-four_AP_sensitive_currents_g_to_Centre);
	four_AP_sensitive_currents_g_sus = four_AP_sensitive_currents_g_sus_Centre+membrane_FCell*(four_AP_sensitive_currents_g_sus_Periphery-four_AP_sensitive_currents_g_sus_Centre);
	reversal_and_equilibrium_potentials_E_K = membrane_R*membrane_T/membrane_F*log(ionic_concentrations_K_o/ionic_concentrations_K_i);
	four_AP_sensitive_currents_i_to = four_AP_sensitive_currents_g_to*Y(1)*Y(2)*(Y(6)-reversal_and_equilibrium_potentials_E_K);
	four_AP_sensitive_currents_i_sus = four_AP_sensitive_currents_g_sus*Y(2)*(Y(6)-reversal_and_equilibrium_potentials_E_K);
	four_AP_sensitive_currents_q_gate_q_infinity = 1.0/(1.0+exp((Y(6)+59.37)/13.1));
	four_AP_sensitive_currents_q_gate_tau_q = 0.0101+0.06517/(0.5686*exp(-0.08161*(Y(6)+39.0))+0.7174*exp(0.2719*(Y(6)+40.93)));
	dY(1, 1) = (four_AP_sensitive_currents_q_gate_q_infinity-Y(1))/four_AP_sensitive_currents_q_gate_tau_q;
	four_AP_sensitive_currents_r_gate_r_infinity = 1.0/(1.0+exp(-(Y(6)-10.93)/19.7));
	four_AP_sensitive_currents_r_gate_tau_r = 0.001*(2.98+19.59/(1.037*exp(0.09012*(Y(6)+30.61))+0.369*exp(-0.119*(Y(6)+23.84))));
	dY(2, 1) = (four_AP_sensitive_currents_r_gate_r_infinity-Y(2))/four_AP_sensitive_currents_r_gate_tau_r;
	hyperpolarisation_activated_current_g_f_Na = hyperpolarisation_activated_current_g_f_Na_Centre+membrane_FCell*(hyperpolarisation_activated_current_g_f_Na_Periphery-hyperpolarisation_activated_current_g_f_Na_Centre);
	hyperpolarisation_activated_current_i_f_Na = hyperpolarisation_activated_current_g_f_Na*Y(3)*(Y(6)-77.6);
	hyperpolarisation_activated_current_g_f_K = hyperpolarisation_activated_current_g_f_K_Centre+membrane_FCell*(hyperpolarisation_activated_current_g_f_K_Periphery-hyperpolarisation_activated_current_g_f_K_Centre);
	hyperpolarisation_activated_current_i_f_K = hyperpolarisation_activated_current_g_f_K*Y(3)*(Y(6)+102.0);
	hyperpolarisation_activated_current_y_gate_alpha_y = exp(-(Y(6)+78.91)/26.63);
	hyperpolarisation_activated_current_y_gate_beta_y = exp((Y(6)+75.13)/21.25);
	dY(3, 1) = hyperpolarisation_activated_current_y_gate_alpha_y*(1.0-Y(3))-hyperpolarisation_activated_current_y_gate_beta_y*Y(3);
	L_type_Ca_channel_g_Ca_L = L_type_Ca_channel_g_Ca_L_Centre+membrane_FCell*(L_type_Ca_channel_g_Ca_L_Periphery-L_type_Ca_channel_g_Ca_L_Centre);
	L_type_Ca_channel_i_Ca_L = L_type_Ca_channel_g_Ca_L*(Y(5)*Y(4)+0.006/(1.0+exp(-(Y(6)+14.1)/6.0)))*(Y(6)-L_type_Ca_channel_E_Ca_L);
	L_type_Ca_channel_d_gate_d_L_infinity = 1.0/(1.0+exp(-(Y(6)+22.2)/6.0));
	L_type_Ca_channel_d_gate_alpha_d_L = -28.4*(Y(6)+35.0)/(exp(-(Y(6)+35.0)/2.5)-1.0)-84.9*Y(6)/(exp(-0.208*Y(6))-1.0);
	L_type_Ca_channel_d_gate_beta_d_L = 11.42*(Y(6)-5.0)/(exp(0.4*(Y(6)-5.0))-1.0);
	L_type_Ca_channel_d_gate_tau_d_L = 2.0/(L_type_Ca_channel_d_gate_alpha_d_L+L_type_Ca_channel_d_gate_beta_d_L);
	dY(4, 1) = (L_type_Ca_channel_d_gate_d_L_infinity-Y(4))/L_type_Ca_channel_d_gate_tau_d_L;
	L_type_Ca_channel_f_gate_f_L_infinity = 1.0/(1.0+exp((Y(6)+45.0)/5.0));
	L_type_Ca_channel_f_gate_alpha_f_L = 3.12*(Y(6)+28.0)/(exp((Y(6)+28.0)/4.0)-1.0);
	L_type_Ca_channel_f_gate_beta_f_L = 25.0/(1.0+exp(-(Y(6)+28.0)/4.0));
	L_type_Ca_channel_f_gate_tau_f_L = 1.0/(L_type_Ca_channel_f_gate_alpha_f_L+L_type_Ca_channel_f_gate_beta_f_L);
	dY(5, 1) = (L_type_Ca_channel_f_gate_f_L_infinity-Y(5))/L_type_Ca_channel_f_gate_tau_f_L;
	membrane_Cm = membrane_CmCentre+membrane_FCell*(membrane_CmPeriphery-membrane_CmCentre);
	sodium_current_g_Na = sodium_current_g_Na_Centre+membrane_FCell*(sodium_current_g_Na_Periphery-sodium_current_g_Na_Centre);
	sodium_current_h_gate_F_Na = 0.09518*exp(-0.06306*(Y(6)+34.4))/(1.0+1.662*exp(-0.2251*(Y(6)+63.7)))+0.08693;
	sodium_current_h_gate_h = (1.0-sodium_current_h_gate_F_Na)*Y(11)+sodium_current_h_gate_F_Na*Y(12);
	reversal_and_equilibrium_potentials_E_Na = membrane_R*membrane_T/membrane_F*log(ionic_concentrations_Na_o/ionic_concentrations_Na_i);
	sodium_current_i_Na = sodium_current_g_Na*Y(13)^3.0*sodium_current_h_gate_h*ionic_concentrations_Na_o*membrane_F^2.0/(membrane_R*membrane_T)*(exp((Y(6)-reversal_and_equilibrium_potentials_E_Na)*membrane_F/(membrane_R*membrane_T))-1.0)/(exp(Y(6)*membrane_F/(membrane_R*membrane_T))-1.0)*Y(6);
	T_type_Ca_channel_g_Ca_T = T_type_Ca_channel_g_Ca_T_Centre+membrane_FCell*(T_type_Ca_channel_g_Ca_T_Periphery-T_type_Ca_channel_g_Ca_T_Centre);
	T_type_Ca_channel_i_Ca_T = T_type_Ca_channel_g_Ca_T*Y(14)*Y(15)*(Y(6)-T_type_Ca_channel_E_Ca_T);
	rapid_delayed_rectifying_potassium_current_g_K_r = rapid_delayed_rectifying_potassium_current_g_K_r_Centre+membrane_FCell*(rapid_delayed_rectifying_potassium_current_g_K_r_Periphery-rapid_delayed_rectifying_potassium_current_g_K_r_Centre);
	rapid_delayed_rectifying_potassium_current_P_a = 0.6*Y(7)+0.4*Y(8);
	rapid_delayed_rectifying_potassium_current_i_K_r = rapid_delayed_rectifying_potassium_current_g_K_r*rapid_delayed_rectifying_potassium_current_P_a*Y(9)*(Y(6)-reversal_and_equilibrium_potentials_E_K);
	slow_delayed_rectifying_potassium_current_g_K_s = slow_delayed_rectifying_potassium_current_g_K_s_Centre+membrane_FCell*(slow_delayed_rectifying_potassium_current_g_K_s_Periphery-slow_delayed_rectifying_potassium_current_g_K_s_Centre);
	reversal_and_equilibrium_potentials_E_K_s = membrane_R*membrane_T/membrane_F*log((ionic_concentrations_K_o+0.03*ionic_concentrations_Na_o)/(ionic_concentrations_K_i+0.03*ionic_concentrations_Na_i));
	slow_delayed_rectifying_potassium_current_i_K_s = slow_delayed_rectifying_potassium_current_g_K_s*Y(10)^2.0*(Y(6)-reversal_and_equilibrium_potentials_E_K_s);
	sodium_background_current_g_b_Na = sodium_background_current_g_b_Na_Centre+membrane_FCell*(sodium_background_current_g_b_Na_Periphery-sodium_background_current_g_b_Na_Centre);
	sodium_background_current_i_b_Na = sodium_background_current_g_b_Na*(Y(6)-reversal_and_equilibrium_potentials_E_Na);
	potassium_background_current_g_b_K = potassium_background_current_g_b_K_Centre+membrane_FCell*(potassium_background_current_g_b_K_Periphery-potassium_background_current_g_b_K_Centre);
	potassium_background_current_i_b_K = potassium_background_current_g_b_K*(Y(6)-reversal_and_equilibrium_potentials_E_K);
	sodium_calcium_exchanger_k_NaCa = sodium_calcium_exchanger_k_NaCa_Centre+membrane_FCell*(sodium_calcium_exchanger_k_NaCa_Periphery-sodium_calcium_exchanger_k_NaCa_Centre);
	sodium_calcium_exchanger_i_NaCa = sodium_calcium_exchanger_k_NaCa*(ionic_concentrations_Na_i^3.0*ionic_concentrations_Ca_o*exp(0.03743*Y(6)*sodium_calcium_exchanger_gamma_NaCa)-ionic_concentrations_Na_o^3.0*ionic_concentrations_Ca_i*exp(0.03743*Y(6)*(sodium_calcium_exchanger_gamma_NaCa-1.0)))/(1.0+sodium_calcium_exchanger_d_NaCa*(ionic_concentrations_Ca_i*ionic_concentrations_Na_o^3.0+ionic_concentrations_Ca_o*ionic_concentrations_Na_i^3.0));
	sodium_potassium_pump_i_p_max = sodium_potassium_pump_i_p_max_Centre+membrane_FCell*(sodium_potassium_pump_i_p_max_Periphery-sodium_potassium_pump_i_p_max_Centre);
	sodium_potassium_pump_i_p = sodium_potassium_pump_i_p_max*(ionic_concentrations_Na_i/(sodium_potassium_pump_K_m_Na+ionic_concentrations_Na_i))^3.0*(ionic_concentrations_K_o/(sodium_potassium_pump_K_m_K+ionic_concentrations_K_o))^2.0*1.6/(1.5+exp(-(Y(6)+60.0)/40.0));
	persistent_calcium_current_i_Ca_p_max = persistent_calcium_current_i_Ca_p_max_Centre+membrane_FCell*(persistent_calcium_current_i_Ca_p_max_Periphery-persistent_calcium_current_i_Ca_p_max_Centre);
	persistent_calcium_current_i_Ca_p = persistent_calcium_current_i_Ca_p_max*ionic_concentrations_Ca_i/(ionic_concentrations_Ca_i+0.0004);
	dY(6, 1) = -1.0/membrane_Cm*(sodium_current_i_Na+L_type_Ca_channel_i_Ca_L+T_type_Ca_channel_i_Ca_T+four_AP_sensitive_currents_i_to+four_AP_sensitive_currents_i_sus+rapid_delayed_rectifying_potassium_current_i_K_r+slow_delayed_rectifying_potassium_current_i_K_s+hyperpolarisation_activated_current_i_f_Na+hyperpolarisation_activated_current_i_f_K+sodium_background_current_i_b_Na+calcium_background_current_i_b_Ca+potassium_background_current_i_b_K+sodium_calcium_exchanger_i_NaCa+sodium_potassium_pump_i_p+persistent_calcium_current_i_Ca_p);
	rapid_delayed_rectifying_potassium_current_P_af_gate_P_af_inf = 1.0/(1.0+exp(-(Y(6)+13.2)/10.6));
	rapid_delayed_rectifying_potassium_current_P_af_gate_tau_P_af = 1.0/(37.2*exp((Y(6)-10.0)/15.9)+0.96*exp(-(Y(6)-10.0)/22.5));
	dY(7, 1) = (rapid_delayed_rectifying_potassium_current_P_af_gate_P_af_inf-Y(7))/rapid_delayed_rectifying_potassium_current_P_af_gate_tau_P_af;
	rapid_delayed_rectifying_potassium_current_P_as_gate_P_as_inf = rapid_delayed_rectifying_potassium_current_P_af_gate_P_af_inf;
	rapid_delayed_rectifying_potassium_current_P_as_gate_tau_P_as = 1.0/(4.2*exp((Y(6)-10.0)/17.0)+0.15*exp(-(Y(6)-10.0)/21.6));
	dY(8, 1) = (rapid_delayed_rectifying_potassium_current_P_as_gate_P_as_inf-Y(8))/rapid_delayed_rectifying_potassium_current_P_as_gate_tau_P_as;
	rapid_delayed_rectifying_potassium_current_P_i_gate_P_i_inf = 1.0/(1.0+exp((Y(6)+18.6)/10.1));
	dY(9, 1) = (rapid_delayed_rectifying_potassium_current_P_i_gate_P_i_inf-Y(9))/rapid_delayed_rectifying_potassium_current_P_i_gate_tau_P_i;
	slow_delayed_rectifying_potassium_current_xs_gate_alpha_xs = 14.0/(1.0+exp(-(Y(6)-40.0)/9.0));
	slow_delayed_rectifying_potassium_current_xs_gate_beta_xs = exp(-Y(6)/45.0);
	dY(10, 1) = slow_delayed_rectifying_potassium_current_xs_gate_alpha_xs*(1.0-Y(10))-slow_delayed_rectifying_potassium_current_xs_gate_beta_xs*Y(10);
	sodium_current_h_gate_h1_infinity = 1.0/(1.0+exp((Y(6)+66.1)/6.4));
	sodium_current_h_gate_tau_h1 = 3.717e-6*exp(-0.2815*(Y(6)+17.11))/(1.0+0.003732*exp(-0.3426*(Y(6)+37.76)))+0.0005977;
	dY(11, 1) = (sodium_current_h_gate_h1_infinity-Y(11))/sodium_current_h_gate_tau_h1;
	sodium_current_h_gate_h2_infinity = sodium_current_h_gate_h1_infinity;
	sodium_current_h_gate_tau_h2 = 3.186e-8*exp(-0.6219*(Y(6)+18.8))/(1.0+7.189e-5*exp(-0.6683*(Y(6)+34.07)))+0.003556;
	dY(12, 1) = (sodium_current_h_gate_h2_infinity-Y(12))/sodium_current_h_gate_tau_h2;
	sodium_current_m_gate_m_infinity = (1.0/(1.0+exp(-(Y(6)+30.32)/5.46)))^(1.0/3.0);
	sodium_current_m_gate_tau_m = 0.0006247/(0.8322166*exp(-0.33566*(Y(6)+56.7062))+0.6274*exp(0.0823*(Y(6)+65.0131)))+4.569e-5;
	dY(13, 1) = (sodium_current_m_gate_m_infinity-Y(13))/sodium_current_m_gate_tau_m;
	T_type_Ca_channel_d_gate_d_T_infinity = 1.0/(1.0+exp(-(Y(6)+37.0)/6.8));
	T_type_Ca_channel_d_gate_alpha_d_T = 1068.0*exp((Y(6)+26.3)/30.0);
	T_type_Ca_channel_d_gate_beta_d_T = 1068.0*exp(-(Y(6)+26.3)/30.0);
	T_type_Ca_channel_d_gate_tau_d_T = 1.0/(T_type_Ca_channel_d_gate_alpha_d_T+T_type_Ca_channel_d_gate_beta_d_T);
	dY(14, 1) = (T_type_Ca_channel_d_gate_d_T_infinity-Y(14))/T_type_Ca_channel_d_gate_tau_d_T;
	T_type_Ca_channel_f_gate_f_T_infinity = 1.0/(1.0+exp((Y(6)+71.0)/9.0));
	T_type_Ca_channel_f_gate_alpha_f_T = 15.3*exp(-(Y(6)+71.7)/83.3);
	T_type_Ca_channel_f_gate_beta_f_T = 15.0*exp((Y(6)+71.7)/15.38);
	T_type_Ca_channel_f_gate_tau_f_T = 1.0/(T_type_Ca_channel_f_gate_alpha_f_T+T_type_Ca_channel_f_gate_beta_f_T);
	dY(15, 1) = (T_type_Ca_channel_f_gate_f_T_infinity-Y(15))/T_type_Ca_channel_f_gate_tau_f_T;

	fout	= -dY;
end
% end f(...)

function qout = q(x, DAE)
	qout = x;
end
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x, u %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Jq = dq_dx(x, DAE)
	Jq = eye(15);
end
% end dq_dx(...)

function dfdu = df_du(x, u, DAE)
	%{
	eC = x(1); iL = x(2); 
	Iin = u;

	% create variables of the same names as the parameters and assign
	% them the values in DAE.parms
	pnames = parmnames_DAEAPI(DAE);
	for i = 1:feval(DAE.nparms,DAE)
		%assignin('base', pnames{i}, DAE.parms{i}) % doesn't seem to work, for some reason
		evalstr = sprintf('%s = DAE.parms{i};', pnames{i});
		eval(evalstr);
	end
	%}
	dfdu = sparse(15,0);
end
% end df_du(...)


%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	out = eye(15);
end
% end C(...)

function out = D(DAE)
	out = sparse(15,0);
end
% end D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	%
	% steady state: xinit = [0.29760539675, 0.064402950262, 0.03889291759, 0.04804900895, 0.48779845203, -39.013558536, 0.13034201158, 0.46960956028, 0.87993375273, 0.082293827208, 0.015905380261, 0.01445216109, 0.092361701692, 0.42074047435, 0.038968420558];
	out = [0.29760539675; ...  % unk_1
	       0.064402950262; ... % unk_2
	       0.03889291759; ...  % unk_3
	       0.04804900895; ...  % unk_4
	       0.48779845203; ...  % unk_5
	       -39.013558536; ...  % unk_6
	       0.13034201158; ...  % unk_7
	       0.46960956028; ...  % unk_8
	       0.87993375273; ...  % unk_9
	       0.082293827208; ... % unk_10
	       0.015905380261; ... % unk_11
	       0.01445216109; ...  % unk_12
	       0.092361701692; ... % unk_13
	       0.42074047435; ...  % unk_14
	       0.038968420558];    % unk_15
end
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE)
	newdx = dx;
end
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs
	m = nNoiseSources(DAE);
	out = speye(m);
	% unit PSDs; all the action is moved to m(x,n)
end
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
	% NOTE: m should be for one-sided PSDs
	% M is of size neqns. n is of size nNoiseSources
	%
	M = dm_dn(x,n,DAE);
	out = M*n;
end
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
	n = nunks(DAE);
	Jm = sparse([]);
	Jm(n,n) = 0;
end
% end dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
	% M is of size neqns. n is of size nNoiseSources
	% NOTE: M should be for one-sided PSDs
	%
	k = 1.3806503e-23; % Boltzmann's const
	q = 1.60217646e-19; % electronic charge
	T = 300; % Kelvin; absolute temperature FIXME: this should be a parameter

	n = nunks(DAE);
	nn = nNoiseSources(DAE);
	M = sparse([]); M(nsegs,nsegs) = 0;
	M = M*sqrt(4*k*T/R);
end
% end dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
	ifs = 'No internal functions exposed by this DAE system.';
	%ifs.stoichmatfunc = @stoichmatfunc;
	%ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
end
% end internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
