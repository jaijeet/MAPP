function DAE = connectCktsAtNodes(uniqIDstr, DAE1, nodesKCLs1, nodesKCLs2, DAE2)
%function DAE = connectCktsAtNodes(uniqIDstr, DAE1, nodesKCLs1, nodesKCLs2, DAE2)
%Given two DAEs (or just a single DAE) and a list of node voltage unknowns and corresponding KCLs for each, produces a DAE corresponding to connecting the nodes together.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%
% % connect nodes 1 and 10, 5 and 7 of 2 circuit DAEs
% nDAE = connectCktsAtNodes('new', DAE1, {{'e1', 'e5'}, {'KCL1', 'KCL5'}}, {{'e10', 'e7'}, {'KCL10', 'KCL7'}}, DAE2);
%
% % concatenate 2 DAEs without connecting any nodes
% nDAE = connectCktsAtNodes('new', DAE1, {{}, {}}, {{}, {}}, DAE2);
% nDAE = connectCktsAtNodes('new', DAE1, {}, {}, DAE2);
% nDAE = connectCktsAtNodes('new', DAE1, [], [], DAE2);
%
% % connect nodes of a single DAE: nodes 1 and ground, and nodes 5 and 7
% nDAE = connectCktsAtNodes('new', DAE1, {{'e1', 'e5'}, {'KCL1', 'KCL5'}}, {{'ground', 'e7'}, {'ground', 'KCL7'}});
% there should be a special node/KCL name "ground", to be used in the node/KCL lists
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Given two DAEs (or just a single DAE) and a list of node voltage unknowns and
%corresponding KCLs for each, %produces a DAE corresponding to connecting the
%nodes together.
%
%It does this by concatenating the unknowns and equations of the two systems;
%and for each pair of nodes joined, subtracting an equation (replacing two
%KCLs by one, ie, their sum) and an unknown (replacing two node voltages by one).
%
%
%[each DAE is of the form:
% if the flag DAE.f_takes_inputs == 0:
%
% 	qdot(x, p) + f(x, p) + B*u(t) + m(x, n(t), p) = 0
%	y = C*x + D*u(t)
%
% if the flag DAE.f_takes_inputs == 1:
%
% 	qdot(x, p) + f(x, u(t), p) + m(x, n(t), p) = 0
%	y = C*x + D*u(t)
%]
%
%inputs: concatenated if two DAEs, untouched if one DAE
%outputs: concatenated if two DAEs, untouched if one DAE
%parameters: concatenated if two DAEs, untouched if one DAE
%noise inputs: concatenated if two DAEs, untouched if one DAE
%names: each DAEs uniqID prepended to all names if 2 DAEs; replicated if only one
%internalfuncs: checked to be undefined if 2 DAEs (string: "No internal 
%	functions"); otherwise an error. Replicated if one DAE.
%InitGuess: concatenated if two DAEs; replicated if one DAE.
%NRlimiting: min alpha from orig NRlimitings used.
%
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See DAEAPIv6_doc.m for documentation on the DAEAPIv6.2 functions here.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPIv6.2';
	DAE.Usage = help('connectCktsAtNodes');
	%

%data: store problem parameters, precompute stuff
	DAE.uniqIDstr = uniqIDstr;
	DAE.DAE1 = DAE1;
	DAE.nodes1 = nodesKCLs1{1};
	DAE.KCLs1 = nodesKCLs1{2};
	if nargin < 5 % uniqID, DAE1, connects1, connects2
		DAE.isDAE2 = 0;
	else
		if 1 == strcmp(feval(DAE1.uniqID, DAE1), feval(DAE2.uniqID, DAE2))
			error('DAE1 and DAE2 have the same uniqIDs - they should be different');
		else
			DAE.DAE2 = DAE2;
			DAE.isDAE2 = 1;
		end
	end
	DAE.nodes2 = nodesKCLs2{1};
	DAE.KCLs2 = nodesKCLs2{2};

	DAE.nConnects = length(DAE.nodes1);
	if length(DAE.KCLs1) ~= DAE.nConnects
		error('length of DAE1''s node and KCL lists not equal.');
	end

	nConnects2 = length(DAE.nodes2);
	if length(DAE.KCLs2) ~= nConnects2
		error('length of 2nd node and KCL lists not equal.');
	end
	if length(DAE.KCLs2) ~= DAE.nConnects
		error('length of first and second node lists not equal.');
	end

	% set up total number of unknowns
	DAE.nunkstot = feval(DAE1.nunks, DAE1) -  DAE.nConnects; % one node unknown eliminated for each connection
	if 1 == DAE.isDAE2
		DAE.nunkstot = DAE.nunkstot + feval(DAE2.nunks, DAE2);
	end

	% set up total number of equations
	DAE.neqnstot = feval(DAE1.neqns, DAE1) - DAE.nConnects; % two KCLs collapsed into one for each connection
	if 1 == DAE.isDAE2
		DAE.neqnstot = DAE.neqnstot + feval(DAE2.neqns, DAE2);
	end

	% set up: 
	%	unknown/equation names/order: DAE.mergedUnknames, DAE.mergedEqnnames
	%	mappings from mergedx to x1 and x2: DAE.DAE1unkIdxs/DAE.DAE2unkIdxs, DAE.DAE1eqnIdxs, DAE.DAE2eqnIdxs
	uniqID1 = feval(DAE.DAE1.uniqID, DAE.DAE1);
	uniqID1dot = strcat(uniqID1, '.');
	DAE.uniqID1dot = uniqID1dot;
	if 1 == DAE.isDAE2
		uniqID2 = feval(DAE.DAE2.uniqID, DAE.DAE2);
		uniqID2dot = strcat(uniqID2, '.');
		DAE.uniqID2dot = uniqID2dot;
	end

	unknames1 = feval(DAE.DAE1.unknames, DAE.DAE1);
	eqnnames1 = feval(DAE.DAE1.eqnnames, DAE.DAE1);
	if 1 == DAE.isDAE2
		unknames2 = feval(DAE.DAE2.unknames, DAE.DAE2);
		eqnnames2 = feval(DAE.DAE2.eqnnames, DAE.DAE2);
		[DAE.mergedUnknames, DAE.DAE1unkIdxs, DAE.DAE2unkIdxs, ...
			DAE.mergedCommonUnkIdxs, DAE.commonUnkIdxs1, ...
			DAE.commonUnkIdxs2, DAE.mergedOtherUnkIdxs1, ...
			DAE.otherUnkIdxs1, DAE.mergedOtherUnkIdxs2, ...
			DAE.otherUnkIdxs2] = ...
				merge_names_setup_idxs(DAE.nodes1, ...
					DAE.nodes2, unknames1, ...
					unknames2, uniqID1, uniqID2);
		[DAE.mergedEqnnames, DAE.DAE1eqnIdxs, DAE.DAE2eqnIdxs, ...
			DAE.mergedCommonEqnIdxs, DAE.commonEqnIdxs1, ...
			DAE.commonEqnIdxs2, DAE.mergedOtherEqnIdxs1, ...
			DAE.otherEqnIdxs1, DAE.mergedOtherEqnIdxs2, ...
			DAE.otherEqnIdxs2] = ...
				merge_names_setup_idxs(DAE.KCLs1, ...
					DAE.KCLs2, eqnnames1, ...
					eqnnames2, uniqID1, uniqID2);

		if max(DAE.otherEqnIdxs1) > length(DAE.mergedEqnnames)
			error(sprintf('connectCktsAtNodes constructor: max(DAE.otherEqnIdxs1) > length(DAE.mergedEqnnames)'));
		end

	else
		1==1;% DEAL WITH THIS
	end

	% set up input names, output names, mappings from merged inputs/outputs to DAE1's and DAE2's
	inputnames1 = feval(DAE.DAE1.inputnames, DAE.DAE1);
	outputnames1 = feval(DAE.DAE1.outputnames, DAE.DAE1);
	DAE.DAE1inputIdxs = 1:length(inputnames1);
	DAE.DAE1outputIdxs = 1:length(outputnames1);
	DAE.mergedInputnames = inputnames1;
	DAE.mergedOutputnames = outputnames1;
	if 1 == DAE.isDAE2
		if feval(DAE.DAE1.ninputs, DAE.DAE1) > 0
			inputnames1 = strcat(uniqID1dot, inputnames1);
		else
			inputnames1 = {};
		end
		if feval(DAE.DAE2.ninputs, DAE.DAE2) > 0
			inputnames2 = feval(DAE.DAE2.inputnames, DAE.DAE2);
			inputnames2 = strcat(uniqID2dot, inputnames2);
		else
			inputnames2 = {};
		end
		DAE.mergedInputnames = {inputnames1{:},inputnames2{:}};
		DAE.DAE2inputIdxs = length(inputnames1) + (1:length(inputnames2));

		if feval(DAE.DAE1.noutputs, DAE.DAE1) > 0
			outputnames1 = strcat(uniqID1dot, outputnames1);
		else
			outputnames1 = {};
		end
		if feval(DAE.DAE2.noutputs, DAE.DAE2) > 0
			outputnames2 = feval(DAE.DAE2.outputnames, DAE.DAE2);
			outputnames2 = strcat(uniqID2dot, outputnames2);
		else
			outputnames2 = {};
		end
		DAE.mergedOutputnames = {outputnames1{:},outputnames2{:}};
		DAE.DAE2outputIdxs = length(outputnames1) + (1:length(outputnames2));
	end

	% set up merged parameter names, mappings from merged parameters to DAE1's and DAE2's
	% 	getparms and setparms will also need wrappers
	parmnames1 = feval(DAE.DAE1.parmnames, DAE.DAE1);
	DAE.DAE1parmIdxs = 1:feval(DAE.DAE1.nparms, DAE.DAE1);
	DAE.mergedParmnames = parmnames1;
	if 1 == DAE.isDAE2
		if feval(DAE.DAE1.nparms, DAE.DAE1) > 0
			parmnames1 = strcat(uniqID1dot, parmnames1);
		else
			parmnames1 = {};
		end
		if feval(DAE.DAE2.nparms, DAE.DAE2) > 0
			parmnames2 = feval(DAE.DAE2.parmnames, DAE.DAE2);
			parmnames2 = strcat(uniqID2dot, parmnames2);
		else
			parmnames2 = {};
		end
		DAE.mergedParmnames = {parmnames1{:}, parmnames2{:}};
		DAE.DAE2parmIdxs = length(parmnames1) + (1:length(parmnames2));
	end

	% set up merged noise source names, mappings from merged noise sources to DAE1's and DAE2's
	nsnames1 = feval(DAE.DAE1.NoiseSourceNames, DAE.DAE1);
	DAE.DAE1noiseSrcIdxs = 1:feval(DAE.DAE1.nNoiseSources, DAE.DAE1);
	DAE.mergedNoiseSourceNames = nsnames1;
	if 1 == DAE.isDAE2
		if feval(DAE.DAE1.nNoiseSources, DAE.DAE1) > 0
			nsnames1 = strcat(uniqID1dot, nsnames1);
		else
			nsnames1 = {};
		end
		if feval(DAE.DAE2.nNoiseSources, DAE.DAE2) > 0
			nsnames2 = feval(DAE.DAE2.NoiseSourceNames, DAE.DAE2);
			nsnames2 = strcat(uniqID2dot, nsnames2);
		else
			nsnames2 = {};
		end
		DAE.mergedNoiseSourceNames = {nsnames1{:}, nsnames2{:}};
		DAE.DAE2noiseSrcIdxs = length(nsnames1) + (1:length(nsnames2));
	end

	DAE.unknameList = setup_unknames(DAE);
	DAE.eqnnameList = setup_eqnnames(DAE);
	DAE.parmnameList = setup_parmnames(DAE);
	%

% set up inputs

	% The input functions for various analyses are initially set to defaults that put
	% together inputs from DAE1 and DAE2
	%{
	DAE.uQSSvec = default_uQSS(DAE); % needed for QSS (DC analysis).
	DAE.utfunc = @default_utfunc; % needed for transient analysis.
	DAE.utargs = DAE; % 2nd arg of utfunc 
	DAE.Uffunc = @default_Uffunc; % needed for AC/SSS analysis. 
	DAE.Ufargs = DAE; % 2nd arg of Uffunc 
	%}
	DAE.uQSSvec_default = @default_uQSS; % needed for QSS (DC analysis).
	DAE.utfunc_default = @default_utfunc; % needed for transient analysis.
	DAE.Uffunc_default = @default_Uffunc; % needed for AC/SSS analysis. 
	% TODO: no HB support yet

% sizes: 
	DAE.nunks = @nunks;
	DAE.neqns = @neqns;
	DAE.ninputs = @ninputs;
	DAE.noutputs = @noutputs;
	%
% f, q: 
	DAE.f_takes_inputs = 1; % always so, regardless of whether DAE1 or DAE2's f take inputs
	DAE.f = @f;
	DAE.q = @q;
	%
% df, dq
	DAE.df_dx = @df_dx;
	DAE.df_du = @df_du;
	DAE.dq_dx = @dq_dx;
	%
% input-related functions
	%
	%DAE.B = @B;
	%
% output-related functions
	% what makes sense here for transient, LTISSS, etc.?
	DAE.C = @C;
	DAE.D = @D;
	%
% names
	DAE.uniqID   = @uniqID;
	DAE.daename   = @daename;
	DAE.unknames  = @unknames_DAEAPI;
	DAE.eqnnames  = @eqnnames_DAEAPI;
	DAE.inputnames  = @inputnames;
	DAE.outputnames  = @outputnames;
	DAE.renameUnks = @renameUnks_DAEAPI;
	DAE.renameEqns = @renameEqns_DAEAPI;
	DAE.renameParms = @renameParms_DAEAPI;
	%
% QSS initial guess support
	DAE.QSSinitGuess = @QSSinitGuess;
	%
% NR limiting support
	DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	DAE.nparms = @nparms;
	DAE.parmdefaults  = @parmdefaults;
	DAE.parmnames = @parmnames_DAEAPI;
	DAE.getparms  = @mergedCktgetparms;
	DAE.setparms  = @mergedCktsetparms;
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp;
	%DAE.dq_dp  = @dq_dp;
	%
% helper functions exposed by DAE
	DAE.internalfuncs = @internalfuncs;
	%
% functions for supporting noise
	% 
	DAE.nNoiseSources = @nNoiseSources;
	DAE.NoiseSourceNames = @NoiseSourceNames;
	DAE.NoiseStationaryComponentPSDmatrix = @NoiseStationaryComponentPSDmatrix;
	DAE.m = @m;
	DAE.dm_dx = @dm_dx;
	DAE.dm_dn = @dm_dn;
%
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = DAE.nunkstot;
% end nunks(...)

function out = neqns(DAE)
	out = DAE.neqnstot;
% end neqns(...)

function out = ninputs(DAE)
	out = feval(DAE.DAE1.ninputs, DAE.DAE1);
	if 1 == DAE.isDAE2
		out = out + feval(DAE.DAE2.ninputs, DAE.DAE2);
	end
% end ninputs(...)

function out = noutputs(DAE)
	out = feval(DAE.DAE1.noutputs, DAE.DAE1);
	if 1 == DAE.isDAE2
		out = out + feval(DAE.DAE2.noutputs, DAE.DAE2);
	end
% end noutputs(...)

function out = nparms(DAE)
	out = feval(DAE.DAE1.nparms, DAE.DAE1);
	if 1 == DAE.isDAE2
		out = out + feval(DAE.DAE2.nparms, DAE.DAE2);
	end
% end nparms(...)

function out = nNoiseSources(DAE)
	out = feval(DAE.DAE1.nNoiseSources, DAE.DAE1);
	if 1 == DAE.isDAE2
		out = out + feval(DAE.DAE2.nNoiseSources, DAE.DAE2);
	end
	%fprintf(2, 'nNoiseSources of DAE %s is %d\n', feval(DAE.uniqID,DAE), out);
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
% end uniqID

function out = daename(DAE)
	out = sprintf('%s (%s', DAE.uniqIDstr, ...
		feval(DAE.DAE1.uniqID,DAE.DAE1));
	if 1 == DAE.isDAE2
		out = sprintf('%s + %s)', out, ...
			feval(DAE.DAE2.uniqID,DAE.DAE2));
	else
		out = sprintf('%s)', out);
	end
% end daename()

% unknames is in unknames.m
function out = setup_unknames(DAE)
	out = DAE.mergedUnknames;
% end unknames()

% eqnnames is in eqnnames.m
function out = setup_eqnnames(DAE)
	out = DAE.mergedEqnnames;
% end eqnnames()

function out = inputnames(DAE)
	out = DAE.mergedInputnames;
% end inputnames()

function out = outputnames(DAE)
	out = DAE.mergedOutputnames;
% end outputnames()

% parmnames is in parmnames.m
function out = setup_parmnames(DAE)
	out = DAE.mergedParmnames;
% end parmnames()

function out = NoiseSourceNames(DAE)
	out = DAE.mergedNoiseSourceNames;
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = feval(DAE.DAE1.parmdefaults, DAE.DAE1);
	if 1 == DAE.isDAE2
		pvs2 = feval(DAE.DAE2.parmdefaults, DAE.DAE2);
		parmvals = {parmvals{:}, pvs2{:}};
	end
% end parmdefaults(...)

function parmvals = mergedCktgetparms(firstarg, secondarg)
% wrapper around the standard getparms for connectCktsAtNodes
% call as: parmvals = getparms(DAE)
%   - returns values of all defined parameters
% OR as parmval = getparms(parmname, DAE)
%         ^                   ^         
%       value               string
% OR as parmvals = getparms(parmnames, DAE)
%         ^                     ^ 
%    cell array            cell array
%
	if 2 == nargin
		DAE = secondarg;
		if (1 == isa(firstarg, 'cell'))
			% getparms(parmnames, DAE)
			parmnames = firstarg;
		else
			% getparms(parmname, DAE)
			parmnames{1} = firstarg;
		end

		parmnames1 = {}; pidxs1 = [];
		parmnames2 = {}; pidxs2 = [];
		for i = 1:length(parmnames)
			pname = parmnames{i};
			pidx = find(strcmp(pname,DAE.parmnameList));
			if length(pidx) ~= 1
				error(sprintf('parm name %s not found exactly once in DAE''s parameter names.', pname));
			end
			np1 = feval(DAE.DAE1.nparms, DAE.DAE1)
			if pidx <= np1
				pname = regexprep(pname, DAE.uniqID1dot, '');
				parmnames1 = {parmnames1{:}, pname};
				pidxs1 = [pidxs1, i];
			else
				pname = regexprep(pname, DAE.uniqID2dot, '');
				parmnames2 = {parmnames2{:}, pname};
				pidxs2 = [pidxs2, i-np1];
			end
		end
		pvals1 = feval(DAE.DAE1.getparms, parmnames1, DAE.DAE1);
		pvals2 = feval(DAE.DAE2.getparms, parmnames2, DAE.DAE2);
		if length(pidxs1) > 0
			parmvals(pidxs1) = pvals1;
		end
		if length(pidxs2) > 0
			parmvals(pidxs2) = pvals2;
		end
	elseif 1 == nargin
		DAE = firstarg;
		parmvals = feval(DAE.DAE1.getparms, DAE.DAE1);
		if 1 == DAE.isDAE2
			pvs2 = feval(DAE.DAE2.getparms, DAE.DAE2);
			parmvals = {parmvals{:}, pvs2{:}};
		end
	else
		error('mergedCktgetparms takes 1 or 2 arguments');
	end
% end of mergedCktgetparms

function outDAE = mergedCktsetparms(firstarg, secondarg, thirdarg)
% wrapper around the setparms.m for connectCktsAtNodes
% call as: outDAE = setparms(parms, DAE)
%                              ^     
%              cell array with values of all defined parameters
% OR as outDAE = setparms(parmname, newval, DAE)
%                            ^         ^
%                          string    value
% OR as outDAE = setparms(parmnames, newvals, DAE)
%                            ^         ^
%                            cell arrays
%
	if 3 == nargin
		DAE = thirdarg;
		if (1 == isa(firstarg, 'cell'))
			% setparms(parmnames, newvals, DAE)
			parmnames = firstarg;
			newvals = secondarg;
		else
			% setparms(parmname, newval, DAE)
			parmnames{1} = firstarg;
			newvals{1} = secondarg;
		end

		parmnames1 = {}; pidxs1 = [];
		parmnames2 = {}; pidxs2 = [];
		for i = 1:length(parmnames)
			pname = parmnames{i};
			pidx = find(strcmp(pname, DAE.parmnameList));
			if length(pidx) ~= 1
				error(sprintf('parameter %s not found exactly once in DAE''s parameter names.', pname));
			end
			np1 = feval(DAE.DAE1.nparms, DAE.DAE1);
			if pidx <= feval(DAE.DAE1.nparms, DAE.DAE1)
				pname = regexprep(pname, DAE.uniqID1dot, '');
				parmnames1 = {parmnames1{:}, pname};
				pidxs1 = [pidxs1, i];
			else
				pname = regexprep(pname, DAE.uniqID2dot, '');
				parmnames2 = {parmnames2{:}, pname};
				pidxs2 = [pidxs2, i-np1];
			end
		end

		if length(pidxs1) > 0
			newvals1 = {newvals{pidxs1}};
			DAE.DAE1 = feval(DAE.DAE1.setparms, parmnames1, newvals1, DAE.DAE1);
		end
		if length(pidxs2) > 0
			newvals2 = {newvals{pidxs2}};
			DAE.DAE2 = feval(DAE.DAE2.setparms, parmnames2, newvals2, DAE.DAE2);
		end
	elseif 2 == nargin
		DAE = secondarg;
		parmvals = firstarg;
		parmvals1 = {parmvals{DAE.DAE1parmIdxs}};
		DAE.DAE1 = feval(DAE.DAE1.setparms, parmvals1, DAE.DAE1);
		if 1 == DAE.isDAE2
			parmvals2 = {parmvals{DAE.DAE2parmIdxs}};
			DAE.DAE2 = feval(DAE.DAE2.setparms, parmvals2, DAE.DAE2);
		end
	else
		error('mergedCktsetparms takes 2 or 3 arguments');
	end
	outDAE = DAE;
% end mergedCktsetparms

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fout = f(x, u, DAE)

	x1 = x(DAE.DAE1unkIdxs,1);
	ninps1 = feval(DAE.DAE1.ninputs, DAE.DAE1);
	if ninps1 > 0
		u1 = u(DAE.DAE1inputIdxs,1);
	else
		u1 = [];
	end
	if 1 == DAE.DAE1.f_takes_inputs
		f1 = feval(DAE.DAE1.f, x1, u1, DAE.DAE1);
	else
		f1 = feval(DAE.DAE1.f, x1, DAE.DAE1);
		if ninps1 > 0
			f1 = f1 + feval(DAE.DAE1.B, DAE.DAE1)*u1;
		end
	end

	if 1 == DAE.isDAE2
		x2 = x(DAE.DAE2unkIdxs,1);
		ni2 = feval(DAE.DAE2.ninputs, DAE.DAE2);
		if ni2 > 0
			u2 = u(DAE.DAE2inputIdxs,1);
		else
			u2 = [];
		end
		if 1 == DAE.DAE2.f_takes_inputs
			f2 = feval(DAE.DAE2.f, x2, u2, DAE.DAE2);
		else
			f2 = feval(DAE.DAE2.f, x2, DAE.DAE2);
			if ni2 > 0
				f2 = f2 + feval(DAE.DAE2.B, DAE.DAE2)*u2;
			end
		end
	else
		1 == 1; %TODO
	end

	%fout = zeros(feval(DAE.neqns, DAE),1); messes up vecvalder
	%{
	fprintf('---------------------------------------------------------------------------\n');
	fprintf('f1: '); f1
	fprintf('DAE.mergedCommonEqnIdxs: '); DAE.mergedCommonEqnIdxs
	fprintf('f1(DAE.commonEqnIdxs1): '); f1(DAE.commonEqnIdxs1)
	%}

	fout(DAE.mergedCommonEqnIdxs,1) = f1(DAE.commonEqnIdxs1,1);
	%{
	fprintf('fout after fout(DAE.mergedCommonEqnIdxs) = f1(DAE.commonEqnIdxs1): '); fout

	fprintf('f1: '); f1
	fprintf('DAE.otherEqnIdxs1: '); DAE.otherEqnIdxs1
	fprintf('f1(DAE.otherEqnIdxs1): '); f1(DAE.otherEqnIdxs1)

	%fprintf('fout(DAE.mergedOtherEqnIdxs1): '); fout(DAE.mergedOtherEqnIdxs1)

	fprintf('DAE.mergedOtherEqnIdxs1: '); DAE.mergedOtherEqnIdxs1
	%}

	fout(DAE.mergedOtherEqnIdxs1,1) = f1(DAE.otherEqnIdxs1,1);
	%fprintf('fout after fout(DAE.mergedOtherEqnIdxs1) = f1(DAE.otherEqnIdxs1): '); fout

	if 1 == DAE.isDAE2
		%{
		fprintf('DAE.mergedCommonEqnIdxs: '); DAE.mergedCommonEqnIdxs
		fprintf('f2: '); f2
		fprintf('DAE.commonEqnIdxs2: '); DAE.commonEqnIdxs2
		%}
		fout(DAE.mergedCommonEqnIdxs,1) = fout(DAE.mergedCommonEqnIdxs,1) + f2(DAE.commonEqnIdxs2,1);
		fout(DAE.mergedOtherEqnIdxs2) = f2(DAE.otherEqnIdxs2);
	end
	%fprintf('---------------------------------------------------------------------------\n');
% end f(...)

function qout = q(x, DAE)
	x1 = x(DAE.DAE1unkIdxs);
	q1 = feval(DAE.DAE1.q, x1, DAE.DAE1);

	if 1 == DAE.isDAE2
		x2 = x(DAE.DAE2unkIdxs);
		q2 = feval(DAE.DAE2.q, x2, DAE.DAE2);
	else
		1 == 1; %TODO
	end

	qout(DAE.mergedCommonEqnIdxs,1) = q1(DAE.commonEqnIdxs1,1);
	qout(DAE.mergedOtherEqnIdxs1,1) = q1(DAE.otherEqnIdxs1,1);
	if 1 == DAE.isDAE2
		qout(DAE.mergedCommonEqnIdxs,1) = qout(DAE.mergedCommonEqnIdxs,1) + q2(DAE.commonEqnIdxs2,1);
		qout(DAE.mergedOtherEqnIdxs2,1) = q2(DAE.otherEqnIdxs2,1);
	end
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, u, DAE)

	x1 = x(DAE.DAE1unkIdxs);
	if 1 == DAE.DAE1.f_takes_inputs
		u1 = u(DAE.DAE1inputIdxs);
		Jf1 = feval(DAE.DAE1.df_dx, x1, u1, DAE.DAE1);
	else
		Jf1 = feval(DAE.DAE1.df_dx, x1, DAE.DAE1);
	end

	neqns = feval(DAE.neqns, DAE);
	nunks = feval(DAE.nunks, DAE);
	Jf = sparse(neqns, nunks);

	Jf(DAE.DAE1eqnIdxs, DAE.DAE1unkIdxs) = Jf1;

	if 1 == DAE.isDAE2
		x2 = x(DAE.DAE2unkIdxs);
		if 1 == DAE.DAE2.f_takes_inputs
			u2 = u(DAE.DAE2inputIdxs);
			Jf2 = feval(DAE.DAE2.df_dx, x2, u2, DAE.DAE2);
		else
			Jf2 = feval(DAE.DAE2.df_dx, x2, DAE.DAE2);
		end

		Jf(DAE.DAE2eqnIdxs, DAE.DAE2unkIdxs) = Jf(DAE.DAE2eqnIdxs, DAE.DAE2unkIdxs) + Jf2; 
	else
		1 == 1; %TODO
	end
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	x1 = x(DAE.DAE1unkIdxs);
	Jq1 = feval(DAE.DAE1.dq_dx, x1, DAE.DAE1);

	neqns = feval(DAE.neqns, DAE);
	nunks = feval(DAE.nunks, DAE);
	Jq = sparse(neqns, nunks);

	Jq(DAE.DAE1eqnIdxs, DAE.DAE1unkIdxs) = Jq1;

	if 1 == DAE.isDAE2
		x2 = x(DAE.DAE2unkIdxs);
		Jq2 = feval(DAE.DAE2.dq_dx, x2, DAE.DAE2);
		Jq(DAE.DAE2eqnIdxs,DAE.DAE2unkIdxs) = Jq(DAE.DAE2eqnIdxs,DAE.DAE2unkIdxs) + Jq2; 
	else
		1 == 1; %TODO
	end
