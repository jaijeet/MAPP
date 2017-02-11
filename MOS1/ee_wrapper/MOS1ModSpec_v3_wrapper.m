function MOD = MOS1ModSpec_v3_wrapper(uniqID)
%function MOD = MOS1ModSpec_v3_wrapper(uniqID)
%
% v3: moved from v2,
%     diode charges are considered
%     diode currents are considered
%     no Qgd, Qgs, Qgb
%     no DS inversion
%     no P type
%     no Rs, Rd
%
% v2: moved from v1,
%     diode currents are considered
%     gmin is added in parms for diode currents
%     no DS inversion
%     no P type
%     no charges
%     no Rs, Rd
%
% v1: only N type is implemented
%     only forward ids is considered, no charge calculation, no diode current
%          calculation
%     no DS inversion
%     no Rs, Rd
%
%This function creates a ModSpec object model for SPICE's MOSFET level 1 model
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'M1'
%
%Return values:
% - MOD:    a ModSpec object for MOS level 1 model
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'d', 'g', 's', 'b'} (drain, gate, source, bulk).
%
% - parameters and their default values:
% model parms based on The SPICE Book:
%     name    default unit   description
%   - 'VTO'    0.0    V      'Zero-bias threshold voltage'
%   - 'KP'     2e-5   A/V^2  'Transconductance coefficient'
%   - 'GAMMA'  0.0    V^0.5  'Bulk threshold parameter'
%   - 'PHI'    0.6    V      'Surface potential'
%   - 'LAMBDA' 0.0    V^-1   'Channel-length modulation'
%   - 'RD'     0.0    Ohm    'Drain ohmic resistance'
%   - 'RS'     0.0    Ohm    'Source ohmic resistance'
%   - 'RSH'    0.0    Ohm/sq 'Drain  source diffusion sheet resistance' %TODO: what's sq
%   - 'CBD'    0.0    F      'Zero-bias bulk-drain p-n capacitance'
%   - 'CBS'    0.0    F      'Zero-bias bulk-source p-n capacitance'
%   - 'CJ'     0.0    F/M^2  'Bulk p-n zero-bias bottom capacitance/area'
%   - 'MJ'     0.5    NONE   'Bulk p-n bottom grading coefficient'
%   - 'CJSW'   0.0    F/M^2  'Bulk p-n zero-bias sidewall capacitance/area' %TODO: CJSW is with unit F/m in The Spice Book
%   - 'MJSW'   0.5    NONE   'Bulk p-n sidewall grading coefficient'
%   - 'PB'     0.8    V      'Bulk p-n bottom potential'
%   - 'IS'     1e-14  A      'Bulk p-n saturation current'
%   - 'CGDO'   0.0    F/M    'Gate-drain overlap capacitance/channel width'
%   - 'CGSO'   0.0    F/M    'Gate-source overlap capacitance/channel width'
%   - 'CGBO'   0.0    F/M    'Gate-bulk overlap capacitance/channel length'
%   - 'TOX'    1e-7   m      'Gate oxide thickness'
%   - 'LD'     0.0    m      'Lateral diffusion length'
%   - 'GMIN'   1e-12  S      'minimum conductance in p-n junctions'
%   - 'MAXSLOPE' 2e17 NONE   'maximum slope in safeexp'
% extra model parms in MOSFET1 in Xyce-6.1 (added in MOS1):
%   - 'FC'     0.5    NONE   'Bulk p-n forward-bias capacitance coefficient'
% extra model parms in MOSFET1 in Xyce-6.1 (ignored for the moment):
%   - 'L'      1e-4   m      'Default channel length'
%   - 'W'      1e-4   m      'Default channel width'
%   - 'JS'     0.0    A/M^2  'Bulk p-n saturation current density'
%   - 'UO'     600.0  CMM2VM1SM1  'Surface mobility' %TODO: what's this
%   - 'U0'     600.0  CMM2VM1SM1  'Surface mobility' %TODO: what's this
%   - 'NSUB'   0.0    CMM3   'Substrate doping density'
%   - 'NSS'    0.0    CMM2   'Surface state density'
%   - 'TNOM'   27.0   NONE   ''
%   - 'KF'     0.0    NONE   'Flicker noise coefficient'
%   - 'AF'     1.0    NONE   'Flicker noise exponent'
%   - 'TPG'    0      NONE   'Gate material type (-1 = same as substrate
%                             0 = aluminum  1 = opposite of substrate)'
% element parms:
%   - 'L'      1e-4   m      'Default channel length'
%   - 'W'      1e-4   m      'Default channel width'
% extra element parms in MOSFET1 in Xyce-6.1 (ignored for the moment):
%   - 'TEMP'   0.0,   K      'Device temperature'
%   - 'AD'     0.0,   m^2    'Drain diffusion area'
%   - 'AS'     0.0,   m^2    'Source diffusion area'
%   - 'NRD'    1.0,   SQUARES 'Multiplier for RSH to yield parasitic resistance of drain'
%   - 'NRS'    1.0,   SQUARES 'Multiplier for RSH to yield parasitic resistance of source'
%   - 'PD'     0.0,   m      'Drain diffusion perimeter'
%   - 'PS'     0.0,   m      'Source diffusion perimeter'
%   - 'M'      1.0,   NONE   'Multiplier for M devices connected in parallel'
%
%Examples
%--------
% % adding an NMOS with default parameters to an existing circuitdata structure
% cktdata = add_element(cktdata, MOS1ModSpec(), 'M1', ...
%           {'nD', 'nG', 'nS', 'nB'}, [], {});
%
%See also
%--------
% 
% add_element, circuitdata, ModSpec, supported_ModSpec_devices, DAEAPI, DAE
%

