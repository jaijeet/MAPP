function MOD = MVS_1_0_1_ModSpec_wrapper_no_v2struct(uniqID)
%function MOD = MVS_1_0_1_ModSpec_wrapper_no_v2struct(uniqID)
% This function creates a ModSpec model for MIT Virtual Source Nanotransistor
% Model (Silicon) v1.0.1. This is the wrapper version; it should be
% identical in function to MVS_1_0_1_ModSpec.
%
% We do not use v2struct(S) in the code - hopefully this will lead to better
% speed. Instead, we use S.parmname, S.biasname, etc. directly in the code.
%
% The model is implemented based on Verilog-A model released on nanoHUB.org:
% https://nanohub.org/resources/19684
%
% The model is hand-translated from the Verilog-A file into ModSpec Matlab API.
% Also, gmin and init/limiting have been added in it.
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'M1'
%
%Return values:
% - MOD:    a ModSpec object for the MVS model
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'d', 'g', 's', 'b'} (drain, gate, source, bulk).
%
% - parameters:
% - 'version' (MVS model version)
%           default: 1.01
% - 'Type'    (type of transistor. nFET Type=1; pFET Type=-1)
%           default: 1
% - 'W'       (Transistor width [cm])
%           default: 1e-4
% - 'Lgdr'    (Physical gate length [cm])
%           default: 80e-7
% - 'dLg'     (Overlap length including both source and drain sides [cm])  
%           default: 10.5e-7
% - 'Cg'      (Gate-to-channel areal capacitance at the virtual source [F/cm^2])
%           default: 2.2e-6
% - 'etov'    (Equivalent thickness of dielectric at S/D-G overlap [cm])
%           default: 1.3e-3
% - 'delta'   (Drain-induced-barrier-lowering (DIBL) [V/V])
%           default: 0.10
% - 'n0'      (Subthreshold swing factor [unit-less])
%           default: 1.5
% - 'Rs0'     (Access resistance on s-terminal [Ohms-micron])
%           default: 100
% - 'Rd0'     (Access resistance on d-terminal [Ohms-micron])
%           default: 100
% - 'Cif'     (Inner fringing S or D capacitance [F/cm])
%           default: 1e-12
% - 'Cof'     (Outer fringing S or D capacitance [F/cm]) 
%           default: 2e-13
% - 'vxo'     (Virtual source injection velocity [cm/s])
%           default: 0.765e7
% - 'Mu'      (Low-field mobility [cm^2/V.s])
%           default: 200
% - 'Beta'    (Saturation factor. Typ. nFET=1.8, pFET=1.6)
%           default: 1.7
% - 'Tjun'    (Junction temperature [K])
%           default: 298
% - 'phib'    (~abs(2*phif)>0 [V])
%           default: 1.2
% - 'Gamma'   (Body factor  [sqrt(V)])
%           default: 0.0
% - 'Vt0'     (Strong inversion threshold voltage [V])
%           default: 0.486
% - 'Alpha'   (Empirical parameter for threshold voltage shift between strong
%              and weak inversion.)
%           default: 3.5
% - 'mc'      (Choose an appropriate value between 0.01 to 10)
%           default: 0.2
% - 'CTM_select' (If CTM_select = 1, then classic DD-NVSAT model is used)
%           default: 1
% - 'CC'   (Fitting parameter to adjust Vg-dependent inner fringe capacitances)
%           default: 0
% - 'nd'      (Punch-through factor [1/V])
%           default: 0
% - 'gmin'    (minimum conductance between drain and source, convergence aid)
%           default: 1e-12
%
%Examples
%--------
% % adding an MVS NMOS with default parameters to a circuitdata structure
% cktdata = add_element(cktdata, MVS_1_0_1_ModSpec_wrapper(), 'M1', ...
%           {'nD', 'nG', 'nS', 'nB'}, [], {});
%
%See also
%--------
% 
% MVS_1_0_1_ModSpec, add_element, circuitdata[TODO], ModSpec, DAEAPI,
% DAE_concepts
%


	MOD = ee_model();
	MOD = add_to_ee_model (MOD, 'modelname', 'MVS_1_0_1_wrapper_no_v2struct');
	MOD = add_to_ee_model (MOD, 'description', 'DAA/Shaloo''s MVS v1.0.1, translated to ModSpec from Verilog-A; no v2structs used.');

    MOD = add_to_ee_model (MOD, 'terminals', {'d', 'g', 's', 'b'});
    MOD = add_to_ee_model (MOD, 'explicit_outs', {'idb', 'igb', 'isb'});

    MOD = add_to_ee_model (MOD, 'internal_unks', {'vdib', 'vsib'});

    MOD = add_to_ee_model (MOD, 'limited_vars', {'vdiblim', 'vgblim', 'vsiblim'});
	limited_matrix = [0 0 0 1 0
	                  0 1 0 0 0
				      0 0 0 0 1];
    MOD = add_to_ee_model (MOD, 'limited_matrix', limited_matrix);

    MOD = add_to_ee_model (MOD, 'parms', {'version',    1.01});
    MOD = add_to_ee_model (MOD, 'parms', {'Type',       1});
    MOD = add_to_ee_model (MOD, 'parms', {'W',          1e-4});
    MOD = add_to_ee_model (MOD, 'parms', {'Lgdr',       80e-7});
    MOD = add_to_ee_model (MOD, 'parms', {'dLg',        10.5e-7});
    MOD = add_to_ee_model (MOD, 'parms', {'Cg',         2.2e-6});
    MOD = add_to_ee_model (MOD, 'parms', {'etov',       1.3e-3});
    MOD = add_to_ee_model (MOD, 'parms', {'delta',      0.10});
    MOD = add_to_ee_model (MOD, 'parms', {'n0',         1.5});
    MOD = add_to_ee_model (MOD, 'parms', {'Rs0',        100});
    MOD = add_to_ee_model (MOD, 'parms', {'Rd0',        100});
    MOD = add_to_ee_model (MOD, 'parms', {'Cif',        1e-12});
    MOD = add_to_ee_model (MOD, 'parms', {'Cof',        2e-13});
    MOD = add_to_ee_model (MOD, 'parms', {'vxo',        0.765e7});
    MOD = add_to_ee_model (MOD, 'parms', {'Mu',         200});
    MOD = add_to_ee_model (MOD, 'parms', {'Beta',       1.7});
    MOD = add_to_ee_model (MOD, 'parms', {'Tjun',       298});
    MOD = add_to_ee_model (MOD, 'parms', {'phib',       1.2});
    MOD = add_to_ee_model (MOD, 'parms', {'Gamma',      0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'Vt0',        0.486});
    MOD = add_to_ee_model (MOD, 'parms', {'Alpha',      3.5});
    MOD = add_to_ee_model (MOD, 'parms', {'mc',         0.2});
    MOD = add_to_ee_model (MOD, 'parms', {'CTM_select', 1});
    MOD = add_to_ee_model (MOD, 'parms', {'CC',         0});
    MOD = add_to_ee_model (MOD, 'parms', {'nd',         0});
    MOD = add_to_ee_model (MOD, 'parms', {'gmin',   1e-12});

    MOD = add_to_ee_model (MOD, 'fqei_all', @fqei_all);

    MOD = add_to_ee_model (MOD, 'fe', @fe); %tianshi: get rid of these after updating QSS.m
    MOD = add_to_ee_model (MOD, 'qe', @qe);
    MOD = add_to_ee_model (MOD, 'fi', @fi);
    MOD = add_to_ee_model (MOD, 'qi', @qi);

    MOD = add_to_ee_model (MOD, 'initGuess', @initGuess);
    MOD = add_to_ee_model (MOD, 'limiting', @limiting);

    MOD = finish_ee_model(MOD);

