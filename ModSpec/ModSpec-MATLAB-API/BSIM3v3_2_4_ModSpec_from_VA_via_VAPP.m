function MOD = BSIM3v3_2_4_ModSpec_from_VA_via_VAPP(uniqID)
    % TRANSLATED BY VAPP

    MOD = ee_model();
    MOD = add_to_ee_model (MOD, 'modelname', 'bsim3');
    MOD = add_to_ee_model (MOD, 'terminals', {'vd', 'vg', 'vs', 'vb'});

    % variable info:
    % explicit outputs: 
    % variable name: ivdvb, equation index: 1
    % variable name: ivgvb, equation index: 2
    % variable name: ivsvb, equation index: 3

    % internal unknowns: 
    % variable name: vvdpvb, equation index: 0
    % variable name: vvspvb, equation index: 0

    MOD = add_to_ee_model (MOD, 'explicit_outs', {'ivdvb', 'ivgvb', 'ivsvb'});
    MOD = add_to_ee_model (MOD, 'internal_unks', {'vvdpvb', 'vvspvb'});

    MOD = add_to_ee_model (MOD, 'parms', {'parm_Type', 0,...
                                          'parm_a0', 1,...
                                          'parm_a1', 0,...
                                          'parm_a2', 1,...
                                          'parm_acde1', 1,...
                                          'parm_ad', 1e-10,...
                                          'parm_af', 1,...
                                          'parm_ags', 0,...
                                          'parm_alpha0', 0,...
                                          'parm_alpha1', 0,...
                                          'parm_as', 1e-10,...
                                          'parm_at', 33000,...
                                          'parm_b0', 0,...
                                          'parm_b1', 0,...
                                          'parm_beta0', 30,...
                                          'parm_binunit', 1,...
                                          'parm_capmod', 0,...
                                          'parm_cdsc', 0.00024,...
                                          'parm_cdscb', 0,...
                                          'parm_cdscd', 0,...
                                          'parm_cf', -9999.9999,...
                                          'parm_cgbo', -9999.9999,...
                                          'parm_cgdl', 0,...
                                          'parm_cgdo', -9999.9999,...
                                          'parm_cgsl', 0,...
                                          'parm_cgso', -9999.9999,...
                                          'parm_cit', 0,...
                                          'parm_cj', 0.0005,...
                                          'parm_cjsw', 5e-10,...
                                          'parm_cjswg', 5e-10,...
                                          'parm_ckappa', 0.6,...
                                          'parm_clc1', 1e-07,...
                                          'parm_cle', 0.6,...
                                          'parm_delta', 0.01,...
                                          'parm_dlc', -9999.9999,...
                                          'parm_drout', 0.56,...
                                          'parm_dsub', 0.56,...
                                          'parm_dvt0', 2.2,...
                                          'parm_dvt0w', 0,...
                                          'parm_dvt1', 0.53,...
                                          'parm_dvt1w', 5300000,...
                                          'parm_dvt2', -0.032,...
                                          'parm_dvt2w', -0.032,...
                                          'parm_dwb', 0,...
                                          'parm_dwc', 0,...
                                          'parm_dwg', 0,...
                                          'parm_ef', 1,...
                                          'parm_elm', 5,...
                                          'parm_em', 41000000,...
                                          'parm_eta0', 0.08,...
                                          'parm_etab', -0.07,...
                                          'parm_gamma1', 0,...
                                          'parm_gamma2', 0,...
                                          'parm_ijth', 0.1,...
                                          'parm_js', 0.0001,...
                                          'parm_jsw', 0,...
                                          'parm_k1', -9999.9999,...
                                          'parm_k2', -9999.9999,...
                                          'parm_k3', 80,...
                                          'parm_k3b', 0,...
                                          'parm_keta', -0.047,...
                                          'parm_kf', 0,...
                                          'parm_kt1', -0.11,...
                                          'parm_kt1l', 0,...
                                          'parm_kt2', 0.022,...
                                          'parm_l', 1e-05,...
                                          'parm_la0', 0,...
                                          'parm_la1', 0,...
                                          'parm_la2', 0,...
                                          'parm_lacde', 0,...
                                          'parm_lags', 0,...
                                          'parm_lalpha0', 0,...
                                          'parm_lalpha1', 0,...
                                          'parm_lat', 0,...
                                          'parm_lb0', 0,...
                                          'parm_lb1', 0,...
                                          'parm_lbeta0', 0,...
                                          'parm_lcdsc', 0,...
                                          'parm_lcdscb', 0,...
                                          'parm_lcdscd', 0,...
                                          'parm_lcf', 0,...
                                          'parm_lcgdl', 0,...
                                          'parm_lcgsl', 0,...
                                          'parm_lcit', 0,...
                                          'parm_lckappa', 0,...
                                          'parm_lclc', 0,...
                                          'parm_lcle', 0,...
                                          'parm_ldelta', 0,...
                                          'parm_ldrout', 0,...
                                          'parm_ldsub', 0,...
                                          'parm_ldvt0', 0,...
                                          'parm_ldvt0w', 0,...
                                          'parm_ldvt1', 0,...
                                          'parm_ldvt1w', 0,...
                                          'parm_ldvt2', 0,...
                                          'parm_ldvt2w', 0,...
                                          'parm_ldwb', 0,...
                                          'parm_ldwg', 0,...
                                          'parm_lelm', 0,...
                                          'parm_leta0', 0,...
                                          'parm_letab', 0,...
                                          'parm_lgamma1', 0,...
                                          'parm_lgamma2', 0,...
                                          'parm_lint', 0,...
                                          'parm_lk1', 0,...
                                          'parm_lk2', 0,...
                                          'parm_lk3', 0,...
                                          'parm_lk3b', 0,...
                                          'parm_lketa', 0,...
                                          'parm_lkt1', 0,...
                                          'parm_lkt1l', 0,...
                                          'parm_lkt2', 0,...
                                          'parm_ll', 0,...
                                          'parm_llc', 0,...
                                          'parm_lln', 1,...
                                          'parm_lmax', 1,...
                                          'parm_lmin', 0,...
                                          'parm_lmoin', 0,...
                                          'parm_lnch', 0,...
                                          'parm_lnfactor', 0,...
                                          'parm_lngate', 0,...
                                          'parm_lnlx', 0,...
                                          'parm_lnoff', 0,...
                                          'parm_lnsub', 0,...
                                          'parm_lpclm', 0,...
                                          'parm_lpdiblc1', 0,...
                                          'parm_lpdiblc2', 0,...
                                          'parm_lpdiblcb', 0,...
                                          'parm_lprt', 0,...
                                          'parm_lprwb', 0,...
                                          'parm_lprwg', 0,...
                                          'parm_lpscbe1', 0,...
                                          'parm_lpscbe2', 0,...
                                          'parm_lpvag', 0,...
                                          'parm_lrdsw', 0,...
                                          'parm_lu0', 0,...
                                          'parm_lua', 0,...
                                          'parm_lua1', 0,...
                                          'parm_lub', 0,...
                                          'parm_lub1', 0,...
                                          'parm_luc', 0,...
                                          'parm_luc1', 0,...
                                          'parm_lute', 0,...
                                          'parm_lvbm', 0,...
                                          'parm_lvbx', 0,...
                                          'parm_lvfb', 0,...
                                          'parm_lvfbcv', 0,...
                                          'parm_lvoff', 0,...
                                          'parm_lvoffcv', 0,...
                                          'parm_lvsat', 0,...
                                          'parm_lvth0', 0,...
                                          'parm_lw', 0,...
                                          'parm_lw0', 0,...
                                          'parm_lwc', 0,...
                                          'parm_lwl', 0,...
                                          'parm_lwlc', 0,...
                                          'parm_lwn', 1,...
                                          'parm_lwr', 0,...
                                          'parm_lxj', 0,...
                                          'parm_lxt', 0,...
                                          'parm_mj', 0.5,...
                                          'parm_mjsw', 0.33,...
                                          'parm_mjswg', 0.33,...
                                          'parm_mobmod', 1,...
                                          'parm_moin', 15,...
                                          'parm_nch', 1.7e+17,...
                                          'parm_nfactor', 1,...
                                          'parm_ngate', 0,...
                                          'parm_nj', 1,...
                                          'parm_nlx', 1.74e-07,...
                                          'parm_noff', 1,...
                                          'parm_noia', 1e+20,...
                                          'parm_noib', 50000,...
                                          'parm_noic', -1.4e-12,...
                                          'parm_noimod', 1,...
                                          'parm_nqsmod', 0,...
                                          'parm_nrd', 1,...
                                          'parm_nrs', 1,...
                                          'parm_nsub', 6e-16,...
                                          'parm_pa0', 0,...
                                          'parm_pa1', 0,...
                                          'parm_pa2', 0,...
                                          'parm_pacde', 0,...
                                          'parm_pags', 0,...
                                          'parm_palpha0', 0,...
                                          'parm_palpha1', 0,...
                                          'parm_pat', 0,...
                                          'parm_pb', 1,...
                                          'parm_pb0', 0,...
                                          'parm_pb1', 0,...
                                          'parm_pbeta0', 0,...
                                          'parm_pbsw', 1,...
                                          'parm_pbswg', 1,...
                                          'parm_pcdsc', 0,...
                                          'parm_pcdscb', 0,...
                                          'parm_pcdscd', 0,...
                                          'parm_pcf', 0,...
                                          'parm_pcgdl', 0,...
                                          'parm_pcgsl', 0,...
                                          'parm_pcit', 0,...
                                          'parm_pckappa', 0,...
                                          'parm_pclc', 0,...
                                          'parm_pcle', 0,...
                                          'parm_pclm', 1.3,...
                                          'parm_pd', 4e-05,...
                                          'parm_pdelta', 0,...
                                          'parm_pdiblc1', 0.39,...
                                          'parm_pdiblc2', 0.0086,...
                                          'parm_pdiblcb', 0,...
                                          'parm_pdrout', 0,...
                                          'parm_pdsub', 0,...
                                          'parm_pdvt0', 0,...
                                          'parm_pdvt0w', 0,...
                                          'parm_pdvt1', 0,...
                                          'parm_pdvt1w', 0,...
                                          'parm_pdvt2', 0,...
                                          'parm_pdvt2w', 0,...
                                          'parm_pdwb', 0,...
                                          'parm_pdwg', 0,...
                                          'parm_pelm', 0,...
                                          'parm_peta0', 0,...
                                          'parm_petab', 0,...
                                          'parm_pgamma1', 0,...
                                          'parm_pgamma2', 0,...
                                          'parm_pk1', 0,...
                                          'parm_pk2', 0,...
                                          'parm_pk3', 0,...
                                          'parm_pk3b', 0,...
                                          'parm_pketa', 0,...
                                          'parm_pkt1', 0,...
                                          'parm_pkt1l', 0,...
                                          'parm_pkt2', 0,...
                                          'parm_pmoin', 0,...
                                          'parm_pnch', 0,...
                                          'parm_pnfactor', 0,...
                                          'parm_pngate', 0,...
                                          'parm_pnlx', 0,...
                                          'parm_pnoff', 0,...
                                          'parm_pnsub', 0,...
                                          'parm_ppclm', 0,...
                                          'parm_ppdiblc1', 0,...
                                          'parm_ppdiblc2', 0,...
                                          'parm_ppdiblcb', 0,...
                                          'parm_pprt', 0,...
                                          'parm_pprwb', 0,...
                                          'parm_pprwg', 0,...
                                          'parm_ppscbe1', 0,...
                                          'parm_ppscbe2', 0,...
                                          'parm_ppvag', 0,...
                                          'parm_prdsw', 0,...
                                          'parm_prt', 0,...
                                          'parm_prwb', 0,...
                                          'parm_prwg', 0,...
                                          'parm_ps', 4e-05,...
                                          'parm_pscbe1', 424000000,...
                                          'parm_pscbe2', 1e-05,...
                                          'parm_pu0', 0,...
                                          'parm_pua', 0,...
                                          'parm_pua1', 0,...
                                          'parm_pub', 0,...
                                          'parm_pub1', 0,...
                                          'parm_puc', 0,...
                                          'parm_puc1', 0,...
                                          'parm_pute', 0,...
                                          'parm_pvag', 0,...
                                          'parm_pvbm', 0,...
                                          'parm_pvbx', 0,...
                                          'parm_pvfb', 0,...
                                          'parm_pvfbcv', 0,...
                                          'parm_pvoff', 0,...
                                          'parm_pvoffcv', 0,...
                                          'parm_pvsat', 0,...
                                          'parm_pvth0', 0,...
                                          'parm_pw0', 0,...
                                          'parm_pwr', 0,...
                                          'parm_pxj', 0,...
                                          'parm_pxt', 0,...
                                          'parm_rdsw', 0,...
                                          'parm_rsh', 0,...
                                          'parm_tcj', 0,...
                                          'parm_tcjsw', 0,...
                                          'parm_tcjswg', 0,...
                                          'parm_tnom', 0,...
                                          'parm_tox', 1.5e-08,...
                                          'parm_toxm', 1.5e-08,...
                                          'parm_tpb', 0,...
                                          'parm_tpbsw', 0,...
                                          'parm_tpbswg', 0,...
                                          'parm_u0', -9999.9999,...
                                          'parm_ua', 2.25e-09,...
                                          'parm_ua1', 4.31e-09,...
                                          'parm_ub', 5.87e-19,...
                                          'parm_ub1', -7.61e-18,...
                                          'parm_uc', -9999.9999,...
                                          'parm_uc1', -9999.9999,...
                                          'parm_ute', -1.5,...
                                          'parm_vbm', -3,...
                                          'parm_vbx', 0,...
                                          'parm_version', 3.24,...
                                          'parm_vfb', -1,...
                                          'parm_vfbcv', -1,...
                                          'parm_voff', -0.08,...
                                          'parm_voffcv', 0,...
                                          'parm_vsat', 80000,...
                                          'parm_vth0', -9999.9999,...
                                          'parm_w', 5e-06,...
                                          'parm_w0', 2.5e-06,...
                                          'parm_wa0', 0,...
                                          'parm_wa1', 0,...
                                          'parm_wa2', 0,...
                                          'parm_wacde', 0,...
                                          'parm_wags', 0,...
                                          'parm_walpha0', 0,...
                                          'parm_walpha1', 0,...
                                          'parm_wat', 0,...
                                          'parm_wb0', 0,...
                                          'parm_wb1', 0,...
                                          'parm_wbeta0', 0,...
                                          'parm_wcdsc', 0,...
                                          'parm_wcdscb', 0,...
                                          'parm_wcdscd', 0,...
                                          'parm_wcf', 0,...
                                          'parm_wcgdl', 0,...
                                          'parm_wcgsl', 0,...
                                          'parm_wcit', 0,...
                                          'parm_wckappa', 0,...
                                          'parm_wclc', 0,...
                                          'parm_wcle', 0,...
                                          'parm_wdelta', 0,...
                                          'parm_wdrout', 0,...
                                          'parm_wdsub', 0,...
                                          'parm_wdvt0', 0,...
                                          'parm_wdvt0w', 0,...
                                          'parm_wdvt1', 0,...
                                          'parm_wdvt1w', 0,...
                                          'parm_wdvt2', 0,...
                                          'parm_wdvt2w', 0,...
                                          'parm_wdwb', 0,...
                                          'parm_wdwg', 0,...
                                          'parm_welm', 0,...
                                          'parm_weta0', 0,...
                                          'parm_wetab', 0,...
                                          'parm_wgamma1', 0,...
                                          'parm_wgamma2', 0,...
                                          'parm_wint', 0,...
                                          'parm_wk1', 0,...
                                          'parm_wk2', 0,...
                                          'parm_wk3', 0,...
                                          'parm_wk3b', 0,...
                                          'parm_wketa', 0,...
                                          'parm_wkt1', 0,...
                                          'parm_wkt1l', 0,...
                                          'parm_wkt2', 0,...
                                          'parm_wl', 0,...
                                          'parm_wlc', 0,...
                                          'parm_wln', 1,...
                                          'parm_wmax', 1,...
                                          'parm_wmin', 0,...
                                          'parm_wmoin', 0,...
                                          'parm_wnch', 0,...
                                          'parm_wnfactor', 0,...
                                          'parm_wngate', 0,...
                                          'parm_wnlx', 0,...
                                          'parm_wnoff', 0,...
                                          'parm_wnsub', 0,...
                                          'parm_wpclm', 0,...
                                          'parm_wpdiblc1', 0,...
                                          'parm_wpdiblc2', 0,...
                                          'parm_wpdiblcb', 0,...
                                          'parm_wprt', 0,...
                                          'parm_wprwb', 0,...
                                          'parm_wprwg', 0,...
                                          'parm_wpscbe1', 0,...
                                          'parm_wpscbe2', 0,...
                                          'parm_wpvag', 0,...
                                          'parm_wr', 1,...
                                          'parm_wrdsw', 0,...
                                          'parm_wu0', 0,...
                                          'parm_wua', 0,...
                                          'parm_wua1', 0,...
                                          'parm_wub', 0,...
                                          'parm_wub1', 0,...
                                          'parm_wuc', 0,...
                                          'parm_wuc1', 0,...
                                          'parm_wute', 0,...
                                          'parm_wvbm', 0,...
                                          'parm_wvbx', 0,...
                                          'parm_wvfb', 0,...
                                          'parm_wvfbcv', 0,...
                                          'parm_wvoff', 0,...
                                          'parm_wvoffcv', 0,...
                                          'parm_wvsat', 0,...
                                          'parm_wvth0', 0,...
                                          'parm_ww', 0,...
                                          'parm_ww0', 0,...
                                          'parm_wwc', 0,...
                                          'parm_wwl', 0,...
                                          'parm_wwlc', 0,...
                                          'parm_wwn', 1,...
                                          'parm_wwr', 0,...
                                          'parm_wxj', 0,...
                                          'parm_wxt', 0,...
                                          'parm_xj', 1.5e-07,...
                                          'parm_xpart', 0,...
                                          'parm_xt', 1.55e-07,...
                                          'parm_xti', 3});

    MOD = add_to_ee_model (MOD, 'fqei_all', @fqei_all);

    MOD = finish_ee_model(MOD);

