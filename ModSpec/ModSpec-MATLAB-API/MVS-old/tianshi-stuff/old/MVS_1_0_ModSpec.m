function MOD = daa_mosfet_VA_ModSpec(uniqID)
%author: Tianshi Wang   2013/09/17

%change log:
%-----------
%2014/05/13: Bichen Wu <bichen@berkeley.edu> Added the function handle of fqei
%            and fqeiJ to reduce redundant calling of f/q functions and to
%            improve efficiency


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
		'version', ...
		'tipe', ...
		'W', ...
		'Lgdr', ...
		'dLg', ...
		'Cg', ...
		'etov', ...
		'delta', ...
		'n0', ...
		'Rs0', ...
		'Rd0', ...
		'Cif', ...
		'Cof', ...
		'vxo', ...
		'parm_mu', ...
		'parm_beta', ...
		'phit', ...
		'phib', ...
		'parm_gamma', ...
		'Vt0', ...
		'parm_alpha', ...
		'mc', ...
		'CTM_select', ...
		'CC', ...
		'nd' ...
	};

	MOD.parm_defaultvals = {...
		1.00, ...
		1, ...
		1e-4, ...
		80e-7, ...
		10.5e-7, ...
		2.2e-6, ...
		1.3e-3, ...
		0.10, ...
		1.5, ...
		100, ...
		100, ...
		1e-12, ...
		2e-13, ...
		0.765e7, ...
		200, ...
		1.7, ...
		0.0256, ...
		1.2, ...
		0.0, ...
		0.486, ...
		3.5, ...
		0.2, ...
		1, ...
		0, ...
		0 ...
	};

	MOD.parm_types = {...
		'real', ...
		'integer', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real', ...
		'real' ...
	};

	MOD.parm_vals = MOD.parm_defaultvals; 
	MOD.explicit_output_names = {'idb', 'igb', 'isb'}; % vecZ
	MOD.internal_unk_names = {'vdib', 'vsib'}; % vecY
	MOD.implicit_equation_names = {...
		'KCL-di', ...
		'KCL-si', ...
	};

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
	MOD.fqeiJ = @fqeiJ;
	MOD.fqei = @fqei_all;

% Newton-Raphson initialization support

% Newton-Raphson limiting support

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % MOD constructor

%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%
%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%
function fiout = fi(vecX, vecY, u, MOD)
	fiout = fqei(vecX, vecY, u, MOD, 'f', 'i');
end % fi(...)

function qiout = qi(vecX, vecY, MOD)
	qiout = fqei(vecX, vecY, [], MOD, 'q', 'i');
end % qi(...)

function feout = fe(vecX, vecY, u, MOD)
	feout = fqei(vecX, vecY, u, MOD, 'f', 'e');
end % fe(...)

function qeout = qe(vecX, vecY, MOD)
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

	vdb = vecX(1); vgb = vecX(2); vsb = vecX(3);
	vdib = vecY(1); vsib = vecY(2);

	vb  = 0;
	vd  = vdb + vb;
	vg  = vgb + vb;
	vs  = vsb + vb;
	vdi = vdib + vb;
	vsi = vsib + vb;

	[iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, MOD);

	if 1 == strcmp(eori,'e') % e
		if 1 == strcmp(forq, 'f') % f
			% KCL at d
			fqout(1,1) = iddi;
			% KCL at g
			fqout(2,1) = 0;
			% KCL at s
			fqout(3,1) = -isis;
		else % q
			% KCL at g
			fqout(2,1) = qgb; % TODO: vecvalder trick...
			% KCL at d
			fqout(1,1) = 0;
			% KCL at s
			fqout(3,1) = 0;
		end % forq
	else % i
		if 1 == strcmp(forq, 'f') % f
			% KCL at di
			fqout(1,1) = idisi - iddi;
			% KCL at si
			fqout(2,1) = isis - idisi;
		else % q
			% KCL at di
			fqout(1,1) = qdib;
			% KCL at si
			fqout(2,1) = qsib;
		end
	end
end % fqei(...)

function [fqei, J] = fqeiJ(vecX, vecY, vecLim, vecU, flag, MOD)
	if flag.J == 0
		[fqei.fe, fqei.qe, fqei.fi, fqei.qi] = fqei_all(vecX, vecY, vecLim, vecU, flag, MOD);
		J = [];
	else
		[fqei J] = dfqei_dvecXYLimU_auto(vecX, vecY, vecLim, vecU, MOD);
	end
end