% end dq_dx(...)

function B = df_du(x, u, DAE)
	x1 = x(DAE.DAE1unkIdxs);
	if 1 == DAE.DAE1.f_takes_inputs
		u1 = u(DAE.DAE1inputIdxs);
		B1 = feval(DAE.DAE1.df_du, x1, u1, DAE.DAE1);
	else
		B1 = feval(DAE.DAE1.B, DAE.DAE1);
	end

	neqns = feval(DAE.neqns, DAE);
	ninps = feval(DAE.ninputs, DAE);
	B = sparse(neqns, ninps);

	if feval(DAE.DAE1.ninputs, DAE.DAE1) > 0
		B(DAE.DAE1eqnIdxs, DAE.DAE1inputIdxs) = B1;
	end

	if 1 == DAE.isDAE2
		x2 = x(DAE.DAE2unkIdxs);
		if 1 == DAE.DAE2.f_takes_inputs
			u2 = u(DAE.DAE2inputIdxs);
			B2 = feval(DAE.DAE2.df_du, x2, u2, DAE.DAE2);
		else
			B2 = feval(DAE.DAE2.B, DAE.DAE2);
		end

		if feval(DAE.DAE2.ninputs, DAE.DAE2) > 0
			B(DAE.DAE2eqnIdxs, DAE.DAE2inputIdxs) = B(DAE.DAE2eqnIdxs, DAE.DAE2inputIdxs) + B2; 
		end
	else
		1 == 1; %TODO
	end