%
% author: T. Wang. 2014-06-27

%change log:
%-----------
%2014/06/27: Tianshi Wang <tianshi@berkeley.edu> Created

    MOD = ee_model();

    MOD = add_to_ee_model (MOD, 'modelname', 'MOS1');
    MOD = add_to_ee_model (MOD, 'description', 'SPICE''s MOSFET level 1 model');

    MOD = add_to_ee_model (MOD, 'terminals', {'d', 'g', 's', 'b'});
    MOD = add_to_ee_model (MOD, 'explicit_outs', {'idb', 'igb', 'isb'});

    % model parms:
    MOD = add_to_ee_model (MOD, 'parms', {'VTO',    0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'KP',     2e-5});
    MOD = add_to_ee_model (MOD, 'parms', {'GAMMA',  0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'PHI',    0.6});
    MOD = add_to_ee_model (MOD, 'parms', {'LAMBDA', 0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'RD',     0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'RS',     0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'RSH',    0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'CBD',    0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'CBS',    0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'CJ',     0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'MJ',     0.5});
    MOD = add_to_ee_model (MOD, 'parms', {'CJSW',   0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'MJSW',   0.5});
    MOD = add_to_ee_model (MOD, 'parms', {'PB',     0.8});
    MOD = add_to_ee_model (MOD, 'parms', {'IS',     1e-14});
    MOD = add_to_ee_model (MOD, 'parms', {'CGDO',   0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'CGSO',   0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'CGBO',   0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'TOX',    1e-7});
    MOD = add_to_ee_model (MOD, 'parms', {'LD',     0.0});
    MOD = add_to_ee_model (MOD, 'parms', {'GMIN',   1e-12});
    MOD = add_to_ee_model (MOD, 'parms', {'MAXSLOPE', 2e17});
    MOD = add_to_ee_model (MOD, 'parms', {'FC',     0.5});
    % element parms:
    MOD = add_to_ee_model (MOD, 'parms', {'L',      1e-4});
    MOD = add_to_ee_model (MOD, 'parms', {'W',      1e-4});

    MOD = add_to_ee_model (MOD, 'fe', @fe);
    MOD = add_to_ee_model (MOD, 'qe', @qe);
    MOD = add_to_ee_model (MOD, 'fi', @fi);
    MOD = add_to_ee_model (MOD, 'qi', @qi);

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

    v2struct(S);

    vds = vdb - vsb;
    vgs = vgb - vsb;
    vbs = -vsb;

    VTH = MOS1_VTH(vbs, VTO, GAMMA, PHI);
    ids = forward_ids(vds, vgs, VTH, KP, W, L, LD, LAMBDA);

    % ==========================================================================
    % BD, BS diode currents calculation:
    %{
    % Xyce-6.1, N_DEV_MOSFET1.C
    2843   ////
    2844   //  bulk-source and bulk-drain diodes
    2845   //  here we just evaluate the ideal diode current and the
    2846   //   corresponding derivative (conductance).
    2847   ////
    2848   if(vbs <= 0)
    2849   {
    2850     gbs = SourceSatCur/vt;
    2851     gbs += getDeviceOptions().gmin;
    2852     cbs = gbs*vbs;
    2853   }
    2854   else
    2855   {
    2856     evbs = exp(Xycemin(CONSTMAX_EXP_ARG,vbs/vt));
    2857     gbs = (SourceSatCur*evbs/vt + getDeviceOptions().gmin);
    2858     cbs = (SourceSatCur * (evbs-1) + getDeviceOptions().gmin*vbs);
    2859   }
    2860   if(vbd <= 0)
    2861   {
    2862     gbd = DrainSatCur/vt;
    2863     gbd += getDeviceOptions().gmin;
    2864     cbd = gbd *vbd;
    2865   }
    2866   else
    2867   {
    2868     evbd = exp(Xycemin(CONSTMAX_EXP_ARG,vbd/vt));
    2869     gbd = (DrainSatCur*evbd/vt + getDeviceOptions().gmin);
    2870     cbd = (DrainSatCur *(evbd-1) + getDeviceOptions().gmin*vbd);
    2871   }
    %
    % DrainSatCur, SourceSatCur
    2655   if( (tSatCurDens == 0) || (drainArea == 0) || (sourceArea == 0))
    2656   {
    2657     DrainSatCur = tSatCur;
    2658     SourceSatCur = tSatCur;
    2659   }
    2660   else
    2661   {
    2662     DrainSatCur = tSatCurDens * drainArea;
    2663     SourceSatCur = tSatCurDens * sourceArea;
    2664   }
    % tSatCur, tSatCurDens
    3529   tSatCur = model_.jctSatCur* exp(-egfet/vt+model_.egfet1/model_.vtnom);
    3530   tSatCurDens = model_.jctSatCurDensity * exp(-egfet/vt+model_.egfet1/model_.vtnom);
    % where jctSatCur is IS, jctSatCurDensity is JS
    % and
    3494   egfet = 1.16-(7.02e-4*temp*temp)/(temp+1108);
    3799   egfet1 = 1.16-(7.02e-4*tnom*tnom)/(tnom+1108);
    % In short, when temp == tnom, tSatCur == jctSatCur (IS)
    %
    %}

    k = 1.3806226e-23;
    T = 300;
    q = 1.6021918e-19;
    vt = k*T/q;
    %{
    % from constants.vams
    % http://cp.literature.agilent.com/litweb/pdf/ads2004a/verilogaref/varefC3.html
    // charge of electron in coulombs
    `define P_Q 1.6021918e-19
    // Boltzman's constant in joules/kelvin
    `define P_K 1.3806226e-23
    %}
    if vbs <= 0
        gbs = IS/vt + GMIN;
        ibs = gbs*vbs;
    else
        % evbs = exp(Xycemin(CONSTMAX_EXP_ARG, vbs/vt)); % from Xyce
        evbs = safeexp(vbs/vt, MAXSLOPE)
        ibs = IS * (evbs-1) + GMIN*vbs;
    end
    vbd = -vdb;
    if vbd <= 0
        gbd = IS/vt + GMIN;
        ibd = gbd *vbd;
    else
        % evbd = exp(Xycemin(CONSTMAX_EXP_ARG,vbd/vt));
        evbd = safeexp(vbd/vt, MAXSLOPE);
        ibd = IS * (evbd-1) + GMIN*vbd;
    end
    % done with BD, BS diode currents calculation
    % ==========================================================================

    if 1 == strcmp(forq, 'q') % calculate charges
        % ======================================================================
        % BD, BS diode charges calculation
        % based on Xyce code, except that temp is assumed to be tnom to simplify
        % calculation
		%
		% questions to answer before coding:
		%
        % what are Cbs, Cbssw?
		%    Cbs = czbs;
		%    Cbssw = czbssw;
		%    what are czbs, czbssw
		%       if(model_.capBSGiven) % CBS given in parms
		%       {
		%         czbs=tCbs; % tCbs is CBS in parms when temp==tnom
		%       }
		%       else
		%       {
		%         if(model_.bulkCapFactorGiven) % CJ given in parms
		%         {
		%           czbs=tCj*sourceArea; % tCj is CJ, temp==tnom
		%                                % sourceArea is AS in element parms
		%         }
		%         else
		%         {
		%           czbs=0;
		%         }
		%       }
		%       if(model_.sideWallCapFactorGiven) % CJSW given in parms
		%       {
		%         czbssw = tCjsw * sourcePerimeter; % tCjsw is CJSW, temp==tnom
		%                              % sourcePerimeter is PS in element parms
		%       }
		%       else
		%       {
		%         czbssw=0;
		%       }
        %
        % what is tDepCap?
		%    tDepCap = model_.fwdCapDepCoeff * tBulkPot; % FC in model parms
        % what is tBulkPot?
		%    tBulkPot = fact2 * pbo+pbfact;
		%    what are fact2, pbo, pbfact
		%       fact2 = temp/CONSTREFTEMP; % == 1 if not considering temperature
		%       pbfact = -2*vt *(1.5*log(fact2)+CONSTQ*arg);
		%       pbo = (model_.bulkJctPotential - model_.pbfact1)/model_.fact1;
		%       what are arg, pbfact1, fact1
		%           egfet = 1.16-(7.02e-4*temp*temp)/(temp+1108);
		%           arg = -egfet/(kt+kt)+1.1150877/(CONSTboltz*(CONSTREFTEMP+CONSTREFTEMP));
		%           % kt is k*temp
		%           fact1 = tnom/CONSTREFTEMP;
		%           pbfact1 = -2*vtnom *(1.5*log(fact1)+CONSTQ*arg1);
		% in short, tBultPot is PD in model parms: 'Bulk p-n bottom potential'
		% so tDepCap is FC*PB
        % what are f2s, f3s, f4s?
		%
		tBulkPot = PB;
		tDepCap = FC * PB;
		arg = 1-FC;
		sarg = exp((-MJ) * log(arg));
		sargsw = exp((-MJSW) * log(arg));
		%
		% qbs
		czbs = CBS; % simplified
		czbssw = 0; % simplified
		Cbs = czbs;
		Cbssw = czbssw;
		f2s = czbs*(1-FC* (1+MJ))* sarg/arg + czbssw*(1-FC* (1+MJSW))* sargsw/arg;
		f3s = czbs * MJ * sarg/arg/ tBulkPot + czbssw * MJSW * sargsw/arg / tBulkPot;
		f4s = czbs*tBulkPot*(1-arg*sarg)/ (1-MJ) + czbssw*tBulkPot*(1-arg*sargsw)/...
		  (1-MJSW) -f3s/2* (tDepCap*tDepCap) -tDepCap * f2s;
        if Cbs ~= 0 || Cbssw ~= 0
            if vbs < tDepCap
                arg=1-vbs/tBulkPot;
                sarg = exp(-MJ * log(arg));
                sargsw =exp(-MJSW * log(arg));
                qbs = tBulkPot*(Cbs*(1-arg*sarg)/(1-MJ) + Cbssw*(1-arg*sargsw)/(1-MJSW));
            else
                qbs = f4s + vbs*(f2s+vbs*(f3s/2));
            end
        else
            qbs = 0;
        end
		% qbd
		czbd = CBD; % simplified
		czbdsw = 0; % simplified
		Cbd = czbd;
		Cbdsw = czbdsw;
		f2d = czbd*(1-FC* (1+MJ))* sarg/arg + czbdsw*(1-FC* (1+MJSW))* sargsw/arg;
		f3d = czbd * MJ* sarg/arg/ tBulkPot + czbdsw * MJSW * sargsw/arg / tBulkPot;
		f4d = czbd*tBulkPot*(1-arg*sarg)/ (1-MJ) + czbdsw*tBulkPot*(1-arg*sargsw)/...
		  (1-MJSW) -f3d/2* (tDepCap*tDepCap) -tDepCap * f2d;
        if Cbd ~= 0 || Cbdsw ~= 0
            if (vbd < tDepCap)
                arg=1-vbd/tBulkPot;
                sarg = exp(-MJ*log(arg));
                sargsw =exp(-MJSW*log(arg));
                qbd = tBulkPot*(Cbd* (1-arg*sarg) /(1-MJ) + Cbdsw* (1-arg*sargsw) /(1-MJSW));
            else
                qbd = f4d + vbd * (f2d + vbd * f3d/2);
            end
        else
            qbd = 0;
        end
        % done with BD, BS diode charges calculation
        % ======================================================================


        % ======================================================================
        % GD, GS, GB charges calculation
        % based on Xyce code, calling qmeyer in DeviceSupport, except that temp
        % is assumed to be tnom to simplify calculation
        %
        % How qmeyer is called in N_DEV_MOSFET1.C
        % qmeyer(vgs, vgd, Vgb, Von, Vdsat, capgs, capgd, capgb, tPhi, OxideCap);
        % which is to say:
        % [capgs, capgd, capgb] = qmeyer(vgs, vgd, Vgb, Von, Vdsat, tPhi, OxideCap);
        % What are Von, Vdsat?
        %    Von=(tVbi*model_.dtype)+model_.gamma*sarg; % dtype: P/N type, N is 1
        %    vgst=(mode==1?vgs:vgd)-Von;  % mode: DS inversion, mode == 1 means forward
        %    Vdsat=Xycemax(vgst,0.0);
        %   What are tVbi, sarg?
        %     tVbi = model_.vt0 - model_.dtype *
        %          (model_.gamma* sqrt(model_.phi))+.5*(model_.egfet1-egfet)
        %          + model_.dtype*.5* (tPhi-model_.phi);
        %     vt0 is VT0 in parms
        %     what are egfet1 and egfet?
        %         egfet1 = 1.16-(7.02e-4*tnom*tnom)/(tnom+1108);
        %         egfet = 1.16-(7.02e-4*temp*temp)/(temp+1108);
        %     arg = 1-model_.fwdCapDepCoeff;   % FC in parms
        %     sarg = exp( (-model_.bulkJctBotGradingCoeff) * log(arg) ); % MJ in parms
        %
        % What are tPhi, OxideCap?
        %     phio= (model_.phi-model_.pbfact1)/model_.fact1;
        %     tPhi = fact2 * phio + pbfact;
        %     what are fact2, pdfact?
        %         vt = temp * CONSTKoverQ;
        %         ratio = temp/tnom; % 1
        %         fact2 = temp/CONSTREFTEMP; % 1
        %         kt = temp * CONSTboltz; % k*T
        %         egfet = 1.16-(7.02e-4*temp*temp)/(temp+1108);
        %         arg = -egfet/(kt+kt)+1.1150877/(CONSTboltz*(CONSTREFTEMP+CONSTREFTEMP));
        %         pbfact = -2*vt *(1.5*log(fact2)+CONSTQ*arg);
        %     what are fact1, pdfact1?
        %         fact1 = tnom/CONSTREFTEMP;
        %         vtnom = tnom*CONSTKoverQ;
        %         kt1 = CONSTboltz * tnom;
        %         egfet1 = 1.16-(7.02e-4*tnom*tnom)/(tnom+1108);
        %         arg1 = -egfet1/(kt1+kt1)+1.1150877/(CONSTboltz*(CONSTREFTEMP+CONSTREFTEMP));
        %         pbfact1 = -2*vtnom *(1.5*log(fact1)+CONSTQ*arg1);
        % Why does Vgb have cap V?
        %    nothing special, see line 2836 of N_DEV_MOSFET1.C
        %
        % [capgs, capgd, capgb] = qmeyer(vgs, vgd, Vgb, Von, Vdsat, tPhi, OxideCap);
    end

    if 1 == strcmp(eori,'e') % e
        if 1 == strcmp(forq, 'f') % f
            % idb
            out(1,1) = ids - ibd;
            % igb
            out(2,1) = 0;
            % isb
            out(3,1) = -ids - ibs;
        else % q
            % qdb
            out(1,1) = -qbd;
            % qgb
            out(2,1) = 0;
            % qsb
            out(3,1) = -qbs;
        end % forq
    else % i
        if 1 == strcmp(forq, 'f') % f
            out = [];
        else % q
            out = [];
        end
    end
