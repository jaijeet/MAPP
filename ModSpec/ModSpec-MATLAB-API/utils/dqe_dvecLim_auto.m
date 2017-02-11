function dZq_dvecLim = dqe_dvecLim_auto(vecX, vecY, vecLim, MOD)
%function dZq_dvecLim = dqe_dvecLim_auto(vecX, vecY, vecLim, MOD)
%This function computes dqe_dvecLim using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dZq_dvecLim       - dqe_dvecLim(vecX, vecY, vecLim, MOD)

%Author: Tianshi Wang <tianshi@berkeley.edu> 2013/03/29
% 
    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dqe_dvecLim_auto: vecvalder (needed for computing dqe/dvecLim) not found - aborting');
		dZq_dvecLim = [];
		return;
	end
    %}

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	limnames = feval(MOD.LimitedVarNames, MOD);

	nvecZ = length(eonames);
	nvecLim = length(limnames);

	if nvecZ > 0 && nvecLim > 0
		vvecLim = vecvalder(vecLim, speye(nvecLim)); % single vecvalder

		vvecZ = feval(MOD.qe, vecX, vecY, vvecLim, MOD); 

		if isa(vvecZ, 'vecvalder')
			dZq_dvecLim = sparse(der2mat(vvecZ));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dZq_dvecLim);
			if [oof1, oof2] ~= [nvecZ, nvecLim]
				fprintf(2, '%s: WARNING: size of dZq_dvecLim incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecZ,nvecLim);
				if 0 == 1
					[i, j, s] = find(dZq_dvecLim);
					[m, n] = size(dZq_dvecLim);
					dZq_dvecLim = sparse(i, j, s, nvecZ, nvecLim);
				end
			end
		else
			dZq_dvecLim = sparse(nvecZ, nvecLim);
		end
	else
		dZq_dvecLim = sparse(nvecZ, nvecLim);
	end
end
%end dqe_dvecLim_auto