end

function out = fe(S)
	out = fqei(S, 'f', 'e');
end

function out = qe(S)
	out = fqei(S, 'q', 'e');
end

function out = fi(S)
	out = fqei(S, 'f', 'i');
end

function out = qi(S)
	out = fqei(S, 'q', 'i');
end

function out = fqei(S, forq, eori)

    %v2struct(S);

	vb  = 0;
	vd  = S.vdb + vb;
	vg  = S.vgblim + vb;
	vs  = S.vsb + vb;
	vdi = S.vdiblim + vb;
	vsi = S.vsiblim + vb;


	if 1 == strcmp(eori,'e') % e
		if 1 == strcmp(forq, 'f') % f
			[iddi, idisi, isis, qgb, qdib, qsib] = mvs_si_1_0_1(vd, vg, vs, vb, vdi, vsi, S, 0);
			% KCL at d
			out(1,1) = iddi;
			% KCL at g
			out(2,1) = 0;
			% KCL at s
			out(3,1) = -isis;
		else % q
			[iddi, idisi, isis, qgb, qdib, qsib] = mvs_si_1_0_1(vd, vg, vs, vb, vdi, vsi, S, 1);
			% KCL at g
			out(2,1) = qgb;
			% KCL at d
			out(1,1) = 0;
			% KCL at s
			out(3,1) = 0;
		end % forq
	else % i
		if 1 == strcmp(forq, 'f') % f
			[iddi, idisi, isis, qgb, qdib, qsib] = mvs_si_1_0_1(vd, vg, vs, vb, vdi, vsi, S, 0);
			idisi = idisi + (vdi - vsi) * S.gmin;
			% KCL at di
			out(1,1) = idisi - iddi;
			% KCL at si
			out(2,1) = isis - idisi;
		else % q
			[iddi, idisi, isis, qgb, qdib, qsib] = mvs_si_1_0_1(vd, vg, vs, vb, vdi, vsi, S, 1);
			% KCL at di
			out(1,1) = qdib;
			% KCL at si
			out(2,1) = qsib;
		end
	end
