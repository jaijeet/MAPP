function [dfe_dvecU, dfi_dvecU] = dfqei_dvecU_auto(vecX, vecY, vecLim, vecU, flag, MOD)
%function [dfe_dvecU, dfi_dvecU] = dfqei_dvecU_auto(vecX, vecY, vecLim, vecU, flag, MOD)
%This function computes d{f} X {e,i}/dvecU using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%	MOD				- struct (Modspec struct)
%OUTPUT:
%	dfe_dvecU
%	dfi_dvecU 

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
		fprintf(2,'dfqei_dvecU_auto: vecvalder (needed for computing dfqei/dvecU) not found - aborting');
		dfe_dvecU = [];
		dfi_dvecU = [];
		return;
	end
    %}

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	ienames = feval(MOD.ImplicitEquationNames, MOD);
	unames = feval(MOD.uNames, MOD);

	nvecZ = length(eonames);
	nvecW = length(ienames);
	nvecU = length(unames);
	
	if nvecU > 0
		% flag.fe = 1; flag.qe = 0; flag.fi = 1; flag.qi = 0;
		vvecU = vecvalder(vecU, speye(nvecU));
		[vvecfe, vvecqe, vvecfi, vvecqi] = feval(MOD.fqeiJ, vecX, vecY, vecLim, vvecU, flag, MOD);
		if isa(vvecfe, 'vecvalder')
			dfe_dvecU = sparse(der2mat(vvecfe));
		else
			dfe_dvecU = sparse(nvecZ, nvecU);
		end
		if isa(vvecfi, 'vecvalder')
			dfi_dvecU = sparse(der2mat(vvecfe));
		else
			dfi_dvecU = sparse(nvecW, nvecU);
		end
	else
		dfe_dvecU = sparse(nvecZ, nvecU);
		dfi_dvecU = sparse(nvecW, nvecU);
	end
end
%end dfe_dvecU_auto