function [fe, qe, fi, qi] = fqei_all(vecX, vecY, vecLim, u, flag, MOD)

	if ~isfield(flag,'fe')
		flag.fe =0;
	end
	if ~isfield(flag,'qe')
		flag.qe =0;
	end
	if ~isfield(flag,'fi')
		flag.fi =0;
	end
	if ~isfield(flag,'qi')
		flag.qi =0;
	end

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

	vdb = vecX(1); vgb = vecX(2); vsb = vecX(3);
	vdib = vecY(1); vsib = vecY(2);

	vb  = 0;
	vd  = vdb + vb;
	vg  = vgb + vb;
	vs  = vsb + vb;
	vdi = vdib + vb;
	vsi = vsib + vb;

	[iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, MOD);


	if flag.fe == 1
		% KCL at d
		fe(1,1) = iddi;
		% KCL at g
		fe(2,1) = 0;
		% KCL at s
		fe(3,1) = -isis;
	else
		fe = [];
	end

	if flag.qe == 1
		% KCL at g
		qe(2,1) = qgb; % TODO: vecvalder trick...
		% KCL at d
		qe(1,1) = 0;
		% KCL at s
		qe(3,1) = 0;
	else
		qe = [];
	end

	if flag.fi == 1
		% KCL at di
		fi(1,1) = idisi - iddi;
		% KCL at si
		fi(2,1) = isis - idisi;
	else
		fi = [];
	end

	if flag.qi == 1
		% KCL at di
		qi(1,1) = qdib;
		% KCL at si
		qi(2,1) = qsib;
	else
		qi = [];
	end
end % fqei_all



%%%%%%%%%%%%%  Internal Functions  %%%%%%%%%%%%%%%%%
%===================================================================================
%			this part is derived from daa_mosfet Verilog-A model
%===================================================================================

function [iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, MOD)
	smoothing = 1e-5; % TODO: used in smoothabs. where to put it?

	pnames = feval(MOD.parmnames,MOD);
	for i = 1:length(pnames)
		evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
		eval(evalstr);
	end

	SMALL_VALUE = 1e-10;
	LARGE_VALUE = 40;
	P_Q = 1.6021918e-19;

	vgsi =  vg - vsi; 	% branch: (g, si)	br_gsi; %TODO: riscky naming convention, may cause conflictions, has to be checked
	vgdi =  vg - vdi; 	% branch: (g, di) 	br_gdi;
	vgs =   vg - vs;  	% branch: (g, s) 	br_gs;
	vgd =   vg - vd;  	% branch: (g, d) 	br_gd;
	vgb =   vg - vb;  	% branch: (g, b) 	br_gb;
	vdisi = vdi - vsi;	% branch: (di, si) 	br_disi;
	vds =   vd - vs;  	% branch: (d, s)	br_ds;
	vddi =  vd - vdi; 	% branch: (d, di) 	br_ddi;
	vdib =  vdi - vb; 	% branch: (di, b) 	br_dib;
	vbs =   vb - vs;  	% branch: (b, s) 	br_bs;
	vbsi =  vb - vsi; 	% branch: (b, si) 	br_bsi;
	vbd =   vb - vd;  	% branch: (b, d) 	br_bd;
	vbdi =  vb - vdi; 	% branch: (b, di) 	br_bdi;
	vsd =   vs - vd;  	% branch: (s, d) 	br_sd;
	vsidi = vsi - vdi;	% branch: (si, di) 	br_sidi;
	vsis =  vsi - vs; 	% branch: (si, s) 	br_sis;
	vsib =  vsi - vb; 	% branch: (si, b) 	br_sib;

	Vgsraw  = tipe*(vgsi);
	Vgdraw  = tipe*(vgdi);
	if (Vgsraw >= Vgdraw)
		Vds = tipe*(vds); 
		Vgs = tipe*(vgs);
		Vgd = tipe*(vgd);
		Vbs = tipe*(vbs);
		Vdsi = tipe*(vdisi);
		Vgsi = Vgsraw;
		Vgdi = Vgdraw;
		Vbsi = tipe*(vbsi);
		dir = 1;
	else
		Vds = tipe*(vsd);
		Vgs = tipe*(vgd);
		Vgd = tipe*(vgs);
		Vbs = tipe*(vbd);
		Vdsi = tipe*(vsidi);
		Vgsi = Vgdraw;
		Vgdi = Vgsraw;
		Vbsi = tipe*(vbdi);
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
	Qsov  = Cofs*(vgsi);
	Qdov  = Cofd*(vgdi);
	Vt0x  = Vt0+parm_gamma*(sqrt(smoothabs(phib-tipe*(vbsi), smoothing))-sqrt(phib));
	Vt0y  = Vt0+parm_gamma*(sqrt(smoothabs(phib-tipe*(vbdi), smoothing))-sqrt(phib));
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
	idisi =  tipe*dir*Id;
	iddi =  (vddi)/Rd;
	isis =  (vsis)/Rs;
	qsib = Qs;  
	qdib = Qd;
	qgb = Qg; 
end % daa_mosfet_core_model

function out =  pow(a,b)
    out = a^b;
end % pow

