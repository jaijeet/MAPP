function dZq_dvecY = dqe_dvecY_auto(vecX, vecY, vecLim, MOD)
%function dZq_dvecY = dqe_dvecY_auto(vecX, vecY, vecLim, MOD)
%This function computes dqe_dvecY using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dZq_dvecY       - dqe_dvecY(vecX, vecY, vecLim, vecU, MOD)

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
		fprintf(2,'dqe_dvecY_auto: vecvalder (needed for computing dqe/dvecY) not found - aborting');
		dZq_dvecY = [];
		return;
	end
    %}

	if 4 > nargin
		MOD = vecLim;
	end

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	iunames = feval(MOD.InternalUnkNames, MOD);

	nvecZ = length(eonames);
	nvecY = length(iunames);

	if nvecZ > 0 && nvecY > 0
		vvecY = vecvalder(vecY, speye(nvecY)); % single vecvalder

        if 0 == MOD.support_initlimiting
            if 4 == nargin
                error(sprintf('The model %s doesn''t support init/limiting.',...
                     feval(MOD.name, MOD)));
            else
                vvecZ = feval(MOD.qe, vecX, vvecY, MOD); 
            end
        else % 1 == MOD.support_initlimiting
            if 4 == nargin
                vvecZ = feval(MOD.qe, vecX, vvecY, vecLim, MOD); 
            else
                vvecLim = feval(MOD.vecXYtoLimitedVars, vecX, vvecY, MOD);
                vvecZ = feval(MOD.qe, vecX, vvecY, vvecLim, MOD); 
            end
        end

		if isa(vvecZ, 'vecvalder')
			dZq_dvecY = sparse(der2mat(vvecZ));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dZq_dvecY);
			if [oof1, oof2] ~= [nvecZ, nvecY]
				fprintf(2, '%s: WARNING: size of dZq_dvecY incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecZ,nvecY);
				if 0 == 1
					[i, j, s] = find(dZq_dvecY);
					[m, n] = size(dZq_dvecY);
					dZq_dvecY = sparse(i, j, s, nvecZ, nvecY);
				end
			end
		else
			dZq_dvecY = sparse(nvecZ, nvecY);
		end
	else
		dZq_dvecY = sparse(nvecZ, nvecY);
	end
end
%end dqe_dvecY_auto
