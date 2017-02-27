function outObj = LMSmethods()
%function outObj = LMSmethods()
%Defines supported LMS methods: .FE, .BE, .TRAP, .GEAR2
%
%Each method contains the fields:
% .order (this is p, eg, 1)
% .name (eg, 'BE')
% .alphasfunc(tpts) 
%   - tpts = [tn, tn-1, tn-2, ..., tn-p];
%   - returns [alpha0(tpts), ..., alphap(tpts)] for the method
% .betasfunc(tpts)
%   - tpts = [tn, tn-1, tn-2, ..., tn-p];
%   - returns [beta0(tpts), ..., betap(tpts)] for the method
% .dalphasfunc(tpts) 
%   - tpts = [tn, tn-1, tn-2, ..., tn-p];
%   - returns [d(alpha0(tpts))/dtn, ..., d(alphap(tpts))/dtn] for the method
% .dbetasfunc(tpts)
%   - tpts = [tn, tn-1, tn-2, ..., tn-p];
%   - returns [d(beta0(tpts))/dtn, ..., d(betap(tpts))/dtn] for the method
%
%these are used by the LMS solver.
%
%TODO: put in a tutorial on adding a new LMS method to LMSmethods()
%
%Examples
%--------
%
%% set up DAE
%nsegs = 1; R = 1e3; C = 1e-6;
%DAE =  RClineDAEAPIv6('', nsegs, R, C);
%
%% set transient input to the DAE
%utargs.A = 1; utargs.f=1e3; utargs.phi=0;
%utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
%DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
%
%%set up a transient using the TRAPezoidal method from LMSmethods()
%TRmethods = LMSmethods(); % defines FE, BE, TRAP, and GEAR2 
%TransObjTRAP = LMS(DAE, TRmethods.TRAP);
%
%% run transient and plot
%xinit = 1; tstart = 0; tstep = 10e-6; tstop = 5e-3;
%TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, ...
%      xinit, tstart, tstep, tstop);
%[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP);
%
%
%See also
%--------
%
% LMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Changelog:
%---------
%2014/02/07: Jian Yao <jianyao@berkeley.edu>: add function to calculate LTE value. 
%

%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% set up BE method to be available "outside"
    outObj.BE.order = 1; % p = order
    outObj.BE.kth_exact = 1; % k = kth-exact based on exactness constraints  %modified by jian
    outObj.BE.name = 'BE'; % p = order
    outObj.BE.alphasfunc = @BEalphasfunc; 
		% feval(alphasfunc, last_pp1_ts) = alpha0, alpha1, ...
		% last_pp1_ts = [t_n, t_{n-1}, ..., t_{n-p}]
    outObj.BE.dalphasfunc = @dBEalphasfunc; 
		% feval(betasfunc, last_pp1_ts) = beta0, beta1, ...
    outObj.BE.betasfunc = @BEbetasfunc; 
		% last_pp1_ts = [t_n, t_{n-1}, ..., t_{n-p}]
    outObj.BE.dbetasfunc = @dBEbetasfunc; 
    outObj.BE.ddtApproxATtn = @simpleTwoPtFiniteDifference; 
		% this provides an approximation to xdot(tn) consistent
		% with the LMS method
    outObj.BE.LTEcontrol = @BELTEcontrol;   %modified by jian
		% this is used for calculating the LTE value with the given
		% timestep and x value
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% set up FE method to be available "outside"
    outObj.FE.order = 1;
    outObj.FE.kth_exact = 1; 
    outObj.FE.name = 'FE';
    outObj.FE.alphasfunc = @FEalphasfunc; 
    outObj.FE.dalphasfunc = @dFEalphasfunc; 
    outObj.FE.betasfunc = @FEbetasfunc; 
    outObj.FE.dbetasfunc = @dFEbetasfunc; 
    outObj.FE.ddtApproxATtn = @simpleTwoPtFiniteDifference; 
    outObj.FE.LTEcontrol = @FELTEcontrol; 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% set up TRAP method to be available "outside"
    outObj.TRAP.order = 1;
    outObj.TRAP.kth_exact = 2; 
    outObj.TRAP.name = 'TRAP';
    outObj.TRAP.betasfunc =  @TRAPbetasfunc; 
    outObj.TRAP.dbetasfunc =  @dTRAPbetasfunc; 
    outObj.TRAP.alphasfunc = @TRAPalphasfunc; 
    outObj.TRAP.dalphasfunc = @dTRAPalphasfunc; 
    outObj.TRAP.ddtApproxATtn = @simpleTwoPtFiniteDifference;
    outObj.TRAP.LTEcontrol = @TRAPLTEcontrol; 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% set up GEAR2 method to be available "outside"
    outObj.GEAR2.order = 2;
    outObj.GEAR2.kth_exact = 2;
    outObj.GEAR2.name = 'GEAR2';
    outObj.GEAR2.alphasfunc = @GEAR2alphasfunc; 
    outObj.GEAR2.dalphasfunc = @dGEAR2alphasfunc; 
    outObj.GEAR2.betasfunc =  @GEAR2betasfunc; 
    outObj.GEAR2.dbetasfunc =  @dGEAR2betasfunc; 
    outObj.GEAR2.ddtApproxATtn = @GEAR2ddtApproxATtn; 
    outObj.GEAR2.LTEcontrol = @GEAR2LTEcontrol; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% provide a method to do the LHS sum of alphas
	% 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end % LMSmethods constructor

