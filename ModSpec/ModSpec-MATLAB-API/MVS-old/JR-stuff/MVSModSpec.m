function MOD = DAAV6ModSpec(uniqID)
%function MOD = DAAV6ModSpec(uniqID)
% MIT Virtual Source (VS) model version v0.0.1
%
%Model authors: Dimitri Antoniadis, Lan Wei, Ujwal Radhakrishnan
%
%translated into ModSpec by: J. Roychowdhury.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% use the common ModSpec skeleton, sets up fields and defaults
	MOD = ModSpec_common_skeleton();

% set up data members defined in ModSpec_common_skeleton. These are
% used by the API functions defined there.

% version, help string: 
	MOD.version = 'MVSModSpec';
	MOD.Usage = help('MVSModSpec');
	%

% uniqID
	if nargin < 1
		MOD.uniqID = '';
	else
		MOD.uniqID = uniqID;
	end

	MOD.model_name = 'MVS';
	MOD.spice_key = 'm';
	MOD.model_description = 'MVS FET model, v0.0.1-base';

	MOD.parm_names = {...
		 'tipe',   ... % 'n' or 'p'
		 'W',      ... % Width [cm]
		 'Lg',	   ... % Gate length [cm]
		 'dLg',    ... % dLg=L_g-L_c (default 0.3xLg_nom)
		 'Cg',     ... % Gate cap [F/cm^2]
		 'delta',  ... % DIBL [V/V]
		 'S',      ... % Subthreshold swing [V/decade] OBSOLETE?
		 'Ioff',   ... % Adjusted from Transfer Id-Vg OBSOLETE?
		 'Vdd',    ... % Vd [V] corresponding to Ioff OBSOLETE?
		 'Vgoff',  ... % Vg [V] corresponding to Ioff (typ. 0V) OBSOLETE?
		 'Rs',     ... % Rs [ohm-micron] 
		 'Rd',     ... % Rd [ohm-micron] 
		 'vxo',    ... % Virtual source velocity [cm/s]
		 'mu',     ... % Mobility [cm^2/V.s]
		 'beta',   ... % Saturation factor. Typ. nFET=1.8, pFET=1.4
		 'phit',   ... % kT/q assuming T=27 C.                      
		 'gamma',  ... % Body factor  [sqrt(V)]
		 'phib',   ... % =abs(2*phin)>0 [V]
		 'smoothing',  ... % smoothing parameter for smoothing funcs
		 'expMaxslope'  ... % max slope for safeexp
	};

	MOD.parm_defaultvals = {...
		'n', 	   ... % NFET - can  also be 'p' for PFET
		1.0e-4,    ... % W: Width [cm]
		35e-7,     ... % Lg: Gate length [cm]
		0.3*35e-7, ... % dLg=L_g-L_c (default {0.3,0.25}xLg_nom) {n,p}
		1.83e-6,   ... % Cg: Gate cap [F/cm^2] (p: 1.70e-6)
		0.120,     ... % delta: DIBL [V/V] (p: 0.155)
		0.100,     ... % S: Subthreshold swing [V/decade]
		100e-9,    ... % Ioff: Adjusted from Transfer Id-Vg
		1.2,       ... % Vdd: Vd [V] corresponding to Ioff
		0,         ... % Vgoff: Vg [V] corresponding to Ioff (typ. 0V)
		80,        ... % Rs [ohm-micron] (p: 130)
		80,        ... % Rd [ohm-micron] (assume Rs=Rd) (p: 130)
		1.4e7,     ... % vxo: Virtual source velocity [cm/s] (p: 0.85e7)
		250,       ... % mu: Mobility [cm^2/V.s] (p: 140)
		1.8,       ... % beta: Saturation factor. Typ. nFET=1.8, pFET=1.4
		0.0256,    ... % phit: kT/q assuming T=27 C.                     
		0.1,       ... % gamma
		0.9,       ... % phib
		1e-20,     ... % smoothing
		1e50       ... % expMaxslope
	};

	MOD.parm_types = {...
		'char', 	   ... % NFET - can  also be 'p' for PFET
		'double',    ... % W: Width [cm]
		'double',     ... % Lg: Gate length [cm]
		'double', ... % dLg=L_g-L_c (default {0.3,0.25}xLg_nom) {n,p}
		'double',   ... % Cg: Gate cap [F/cm^2] (p: 1.70e-6)
		'double',     ... % delta: DIBL [V/V] (p: 0.155)
		'double',     ... % S: Subthreshold swing [V/decade]
		'double',    ... % Ioff: Adjusted from Transfer Id-Vg
		'double',       ... % Vdd: Vd [V] corresponding to Ioff
		'double',         ... % Vgoff: Vg [V] corresponding to Ioff (typ. 0V)
		'double',        ... % Rs [ohm-micron] (p: 130)
		'double',        ... % Rd [ohm-micron] (assume Rs=Rd) (p: 130)
		'double',     ... % vxo: Virtual source velocity [cm/s] (p: 0.85e7)
		'double',       ... % mu: Mobility [cm^2/V.s] (p: 140)
		'double',       ... % beta: Saturation factor. Typ. nFET=1.8, pFET=1.4
		'double',    ... % phit: kT/q assuming T=27 C.                     
		'double',       ... % gamma
		'double',       ... % phib
		'double',     ... % smoothing
		'double'       ... % expMaxslope
	};

	MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

	MOD.NIL.node_names = {'d', 'g', 's', 'b'};
	MOD.NIL.refnode_name = 'b';
		% IOs will be: vdb, vgb, vsb, idb, igb, isb
	MOD.explicit_output_names = {'idb', 'igb', 'isb'};
	MOD.internal_unk_names = {'vdi_b', 'vsi_b'};
	MOD.implicit_equation_names = {'di_KCL', 'si_KCL'};
	MOD.u_names = {};

	% MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
	% MOD.NIL.io_nodenames are set up by this helper function
	MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
	MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
	MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
	MOD.qi = @qi; % qi(vecX, vecY, MOD)
	MOD.qe = @qe; % qe(vecX, vecY, MOD)

