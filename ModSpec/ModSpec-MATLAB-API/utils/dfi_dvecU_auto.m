function dWf_dvecU = dfi_dvecU_auto(vecX, vecY, vecLim, vecU, MOD)
%function dWf_dvecU = dfi_dvecU_auto(vecX, vecY, vecLim, vecU, MOD)
%This function computes dfi_dvecU using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dWf_dvecU       - dfi_dvecU(vecX, vecY, vecLim, vecU, MOD)

%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2012/07/22
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
		fprintf(2,'dfi_dvecU_auto: vecvalder (needed for computing dfi/dvecU) not found - aborting');
		dWf_dvecU = [];
		return;
	end
    %}

	if 5 > nargin
		MOD = vecU;
		vecU = vecLim;
	end

	ienames = feval(MOD.ImplicitEquationNames, MOD);
	unames = feval(MOD.uNames, MOD);

	nvecW = length(ienames);
	nvecU = length(unames);

	if nvecU > 0 && nvecW > 0
		vvecU = vecvalder(vecU, speye(nvecU)); % single vecvalder

        if 0 == MOD.support_initlimiting
            if 5 == nargin
                error(sprintf('The model %s doesn''t support init/limiting.',...
                     feval(MOD.name, MOD)));
            else
                vvecW = feval(MOD.fi, vecX, vecY, vvecU, MOD); 
            end
        else % 1 == MOD.support_initlimiting
            if 5 == nargin
                vvecW = feval(MOD.fi, vecX, vecY, vecLim, vvecU, MOD); 
            else
                vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
                vvecW = feval(MOD.fi, vecX, vecY, vecLim, vvecU, MOD); 
            end
        end

		if isa(vvecW, 'vecvalder')
			dWf_dvecU = sparse(der2mat(vvecW));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dWf_dvecU);
			if [oof1, oof2] ~= [nvecW, nvecU]
				fprintf(2, '%s: WARNING: size of dWf_dvecU incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecW,nvecU);
				if 0 == 1
					[i, j, s] = find(dWf_dvecU);
					[m, n] = size(dWf_dvecU);
					dWf_dvecU = sparse(i, j, s, nvecW, nvecU);
				end
			end
		else
			dWf_dvecU = sparse(nvecW, nvecU);
		end
	else % nvecU > 0 && nvecW > 0
		dWf_dvecU = sparse(nvecW, nvecU);
	end
end
%end dfi_dvecX_auto