%%%%%%%%%%%%%%%%%%%%%%%%%
%% BE
function BEalphas = BEalphasfunc(last_2_ts)
%function BEalphas = BEalphasfunc(last_2_ts)
%This function computes alpha_0 and alpha_1 for the BE-based LMS method.
%INPUT args:
%   last_2_ts       - two consecutive times points (1x2 sized array)
%
%OUTPUT:
%   BEalphas        - [alpha_0, alpha_1] = alphas for the BE-based LMS method 
    BEalphas = [1, -1]; % alpha_0, alpha_1
end %  of BEalphasfunc

function dBEalphas = dBEalphasfunc(last_2_ts)
%function dBEalphas = dBEalphasfunc(last_2_ts)
%This function computes d(alpha_0)/dtn and d(alpha_1)/dtn for the BE-based LMS method.
%INPUT args:
%   last_2_ts       - two consecutive times points (1x2 sized array)
%
%OUTPUT:
%   dBEalphas        - [d(alpha_0)/dtn, d(alpha_1)/dtn] = for BE
    dBEalphas = [0, 0];
end %  of dBEalphasfunc

function BEbetas = BEbetasfunc(last_2_ts)
%function BEbetas = BEbetasfunc(last_2_ts)
%This function computes beta_0 and beta_1 for the BE-based LMS method.
%INPUT args:
%   last_2_ts       - two consecutive times points (1x2 sized array)
%
%OUTPUT:
%   BEbetas        - [beta_0, beta_1] = betas for the BE-based LMS method 
    h = last_2_ts(1)-last_2_ts(2);
    BEbetas = [h, 0]; % beta_0, beta_1
end % of BEbetasfunc

function dBEbetas = dBEbetasfunc(last_2_ts)
%function dBEbetas = dBEbetasfunc(last_2_ts)
%This function computes d(beta_0)/dtn and d(beta_1)/dtn for the BE-based LMS method.
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%
%OUTPUT:
%   dBEbetas        - [d(beta_0)/dtn, d(beta_1)/dtn] = for BE
    % h = last_2_ts(1)-last_2_ts(2);
    % BEbetas = [h, 0];
    dBEbetas = [1, 0]; 
end % of dBEbetasfunc

function out = simpleTwoPtFiniteDifference(last_2_ts, last_2_xs)
%function out = simpleTwoPtFiniteDifference(last_2_ts, last_2_xs)
%This function provides an approximation to xdot(tn) consistent with the LMS
%method.
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%   last_2_xs       - two consecutive xs (1x2 sized array)
%
%OUTPUT:
%   out             - xdot(tn) approximation
    h = last_2_ts(1)-last_2_ts(2);
    out = last_2_xs(:,1) - last_2_xs(:,2);
    out = out/h;
end % of BEbetasfunc

