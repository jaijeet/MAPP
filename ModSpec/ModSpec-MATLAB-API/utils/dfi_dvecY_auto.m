function dWf_dvecY = dfi_dvecY_auto(vecX, vecY, vecLim, vecU, MOD)
%function dWf_dvecY = dfi_dvecY_auto(vecX, vecY, vecLim, vecU, MOD)
%This function computes dfi_dvecY using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%OUTPUT:
%   dWf_dvecY       - dfi_dvecY(vecX,vecY,vecU,MOD)

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
		fprintf(2,'dfi_dvecY_auto: vecvalder (needed for computing dfi/dvecY) not found - aborting');
		dWf_dvecY = [];
		return;
	end
    %}

	if 5 > nargin
		MOD = vecU;
		vecU = vecLim;
	end

	ienames = feval(MOD.ImplicitEquationNames, MOD);
	iunames = feval(MOD.InternalUnkNames, MOD);

	nvecW = length(ienames);
	nvecY = length(iunames);

	if nvecW > 0 && nvecY > 0
		vvecY = vecvalder(vecY, speye(nvecY)); % single vecvalder

        if 0 == MOD.support_initlimiting
            if 5 == nargin
                error(sprintf('The model %s doesn''t support init/limiting.',...
                     feval(MOD.name, MOD)));
            else
                vvecW = feval(MOD.fi, vecX, vvecY, vecU, MOD); 
            end
        else % 1 == MOD.support_initlimiting
            if 5 == nargin
                vvecW = feval(MOD.fi, vecX, vvecY, vecLim, vecU, MOD); 
            else
                vvecLim = feval(MOD.vecXYtoLimitedVars, vecX, vvecY, MOD);
                vvecW = feval(MOD.fi, vecX, vvecY, vvecLim, vecU, MOD); 
            end
        end

		if isa(vvecW, 'vecvalder')
			dWf_dvecY = sparse(der2mat(vvecW));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dWf_dvecY);
			if [oof1, oof2] ~= [nvecW, nvecY]
				fprintf(2, '%s: WARNING: size of dWf_dvecY incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecW,nvecY);
				if 0 == 1
					[i, j, s] = find(dWf_dvecY);
					[m, n] = size(dWf_dvecY);
					dWf_dvecY = sparse(i, j, s, nvecW, nvecY);
				end
			end
		else
			dWf_dvecY = sparse(nvecW, nvecY);
		end
	else
		dWf_dvecY = sparse(nvecW, nvecY);
	end
end
%end dfi_dvecY_auto
