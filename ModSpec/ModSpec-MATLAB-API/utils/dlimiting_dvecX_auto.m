function dvecLim_dvecX = dlimiting_dvecX_auto(vecX, vecY, vecLimOld, vecU, MOD)
%function dvecLim_dvecX = dlimiting_dvecX_auto(vecX, vecY, vecLimOld, vecU, MOD)
%This function computes dlimiting/dvecX using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLimOld          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dZf_dvecLim       - dfe_dvecLim(vecX, vecY, vecLim, vecU, MOD)

%Author: Tianshi Wang <tianshi@berkeley.edu> 2013/03/29
% 
    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dlimiting_dvecX_auto: vecvalder (needed for computing dlimiting/dvecX) not found - aborting');
		dvecLim_dvecX = [];
		return;
	end
    %}

	limnames = feval(MOD.LimitedVarNames, MOD);
	oionames = feval(MOD.OtherIONames, MOD);

	nvecLim = length(limnames);
	nvecX = length(oionames);

	if nvecLim > 0 && nvecX > 0
		vvecX = vecvalder(vecX, speye(nvecX)); % single vecvalder

		vvecLim = feval(MOD.limiting, vvecX, vecY, vecLimOld, vecU, MOD); 

		if isa(vvecLim, 'vecvalder')
			dvecLim_dvecX = sparse(der2mat(vvecLim));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dvecLim_dvecX);
			if [oof1, oof2] ~= [nvecLim, nvecX]
				fprintf(2, '%s: WARNING: size of dvecLim_dvecX incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecLim,nvecX);
				if 0 == 1
					[i, j, s] = find(dvecLim_dvec);
					[m, n] = size(dvecLim_dvec);
					dvecLim_dvec = sparse(i, j, s, nvecLim, nvecX);
				end
			end
		else
			dvecLim_dvecX = sparse(nvecLim, nvecX);
		end
	else
		dvecLim_dvecX = sparse(nvecLim, nvecX);
	end
end
%end dvecLim_dvecX_auto
