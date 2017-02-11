function MOD = MVS_no_int_nodes_ModSpec(uniqID)
% function MOD = MVS_no_int_nodes_ModSpec(uniqID)
% This model MIT Virtual Source (MVS) DOES NOT include source and drain resistances (Rs/Rd) internal to the model
%version number: TBD
%Model authors: Dimitri Antoniadis, Lan Wei, Ujwal Radhakrishna; 
%
% This model includes terminal charges in Nvsat, Vsat and QB/B regimes
% It also includes fringing capacitances
%transport model:  A. Khakifirooz, et al, p. 1674, T-ED 2009.
%charge model: L. Wei, et al, p. 1263, T-ED 2012.
%ModSpec template by: J. Roychowdhury (UCB).
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%How the ModSpec description is set up
%
%This is a 4-terminal model (external d g s b), hence 
%there are 6 IOs (using b as the reference node):
%vdb vgb vsb idb igb isb
%
%ie, n = 3 (recall 2n is the number of IOs)
%
%all three currents (idb igb isb) are explicitly provided in terms of the
%remaining IOs, so we have l==3==n ExplicitOutputs == {'idb', 'ibb', 'isb'}.
%
%Thus, vecZ, representing these ExplicitOutputs, is of size 3. fe and qe, which
%provide the f and q components of vecZ, are therefore of size 3.
%
%The remaining IOs are the OtherIOs == {'vdb', 'vgb', 'vsb'}. This is vecX,
%also of size 3==2n-l.
%
%We don't have any internal nodes or unknowns, hence m==0 and vecY is empty.
%
%The total number of implicit equations should be n+m-l == 0. Hence vecW, and
%fi and qi, are empty.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%

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
	MOD.model_description = 'MVS FET model, v_no_int_nodes_TBD';

	% Note: Rs and Rd have been taken out of parm_{names,defaultvals,types}
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
		 'vxo',    ... % Virtual source velocity [cm/s]
		 'mu',     ... % Mobility [cm^2/V.s]
		 'beta',   ... % Saturation factor. Typ. nFET=1.8, pFET=1.4
		 'phit',   ... % kT/q assuming T=27 C.                      
		 'gamma',  ... % Body factor  [sqrt(V)]
		 'phib',   ... % =abs(2*phin)>0 [V]
		 'smoothing',  ... % smoothing parameter for smoothing funcs
		 'expMaxslope',  ... % max slope for safeexp
		 'alpha',  ... % Empirical parameter for Vt shift from strong to weak inversion
		 'XL',     ... % Gate length offset due to mask/etch effects [cm]
		 'rv',	   ... % Ratio vxo(strong inversion)/vxo(weak inversion). Set rv=1 for constant vxo (zeta irrelevant BUT DO NOT SET TO 0)
		 'zeta',   ... % Parameter determines transtion Vg for vxo
		 'nd', 	   ... % punch-through factor [0-0.4] 
         	 'mc',     ...% Carrier effective mass. (Note that it is used for capacitance calculation only in quasi-ballistic model)
          	'Cif',    ... % Inner fringing S or D capacitance [F/cm]
		 'Cof',    ... % Outer fringing S or D capacitance [F/cm]
		 'etov',    ... % Equivalent thickness of dielectric at S/D-G overlap
		 'CC'     ... % Fitting parameter to adjust Vg-dependent inner fringe capacitance [F/cm]
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
		1.4e7,     ... % vxo: Virtual source velocity [cm/s] (p: 0.85e7)
		250,       ... % mu: Mobility [cm^2/V.s] (p: 140)
		1.8,       ... % beta: Saturation factor. Typ. nFET=1.8, pFET=1.4
		0.0256,    ... % phit: kT/q assuming T=27 C.                     
		0.1,       ... % gamma
		0.9,       ... % phib
		1e-20,     ... % smoothing
		1e50,      ... % expMaxslope
		3.5,  	   ... % Empirical parameter for Vt shift from strong to weak inversion
		0,    	   ... % Gate length offset due to mask/etch effects [cm]
		 1.0,	   ... % Ratio vxo(strong inversion)/vxo(weak inversion). Set rv=1 for constant vxo (zeta irrelevant BUT DO NOT SET TO 0)
		 1.0,	   ... % Parameter determines transtion Vg for vxo
		 0, 	   ... % punch-through factor [0-0.4] 
		100,      ... % Carrier effective mass. (Note that it is used for capacitance calculation only in quasi-ballistic model)
		2.3e-12,   ... % Inner fringing S or D capacitance [F/cm]
		6.4e-13,   ... % Outer fringing S or D capacitance [F/cm]
		0.75e-7,   ... % Equivalent thickness of dielectric at S/D-G overlap
		3e-13     ... % Fitting parameter to adjust Vg-dependent inner fringe capacitance [F/cm]
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
		'double',     ... % vxo: Virtual source velocity [cm/s] (p: 0.85e7)
		'double',       ... % mu: Mobility [cm^2/V.s] (p: 140)
		'double',       ... % beta: Saturation factor. Typ. nFET=1.8, pFET=1.4
		'double',    ... % phit: kT/q assuming T=27 C.                     
		'double',       ... % gamma
		'double',       ... % phib
		'double',     ... % smoothing
		'double',       ... % expMaxslope
		'double',  	   ... % Empirical parameter for Vt shift from strong to weak inversion
		'double',   	   ... % Gate length offset due to mask/etch effects [cm]
		'double',   ... % Ratio vxo(strong inversion)/vxo(weak inversion). Set rv=1 for constant vxo (zeta irrelevant BUT DO NOT SET TO 0)
		'double',   ... % Parameter determines transtion Vg for vxo
		 'double', 	   ... % punch-through factor [0-0.4] 
		'double',   ... % Carrier effective mass. (Note that it is used for capacitance calculation only in quasi-ballistic model)
		 'double',   ... % Inner fringing S or D capacitance [F/cm]
		 'double',   ... % Outer fringing S or D capacitance [F/cm]
		 'double',   ... % Overlap S or D capacitance [F/cm]
		 'double'   ... % Fitting parameter to adjust Vg-dependent inner fringe capacitance [F/cm]
	};

	MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

	MOD.NIL.node_names = {'d', 'g', 's', 'b'};
	MOD.NIL.refnode_name = 'b';
		% IOs will be: vdb, vgb, vsb, idb, igb, isb
	MOD.explicit_output_names = {'idb', 'igb', 'isb'};
	MOD.internal_unk_names = {}; % no internal unknowns vecY
	MOD.implicit_equation_names = {}; % no implicity equations vecW == fi/qi
	MOD.u_names = {};

	% MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
	% MOD.NIL.io_nodenames are set up by this helper function
	MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
	MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
	MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
	MOD.qi = @qi; % qi(vecX, vecY, MOD)
	MOD.qe = @qe; % qe(vecX, vecY, MOD)

