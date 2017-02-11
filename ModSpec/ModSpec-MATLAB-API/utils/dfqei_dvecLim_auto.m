function [dfe_dvecLim, dqe_dvecLim, dfi_dvecLim, dqi_dvecLim] = dfqei_dvecLim_auto(vecX, vecY, vecLim, vecU, flag, MOD)
%function [dfe_dvecLim, dqe_dvecLim, dfi_dvecLim, dqi_dvecLim] = dfqei_dvecLim_auto(vecX, vecY, vecLim, vecU, flag, MOD)
%This function computes d{f,q} X {e,i}/dvecLim using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%	MOD				- struct (Modspec struct)
%OUTPUT:
%	dfe_dvecLim
%	dqe_dvecLim 
%	dfi_dvecLim 
%	dqi_dvecLim

%Author: Bichen Wu <bichen@berkeley.edu> 2014/05/13
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dfqei_dvecLim_auto: vecvalder (needed for computing dfqei/dvecLim) not found - aborting');
		dfe_dvecLim = [];
		dqe_dvecLim = [];
		dfi_dvecLim = [];
		dqi_dvecLim = [];
		return;
	end
    %}

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	ienames = feval(MOD.ImplicitEquationNames, MOD);
	limnames = feval(MOD.LimitedVarNames, MOD);

	nvecZ = length(eonames);
	nvecW = length(ienames);
	nvecLim = length(limnames);
	
	if nvecLim > 0
		% flag.fe = 1; flag.qe = 1; flag.fi = 1; flag.qi = 1;
		vvecLim = vecvalder(vecLim, speye(nvecLim));
		[vvecfe, vvecqe, vvecfi, vvecqi] = feval(MOD.fqeiJ, vecX, vecY, vvecLim, vecU, flag, MOD);
		if isa(vvecfe, 'vecvalder')
			dfe_dvecLim = sparse(der2mat(vvecfe));
		else
			dfe_dvecLim = sparse(nvecZ, nvecLim);
		end
		if isa(vvecqe, 'vecvalder')
			dqe_dvecLim = sparse(der2mat(vvecqe));
		else
			dqe_dvecLim = sparse(nvecZ, nvecLim);
		end
		if isa(vvecfi, 'vecvalder')
			dfi_dvecLim = sparse(der2mat(vvecfi));
		else
			dfi_dvecLim = sparse(nvecW, nvecLim);
		end
		if isa(vvecqi, 'vecvalder')
			dqi_dvecLim = sparse(der2mat(vvecqi));
		else
			dqi_dvecLim = sparse(nvecW, nvecLim);
		end
	else
		dfe_dvecLim = sparse(nvecZ, nvecLim);
		dqe_dvecLim = sparse(nvecZ, nvecLim);
		dfi_dvecLim = sparse(nvecW, nvecLim);
		dqi_dvecLim = sparse(nvecW, nvecLim);
	end
end
%end dfe_dvecLim_auto