% end df_du(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% see below (other local functions section) for default_{uQSS,utfunc,Uffunc}, used
% in the constructor.

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)

	nunks = feval(DAE.nunks, DAE);
	nouts = feval(DAE.noutputs, DAE);
	%ninps = feval(DAE.ninputs, DAE);

	if 0 == nouts 
		out = [];
		return
	end

	out = sparse(nouts, nunks);

	if feval(DAE.DAE1.noutputs, DAE.DAE1) > 0
		C1 = feval(DAE.DAE1.C, DAE.DAE1);
		out(DAE.DAE1outputIdxs, DAE.DAE1unkIdxs) = C1;
	end

	if 1 == DAE.isDAE2
		if feval(DAE.DAE2.noutputs, DAE.DAE2) > 0
			C2 = feval(DAE.DAE2.C, DAE.DAE2);
			out(DAE.DAE2outputIdxs, DAE.DAE2unkIdxs) = out(DAE.DAE2outputIdxs, DAE.DAE2unkIdxs) + C2; 
		end
	else
		1 == 1; %TODO
	end
% end C(...)

function out = D(DAE)
	nouts = feval(DAE.noutputs, DAE);
	ninps = feval(DAE.ninputs, DAE);

	if 0 == nouts || 0 == ninps
		out = [];
		return
	end

	out = sparse(nouts, ninps);
	if feval(DAE.DAE1.ninputs, DAE.DAE1) > 0  && feval(DAE.DAE1.noutputs, DAE.DAE1) > 0
		D1 = feval(DAE.DAE1.D, DAE.DAE1);
		out(DAE.DAE1outputIdxs, DAE.DAE1inputIdxs) = D1;
	end

	if 1 == DAE.isDAE2
		if feval(DAE.DAE2.ninputs, DAE.DAE2) > 0 && feval(DAE.DAE2.noutputs, DAE.DAE2) > 0
			D2 = feval(DAE.DAE2.D, DAE.DAE2);
			out(DAE.DAE2outputIdxs, DAE.DAE2inputIdxs) = out(DAE.DAE2outputIdxs, DAE.DAE2inputIdxs) + D2; 
		end
	else
		1 == 1; %TODO
	end
