function dWq_dvecX = dqi_dvecX_auto(vecX, vecY, vecLim, MOD)
%function dWq_dvecX = dqi_dvecX_auto(vecX, vecY, vecLim, MOD)
%This function computes dqi_dvecX using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dWq_dvecX       - dqi_dvecX(vecX, vecY, vecLim, vecU, MOD)

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
		fprintf(2,'dqi_dvecX_auto: vecvalder (needed for computing dqi/dvecX) not found - aborting');
		dWq_dvecX = [];
		return;
	end
    %}

	if 4 > nargin
		MOD = vecLim;
	end

	ienames = feval(MOD.ImplicitEquationNames, MOD);
	oionames = feval(MOD.OtherIONames, MOD);

	nvecW = length(ienames);
	nvecX = length(oionames);

	if nvecW > 0 && nvecX > 0
		vvecX = vecvalder(vecX, speye(nvecX)); % single vecvalder

        if 0 == MOD.support_initlimiting
            if 4 == nargin
                error(sprintf('The model %s doesn''t support init/limiting.',...
                     feval(MOD.name, MOD)));
            else
                vvecW = feval(MOD.qi, vvecX, vecY, MOD); 
            end
        else % 1 == MOD.support_initlimiting
            if 4 == nargin
                vvecW = feval(MOD.qi, vvecX, vecY, vecLim, MOD); 
            else
                vvecLim = feval(MOD.vecXYtoLimitedVars, vvecX, vecY, MOD);
                vvecW = feval(MOD.qi, vvecX, vecY, vvecLim, MOD); 
            end
        end

		if isa(vvecW, 'vecvalder')
			dWq_dvecX = sparse(der2mat(vvecW));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dWq_dvecX);
			if [oof1, oof2] ~= [nvecW, nvecX]
				fprintf(2, '%s: WARNING: size of dWq_dvecX incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecW,nvecX);
				if 0 == 1
					[i, j, s] = find(dWq_dvecX);
					[m, n] = size(dWq_dvecX);
					dWq_dvecX = sparse(i, j, s, nvecW, nvecX);
				end
			end
		else
			dWq_dvecX = sparse(nvecW, nvecX);
		end
	else
		dWq_dvecX = sparse(nvecW, nvecX);
	end
end
%end dqi_dvecX_auto