end

function [fe, qe, fi, qi] = fqei_all(S)
    v2struct(S);
    % initializing variables
    BSIM3gamma1Given = 0;
    BSIM3gamma2Given = 0;
    BSIM3nqsMod = 0;
    BSIM3nsubGiven = 0;
    BSIM3vbxGiven = 0;
    BSIM3vfbGiven = 0;
    BSIM3xtGiven = 0;
    dsqrtPhis_dVb = 0;
    % printing IO aliases
    vvbvsp = -vvspvb;
    vvdpvsp = vvdpvb - vvspvb;
    vvgvsp = vvgvb - vvspvb;
    vvdvdp = vvdvb - vvdpvb;
    vvsvsp = vvsvb - vvspvb;
    % module body
    BSIM3drainArea = parm_ad;
    BSIM3sourceArea = parm_as;
    BSIM3drainSquares = parm_nrd;
    BSIM3sourceSquares = parm_nrs;
    BSIM3drainPerimeter = parm_pd;
    BSIM3sourcePerimeter = parm_ps;
    BSIM3mobMod = parm_mobmod;
    BSIM3binUnit = parm_binunit;
    BSIM3capMod = parm_capmod;
    BSIM3noiMod = parm_noimod;
    BSIM3version = parm_version;
    BSIM3tox = parm_tox;
    BSIM3toxm = parm_toxm;
    BSIM3cdsc = parm_cdsc;
    BSIM3cdscb = parm_cdscb;
    BSIM3cdscd = parm_cdscd;
    BSIM3cit = parm_cit;
    BSIM3nfactor = parm_nfactor;
    BSIM3xj = parm_xj;
    BSIM3vsat = parm_vsat;
    BSIM3a0 = parm_a0;
    BSIM3ags = parm_ags;
    BSIM3a1 = parm_a1;
    BSIM3a2 = parm_a2;
    BSIM3at = parm_at;
    BSIM3keta = parm_keta;
    BSIM3nsub = parm_nsub;
    BSIM3npeak = parm_nch;
    BSIM3ngate = parm_ngate;
    BSIM3gamma1 = parm_gamma1;
    BSIM3gamma2 = parm_gamma2;
    BSIM3vbx = parm_vbx;
    BSIM3vbm = parm_vbm;
    BSIM3xt = parm_xt;
    BSIM3k1 = parm_k1;
    BSIM3kt1 = parm_kt1;
    BSIM3kt1l = parm_kt1l;
    BSIM3kt2 = parm_kt2;
    BSIM3k2 = parm_k2;
    BSIM3k3 = parm_k3;
    BSIM3k3b = parm_k3b;
    BSIM3nlx = parm_nlx;
    BSIM3w0 = parm_w0;
    BSIM3dvt0 = parm_dvt0;
    BSIM3dvt1 = parm_dvt1;
    BSIM3dvt2 = parm_dvt2;
    BSIM3dvt0w = parm_dvt0w;
    BSIM3dvt1w = parm_dvt1w;
    BSIM3dvt2w = parm_dvt2w;
    BSIM3drout = parm_drout;
    BSIM3dsub = parm_dsub;
    BSIM3vth0 = parm_vth0;
    BSIM3ua = parm_ua;
    BSIM3ua1 = parm_ua1;
    BSIM3ub = parm_ub;
    BSIM3ub1 = parm_ub1;
    BSIM3uc = parm_uc;
    BSIM3uc1 = parm_uc1;
    BSIM3u0 = parm_u0;
    BSIM3ute = parm_ute;
    BSIM3voff = parm_voff;
    BSIM3delta = parm_delta;
    BSIM3rdsw = parm_rdsw;
    BSIM3prwg = parm_prwg;
    BSIM3prwb = parm_prwb;
    BSIM3prt = parm_prt;
    BSIM3eta0 = parm_eta0;
    BSIM3etab = parm_etab;
    BSIM3pclm = parm_pclm;
    BSIM3pdibl1 = parm_pdiblc1;
    BSIM3pdibl2 = parm_pdiblc2;
    BSIM3pdiblb = parm_pdiblcb;
    BSIM3pscbe1 = parm_pscbe1;
    BSIM3pscbe2 = parm_pscbe2;
    BSIM3pvag = parm_pvag;
    BSIM3wr = parm_wr;
    BSIM3dwg = parm_dwg;
    BSIM3dwb = parm_dwb;
    BSIM3b0 = parm_b0;
    BSIM3b1 = parm_b1;
    BSIM3alpha0 = parm_alpha0;
    BSIM3alpha1 = parm_alpha1;
    BSIM3beta0 = parm_beta0;
    BSIM3ijth = parm_ijth;
    BSIM3vfb = parm_vfb;
    BSIM3elm = parm_elm;
    BSIM3cgsl = parm_cgsl;
    BSIM3cgdl = parm_cgdl;
    BSIM3ckappa = parm_ckappa;
    BSIM3cf = parm_cf;
    BSIM3clc = parm_clc1;
    BSIM3cle = parm_cle;
    BSIM3dwc = parm_dwc;
    BSIM3dlc = parm_dlc;
    BSIM3vfbcv = parm_vfbcv;
    BSIM3acde = parm_acde1;
    BSIM3moin = parm_moin;
    BSIM3noff = parm_noff;
    BSIM3voffcv = parm_voffcv;
    BSIM3tcj = parm_tcj;
    BSIM3tpb = parm_tpb;
    BSIM3tcjsw = parm_tcjsw;
    BSIM3tpbsw = parm_tpbsw;
    BSIM3tcjswg = parm_tcjswg;
    BSIM3tpbswg = parm_tpbswg;
    BSIM3lcdsc = parm_lcdsc;
    BSIM3lcdscb = parm_lcdscb;
    BSIM3lcdscd = parm_lcdscd;
    BSIM3lcit = parm_lcit;
    BSIM3lnfactor = parm_lnfactor;
    BSIM3lxj = parm_lxj;
    BSIM3lvsat = parm_lvsat;
    BSIM3la0 = parm_la0;
    BSIM3lags = parm_lags;
    BSIM3la1 = parm_la1;
    BSIM3la2 = parm_la2;
    BSIM3lat = parm_lat;
    BSIM3lketa = parm_lketa;
    BSIM3lnsub = parm_lnsub;
    BSIM3lnpeak = parm_lnch;
    BSIM3lngate = parm_lngate;
    BSIM3lgamma1 = parm_lgamma1;
    BSIM3lgamma2 = parm_lgamma2;
    BSIM3lvbx = parm_lvbx;
    BSIM3lvbm = parm_lvbm;
    BSIM3lxt = parm_lxt;
    BSIM3lk1 = parm_lk1;
    BSIM3lkt1 = parm_lkt1;
    BSIM3lkt1l = parm_lkt1l;
    BSIM3lkt2 = parm_lkt2;
    BSIM3lk2 = parm_lk2;
    BSIM3lk3 = parm_lk3;
    BSIM3lk3b = parm_lk3b;
    BSIM3lnlx = parm_lnlx;
    BSIM3lw0 = parm_lw0;
    BSIM3ldvt0 = parm_ldvt0;
    BSIM3ldvt1 = parm_ldvt1;
    BSIM3ldvt2 = parm_ldvt2;
    BSIM3ldvt0w = parm_ldvt0w;
    BSIM3ldvt1w = parm_ldvt1w;
    BSIM3ldvt2w = parm_ldvt2w;
    BSIM3ldrout = parm_ldrout;
    BSIM3ldsub = parm_ldsub;
    BSIM3lvth0 = parm_lvth0;
    BSIM3lua = parm_lua;
    BSIM3lua1 = parm_lua1;
    BSIM3lub = parm_lub;
    BSIM3lub1 = parm_lub1;
    BSIM3luc = parm_luc;
    BSIM3luc1 = parm_luc1;
    BSIM3lu0 = parm_lu0;
    BSIM3lute = parm_lute;
    BSIM3lvoff = parm_lvoff;
    BSIM3ldelta = parm_ldelta;
    BSIM3lrdsw = parm_lrdsw;
    BSIM3lprwb = parm_lprwb;
    BSIM3lprwg = parm_lprwg;
    BSIM3lprt = parm_lprt;
    BSIM3leta0 = parm_leta0;
    BSIM3letab = parm_letab;
    BSIM3lpclm = parm_lpclm;
    BSIM3lpdibl1 = parm_lpdiblc1;
    BSIM3lpdibl2 = parm_lpdiblc2;
    BSIM3lpdiblb = parm_lpdiblcb;
    BSIM3lpscbe1 = parm_lpscbe1;
    BSIM3lpscbe2 = parm_lpscbe2;
    BSIM3lpvag = parm_lpvag;
    BSIM3lwr = parm_lwr;
    BSIM3ldwg = parm_ldwg;
    BSIM3ldwb = parm_ldwb;
    BSIM3lb0 = parm_lb0;
    BSIM3lb1 = parm_lb1;
    BSIM3lalpha0 = parm_lalpha0;
    BSIM3lalpha1 = parm_lalpha1;
    BSIM3lbeta0 = parm_lbeta0;
    BSIM3lvfb = parm_lvfb;
    BSIM3lelm = parm_lelm;
    BSIM3lcgsl = parm_lcgsl;
    BSIM3lcgdl = parm_lcgdl;
    BSIM3lckappa = parm_lckappa;
    BSIM3lcf = parm_lcf;
    BSIM3lclc = parm_lclc;
    BSIM3lcle = parm_lcle;
    BSIM3lvfbcv = parm_lvfbcv;
    BSIM3lacde = parm_lacde;
    BSIM3lmoin = parm_lmoin;
    BSIM3lnoff = parm_lnoff;
    BSIM3lvoffcv = parm_lvoffcv;
    BSIM3wcdsc = parm_wcdsc;
    BSIM3wcdscb = parm_wcdscb;
    BSIM3wcdscd = parm_wcdscd;
    BSIM3wcit = parm_wcit;
    BSIM3wnfactor = parm_wnfactor;
    BSIM3wxj = parm_wxj;
    BSIM3wvsat = parm_wvsat;
    BSIM3wa0 = parm_wa0;
    BSIM3wags = parm_wags;
    BSIM3wa1 = parm_wa1;
    BSIM3wa2 = parm_wa2;
    BSIM3wat = parm_wat;
    BSIM3wketa = parm_wketa;
    BSIM3wnsub = parm_wnsub;
    BSIM3wnpeak = parm_wnch;
    BSIM3wngate = parm_wngate;
    BSIM3wgamma1 = parm_wgamma1;
    BSIM3wgamma2 = parm_wgamma2;
    BSIM3wvbx = parm_wvbx;
    BSIM3wvbm = parm_wvbm;
    BSIM3wxt = parm_wxt;
    BSIM3wk1 = parm_wk1;
    BSIM3wkt1 = parm_wkt1;
    BSIM3wkt1l = parm_wkt1l;
    BSIM3wkt2 = parm_wkt2;
    BSIM3wk2 = parm_wk2;
    BSIM3wk3 = parm_wk3;
    BSIM3wk3b = parm_wk3b;
    BSIM3wnlx = parm_wnlx;
    BSIM3ww0 = parm_ww0;
    BSIM3wdvt0 = parm_wdvt0;
    BSIM3wdvt1 = parm_wdvt1;
    BSIM3wdvt2 = parm_wdvt2;
    BSIM3wdvt0w = parm_wdvt0w;
    BSIM3wdvt1w = parm_wdvt1w;
    BSIM3wdvt2w = parm_wdvt2w;
    BSIM3wdrout = parm_wdrout;
    BSIM3wdsub = parm_wdsub;
    BSIM3wvth0 = parm_wvth0;
    BSIM3wua = parm_wua;
    BSIM3wua1 = parm_wua1;
    BSIM3wub = parm_wub;
    BSIM3wub1 = parm_wub1;
    BSIM3wuc = parm_wuc;
    BSIM3wuc1 = parm_wuc1;
    BSIM3wu0 = parm_wu0;
    BSIM3wute = parm_wute;
    BSIM3wvoff = parm_wvoff;
    BSIM3wdelta = parm_wdelta;
    BSIM3wrdsw = parm_wrdsw;
    BSIM3wprwb = parm_wprwb;
    BSIM3wprwg = parm_wprwg;
    BSIM3wprt = parm_wprt;
    BSIM3weta0 = parm_weta0;
    BSIM3wetab = parm_wetab;
    BSIM3wpclm = parm_wpclm;
    BSIM3wpdibl1 = parm_wpdiblc1;
    BSIM3wpdibl2 = parm_wpdiblc2;
    BSIM3wpdiblb = parm_wpdiblcb;
    BSIM3wpscbe1 = parm_wpscbe1;
    BSIM3wpscbe2 = parm_wpscbe2;
    BSIM3wpvag = parm_wpvag;
    BSIM3wwr = parm_wwr;
    BSIM3wdwg = parm_wdwg;
    BSIM3wdwb = parm_wdwb;
    BSIM3wb0 = parm_wb0;
    BSIM3wb1 = parm_wb1;
    BSIM3walpha0 = parm_walpha0;
    BSIM3walpha1 = parm_walpha1;
    BSIM3wbeta0 = parm_wbeta0;
    BSIM3wvfb = parm_wvfb;
    BSIM3welm = parm_welm;
    BSIM3wcgsl = parm_wcgsl;
    BSIM3wcgdl = parm_wcgdl;
    BSIM3wckappa = parm_wckappa;
    BSIM3wcf = parm_wcf;
    BSIM3wclc = parm_wclc;
    BSIM3wcle = parm_wcle;
    BSIM3wvfbcv = parm_wvfbcv;
    BSIM3wacde = parm_wacde;
    BSIM3wmoin = parm_wmoin;
    BSIM3wnoff = parm_wnoff;
    BSIM3wvoffcv = parm_wvoffcv;
    BSIM3pcdsc = parm_pcdsc;
    BSIM3pcdscb = parm_pcdscb;
    BSIM3pcdscd = parm_pcdscd;
    BSIM3pcit = parm_pcit;
    BSIM3pnfactor = parm_pnfactor;
    BSIM3pxj = parm_pxj;
    BSIM3pvsat = parm_pvsat;
    BSIM3pa0 = parm_pa0;
    BSIM3pags = parm_pags;
    BSIM3pa1 = parm_pa1;
    BSIM3pa2 = parm_pa2;
    BSIM3pat = parm_pat;
    BSIM3pketa = parm_pketa;
    BSIM3pnsub = parm_pnsub;
    BSIM3pnpeak = parm_pnch;
    BSIM3pngate = parm_pngate;
    BSIM3pgamma1 = parm_pgamma1;
    BSIM3pgamma2 = parm_pgamma2;
    BSIM3pvbx = parm_pvbx;
    BSIM3pvbm = parm_pvbm;
    BSIM3pxt = parm_pxt;
    BSIM3pk1 = parm_pk1;
    BSIM3pkt1 = parm_pkt1;
    BSIM3pkt1l = parm_pkt1l;
    BSIM3pkt2 = parm_pkt2;
    BSIM3pk2 = parm_pk2;
    BSIM3pk3 = parm_pk3;
    BSIM3pk3b = parm_pk3b;
    BSIM3pnlx = parm_pnlx;
    BSIM3pw0 = parm_pw0;
    BSIM3pdvt0 = parm_pdvt0;
    BSIM3pdvt1 = parm_pdvt1;
    BSIM3pdvt2 = parm_pdvt2;
    BSIM3pdvt0w = parm_pdvt0w;
    BSIM3pdvt1w = parm_pdvt1w;
    BSIM3pdvt2w = parm_pdvt2w;
    BSIM3pdrout = parm_pdrout;
    BSIM3pdsub = parm_pdsub;
    BSIM3pvth0 = parm_pvth0;
    BSIM3pua = parm_pua;
    BSIM3pua1 = parm_pua1;
    BSIM3pub = parm_pub;
    BSIM3pub1 = parm_pub1;
    BSIM3puc = parm_puc;
    BSIM3puc1 = parm_puc1;
    BSIM3pu0 = parm_pu0;
    BSIM3pute = parm_pute;
    BSIM3pvoff = parm_pvoff;
    BSIM3pdelta = parm_pdelta;
    BSIM3prdsw = parm_prdsw;
    BSIM3pprwb = parm_pprwb;
    BSIM3pprwg = parm_pprwg;
    BSIM3pprt = parm_pprt;
    BSIM3peta0 = parm_peta0;
    BSIM3petab = parm_petab;
    BSIM3ppclm = parm_ppclm;
    BSIM3ppdibl1 = parm_ppdiblc1;
    BSIM3ppdibl2 = parm_ppdiblc2;
    BSIM3ppdiblb = parm_ppdiblcb;
    BSIM3ppscbe1 = parm_ppscbe1;
    BSIM3ppscbe2 = parm_ppscbe2;
    BSIM3ppvag = parm_ppvag;
    BSIM3pwr = parm_pwr;
    BSIM3pdwg = parm_pdwg;
    BSIM3pdwb = parm_pdwb;
    BSIM3pb0 = parm_pb0;
    BSIM3pb1 = parm_pb1;
    BSIM3palpha0 = parm_palpha0;
    BSIM3palpha1 = parm_palpha1;
    BSIM3pbeta0 = parm_pbeta0;
    BSIM3pvfb = parm_pvfb;
    BSIM3pelm = parm_pelm;
    BSIM3pcgsl = parm_pcgsl;
    BSIM3pcgdl = parm_pcgdl;
    BSIM3pckappa = parm_pckappa;
    BSIM3pcf = parm_pcf;
    BSIM3pclc = parm_pclc;
    BSIM3pcle = parm_pcle;
    BSIM3pvfbcv = parm_pvfbcv;
    BSIM3pacde = parm_pacde;
    BSIM3pmoin = parm_pmoin;
    BSIM3pnoff = parm_pnoff;
    BSIM3pvoffcv = parm_pvoffcv;
    BSIM3tnom = parm_tnom+273.15;
    BSIM3cgso = parm_cgso;
    BSIM3cgdo = parm_cgdo;
    BSIM3cgbo = parm_cgbo;
    BSIM3xpart = parm_xpart;
    BSIM3sheetResistance = parm_rsh;
    BSIM3jctSatCurDensity = parm_js;
    BSIM3jctSidewallSatCurDensity = parm_jsw;
    BSIM3bulkJctPotential = parm_pb;
    BSIM3bulkJctBotGradingCoeff = parm_mj;
    BSIM3sidewallJctPotential = parm_pbsw;
    BSIM3bulkJctSideGradingCoeff = parm_mjsw;
    BSIM3unitAreaJctCap = parm_cj;
    BSIM3unitLengthSidewallJctCap = parm_cjsw;
    BSIM3jctEmissionCoeff = parm_nj;
    BSIM3GatesidewallJctPotential = parm_pbswg;
    BSIM3bulkJctGateSideGradingCoeff = parm_mjswg;
    BSIM3unitLengthGateSidewallJctCap = parm_cjswg;
    BSIM3jctTempExponent = parm_xti;
    BSIM3Lint = parm_lint;
    BSIM3Ll = parm_ll;
    BSIM3Llc = parm_llc;
    BSIM3Lln = parm_lln;
    BSIM3Lw = parm_lw;
    BSIM3Lwc = parm_lwc;
    BSIM3Lwn = parm_lwn;
    BSIM3Lwl = parm_lwl;
    BSIM3Lwlc = parm_lwlc;
    BSIM3Lmin = parm_lmin;
    BSIM3Lmax = parm_lmax;
    BSIM3Wint = parm_wint;
    BSIM3Wl = parm_wl;
    BSIM3Wlc = parm_wlc;
    BSIM3Wln = parm_wln;
    BSIM3Ww = parm_ww;
    BSIM3Wwc = parm_wwc;
    BSIM3Wwn = parm_wwn;
    BSIM3Wwl = parm_wwl;
    BSIM3Wwlc = parm_wwlc;
    BSIM3Wmin = parm_wmin;
    BSIM3Wmax = parm_wmax;
    BSIM3oxideTrapDensityA = parm_noia;
    BSIM3oxideTrapDensityB = parm_noib;
    BSIM3oxideTrapDensityC = parm_noic;
    BSIM3em = parm_em;
    BSIM3ef = parm_ef;
    BSIM3af = parm_af;
    BSIM3kf = parm_kf;
    BSIM3l = parm_l;
    BSIM3w = parm_w;
    BSIM3type = parm_Type;
    if parm_vth0==-9999.9999
        BSIM3vth0Given = 0;
        BSIM3vth0 = qmcol_vapp(BSIM3type==1, 0.7, -0.7);
    else
        BSIM3vth0Given = 1;
    end
    if parm_k1==-9999.9999
        BSIM3k1Given = 0;
        BSIM3k1 = 0.53;
    else
        BSIM3k1Given = 1;
    end
    if parm_k2==-9999.9999
        BSIM3k2Given = 0;
        BSIM3k2 = -0.0186;
    else
        BSIM3k2Given = 1;
    end
    if parm_ijth==-9999.9999
        BSIM3ijth = 0.1;
    end
    if parm_uc==-9999.9999
        BSIM3uc = qmcol_vapp(BSIM3mobMod==3, -0.0465, -4.65e-11);
    end
    if parm_uc1==-9999.9999
        BSIM3uc1 = qmcol_vapp(BSIM3mobMod==3, -0.056, -5.6e-11);
    end
    if parm_u0==-9999.9999
        BSIM3u0 = qmcol_vapp(BSIM3type==1, 0.067, 0.025);
    end
    if parm_cf==-9999.9999
        BSIM3cf = ((2*3.4531e-11)/3.1416)*log10(1+4e-07/BSIM3tox);
    end
    if BSIM3dlc==-9999.9999
        BSIM3dlcGiven = 0;
        BSIM3dlc = BSIM3Lint;
    else
        BSIM3dlcGiven = 1;
    end
    BSIM3cox = 3.4531e-11/BSIM3tox;
    Cox = BSIM3cox;
    if parm_cgdo==-9999.9999
        if BSIM3dlc>0
            BSIM3cgdo = BSIM3dlc*BSIM3cox-BSIM3cgdl;
        else
            BSIM3cgdo = (0.6*BSIM3xj)*BSIM3cox;
        end
    end
    if BSIM3cgso==-9999.9999
        if BSIM3dlc>0
            BSIM3cgso = BSIM3dlc*BSIM3cox-BSIM3cgsl;
        else
            BSIM3cgso = (0.6*BSIM3xj)*BSIM3cox;
        end
    end
    if BSIM3cgbo==-9999.9999
        BSIM3cgbo = (2*BSIM3dwc)*BSIM3cox;
    end
    Tnom = BSIM3tnom;
    Temp = Tnom;
    TRatio = Temp/Tnom;
    BSIM3vcrit = 0.025864*log(0.025864/(sqrt(2)*1e-14));
    BSIM3factor1 = sqrt((1.0359e-10/3.4531e-11)*BSIM3tox);
    Vtm0 = 8.6171e-05*Tnom;
    Eg0 = 1.16-((0.000702*Tnom)*Tnom)/(Tnom+1108);
    ni = ((14500000000*(Tnom/300.15))*sqrt(Tnom/300.15))*exp(21.5566-Eg0/(2*Vtm0));
    BSIM3vtm = 8.6171e-05*Temp;
    Eg = 1.16-((0.000702*Temp)*Temp)/(Temp+1108);
    if Temp~=Tnom
        T0 = (Eg0/Vtm0-Eg/BSIM3vtm)+BSIM3jctTempExponent*log10(Temp/Tnom);
        T1 = exp(T0/BSIM3jctEmissionCoeff);
        BSIM3jctTempSatCurDensity = BSIM3jctSatCurDensity*T1;
        BSIM3jctSidewallTempSatCurDensity = BSIM3jctSidewallSatCurDensity*T1;
    else
        BSIM3jctTempSatCurDensity = BSIM3jctSatCurDensity;
        BSIM3jctSidewallTempSatCurDensity = BSIM3jctSidewallSatCurDensity;
    end
    if BSIM3jctTempSatCurDensity<0
        BSIM3jctTempSatCurDensity = 0;
    end
    if BSIM3jctSidewallTempSatCurDensity<0
        BSIM3jctSidewallTempSatCurDensity = 0;
    end
    delTemp = (27+273.15)-BSIM3tnom;
    T0 = BSIM3tcj*delTemp;
    if T0>=-1
        BSIM3unitAreaTempJctCap = BSIM3unitAreaJctCap*(1+T0);
    else
        if BSIM3unitAreaJctCap>0
            BSIM3unitAreaTempJctCap = 0;
            sim_strobe_vapp('Temperature effect has caused cj to be negative. Cj is clamped to zero.\n')
        end
    end
    T0 = BSIM3tcjsw*delTemp;
    if T0>=-1
        BSIM3unitLengthSidewallTempJctCap = BSIM3unitLengthSidewallJctCap*(1+T0);
    else
        if BSIM3unitLengthSidewallJctCap>0
            BSIM3unitLengthSidewallTempJctCap = 0;
            sim_strobe_vapp('Temperature effect has caused cjsw to be negative. Cjsw is clamped to zero.\n')
        end
    end
    T0 = BSIM3tcjswg*delTemp;
    if T0>=-1
        BSIM3unitLengthGateSidewallTempJctCap = BSIM3unitLengthGateSidewallJctCap*(1+T0);
    else
        if BSIM3unitLengthGateSidewallJctCap>0
            BSIM3unitLengthGateSidewallTempJctCap = 0;
            sim_strobe_vapp('Temperature effect has caused cjswg to be negative. Cjswg is clamped to zero.\n')
        end
    end
    BSIM3PhiB = BSIM3bulkJctPotential-BSIM3tpb*delTemp;
    if BSIM3PhiB<0.01
        BSIM3PhiB = 0.01;
        sim_strobe_vapp('Temperature effect has caused pb to be less than 0.01. Pb is clamped to 0.01.\n')
    end
    BSIM3PhiBSW = BSIM3sidewallJctPotential-BSIM3tpbsw*delTemp;
    if BSIM3PhiBSW<=0.01
        BSIM3PhiBSW = 0.01;
        sim_strobe_vapp('Temperature effect has caused pbsw to be less than 0.01. Pbsw is clamped to 0.01.\n')
    end
    BSIM3PhiBSWG = BSIM3GatesidewallJctPotential-BSIM3tpbswg*delTemp;
    if BSIM3PhiBSWG<=0.01
        BSIM3PhiBSWG = 0.01;
        sim_strobe_vapp('Temperature effect has caused pbswg to be less than 0.01. Pbswg is clamped to 0.01.\n')
    end
    Ldrn = parm_l;
    Wdrn = parm_w;
    Length = Ldrn;
    Width = Wdrn;
    T0 = pow_vapp(Ldrn, BSIM3Lln);
    T1 = pow_vapp(Wdrn, BSIM3Lwn);
    tmp1 = (BSIM3Ll/T0+BSIM3Lw/T1)+BSIM3Lwl/(T0*T1);
    BSIM3dl = BSIM3Lint+tmp1;
    tmp2 = (BSIM3Llc/T0+BSIM3Lwc/T1)+BSIM3Lwlc/(T0*T1);
    BSIM3dlc = BSIM3dlc+tmp2;
    T2 = pow_vapp(Ldrn, BSIM3Wln);
    T3 = pow_vapp(Wdrn, BSIM3Wwn);
    tmp1 = (BSIM3Wl/T2+BSIM3Ww/T3)+BSIM3Wwl/(T2*T3);
    BSIM3dw = BSIM3Wint+tmp1;
    tmp2 = (BSIM3Wlc/T2+BSIM3Wwc/T3)+BSIM3Wwlc/(T2*T3);
    BSIM3dwc = BSIM3dwc+tmp2;
    BSIM3leff = BSIM3l-2*BSIM3dl;
    if BSIM3leff<=0
        sim_strobe_vapp('BSIM3: Effective channel length <= 0\n')
        sim_finish_vapp(-1)
    end
    BSIM3weff = BSIM3w-2*BSIM3dw;
    if BSIM3weff<=0
        sim_strobe_vapp('BSIM3: Effective channel width <= 0\n')
        sim_finish_vapp(-1)
    end
    BSIM3leffCV = BSIM3l-2*BSIM3dlc;
    if BSIM3leffCV<=0
        sim_strobe_vapp('BSIM3: Effective channel length for C-V <= 0\n')
        sim_finish_vapp(-1)
    end
    BSIM3weffCV = BSIM3w-2*BSIM3dwc;
    if BSIM3weffCV<=0
        sim_strobe_vapp('BSIM3: Effective channel width for C-V <= 0\n')
        sim_finish_vapp(-1)
    end
    if BSIM3binUnit==1
        Inv_L = 1e-06/BSIM3leff;
        Inv_W = 1e-06/BSIM3weff;
        Inv_LW = 1e-12/(BSIM3leff*BSIM3weff);
    else
        Inv_L = 1/BSIM3leff;
        Inv_W = 1/BSIM3weff;
        Inv_LW = 1/(BSIM3leff*BSIM3weff);
    end
    BSIM3cdsc = ((BSIM3cdsc+BSIM3lcdsc*Inv_L)+BSIM3wcdsc*Inv_W)+BSIM3pcdsc*Inv_LW;
    BSIM3cdscb = ((BSIM3cdscb+BSIM3lcdscb*Inv_L)+BSIM3wcdscb*Inv_W)+BSIM3pcdscb*Inv_LW;
    BSIM3cdscd = ((BSIM3cdscd+BSIM3lcdscd*Inv_L)+BSIM3wcdscd*Inv_W)+BSIM3pcdscd*Inv_LW;
    BSIM3cit = ((BSIM3cit+BSIM3lcit*Inv_L)+BSIM3wcit*Inv_W)+BSIM3pcit*Inv_LW;
    BSIM3nfactor = ((BSIM3nfactor+BSIM3lnfactor*Inv_L)+BSIM3wnfactor*Inv_W)+BSIM3pnfactor*Inv_LW;
    BSIM3xj = ((BSIM3xj+BSIM3lxj*Inv_L)+BSIM3wxj*Inv_W)+BSIM3pxj*Inv_LW;
    BSIM3vsat = ((BSIM3vsat+BSIM3lvsat*Inv_L)+BSIM3wvsat*Inv_W)+BSIM3pvsat*Inv_LW;
    BSIM3at = ((BSIM3at+BSIM3lat*Inv_L)+BSIM3wat*Inv_W)+BSIM3pat*Inv_LW;
    BSIM3a0 = ((BSIM3a0+BSIM3la0*Inv_L)+BSIM3wa0*Inv_W)+BSIM3pa0*Inv_LW;
    BSIM3ags = ((BSIM3ags+BSIM3lags*Inv_L)+BSIM3wags*Inv_W)+BSIM3pags*Inv_LW;
    BSIM3a1 = ((BSIM3a1+BSIM3la1*Inv_L)+BSIM3wa1*Inv_W)+BSIM3pa1*Inv_LW;
    BSIM3a2 = ((BSIM3a2+BSIM3la2*Inv_L)+BSIM3wa2*Inv_W)+BSIM3pa2*Inv_LW;
    BSIM3keta = ((BSIM3keta+BSIM3lketa*Inv_L)+BSIM3wketa*Inv_W)+BSIM3pketa*Inv_LW;
    BSIM3nsub = ((BSIM3nsub+BSIM3lnsub*Inv_L)+BSIM3wnsub*Inv_W)+BSIM3pnsub*Inv_LW;
    BSIM3npeak = ((BSIM3npeak+BSIM3lnpeak*Inv_L)+BSIM3wnpeak*Inv_W)+BSIM3pnpeak*Inv_LW;
    BSIM3ngate = ((BSIM3ngate+BSIM3lngate*Inv_L)+BSIM3wngate*Inv_W)+BSIM3pngate*Inv_LW;
    BSIM3gamma1 = ((BSIM3gamma1+BSIM3lgamma1*Inv_L)+BSIM3wgamma1*Inv_W)+BSIM3pgamma1*Inv_LW;
    BSIM3gamma2 = ((BSIM3gamma2+BSIM3lgamma2*Inv_L)+BSIM3wgamma2*Inv_W)+BSIM3pgamma2*Inv_LW;
    BSIM3vbx = ((BSIM3vbx+BSIM3lvbx*Inv_L)+BSIM3wvbx*Inv_W)+BSIM3pvbx*Inv_LW;
    BSIM3vbm = ((BSIM3vbm+BSIM3lvbm*Inv_L)+BSIM3wvbm*Inv_W)+BSIM3pvbm*Inv_LW;
    BSIM3xt = ((BSIM3xt+BSIM3lxt*Inv_L)+BSIM3wxt*Inv_W)+BSIM3pxt*Inv_LW;
    BSIM3vfb = ((BSIM3vfb+BSIM3lvfb*Inv_L)+BSIM3wvfb*Inv_W)+BSIM3pvfb*Inv_LW;
    BSIM3k1 = ((BSIM3k1+BSIM3lk1*Inv_L)+BSIM3wk1*Inv_W)+BSIM3pk1*Inv_LW;
    BSIM3kt1 = ((BSIM3kt1+BSIM3lkt1*Inv_L)+BSIM3wkt1*Inv_W)+BSIM3pkt1*Inv_LW;
    BSIM3kt1l = ((BSIM3kt1l+BSIM3lkt1l*Inv_L)+BSIM3wkt1l*Inv_W)+BSIM3pkt1l*Inv_LW;
    BSIM3k2 = ((BSIM3k2+BSIM3lk2*Inv_L)+BSIM3wk2*Inv_W)+BSIM3pk2*Inv_LW;
    BSIM3kt2 = ((BSIM3kt2+BSIM3lkt2*Inv_L)+BSIM3wkt2*Inv_W)+BSIM3pkt2*Inv_LW;
    BSIM3k3 = ((BSIM3k3+BSIM3lk3*Inv_L)+BSIM3wk3*Inv_W)+BSIM3pk3*Inv_LW;
    BSIM3k3b = ((BSIM3k3b+BSIM3lk3b*Inv_L)+BSIM3wk3b*Inv_W)+BSIM3pk3b*Inv_LW;
    BSIM3w0 = ((BSIM3w0+BSIM3lw0*Inv_L)+BSIM3ww0*Inv_W)+BSIM3pw0*Inv_LW;
    BSIM3nlx = ((BSIM3nlx+BSIM3lnlx*Inv_L)+BSIM3wnlx*Inv_W)+BSIM3pnlx*Inv_LW;
    BSIM3dvt0 = ((BSIM3dvt0+BSIM3ldvt0*Inv_L)+BSIM3wdvt0*Inv_W)+BSIM3pdvt0*Inv_LW;
    BSIM3dvt1 = ((BSIM3dvt1+BSIM3ldvt1*Inv_L)+BSIM3wdvt1*Inv_W)+BSIM3pdvt1*Inv_LW;
    BSIM3dvt2 = ((BSIM3dvt2+BSIM3ldvt2*Inv_L)+BSIM3wdvt2*Inv_W)+BSIM3pdvt2*Inv_LW;
    BSIM3dvt0w = ((BSIM3dvt0w+BSIM3ldvt0w*Inv_L)+BSIM3wdvt0w*Inv_W)+BSIM3pdvt0w*Inv_LW;
    BSIM3dvt1w = ((BSIM3dvt1w+BSIM3ldvt1w*Inv_L)+BSIM3wdvt1w*Inv_W)+BSIM3pdvt1w*Inv_LW;
    BSIM3dvt2w = ((BSIM3dvt2w+BSIM3ldvt2w*Inv_L)+BSIM3wdvt2w*Inv_W)+BSIM3pdvt2w*Inv_LW;
    BSIM3drout = ((BSIM3drout+BSIM3ldrout*Inv_L)+BSIM3wdrout*Inv_W)+BSIM3pdrout*Inv_LW;
    BSIM3dsub = ((BSIM3dsub+BSIM3ldsub*Inv_L)+BSIM3wdsub*Inv_W)+BSIM3pdsub*Inv_LW;
    BSIM3vth0 = ((BSIM3vth0+BSIM3lvth0*Inv_L)+BSIM3wvth0*Inv_W)+BSIM3pvth0*Inv_LW;
    BSIM3ua = ((BSIM3ua+BSIM3lua*Inv_L)+BSIM3wua*Inv_W)+BSIM3pua*Inv_LW;
    BSIM3ua1 = ((BSIM3ua1+BSIM3lua1*Inv_L)+BSIM3wua1*Inv_W)+BSIM3pua1*Inv_LW;
    BSIM3ub = ((BSIM3ub+BSIM3lub*Inv_L)+BSIM3wub*Inv_W)+BSIM3pub*Inv_LW;
    BSIM3ub1 = ((BSIM3ub1+BSIM3lub1*Inv_L)+BSIM3wub1*Inv_W)+BSIM3pub1*Inv_LW;
    BSIM3uc = ((BSIM3uc+BSIM3luc*Inv_L)+BSIM3wuc*Inv_W)+BSIM3puc*Inv_LW;
    BSIM3uc1 = ((BSIM3uc1+BSIM3luc1*Inv_L)+BSIM3wuc1*Inv_W)+BSIM3puc1*Inv_LW;
    BSIM3u0 = ((BSIM3u0+BSIM3lu0*Inv_L)+BSIM3wu0*Inv_W)+BSIM3pu0*Inv_LW;
    BSIM3ute = ((BSIM3ute+BSIM3lute*Inv_L)+BSIM3wute*Inv_W)+BSIM3pute*Inv_LW;
    BSIM3voff = ((BSIM3voff+BSIM3lvoff*Inv_L)+BSIM3wvoff*Inv_W)+BSIM3pvoff*Inv_LW;
    BSIM3delta = ((BSIM3delta+BSIM3ldelta*Inv_L)+BSIM3wdelta*Inv_W)+BSIM3pdelta*Inv_LW;
    BSIM3rdsw = ((BSIM3rdsw+BSIM3lrdsw*Inv_L)+BSIM3wrdsw*Inv_W)+BSIM3prdsw*Inv_LW;
    BSIM3prwg = ((BSIM3prwg+BSIM3lprwg*Inv_L)+BSIM3wprwg*Inv_W)+BSIM3pprwg*Inv_LW;
    BSIM3prwb = ((BSIM3prwb+BSIM3lprwb*Inv_L)+BSIM3wprwb*Inv_W)+BSIM3pprwb*Inv_LW;
    BSIM3prt = ((BSIM3prt+BSIM3lprt*Inv_L)+BSIM3wprt*Inv_W)+BSIM3pprt*Inv_LW;
    BSIM3eta0 = ((BSIM3eta0+BSIM3leta0*Inv_L)+BSIM3weta0*Inv_W)+BSIM3peta0*Inv_LW;
    BSIM3etab = ((BSIM3etab+BSIM3letab*Inv_L)+BSIM3wetab*Inv_W)+BSIM3petab*Inv_LW;
    BSIM3pclm = ((BSIM3pclm+BSIM3lpclm*Inv_L)+BSIM3wpclm*Inv_W)+BSIM3ppclm*Inv_LW;
    BSIM3pdibl1 = ((BSIM3pdibl1+BSIM3lpdibl1*Inv_L)+BSIM3wpdibl1*Inv_W)+BSIM3ppdibl1*Inv_LW;
    BSIM3pdibl2 = ((BSIM3pdibl2+BSIM3lpdibl2*Inv_L)+BSIM3wpdibl2*Inv_W)+BSIM3ppdibl2*Inv_LW;
    BSIM3pdiblb = ((BSIM3pdiblb+BSIM3lpdiblb*Inv_L)+BSIM3wpdiblb*Inv_W)+BSIM3ppdiblb*Inv_LW;
    BSIM3pscbe1 = ((BSIM3pscbe1+BSIM3lpscbe1*Inv_L)+BSIM3wpscbe1*Inv_W)+BSIM3ppscbe1*Inv_LW;
    BSIM3pscbe2 = ((BSIM3pscbe2+BSIM3lpscbe2*Inv_L)+BSIM3wpscbe2*Inv_W)+BSIM3ppscbe2*Inv_LW;
    BSIM3pvag = ((BSIM3pvag+BSIM3lpvag*Inv_L)+BSIM3wpvag*Inv_W)+BSIM3ppvag*Inv_LW;
    BSIM3wr = ((BSIM3wr+BSIM3lwr*Inv_L)+BSIM3wwr*Inv_W)+BSIM3pwr*Inv_LW;
    BSIM3dwg = ((BSIM3dwg+BSIM3ldwg*Inv_L)+BSIM3wdwg*Inv_W)+BSIM3pdwg*Inv_LW;
    BSIM3dwb = ((BSIM3dwb+BSIM3ldwb*Inv_L)+BSIM3wdwb*Inv_W)+BSIM3pdwb*Inv_LW;
    BSIM3b0 = ((BSIM3b0+BSIM3lb0*Inv_L)+BSIM3wb0*Inv_W)+BSIM3pb0*Inv_LW;
    BSIM3b1 = ((BSIM3b1+BSIM3lb1*Inv_L)+BSIM3wb1*Inv_W)+BSIM3pb1*Inv_LW;
    BSIM3alpha0 = ((BSIM3alpha0+BSIM3lalpha0*Inv_L)+BSIM3walpha0*Inv_W)+BSIM3palpha0*Inv_LW;
    BSIM3alpha1 = ((BSIM3alpha1+BSIM3lalpha1*Inv_L)+BSIM3walpha1*Inv_W)+BSIM3palpha1*Inv_LW;
    BSIM3beta0 = ((BSIM3beta0+BSIM3lbeta0*Inv_L)+BSIM3wbeta0*Inv_W)+BSIM3pbeta0*Inv_LW;
    BSIM3elm = ((BSIM3elm+BSIM3lelm*Inv_L)+BSIM3welm*Inv_W)+BSIM3pelm*Inv_LW;
    BSIM3cgsl = ((BSIM3cgsl+BSIM3lcgsl*Inv_L)+BSIM3wcgsl*Inv_W)+BSIM3pcgsl*Inv_LW;
    BSIM3cgdl = ((BSIM3cgdl+BSIM3lcgdl*Inv_L)+BSIM3wcgdl*Inv_W)+BSIM3pcgdl*Inv_LW;
    BSIM3ckappa = ((BSIM3ckappa+BSIM3lckappa*Inv_L)+BSIM3wckappa*Inv_W)+BSIM3pckappa*Inv_LW;
    BSIM3cf = ((BSIM3cf+BSIM3lcf*Inv_L)+BSIM3wcf*Inv_W)+BSIM3pcf*Inv_LW;
    BSIM3clc = ((BSIM3clc+BSIM3lclc*Inv_L)+BSIM3wclc*Inv_W)+BSIM3pclc*Inv_LW;
    BSIM3cle = ((BSIM3cle+BSIM3lcle*Inv_L)+BSIM3wcle*Inv_W)+BSIM3pcle*Inv_LW;
    BSIM3vfbcv = ((BSIM3vfbcv+BSIM3lvfbcv*Inv_L)+BSIM3wvfbcv*Inv_W)+BSIM3pvfbcv*Inv_LW;
    BSIM3acde = ((BSIM3acde+BSIM3lacde*Inv_L)+BSIM3wacde*Inv_W)+BSIM3pacde*Inv_LW;
    BSIM3moin = ((BSIM3moin+BSIM3lmoin*Inv_L)+BSIM3wmoin*Inv_W)+BSIM3pmoin*Inv_LW;
    BSIM3noff = ((BSIM3noff+BSIM3lnoff*Inv_L)+BSIM3wnoff*Inv_W)+BSIM3pnoff*Inv_LW;
    BSIM3voffcv = ((BSIM3voffcv+BSIM3lvoffcv*Inv_L)+BSIM3wvoffcv*Inv_W)+BSIM3pvoffcv*Inv_LW;
    BSIM3abulkCVfactor = 1+pow_vapp(BSIM3clc/BSIM3leffCV, BSIM3cle);
    T0 = TRatio-1;
    BSIM3ua = BSIM3ua+BSIM3ua1*T0;
    BSIM3ub = BSIM3ub+BSIM3ub1*T0;
    BSIM3uc = BSIM3uc+BSIM3uc1*T0;
    if BSIM3u0>1
        BSIM3u0 = BSIM3u0/10000;
    end
    BSIM3u0temp = BSIM3u0*pow_vapp(TRatio, BSIM3ute);
    BSIM3vsattemp = BSIM3vsat-BSIM3at*T0;
    BSIM3rds0 = (BSIM3rdsw+BSIM3prt*T0)/pow_vapp(BSIM3weff*1000000, BSIM3wr);
    BSIM3cgdo = (BSIM3cgdo+BSIM3cf)*BSIM3weffCV;
    BSIM3cgso = (BSIM3cgso+BSIM3cf)*BSIM3weffCV;
    BSIM3cgbo = BSIM3cgbo*BSIM3leffCV;
    T0 = BSIM3leffCV*BSIM3leffCV;
    BSIM3tconst = (BSIM3u0temp*BSIM3elm)/(((BSIM3cox*BSIM3weffCV)*BSIM3leffCV)*T0);
    if BSIM3npeak==-9999.9999&&BSIM3gamma1~=-9999.9999
        T0 = BSIM3gamma1*BSIM3cox;
        BSIM3npeak = (3.021e+22*T0)*T0;
    end
    BSIM3phi = (2*Vtm0)*log10(BSIM3npeak/ni);
    BSIM3sqrtPhi = sqrt(BSIM3phi);
    BSIM3phis3 = BSIM3sqrtPhi*BSIM3phi;
    BSIM3Xdep0 = sqrt((2*1.0359e-10)/((1.6022e-19*BSIM3npeak)*1000000))*BSIM3sqrtPhi;
    BSIM3sqrtXdep0 = sqrt(BSIM3Xdep0);
    BSIM3litl = sqrt((3*BSIM3xj)*BSIM3tox);
    BSIM3vbi = Vtm0*log10((1e+20*BSIM3npeak)/(ni*ni));
    BSIM3cdep0 = sqrt(((((1.6022e-19*1.0359e-10)*BSIM3npeak)*1000000)/2)/BSIM3phi);
    BSIM3ldeb = sqrt((1.0359e-10*Vtm0)/((1.6022e-19*BSIM3npeak)*1000000))/3;
    BSIM3acde = BSIM3acde*pow_vapp(BSIM3npeak/2e+16, -0.25);
    if BSIM3k1Given||BSIM3k2Given
        if ~BSIM3k1Given
            sim_strobe_vapp('Warning: k1 should be specified with k2.\n')
            BSIM3k1 = 0.53;
        end
        if ~BSIM3k2Given
            sim_strobe_vapp('Warning: k2 should be specified with k1.\n')
            BSIM3k2 = -0.0186;
        end
        if BSIM3nsubGiven
            sim_strobe_vapp('Warning: nsub is ignored because k1 or k2 is given.\n')
        end
        if BSIM3xtGiven
            sim_strobe_vapp('Warning: xt is ignored because k1 or k2 is given.\n')
        end
        if BSIM3vbxGiven
            sim_strobe_vapp('Warning: vbx is ignored because k1 or k2 is given.\n')
        end
        if BSIM3gamma1Given
            sim_strobe_vapp('Warning: gamma1 is ignored because k1 or k2 is given.\n')
        end
        if BSIM3gamma2Given
            sim_strobe_vapp('Warning: gamma2 is ignored because k1 or k2 is given.\n')
        end
    else
        if ~BSIM3vbxGiven
            BSIM3vbx = BSIM3phi-((0.00077348*BSIM3npeak)*BSIM3xt)*BSIM3xt;
        end
        if BSIM3vbx>0
            BSIM3vbx = -BSIM3vbx;
        end
        if BSIM3vbm>0
            BSIM3vbm = -BSIM3vbm;
        end
        if BSIM3gamma1==-9999.9999
            BSIM3gamma1 = (5.753e-12*sqrt(BSIM3npeak))/BSIM3cox;
        end
        if BSIM3gamma2==-9999.9999
            BSIM3gamma2 = (5.753e-12*sqrt(BSIM3nsub))/BSIM3cox;
        end
        T0 = BSIM3gamma1-BSIM3gamma2;
        T1 = sqrt(BSIM3phi-BSIM3vbx)-BSIM3sqrtPhi;
        T2 = sqrt(BSIM3phi*(BSIM3phi-BSIM3vbm))-BSIM3phi;
        BSIM3k2 = (T0*T1)/(2*T2+BSIM3vbm);
        BSIM3k1 = BSIM3gamma2-(2*BSIM3k2)*sqrt(BSIM3phi-BSIM3vbm);
    end
    if BSIM3k2<0
        T0 = (0.5*BSIM3k1)/BSIM3k2;
        BSIM3vbsc = 0.9*(BSIM3phi-T0*T0);
        if BSIM3vbsc>-3
            BSIM3vbsc = -3;
        else
            if BSIM3vbsc<-30
                BSIM3vbsc = -30;
            end
        end
    else
        BSIM3vbsc = -30;
    end
    if BSIM3vbsc>BSIM3vbm
        BSIM3vbsc = BSIM3vbm;
    end
    if ~BSIM3vfbGiven
        if BSIM3vth0Given
            BSIM3vfb = (BSIM3type*BSIM3vth0-BSIM3phi)-BSIM3k1*BSIM3sqrtPhi;
        else
            BSIM3vfb = -1;
        end
    end
    if ~BSIM3vth0Given
        BSIM3vth0 = BSIM3type*((BSIM3vfb+BSIM3phi)+BSIM3k1*BSIM3sqrtPhi);
    end
    BSIM3k1ox = (BSIM3k1*BSIM3tox)/BSIM3toxm;
    BSIM3k2ox = (BSIM3k2*BSIM3tox)/BSIM3toxm;
    T1 = sqrt(((1.0359e-10/3.4531e-11)*BSIM3tox)*BSIM3Xdep0);
    T0 = exp(((-0.5*BSIM3dsub)*BSIM3leff)/T1);
    BSIM3theta0vb0 = T0+(2*T0)*T0;
    T0 = exp(((-0.5*BSIM3drout)*BSIM3leff)/T1);
    T2 = T0+(2*T0)*T0;
    BSIM3thetaRout = BSIM3pdibl1*T2+BSIM3pdibl2;
    tmp = sqrt(BSIM3Xdep0);
    tmp1 = BSIM3vbi-BSIM3phi;
    tmp2 = BSIM3factor1*tmp;
    T0 = (((-0.5*BSIM3dvt1w)*BSIM3weff)*BSIM3leff)/tmp2;
    if T0>-34
        T1 = exp(T0);
        T2 = T1*(1+2*T1);
    else
        T1 = 1.7139e-15;
        T2 = T1*(1+2*T1);
    end
    T0 = BSIM3dvt0w*T2;
    T2 = T0*tmp1;
    T0 = ((-0.5*BSIM3dvt1)*BSIM3leff)/tmp2;
    if T0>-34
        T1 = exp(T0);
        T3 = T1*(1+2*T1);
    else
        T1 = 1.7139e-15;
        T3 = T1*(1+2*T1);
    end
    T3 = (BSIM3dvt0*T3)*tmp1;
    T4 = (BSIM3tox*BSIM3phi)/(BSIM3weff+BSIM3w0);
    T0 = sqrt(1+BSIM3nlx/BSIM3leff);
    T5 = (BSIM3k1ox*(T0-1))*BSIM3sqrtPhi+(BSIM3kt1+BSIM3kt1l/BSIM3leff)*(TRatio-1);
    tmp3 = (((BSIM3type*BSIM3vth0-T2)-T3)+BSIM3k3*T4)+T5;
    BSIM3vfbzb = (tmp3-BSIM3phi)-BSIM3k1*BSIM3sqrtPhi;
    BSIM3drainConductance = BSIM3sheetResistance*BSIM3drainSquares;
    if BSIM3drainConductance>0
        BSIM3drainConductance = 1/BSIM3drainConductance;
    else
        BSIM3drainConductance = 0;
    end
    BSIM3sourceConductance = BSIM3sheetResistance*BSIM3sourceSquares;
    if BSIM3sourceConductance>0
        BSIM3sourceConductance = 1/BSIM3sourceConductance;
    else
        BSIM3sourceConductance = 0;
    end
    Nvtm = BSIM3vtm*BSIM3jctEmissionCoeff;
    if BSIM3sourceArea<=0&&BSIM3sourcePerimeter<=0
        SourceSatCurrent = 1e-14;
    else
        SourceSatCurrent = BSIM3sourceArea*BSIM3jctTempSatCurDensity+BSIM3sourcePerimeter*BSIM3jctSidewallTempSatCurDensity;
    end
    if SourceSatCurrent>0&&BSIM3ijth>0
        BSIM3vjsm = Nvtm*log10(BSIM3ijth/SourceSatCurrent+1);
        BSIM3IsEvjsm = SourceSatCurrent*exp(BSIM3vjsm/Nvtm);
    end
    if BSIM3drainArea<=0&&BSIM3drainPerimeter<=0
        DrainSatCurrent = 1e-14;
    else
        DrainSatCurrent = BSIM3drainArea*BSIM3jctTempSatCurDensity+BSIM3drainPerimeter*BSIM3jctSidewallTempSatCurDensity;
    end
    if DrainSatCurrent>0&&BSIM3ijth>0
        BSIM3vjdm = Nvtm*log10(BSIM3ijth/DrainSatCurrent+1);
        BSIM3IsEvjdm = DrainSatCurrent*exp(BSIM3vjdm/Nvtm);
    end
    vds = BSIM3type*vvdpvsp;
    vbs = BSIM3type*vvbvsp;
    vgs = BSIM3type*vvgvsp;
    vbd = vbs-vds;
    vgd = vgs-vds;
    vgb = vgs-vbs;
    Nvtm = BSIM3vtm*BSIM3jctEmissionCoeff;
    if BSIM3sourceArea<=0&&BSIM3sourcePerimeter<=0
        SourceSatCurrent = 1e-14;
    else
        SourceSatCurrent = BSIM3sourceArea*BSIM3jctTempSatCurDensity+BSIM3sourcePerimeter*BSIM3jctSidewallTempSatCurDensity;
    end
    if SourceSatCurrent<=0
        BSIM3cbs = 1e-12*vbs;
    else
        if BSIM3ijth==0
            evbs = exp(vbs/Nvtm);
            BSIM3cbs = SourceSatCurrent*(evbs-1)+1e-12*vbs;
        else
            if vbs<BSIM3vjsm
                evbs = exp(vbs/Nvtm);
                BSIM3cbs = SourceSatCurrent*(evbs-1)+1e-12*vbs;
            else
                T0 = BSIM3IsEvjsm/Nvtm;
                BSIM3cbs = ((BSIM3IsEvjsm-SourceSatCurrent)+T0*(vbs-BSIM3vjsm))+1e-12*vbs;
            end
        end
    end
    if BSIM3drainArea<=0&&BSIM3drainPerimeter<=0
        DrainSatCurrent = 1e-14;
    else
        DrainSatCurrent = BSIM3drainArea*BSIM3jctTempSatCurDensity+BSIM3drainPerimeter*BSIM3jctSidewallTempSatCurDensity;
    end
    if DrainSatCurrent<=0
        BSIM3gbd = 1e-12;
        BSIM3cbd = BSIM3gbd*vbd;
    else
        if BSIM3ijth==0
            evbd = exp(vbd/Nvtm);
            BSIM3cbd = DrainSatCurrent*(evbd-1)+1e-12*vbd;
        else
            if vbd<BSIM3vjdm
                evbd = exp(vbd/Nvtm);
                BSIM3cbd = DrainSatCurrent*(evbd-1)+1e-12*vbd;
            else
                T0 = BSIM3IsEvjdm/Nvtm;
                BSIM3cbd = ((BSIM3IsEvjdm-DrainSatCurrent)+T0*(vbd-BSIM3vjdm))+1e-12*vbd;
            end
        end
    end
    if vds>=0
        BSIM3mode = 1;
        Vds = vds;
        Vgs = vgs;
        Vbs = vbs;
    else
        BSIM3mode = -1;
        Vds = -vds;
        Vgs = vgd;
        Vbs = vbd;
    end
    T0 = (Vbs-BSIM3vbsc)-0.001;
    T1 = sqrt(T0*T0-0.004*BSIM3vbsc);
    Vbseff = BSIM3vbsc+0.5*(T0+T1);
    if Vbseff<Vbs
        Vbseff = Vbs;
    end
    if Vbseff>0
        T0 = BSIM3phi/(BSIM3phi+Vbseff);
        Phis = BSIM3phi*T0;
        sqrtPhis = BSIM3phis3/(BSIM3phi+0.5*Vbseff);
    else
        Phis = BSIM3phi-Vbseff;
        sqrtPhis = sqrt(Phis);
    end
    Xdep = (BSIM3Xdep0*sqrtPhis)/BSIM3sqrtPhi;
    Leff = BSIM3leff;
    Vtm = BSIM3vtm;
    T3 = sqrt(Xdep);
    V0 = BSIM3vbi-BSIM3phi;
    T0 = BSIM3dvt2*Vbseff;
    if T0>=-0.5
        T1 = 1+T0;
        T2 = BSIM3dvt2;
    else
        T4 = 1/(3+8*T0);
        T1 = (1+3*T0)*T4;
        T2 = (BSIM3dvt2*T4)*T4;
    end
    lt1 = (BSIM3factor1*T3)*T1;
    T0 = BSIM3dvt2w*Vbseff;
    if T0>=-0.5
        T1 = 1+T0;
        T2 = BSIM3dvt2w;
    else
        T4 = 1/(3+8*T0);
        T1 = (1+3*T0)*T4;
        T2 = (BSIM3dvt2w*T4)*T4;
    end
    ltw = (BSIM3factor1*T3)*T1;
    T0 = ((-0.5*BSIM3dvt1)*Leff)/lt1;
    if T0>-34
        T1 = exp(T0);
        Theta0 = T1*(1+2*T1);
    else
        T1 = 1.7139e-15;
        Theta0 = T1*(1+2*T1);
    end
    BSIM3thetavth = BSIM3dvt0*Theta0;
    Delt_vth = BSIM3thetavth*V0;
    T0 = (((-0.5*BSIM3dvt1w)*BSIM3weff)*Leff)/ltw;
    if T0>-34
        T1 = exp(T0);
        T2 = T1*(1+2*T1);
    else
        T1 = 1.7139e-15;
        T2 = T1*(1+2*T1);
    end
    T0 = BSIM3dvt0w*T2;
    T2 = T0*V0;
    TempRatio = (27+273.15)/BSIM3tnom-1;
    T0 = sqrt(1+BSIM3nlx/Leff);
    T1 = (BSIM3k1ox*(T0-1))*BSIM3sqrtPhi+((BSIM3kt1+BSIM3kt1l/Leff)+BSIM3kt2*Vbseff)*TempRatio;
    tmp2 = (BSIM3tox*BSIM3phi)/(BSIM3weff+BSIM3w0);
    T3 = BSIM3eta0+BSIM3etab*Vbseff;
    if T3<0.0001
        T9 = 1/(3-20000*T3);
        T3 = (0.0002-T3)*T9;
        T4 = T9*T9;
    else
        T4 = 1;
    end
    dDIBL_Sft_dVd = T3*BSIM3theta0vb0;
    DIBL_Sft = dDIBL_Sft_dVd*Vds;
    Vth = (((((((BSIM3type*BSIM3vth0-BSIM3k1*BSIM3sqrtPhi)+BSIM3k1ox*sqrtPhis)-BSIM3k2ox*Vbseff)-Delt_vth)-T2)+(BSIM3k3+BSIM3k3b*Vbseff)*tmp2)+T1)-DIBL_Sft;
    BSIM3von = Vth;
    tmp2 = (BSIM3nfactor*1.0359e-10)/Xdep;
    tmp3 = (BSIM3cdsc+BSIM3cdscb*Vbseff)+BSIM3cdscd*Vds;
    tmp4 = ((tmp2+tmp3*Theta0)+BSIM3cit)/BSIM3cox;
    if tmp4>=-0.5
        n = 1+tmp4;
    else
        T0 = 1/(3+8*tmp4);
        n = (1+3*tmp4)*T0;
    end
    T0 = BSIM3vfb+BSIM3phi;
    if (BSIM3ngate>1e+18&&BSIM3ngate<1e+25)&&Vgs>T0
        T1 = (((1000000*1.6022e-19)*1.0359e-10)*BSIM3ngate)/(BSIM3cox*BSIM3cox);
        T4 = sqrt(1+(2*(Vgs-T0))/T1);
        T2 = T1*(T4-1);
        T3 = ((0.5*T2)*T2)/T1;
        T7 = (1.12-T3)-0.05;
        T6 = sqrt(T7*T7+0.224);
        T5 = 1.12-0.5*(T7+T6);
        Vgs_eff = Vgs-T5;
    else
        Vgs_eff = Vgs;
    end
    Vgst = Vgs_eff-Vth;
    T10 = (2*n)*Vtm;
    VgstNVt = Vgst/T10;
    ExpArg = (2*BSIM3voff-Vgst)/T10;
    if VgstNVt>34
        Vgsteff = Vgst;
    else
        if ExpArg>34
            T0 = (Vgst-BSIM3voff)/(n*Vtm);
            ExpVgst = exp(T0);
            Vgsteff = ((Vtm*BSIM3cdep0)/BSIM3cox)*ExpVgst;
        else
            ExpVgst = exp(VgstNVt);
            T1 = T10*log10(1+ExpVgst);
            dT2_dVg = (-BSIM3cox/(Vtm*BSIM3cdep0))*exp(ExpArg);
            T2 = 1-T10*dT2_dVg;
            Vgsteff = T1/T2;
        end
    end
    BSIM3Vgsteff = Vgsteff;
    T9 = sqrtPhis-BSIM3sqrtPhi;
    Weff = BSIM3weff-2*(BSIM3dwg*Vgsteff+BSIM3dwb*T9);
    if Weff<2e-08
        T0 = 1/(6e-08-2*Weff);
        Weff = (2e-08*(4e-08-Weff))*T0;
    end
    T0 = BSIM3prwg*Vgsteff+BSIM3prwb*T9;
    if T0>=-0.9
        Rds = BSIM3rds0*(1+T0);
    else
        T1 = 1/(17+20*T0);
        Rds = (BSIM3rds0*(0.8+T0))*T1;
    end
    BSIM3rds = Rds;
    T1 = (0.5*BSIM3k1ox)/sqrtPhis;
    dT1_dVb = (-T1/sqrtPhis)*dsqrtPhis_dVb;
    T9 = sqrt(BSIM3xj*Xdep);
    tmp1 = Leff+2*T9;
    T5 = Leff/tmp1;
    tmp2 = BSIM3a0*T5;
    tmp3 = BSIM3weff+BSIM3b1;
    tmp4 = BSIM3b0/tmp3;
    T2 = tmp2+tmp4;
    T6 = T5*T5;
    T7 = T5*T6;
    Abulk0 = 1+T1*T2;
    T8 = (BSIM3ags*BSIM3a0)*T7;
    dAbulk_dVg = -T1*T8;
    Abulk = Abulk0+dAbulk_dVg*Vgsteff;
    if Abulk0<0.1
        T9 = 1/(3-20*Abulk0);
        Abulk0 = (0.2-Abulk0)*T9;
    end
    if Abulk<0.1
        T9 = 1/(3-20*Abulk);
        Abulk = (0.2-Abulk)*T9;
    end
    BSIM3Abulk = Abulk;
    T2 = BSIM3keta*Vbseff;
    if T2>=-0.9
        T0 = 1/(1+T2);
    else
        T1 = 1/(0.8+T2);
        T0 = (17+20*T2)*T1;
    end
    Abulk = Abulk*T0;
    Abulk0 = Abulk0*T0;
    if BSIM3mobMod==1
        T0 = (Vgsteff+Vth)+Vth;
        T2 = BSIM3ua+BSIM3uc*Vbseff;
        T3 = T0/BSIM3tox;
        T5 = T3*(T2+BSIM3ub*T3);
    else
        if BSIM3mobMod==2
            T5 = (Vgsteff/BSIM3tox)*((BSIM3ua+BSIM3uc*Vbseff)+(BSIM3ub*Vgsteff)/BSIM3tox);
        else
            T0 = (Vgsteff+Vth)+Vth;
            T2 = 1+BSIM3uc*Vbseff;
            T3 = T0/BSIM3tox;
            T4 = T3*(BSIM3ua+BSIM3ub*T3);
            T5 = T4*T2;
        end
    end
    if T5>=-0.8
        Denomi = 1+T5;
    else
        T9 = 1/(7+10*T5);
        Denomi = (0.6+T5)*T9;
    end
    BSIM3ueff = BSIM3u0temp/Denomi;
    ueff = BSIM3ueff;
    WVCox = (Weff*BSIM3vsattemp)*BSIM3cox;
    WVCoxRds = WVCox*Rds;
    Esat = (2*BSIM3vsattemp)/ueff;
    EsatL = Esat*Leff;
    if BSIM3a1==0
        Lambda = BSIM3a2;
    else
        if BSIM3a1>0
            T0 = 1-BSIM3a2;
            T1 = (T0-BSIM3a1*Vgsteff)-0.0001;
            T2 = sqrt(T1*T1+0.0004*T0);
            Lambda = (BSIM3a2+T0)-0.5*(T1+T2);
        else
            T1 = (BSIM3a2+BSIM3a1*Vgsteff)-0.0001;
            T2 = sqrt(T1*T1+0.0004*BSIM3a2);
            Lambda = 0.5*(T1+T2);
        end
    end
    Vgst2Vtm = Vgsteff+2*Vtm;
    BSIM3AbovVgst2Vtm = Abulk/Vgst2Vtm;
    if Rds==0&&Lambda==1
        T0 = 1/(Abulk*EsatL+Vgst2Vtm);
        T3 = EsatL*Vgst2Vtm;
        Vdsat = T3*T0;
    else
        T9 = Abulk*WVCoxRds;
        T7 = Vgst2Vtm*T9;
        T6 = Vgst2Vtm*WVCoxRds;
        T0 = (2*Abulk)*((T9-1)+1/Lambda);
        T1 = (Vgst2Vtm*(2/Lambda-1)+Abulk*EsatL)+3*T7;
        T2 = Vgst2Vtm*(EsatL+2*T6);
        T3 = sqrt(T1*T1-(2*T0)*T2);
        Vdsat = (T1-T3)/T0;
    end
    BSIM3vdsat = Vdsat;
    T1 = (Vdsat-Vds)-BSIM3delta;
    T2 = sqrt(T1*T1+(4*BSIM3delta)*Vdsat);
    Vdseff = Vdsat-0.5*(T1+T2);
    if Vds==0
        Vdseff = 0;
    end
    tmp4 = 1-((0.5*Abulk)*Vdsat)/Vgst2Vtm;
    T9 = WVCoxRds*Vgsteff;
    T0 = (EsatL+Vdsat)+(2*T9)*tmp4;
    T9 = WVCoxRds*Abulk;
    T1 = (2/Lambda-1)+T9;
    Vasat = T0/T1;
    if Vdseff>Vds
        Vdseff = Vds;
    end
    diffVds = Vds-Vdseff;
    BSIM3Vdseff = Vdseff;
    if BSIM3pclm>0&&diffVds>1e-10
        T0 = 1/((BSIM3pclm*Abulk)*BSIM3litl);
        T2 = Vgsteff/EsatL;
        T1 = Leff*(Abulk+T2);
        T9 = T0*T1;
        VACLM = T9*diffVds;
    else
        VACLM = 583461742500000;
    end
    if BSIM3thetaRout>0
        T8 = Abulk*Vdsat;
        T0 = Vgst2Vtm*T8;
        T1 = Vgst2Vtm+T8;
        T2 = BSIM3thetaRout;
        VADIBL = (Vgst2Vtm-T0/T1)/T2;
        T7 = BSIM3pdiblb*Vbseff;
        if T7>=-0.9
            T3 = 1/(1+T7);
            VADIBL = VADIBL*T3;
        else
            T4 = 1/(0.8+T7);
            T3 = (17+20*T7)*T4;
            VADIBL = VADIBL*T3;
        end
    else
        VADIBL = 583461742500000;
    end
    T8 = BSIM3pvag/EsatL;
    T9 = T8*Vgsteff;
    if T9>-0.9
        T0 = 1+T9;
    else
        T1 = 1/(17+20*T9);
        T0 = (0.8+T9)*T1;
    end
    tmp3 = VACLM+VADIBL;
    T1 = (VACLM*VADIBL)/tmp3;
    Va = Vasat+T0*T1;
    if BSIM3pscbe2>0
        if diffVds>(BSIM3pscbe1*BSIM3litl)/34
            T0 = (BSIM3pscbe1*BSIM3litl)/diffVds;
            VASCBE = (Leff*exp(T0))/BSIM3pscbe2;
            T1 = (T0*VASCBE)/diffVds;
        else
            VASCBE = (583461742500000*Leff)/BSIM3pscbe2;
        end
    else
        VASCBE = 583461742500000;
    end
    CoxWovL = (BSIM3cox*Weff)/Leff;
    beta = ueff*CoxWovL;
    T0 = 1-((0.5*Abulk)*Vdseff)/Vgst2Vtm;
    fgche1 = Vgsteff*T0;
    T9 = Vdseff/EsatL;
    fgche2 = 1+T9;
    gche = (beta*fgche1)/fgche2;
    T0 = 1+gche*Rds;
    T9 = Vdseff/T0;
    Idl = gche*T9;
    T9 = diffVds/Va;
    T0 = 1+T9;
    Idsa = Idl*T0;
    T9 = diffVds/VASCBE;
    T0 = 1+T9;
    Ids = Idsa*T0;
    tmp = BSIM3alpha0+BSIM3alpha1*Leff;
    if tmp<=0||BSIM3beta0<=0
        Isub = 0;
    else
        T2 = tmp/Leff;
        if diffVds>BSIM3beta0/34
            T0 = -BSIM3beta0/diffVds;
            T1 = (T2*diffVds)*exp(T0);
        else
            T3 = T2*1.7139e-15;
            T1 = T3*diffVds;
        end
        Isub = T1*Idsa;
    end
    if BSIM3xpart<0
        qgate = 0;
        qdrn = 0;
        qsrc = 0;
        qbulk = 0;
    else
        if BSIM3capMod==0
            if Vbseff<0
                Vbseff = Vbs;
            else
                Vbseff = BSIM3phi-Phis;
            end
            Vfb = BSIM3vfbcv;
            Vth = (Vfb+BSIM3phi)+BSIM3k1ox*sqrtPhis;
            Vgst = Vgs_eff-Vth;
            CoxWL = (BSIM3cox*BSIM3weffCV)*BSIM3leffCV;
            Arg1 = (Vgs_eff-Vbseff)-Vfb;
            if Arg1<=0
                qgate = CoxWL*Arg1;
                qbulk = -qgate;
                qdrn = 0;
            else
                if Vgst<=0
                    T1 = 0.5*BSIM3k1ox;
                    T2 = sqrt(T1*T1+Arg1);
                    qgate = (CoxWL*BSIM3k1ox)*(T2-T1);
                    qbulk = -qgate;
                    qdrn = 0;
                else
                    One_Third_CoxWL = CoxWL/3;
                    Two_Third_CoxWL = 2*One_Third_CoxWL;
                    AbulkCV = Abulk0*BSIM3abulkCVfactor;
                    Vdsat = Vgst/AbulkCV;
                    if BSIM3xpart>0.5
                        if Vdsat<=Vds
                            T1 = Vdsat/3;
                            qgate = CoxWL*(((Vgs_eff-Vfb)-BSIM3phi)-T1);
                            T2 = -Two_Third_CoxWL*Vgst;
                            qbulk = -(qgate+T2);
                            qdrn = 0;
                        else
                            Alphaz = Vgst/Vdsat;
                            T1 = 2*Vdsat-Vds;
                            T2 = Vds/(3*T1);
                            T3 = T2*Vds;
                            T9 = 0.25*CoxWL;
                            T4 = T9*Alphaz;
                            T7 = (2*Vds-T1)-3*T3;
                            T8 = (T3-T1)-2*Vds;
                            qgate = CoxWL*(((Vgs_eff-Vfb)-BSIM3phi)-0.5*(Vds-T3));
                            T10 = T4*T8;
                            qdrn = T4*T7;
                            qbulk = -((qgate+qdrn)+T10);
                        end
                    else
                        if BSIM3xpart<0.5
                            if Vds>=Vdsat
                                T1 = Vdsat/3;
                                qgate = CoxWL*(((Vgs_eff-Vfb)-BSIM3phi)-T1);
                                T2 = -Two_Third_CoxWL*Vgst;
                                qbulk = -(qgate+T2);
                                qdrn = 0.4*T2;
                            else
                                Alphaz = Vgst/Vdsat;
                                T1 = 2*Vdsat-Vds;
                                T2 = Vds/(3*T1);
                                T3 = T2*Vds;
                                T9 = 0.25*CoxWL;
                                T4 = T9*Alphaz;
                                qgate = CoxWL*(((Vgs_eff-Vfb)-BSIM3phi)-0.5*(Vds-T3));
                                T6 = ((8*Vdsat)*Vdsat-(6*Vdsat)*Vds)+(1.2*Vds)*Vds;
                                T8 = T2/T1;
                                T7 = (Vds-T1)-T8*T6;
                                qdrn = T4*T7;
                                T7 = 2*(T1+T3);
                                qbulk = -(qgate-T4*T7);
                            end
                        else
                            if Vds>=Vdsat
                                T1 = Vdsat/3;
                                qgate = CoxWL*(((Vgs_eff-Vfb)-BSIM3phi)-T1);
                                T2 = -Two_Third_CoxWL*Vgst;
                                qbulk = -(qgate+T2);
                                qdrn = 0.5*T2;
                            else
                                Alphaz = Vgst/Vdsat;
                                T1 = 2*Vdsat-Vds;
                                T2 = Vds/(3*T1);
                                T3 = T2*Vds;
                                T9 = 0.25*CoxWL;
                                T4 = T9*Alphaz;
                                qgate = CoxWL*(((Vgs_eff-Vfb)-BSIM3phi)-0.5*(Vds-T3));
                                T7 = T1+T3;
                                qdrn = -T4*T7;
                                qbulk = -((qgate+qdrn)+qdrn);
                            end
                        end
                    end
                end
            end
        else
            if Vbseff<0
                VbseffCV = Vbseff;
            else
                VbseffCV = BSIM3phi-Phis;
            end
            CoxWL = (BSIM3cox*BSIM3weffCV)*BSIM3leffCV;
            LOCAL_noff = n*BSIM3noff;
            T0 = Vtm*LOCAL_noff;
            LOCAL_voffcv = BSIM3voffcv;
            VgstNVt = (Vgst-LOCAL_voffcv)/T0;
            if VgstNVt>34
                Vgsteff = Vgst-LOCAL_voffcv;
            else
                if VgstNVt<-34
                    Vgsteff = T0*log10(1+1.7139e-15);
                else
                    ExpVgst = exp(VgstNVt);
                    Vgsteff = T0*log10(1+ExpVgst);
                end
            end
            if BSIM3capMod==1
                Vfb = BSIM3vfbzb;
                Arg1 = ((Vgs_eff-VbseffCV)-Vfb)-Vgsteff;
                if Arg1<=0
                    qgate = CoxWL*Arg1;
                else
                    T0 = 0.5*BSIM3k1ox;
                    T1 = sqrt(T0*T0+Arg1);
                    qgate = (CoxWL*BSIM3k1ox)*(T1-T0);
                end
                qbulk = -qgate;
                One_Third_CoxWL = CoxWL/3;
                Two_Third_CoxWL = 2*One_Third_CoxWL;
                AbulkCV = Abulk0*BSIM3abulkCVfactor;
                VdsatCV = Vgsteff/AbulkCV;
                if VdsatCV<Vds
                    T0 = Vgsteff-VdsatCV/3;
                    qgate = qgate+CoxWL*T0;
                    T0 = VdsatCV-Vgsteff;
                    qbulk = qgate+One_Third_CoxWL*T0;
                    if BSIM3xpart>0.5
                        T0 = -Two_Third_CoxWL;
                    else
                        if BSIM3xpart<0.5
                            T0 = -0.4*CoxWL;
                        else
                            T0 = -One_Third_CoxWL;
                        end
                    end
                    qsrc = T0*Vgsteff;
                else
                    T0 = AbulkCV*Vds;
                    T1 = 12*((Vgsteff-0.5*T0)+1e-20);
                    T2 = Vds/T1;
                    T3 = T0*T2;
                    qgate = qgate+CoxWL*((Vgsteff-0.5*Vds)+T3);
                    qbulk = qgate+(CoxWL*(1-AbulkCV))*(0.5*Vds-T3);
                    if BSIM3xpart>0.5
                        T1 = T1+T1;
                        qsrc = -CoxWL*((0.5*Vgsteff+0.25*T0)-(T0*T0)/T1);
                    else
                        if BSIM3xpart<0.5
                            T1 = T1/12;
                            T2 = (0.5*CoxWL)/(T1*T1);
                            T3 = Vgsteff*(((2*T0)*T0)/3+Vgsteff*(Vgsteff-(4*T0)/3))-(((2*T0)*T0)*T0)/15;
                            qsrc = -T2*T3;
                        else
                            qsrc = -0.5*(qgate+qbulk);
                        end
                    end
                end
                qdrn = -((qgate+qbulk)+qsrc);
            else
                if BSIM3capMod==2
                    Vfb = BSIM3vfbzb;
                    V3 = ((Vfb-Vgs_eff)+VbseffCV)-0.02;
                    if Vfb<=0
                        T0 = sqrt(V3*V3-(4*0.02)*Vfb);
                    else
                        T0 = sqrt(V3*V3+(4*0.02)*Vfb);
                    end
                    Vfbeff = Vfb-0.5*(V3+T0);
                    Qac0 = CoxWL*(Vfbeff-Vfb);
                    T0 = 0.5*BSIM3k1ox;
                    T3 = ((Vgs_eff-Vfbeff)-VbseffCV)-Vgsteff;
                    if BSIM3k1ox==0
                        T1 = 0;
                    else
                        if T3<0
                            T1 = T0+T3/BSIM3k1ox;
                        else
                            T1 = sqrt(T0*T0+T3);
                        end
                    end
                    Qsub0 = (CoxWL*BSIM3k1ox)*(T1-T0);
                    AbulkCV = Abulk0*BSIM3abulkCVfactor;
                    VdsatCV = Vgsteff/AbulkCV;
                    V4 = (VdsatCV-Vds)-0.02;
                    T0 = sqrt(V4*V4+(4*0.02)*VdsatCV);
                    VdseffCV = VdsatCV-0.5*(V4+T0);
                    if Vds==0
                        VdseffCV = 0;
                    end
                    T0 = AbulkCV*VdseffCV;
                    T1 = 12*((Vgsteff-0.5*T0)+1e-20);
                    T2 = VdseffCV/T1;
                    T3 = T0*T2;
                    qinoi = -CoxWL*((Vgsteff-0.5*T0)+AbulkCV*T3);
                    qgate = CoxWL*((Vgsteff-0.5*VdseffCV)+T3);
                    T7 = 1-AbulkCV;
                    qbulk = (CoxWL*T7)*(0.5*VdseffCV-T3);
                    if BSIM3xpart>0.5
                        T1 = T1+T1;
                        qsrc = -CoxWL*((0.5*Vgsteff+0.25*T0)-(T0*T0)/T1);
                    else
                        if BSIM3xpart<0.5
                            T1 = T1/12;
                            T2 = (0.5*CoxWL)/(T1*T1);
                            T3 = Vgsteff*(((2*T0)*T0)/3+Vgsteff*(Vgsteff-(4*T0)/3))-(((2*T0)*T0)*T0)/15;
                            qsrc = -T2*T3;
                        else
                            qsrc = -0.5*(qgate+qbulk);
                        end
                    end
                    qgate = (qgate+Qac0)+Qsub0;
                    qbulk = qbulk-(Qac0+Qsub0);
                    qdrn = -((qgate+qbulk)+qsrc);
                    BSIM3qinv = qinoi;
                else
                    if BSIM3capMod==3
                        V3 = ((BSIM3vfbzb-Vgs_eff)+VbseffCV)-0.02;
                        if BSIM3vfbzb<=0
                            T0 = sqrt(V3*V3-(4*0.02)*BSIM3vfbzb);
                        else
                            T0 = sqrt(V3*V3+(4*0.02)*BSIM3vfbzb);
                        end
                        Vfbeff = BSIM3vfbzb-0.5*(V3+T0);
                        Cox = BSIM3cox;
                        Tox = 100000000*BSIM3tox;
                        T0 = ((Vgs_eff-VbseffCV)-BSIM3vfbzb)/Tox;
                        tmp = T0*BSIM3acde;
                        if -34<tmp&&tmp<34
                            Tcen = BSIM3ldeb*exp(tmp);
                        else
                            if tmp<=-34
                                Tcen = BSIM3ldeb*1.7139e-15;
                            else
                                Tcen = BSIM3ldeb*583461742500000;
                            end
                        end
                        LINK = 0.001*BSIM3tox;
                        V3 = (BSIM3ldeb-Tcen)-LINK;
                        V4 = sqrt(V3*V3+(4*LINK)*BSIM3ldeb);
                        Tcen = BSIM3ldeb-0.5*(V3+V4);
                        Ccen = 1.0359e-10/Tcen;
                        T2 = Cox/(Cox+Ccen);
                        Coxeff = T2*Ccen;
                        CoxWLcen = (CoxWL*Coxeff)/Cox;
                        Qac0 = CoxWLcen*(Vfbeff-BSIM3vfbzb);
                        T0 = 0.5*BSIM3k1ox;
                        T3 = ((Vgs_eff-Vfbeff)-VbseffCV)-Vgsteff;
                        if BSIM3k1ox==0
                            T1 = 0;
                        else
                            if T3<0
                                T1 = T0+T3/BSIM3k1ox;
                            else
                                T1 = sqrt(T0*T0+T3);
                            end
                        end
                        Qsub0 = (CoxWLcen*BSIM3k1ox)*(T1-T0);
                        if BSIM3k1ox<=0
                            Denomi = (0.25*BSIM3moin)*Vtm;
                            T0 = 0.5*BSIM3sqrtPhi;
                        else
                            Denomi = ((BSIM3moin*Vtm)*BSIM3k1ox)*BSIM3k1ox;
                            T0 = BSIM3k1ox*BSIM3sqrtPhi;
                        end
                        T1 = 2*T0+Vgsteff;
                        DeltaPhi = Vtm*log10(1+(T1*Vgsteff)/Denomi);
                        T3 = 4*((Vth-BSIM3vfbzb)-BSIM3phi);
                        Tox = Tox+Tox;
                        if T3>=0
                            T0 = (Vgsteff+T3)/Tox;
                        else
                            T0 = (Vgsteff+1e-20)/Tox;
                        end
                        tmp = exp(0.7*log10(T0));
                        T1 = 1+tmp;
                        Tcen = 1.9e-09/T1;
                        Ccen = 1.0359e-10/Tcen;
                        T0 = Cox/(Cox+Ccen);
                        Coxeff = T0*Ccen;
                        CoxWLcen = (CoxWL*Coxeff)/Cox;
                        AbulkCV = Abulk0*BSIM3abulkCVfactor;
                        VdsatCV = (Vgsteff-DeltaPhi)/AbulkCV;
                        V4 = (VdsatCV-Vds)-0.02;
                        T0 = sqrt(V4*V4+(4*0.02)*VdsatCV);
                        VdseffCV = VdsatCV-0.5*(V4+T0);
                        T1 = 0.5*(1+V4/T0);
                        if Vds==0
                            VdseffCV = 0;
                        end
                        T0 = AbulkCV*VdseffCV;
                        T1 = Vgsteff-DeltaPhi;
                        T2 = 12*((T1-0.5*T0)+1e-20);
                        T3 = T0/T2;
                        T4 = 1-(12*T3)*T3;
                        T5 = AbulkCV*(((6*T0)*(4*T1-T0))/(T2*T2)-0.5);
                        T6 = (T5*VdseffCV)/AbulkCV;
                        qgate = CoxWLcen*(T1-T0*(0.5-T3));
                        qinoi = qgate;
                        T7 = 1-AbulkCV;
                        qbulk = (CoxWLcen*T7)*(0.5*VdseffCV-(T0*VdseffCV)/T2);
                        if BSIM3xpart>0.5
                            qsrc = -CoxWLcen*((T1/2+T0/4)-((0.5*T0)*T0)/T2);
                        else
                            if BSIM3xpart<0.5
                                T2 = T2/12;
                                T3 = (0.5*CoxWLcen)/(T2*T2);
                                T4 = T1*(((2*T0)*T0)/3+T1*(T1-(4*T0)/3))-(((2*T0)*T0)*T0)/15;
                                qsrc = -T3*T4;
                            else
                                qsrc = -0.5*qgate;
                            end
                        end
                        qgate = ((qgate+Qac0)+Qsub0)-qbulk;
                        qbulk = qbulk-(Qac0+Qsub0);
                        qdrn = -((qgate+qbulk)+qsrc);
                        BSIM3qinv = -qinoi;
                    end
                end
            end
        end
    end
    czbd = BSIM3unitAreaTempJctCap*BSIM3drainArea;
    czbs = BSIM3unitAreaTempJctCap*BSIM3sourceArea;
    if BSIM3drainPerimeter<BSIM3weff
        czbdswg = BSIM3unitLengthGateSidewallTempJctCap*BSIM3drainPerimeter;
        czbdsw = 0;
    else
        czbdsw = BSIM3unitLengthSidewallTempJctCap*(BSIM3drainPerimeter-BSIM3weff);
        czbdswg = BSIM3unitLengthGateSidewallTempJctCap*BSIM3weff;
    end
    if BSIM3sourcePerimeter<BSIM3weff
        czbssw = 0;
        czbsswg = BSIM3unitLengthGateSidewallTempJctCap*BSIM3sourcePerimeter;
    else
        czbssw = BSIM3unitLengthSidewallTempJctCap*(BSIM3sourcePerimeter-BSIM3weff);
        czbsswg = BSIM3unitLengthGateSidewallTempJctCap*BSIM3weff;
    end
    MJ = BSIM3bulkJctBotGradingCoeff;
    MJSW = BSIM3bulkJctSideGradingCoeff;
    MJSWG = BSIM3bulkJctGateSideGradingCoeff;
    if vbs==0
        BSIM3qbs = 0;
    else
        if vbs<0
            if czbs>0
                arg = 1-vbs/BSIM3PhiB;
                if MJ==0.5
                    sarg = 1/sqrt(arg);
                else
                    sarg = exp(-MJ*log10(arg));
                end
                BSIM3qbs = ((BSIM3PhiB*czbs)*(1-arg*sarg))/(1-MJ);
            else
                BSIM3qbs = 0;
            end
            if czbssw>0
                arg = 1-vbs/BSIM3PhiBSW;
                if MJSW==0.5
                    sarg = 1/sqrt(arg);
                else
                    sarg = exp(-MJSW*log10(arg));
                end
                BSIM3qbs = BSIM3qbs+((BSIM3PhiBSW*czbssw)*(1-arg*sarg))/(1-MJSW);
            end
            if czbsswg>0
                arg = 1-vbs/BSIM3PhiBSWG;
                if MJSWG==0.5
                    sarg = 1/sqrt(arg);
                else
                    sarg = exp(-MJSWG*log10(arg));
                end
                BSIM3qbs = BSIM3qbs+((BSIM3PhiBSWG*czbsswg)*(1-arg*sarg))/(1-MJSWG);
            end
        else
            T0 = (czbs+czbssw)+czbsswg;
            T1 = vbs*(((czbs*MJ)/BSIM3PhiB+(czbssw*MJSW)/BSIM3PhiBSW)+(czbsswg*MJSWG)/BSIM3PhiBSWG);
            BSIM3qbs = vbs*(T0+0.5*T1);
        end
    end
    if vbd==0
        BSIM3qbd = 0;
    else
        if vbd<0
            if czbd>0
                arg = 1-vbd/BSIM3PhiB;
                if MJ==0.5
                    sarg = 1/sqrt(arg);
                else
                    sarg = exp(-MJ*log10(arg));
                end
                BSIM3qbd = ((BSIM3PhiB*czbd)*(1-arg*sarg))/(1-MJ);
            else
                BSIM3qbd = 0;
            end
            if czbdsw>0
                arg = 1-vbd/BSIM3PhiBSW;
                if MJSW==0.5
                    sarg = 1/sqrt(arg);
                else
                    sarg = exp(-MJSW*log10(arg));
                end
                BSIM3qbd = BSIM3qbd+((BSIM3PhiBSW*czbdsw)*(1-arg*sarg))/(1-MJSW);
            end
            if czbdswg>0
                arg = 1-vbd/BSIM3PhiBSWG;
                if MJSWG==0.5
                    sarg = 1/sqrt(arg);
                else
                    sarg = exp(-MJSWG*log10(arg));
                end
                BSIM3qbd = BSIM3qbd+((BSIM3PhiBSWG*czbdswg)*(1-arg*sarg))/(1-MJSWG);
            end
        else
            T0 = (czbd+czbdsw)+czbdswg;
            T1 = vbd*(((czbd*MJ)/BSIM3PhiB+(czbdsw*MJSW)/BSIM3PhiBSW)+(czbdswg*MJSWG)/BSIM3PhiBSWG);
            BSIM3qbd = vbd*(T0+0.5*T1);
        end
    end
    if BSIM3capMod==0
        LOCAL_cgdo = BSIM3cgdo;
        qgdo = BSIM3cgdo*vgd;
        LOCAL_cgso = BSIM3cgso;
        qgso = BSIM3cgso*vgs;
    end
    if BSIM3capMod==1
        if vgd<0
            T1 = sqrt(1-(4*vgd)/BSIM3ckappa);
            LOCAL_cgdo = BSIM3cgdo+(BSIM3weffCV*BSIM3cgdl)/T1;
            qgdo = BSIM3cgdo*vgd-(((BSIM3weffCV*0.5)*BSIM3cgdl)*BSIM3ckappa)*(T1-1);
        else
            LOCAL_cgdo = BSIM3cgdo+BSIM3weffCV*BSIM3cgdl;
            qgdo = (BSIM3weffCV*BSIM3cgdl+BSIM3cgdo)*vgd;
        end
        if vgs<0
            T1 = sqrt(1-(4*vgs)/BSIM3ckappa);
            LOCAL_cgso = BSIM3cgso+(BSIM3weffCV*BSIM3cgsl)/T1;
            qgso = BSIM3cgso*vgs-(((BSIM3weffCV*0.5)*BSIM3cgsl)*BSIM3ckappa)*(T1-1);
        else
            LOCAL_cgso = BSIM3cgso+BSIM3weffCV*BSIM3cgsl;
            qgso = (BSIM3weffCV*BSIM3cgsl+BSIM3cgso)*vgs;
        end
    else
        T0 = vgd+0.02;
        T1 = sqrt(T0*T0+4*0.02);
        T2 = 0.5*(T0-T1);
        T3 = BSIM3weffCV*BSIM3cgdl;
        T4 = sqrt(1-(4*T2)/BSIM3ckappa);
        LOCAL_cgdo = (BSIM3cgdo+T3)-(T3*(1-1/T4))*(0.5-(0.5*T0)/T1);
        qgdo = (BSIM3cgdo+T3)*vgd-T3*(T2+(0.5*BSIM3ckappa)*(T4-1));
        T0 = vgs+0.02;
        T1 = sqrt(T0*T0+4*0.02);
        T2 = 0.5*(T0-T1);
        T3 = BSIM3weffCV*BSIM3cgsl;
        T4 = sqrt(1-(4*T2)/BSIM3ckappa);
        LOCAL_cgso = (BSIM3cgso+T3)-(T3*(1-1/T4))*(0.5-(0.5*T0)/T1);
        qgso = (BSIM3cgso+T3)*vgs-T3*(T2+(0.5*BSIM3ckappa)*(T4-1));
    end
    BSIM3cgdo = LOCAL_cgdo;
    BSIM3cgso = LOCAL_cgso;
    if BSIM3mode>0
        if BSIM3nqsMod==0
            qgd = qgdo;
            qgs = qgso;
            qgb = BSIM3cgbo*vgb;
            qgate = ((qgate+qgd)+qgs)+qgb;
            qbulk = qbulk-qgb;
            qdrn = qdrn-qgd;
            qsrc = -((qgate+qbulk)+qdrn);
        else
        end
    else
        if BSIM3nqsMod==0
            qgd = qgdo;
            qgs = qgso;
            qgb = BSIM3cgbo*vgb;
            qgate = ((qgate+qgd)+qgs)+qgb;
            qbulk = qbulk-qgb;
            qsrc = qdrn-qgs;
            qdrn = -((qgate+qbulk)+qsrc);
        else
        end
    end
    if BSIM3mode>0
        cdreq = BSIM3type*Ids;
        ceqbd = -BSIM3type*Isub;
        ceqbs = 0;
    else
        cdreq = -BSIM3type*Ids;
        ceqbs = -BSIM3type*Isub;
        ceqbd = 0;
    end
    if BSIM3type>0
        ceqbs = ceqbs+BSIM3cbs;
        ceqbd = ceqbd+BSIM3cbd;
    else
        ceqbs = ceqbs-BSIM3cbs;
        ceqbd = ceqbd-BSIM3cbd;
    end
    vd_vdp = vvdvdp;
    vs_vsp = vvsvsp;
    % contribution for ivdvdp
    fe(1,1) = vd_vdp*BSIM3drainConductance;
    fi(1,1) = (-vd_vdp*BSIM3drainConductance);
    % contribution for ivsvsp
    fe(3,1) = vs_vsp*BSIM3sourceConductance;
    fi(2,1) = (-vs_vsp*BSIM3sourceConductance);
    % contribution for ivdpvsp
    fi(1,1) = fi(1,1) + cdreq;
    fi(2,1) = fi(2,1) + (-cdreq);
    % contribution for ivbvdp
    fi(1,1) = fi(1,1) + (-(ceqbd));
    % contribution for ivbvsp
    fi(2,1) = fi(2,1) + (-(ceqbs));
    % contribution for ivgvsp
    qe(2,1) = BSIM3type*qgate;
    qi(2,1) = (-BSIM3type*qgate);
    % contribution for ivbvsp
    qi(2,1) = qi(2,1) + (-(BSIM3type*qbulk));
    % contribution for ivbvsp
    qi(2,1) = qi(2,1) + (-(BSIM3type*BSIM3qbs));
    % contribution for ivbvdp
    qi(1,1) = (-(BSIM3type*BSIM3qbd));
    % contribution for ivdpvsp
    qi(1,1) = qi(1,1) + BSIM3type*qdrn;
    qi(2,1) = qi(2,1) + (-BSIM3type*qdrn);

    % module back 

    % module finishing
    qe(1,1) = 0;
    fe(2,1) = 0;
    qe(3,1) = 0;
end