%%%%%%%%%%%%%% added by jian%%%%%%%%%%%%%%%%%
function out =  BELTEcontrol(last_2_ts, last_2_xs, funcparms)
%function out = BELTEcontrol(last_2_ts, last_2_xs, funcparms)
%This function computes the LTE value for a given time_step and x value
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%   last_2_xs       - two consecutive xs (1x2 sized array)
%   funcparms       - LMSobj.AFobj
%
%OUTPUT:
%   out             - LTE value for the given time_step and x value
    h = last_2_ts(1)-last_2_ts(2);
    g1= calg_x_t(last_2_xs(:,1),last_2_ts(1),funcparms);
    g2= calg_x_t(last_2_xs(:,2),last_2_ts(2),funcparms);
    out = -0.5*(g1-g2)*h;	
end % of BELTEcontrol

%%%%%%%%%%%%%%%%%%%%%%%%%
%% FE
function FEalphas = FEalphasfunc(last_2_ts)
%function FEalphas = FEalphasfunc(last_2_ts)
%This function computes alpha_0 and alpha_1 for the FE-based LMS method.
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%
%OUTPUT:
%   FEalphas        - [alpha_0, alpha_1] = alphas for the FE-based LMS method 
    FEalphas = [1, -1]; % alpha_0, alpha_1
end % of FEalphasfunc

function dFEalphas = dFEalphasfunc(last_2_ts)
%function dFEalphas = dFEalphasfunc(last_2_ts)
%This function computes d(alpha_0)/dtn and d(alpha_1)/dtn for the FE-based LMS method.
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%
%OUTPUT:
%   dFEalphas        - [d(alpha_0)/dtn, d(alpha_1)/dtn] for FE
    dFEalphas = [0, 0]; % alpha_0, alpha_1
end % of dFEalphasfunc

function FEbetas = FEbetasfunc(last_2_ts)
%function FEbetas = FEbetasfunc(last_2_ts)
%This function computes beta_0 and beta_1 for the FE-based LMS method.
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%
%OUTPUT:
%   FEbetas        - [beta_0, beta_1] = betas for the FE-based LMS method 
    h = last_2_ts(1)-last_2_ts(2);
    FEbetas = [0, h]; % beta_0, beta_1
end % of FEbetasfunc

function dFEbetas = dFEbetasfunc(last_2_ts)
%function dFEbetas = dFEbetasfunc(last_2_ts)
%This function computes d(beta_0)/dtn and d(beta_1)/dtn for FE.
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%
%OUTPUT:
%   dFEbetas        - [d(beta_0)/dtn, d(beta_1)/dtn] = betas for FE.
    % h = last_2_ts(1)-last_2_ts(2);
    % FEbetas = [0, h];
    dFEbetas = [0, 1];
end % of dFEbetasfunc

function out =  FELTEcontrol(last_2_ts, last_2_xs, funcparms)
%function out = FELTEcontrol(last_2_ts, last_2_xs, funcparms)
%This function computes the LTE value for a given time_step and x value
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%   last_2_xs       - two consecutive xs (1x2 sized array)
%   funcparms       - LMSobj.AFobj
%
%OUTPUT:
%   out             - LTE value for the given time_step and x value
    h = last_2_ts(1)-last_2_ts(2);
    g1= calg_x_t(last_2_xs(:,1),last_2_ts(1),funcparms);
    g2= calg_x_t(last_2_xs(:,2),last_2_ts(2),funcparms);
    out = 0.5*(g1-g2)*h;	
end % of FELTEcontrol

%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%
%% TRAP
function TRAPalphas = TRAPalphasfunc(last_2_ts)
%function TRAPalphas = TRAPalphasfunc(last_2_ts)
%This function computes alpha_0 and alpha_1 for the TRAP-based LMS method.
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%
%OUTPUT:
%   TRAPalphas      - [alpha_0, alpha_1] = alphas for the TRAP-based LMS method 
    TRAPalphas = [1, -1]; % alpha_0, alpha_1
end % of TRAPalphasfunc

function dTRAPalphas = dTRAPalphasfunc(last_2_ts)
%function dTRAPalphas = dTRAPalphasfunc(last_2_ts)
%This function computes d(alpha_0)/dtn and d(alpha_1)/dtn for TRAP.
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%
%OUTPUT:
%   dTRAPalphas      - [d(alpha_0)/dtn, d(alpha_1)/dtn] = alphas for TRAP
    % TRAPalphas = [1, -1]; % alpha_0, alpha_1
    dTRAPalphas = [0, 0];
end % of dTRAPalphasfunc

