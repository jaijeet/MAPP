function MOD = MVS_ModSpec()

	MOD = ee_model();

    MOD = add_to_ee_model (MOD, 'terminals', {'d', 'g', 's', 'b'});
    MOD = add_to_ee_model (MOD, 'explicit_outs', {'idb', 'igb', 'isb'});

    MOD = add_to_ee_model (MOD, 'internal_unks', {'vdib', 'vsib'});

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

    MOD = add_to_ee_model (MOD, 'fe', @fe);
    MOD = add_to_ee_model (MOD, 'qe', @qe);
    MOD = add_to_ee_model (MOD, 'fi', @fi);
    MOD = add_to_ee_model (MOD, 'qi', @qi);

    MOD = finish_ee_model(MOD);

end


function out = fe (S)
	out = fqei(S, 'f', 'e');
end

function out = qe (S)
	out = fqei(S, 'q', 'e');
end

function out = fi (S)
	out = fqei(S, 'f', 'i');
end

function out = qi (S)
	out = fqei(S, 'q', 'i');
end

function out = fqei (S, forq, eori)

    v2struct(S);

	vb  = 0;
	vd  = vdb + vb;
	vg  = vgb + vb;
	vs  = vsb + vb;
	vdi = vdib + vb;
	vsi = vsib + vb;


	if 1 == strcmp(eori,'e') % e
		if 1 == strcmp(forq, 'f') % f
			[iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, S, 0);
			% KCL at d
			out(1,1) = iddi;
			% KCL at g
			out(2,1) = 0;
			% KCL at s
			out(3,1) = -isis;
		else % q
			[iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, S, 1);
			% KCL at g
			out(2,1) = qgb;
			% KCL at d
			out(1,1) = 0;
			% KCL at s
			out(3,1) = 0;
		end % forq
	else % i
		if 1 == strcmp(forq, 'f') % f
			[iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, S, 0);
			% KCL at di
			out(1,1) = idisi - iddi;
			% KCL at si
			out(2,1) = isis - idisi;
		else % q
			[iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, S, 1);
			% KCL at di
			out(1,1) = qdib;
			% KCL at si
			out(2,1) = qsib;
		end
	end
end

%%%%%%%%%%%%%  Internal Functions  %%%%%%%%%%%%%%%%%
%===================================================================================
%			this part is derived from daa_mosfet Verilog-A model
%===================================================================================

