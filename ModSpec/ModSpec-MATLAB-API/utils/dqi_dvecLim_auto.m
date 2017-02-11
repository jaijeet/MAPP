function dWq_dvecLim = dqi_dvecLim_auto(vecX, vecY, vecLim, MOD)
%function dWq_dvecLim = dqi_dvecLim_auto(vecX, vecY, vecLim, MOD)
%This function computes dqi_dvecLim using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dWq_dvecLim       - dqi_dvecLim(vecX, vecY, vecLim, vecU, MOD)
%
%Author: Tianshi Wang <tianshi@berkeley.edu> 2013/03/29
% 
    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dqi_dvecLim_auto: vecvalder (needed for computing dqi/dvecLim) not found - aborting');
		dWq_dvecLim = [];
		return;
	end
    %}

	ienames = feval(MOD.ImplicitEquationNames, MOD);
	limnames = feval(MOD.LimitedVarNames, MOD);

	nvecW = length(ienames);
	nvecLim = length(limnames);

	if nvecW > 0 && nvecLim > 0
		vvecLim = vecvalder(vecLim, speye(nvecLim)); % single vecvalder

		vvecW = feval(MOD.qi, vecX, vecY, vvecLim, MOD); 

		if isa(vvecW, 'vecvalder')
			dWq_dvecLim = sparse(der2mat(vvecW));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dWq_dvecLim);
			if [oof1, oof2] ~= [nvecW, nvecLim]
				fprintf(2, '%s: WARNING: size of dWq_dvecLim incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecW,nvecLim);
				if 0 == 1
					[i, j, s] = find(dWq_dvecLim);
					[m, n] = size(dWq_dvecLim);
					dWq_dvecLim = sparse(i, j, s, nvecW, nvecLim);
				end
			end
		else
			dWq_dvecLim = sparse(nvecW, nvecLim);
		end
	else
		dWq_dvecLim = sparse(nvecW, nvecLim);
	end
end
%end dqi_dvecLim_auto