end

function [fe, qe, fi, qi] = fqei_all(S)
    %v2struct(S);

	vb  = 0;
	vd  = S.vdb + vb;
	vg  = S.vgblim + vb;
	vs  = S.vsb + vb;
	vdi = S.vdiblim + vb;
	vsi = S.vsiblim + vb;

	if 1 == S.flag.qe || 1 == S.flag.qi 
		% do charges
		[iddi, idisi, isis, qgb, qdib, qsib] = mvs_si_1_0_1(vd, vg, vs, vb, vdi, vsi, S, 1);
	else
		[iddi, idisi, isis, qgb, qdib, qsib] = mvs_si_1_0_1(vd, vg, vs, vb, vdi, vsi, S, 0);
	end


	if 1 == S.flag.fe
		% KCL at d
		fe(1,1) = iddi;
		% KCL at g
		fe(2,1) = 0;
		% KCL at s
		fe(3,1) = -isis;
	else
		fe = [];
	end

	if 1 == S.flag.qe
		% KCL at g
		qe(2,1) = qgb;
		% KCL at d
		qe(1,1) = 0;
		% KCL at s
		qe(3,1) = 0;
	else
		qe = [];
	end

	if 1 == S.flag.fi
		idisi = idisi + (vdi - vsi) * S.gmin;
		% KCL at di
		fi(1,1) = idisi - iddi;
		% KCL at si
		fi(2,1) = isis - idisi;
	else
		fi = [];
	end

	if 1 == S.flag.qi
		% KCL at di
		qi(1,1) = qdib;
		% KCL at si
		qi(2,1) = qsib;
	else
		qi = [];
	end
end

%%%%%%%%%%%%%  Internal Functions  %%%%%%%%%%%%%%%%%
%===================================================================================
%			this part is derived from mvs_si_1_0_1 Verilog-A model
%===================================================================================