% end D(...)

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% not supported yet

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	u1 = u(DAE.DAE1inputIdxs);
	guess1 = feval(DAE.DAE1.QSSinitGuess, u1, DAE.DAE1);

	guess1Commons = guess1(DAE.commonUnkIdxs1);
	guess1Others = guess1(DAE.otherUnkIdxs1);
	out(DAE.DAE1unkIdxs,1) = guess1; % this sets all entries for DAE1

	if 1 == DAE.isDAE2
		u2 = u(DAE.DAE2inputIdxs);
		guess2 = feval(DAE.DAE2.QSSinitGuess, u2, DAE.DAE2);
		guess2Commons = guess2(DAE.commonUnkIdxs2);
		guess2Others = guess2(DAE.otherUnkIdxs2);
		out(DAE.mergedOtherUnkIdxs2,1) = guess2Others; % sets entries exclusive to DAE2
		% averaging the initGuesses for the common nodes - a hack, of course, but can't think of anything better
		out(DAE.mergedCommonUnkIdxs,1) = 0.5*(guess2Commons+guess1Commons);
	else
		1 == 1; %TODO
	end
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE)
	% FIXME: this hardcodes an minimum based limiting heuristic
	dx1 = dx(DAE.DAE1unkIdxs);
	xold1 = xold(DAE.DAE1unkIdxs);
	u1 = u(DAE.DAE1inputIdxs);

	newdx1 = feval(DAE.DAE1.NRlimiting, dx1, xold1, u1, DAE.DAE1);

	newdx1Commons = newdx1(DAE.commonUnkIdxs1);

	newdx(DAE.DAE1unkIdxs,1) = newdx1;


	if 1 == DAE.isDAE2
		dx2 = dx(DAE.DAE2unkIdxs);
		xold2 = xold(DAE.DAE2unkIdxs);
		u2 = u(DAE.DAE2inputIdxs);

		newdx2 = feval(DAE.DAE2.NRlimiting, dx2, xold2, u2, DAE.DAE2);

		newdx2Others = newdx2(DAE.otherUnkIdxs2);
		newdx(DAE.mergedOtherUnkIdxs2,1) = newdx2Others;

		newdx2Commons = newdx2(DAE.commonUnkIdxs2);
		for i = 1:length(newdx2Commons)
			dx1 = newdx1Commons(i);
			dx2 = newdx2Commons(i);

			if sign(dx2) == sign(dx1) % same sign, take the smaller one
				dx = sign(dx1)*min(abs(dx2),abs(dx1));
			else % opposite signs - average the two
				dx = 0.5*(dx2+dx1);
			end
			newdx(DAE.mergedCommonUnkIdxs(i),1) = dx;
		end
	else
		1 == 1; %TODO
	end
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	% NOTE: these should be one-sided PSDs

	nns = feval(DAE.nNoiseSources, DAE);

	out = sparse(nns, nns);
	nn1 = feval(DAE.DAE1.nNoiseSources, DAE.DAE1);

	PSDmat1 = feval(DAE.DAE1.NoiseStationaryComponentPSDmatrix, DAE.DAE1); 
	out(1:nn1, 1:nn1) = PSDmat1;

	if 1 == DAE.isDAE2
		PSDmat2 = feval(DAE.DAE2.NoiseStationaryComponentPSDmatrix, DAE.DAE2);
		out((nn1+1):nns, (nn1+1):nns) = PSDmat2;
	else
		1 == 1; %TODO
	end
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
	% NOTE: m should be for one-sided PSDs
	% M is of size neqns. n is of size nNoiseSources

	neqns = feval(DAE.neqns, DAE);

	nns1 = feval(DAE.DAE1.nNoiseSources, DAE.DAE1);
	nns2 = feval(DAE.DAE2.nNoiseSources, DAE.DAE2);
	nns = feval(DAE.nNoiseSources, DAE);

	x1 = x(DAE.DAE1unkIdxs,1);
	if nns1 > 0
		n1 = n(DAE.DAE1noiseSrcIdxs,1);
	else
		n1 = [];
	end
	m1 = feval(DAE.DAE1.m, x1, n1, DAE.DAE1);

	if 1 == DAE.isDAE2 
		x2 = x(DAE.DAE2unkIdxs);
		if nns2 > 0
			n2 = n(DAE.DAE2noiseSrcIdxs,1);
		else
			n2 = [];
		end
		m2 = feval(DAE.DAE2.m, x2, n2, DAE.DAE2);
	end

	out(DAE.mergedCommonEqnIdxs,1) = m1(DAE.commonEqnIdxs1,1);
	out(DAE.mergedOtherEqnIdxs1,1) = m1(DAE.otherEqnIdxs1,1);

	if 1 == DAE.isDAE2
		out(DAE.mergedCommonEqnIdxs,1) = out(DAE.mergedCommonEqnIdxs,1) + m2(DAE.commonEqnIdxs2,1);
		out(DAE.mergedOtherEqnIdxs2,1) = m2(DAE.otherEqnIdxs2,1);
	end

	if length(out) ~= neqns
		error(sprintf('connectCktsAtNodes.m(): length of out != neqns for DAE with uniqID %s\n', feval(DAE.uniqID, DAE)));
	end
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
	neqns = feval(DAE.neqns, DAE);
	nunks = feval(DAE.nunks, DAE);
	Jm = sparse(neqns, nunks);

	if feval(DAE.DAE1.nNoiseSources, DAE.DAE1) > 0
		x1 = x(DAE.DAE1unkIdxs);
		n1 = n(DAE.DAE1noiseSrcIdxs);
		Jm1 = feval(DAE.DAE1.dm_dx, x1, n1, DAE.DAE1);

		Jm(DAE.DAE1eqnIdxs, DAE.DAE1unkIdxs) = Jm1;
	end

	if 1 == DAE.isDAE2 && feval(DAE.DAE2.nNoiseSources, DAE.DAE2) > 0
		x2 = x(DAE.DAE2unkIdxs);
		n2 = n(DAE.DAE2noiseSrcIdxs);
		Jm2 = feval(DAE.DAE2.dm_dx, x2, n2, DAE.DAE2);

		Jm(DAE.DAE2eqnIdxs, DAE.DAE2unkIdxs) = Jm(DAE.DAE2eqnIdxs, DAE.DAE2unkIdxs) + Jm2; 
	end
	% 1 == 1; %TODO
