function MOD = daa_mosfet_VA_ModSpec_auto(uniqID)
%author: Tianshi Wang's VA-ModSpec parser
%	with manual adjustments

% use the common ModSpec skeleton, sets up fields and defaults
	MOD = ModSpec_common_skeleton();

% set up data members defined in ModSpec_common_skeleton. These are
% used by the API functions defined there.

% version, help string: 
	MOD.version = 'daa_mosfet_VA_ModSpec v1.0.0';
	MOD.Usage = help('');

% uniqID
	if nargin < 1
		MOD.uniqID = '';
	else
		MOD.uniqID = uniqID;
	end

	MOD.model_name = 'daa_mosfet';
	MOD.spice_key = 'm';
	MOD.model_description = '';

	MOD.parm_names = {...
		'version', ...		%	MVS model version = 1.0.0
		'tipe', ...			%	type of transistor. nFET tipe=1; pFET tipe=-1
		'W', ...			%	Transistor width [cm]
		'Lgdr', ...			%	Physical gate length [cm].
		'dLg', ...			%	Overlap length including both source and drain sides [cm].
		'Cg', ...			%	Gate-to-channel areal capacitance at the virtual source [F/cm^2]
		'etov', ...			%	Equivalent thickness of dielectric at S/D-G overlap [cm]
		'delta', ...		%	Drain-induced-barrier-lowering (DIBL) [V/V]	
		'n0', ...			%	Subthreshold swing factor [unit-less] {typically between 1.0 and 2.0}
		'Rs0', ...			%	Access resistance on s-terminal [Ohms-micron]
		'Rd0', ...			%	Access resistance on d-terminal [Ohms-micron]
		'Cif', ...			%	Inner fringing S or D capacitance [F/cm]
		'Cof', ...			%	Outer fringing S or D capacitance [F/cm]
		'vxo', ...			%	Virtual source injection velocity [cm/s]
		'parm_mu', ...		%	Low-field mobility [cm^2/V.s]
		'parm_beta', ...	%	Saturation factor. Typ. nFET=1.8, pFET=1.6
		'phit', ...			%	Thermal voltage, kT/q [V]
		'phib', ...			%	~abs(2*phif)>0 [V]
		'parm_gamma', ...	%	Body factor  [sqrt(V)]													  			
		'Vt0', ...			%	Strong inversion threshold voltage [V] 	
		'parm_alpha', ...	%	Empirical parameter associated with threshold voltage shift	between strong and weak inversion.
		'mc', ...			%	Choose an appropriate value between 0.01
		'CTM_select', ...	%	if CTM_select = 1, then classic DD-NVSAT 			
		'CC', ...			%	Fitting parameter to adjust Vg-dependent inner fringe capacitances, CC is not used in this version.
		'nd' ...			%	Punch-through factor [1/V]																			
	};

	MOD.parm_defaultvals = {...
		1.00, ...	 % version
		1, ...		 % tipe
		1e-4, ...	 % W
		80e-7, ...	 % Lgdr
		10.5e-7, ... % dLg
		2.2e-6, ...	 % Cg
		1.3e-3, ...	 % etov
		0.10, ...	 % delta
		1.5, ...	 % n0
		100, ...	 % Rs0
		100, ...	 % Rd0
		1e-12, ...	 % Cif
		2e-13, ...	 % Cof
		0.765e7, ... % vxo
		200, ...	 % parm_mu
		1.7, ...	 % parm_beta
		0.0256, ...	 % phit
		1.2, ...	 % phib
		0.0, ...	 % parm_gamma
		0.486, ...	 % Vt0
		3.5, ...	 % parm_alph
		0.2, ...	 % mc
		1, ...		 % CTM_select
		0, ...		 % CC
		0 ...		 % nd
	};

	MOD.parm_types = {...
		'real', ...		% version
		'integer', ...	% tipe
		'real', ...		% W
		'real', ...		% Lgdr
		'real', ...		% dLg
		'real', ...		% Cg
		'real', ...		% etov
		'real', ...		% delta
		'real', ...		% n0
		'real', ...		% Rs0
		'real', ...		% Rd0
		'real', ...		% Cif
		'real', ...		% Cof
		'real', ...		% vxo
		'real', ...		% parm_mu
		'real', ...		% parm_beta
		'real', ...		% phit
		'real', ...		% phib
		'real', ...		% parm_gamma
		'real', ...		% Vt0
		'real', ...		% parm_alpha
		'real', ...		% mc
		'real', ...		% CTM_select
		'real', ...		% CC
		'real' ...		% nd
	};

	MOD.parm_vals = MOD.parm_defaultvals; 
	MOD.explicit_output_names = {'idb', 'igb', 'isb'}; % vecZ
	MOD.internal_unk_names = {'vdib', 'vsib'}; % vecY
	MOD.implicit_equation_names = {...
		'KCL-di', ...
		'KCL-si', ...
	};

	MOD.limited_var_names = {};
	MOD.vecXY_to_limitedvars_matrix = zeros(0, 5); %TODO

	MOD.u_names = {};

	MOD.NIL.node_names = {'d', 'g', 's', 'b' };
	MOD.NIL.refnode_name = 'b';

	% MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
	% MOD.NIL.io_nodenames are set up by this helper function
	MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
	MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
	MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
	MOD.qi = @qi; % qi(vecX, vecY, MOD)
	MOD.qe = @qe; % qe(vecX, vecY, MOD)

