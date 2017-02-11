function [fqei J] = dfqei_dvecXYLimU_auto(vecX, vecY, vecLim, vecU, MOD)
%function [fqei J] = dfqei_dvecXYLimU_auto(vecX, vecY, vecLim, vecU, MOD)
%This function computes d{f,q}{e,i}/dvec{X,Y,Lim,U} using vecvalder (automatic differentiation).
%INPUT args:
%   vecX            - vector (ModSpec other IOs)
%   vecY            - vector (ModSpec internal variables)
%   vecLim          - vector (ModSpec limited variables)
%   vecU            - vector (ModSpec inputs)
%	MOD				- struct (Modspec struct)
%
%OUTPUTS:
%
%	fqei.fe 
%	fqei.qe
%	fqei.fi
%	fqei.qi
%
%	J.Jfe			- struct that contains:
%						.dfe_dvecX
%						.dfe_dvecY
%						.dfe_dvecLim
%						.dfe_dvecU
%	J.Jqe			- struct that contains:
%						.dqe_dvecX
%						.dqe_dvecY
%						.dqe_dvecLim
%	J.Jfi			- struct that contains:
%						.dfi_dvecX
%						.dfi_dvecY
%						.dfi_dvecLim
%						.dfi_dvecU
%	J.Jqi			- struct that contains:
%						.dqi_dvecX
%						.dqi_dvecY
%						.dqi_dvecLim
%

