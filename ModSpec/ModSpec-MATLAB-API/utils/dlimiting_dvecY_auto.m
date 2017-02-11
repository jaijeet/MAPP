function dvecLim_dvecY = dlimiting_dvecY_auto(vecX, vecY, vecLimOld, vecU, MOD)
%function dvecLim_dvecY = dlimiting_dvecY_auto(vecX, vecY, vecLimOld, vecU, MOD)
%This function computes dlimiting/dvecY using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLimOld          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dZf_dvecLim       - dfe_dvecLim(vecX, vecY, vecLim, vecU, MOD)

%Author: Tianshi Wang <tianshi@berkeley.edu> 2013/03/29
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
		fprintf(2,'dlimiting_dvecY_auto: vecvalder (needed for computing dlimiting/dvecY) not found - aborting');
		dvecLim_dvecY = [];
		return;
	end
    %}

	limnames = feval(MOD.LimitedVarNames, MOD);
	iunames = feval(MOD.InternalUnkNames, MOD);

	nvecLim = length(limnames);
	nvecY = length(iunames);

	if nvecLim > 0 && nvecY > 0
		vvecY = vecvalder(vecY, speye(nvecY)); % single vecvalder

		vvecLim = feval(MOD.limiting, vecX, vvecY, vecLimOld, vecU, MOD); 

		if isa(vvecLim, 'vecvalder')
			dvecLim_dvecY = sparse(der2mat(vvecLim));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dvecLim_dvecY);
			if [oof1, oof2] ~= [nvecLim, nvecY]
				fprintf(2, '%s: WARNING: size of dvecLim_dvecY incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecLim,nvecY);
				if 0 == 1
					[i, j, s] = find(dvecLim_dvec);
					[m, n] = size(dvecLim_dvec);
					dvecLim_dvec = sparse(i, j, s, nvecLim, nvecY);
				end
			end
		else
			dvecLim_dvecY = sparse(nvecLim, nvecY);
		end
	else
		dvecLim_dvecY = sparse(nvecLim, nvecY);
	end
end
%end dvecLim_dvecY_auto