function TRAPbetas = TRAPbetasfunc(last_2_ts)
%function TRAPbetas = TRAPbetasfunc(last_2_ts)
%This function computes beta_0 and beta_1 for the TRAP-based LMS method.
%INPUT args:
%   last_2_ts       - two consecutive times steps (1x2 sized array)
%
%OUTPUT:
%   TRAPbetas       - [beta_0, beta_1] = betas for the TRAP-based LMS method 
    h = last_2_ts(1)-last_2_ts(2);
    TRAPbetas = [h/2, h/2]; % beta_0, beta_1
end % of TRAPbetasfunc

function dTRAPbetas = dTRAPbetasfunc(last_2_ts)
%function dTRAPbetas = dTRAPbetasfunc(last_2_ts)
%This function computes d(beta_0)/dtn and d(beta_1)/dtn for TRAP.
%INPUT args:
%   last_2_ts       - two consecutive time points (1x2 sized array)
%
%OUTPUT:
%   dTRAPbetas       - [d(beta_0)/dtn, d(beta_1)/dtn] = betas for the TRAP-based LMS method 
    % h = last_2_ts(1)-last_2_ts(2);
    % TRAPbetas = [h/2, h/2]; % beta_0, beta_1
    dTRAPbetas = [1/2, 1/2];
end % of dTRAPbetasfunc

function out =  TRAPLTEcontrol(last_3_ts, last_3_xs, funcparms)
%function out = TRAPLTEcontrol(last_3_ts, last_3_xs, funcparms)
%This function computes the LTE value for a given time_step and x value
%INPUT args:
%   last_3_ts       - three consecutive time points (1x3 sized array)
%   last_3_xs       - three consecutive xs (1x3 sized array)
%   funcparms       - LMSobj.AFobj
%
%OUTPUT:
%   out             - LTE value for the given time_step and x value
    h = last_3_ts(1)-last_3_ts(2);
    g1= calg_x_t(last_3_xs(:,1),last_3_ts(1),funcparms);
    g2= calg_x_t(last_3_xs(:,2),last_3_ts(2),funcparms);
    g3= calg_x_t(last_3_xs(:,3),last_3_ts(3),funcparms);
    out = -(1/12)*(g1-2*g2+g3)*h;	
end % of TRAPLTEcontrol
%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%
%% GEAR2
%
% Variable step GEAR2: x_{n+1} = x_n*(h1+h2)^2/(h2*(2*h1+h2)) ...
%			- x_{n-1}*h1^2/(h2*(2*h1+h2)) ...
%			+xdot_{n+1}*h1*(h1+h2)/(2*h1+h2) 
%	where n+1 is the current timepoint, h1=t_{n+1}-t_n, h2=t_n-t_{n-1}
%	reference: page 381, eqn (23) of Schichman's paper of 1970.
%
% or: [rewriting the current timepoint as n]
%
%	x_n - x_{n-1}*(h1+h2)^2/(h2*(2*h1+h2)) + x_{n-2}*h1^2/(h2*(2*h1+h2))
%		= xdot_{n}*h1*(h1+h2)/(2*h1+h2)
%
% or: [multiplying throughout by h2*(2*h1+h2)]
%
% ---> x_n*h2*(2*h1+h2) - x_{n-1}*(h1+h2)^2 + x_{n-2}*h1^2
%		= xdot_{n}*h1*h2*(h1+h2)
%
% Note 1: all coeffs are O(h^2) and O(h^3), so can be very small (10^-20),
%	  but should be OK in floating point.
%
% Note 2: h1 << h2 frequently arises due to timestep control, the above
%	  approximates to: 
%
%	x_n*h2^2 - x_{n-1}*h2^2 + x_{n-2}*h1^2 = xdot_{n}*h1*h2^2
%		(above is what is solved numerically, no matrix conditioning
%		 problems)
%	=> x_n - x_{n-1} + x_{n-2}*(h1/h2)^2 = xdot_{n}*h1
%	which solves roughly to x_n = x_{n-1}
%
% Alphas and betas:
%
% alpha_0 = h2*(2*h1+h2); alpha_1 = -(h1+h2)^2; alpha_2 = h1^2
% beta_0 = h1*h2*(h1+h2); beta_1=beta_2=0.
%
% ===========================
%
% The dependence of alpha values on h1 and h2 may be responsible for
% the quick breakdown into timestep too small. Try expressing each
% coeff in terms of h1 and h2/h1:
%
% GEAR2alphas = h1^2*[(h2/h1)*(2+(h2/h1)), -(1+(h2/h1))^2, 1]; % alpha_0, alpha_1, alpha_2
%                       ^^^^^^ this is the problem - it can go to zero
% some experiments:
%
% firstly: the three alpha terms add to zero? Yes:
%	2*h1*h2 + h2^2 - (h1^2 + h2^2 + 2*h1*h2) + h1^2 = 0
%
% so: divide the entire LMS formula by h2*(2h1+h2) to get:
%
% 	alphas(1) = 1; % coeff on q(xn)
%	alphas(2) = -(h1+h2)^2/h2/(2*h1+h2); % as h1 -> 0, this -> -1
%	alphas(3) = h1^2/h2/(2*h1+h2); % as h1 -> 0, this -> 0
%	
%	this is exactly the right desired behaviour as h1->0
%
%	betas(0) = h1*h2*(h1+h2)/h2/(2*h1+h2) = h1*(h1+h2)/(h1 + h1+h2) 
%		 = h1 || (h1+h2)
%	as h1->0, this -> h1 (which is exactly the desired behaviour)
%