% end dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
	% M is of size neqns. n is of size nNoiseSources
	% NOTE: M should be for one-sided PSDs

	nns = feval(DAE.nNoiseSources, DAE);

	if 0 == nns
		M = [];
		return;
	end

	neqns = feval(DAE.neqns, DAE);
	M = sparse(neqns, nns);

	if feval(DAE.DAE1.nNoiseSources, DAE.DAE1) > 0
		x1 = x(DAE.DAE1unkIdxs);
		n1 = n(DAE.DAE1noiseSrcIdxs);
		M1 = feval(DAE.DAE1.dm_dn, x1, n1, DAE.DAE1);
		M(DAE.DAE1eqnIdxs, DAE.DAE1noiseSrcIdxs) = M1;
	end

	if 1 == DAE.isDAE2 && feval(DAE.DAE2.nNoiseSources, DAE.DAE2) > 0
		x2 = x(DAE.DAE2unkIdxs);
		n2 = n(DAE.DAE2inputIdxs);
		M2 = feval(DAE.DAE2.dm_dn, x2, n2, DAE.DAE2);

		M(DAE.DAE2eqnIdxs, DAE.DAE2noiseSrcIdxs) = M(DAE.DAE2eqnIdxs, DAE.DAE2noiseSrcIdxs) + M2; 
	end
		% 1 == 1; %TODO
