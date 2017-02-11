function dZf_dvecLim = dfe_dvecLim_auto(vecX, vecY, vecLim, vecU, MOD)
%function dZf_dvecLim = dfe_dvecLim_auto(vecX, vecY, vecLim, vecU, MOD)
%This function computes dfe/dvecLim using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dZf_dvecLim       - dfe_dvecLim(vecX, vecY, vecLim, vecU, MOD)

%Author: Tianshi Wang <tianshi@berkeley.edu> 2013/03/29
% 
    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dfe_dvecLim_auto: vecvalder (needed for computing dfe/dvecLim) not found - aborting');
		dZf_dvecLim = [];
		return;
	end
    %}

    if 5 == nargin
        fe_takes_vecLim = 1;
    else % if 4 == nargin
        fe_takes_vecLim = 0;
        MOD = vecU;
        vecU = vecLim;
    end

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	limnames = feval(MOD.LimitedVarNames, MOD);

	nvecZ = length(eonames);
	nvecLim = length(limnames);

	if 0 == fe_takes_vecLim
		dZf_dvecLim = zeros(nvecZ, nvecLim);
		return;
	end

	if nvecZ > 0 && nvecLim > 0
		vvecLim = vecvalder(vecLim, speye(nvecLim)); % single vecvalder

		vvecZ = feval(MOD.fe, vecX, vecY, vvecLim, vecU, MOD); 

		if isa(vvecZ, 'vecvalder')
			dZf_dvecLim = sparse(der2mat(vvecZ));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dZf_dvecLim);
			if [oof1, oof2] ~= [nvecZ, nvecLim]
				fprintf(2, '%s: WARNING: size of dZf_dvecLim incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecZ,nvecLim);
				if 0 == 1
					[i, j, s] = find(dZf_dvecLim);
					[m, n] = size(dZf_dvecLim);
					dZf_dvecLim = sparse(i, j, s, nvecZ, nvecLim);
				end
			end
		else
			dZf_dvecLim = sparse(nvecZ, nvecLim);
		end
	else
		dZf_dvecLim = sparse(nvecZ, nvecLim);
	end
end
%end dfe_dvecLim_auto