function GEAR2alphas = GEAR2alphasfunc(last_3_ts)
%function GEAR2alphas = GEAR2alphasfunc(last_3_ts)
%This function computes alpha_0, alpha_1 and alpha_2 for the GEAR2-based LMS
%method.
%INPUT args:
%   last_3_ts       - three consecutive times steps (1x3 sized array)
%
%OUTPUT:
%   GEAR2alphas     - [alpha_0, alpha_1, alpha_2] = alphas for the GEAR2-based
%                                                   LMS method 
    h1 = last_3_ts(1)-last_3_ts(2);
    h2 = last_3_ts(2)-last_3_ts(3);
    GEAR2alphas = [h2*(2*h1+h2), -(h1+h2)^2, h1^2]; % alpha_0, alpha_1, alpha_2
    %GEAR2alphas = [1, -(h1+h2)^2/h2/(2*h1+h2), h1^2/h2/(2*h1+h2)]; % NEW alpha_0, alpha_1, alpha_2
end % of GEAR2alphasfunc

function dGEAR2alphas = dGEAR2alphasfunc(last_3_ts)
%function dGEAR2alphas = dGEAR2alphasfunc(last_3_ts)
%This function computes d(alpha_0)/dtn, d(alpha_1)/dtn and d(alpha_2)/dtn for GEAR2
%INPUT args:
%   last_3_ts       - three consecutive times steps (1x3 sized array)
%
%OUTPUT:
%   dGEAR2alphas     - d[alpha_0, alpha_1, alpha_2]/dtn
    h1 = last_3_ts(1)-last_3_ts(2);
    h2 = last_3_ts(2)-last_3_ts(3);
    % GEAR2alphas = [h2*(2*h1+h2), -(h1+h2)^2, h1^2]; % alpha_0, alpha_1, alpha_2
    dGEAR2alphas = [h2*2, -2*(h1+h2), 2*h1];
end % of dGEAR2alphasfunc

function GEAR2betas = GEAR2betasfunc(last_3_ts)
%function GEAR2betas = GEAR2betasfunc(last_3_ts)
%This function computes beta_0, beta_1 and beta_2 for the GEAR2-based LMS method.
%INPUT args:
%   last_3_ts       - three consecutive times steps (1x3 sized array)
%
%OUTPUT:
%   GEAR2betas      - [beta_0, beta_1, beta_2] = betas for the GEAR2-based LMS
%                                                 method 
    h1 = last_3_ts(1)-last_3_ts(2);
    h2 = last_3_ts(2)-last_3_ts(3);
    GEAR2betas = [h1*h2*(h1+h2), 0, 0]; % beta_0, beta_1, beta_2
    %GEAR2betas = [parallel(h1,h1+h2), 0, 0]; % beta_0, beta_1, beta_2
end % of GEAR2betasfunc

