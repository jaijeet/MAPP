function dWf_dvecLim = dfi_dvecLim_auto(vecX, vecY, vecLim, vecU, MOD)
%function dWf_dvecLim = dfi_dvecLim_auto(vecX, vecY, vecLim, vecU, MOD)
%This function computes dfi/dvecLim using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dWf_dvecLim       - dfi_dvecLim(vecX, vecY, vecLim, vecU, MOD)

%Author: Tianshi Wang <tianshi@berkeley.edu> 2013/03/29
% 
    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dfi_dvecLim_auto: vecvalder (needed for computing dfi/dvecLim) not found - aborting');
		dWf_dvecLim = [];
		return;
	end
    %}

	ienames = feval(MOD.ImplicitEquationNames, MOD);
	limnames = feval(MOD.LimitedVarNames, MOD);

	nvecW = length(ienames);
	nvecLim = length(limnames);

	if nvecW > 0 && nvecLim > 0
		vvecLim = vecvalder(vecLim, speye(nvecLim)); % single vecvalder

		vvecW = feval(MOD.fi, vecX, vecY, vvecLim, vecU, MOD); 

		if isa(vvecW, 'vecvalder')
			dWf_dvecLim = sparse(der2mat(vvecW));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dWf_dvecLim);
			if [oof1, oof2] ~= [nvecW, nvecLim]
				fprintf(2, '%s: WARNING: size of dWf_dvecLim incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecW,nvecLim);
				if 0 == 1
					[i, j, s] = find(dWf_dvecLim);
					[m, n] = size(dWf_dvecLim);
					dWf_dvecLim = sparse(i, j, s, nvecW, nvecLim);
				end
			end
		else
			dWf_dvecLim = sparse(nvecW, nvecLim);
		end
	else
		dWf_dvecLim = sparse(nvecW, nvecLim);
	end
end
%end dfi_dvecLim_auto
