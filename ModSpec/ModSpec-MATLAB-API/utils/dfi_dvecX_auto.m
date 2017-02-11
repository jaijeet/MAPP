function dWf_dvecX = dfi_dvecX_auto(vecX, vecY, vecLim, vecU, MOD)
%function dWf_dvecX = dfi_dvecX_auto(vecX, vecY, vecLim, vecU, MOD)
%This function computes dfi_dvecX using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dWf_dvecX       - dfi_dvecX(vecX, vecY, vecLim, vecU, MOD)

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
		fprintf(2,'dfi_dvecX_auto: vecvalder (needed for computing dfi/dvecX) not found - aborting');
		dWf_dvecX = [];
		return;
	end
    %}

	if 5 > nargin
		MOD = vecU;
		vecU = vecLim;
	end

	ienames = feval(MOD.ImplicitEquationNames, MOD);
	oionames = feval(MOD.OtherIONames, MOD);

	nvecW = length(ienames);
	nvecX = length(oionames);

	if nvecW > 0 && nvecX > 0
		vvecX = vecvalder(vecX, speye(nvecX)); % single vecvalder

        if 0 == MOD.support_initlimiting
            if 5 == nargin
                error(sprintf('The model %s doesn''t support init/limiting.',...
                     feval(MOD.name, MOD)));
            else
                vvecW = feval(MOD.fi, vvecX, vecY, vecU, MOD); 
            end
        else % 1 == MOD.support_initlimiting
            if 5 == nargin
                vvecW = feval(MOD.fi, vvecX, vecY, vecLim, vecU, MOD); 
            else
                vvecLim = feval(MOD.vecXYtoLimitedVars, vvecX, vecY, MOD);
                vvecW = feval(MOD.fi, vvecX, vecY, vvecLim, vecU, MOD); 
            end
        end

		if isa(vvecW, 'vecvalder')
			dWf_dvecX = sparse(der2mat(vvecW));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dWf_dvecX);
			if [oof1, oof2] ~= [nvecW, nvecX]
				fprintf(2, '%s: WARNING: size of dWf_dvecX incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecW,nvecX);
				if 0 == 1
					[i, j, s] = find(dWf_dvecX);
					[m, n] = size(dWf_dvecX);
					dWf_dvecX = sparse(i, j, s, nvecW, nvecX);
				end
			end
		else
			dWf_dvecX = sparse(nvecW, nvecX);
		end
	else
		dWf_dvecX = sparse(nvecW, nvecX);
	end
end
%end dfi_dvecX_auto
