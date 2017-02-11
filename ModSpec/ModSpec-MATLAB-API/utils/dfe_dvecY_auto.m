function dZf_dvecY = dfe_dvecY_auto(vecX, vecY, vecLim, vecU, MOD)
%function dZf_dvecY = dfe_dvecY_auto(vecX, vecY, vecLim, vecU, MOD)
%This function computes dfe_dvecY using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dZf_dvecY       - dfe_dvecY(vecX, vecY, vecLim, vecU, MOD)

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
		fprintf(2,'dfe_dvecY_auto: vecvalder (needed for computing dfe/dvecY) not found - aborting');
		dZf_dvecY = [];
		return;
	end
    %}

	if 5 > nargin
		MOD = vecU;
		vecU = vecLim;
	end

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	iunames = feval(MOD.InternalUnkNames, MOD);

	nvecZ = length(eonames);
	nvecY = length(iunames);

	if nvecZ > 0 && nvecY > 0
		vvecY = vecvalder(vecY, speye(nvecY)); % single vecvalder

        if 0 == MOD.support_initlimiting
            if 5 == nargin
                error(sprintf('The model %s doesn''t support init/limiting.',...
                     feval(MOD.name, MOD)));
            else
                vvecZ = feval(MOD.fe, vecX, vvecY, vecU, MOD); 
            end
        else % 1 == MOD.support_initlimiting
            if 5 == nargin
                vvecZ = feval(MOD.fe, vecX, vvecY, vecLim, vecU, MOD); 
            else
                vvecLim = feval(MOD.vecXYtoLimitedVars, vecX, vvecY, MOD);
                vvecZ = feval(MOD.fe, vecX, vvecY, vvecLim, vecU, MOD); 
            end
        end


		if isa(vvecZ, 'vecvalder')
			dZf_dvecY = sparse(der2mat(vvecZ));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dZf_dvecY);
			if [oof1, oof2] ~= [nvecZ, nvecY]
				fprintf(2, '%s: WARNING: size of dZf_dvecY incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecZ,nvecY);
				if 0 == 1
					[i, j, s] = find(dZf_dvecY);
					[m, n] = size(dZf_dvecY);
					dZf_dvecY = sparse(i, j, s, nvecZ, nvecY);
				end
			end
		else
			dZf_dvecY = sparse(nvecZ, nvecY);
		end
	else
		dZf_dvecY = sparse(nvecZ, nvecY);
	end
end
%end dfe_dvecY_auto