function dGEAR2betas = dGEAR2betasfunc(last_3_ts)
%function dGEAR2betas = dGEAR2betasfunc(last_3_ts)
%This function computes d(beta_0)/dtn, d(beta_1)/dtn and d(beta_2)/dtn for GEAR2.
%INPUT args:
%   last_3_ts       - three consecutive times steps (1x3 sized array)
%
%OUTPUT:
%   dGEAR2betas      - d[beta_0, beta_1, beta_2]/dtn = betas for GEAR2
    h1 = last_3_ts(1)-last_3_ts(2);
    h2 = last_3_ts(2)-last_3_ts(3);
    % GEAR2betas = [h1*h2*(h1+h2), 0, 0]; % beta_0, beta_1, beta_2
    dGEAR2betas = [h2*(h1+h2) + h1*h2, 0, 0]; 
end % of dGEAR2betasfunc

function out = GEAR2ddtApproxATtn(last_3_ts, last_3_xs)
%function out = GEAR2ddtApproxATtn(last_3_ts, last_3_xs)
%This function approximates ddt(x) for GEAR2-based LMS method.  It relies on
%the fact that for GEAR, only \beta0 is non-zero and all the other betas are 0.
%INPUT args:
%   last_3_ts       - three consecutive times steps (1x3 sized array)
%   last_3_xs       - three consecutive xs (1x3 sized array)
%
%OUTPUT:
%   out             - ddt(x) approximation
    alphas = GEAR2alphasfunc(last_3_ts);
    betas = GEAR2betasfunc(last_3_ts);
    out = alphas(1)*last_3_xs(:,1) + alphas(2)*last_3_xs(:,2) + alphas(3)*last_3_xs(:,3);
    out = out/betas(1);
end % of GEAR2ddtApproxATtn

function out =  GEAR2LTEcontrol(last_3_ts, last_3_xs, funcparms) 
%function out = GEAR2LTEcontrol(last_3_ts, last_3_xs, funcparms)
%This function computes the LTE value for a given time_step and x value
%INPUT args:
%   last_3_ts       - three consecutive times steps (1x3 sized array)
%   last_3_xs       - three consecutive xs (1x3 sized array)
%   funcparms       - LMSobj.AFobj
%
%OUTPUT:
%   out             - LTE value for the given time_step and x value
    h1 = last_3_ts(1)-last_3_ts(2);
    h2 = last_3_ts(2)-last_3_ts(3);
    g1= calg_x_t(last_3_xs(:,1),last_3_ts(1),funcparms);
    g2= calg_x_t(last_3_xs(:,2),last_3_ts(2),funcparms);
    g3= calg_x_t(last_3_xs(:,3),last_3_ts(3),funcparms);
    out = -(1/6)*(h1+h2)^2/(2*h1+h2)/h2*(h2*g1-(h1+h2)*g2+h1*g3);	
end % of GEAE2LTEcontrol
%
%%%%%%%%%%%%%%%%%%%%%%%%%

% internal function
function out = parallel(R1, R2)
%function out = parallel(R1, R2)
%Given two inputs x1, and x2, this function computes x1*x2/(x1=x2)
    out = R1*R2/(R1+R2);
end % parallel

%%%%%%%%%%%%%%%%%%%%%%    added by jian
% internal function
function out = calg_x_t (x, t, funcparms)
%function out = calg_x_t (x, t, funcparms)
%This function is used to calculate DAE g(x,t)= -(f(x)+B*u(t)) with given x
%and t
%%INPUT args:
%   x               - DAE: value of x
%   t               - DAE: value of t
%   funcparms       - LMSobj.AFobj
%
%OUTPUT:
%   out             - DAE: value of g(x,t)= -(f(x)+B*u(t))
    DAE=funcparms.DAE;
    ninputs = feval(DAE.ninputs, DAE);
    if  ninputs > 0
        u = feval(DAE.utransient, t, DAE);
    else
        u = [];
    end
    if 1 == DAE.f_takes_inputs
        % DAE is d/dt q(x) + f(x, u(t)) = 0
        fbterm = feval(DAE.f, x, u, DAE);
    else
        % DAE is d/dt q(x) + f(x) + B*u(t) = 0
        fbterm = feval(DAE.f, x, DAE);
        if ninputs > 0
            fbterm = fbterm + feval(DAE.B, DAE) * u;
        end
    end
    % g(x,t)= -(f(x)+B*u(t))
    out= - fbterm;
end % of calg_x_t
%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end predefined LMS methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