end


function VTH = MOS1_VTH(vbs, VTO, GAMMA, PHI)
%function VTH = MOS1_VTH(vbs, VTO, GAMMA, PHI)
% This function calculates threshold voltage VTH in MOS level 1 model
% The implementation is based on "The SPICE Book", Chapter 3
% "Semiconductor-Device Elements", Section 3.5.1 MOSFET DC Model, Page 103.
% VTH = VTO + GAMMA * (sqrt(2*PHI-vbs) - sqrt(2*PHI))
% is the threshold voltage in the presence of back-gate bias, vbs < 0
    VTH = VTO + GAMMA * (sqrt(2*PHI-vbs) - sqrt(2*PHI));
end % MOS1_VTH

function ids = forward_ids(vds, vgs, VTH, KP, W, L, LD, LAMBDA)
%function ids = forward_ids(vds, vgs, VTH, KP, W, L, LD, LAMBDA)
% This function calculates forward ids in MOS level 1 model. It is pretty much
% the same as ids in Shichman Hodges model.
% The implementation is based on "The SPICE Book", Chapter 3
% "Semiconductor-Device Elements", Section 3.5.1 MOSFET DC Model, Page 103.
%       0                                              for vgs <= VTH
% ids = KP/2 * W/Leff * (vgs-VTH)^2 * (1+LAMBDA*vds)   for 0< vgs - VTH <= vds
%       KP/2 * W/Leff * vds * (2*(vgs-VTH)-vds) * (1+LAMBDA*vds)
%                                                       for 0< vds < vgs - VTH
% where Leff = L - 2*LD is the effective channel length corrected for the
% lateral diffusion LD, of the drain and source
    Leff = L - 2*LD;
    if (vgs <= VTH)
          % off
          ids = 0;
    elseif (vgs <= vds + VTH)
          % active
          ids = KP/2 * W/Leff * (vgs-VTH)^2 * (1+LAMBDA*vds);
    else % vgs > vds+VTH
          % triode
          ids = KP/2 * W/Leff * vds * (2*(vgs-VTH)-vds) * (1+LAMBDA*vds);
    end