% Derivative functions
	%If you don't define these, vecvalder-based automatic
	%differentiation will be used -- slow to run, but very convenient.
	%{
	MOD.dfe_dvecX = @dfe_dvecX;
	MOD.dfe_dvecY = @dfe_dvecY;
	MOD.dfe_dvecU = @dfe_dvecU;
	MOD.dqe_dvecX = @dqe_dvecX;
	MOD.dqe_dvecY = @dqe_dvecY;
	MOD.dfi_dvecX = @dfi_dvecX;
	MOD.dfi_dvecY = @dfi_dvecY;
	MOD.dfi_dvecU = @dfi_dvecU;
	MOD.dqi_dvecX = @dqi_dvecX;
	MOD.dqi_dvecY = @dqi_dvecY;
	%}

% Newtos-Raphson initialization support
	% MOD.initGuess = @initGuess; 

% Newton-Raphson limiting support
        % MOD.limiting = @limiting;

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % DAAV6 MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fiout = fi(vecX, vecY, vecU, MOD)
	fiout = fqei(vecX, vecY, vecU, MOD, 'f', 'i');
end % fi(...)

function qiout = qi(vecX, vecY, MOD)
	qiout = fqei(vecX, vecY, [], MOD, 'q', 'i');
end % qi(...)

function feout = fe(vecX, vecY, vecU, MOD)
	feout = fqei(vecX, vecY, vecU, MOD, 'f', 'e');
end % fe(...)

function qeout = qe(vecX, vecY, MOD)
	qeout = fqei(vecX, vecY, [], MOD, 'q', 'e');
end % qe(...)




