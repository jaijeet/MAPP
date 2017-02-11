function dZf_dvecU = dfe_dvecU_auto(vecX, vecY, vecLim, vecU, MOD)
%function dZf_dvecU = dfe_dvecU_auto(vecX, vecY, vecLim, vecU, MOD)
%This function computes dfe/dvecU using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dZf_dvecU       - dfe_dvecU(vecX, vecY, vecLim, vecU, MOD)

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
		fprintf(2,'dfe_dvecU_auto: vecvalder (needed for computing dfe/dvecU) not found - aborting');
		dZf_dvecU = [];
		return;
	end
    %}

	if 5 > nargin
		MOD = vecU;
		vecU = vecLim;
	end

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	unames = feval(MOD.uNames, MOD);

	nvecZ = length(eonames);
	nvecU = length(unames);

	if nvecU > 0 && nvecZ > 0
		vvecU = vecvalder(vecU, speye(nvecU)); % single vecvalder

        if 0 == MOD.support_initlimiting
            if 5 == nargin
                error(sprintf('The model %s doesn''t support init/limiting.',...
                     feval(MOD.name, MOD)));
            else
                vvecZ = feval(MOD.fe, vecX, vecY, vvecU, MOD); 
            end
        else % 1 == MOD.support_initlimiting
            if 5 == nargin
                vvecZ = feval(MOD.fe, vecX, vecY, vecLim, vvecU, MOD); 
            else
                vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
                vvecZ = feval(MOD.fe, vecX, vecY, vecLim, vvecU, MOD); 
            end
        end

		if isa(vvecZ, 'vecvalder')
			dZf_dvecU = sparse(der2mat(vvecZ));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dZf_dvecU);
			if [oof1, oof2] ~= [nvecZ, nvecU]
				fprintf(2, '%s: WARNING: size of dZf_dvecU incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecZ,nvecU);
				if 0 == 1
					[i, j, s] = find(dZf_dvecU);
					[m, n] = size(dZf_dvecU);
					dZf_dvecU = sparse(i, j, s, nvecZ, nvecU);
				end
			end
		else
			dZf_dvecU = sparse(nvecZ, nvecU);
		end
	else % nvecU > 0 && nvecZ > 0
		dZf_dvecU = sparse(nvecZ, nvecU);
	end
end
%end dfe_dvecX_auto
