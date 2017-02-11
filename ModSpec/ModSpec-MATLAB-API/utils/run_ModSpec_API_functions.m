function run_ModSpec_API_functions(MOD)
%function run_ModSpec_API_functions(MOD)
% A script to run all ModSpec API function to check every function runs (Does
% not imply correctness of model).
%INPUT arg:
%   MOD         - a ModSpec model object
%
%OUTPUT: <none>

%author: J. Roychowdhury.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	fprintf(1, '--------------------------------------------\n');
	% run ModelName
	mnm = feval(MOD.ModelName, MOD);
	fprintf(1, 'ModelName: %s\n', mnm);

	% run name
	nm = feval(MOD.name, MOD);
	fprintf(1, 'element name (id): ''%s''\n', nm);

	% run SpiceKey
	spk = feval(MOD.SpiceKey, MOD);
	fprintf(1, 'SpiceKey: %s\n', spk);

	% run description
	desc = feval(MOD.description, MOD);
	fprintf(1, 'description: %s\n\n', desc);

	% run NIL.NodeNames
	nnames = feval(MOD.NIL.NodeNames, MOD);
	fprintf(1, 'NIL.NodeNames: %s\n', cell2str(nnames));

	% run NIL.RefNodeName
	rnn = feval(MOD.NIL.RefNodeName, MOD);
	fprintf(1, 'NIL.RefNodeName: %s\n\n', rnn);

	% run IOnames (derived from NIL.NodeNames and NIL.RefNodeName)
	ionames = feval(MOD.IOnames, MOD);
	fprintf(1, 'IOnames (derived): %s\n', cell2str(ionames));

	% run NIL.IOtypes
	iotypes = feval(MOD.NIL.IOtypes, MOD);
	fprintf(1, 'NIL.IOtypes (derived): %s\n', cell2str(iotypes));

	% run NIL.IOnodeNames
	ionn = feval(MOD.NIL.IOnodeNames, MOD);
	fprintf(1, 'NIL.IOnodeNames (derived): %s\n\n', cell2str(ionn));

	% run ExplicitOutputNames
	eons = feval(MOD.ExplicitOutputNames, MOD);
	fprintf(1, 'ExplicitOutputNames: %s\n', cell2str(eons));

	% run OtherIONames (derived from IOnames and ExplicitOutputNames)
	oions = feval(MOD.OtherIONames, MOD);
	fprintf(1, 'OtherIONames (derived): %s\n\n', cell2str(oions));

	% run InternalUnkNames
	iuns = feval(MOD.InternalUnkNames, MOD);
	fprintf(1, 'InternalUnkNames: %s\n', cell2str(iuns));

	% run LimitedVarNames
	lvars = feval(MOD.LimitedVarNames, MOD);
	fprintf(1, 'LimitedVarNames: %s\n', cell2str(lvars));

	% run ImplicitEquationNames
	iens = feval(MOD.ImplicitEquationNames, MOD);
	fprintf(1, 'ImplicitEquationNames: %s\n\n', cell2str(iens));

	% run uNames
	unames = feval(MOD.uNames, MOD);
	fprintf(1, 'uNames: %s\n\n', cell2str(unames));

	% run parmnames
	parmnames = feval(MOD.parmnames, MOD);
	fprintf(1, 'parmnames: %s\n', cell2str(parmnames));

	% parmdefaults
	parmvals = feval(MOD.parmdefaults, MOD);
	parmdefaults = parmvals

	if length(parmvals) > 0
		% setparms
		parmvals{end} = (2*parmvals{end}+0.5);
		MOD = feval(MOD.setparms, parmvals, MOD);
		fprintf(1, 'running setparms: last parameter set to %g\n', parmvals{end}); 

		% getparms
		newpvals = feval(MOD.getparms, MOD);
		err = parmvals{end} - newpvals{end};
		if 0 == err
			fprintf(1, 'running getparms: last parameter was set correctly\n');
		else
			fprintf(1, 'running getparms: ERROR: last parameter setting was off by %g\n', err);
		end
	end % if

	% fe, qe, fi, qi and their derivatives

	vecX = rand(length(oions),1); fprintf(1, '\nvecX chosen to be rand(%d=length(OtherIOs))\n', length(vecX));
	vecY = rand(length(iuns),1); fprintf(1, 'vecY chosen to be rand(%d=length(InternalUnkNames))\n', length(vecY));
	vecU = rand(length(unames),1); fprintf(1, 'vecU chosen to be rand(%d=length(uNames))\n\n', length(vecU));
	vecLim = rand(length(lvars),1); fprintf(1, 'vecLim chosen to be rand(%d=length(LimitedVarNames))\n\n', length(vecLim));
	vecLimOld = rand(length(lvars),1); fprintf(1, 'vecLimOld chosen to be rand(%d=length(LimitedVarNames))\n\n', length(vecLimOld));

	% run fe(vecX, vecY, vecLim, vecU) to get vecZf
	vecZf = feval(MOD.fe, vecX, vecY, vecLim, vecU, MOD);
	fprintf(1, 'running vecZf=fe(vecX,vecY,vecLim,vecU):\n\t');
	if length(vecZf) == length(eons)
		fprintf(1, 'vecZf length (=%d) is correct (=length(ExplicitOutputNames))\n', length(vecZf));
	else
		fprintf(1, 'vecZf length (=%d) is WRONG (!=length(ExplicitOutputNames))\n', length(vecZf));
	end
	vecZf

	% run dfe_dvecX(vecX, vecY, vecLim, vecU) 
	dvecZf_dvecX = feval(MOD.dfe_dvecX, vecX, vecY, vecLim, vecU, MOD);
	fprintf(1, 'running dvecZf_dvecX=dfe_dvecX(vecX,vecY,vecLim,vecU):\n\t');
	[oof1, oof2] = size(dvecZf_dvecX);
	if [oof1, oof2] == [length(eons), length(oions)]
		fprintf(1, 'dvecZf_dvecX size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(OtherIOnames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecZf_dvecX size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(OtherIOnames)])!\n', oof1, oof2);
	end
	dvecZf_dvecX = full(dvecZf_dvecX)

	% run dfe_dvecY(vecX, vecY, vecLim, vecU) 
	dvecZf_dvecY = feval(MOD.dfe_dvecY, vecX, vecY, vecLim, vecU, MOD);
	fprintf(1, 'running dvecZf_dvecY=dfe_dvecY(vecX,vecY,vecLim,vecU):\n\t');
	[oof1, oof2] = size(dvecZf_dvecY);
	if [oof1, oof2] == [length(eons), length(iuns)]
		fprintf(1, 'dvecZf_dvecY size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(InternalUnkNames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecZf_dvecY size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(InternalUnkNames)])!\n', oof1, oof2);
	end
	dvecZf_dvecY = full(dvecZf_dvecY)

	% run dfe_dvecLim(vecX, vecY, vecLim, vecLim) 
	dvecZf_dvecLim = feval(MOD.dfe_dvecLim, vecX, vecY, vecLim, vecU, MOD);
	fprintf(1, 'running dvecZf_dvecLim=dfe_dvecLim(vecX,vecY,vecLim,vecU):\n\t');
	[oof1, oof2] = size(dvecZf_dvecLim);
	if [oof1, oof2] == [length(eons), length(lvars)]
		fprintf(1, 'dvecZf_dvecLim size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(uNames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecZf_dvecLim size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(uNames)])!\n', oof1, oof2);
	end
	dvecZf_dvecLim = full(dvecZf_dvecLim)

	% run dfe_dvecU(vecX, vecY, vecLim, vecU) 
	dvecZf_dvecU = feval(MOD.dfe_dvecU, vecX, vecY, vecLim, vecU, MOD);
	fprintf(1, 'running dvecZf_dvecU=dfe_dvecU(vecX,vecY,vecLim,vecU):\n\t');
	[oof1, oof2] = size(dvecZf_dvecU);
	if [oof1, oof2] == [length(eons), length(unames)]
		fprintf(1, 'dvecZf_dvecU size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(uNames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecZf_dvecU size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(uNames)])!\n', oof1, oof2);
	end
	dvecZf_dvecU = full(dvecZf_dvecU)

	% run qe(vecX, vecY) to get vecZq
	vecZq = feval(MOD.qe, vecX, vecY, vecLim, MOD);
	fprintf(1, 'running vecZq=qe(vecX,vecY,vecLim):\n\t');
	if length(vecZq) == length(eons)
		fprintf(1, 'vecZq length (=%d) is correct (=length(ExplicitOutputNames))\n', length(vecZq));
	else
		fprintf(1, 'vecZq length (=%d) is WRONG (!=length(ExplicitOutputNames))\n', length(vecZq));
	end
	vecZq

	% run dqe_dvecX(vecX, vecY, vecLim, vecU) 
	dvecZq_dvecX = feval(MOD.dqe_dvecX, vecX, vecY, vecLim, MOD);
	fprintf(1, 'running dvecZq_dvecX=dqe_dvecX(vecX,vecY,vecLim,vecU):\n\t');
	[oof1, oof2] = size(dvecZq_dvecX);
	if [oof1, oof2] == [length(eons), length(oions)]
		fprintf(1, 'dvecZq_dvecX size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(OtherIOnames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecZq_dvecX size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(OtherIOnames)])!\n', oof1, oof2);
	end
	dvecZq_dvecX = full(dvecZq_dvecX)

	% run dqe_dvecY(vecX, vecY, vecLim, vecU) 
	dvecZq_dvecY = feval(MOD.dqe_dvecY, vecX, vecY, vecLim, MOD);
	fprintf(1, 'running dvecZq_dvecY=dqe_dvecY(vecX,vecY,vecLim,vecU):\n\t');
	[oof1, oof2] = size(dvecZq_dvecY);
	if [oof1, oof2] == [length(eons), length(iuns)]
		fprintf(1, 'dvecZq_dvecY size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(InternalUnkNames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecZq_dvecY size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(InternalUnkNames)])!\n', oof1, oof2);
	end
	dvecZq_dvecY = full(dvecZq_dvecY)

	% run fi(vecX, vecY, vecLim, vecU) to get vecWf
	vecWf = feval(MOD.fi, vecX, vecY, vecLim, vecU, MOD);
	fprintf(1, 'running vecWf=fi(vecX,vecY,vecLim,vecU):\n\t');
	if length(vecWf) == length(iens)
		fprintf(1, 'vecWf length (=%d) is correct (=length(ImplicitEquationNames))\n', length(vecWf));
	else
		fprintf(1, 'vecWf length (=%d) is WRONG (!=length(ImplicitEquationNames))\n', length(vecWf));
	end
	vecWf

	% run dfi_dvecX(vecX, vecY, vecLim, vecU) 
	dvecWf_dvecX = feval(MOD.dfi_dvecX, vecX, vecY, vecLim, vecU, MOD);
	fprintf(1, 'running dvecWf_dvecX=dfi_dvecX(vecX,vecY,vecLim,vecU):\n\t');
	[oof1, oof2] = size(dvecWf_dvecX);
	if [oof1, oof2] == [length(iens), length(oions)]
		fprintf(1, 'dvecWf_dvecX size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(OtherIOnames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecWf_dvecX size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(OtherIOnames)])!\n', oof1, oof2);
	end
	dvecWf_dvecX = full(dvecWf_dvecX)

	% run dfi_dvecY(vecX, vecY, vecLim, vecU) 
	dvecWf_dvecY = feval(MOD.dfi_dvecY, vecX, vecY, vecLim, vecU, MOD);
	fprintf(1, 'running dvecWf_dvecY=dfi_dvecY(vecX,vecY,vecLim,vecU):\n\t');
	[oof1, oof2] = size(dvecWf_dvecY);
	if [oof1, oof2] == [length(iens), length(iuns)]
		fprintf(1, 'dvecWf_dvecY size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(InternalUnkNames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecWf_dvecY size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(InternalUnkNames)])!\n', oof1, oof2);
	end
	dvecWf_dvecY = full(dvecWf_dvecY)

	% run dfi_dvecU(vecX, vecY, vecLim, vecU) 
	dvecWf_dvecU = feval(MOD.dfi_dvecU, vecX, vecY, vecLim, vecU, MOD);
	fprintf(1, 'running dvecWf_dvecU=dfi_dvecU(vecX,vecY,vecLim,vecU):\n\t');
	[oof1, oof2] = size(dvecWf_dvecU);
	if [oof1, oof2] == [length(iens), length(unames)]
		fprintf(1, 'dvecWf_dvecU size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(uNames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecWf_dvecU size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(uNames)])!\n', oof1, oof2);
	end
	dvecWf_dvecU = full(dvecWf_dvecU)

	% run qi(vecX, vecY) to get vecWf
	vecWq = feval(MOD.qi, vecX, vecY, vecLim, MOD);
	fprintf(1, 'running vecWq=qi(vecX,vecY,vecLim):\n\t');
	if length(vecWq) == length(iens)
		fprintf(1, 'vecWq length (=%d) is correct (=length(ImplicitEquationNames))\n', length(vecWq));
	else
		fprintf(1, 'vecWq length (=%d) is WRONG (!=length(ImplicitEquationNames))\n', length(vecWq));
	end
	vecWq

	% run dqi_dvecX(vecX, vecY, vecLim, vecU) 
	dvecWq_dvecX = feval(MOD.dqi_dvecX, vecX, vecY, vecLim, MOD);
	fprintf(1, 'running dvecWq_dvecX=dqi_dvecX(vecX,vecY,vecLim):\n\t');
	[oof1, oof2] = size(dvecWq_dvecX);
	if [oof1, oof2] == [length(iens), length(oions)]
		fprintf(1, 'dvecWq_dvecX size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(OtherIOnames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecWq_dvecX size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(OtherIOnames)])!\n', oof1, oof2);
	end
	dvecWq_dvecX = full(dvecWq_dvecX)

	% run dqi_dvecY(vecX, vecY, vecLim, vecU) 
	dvecWq_dvecY = feval(MOD.dqi_dvecY, vecX, vecY, vecLim, MOD);
	fprintf(1, 'running dvecWq_dvecY=dqi_dvecY(vecX,vecY,vecLim):\n\t');
	[oof1, oof2] = size(dvecWq_dvecY);
	if [oof1, oof2] == [length(iens), length(iuns)]
		fprintf(1, 'dvecWq_dvecY size (=[%d,%d]) is correct (=[length(ExplicitOutputNames), length(InternalUnkNames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecWq_dvecY size (=[%d,%d]) is WRONG (!=[length(ExplicitOutputNames), length(InternalUnkNames)])!\n', oof1, oof2);
	end
	dvecWq_dvecY = full(dvecWq_dvecY)

	% run initGuess(vecU) 
	initguess = feval(MOD.initGuess, vecU, MOD);
	fprintf(1, 'running initguess = initGuess(vecU):\n\t');
	if length(initguess) == length(lvars)
		fprintf(1, 'initguess length (=%d) is correct (=length(LimitedVarNames))\n', length(lvars));
	else
		fprintf(1, 'initguess length (=%d) is WRONG (!=length(LimitedVarNames))\n', length(lvars));
	end
	initguess

	% run limiting(vecX, vecY, vecLimOld, u) 
	vecLimNew = feval(MOD.limiting, vecX, vecY, vecLimOld, vecU, MOD);
	fprintf(1, 'running vecLimNew = limiting(vecX,vecY,vecLimOld,vecU):\n\t');
	if length(vecLimNew) == length(lvars)
		fprintf(1, 'vecLimNew length (=%d) is correct (=length(LimitedVarNames))\n', length(lvars));
	else
		fprintf(1, 'vecLimNew length (=%d) is WRONG (!=length(LimitedVarNames))\n', length(lvars));
	end
	vecLimNew

	% run dlimiting_dvecX(vecX, vecY, vecLimOld, vecU) 
	dvecLim_dvecX = feval(MOD.dlimiting_dvecX, vecX, vecY, vecLimOld, vecU, MOD);
	fprintf(1, 'running dvecLim_dvecX=dlimiting_dvecX(vecX,vecY,vecLimOld,vecU):\n\t');
	[oof1, oof2] = size(dvecLim_dvecX);
	if [oof1, oof2] == [length(lvars), length(oions)] % tianshi: probably not correct in Matlab, need to check TODO
		fprintf(1, 'dvecLim_dvecX size (=[%d,%d]) is correct (=[length(LimitedVarNames), length(OtherIOnames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecLim_dvecX size (=[%d,%d]) is WRONG (!=[length(LimitedVarNames), length(OtherIOnames)])\n', oof1, oof2);
	end
	dvecLim_dvecX = full(dvecLim_dvecX)

	% run dlimiting_dvecY(vecX, vecY, vecLimOld, vecU) 
	dvecLim_dvecY = feval(MOD.dlimiting_dvecY, vecX, vecY, vecLimOld, vecU, MOD);
	fprintf(1, 'running dvecLim_dvecY=dlimiting_dvecY(vecX,vecY,vecLimOld,vecU):\n\t');
	[oof1, oof2] = size(dvecLim_dvecY);
	if [oof1, oof2] == [length(lvars), length(iuns)]
		fprintf(1, 'dvecLim_dvecY size (=[%d,%d]) is correct (=[length(LimitedVarNames), length(InternalUnkNames)])\n', oof1, oof2);
	else
		fprintf(1, 'dvecLim_dvecY size (=[%d,%d]) is WRONG (!=[length(LimitedVarNames), length(InternalUnkNames)])\n', oof1, oof2);
	end
	dvecLim_dvecY = full(dvecLim_dvecY)

	fprintf(1, '--------------------------------------------\n');
end
