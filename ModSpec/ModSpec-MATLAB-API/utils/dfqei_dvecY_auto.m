function [dfe_dvecY, dqe_dvecY, dfi_dvecY, dqi_dvecY] = dfqei_dvecY_auto(vecX, vecY, vecLim, vecU, flag, MOD)
%function [dfe_dvecY, dqe_dvecY, dfi_dvecY, dqi_dvecY] = dfqei_dvecY_auto(vecX, vecY, vecLim, vecU, flag, MOD)
%This function computes d{f,q} X {e,i}/dvecY using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%	MOD				- struct (Modspec struct)
%OUTPUT:
%	dfe_dvecY
%	dqe_dvecY 
%	dfi_dvecY 
%	dqi_dvecY

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
		fprintf(2,'dfqei_dvecY_auto: vecvalder (needed for computing dfqei/dvecY) not found - aborting');
		dfe_dvecY = [];
		dfi_dvecY = [];
		dqe_dvecY = [];
		dqi_dvecY = [];
		return;
	end
    %}

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	ienames = feval(MOD.ImplicitEquationNames, MOD);
	iunames = feval(MOD.InternalUnkNames, MOD);


	nvecZ = length(eonames);
	nvecW = length(ienames);
	nvecY = length(iunames);
	
	if nvecY > 0
		% flag.fe = 1; flag.qe = 1; flag.fi = 1; flag.qi = 1;
		vvecY = vecvalder(vecY, speye(nvecY));
		[vvecfe, vvecqe, vvecfi, vvecqi] = feval(MOD.fqeiJ, vecX, vvecY, vecLim, vecU, flag, MOD);
		if isa(vvecfe, 'vecvalder')
			dfe_dvecY = sparse(der2mat(vvecfe));
		else
			dfe_dvecY = sparse(nvecZ, nvecY);
		end
		if isa(vvecqe, 'vecvalder')
			dqe_dvecY = sparse(der2mat(vvecqe));
		else
			dqe_dvecY = sparse(nvecZ, nvecY);
		end
		if isa(vvecfi, 'vecvalder')
			dfi_dvecY = sparse(der2mat(vvecfi));
		else
			dfi_dvecY = sparse(nvecW, nvecY);
		end
		if isa(vvecqi, 'vecvalder')
			dqi_dvecY = sparse(der2mat(vvecqi));
		else
			dqi_dvecY = sparse(nvecW, nvecY);
		end
	else
		dfe_dvecY = sparse(nvecZ, nvecY);
		dqe_dvecY = sparse(nvecZ, nvecY);
		dfi_dvecY = sparse(nvecW, nvecY);
		dqi_dvecY = sparse(nvecW, nvecY);
	end
end
%end dfe_dvecY_auto
