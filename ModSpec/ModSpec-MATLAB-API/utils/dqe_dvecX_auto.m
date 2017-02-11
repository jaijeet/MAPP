function dZq_dvecX = dqe_dvecX_auto(vecX, vecY, vecLim, MOD)
%function dZq_dvecX = dqe_dvecX_auto(vecX, vecY, vecLim, MOD)
%This function computes dqe_dvecX using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dZq_dvecX       - dqe_dvecX(vecX, vecY, vecLim, vecU, MOD)

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
		fprintf(2,'dqe_dvecX_auto: vecvalder (needed for computing dqe/dvecX) not found - aborting');
		dZq_dvecX = [];
		return;
	end
    %}

	if 4 > nargin
		MOD = vecLim;
	end

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	oionames = feval(MOD.OtherIONames, MOD);

	nvecZ = length(eonames);
	nvecX = length(oionames);

	if nvecZ > 0 && nvecX > 0
		vvecX = vecvalder(vecX, speye(nvecX)); % single vecvalder

        if 0 == MOD.support_initlimiting
            if 4 == nargin
                error(sprintf('The model %s doesn''t support init/limiting.',...
                     feval(MOD.name, MOD)));
            else
                vvecZ = feval(MOD.qe, vvecX, vecY, MOD); 
            end
        else % 1 == MOD.support_initlimiting
            if 4 == nargin
                vvecZ = feval(MOD.qe, vvecX, vecY, vecLim, MOD); 
            else
                vvecLim = feval(MOD.vecXYtoLimitedVars, vvecX, vecY, MOD);
                vvecZ = feval(MOD.qe, vvecX, vecY, vvecLim, MOD); 
            end
        end

		if isa(vvecZ, 'vecvalder')
			dZq_dvecX = sparse(der2mat(vvecZ));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dZq_dvecX);
			if [oof1, oof2] ~= [nvecZ, nvecX]
				fprintf(2, '%s: WARNING: size of dZq_dvecX incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecZ,nvecX);
				if 0 == 1
					[i, j, s] = find(dZq_dvecX);
					[m, n] = size(dZq_dvecX);
					dZq_dvecX = sparse(i, j, s, nvecZ, nvecX);
				end
			end
		else
			dZq_dvecX = sparse(nvecZ, nvecX);
		end
	else
		dZq_dvecX = sparse(nvecZ, nvecX);
	end
end
%end dqe_dvecX_auto