% Derivative functions - commented out (vecvalder-based adiff used)
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
	%MOD.initGuess = @initGuess;

% Newton-Raphson limiting support
        %MOD.limiting = @limiting;

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % MVS MOD constructor

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
function [fqout, dfqout] = fqei(vecX, vecY, vecU, MOD, forq, eori)
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
	% there's no vecY for this model, so commented out
	%{
	iunks = feval(MOD.InternalUnkNames, MOD);
	for i = 1:length(iunks)
		evalstr = sprintf('%s = vecY(i);', iunks{i});
		eval(evalstr); % should be OK for vecvalder
	end
	%}
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

	% DAAV6/MVS was written originally using node voltages, not branch voltages
	% re-using that code, so defining node voltages
	vb = 0; % internal reference, arbitrary value
	vd = vdb + vb;
	vg = vgb + vb;
	vs = vsb + vb;
	vdi = vd; % "internal node" is the same as the external node (re-using vdi in code below).
	vsi = vs; % "internal node" is the same as the external node (re-using vsi in code below).

	corevd = typemult*vdi;
	corevg = typemult*vg;
	corevs = typemult*vsi;
	corevb = typemult*vb;

	mparms = feval(MOD.getparms, MOD);

	if 1 == strcmp(eori,'i') % i == implicit equations
		% vecW = [];
		fqout = [];
	else % e == explicit equations
		% vecZ: order is idb igb isb. 
		if 1 == strcmp(forq, 'f') % f
			%	ids is represented as idb = ids and isb = -ids
			%	there is no f() component to the gate current, hence igb = 0.
			idsi = daaV6_core_model_Iy(corevd, corevg, corevs, corevb, mparms);
			% idb
			fqout(1,1) = typemult*idsi;
			% igb 
			fqout(2,1) = 0;
			% isb 
			fqout(3,1) = -typemult*idsi;

		else % q
			[qdi,qg,qsi,qb] = daaV6_core_model_Qs(corevd, corevg, corevs, corevb, mparms);
			% qb not used because it is redundant: qb = (-qdi-qg-qsi)
			% qdb
			fqout(1,1) = typemult*qdi;
			% qgb
			fqout(2,1) = typemult*qg;
			% qsb:
			fqout(3,1) = typemult*qsi;
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
        vxo,  ...
        mu,   ...
        beta, ...
        phit, ...
        gamma,...
        phib, ...
        smoothing, ...
        expMaxslope, ...
	alpha, ...
	XL,   ...
	rv,   ...
	zeta, ...
	nd,   ...
        mc,   ...
        Cif,  ...
        Cof,  ...
	etov,  ...
        CC   ...
	] = deal(mparms{:});

	% tipe is not used here, but applied in ./daaV6_{f,q,df,dq}func.m

	% from Dimitri's NFET_I_V_Q_2
    	Leff=Lg+XL-dLg;
	n0 = S/(2.3*phit);
	me	=	(9.1e-31)*mc;
	qe	=	1.602e-19;
    Qref0=Cg*n0*phit;

    [Vt, Vt0] = VT(W,Ioff,Vgoff,Vdd,S,delta,vxo,Qref0,phit);	

	% from Dimitri's IDC2n_smoothed.m


	% charges are O(fF) = 10^-15, so need to scale smoothing for those
	% smoothabs(0) for charge quantities = sqrt(smoothing*qsmoothingfactor)
	% qsmoothingfactor = 10^-16;
	% but all smoothing seems to be applied to voltage quantities, so
	% there should be no need for this.

        Vgg=smoothmax((Vg-Vx),(Vg-Vy),smoothing); 
        Vbb=smoothmax((Vb-Vx),(Vb-Vy),smoothing);
        Vd=smoothabs(Vy-Vx,smoothing); 		 
        dir=smoothsign(Vy-Vx,smoothing);  
        
        n=n0+nd.*Vd ;
        Qref=Cg*n*phit;

        Vt0b=Vt0+gamma*(safesqrt(phib-Vbb,smoothing)-sqrt(phib));
        

        FF=1./(1+safeexp((Vgg-(Vt0b-Vd.*delta-alpha/2*phit))/(alpha*phit),expMaxslope));
        eta=(Vgg-(Vt0b-Vd.*delta-FF*alpha*phit))./(n*phit);
        Qinv = Qref.*safelog(1+safeexp(eta,expMaxslope),smoothing);
        
        etafv=	(Vgg - (Vt0b-Vd.*delta + 0.5.*zeta.*zeta.*phit))./(zeta.*phit);
	    expetafv = safeexp(etafv,expMaxslope);
	    FFv=	1./(1+expetafv);
        vx0=(FFv./rv + (1-FFv)).*vxo;
        Vdsats=vxo.*Leff./mu;
        Vdsat=Vdsats.*(1-FF)+phit*FF;
        Fsat=(Vd./Vdsat)./((1+(Vd./Vdsat).^beta).^(1/beta));

	% Charge model

	Vgt=Qinv./Cg;
	aa	=1 + 0.5*gamma./safesqrt(phib-Vbb,smoothing);
	Va	=Vgt./aa;
	Vdsatq	=sqrt(9*phit*phit + Va.*Va);				
	Vdratioq=  Vd./Vdsatq;
    Fsatq=Vdratioq./((1+(Vdratioq./Vdsatq).^beta).^(1/beta));	