%Author: Bichen Wu <bichen@berkeley.edu> 2014/05/13
%- Later updates by Tianshi Wang <tianshi@berkeley.edu>
%- Help text updated by JR, 2016/06/13.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %{
    for Octave not to complain
	if 2 ~= exist('vecvalder', 'file') && 6 ~= exist('vecvalder', 'file')
		fprintf(2,'dfqei_dvecXYLimU_auto: vecvalder (needed for computing dfqei/dvecX) not found - aborting');
		dfe_dvecX = [];
		dqe_dvecX = [];
		dfi_dvecX = [];
		dqi_dvecX = [];
		return;
	end
    %}

	if 5 > nargin
		MOD = vecU;
		vecU = vecLim;
	end

	eonames = feval(MOD.ExplicitOutputNames, MOD);
	ienames = feval(MOD.ImplicitEquationNames, MOD);
	oionames = feval(MOD.OtherIONames, MOD);
	iunames = feval(MOD.InternalUnkNames, MOD);
	if 1 == MOD.support_initlimiting
		limnames = feval(MOD.LimitedVarNames, MOD);
	end
	unames = feval(MOD.uNames, MOD);

	nvecZ = length(eonames);
	nvecW = length(ienames);
	nvecX = length(oionames);
	nvecY = length(iunames);
	if 1 == MOD.support_initlimiting
		nvecLim = length(limnames);
	end
	nvecU = length(unames);
	
	% Tianshi: the if-else below is slightly verbose, but kept just to make
	% sure logic is correct
	% Tianshi: len is the total number of independent vars
	if 0 == MOD.support_initlimiting
		if 5 == nargin
			error(sprintf('The model %s doesn''t support init/limiting.',...
				 feval(MOD.name, MOD)));
		else
			len = nvecX + nvecY + nvecU;
		end
	else % 1 == MOD.support_initlimiting
		if 5 == nargin
			len = nvecX + nvecY + nvecLim + nvecU;
		else
			len = nvecX + nvecY + nvecU;
		end
	end

	if nvecX > 0
		der = sparse(nvecX, len);
		idx = 0;
		for i = 1:nvecX
			der(i,idx+i) = 1;
		end
		vvecX = vecvalder(vecX, der);
	else
		vvecX = [];
	end

	if nvecY > 0
		der = sparse(nvecY, len);
		idx = nvecX;
		for i = 1:nvecY
			der(i,idx+i) = 1;
		end
		vvecY = vecvalder(vecY, der);
	else
		vvecY = [];
	end

	if 1 == MOD.support_initlimiting
		if 5 == nargin
			if nvecLim > 0
				der = sparse(nvecLim, len);
				idx = nvecX+nvecY;
				for i = 1:nvecLim
					der(i,idx+i) = 1;
				end
				vvecLim = vecvalder(vecLim, der);
			else
				vvecLim = [];
			end
		else
			vvecLim = feval(MOD.vecXYtoLimitedVars, vvecX, vvecY, MOD);
		end
	end

	if nvecU > 0
		der = sparse(nvecU, len);
		if 1 == MOD.support_initlimiting && 5 == nargin
			idx = nvecX+nvecY+nvecLim;
		else
			idx = nvecX+nvecY;
		end
		for i = 1:nvecU
			der(i,idx+i) = 1;
		end
		vvecU = vecvalder(vecU, der);
	else
		vvecU = [];
	end
	
	flag.fe = 1; flag.qe = 1; flag.fi = 1; flag.qi = 1;
	if 5 == nargin
		[vvecfe, vvecqe, vvecfi, vvecqi] = feval(MOD.fqei, vvecX, vvecY, vvecLim, vvecU, flag, MOD);
	else
		[vvecfe, vvecqe, vvecfi, vvecqi] = feval(MOD.fqei, vvecX, vvecY, vvecU, flag, MOD);
	end

	if isa(vvecfe, 'vecvalder')
		Jfe = sparse(der2mat(vvecfe));
		fe = val2mat(vvecfe);
	else
		Jfe = sparse(nvecZ, len);
		if isempty(Jfe)
			fe = sparse(nvecZ,0);
		else
			fe = vvecfe;
		end
	end
	Jfeout.dfe_dvecX = Jfe(:,1:nvecX);
	Jfeout.dfe_dvecY = Jfe(:,nvecX+1:nvecX+nvecY);
	if 1 == MOD.support_initlimiting && 5 == nargin
		Jfeout.dfe_dvecLim = Jfe(:,nvecX+nvecY+1:nvecX+nvecY+nvecLim);
		Jfeout.dfe_dvecU = Jfe(:,nvecX+nvecY+nvecLim+1:nvecX+nvecY+nvecLim+nvecU);
	else
		Jfeout.dfe_dvecLim = [];
		Jfeout.dfe_dvecU = Jfe(:,nvecX+nvecY+1:nvecX+nvecY+nvecU);
	end

	if isa(vvecqe, 'vecvalder')
		Jqe = sparse(der2mat(vvecqe));
		qe = val2mat(vvecqe);
	else
		Jqe = sparse(nvecZ, len);
		if isempty(Jqe)
			qe = sparse(nvecZ,0);
		else
			qe = vvecqe;
		end
	end
	Jqeout.dqe_dvecX = Jqe(:,1:nvecX);
	Jqeout.dqe_dvecY = Jqe(:,nvecX+1:nvecX+nvecY);
	if 1 == MOD.support_initlimiting && 5 == nargin
		Jqeout.dqe_dvecLim = Jqe(:,nvecX+nvecY+1:nvecX+nvecY+nvecLim);
	else
		Jqeout.dqe_dvecLim = [];
	end

	if isa(vvecfi, 'vecvalder')
		Jfi = sparse(der2mat(vvecfi));
		fi = val2mat(vvecfi);
	else
		Jfi = sparse(nvecW, len);
		if isempty(Jfi)
			fi = sparse(nvecW,0);
		else
			fi = vvecfi;
		end
	end
	Jfiout.dfi_dvecX = Jfi(:,1:nvecX);
	Jfiout.dfi_dvecY = Jfi(:,nvecX+1:nvecX+nvecY);
	if 1 == MOD.support_initlimiting && 5 == nargin
		Jfiout.dfi_dvecLim = Jfi(:,nvecX+nvecY+1:nvecX+nvecY+nvecLim);
		Jfiout.dfi_dvecU = Jfi(:,nvecX+nvecY+nvecLim+1:nvecX+nvecY+nvecLim+nvecU);
	else
		Jfiout.dfi_dvecLim = [];
		Jfiout.dfi_dvecU = Jfi(:,nvecX+nvecY+1:nvecX+nvecY+nvecU);
	end

	if isa(vvecqi, 'vecvalder')
		Jqi = sparse(der2mat(vvecqi));
		qi = val2mat(vvecqi);
	else
		Jqi = sparse(nvecW, len);
		if isempty(Jqi)
			qi = sparse(nvecW,0);
		else
			qi = vvecqi;
		end
	end
	Jqiout.dqi_dvecX = Jqi(:,1:nvecX);
	Jqiout.dqi_dvecY = Jqi(:,nvecX+1:nvecX+nvecY);
	if 1 == MOD.support_initlimiting && 5 == nargin
		Jqiout.dqi_dvecLim = Jqi(:,nvecX+nvecY+1:nvecX+nvecY+nvecLim);
	else
		Jqiout.dqi_dvecLim = Jqi(:,nvecX+nvecY+1:nvecX+nvecY);
	end

	fqei.fe = fe;
	fqei.qe = qe;
	fqei.fi = fi;
	fqei.qi = qi;

	J.Jfe = Jfeout;
	J.Jqe = Jqeout;
	J.Jfi = Jfiout;
	J.Jqi = Jqiout;

end
%end dfe_dvecX_auto