% end dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
	ifs = 'No internal functions exposed by this DAE system.';
	%ifs.stoichmatfunc = @stoichmatfunc;
	%ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
% end internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = default_uQSS(DAE)
% this is called once during setup by the constructor, to set up uQSSvec.
% after that, uQSSvec can be changed in the usual way by set_uQSS
	ninputs1 = feval(DAE.DAE1.ninputs, DAE.DAE1);
	out = [];
	if ninputs1 > 0
		oof = feval(DAE.DAE1.uQSS, DAE.DAE1); 
		if ischar(oof) || isempty(oof) % eg, 'undefined' - this should not happen
			out = 'undefined';
			fprintf(2,'connectCktsAtNodes::default_uQSS: DAE1 uQSS provides invalid value\n');
			return;
		else
			out(DAE.DAE1inputIdxs,1) = oof;
		end
	end % ninputs1

	if 1 == DAE.isDAE2 && feval(DAE.DAE2.ninputs, DAE.DAE2) > 0
		oof = feval(DAE.DAE2.uQSS, DAE.DAE2);
		if ischar(oof) || isempty(oof) % eg, 'undefined'
			out = 'undefined';
			fprintf(2,'connectCktsAtNodes::default_uQSS: DAE2 uQSS provides invalid value\n');
			return;
		else
			% DAE1inputIdxs and DAE2inputIdxs should be disjoint
			out(DAE.DAE2inputIdxs,1) = oof;
		end
	else
		1 == 1; %TODO.
	end