%charge model #1: for drift/diffusion model with non-saturated drift velocity (NVsat) 
	x	=	1 - Fsatq;
	den	=	15*(1+x).*(1+x);
	qsc	=	(6 + 12.*x + 8.*x.*x + 4.*x.*x.*x)./den;
	qdc	=	(4 + 8.*x + 12.*x.*x + 6.*x.*x.*x)./den;



%charge model # 2: for drift/diffusion model with saturated drift velocity (Vsat)
	Ec	=	vx0./mu;
	beta_vsat=	1.8;
	Vds_smooth=	Vdsatq .* Fsatq;
	capA	=	aa.*Vds_smooth.*Fsatq./(12-6*Fsatq);
	capB	=	(5-2*Fsatq)./(10-5*Fsatq);
	Ap	=	capA .* (1+Vds_smooth./(Leff)./Ec);
	Bp	=	capB .* (Vds_smooth.*Vds_smooth.*aa)./(2*Ec.*(Leff).*(5.*aa.*Vdsatq-2.*Vds_smooth.*aa)+1);  
	qsv0	=	aa.*Vdsatq/2-Vds_smooth/6+Ap.*(1-Bp);
	qdv0	=	aa.*Vdsatq/2-Vds_smooth/3+Ap.*Bp;
	qsv	=	qsv0./aa./Vdsatq;
	qdv	=	qdv0./aa./Vdsatq;