function [iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, S, do_Charge)
    
    v2struct(S);

	SMALL_VALUE = 1e-10;
	LARGE_VALUE = 40;
	P_Q = 1.6021918e-19; % from constants.vams
	P_K = 1.3806503e-23; % from constants.vams

	vgsi  = vg - vsi; 	% branch: (g, si)	br_gsi;
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

	Vgsraw  = Type*(vgsi);
	Vgdraw  = Type*(vgdi);
	if (Vgsraw >= Vgdraw)
		Vds = Type*(vds); 
		Vgs = Type*(vgs);
		Vbs = Type*(vbs);
		Vdsi = Type*(vdisi);
		Vgsi = Vgsraw;
		Vbsi = Type*(vbsi);
		dir = 1;
	else
		Vds = Type*(vsd);
		Vgs = Type*(vgd);
		Vbs = Type*(vbd);
		Vdsi = Type*(vsidi);
		Vgsi = Vgdraw;
		Vbsi = Type*(vbdi);
		dir = -1;
	end

    % Parasitic element definition
    Rs = 1e-4/ W * Rs0;                           % s-terminal resistance [ohms]
    Rd = Rs;                                      % d-terminal resistance [ohms] For symmetric source and drain Rd = Rs. 
    % Rd = 1e-4/ W * Rd0;                         % d-terminal resistance [ohms] {Uncomment for asymmetric source and drain resistance.}
    Cofs = ( 0.345e-12/ etov ) * dLg/ 2.0 + Cof;  % s-terminal outer fringing cap [F/cm]
    Cofd = ( 0.345e-12/ etov ) * dLg/ 2.0 + Cof;  % d-terminal outer fringing cap [F/cm]
    Leff = Lgdr - dLg;                            % Effective channel length [cm]. After subtracting overlap lengths on s and d side 
    
    phit = dollar_vt(Tjun);                             % Thermal voltage, kT/q [V]
    me = (9.1e-31) * mc;                          % Carrier mass [Kg]
    n = n0 + nd * Vds;                            % Total subthreshold swing factor taking punchthrough into account [unit-less]
    nphit = n * phit;                             % Product of n and phit [used as one variable]
    aphit = Alpha * phit;                         % Product of Alpha and phit [used as one variable]
    
    % Correct Vgsi and Vbsi
    % Vcorr is computed using external Vbs and Vgs but internal Vdsi, Qinv and Qinv_corr are computed with uncorrected Vgs, Vbs and corrected Vgs, Vbs respectively.    
    Vtpcorr = Vt0 + Gamma * (sqrt(abs(phib - Vbs))- sqrt(phib))- Vdsi * delta; % Calculated from extrinsic Vbs
    eVgpre  = exp(( Vgs - Vtpcorr ) / ( aphit * 1.5 ));                         % Calculated from extrinsic Vgs
    FFpre   = 1.0/ ( 1.0 + eVgpre );                                           % Only used to compute the correction factor
    ab      = 2 * ( 1 - 0.99 * FFpre ) * phit;  
    Vcorr   = ( 1.0 + 2.0 * delta ) * ( ab/ 2.0 ) * ( exp( -Vdsi/ ab ));       % Correction to intrinsic Vgs
    Vgscorr = Vgsi + Vcorr;                                                    % Intrinsic Vgs corrected (to be used for charge and current computation)
    Vbscorr = Vbsi + Vcorr;                                                    % Intrinsic Vgs corrected (to be used for charge and current computation)
    Vt0bs   = Vt0 + Gamma * (sqrt( abs( phib - Vbscorr)) - sqrt( phib ));      % Computed from corrected intrinsic Vbs
    Vt0bs0  = Vt0 + Gamma * (sqrt( abs( phib - Vbsi)) - sqrt( phib ));         % Computed from uncorrected intrinsic Vbs
    Vtp     = Vt0bs - Vdsi * delta - 0.5 * aphit;                              % Computed from corrected intrinsic Vbs and intrinsic Vds
    Vtp0    = Vt0bs0 - Vdsi * delta - 0.5 * aphit;                             % Computed from uncorrected intrinsic Vbs and intrinsic Vds
    eVg     = exp(( Vgscorr - Vtp )/ ( aphit ));                               % Compute eVg factor from corrected intrinsic Vgs
    FF      = 1.0/ ( 1.0 + eVg );
    eVg0    = exp(( Vgsi - Vtp0 )/ ( aphit ));                                 % Compute eVg factor from uncorrected intrinsic Vgs
    FF0     = 1.0/ ( 1.0 + eVg0 );
    Qref    = Cg * nphit;    
    eta     = ( Vgscorr - ( Vt0bs - Vdsi * delta - FF * aphit ))/ ( nphit );   % Compute eta factor from corrected intrinsic Vgs and intrinsic Vds
    eta0    = ( Vgsi - ( Vt0bs0 - Vdsi * delta - FFpre * aphit ))/ ( nphit );  % Compute eta0 factor from uncorrected intrinsic Vgs and internal Vds. 
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
    vx0        = vxo;    
    Vdsats     = vx0 * Leff/ Mu;                            
    Vdsat      = Vdsats * ( 1.0 - FF ) + phit * FF; % Saturation drain voltage for current
    Vdratio    = Vdsi/ Vdsat; %0415 removed abs()
    Vdbeta     = pow( Vdratio, Beta);
    Vdbetabeta = pow( 1.0 + Vdbeta, 1.0/ Beta);
    Fsat       = Vdratio / Vdbetabeta; % Transition function from linear to saturation. 
                                       % Fsat = 1 when Vds>>Vdsat; Fsat= Vds when Vds<<Vdsat

    % Total drain current                                         
    Id = Qinv_corr * vx0 * Fsat * W;        

	if do_Charge
		% Calculation of intrinsic charge partitioning factors (qs and qd)
		Vgt = Qinv/ Cg; % Use charge computed from uncorrected intrinsic Vgs

		% Approximate solution for psis is weak inversion
		if (Gamma == 0)
			a  = 1.0;
			if (eta0 <= LARGE_VALUE)
				psis = phib + phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 ))));
			else 
				psis = phib + phit * ( 1.0 + log( eta0 ));
			end
		else
			if (eta0 <= LARGE_VALUE)
			   psis = phib + ( 1.0 - Gamma )/ ( 1.0 + Gamma ) * phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 ))));
			else
			   psis = phib + ( 1.0 - Gamma )/ ( 1.0 + Gamma ) * phit * ( 1.0 + log( eta0 ));
			end
			a = 1.0 + Gamma/ ( 2.0 * sqrt( abs( psis - ( Vbsi ))));
		end
		Vgta   = Vgt / a; % Vdsat in strong inversion
		Vdsatq = sqrt( FF0 * aphit * aphit + Vgta * Vgta); % Vdsat approx. to extend to weak inversion; 
														   % The Multiplier of phit has strong effect on Cgd discontinuity at Vd=0.

		% Modified Fsat for calculation of charge partitioning
		% DD-NVSAT charge
		Fsatq = Vdsi/ Vdsatq/ ( pow( 1.0 + pow( abs( Vdsi/ Vdsatq ), Beta ), 1.0/ Beta )); %0415 removed abs at beginning
		x     = 1.0 - Fsatq;
		den   = 15 * ( 1 + x ) * ( 1 + x );
		qsc   = Qinv *(6 + 12 * x + 8 * x * x + 4 * x * x * x)/ den;
		qdc   = Qinv *(4 + 8 * x + 12 * x * x + 6 * x * x * x)/ den;
		qi    = qsc + qdc; % Charge in the channel 
		

		% QB charge    
		kq  = 0.0;
		tol = ( SMALL_VALUE * vxo/ 100.0 ) * ( SMALL_VALUE * vxo/ 100.0 ) * me/ ( 2 * P_Q );
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
		if (CTM_select == 1) % Ballistic blended with classic DD-NVSAT
			qs = qsc; % Calculation of "ballistic" channel charge partitioning factors, qsb and qdb.
			qd = qdc; % Here it is assumed that the potential increases parabolically from the
					  % virtual source point, where Qinv_corr is known to Vds-dvd at the drain.
		else % Hence carrier velocity increases linearly by kq (below) depending on the
			qs = qsc * ( 1 - Fsatq * Fsatq ) + qsb * Fsatq * Fsatq; % efecive ballistic mass of the carriers.
			qd = qdc * ( 1 - Fsatq * Fsatq ) + qdb * Fsatq * Fsatq;                
		end                                                
														
									
		% Body charge based on approximate surface potential (psis) calculation with delta=0 using psis=phib in Qb gives continuous Cgs, Cgd, Cdd in SI, while Cdd is smooth anyway.
		Qb = -Type * W * Leff * ( Cg * Gamma * sqrt( abs( psis - Vbsi )) + ( a - 1.0 )/ ( 1.0 * a ) * Qinv * ( 1.0 - qi ));

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
		Qinvs = Type * Leff * (( 1 + dir ) * qs + ( 1 - dir ) * qd)/ 2.0;
		Qinvd = Type * Leff * (( 1 - dir ) * qs + ( 1 + dir ) * qd)/ 2.0;

		% Outer fringing capacitance
		Qsov = Cofs * ( vgsi );
		Qdov = Cofd * ( vgdi );

		% Inner fringing capacitance
		Vt0x = Vt0 + Gamma * ( sqrt( abs( phib - Type * ( vbsi ))) - sqrt(phib));
		Vt0y = Vt0 + Gamma * ( sqrt( abs( phib - Type * ( vbdi ))) - sqrt(phib));
		Fs_arg = ( Vgsraw - ( Vt0x - Vdsi * delta * Fsat ) + aphit * 0.5 )/ ( 1.1 * nphit );
		if (Fs_arg <= LARGE_VALUE)
			Fs  = 1.0 + exp( Fs_arg );
			FFx = Vgsraw - nphit * log( Fs );
		else
			Fs  = 0.0; %    Not used
			FFx = Vgsraw - nphit * Fs_arg;
		end
		Fd_arg = ( Vgdraw - ( Vt0y - Vdsi * delta * Fsat ) + aphit * 0.5 )/ ( 1.1 * nphit );
		if (Fd_arg <= LARGE_VALUE)
			Fd  = 1.0 + exp( Fd_arg );
			FFy = Vgdraw - nphit * log( Fd );
		else
			Fd  = 0.0; %    Not used
			FFy = Vgdraw - nphit * Fd_arg;
		end
		Qsif = Type * ( Cif + CC * Vgsraw ) * FFx;
		Qdif = Type * ( Cif + CC * Vgdraw ) * FFy;
		
		% Partitioned charge
		Qs = -W * ( Qinvs + Qsov + Qsif ); %     s-terminal charge
		Qd = -W * ( Qinvd + Qdov + Qdif ); %     d-terminal charge
		Qg = -( Qs + Qd + Qb );            %     g-terminal charge
	else
		Qs = 0;
		Qd = 0;
		Qg = 0;
	end

	% Contributions
	idisi =  Type*dir*Id;
	iddi =  (vddi)/Rd;
	isis =  (vsis)/Rs;
	qsib = Qs;  
	qdib = Qd;
	qgb = Qg; 
end % daa_mosfet_core_model

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
