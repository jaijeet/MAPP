function outMOD = ModSpec_derivative_add_ons(MOD)
%function outMOD = ModSpec_derivative_add_ons(MOD)
%This function sets up additional API functions implementing derivatives in the
%ModSpec API.
%INPUT args:
%   MOD             - input partial ModSpec object
%
%OUTPUT:
%   outMOD          - output MOD with derivative add-ons
%
%This defines additional API functions implementing derivatives in the ModSpec
%API.  These are set by default to use automatic differentiation (vecvalder).

%author: J. Roychowdhury.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    MOD.dfe_dvecX = @dfe_dvecX_auto;
    MOD.dfe_dvecY = @dfe_dvecY_auto;
    MOD.dfe_dvecLim = @dfe_dvecLim_auto;
    MOD.dfe_dvecU = @dfe_dvecU_auto;
    MOD.dqe_dvecX = @dqe_dvecX_auto;
    MOD.dqe_dvecY = @dqe_dvecY_auto;
    MOD.dqe_dvecLim = @dqe_dvecLim_auto;
    MOD.dfi_dvecX = @dfi_dvecX_auto;
    MOD.dfi_dvecY = @dfi_dvecY_auto;
    MOD.dfi_dvecLim = @dfi_dvecLim_auto;
    MOD.dfi_dvecU = @dfi_dvecU_auto;
    MOD.dqi_dvecX = @dqi_dvecX_auto;
    MOD.dqi_dvecY = @dqi_dvecY_auto;
    MOD.dqi_dvecLim = @dqi_dvecLim_auto;

    MOD.dfqei_dvecX = @dfqei_dvecX_auto;
    %Note: [dfe_dvecX, dfi_dvecX, dqe_dvecX, dqi_dvecX] = feval(MOD.dfqei_dvecX, vecX, vecY, vecLim, vecU, MOD);
    % MOD.dfqei_dvecY = @dfqei_dvecY_auto;
    % MOD.dfqei_dvecLim = @dfqei_dvecLim_auto;
    % MOD.dfqei_dvecU = @dfqei_dvecU_auto;
    % MOD.dfqei_dvecXYLimU = @dfqei_dvecXYLimU_auto;
    MOD.fqeiJ = @fqeiJ;

    MOD.dlimiting_dvecX = @dlimiting_dvecX_auto;
    MOD.dlimiting_dvecY = @dlimiting_dvecY_auto;

    outMOD = MOD;
end % ModSpec_derivative_add_ons

function [fqei, J] = fqeiJ(varargin)
%function [fqei, J] = fqeiJ(vecX, vecY, vecLim, vecU, flag, MOD)
% vecLim is optional
    MOD = varargin{end};
    flag = varargin{end-1};
    if flag.J == 0
        [fqei.fe, fqei.qe, fqei.fi, fqei.qi] = MOD.fqei(varargin{:});
        J = [];
    else
        [fqei, J] = dfqei_dvecXYLimU_auto(varargin{1:end-2}, MOD);
    end
end
