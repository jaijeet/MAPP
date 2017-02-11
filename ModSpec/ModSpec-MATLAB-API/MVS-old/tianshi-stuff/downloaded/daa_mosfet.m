function [Idlog,Id,Qs,Qd,Qg,Qb,Vdsi_out]=daa_mosfet(coeff,bias_data)
% Symmetrical Short-Channel MOSFET model (VERSION=1.0.0)

% Returns the log of drain current, Id [A] and partitioned charges
% This model is only valid for Vg >~ Vg(psis=phif) where psis is the surface
% potential.  I.e range of validity is from onset of weak inversion trhough
% strong inversion.

% Original Dimitri Antoniadis, MIT, 09/17/10
% Modified, DAA 10/20/12
% Modified, DAA 07/01/13
% Modified SR 07/24/13 

version = 1.00; % version number

%fitted coefficients
Rs0=coeff(1);       % Access region resistance for s terminal [Ohms-micron]
Rd0=Rs0;            % Access region resistance for d terminal [Ohms-micron] {Generally Rs0=Rd0 for symmetric source and drain}
delta=coeff(3);     % Drain induced barrier lowering (DIBL) [V/V]
n0=coeff(4);        % Subthreshold swing factor [unit-less] {typically between 1.0 and 2.0}
nd = coeff(5);      % Punch-through factor [1/V]
vxo = coeff(6)*1e7; % Virtual-source injection velocity [cm/s]
mu = coeff(7);      % low field mobility [cm^2/Vs]
Vt0 = coeff(8);     % Threshold voltage [V]

%% input parameters known and not fitted.
global input_parms;

tipe=input_parms(1);    % type of transistor. nFET tipe=1; pFET tipe=-1
W=input_parms(2);       % Transistor width [cm]
Lgdr=input_parms(3);    % Physical gate length [cm]. This is the designed gate length for litho printing.
dLg = input_parms(4);   % Overlap length including both source and drain sides [cm].
parm_gamma=input_parms(5);   % Body-factor [sqrt(V)]
phib = input_parms(6);  % ~2*phif [V]
Cg = input_parms(7);    % Gate-to-channel areal capacitance at the virtual source [F/cm^2]
Cif = input_parms(8);   % Inner-fringing capacitance [F/cm]
Cof = input_parms(9);   % Outer-fringing capacitance [F/cm]
etov = input_parms(10); % Equivalent thickness of dielectric at S/D-G overlap [cm]
mc=input_parms(11);     % Effective mass of carriers relative to m0 [unitless]
phit=input_parms(12);   % Thermal voltage = kT/q [V]
parm_beta=input_parms(13);   % Saturation factor. Typ. nFET=1.8, pFET=1.6
parm_alpha=input_parms(14);  % Empirical parameter associated with threshold voltage shift between strong and weak inversion.
CTM_select=input_parms(15); % Parameter to select charge-transport model 
                            % if CTM_select = 1, then classic DD-NVSAT
                            % model is used; for CTM_select other than
                            % 1,blended DD-NVSAT and ballistic charge
                            % transport model is used.
                            

CC = 0 ;                % Fitting parameter to adjust Vg-dependent inner fringe capacitances {not used in this version.}

me=9.1e-31*mc;          % Effective mass [Kg] invoked for ballistic charges
qe=1.602e-19;           % Elementary charge [Col.]

Cofs=(0.345e-12/etov)*dLg/2 + Cof;  % s-terminal outer fringing cap [F/cm]
Cofd=(0.345e-12/etov)*dLg/2 + Cof;  % d-terminal outer fringing cap [F/cm]
Leff = Lgdr-dLg;                    % Effective channel length [cm]
%%%%% ####### model file begins
% Direction of current flow:
% dir=+1 when "x" terminal is the source
% dir=-1 when "y" terminal is the source |

%% bias values
Vd_pre= bias_data(1);
Vg_pre= bias_data(2);
Vb_pre=bias_data(3);
Vs_pre=bias_data(4);