% Newton-Raphson initialization support

% Newton-Raphson limiting support

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % MOD constructor

%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%
%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%
function fiout = fi(vecX, vecY, vecLim, u, MOD)
	fiout = fqei(vecX, vecY, u, MOD, 'f', 'i');
end % fi(...)

function qiout = qi(vecX, vecY, vecLim, MOD)
	qiout = fqei(vecX, vecY, [], MOD, 'q', 'i');
end % qi(...)

function feout = fe(vecX, vecY, vecLim, u, MOD)
	feout = fqei(vecX, vecY, u, MOD, 'f', 'e');
end % fe(...)

function qeout = qe(vecX, vecY, vecLim, MOD)
	qeout = fqei(vecX, vecY, [], MOD, 'q', 'e');
end % qe(...)

function fqout = fqei(vecX, vecY, u, MOD, forq, eori)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	% set up scalar variables for the parms, vecX, vecY and u

	% create variables of the same names as the parameters and assign
	% them the values in MOD.parms
	% ideally, this should be a macro
	%	- could do this using a string and another eval()
	pnames = feval(MOD.parmnames,MOD);
	for i = 1:length(pnames)
		evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
		eval(evalstr);
	end

	% similarly, get values from vecX, named exactly the same as otherIOnames
	% get otherIOs from vecX
	oios = feval(MOD.OtherIONames,MOD);
	for i = 1:length(oios)
		evalstr = sprintf('%s = vecX(i);', oios{i});
		eval(evalstr); % should be OK for vecvalder
	end

	% do the same for vecY from internalUnknowns
	% get internalUnknowns from vecY
	iunks = feval(MOD.InternalUnkNames,MOD);
	for i = 1:length(iunks)
		evalstr = sprintf('%s = vecY(i);', iunks{i});
		eval(evalstr); % should be OK for vecvalder
	end

	% do the same for u from uNames
	unms = feval(MOD.uNames, MOD);
	for i = 1:length(unms)
		evalstr = sprintf('%s = u(i);', unms{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, there are no us

	% end setting up scalar variables for the parms, vecX, vecY and u
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	n = 4;
	m = 17;
	l = 2;
	p = 0;
	vInOutputs = [];
	iInOutputs = [1, 2, 3, 4, 5, 6];
	iInInputs = [];
	vInInputs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
	terminalInNodes = [1, 2, 3];
	refInNodes = [4];
	internalInNodes = [5, 6];
	
	% Node Index
	% 1 : d
	% 2 : g
	% 3 : s
	% 4 : b
	% 5 : di
	% 6 : si

	% Branch Index
	% 1 : br_gsi
	% 2 : br_gdi
	% 3 : br_gs
	% 4 : br_gd
	% 5 : br_gb
	% 6 : br_disi
	% 7 : br_ds
	% 8 : br_ddi
	% 9 : br_dib
	% 10 : br_bs
	% 11 : br_bsi
	% 12 : br_bd
	% 13 : br_bdi
	% 14 : br_sd
	% 15 : br_sidi
	% 16 : br_sis
	% 17 : br_sib


	% Incident Matrix Construction
	InMatrix = zeros(6, 17);
	InMatrix(2, 1) = 1; InMatrix(6, 1) = -1;	% branch: (g, si)	br_gsi;
	InMatrix(2, 2) = 1; InMatrix(5, 2) = -1;	% branch: (g, di)	br_gdi;
	InMatrix(2, 3) = 1; InMatrix(3, 3) = -1;	% branch: (g, s)	br_gs;
	InMatrix(2, 4) = 1; InMatrix(1, 4) = -1;	% branch: (g, d)	br_gd;
	InMatrix(2, 5) = 1; InMatrix(4, 5) = -1;	% branch: (g, b)	br_gb;
	InMatrix(5, 6) = 1; InMatrix(6, 6) = -1;	% branch: (di, si)	br_disi;
	InMatrix(1, 7) = 1; InMatrix(3, 7) = -1;	% branch: (d, s)	br_ds;
	InMatrix(1, 8) = 1; InMatrix(5, 8) = -1;	% branch: (d, di)	br_ddi;
	InMatrix(5, 9) = 1; InMatrix(4, 9) = -1;	% branch: (di, b)	br_dib;
	InMatrix(4, 10) = 1; InMatrix(3, 10) = -1;	% branch: (b, s)	br_bs;
	InMatrix(4, 11) = 1; InMatrix(6, 11) = -1;	% branch: (b, si)	br_bsi;
	InMatrix(4, 12) = 1; InMatrix(1, 12) = -1;	% branch: (b, d)	br_bd;
	InMatrix(4, 13) = 1; InMatrix(5, 13) = -1;	% branch: (b, di)	br_bdi;
	InMatrix(3, 14) = 1; InMatrix(1, 14) = -1;	% branch: (s, d)	br_sd;
	InMatrix(6, 15) = 1; InMatrix(5, 15) = -1;	% branch: (si, di)	br_sidi;
	InMatrix(6, 16) = 1; InMatrix(3, 16) = -1;	% branch: (si, s)	br_sis;
	InMatrix(6, 17) = 1; InMatrix(4, 17) = -1;	% branch: (si, b)	br_sib;


	% Ib = zeros(m, 1);
	Ib = zeros(m, 1) * vecY(1); % TODO: fix vecvalder and remove this
	if 0 ~= p
		Ib(iInInputs) = vecY(l+1:l+p);
	end
	% Vn = zeros(n+l, 1);
	Vn = zeros(n+l, 1) * vecY(1); % TODO: fix vecvalder and remove this
	Vn(terminalInNodes) = vecX;
	Vn(refInNodes) = 0;
	Vn(internalInNodes) = vecY(1:l);
	Vb = InMatrix.' * Vn;

	Outputs = daa_mosfet_core_model(Vb, Ib, MOD);

	% Ib = zeros(m, 1);
	Ib = zeros(m, 1) * vecY(1); % TODO: fix vecvalder and remove this
	Ib(iInOutputs) = Outputs.I;
	if 0 ~= p
		Ib(iInInputs) = vecY(l+1:l+p);
	end

	% Qb = zeros(m, 1);
	Qb = zeros(m, 1) * vecY(1); % TODO: fix vecvalder and remove this
	Qb(iInOutputs) = Outputs.Q;

	if 1 == strcmp(eori,'e') % e
		if 1 == strcmp(forq, 'f') % f
			fqout = InMatrix(terminalInNodes, :) * Ib; 
		else % q
			fqout = InMatrix(terminalInNodes, :) * Qb; 
		end
	else % i
		if 1 == strcmp(forq, 'f') % f
			fqout(1:l, :) = InMatrix(internalInNodes, :) * Ib; 
			if 0 ~= p
				fqout(l+1:l+p, :) = Outputs.V - Vb(vInOutputs); 
			end
		else % q
			fqout(1:l, :) = InMatrix(internalInNodes, :) * Qb; 
			if 0 ~= p
				fqout(l+1:l+p, :) = Outputs.Phi; 
			end
		end
	end
end % fqei(...)

%%%%%%%%%%%%%  Internal Functions  %%%%%%%%%%%%%%%%%
%===================================================================================
%			this part is derived from daa_mosfet Verilog-A model
%===================================================================================

function Outputs = daa_mosfet_core_model(Vb, Ib, MOD)
	smoothing = 1e-5;

	pnames = feval(MOD.parmnames,MOD);
	for i = 1:length(pnames)
		evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
		eval(evalstr);
	end

	SMALL_VALUE = 1e-10;
	LARGE_VALUE = 40;
	P_Q = 1.6021918e-19;

	I = Ib; V = Vb; Q = 0*Ib; Phi = 0*Vb;

	Vgsraw  = tipe*(V(1));
	Vgdraw  = tipe*(V(2));
	if (Vgsraw >= Vgdraw)
		Vds = tipe*(V(7)); 
		Vgs = tipe*(V(3));
		Vgd = tipe*(V(4));
		Vbs = tipe*(V(10));
		Vdsi = tipe*(V(6));
		Vgsi = Vgsraw;
		Vgdi = Vgdraw;
		Vbsi = tipe*(V(11));
		dir = 1;
	else
		Vds = tipe*(V(14));
		Vgs = tipe*(V(4));
		Vgd = tipe*(V(3));
		Vbs = tipe*(V(12));
		Vdsi = tipe*(V(15));
		Vgsi = Vgdraw;
		Vgdi = Vgsraw;
		Vbsi = tipe*(V(13));
		dir = -1;
	end
	Rs = 1e-4/W*Rs0;
	Rd = Rs;
	Cofs = (0.345e-12/etov)*dLg/2.0 + Cof;
	Cofd = (0.345e-12/etov)*dLg/2.0 + Cof;
	Leff = Lgdr-dLg; me = (9.1e-31)*mc;   
	qe = 1.602e-19;
	n  = n0 + nd*Vds;
	nphit = n*phit;
	aphit = parm_alpha*phit;
	Vtpcorr = Vt0+parm_gamma*(sqrt(smoothabs(phib-Vbs, smoothing))-sqrt(phib))-Vdsi*delta; 
	eVgpre = exp((Vgs-Vtpcorr)/(aphit*1.5)); 
	FFpre  = 1.0/(1.0+eVgpre);
	ab  = 2*(1-0.99*FFpre)*phit;  
	Vcorr  = (1.0+2.0*delta)*(ab/2.0)*(exp(-Vdsi/ab)); 
	Vgscorr  = Vgsi+Vcorr; 
	Vbscorr  = Vbsi+Vcorr; 
	Vt0bs  = Vt0+parm_gamma*(sqrt(smoothabs(phib-Vbscorr, smoothing))-sqrt(phib)); 
	Vt0bs0  = Vt0+parm_gamma*(sqrt(smoothabs(phib-Vbsi, smoothing))-sqrt(phib)); 
	Vtp  = Vt0bs-Vdsi*delta-0.5*aphit; 
	Vtp0  = Vt0bs0-Vdsi*delta-0.5*aphit; 
	eVg  = exp((Vgscorr-Vtp)/(aphit)); 
	FF  = 1.0/(1.0+eVg);
	eVg0  = exp((Vgsi-Vtp0)/(aphit)); 
	FF0  = 1.0/(1.0+eVg0);
	Qref  = Cg*nphit; 
	eta  = (Vgscorr-(Vt0bs-Vdsi*delta-FF*aphit))/(nphit); 
	eta0  = (Vgsi-(Vt0bs0-Vdsi*delta-FFpre*aphit))/(nphit);
	if (eta  <= LARGE_VALUE)
		Qinv_corr = Qref * log(1.0 + exp(eta));
	else
		Qinv_corr = Qref*eta;
	end
	if (eta0 <= LARGE_VALUE)
		Qinv  = Qref*log(1.0+exp(eta0));
	else
		Qinv  = Qref*eta0;
	end
	vx0  = vxo; 
	Vdsats  = vx0*Leff/parm_mu;       
	Vdsat  = Vdsats*(1.0-FF) + phit*FF;
	Vdratio  = smoothabs(Vdsi/Vdsat, smoothing);
	Vdbeta  = pow(Vdratio, parm_beta);
	Vdbetabeta = pow(1.0+Vdbeta, 1.0/parm_beta);
	Fsat  = Vdratio / Vdbetabeta;  
	Id  = Qinv_corr*vx0*Fsat*W;
	Vgt  = Qinv/Cg;
	if (parm_gamma == 0)
		a = 1.0;
		if (eta0 <= LARGE_VALUE)
			psis = phib+phit*(1.0+log(log(1.0+SMALL_VALUE+exp(eta0))));
		else
			psis  = phib+phit*(1.0+log(eta0));
		end
	else
		a  = 1.0+parm_gamma/(2.0*sqrt(smoothabs(psis-(Vbsi), smoothing)));
		if (eta0 <= LARGE_VALUE)
			psis  = phib+(1.0-parm_gamma)/(1.0+parm_gamma)*phit*(1.0+log(log(1.0+SMALL_VALUE+exp(eta0))));
		else 
			psis  = phib+(1.0-parm_gamma)/(1.0+parm_gamma)*phit*(1.0+log(eta0));
		end
	end
	Vgta  = Vgt/a; Vdsatq  = sqrt(FF0*aphit*aphit+Vgta*Vgta);
	Fsatq  = smoothabs(Vdsi/Vdsatq, smoothing)/(pow(1.0+pow(smoothabs(Vdsi/Vdsatq, smoothing),parm_beta),1.0/parm_beta));
	x  = 1.0-Fsatq;
	den  = 15*(1+x)*(1+x);
	qsc   = Qinv*(6 + 12*x + 8*x*x + 4*x*x*x)/den;
	qdc  = Qinv*(4 + 8*x + 12*x*x + 6*x*x*x)/den;
	qi  = qsc+qdc;  kq = 0.0;
	tol = (SMALL_VALUE*vxo/100.0)*(SMALL_VALUE*vxo/100.0)*me/(2*P_Q);
	if (Vdsi <= tol)
		kq2 = (2.0*P_Q/me*Vdsi)/(vx0*vx0)*10000.0;
		kq4 = kq2*kq2;
		qsb = Qinv*(0.5-kq2/24.0+kq4/80.0);
		qdb = Qinv*(0.5-0.125*kq2+kq4/16.0);
	else 
		kq = sqrt(2.0*P_Q/me*Vdsi)/vx0*100.0;
		kq2 = kq*kq;
		qsb = Qinv*(asinh(kq)/kq-(sqrt(kq2+1.0)-1.0)/kq2);
		qdb = Qinv*((sqrt(kq2+1.0)-1.0)/kq2);
	end
	if (CTM_select == 1)
		qs = qsc;
		qd = qdc;
	else
		qs = qsc*(1-Fsatq*Fsatq)+qsb*Fsatq*Fsatq;
		qd = qdc*(1-Fsatq*Fsatq)+qdb*Fsatq*Fsatq;
	end
	Qb = -tipe*W*Leff*(Cg*parm_gamma*sqrt(smoothabs(psis-Vbsi, smoothing))+(a-1.0)/(1.0*a)*Qinv*(1.0-qi));
	etai = (Vgsi-(Vt0bs0-FF*aphit))/(nphit);
	if (etai <= LARGE_VALUE)
		Qinvi = Qref*log(1.0+exp(etai));
	else
		Qinvi = Qref*etai;
	end
	dQinv  = Qinv-Qinvi;
	dibl_corr = (1.0-FF0)*(1.0-Fsatq)*qi*dQinv;
	qd  = qd-dibl_corr;
	Qinvs  = tipe*Leff*((1+dir)*qs+(1-dir)*qd)/2.0;
	Qinvd  = tipe*Leff*((1-dir)*qs+(1+dir)*qd)/2.0;
	Qsov  = Cofs*(V(1));
	Qdov  = Cofd*(V(2));
	Vt0x  = Vt0+parm_gamma*(sqrt(smoothabs(phib-tipe*(V(11)), smoothing))-sqrt(phib));
	Vt0y  = Vt0+parm_gamma*(sqrt(smoothabs(phib-tipe*(V(13)), smoothing))-sqrt(phib));
	Fs_arg  = (Vgsraw-(Vt0x-Vdsi*delta*Fsat)+aphit*0.5)/(1.1*nphit);
	if (Fs_arg <= LARGE_VALUE)
		Fs = 1.0+exp(Fs_arg);
		FFx = Vgsraw -nphit*log(Fs);
	else
		Fs = 0.0;  FFx = Vgsraw-nphit*Fs_arg;
	end
	Fd_arg  = (Vgdraw-(Vt0y-Vdsi*delta*Fsat)+aphit*0.5)/(1.1*nphit);
	if (Fd_arg <= LARGE_VALUE)
		Fd = 1.0+exp(Fd_arg);
		FFy = Vgdraw-nphit*log(Fd);
	else
		Fd = 0.0;
		FFy = Vgdraw-nphit*Fd_arg;
	end
	Qsif  = tipe*(Cif+CC*Vgsraw)*FFx;
	Qdif  = tipe*(Cif+CC*Vgdraw)*FFy;
	Qs = -W*(Qinvs+Qsov+Qsif);
	Qd = -W*(Qinvd+Qdov+Qdif);
	Qg = -(Qs+Qd+Qb);
	I(6) =  I(6) +  tipe*dir*Id;
	I(8) =  I(8) +  (V(8))/Rd;
	I(16) =  I(16) +  (V(16))/Rs;
	Q(17)=Q(17)+Qs;  
	Q(9)=Q(9)+Qd;
	Q(5)=Q(5)+Qg; 


	Outputs.I = [I(6), I(8), I(16), I(17), I(9), I(5)];
	Outputs.Q = [Q(6), Q(8), Q(16), Q(17), Q(9), Q(5)];
	Outputs.V = [];
	Outputs.Phi = [];
end % daa_mosfet_core_model

function out =  pow(a,b)
    out = a^b;
end % pow