% end uQSS

function out = default_utfunc(t, DAE)
% utfunc is set to this by the constructor during setup. After that, utfunc it can
% be updated by set_utransient in the normal way.
	out1 = feval(DAE.DAE1.utransient, t, DAE.DAE1);
	if ~isa(out1,'numeric') || isempty(out1)
		out = out1;
		return;
	else
		out(DAE.DAE1inputIdxs) = out1;
	end

	if 1 == DAE.isDAE2
		out2 = feval(DAE.DAE2.utransient, t, DAE.DAE2);
		if ~isa(out2,'numeric') || isempty(out2)
			out = out2;
			return;
		else
			out(DAE.DAE2inputIdxs) = out(DAE.DAE2inputIdxs) + out2;
		end
	else
		1 == 1; %TODO.
	end
% end default_utfunc

function out = default_Uffunc(f, DAE)
% Uffunc is set to this by the constructor during setup. After that, it can
% be updated by set_uLTISSS in the normal way.
	out(DAE.DAE1inputIdxs) = feval(DAE.DAE1.uLTISSS, f, DAE.DAE1);

	if 1 == DAE.isDAE2
		out(DAE.DAE2inputIdxs) = out(DAE.DAE2inputIdxs) + feval(DAE.DAE2.uLTISSS, f, DAE.DAE2);
	else
		1 == 1; %TODO.
	end
% end default_Uffunc
