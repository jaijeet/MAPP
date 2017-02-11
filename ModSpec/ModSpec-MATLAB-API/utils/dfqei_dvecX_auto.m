function [dfe_dvecX, dfi_dvecX, dqe_dvecX, dqi_dvecX] = dfqei_dvecX_auto(vecX, vecY, vecLim, vecU, MOD)
%function [dfe_dvecX, dfi_dvecX, dqe_dvecX, dqi_dvecX] = dfqei_dvecX_auto(vecX, vecY, vecLim, vecU, MOD)
%This function computes d{f,q} X {e,i}/dvecX using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%	MOD				- struct (Modspec struct)
%OUTPUT:
%	dfe_dvecX
%	dqe_dvecX 
%	dfi_dvecX 
%	dqi_dvecX

%Author: Bichen Wu <bichen@berkeley.edu> 2014/05/13
%
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
		fprintf(2,'dfqei_dvecX_auto: vecvalder (needed for computing dfe/dvecX) not found - aborting');
		dZf_dvecX = [];
		return;
	end
    %}

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	ienames = feval(MOD.ImplicitEquationNames, MOD);
	oionames = feval(MOD.OtherIONames, MOD);

	nvecZ = length(eonames);
	nvecW = length(ienames);
	nvecX = length(oionames);

	if nvecZ > 0 && nvecX > 0
		vvecX = vecvalder(vecX, speye(nvecX)); % single vecvalder

		[vdfe_dvecX, vdfi_dvecX, vdqe_dvecX, vdqi_dvecX] = feval(MOD.fqei, vvecX, vecY, vecLim, vecU, MOD); 

		if isa(vdfe_dvecX, 'vecvalder')
			dfe_dvecX = sparse(der2mat(vdfe_dvecX));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dfe_dvecX);
			if [oof1, oof2] ~= [nvecZ, nvecX]
				fprintf(2, '%s: WARNING: size of dZf_dvecX incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecZ,nvecX);
			end
		else
			dfe_dvecX = sparse(nvecZ, nvecX);
		end

		if isa(vdfi_dvecX, 'vecvalder')
			dfi_dvecX = sparse(der2mat(vdfi_dvecX));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dfi_dvecX);
			if [oof1, oof2] ~= [nvecW, nvecX]
				fprintf(2, '%s: WARNING: size of dZf_dvecX incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecZ,nvecX);
			end
		else
			dfi_dvecX = sparse(nvecW, nvecX);
		end

		if isa(vdqe_dvecX, 'vecvalder')
			dqe_dvecX = sparse(der2mat(vdqe_dvecX));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dqe_dvecX);
			if [oof1, oof2] ~= [nvecZ, nvecX]
				fprintf(2, '%s: WARNING: size of dZf_dvecX incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecZ,nvecX);
			end
		else
			dqe_dvecX = sparse(nvecZ, nvecX);
		end

		if isa(vdqi_dvecX, 'vecvalder')
			dqi_dvecX = sparse(der2mat(vdqi_dvecX));
			% adjust sparse matrix size if necessary
			[oof1, oof2] = size(dqi_dvecX);
			if [oof1, oof2] ~= [nvecW, nvecX]
				fprintf(2, '%s: WARNING: size of dZf_dvecX incorrect: [%d,%d] != [%d,%d]\n', oof1,oof2,nvecZ,nvecX);
			end
		else
			dqi_dvecX = sparse(nvecW, nvecX);
		end
	else
		dfe_dvecX = sparse(nvecZ, nvecX);
		dfi_dvecX = sparse(nvecW, nvecX);
		dqe_dvecX = sparse(nvecZ, nvecX);
		dqi_dvecX = sparse(nvecW, nvecX);
	end
end
%end dfqei_dvecX_auto
