function outDAE = DAEAPI_derivative_add_ons(DAE)
%function outDAE = DAEAPI_derivative_add_ons(DAE)
%This function sets up additional API functions implementing derivatives in
%DAEAPI.
%INPUT args:
%   DAE             - input partial DAE object
%
%OUTPUT:
%   outDAE          - output DAE with derivative add-ons
%
%This defines additional API functions implementing derivatives in DAEAPI
%These are set by default to use automatic differentiation (vecvalder).

%author: Tianshi Wang  2013/10/09
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	DAE.df_dx = @df_dx_DAEAPI_auto; % defined in utils: vecvalder-based auto-diff
	DAE.df_dxlim = @df_dxlim_DAEAPI_auto; % defined in utils: vecvalder-based auto-diff
	DAE.df_du = @df_du_DAEAPI_auto; % defined in utils: vecvalder-based auto-diff
	DAE.dq_dx = @dq_dx_DAEAPI_auto; % defined in utils: vecvalder-based auto-diff
	DAE.dq_dxlim = @dq_dxlim_DAEAPI_auto; % defined in utils: vecvalder-based auto-diff

	DAE.dfq_dp  = @dfq_dp_DAEAPI_auto;  % defined in utils: vecvalder-based auto-diff
	DAE.df_dp  = @df_dp_DAEAPI_auto;  % defined in utils: vecvalder-based auto-diff
	DAE.dq_dp  = @dq_dp_DAEAPI_auto;  % defined in utils: vecvalder-based auto-diff

	DAE.dNRlimiting_dx = @dNRlimiting_dx_DAEAPI_auto; % defined in utils: vecvalder-based auto-diff

    DAE.fqJ = @fqJ;

    outDAE = DAE;
end % DAEAPI_derivative_add_ons

function fqJout = fqJ(varargin)
%function fqJout = fqJ(x, xlim, u, flag, DAE)
% xlim is optional, u is also optional depending on f_takes_inputs
    DAE = varargin{end};
    flag = varargin{end-1};
	if flag.dfdx == 0 && flag.dfdu == 0 && flag.dfdxlim == 0 ...
		&& flag.dqdx == 0 && flag.dqdxlim == 0
        [fqJout.f, fqJout.q] = DAE.fq(varargin{:});
        fqJout.dfdx = [];
        fqJout.dfdxlim = [];
        fqJout.dfdu = [];
        fqJout.dqdx = [];
        fqJout.dqdxlim = [];
    else
		[fq, J] = dfq_dxxlimu_auto(varargin{1:end-2}, DAE);

		fqJout.f = fq.f;
		fqJout.q = fq.q;

        fqJout.dfdx    = J.dfdx;
        fqJout.dfdxlim = J.dfdxlim;
        fqJout.dfdu    = J.dfdu;
        fqJout.dqdx    = J.dqdx;
        fqJout.dqdxlim = J.dqdxlim;
    end
end