function [iddi, idisi, isis, qgb, qdib, qsib] = mvs_si_1_0_1(vd, vg, vs, vb, vdi, vsi, S, do_Charge)
    %v2struct(S);

	SMALL_VALUE = 1e-10;
	LARGE_VALUE = 40;
	P_Q = 1.6021918e-19; % from constants.vams
	P_K = 1.3806503e-23; % from constants.vams

	vgsi  = vg - vsi; 	% branch: (g, si)	br_gsi; %TODO: riscky naming convention, may cause conflictions, has to be checked
	vgdi  = vg - vdi; 	% branch: (g, di) 	br_gdi;
	vgs   = vg - vs;  	% branch: (g, s) 	br_gs;
	vgd   = vg - vd;  	% branch: (g, d) 	br_gd;
	vgb   = vg - vb;  	% branch: (g, b) 	br_gb;
	vdisi = vdi - vsi;	% branch: (di, si) 	br_disi;
	vds   = vd - vs;  	% branch: (d, s)	br_ds;
	vddi  = vd - vdi; 	% branch: (d, di) 	br_ddi;
	vdib  = vdi - vb; 	% branch: (di, b) 	br_dib;
	vbs   = vb - vs;  	% branch: (b, s) 	br_bs;
	vbsi  = vb - vsi; 	% branch: (b, si) 	br_bsi;
	vbd   = vb - vd;  	% branch: (b, d) 	br_bd;
	vbdi  = vb - vdi; 	% branch: (b, di) 	br_bdi;
	vsd   = vs - vd;  	% branch: (s, d) 	br_sd;
	vsidi = vsi - vdi;	% branch: (si, di) 	br_sidi;
	vsis  = vsi - vs; 	% branch: (si, s) 	br_sis;
	vsib  = vsi - vb; 	% branch: (si, b) 	br_sib;

	Vgsraw  = S.Type*(vgsi);
	Vgdraw  = S.Type*(vgdi);
	if (Vgsraw >= Vgdraw)
		Vds = S.Type*(vds); 
		Vgs = S.Type*(vgs);
		Vbs = S.Type*(vbs);
		Vdsi = S.Type*(vdisi);
		Vgsi = Vgsraw;
		Vbsi = S.Type*(vbsi);
		dir = 1;
	else
		Vds = S.Type*(vsd);
		Vgs = S.Type*(vgd);
		Vbs = S.Type*(vbd);
		Vdsi = S.Type*(vsidi);
		Vgsi = Vgdraw;
		Vbsi = S.Type*(vbdi);
		dir = -1;
	end

    % Parasitic element definition
    Rs = 1e-4/ S.W * S.Rs0;                           % s-terminal resistance [ohms]
    Rd = Rs;                                      % d-terminal resistance [ohms] For symmetric source and drain Rd = Rs. 
    % Rd = 1e-4/ W * Rd0;                         % d-terminal resistance [ohms] {Uncomment for asymmetric source and drain resistance.}
    Cofs = ( 0.345e-12/ S.etov ) * S.dLg/ 2.0 + S.Cof;  % s-terminal outer fringing cap [F/cm]
    Cofd = ( 0.345e-12/ S.etov ) * S.dLg/ 2.0 + S.Cof;  % d-terminal outer fringing cap [F/cm]
    Leff = S.Lgdr - S.dLg;                            % Effective channel length [cm]. After subtracting overlap lengths on s and d side 
    
    phit = dollar_vt(S.Tjun);                             % Thermal voltage, kT/q [V]
    me = (9.1e-31) * S.mc;                          % Carrier mass [Kg]
    n = S.n0 + S.nd * Vds;                            % Total subthreshold swing factor taking punchthrough into account [unit-less]
    nphit = n * phit;                             % Product of n and phit [used as one variable]
    aphit = S.Alpha * phit;                         % Product of Alpha and phit [used as one variable]
    
    % Correct Vgsi and Vbsi
    % Vcorr is computed using external Vbs and Vgs but internal Vdsi, Qinv and Qinv_corr are computed with uncorrected Vgs, Vbs and corrected Vgs, Vbs respectively.    
    Vtpcorr = S.Vt0 + S.Gamma * (sqrt(abs(S.phib - Vbs))- sqrt(S.phib))- Vdsi * S.delta; % Calculated from extrinsic Vbs
    eVgpre  = exp(( Vgs - Vtpcorr ) / ( aphit * 1.5 ));                        % Calculated from extrinsic Vgs
    FFpre   = 1.0/ ( 1.0 + eVgpre );                                           % Only used to compute the correction factor
    ab      = 2 * ( 1 - 0.99 * FFpre ) * phit;  
    Vcorr   = ( 1.0 + 2.0 * S.delta ) * ( ab/ 2.0 ) * ( exp( -Vdsi/ ab ));     % Correction to intrinsic Vgs
    Vgscorr = Vgsi + Vcorr;                                                    % Intrinsic Vgs corrected (to be used for charge and current computation)
    Vbscorr = Vbsi + Vcorr;                                                    % Intrinsic Vgs corrected (to be used for charge and current computation)
    Vt0bs   = S.Vt0 + S.Gamma * (sqrt( abs(S.phib - Vbscorr)) - sqrt(S.phib)); % Computed from corrected intrinsic Vbs
    Vt0bs0  = S.Vt0 + S.Gamma * (sqrt( abs(S.phib - Vbsi)) - sqrt(S.phib));    % Computed from uncorrected intrinsic Vbs
    Vtp     = Vt0bs - Vdsi * S.delta - 0.5 * aphit;                              % Computed from corrected intrinsic Vbs and intrinsic Vds
    Vtp0    = Vt0bs0 - Vdsi * S.delta - 0.5 * aphit;                             % Computed from uncorrected intrinsic Vbs and intrinsic Vds
    eVg     = exp(( Vgscorr - Vtp )/ ( aphit ));                               % Compute eVg factor from corrected intrinsic Vgs
    FF      = 1.0/ ( 1.0 + eVg );
    eVg0    = exp(( Vgsi - Vtp0 )/ ( aphit ));                                 % Compute eVg factor from uncorrected intrinsic Vgs
    FF0     = 1.0/ ( 1.0 + eVg0 );
    Qref    = S.Cg * nphit;    
    eta     = ( Vgscorr - ( Vt0bs - Vdsi * S.delta - FF * aphit ))/ ( nphit );   % Compute eta factor from corrected intrinsic Vgs and intrinsic Vds
    eta0    = ( Vgsi - ( Vt0bs0 - Vdsi * S.delta - FFpre * aphit ))/ ( nphit );  % Compute eta0 factor from uncorrected intrinsic Vgs and internal Vds. 
                                                                               % Using FF instead of FF0 in eta0 gives smoother capacitances.

    % Charge at VS in saturation (Qinv)
	if (eta  <= LARGE_VALUE)
        Qinv_corr = Qref * log( 1.0 + exp(eta) );
    else
        Qinv_corr = Qref * eta;
    end    
    if (eta0 <= LARGE_VALUE) 
        Qinv = Qref * log( 1.0 + exp(eta0) ); % Compute charge w/ uncorrected intrinsic Vgs for use later on in charge partitioning
	else
        Qinv = Qref * eta0;
    end

    %Transport equations
    vx0        = S.vxo;    
    Vdsats     = vx0 * Leff/S.Mu;                            
    Vdsat      = Vdsats * ( 1.0 - FF ) + phit * FF; % Saturation drain voltage for current
    Vdratio    = abs( Vdsi/ Vdsat);
    Vdbeta     = pow( Vdratio, S.Beta);
    Vdbetabeta = pow( 1.0 + Vdbeta, 1.0/S.Beta);
    Fsat       = Vdratio / Vdbetabeta; % Transition function from linear to saturation. 
                                       % Fsat = 1 when Vds>>Vdsat; Fsat= Vds when Vds<<Vdsat

    % Total drain current                                         
    Id = Qinv_corr * vx0 * Fsat * S.W;        

	if do_Charge
		% Calculation of intrinsic charge partitioning factors (qs and qd)
		Vgt = Qinv/S.Cg; % Use charge computed from uncorrected intrinsic Vgs

		% Approximate solution for psis is weak inversion
		if (S.Gamma == 0)
			a  = 1.0;
			if (eta0 <= LARGE_VALUE)
				psis = S.phib + phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 ))));
			else 
				psis = S.phib + phit * ( 1.0 + log( eta0 ));
			end
		else
			if (eta0 <= LARGE_VALUE)
			   psis = S.phib + ( 1.0 - S.Gamma )/ ( 1.0 + S.Gamma ) * phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 ))));
			else
			   psis = S.phib + ( 1.0 - S.Gamma )/ ( 1.0 + S.Gamma ) * phit * ( 1.0 + log( eta0 ));
			end
			a = 1.0 + S.Gamma/ ( 2.0 * sqrt( abs( psis - ( Vbsi ))));
		end
		Vgta   = Vgt / a; % Vdsat in strong inversion
		Vdsatq = sqrt( FF0 * aphit * aphit + Vgta * Vgta); % Vdsat approx. to extend to weak inversion; 
														   % The Multiplier of phit has strong effect on Cgd discontinuity at Vd=0.

		% Modified Fsat for calculation of charge partitioning
		% DD-NVSAT charge
		Fsatq = abs( Vdsi/ Vdsatq )/(pow( 1.0 + pow( abs( Vdsi/ Vdsatq ), S.Beta ), 1.0/S.Beta ));
		x     = 1.0 - Fsatq;
		den   = 15 * ( 1 + x ) * ( 1 + x );
		qsc   = Qinv *(6 + 12 * x + 8 * x * x + 4 * x * x * x)/ den;
		qdc   = Qinv *(4 + 8 * x + 12 * x * x + 6 * x * x * x)/ den;
		qi    = qsc + qdc; % Charge in the channel 
		

		% QB charge    
		kq  = 0.0;
		tol = ( SMALL_VALUE * S.vxo/ 100.0 ) * ( SMALL_VALUE * S.vxo/ 100.0 ) * me/ ( 2 * P_Q );
		if (Vdsi <= tol)
			kq2 = ( 2.0 * P_Q/ me * Vdsi )/ ( vx0 * vx0 ) * 10000.0;
			kq4 = kq2 * kq2;
			qsb = Qinv * ( 0.5 - kq2/ 24.0 + kq4/ 80.0 );
			qdb = Qinv * ( 0.5 - 0.125 * kq2 + kq4/ 16.0 );
		else
			kq  = sqrt( 2.0 * P_Q/ me * Vdsi )/ vx0 * 100.0;
			kq2 = kq * kq;
			qsb = Qinv * ( asinh( kq )/ kq - ( sqrt( kq2 + 1.0 ) - 1.0 )/ kq2);
			qdb = Qinv * (( sqrt( kq2 + 1.0 )- 1.0 )/ kq2);
		end

		% Flag for classic or ballistic charge partitioning:
		if (S.CTM_select == 1) % Ballistic blended with classic DD-NVSAT
			qs = qsc; % Calculation of "ballistic" channel charge partitioning factors, qsb and qdb.
			qd = qdc; % Here it is assumed that the potential increases parabolically from the
					  % virtual source point, where Qinv_corr is known to Vds-dvd at the drain.
		else % Hence carrier velocity increases linearly by kq (below) depending on the
			qs = qsc * ( 1 - Fsatq * Fsatq ) + qsb * Fsatq * Fsatq; % efecive ballistic mass of the carriers.
			qd = qdc * ( 1 - Fsatq * Fsatq ) + qdb * Fsatq * Fsatq;                
		end                                                
														
									
		% Body charge based on approximate surface potential (psis) calculation with delta=0 using psis=phib in Qb gives continuous Cgs, Cgd, Cdd in SI, while Cdd is smooth anyway.
		Qb = -S.Type * S.W * Leff * ( S.Cg * S.Gamma * sqrt( abs( psis - Vbsi )) + ( a - 1.0 )/ ( 1.0 * a ) * Qinv * ( 1.0 - qi ));

		% DIBL effect on drain charge calculation.
		% Calculate dQinv at virtual source due to DIBL only. Then:Correct the qd factor to reflect this channel charge change due to Vd
		% Vt0bs0 and FF=FF0 causes least discontinuity in Cgs and Cgd but produces a spike in Cdd at Vds=0 (in weak inversion.  But bad in strong inversion)
		etai = ( Vgsi - ( Vt0bs0 - FF * aphit ))/ ( nphit );
		if (etai <= LARGE_VALUE)
			Qinvi = Qref * log( 1.0 + exp( etai ));
		else
			Qinvi = Qref * etai;
		end
		dQinv     = Qinv - Qinvi;
		dibl_corr = ( 1.0 - FF0 ) * ( 1.0 - Fsatq ) * qi * dQinv;
		qd        = qd - dibl_corr;
			 
		% Inversion charge partitioning to terminals s and d
		Qinvs = S.Type * Leff * (( 1 + dir ) * qs + ( 1 - dir ) * qd)/ 2.0;
		Qinvd = S.Type * Leff * (( 1 - dir ) * qs + ( 1 + dir ) * qd)/ 2.0;

		% Outer fringing capacitance
		Qsov = Cofs * ( vgsi );
		Qdov = Cofd * ( vgdi );

		% Inner fringing capacitance
		Vt0x = S.Vt0 + S.Gamma * ( sqrt( abs( S.phib - S.Type * ( vbsi ))) - sqrt(S.phib));
		Vt0y = S.Vt0 + S.Gamma * ( sqrt( abs( S.phib - S.Type * ( vbdi ))) - sqrt(S.phib));
		Fs_arg = ( Vgsraw - ( Vt0x - Vdsi * S.delta * Fsat ) + aphit * 0.5 )/ ( 1.1 * nphit );
		if (Fs_arg <= LARGE_VALUE)
			Fs  = 1.0 + exp( Fs_arg );
			FFx = Vgsraw - nphit * log( Fs );
		else
			Fs  = 0.0; %    Not used
			FFx = Vgsraw - nphit * Fs_arg;
		end
		Fd_arg = ( Vgdraw - ( Vt0y - Vdsi * S.delta * Fsat ) + aphit * 0.5 )/ ( 1.1 * nphit );
		if (Fd_arg <= LARGE_VALUE)
			Fd  = 1.0 + exp( Fd_arg );
			FFy = Vgdraw - nphit * log( Fd );
		else
			Fd  = 0.0; %    Not used
			FFy = Vgdraw - nphit * Fd_arg;
		end
		Qsif = S.Type * ( S.Cif + S.CC * Vgsraw ) * FFx;
		Qdif = S.Type * ( S.Cif + S.CC * Vgdraw ) * FFy;
		
		% Partitioned charge
		Qs = -S.W * ( Qinvs + Qsov + Qsif ); %     s-terminal charge
		Qd = -S.W * ( Qinvd + Qdov + Qdif ); %     d-terminal charge
		Qg = -( Qs + Qd + Qb );            %     g-terminal charge
	else
		Qs = 0;
		Qd = 0;
		Qg = 0;
	end

	% Contributions
	idisi =  S.Type*dir*Id;
	iddi =  (vddi)/Rd;
	isis =  (vsis)/Rs;
	qsib = Qs;  
	qdib = Qd;
	qgb = Qg; 