%charge model # 3: for quasi-ballistic/ballistic devices (QB)
	kq	=	sqrt(2*(qe./me).*(Vd+1e-9))./vx0*1e2;   
	kq2	=	kq .* kq;
	%assuming linear potential profile
	denom_qb=	3.*kq2.*kq2;
	sqrtkq2p1=	sqrt(kq2+1);
	qsb_lin	=	((4.*kq2+4).*sqrtkq2p1-6.*kq2-4)./denom_qb;
	qdb_lin	=	((2.*kq2-4).*sqrtkq2p1+4)./denom_qb;

	qsb	=	qsb_lin;
	qdb	=	qdb_lin;


        %charge model selection (for charge partitioning factors -- qs and qd)

	if (mc>99) 
		kFsatq=0;
	
	else
		kFsatq=1;
	end

	if (kFsatq==1) 
		kvsatq=0;
	else
		kvsatq=0; 
	end
	
	Fsatq_mix=Fsat;
	qs	=((1-kvsatq).*qsc+kvsatq.*qsv).*(1-kFsatq.*Fsatq_mix)+qsb.*kFsatq.*Fsatq_mix;
	qd_temp	=((1-kvsatq).*qdc+kvsatq.*qdv).*(1-kFsatq.*Fsatq_mix)+qdb.*kFsatq.*Fsatq_mix;


%drain charge correction due to DIBL

	etai = (Vgg - (Vt0b - FF*alpha*phit))./(n*phit);
	expetai	=safeexp(etai,expMaxslope);	
	logexpetai = safelog((1+expetai),smoothing);
	dQinv_Qinv = 1 - logexpetai./Qinv.*Qref;   
	dqd	=(1-FF).*(1-Fsatq).*(qs+qd_temp).*dQinv_Qinv;
	qd	=	qd_temp - dqd;
	qi	=	qs + qd;


	Qinvs	=	(Leff).*Qinv.*qs;
	Qinvd	=	(Leff).*Qinv.*qd;



%calculation of charges due to parasitic capaciances
%parasitic capacitances are assumed to be between internal (intrinsic) terminals, by using Vgs/Vds and applying ddtQx/Qy to internal terminals.

	Cov	=	(0.345e-12/etov)*dLg/2 + Cof;
	Qovs	=Cov .* Vgg;
	Qovd	=Cov .* (Vgg-Vd);

	sqrtpmvbd=	sqrt(phib-(Vbb-Vd));
	sqrtphib=	sqrt(phib);
	Vt0d	=	Vt0 + gamma.*(sqrtpmvbd-sqrtphib);
	Vthd	=	Vt0d - Vd.*delta;
	Vths	=	Vt0b - Vd*delta;
	etafs_if=	(Vgg - (Vths+0.5*alpha*phit))./(1.1*n*phit);
	etafd_if=	(Vgg-Vd - (Vthd+0.5*alpha*phit))./(1.1*n*phit);
	exp_etafs=	exp(etafs_if);
	exp_etafd=	exp(etafd_if);
	Fs	=	1./(1+exp_etafs);
	Fd	=	1./(1+exp_etafd);

	FFs	=	Vgg - n.*phit.*safelog(Fs,smoothing);
	FFd	=	Vgg-Vd - n.*phit.*safelog(Fd,smoothing);


	Qifs	=	FFs.*(Cif + CC.*Vgg);
	Qifd	=	FFd.*(Cif + CC.*(Vgg-Vd));


% charges associated with (intrinsic) terminals
	Qs	=	-W.*(Qinvs + Qifs + Qovs);
	Qd	=	-W.*(Qinvd + Qifd + Qovd);

	if (1 == docurrents)
            Iy =dir.*W.*Qinv.*vx0.*Fsat;
	else
	    Iy = [];
	end % docurrents
 
	if (1 == docharges)
            Qx=((1+dir).*Qs+(1-dir).*Qd)/2;
            Qy=((1-dir).*Qs+(1+dir).*Qd)/2;

            psis=phib+alpha*phit+phit*safelog(safelog(1+exp(eta),smoothing),smoothing); 
            %psis=phib;  %Alternative approximation if above is troublesome!
            Qb=-W*Cg*Leff*gamma*(safesqrt(psis-Vbb,smoothing) + ...
            	safesqrt(psis-(Vbb-(Vd.*(1-Fsat)+Vdsat.*Fsat)),smoothing))/2;
            Qg=-(Qx+Qy+Qb);
	else
	    Qx = []; Qy = []; Qb = []; Qg = [];
	end % docharges
end
% end of daaV6_core_model