smoothing = 1e-5;

for len_bias=1:length(Vd_pre)
    Vd=Vd_pre(len_bias);
    Vg=Vg_pre(len_bias);
    Vb=Vb_pre(len_bias);
    Vs=Vs_pre(len_bias);
    dir=tipe*smoothsign(Vd-Vs, smoothing);
    
    Vds=smoothabs(Vd-Vs, smoothing);
    Vgs=smoothmax(tipe*(Vg-Vs),tipe*(Vg-Vd), smoothing);
    Vbs=smoothmax(tipe*(Vb-Vs),tipe*(Vb-Vd), smoothing);
    
    Vt0bs=Vt0+parm_gamma*(sqrt(smoothabs(phib-Vbs, smoothing))-sqrt(phib));
    
    % Denormalize access resistances and allocate them the "source" and
    % drain according to current flow
    Rs=1e-4/W*(Rs0*(1+dir)+Rd0*(1-dir))/2;
    Rd=1e-4/W*(Rd0*(1+dir)+Rs0*(1-dir))/2;
    
    n=n0+nd*Vds;
    aphit = parm_alpha*phit;
    nphit = n*phit;
    Qref=Cg*nphit;
    
    %%% Initial values for current calculation %%%%%%%%%%%%%%%%%%%%
    FF=1./(1+exp((Vgs-(Vt0bs-Vds.*delta-0.5*aphit))/(aphit)));
    Qinv_corr = Qref.*log(1+exp((Vgs-(Vt0bs-Vds.*delta-FF*aphit))./(nphit)));
    Qinv = Qref.*log(1+exp((Vgs-Vt0bs)./(nphit)));
    Rt=Rs + Rd + (Lgdr-dLg)./(W*Qinv*mu);
    vx0=vxo;
    Vdsats=W*Qinv.*vx0.*Rt;
    Vdsat=Vdsats.*(1-exp(-Qinv./Qref))+phit*exp(-Qinv./Qref);
    Fsat=(1-exp(-2*Vds./Vdsat))./(1+exp(-2*Vds./Vdsat));
    Idx = W*Fsat.*Qinv_corr.*vx0;
    Idxx=1e-15;
    dvg=Idx.*Rs;
    dvd=Idx.*Rd;
    count=1;
    
    %%% Current calculation loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	oof = smoothabs(Idx-Idxx, smoothing)./Idx;
    while smoothmax(oof(1), oof(1), smoothing)>1e-10;
        count=count+1;
        if count>500, break, end
        Idxx=Idx;
        dvg=(Idx.*Rs+dvg)/2;
        dvd=(Idx.*Rd+dvd)/2;
        dvds=dvg+dvd; % total drop from source to drain
        
        Vdsi=Vds-dvds;
        Vgsi=Vgs-dvg;
        Vbsi=Vbs-dvg;
        
        Vsint=Vs+Idx.*(Rs0*1e-4/W)*dir;
        Vdint=Vd-Idx.*(Rd0*1e-4/W)*dir;
        Vgsraw=tipe*(Vg-Vsint);
        Vgdraw=tipe*(Vg-Vdint);
        
        
        % correct Vgsi and Vbsi
        % Vcorr is computed using external Vbs and Vgs but internal Vdsi
        % Qinv and Qinv_corr are computed with uncorrected Vgs, Vbs and
        % corrected Vgs, Vbs respectively.
        Vtpcorr=Vt0+parm_gamma.*(sqrt(phib-Vbs)-sqrt(phib))-Vdsi.*delta;
        eVgpre = exp((Vgs-Vtpcorr)/(parm_alpha*phit*1.5));
        FFpre = 1./(1+eVgpre);
        ab=2*(1-0.99*FFpre).*phit;
        Vcorr=(1+2.0*delta)*(ab./2.0).*(exp((-Vdsi)./(ab)));
        Vgscorr=Vgs+Vcorr-dvg;
        Vbscorr=Vbs+Vcorr-dvg;
        %
        
        Vt0bs=Vt0+parm_gamma.*(sqrt(phib-Vbscorr)-sqrt(phib));
        Vt0bs0=Vt0+parm_gamma.*(sqrt(phib-Vbsi)-sqrt(phib));
        
        Vtp=Vt0bs-Vdsi.*delta-0.5*aphit;
        Vtp0=Vt0bs0-Vdsi.*delta-0.5*aphit;
        
        eVg=exp((Vgscorr-Vtp)/(aphit));
        FF=1./(1+eVg);
        eVg0=exp((Vgsi-Vtp0)/(aphit));
        FF0=1./(1+eVg0);
        
        n=n0+smoothabs(nd*Vdsi, smoothing);
        nphit = n*phit;
        Qref=Cg*nphit;
        eta=(Vgscorr-(Vt0bs-Vdsi.*delta-FF*aphit))./(nphit);
        Qinv_corr = Qref.*log(1+exp(eta));
        eta0=(Vgsi-(Vt0bs0-Vdsi.*delta-FFpre*aphit))./(nphit); % compute eta0 factor from uncorrected intrinsic Vgs and internal Vds.
        %FF instead of FF0gives smoother C's!
        Qinv = Qref.*log(1+exp(eta0));
        
        vx0=vxo;
        Vdsats=vx0.*Leff./mu;
        Vdsat=Vdsats.*(1-FF)+ phit*FF;
        Fsat=(smoothabs(Vdsi, smoothing)./Vdsat)./((1+(smoothabs(Vdsi, smoothing)./Vdsat).^parm_beta).^(1./parm_beta));
        v=vx0.*Fsat;
        Idx = (W.*Qinv_corr.*v + 1*Idxx)/2;
    end
    %%% Current, positive into terminal y  %%%%%%%%%%%%%%%%%%%%%%%%
    Id(len_bias,1)=tipe*dir.*Idx; % in A
    Idlog(len_bias,1)=log10(Id(len_bias,1));
    Vdsi_out(len_bias,1) = Vdsi;
    
    
    % BEGIN CHARGE MODEL
    Vgt=Qinv./Cg;
    
    %Approximate solution for psis is weak inversion
    psis=phib+(1-parm_gamma)/(1+parm_gamma)*phit.*(1+log(log(1+exp((eta0)))));
    a=1+parm_gamma./(2*sqrt(psis-(Vbsi))); % body factor
    Vgta=Vgt./a;   % Vdsat in strong inversion
    Vdsatq=sqrt(FF0.*(parm_alpha*phit).^2+(Vgta).^2);  % Vdsat approx. to extend to weak inversion;
    % The multiplier of phit has strong effect on Cgd discontinuity at Vds=0.
    
    %Modified Fsat for calculation of charge partitioning (DD-NVSAT)
    Fsatq=(smoothabs(Vdsi, smoothing)./Vdsatq)./((1+(smoothabs(Vdsi, smoothing)./Vdsatq).^parm_beta).^(1./parm_beta));
    x=1-Fsatq;
    den=15*(1+x).^2;
    qsc=Qinv*(6+12*x+8*x.^2+4*x.^3)./den;
    qdc=Qinv*(4+8*x+12*x.^2+6*x.^3)./den;
    qi=qsc+qdc;
    
    % Calculation of "ballistic" channel charge partitioning factors, qsb and qdb.
    % Here it is assumed that the potential increases parabolically from the
    % virtual source point, where Qinv_corr is known to Vds-dvd at the drain.
    % Hence carrier velocity increases linearly by kq (below) depending on the
    % efecive ballistic mass of the carriers.
    
    if (Vds < 1e-3)
        kq2=2.*qe/me*(Vdsi)/(vx0*vx0)*1e4;
        kq4=kq2.*kq2;
        qsb=Qinv*(0.5 - kq2/24.0 + kq4/80.0);
        qdb=Qinv*(0.5 - 0.125*kq2 + kq4/16.0);
    else
        kq=sqrt(2.*qe./me.*(Vdsi))./vxo.*1e2;  % 1e2 to convert cm/s to m/s. kq is unitless
        kq2=kq.^2;
        qsb=Qinv*(asinh(sqrt(kq2))./sqrt(kq2)-(sqrt(kq2+1)-1)./kq2);
        qdb=Qinv*((sqrt(kq2+1)-1)./kq2);
    end
    
    % Flag for classic or ballistic charge partitioning:
    if (CTM_select == 1)   % classic DD-NVSAT
        qs=qsc;
        qd=qdc;
    else % ballistic blended with classic D/D
        Fsatq2=Fsatq.^2;
        qs=qsc.*(1-Fsatq2)+qsb.*Fsatq2;
        qd=qdc.*(1-Fsatq2)+qdb.*Fsatq2;
    end
    
    % Body charge based on approximate surface potential (psis) calculation.
    % With delta=0 using psis=phib in Qb gives continuous Cgs, Cgd, Cdd in SI,
    % while Cdd is smooth anyway.
    Qb(len_bias,1)=-tipe*W*Leff*(Cg*parm_gamma*sqrt(psis-Vbsi)+(a-1)./a.*Qinv.*(1-qi));
    
    % DIBL effect on drain charge calculation.
    % Calculate dQinv at virtual source due to DIBL only.  Then:
    % Correct the qd factor to reflect this channel charge change due to Vds
    etai=(Vgsi-(Vt0bs0-FF*aphit))./(nphit); % Vt0bs0 and FF=FF0 causes least
    %discontinuity in Cgs and Cgd but produces a spike in Cdd at Vds=0 (in
    %weak inversion.  But bad in strong inversion)
    Qinvi = Qref.*(log(1+exp(etai)));
    dQinv=Qinv-Qinvi;
    dibl_corr=(1-FF0).*(1-Fsatq).*qi.*dQinv;
    qd=qd-dibl_corr; %Potential problem area!
    
    % Inversion charge partitioning to terminals s and d accounting for
    % source drain reversal.
    Qinvs=tipe*Leff.*((1+dir).*qs+(1-dir).*qd)/2;
    Qinvd=tipe*Leff.*((1-dir).*qs+(1+dir).*qd)/2;
    
    % Overlap and outer fringe S and D to G charges
    % First calculate internal Vx and Vy
    
    Qxov=Cofs*(Vg-Vsint);
    Qyov=Cofd*(Vg-Vdint);
    
    % Inner fringing S and D to G charges; both screened by inversion at
    % that terminal (via FF function)
    Vt0x=Vt0+parm_gamma*(sqrt(phib-tipe*(Vb-Vsint))-sqrt(phib));
    Vt0y=Vt0+parm_gamma*(sqrt(phib-tipe*(Vb-Vdint))-sqrt(phib));
    Fs=1+exp((Vgsraw-(Vt0x-Vdsi.*delta.*Fsat)+aphit*0.5)./(1.1*nphit));
    Fd=1+exp((Vgdraw-(Vt0y-Vdsi.*delta.*Fsat)+aphit*0.5)./(1.1*nphit));
    
    FFx=Vgsraw-nphit.*log(Fs);
    FFy=Vgdraw-nphit.*log(Fd);
    
    Qxif=tipe*(Cif+CC*Vgsraw).*FFx;
    Qyif=tipe*(Cif+CC*Vgdraw).*FFy;
    
    % Total charge at internal terminals x and y.
    Qs(len_bias,1)=-W*(Qinvs+Qxov+Qxif);
    Qd(len_bias,1)=-W*(Qinvd+Qyov+Qyif);
    
    % Final charge balance
    Qg(len_bias,1)=-(Qs(len_bias,1)+Qd(len_bias,1)+Qb(len_bias,1));
    
    
    %end
end