end % forward_ids

function [capgs, capgd, capgb] = qmeyer(vgs, vgd, vgb, von, vdsat, phi, cox)
%function [capgs, capgd, capgb] = qmeyer(vgs, vgd, vgb, von, vdsat, phi, cox)
% This function calculates Cgs, Cgd, Cgb in SPICE's MOSFET level 1 model
% It is adapted from Xyce's DeviceSupport::qmeyer
% Original descriptions:
% //---------------------------------------------------------------------------
% // Function      : DeviceSupport::qmeyer
% // Purpose       : Compute the MOS overlap capacitances as functions of the
% //                 device terminal voltages
% //
% // Special Notes : ARGSUSED  because vgb is no longer used
% //
% // Scope         : public
% // Creator       : Eric Keiter, SNL, Parallel Computational Sciences
% // Creation Date : 01/17/01
% //---------------------------------------------------------------------------
%
    vgst = vgs-von;
    if vgst <= -phi
        capgb = cox/2;
        capgs = 0;
        capgd = 0;
    elseif vgst <= -phi/2
        capgb = -vgst*cox/(2*phi);
        capgs = 0;
        capgd = 0;
    elseif vgst <= 0
        capgb = -vgst*cox/(2*phi);
        capgs = vgst*cox/(1.5*phi)+cox/3;
        capgd = 0;
    else
        vds = vgs-vgd;
        if (vdsat <= vds)
            capgs = cox/3;
            capgd = 0;
            capgb = 0;
        else
            vddif = 2.0*vdsat-vds;
            vddif1 = vdsat-vds;
            vddif2 = vddif*vddif;
            capgd = cox*(1.0-vdsat*vdsat/vddif2)/3;
            capgs = cox*(1.0-vddif1*vddif1/vddif2)/3;
            capgb = 0;
        end
    end
end % function qmeyer