end % mvs_si_1_0_1

function out =  pow(a,b)
    out = a^b;
end % pow

function out = limexp(x)
	breakpoint = 40;
	maxslope = exp(breakpoint);
	out = exp(x.*(x <= breakpoint)).*(x <= breakpoint) + ...
		(x>breakpoint).*(maxslope + maxslope*(x-breakpoint));
end % limexp

function vt = dollar_vt(T)
	P_Q = 1.6021918e-19; % from constants.vams
	P_K = 1.3806503e-23; % from constants.vams
	vt = T * P_K / P_Q;
end % dollar_vt

function limitedvarout = initGuess(S)

	%v2struct(S);

    limitedvarout(1, 1) = 0;   % vdiblim
    limitedvarout(2, 1) = S.Type * S.Vt0;  % vgblim 
    limitedvarout(3, 1) = -1;  % vsiblim 
end % initGuess

function limitedvarout = limiting(S)

	%v2struct(S);

    % adpated from spice3f5 code in mos10
	vdb = S.vdib;
	vgb = S.vgb;
	vsb = S.vsib;
	vdbold = S.vdiblim;
	vgbold = S.vgblim;
	vsbold = S.vsiblim;

    vgs = vgb - vsb;
    vgd = vgb - vdb;
    vbs = -vsb;
    vbd = -vdb;

    vdsold = vdbold - vsbold;
    vgsold = vgbold - vsbold;
    vgdold = vgbold - vdbold;
    vbsold = -vsbold;
    vbdold = -vdbold;
    % TODO: vcrit is hard-coded here should get them somehow from parms
    vcrit = 0.6145;

    if vdsold >= 0
        vgs = fetlim(vgs, vgsold, S.Type*S.Vt0);
        vds = vgs - vgd;
        vds = limvds(vds, vdsold);
        vgd = vgs - vds;
    else
        vgd = fetlim(vgd, vgdold, S.Type*S.Vt0);
        vds = vgs - vgd;
        vds = -limvds(-vds, -vdsold);
        vgs = vgd + vds;
    end

    if vds >= 0
        vbs = pnjlim(vbsold, vbs, S.Type*S.Vt0, vcrit);
        vbd = vbs - vds;
    else
        vbd = pnjlim(vbdold, vbd, S.Type*S.Vt0, vcrit);
        vbs = vbd + vds;
    end

    limitedvarout(1, 1) = -vbd; % vdb
    limitedvarout(2, 1) = vgs - vbs; % vgb
    limitedvarout(3, 1) = -vbs; % vsb
end % limiting