%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% ANALYSIS-SPECIFIC INPUT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% EQN and UNK SCALING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MODSPEC API %%%%%%%%%%%%%%%%%%%%%%%%
function fqout = fqei(vecX, vecY, vecU, MOD, forq, eori)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% set up scalar variables for the parms, vecX, vecY and vecU 

	% create variables of the same names as the parameters and assign
	% them the values in MOD.parms
	% ideally, this should be a macro
	% 	- could do this using a string and another eval()
	pnames = feval(MOD.parmnames, MOD);
	for i = 1:length(pnames)
		evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
		eval(evalstr);
	end

	% similarly, get values from vecX, named exactly the same as otherIOnames
	% get otherIOs from vecX
	oios = feval(MOD.OtherIONames, MOD);
	for i = 1:length(oios)
		evalstr = sprintf('%s = vecX(i);', oios{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, this should set up: vdb = vecX(1), vgb = vecX(2), vsb = vecX(3)

	% do the same for vecY from internalUnknowns
	% get internalUnknowns from vecY
	iunks = feval(MOD.InternalUnkNames, MOD);
	for i = 1:length(iunks)
		evalstr = sprintf('%s = vecY(i);', iunks{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, this should set up: vdi_b = vecY(1), vsi_b = vecY(2)

	%{
	% do the same for u from uNames
	unms = uNames(MOD);
	for i = 1:length(unms)
		evalstr = sprintf('%s = vecU(i);', unms{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, there are no us
	%}

	% end setting up scalar variables for the parms, vecX, vecY and u
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	typemult = (tipe == 'n')*2 - 1;  % 1 if n-type device, -1 if p-type

	% DAAV6 was written originally using node voltages, not branch voltages
	% re-using that code, so defining node voltages
	vb = 0; % internal reference, arbitrary value
	vd = vdb + vb;
	vg = vgb + vb;
	vs = vsb + vb;
	vdi = vdi_b + vb;
	vsi = vsi_b + vb;

	corevd = typemult*vdi;
	corevg = typemult*vg;
	corevs = typemult*vsi;
	corevb = typemult*vb;

	mparms = feval(MOD.getparms, MOD);

	if 1 == strcmp(eori,'e') % e
		if 1 == strcmp(forq, 'f') % f
			ig = 0; 
			% idb (vd - vdi)/Rd
			fqout(1,1) = (vd - vdi)/Rd;
			% igb
			fqout(2,1) = typemult*ig;
			% isb (vs - vsi)/Rs
			fqout(3,1) = (vs - vsi)/Rs;
		else % q
			[qdi,qg,qsi,qb] = daaV6_core_model_Qs(corevd, corevg, corevs, corevb, mparms);
			% qb not used because it is redundant: qb = (-qdi-qg-qsi)
			% idb 
			fqout(1,1) = 0*qg; % no d/dt term in idb contribution
			% igb
			fqout(2,1) = typemult*qg;
			% isb
			fqout(3,1) = 0*qg;  % no d/dt term in isb contribution
		end % forq
	else % i
		if 1 == strcmp(forq, 'f') % f
			ig = 0;
			ib = 0; 
			idsi = daaV6_core_model_Iy(corevd, corevg, corevs, corevb, mparms);
			% di_KCL: (vdi - vd)/Rd + idsi
			fqout(1,1) = (vdi-vd)/Rd + typemult*idsi;
			% si_KCL: (vsi - vs)/Rs - idsi - ig - ib
			fqout(2,1) = (vsi-vs)/Rs - typemult*(idsi+ig+ib);

		else % q
			[qdi,qg,qsi,qb] = daaV6_core_model_Qs(corevd, corevg, corevs, corevb, mparms);
			% qb not used because it is redundant: qb = (-qdi-qg-qsi)
			% di_KCL: d/dt terms
			fqout(1,1) = typemult*qdi;
			% si_KQL: d/dt terms
			fqout(2,1) = typemult*qsi;

		end
	end
end % fqei(...)

function [Vt, Vt0] = VT(W,Ioff,Vgoff,Vdd,S,delta,vxo,Qref,phit)
% this function is copied exactly from Dimitri's file VT.m
% Author: Dimitri Antoniadis <daa@mtl.mit.edu> - circa December 2008
% Calculate Vt(Vd=Vdd)from Ioff at Vg=Vgoff and Vd=Vdd.
% Then calculate Vt0=Vt(Vd=0) by accounting for DIBL.
% The Vdd value must be larger than ~3*phit.
% It is assumed that Vgoff is in the weak inversion
	Vt = Vgoff + S./2.3.*log((W*vxo .* Qref)./Ioff);
	dVt=1;
	alpha=3.5;
	% note: involves a loop, below
	while abs(dVt./Vt)>1e-3
	    FF=1./(1+exp((Vgoff-(Vt-alpha/2*phit))/(alpha*phit)));
	    Vtx=Vgoff+FF*alpha*phit-S/2.3.*log(exp(Ioff./(W*vxo*Qref))-1);
	    dVt=Vtx-Vt;
	    Vt=Vtx;
	end 
	Vt0=Vt+Vdd.*delta;
end
% end of VT

function idsi = daaV6_core_model_Iy(Vy, Vg, Vx, Vb, mparms)
	docharges = 0;
	docurrents = 1;
	[idsi,dummy1,dummy2,dummy3,dummy4] = daaV6_core_model(Vy,Vg,Vx,Vb,...
		mparms, docurrents, docharges);
end
% end of daaV6_core_model_Iy

function [qdi, qg, qsi, qb] = daaV6_core_model_Qs(Vy, Vg, Vx, Vb, mparms)
	docharges = 1;
	docurrents = 0;
	[dummy, qdi, qg, qsi, qb] = daaV6_core_model(Vy,Vg,Vx,Vb,mparms,...
		docurrents, docharges);
end
% end of daaV6_core_model_Qs

function [Iy, Qy, Qg, Qx, Qb] = daaV6_core_model(Vy, Vg, Vx, Vb, mparms, docurrents, docharges)
	% order of mparms is specified in the API file daaV6.py
	[     ...
	type, ...
        W,    ...
        Lg,   ...
        dLg,  ...
        Cg,   ...
        delta,...
        S,    ...
        Ioff, ...
        Vdd,  ...
        Vgoff,...
        Rs,   ...
        Rd,   ...
        vxo,  ...
        mu,   ...
        beta, ...
        phit, ...
	gamma,...
	phib, ...
	smoothing, ...
	expMaxslope ...
	] = deal(mparms{:});

	% tipe is not used here, but applied in ./daaV6_{f,q,df,dq}func.m

	% from Dimitri's NFET_I_V_Q_2
	n = S/(2.3*phit);
	Qref=Cg*n*phit;
	[Vt, Vt0] = VT(W,Ioff,Vgoff,Vdd,S,delta,vxo,Qref,phit);

	% from Dimitri's IDC2n_smoothed.m
	alpha = 3.5;

	% charges are O(fF) = 10^-15, so need to scale smoothing for those
	% smoothabs(0) for charge quantities = sqrt(smoothing*qsmoothingfactor)
	% qsmoothingfactor = 10^-16;
	% but all smoothing seems to be applied to voltage quantities, so
	% there should be no need for this.

        Vgg=smoothmax((Vg-Vx),(Vg-Vy),smoothing); 
        Vbb=smoothmax((Vb-Vx),(Vb-Vy),smoothing);
        Vd=smoothabs(Vy-Vx,smoothing); 		 
        dir=smoothsign(Vy-Vx,smoothing);        
        Vt0b=Vt0+gamma*(safesqrt(phib-Vbb,smoothing)-sqrt(phib));

        FF=1./(1+safeexp((Vgg-(Vt0b-Vd.*delta-alpha/2*phit))/(alpha*phit),expMaxslope));
        eta=(Vgg-(Vt0b-Vd.*delta-FF*alpha*phit))./(n*phit);
        Qinv = Qref.*safelog(1+safeexp(eta,expMaxslope),smoothing);
        Vdsats=vxo.*(Lg-dLg)./mu;
        Vdsat=Vdsats.*(1-FF)+phit*FF;
        Fsat=(Vd./Vdsat)./((1+(Vd./Vdsat).^beta).^(1/beta));

	if (1 == docurrents)
            Iy =dir.*W.*Qinv.*vxo.*Fsat;
	else
	    Iy = [];
	end % docurrents
 
	if (1 == docharges)
            Qx=-W*(Lg-dLg)*Qinv.*((1+dir)+(1-dir).*(1-Fsat))/4;
            Qy=-W*(Lg-dLg)*Qinv.*((1-dir)+(1+dir).*(1-Fsat))/4;

            psis=phib+alpha*phit+phit*safelog(safelog(1+exp(eta),smoothing),smoothing); 
            %psis=phib;  %Alternative approximation if above is troublesome!
            Qb=-W*Cg*Lg*gamma*(safesqrt(psis-Vbb,smoothing) + ...
            	safesqrt(psis-(Vbb-(Vd.*(1-Fsat)+Vdsat.*Fsat)),smoothing))/2;
            Qg=-(Qx+Qy+Qb);
	else
	    Qx = []; Qy = []; Qb = []; Qg = [];
	end % docharges
end
% end of daaV6_core_model

%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
