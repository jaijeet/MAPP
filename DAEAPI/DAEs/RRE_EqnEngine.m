function DAE = RRE_EqnEngine(uniqIDstr, reactionsystem)
%function DAE = RRE_EqnEngine(uniqIDstr, reactionsystem)
% Reaction rate equation engine
%author: J. Roychowdhury, 2011/05/21
%
% reactionsystem is a structure containing the fields:
% reactionsystem.name: string. Example: 'DS''s ABC oscillator';
% reactionsystem.reactants: cell array of reactant names.
%	Example: {'A', 'B', 'C', 'X'}
% reactionsystem.input_reactants: cell array of reactant names
%		to be treated as inputs (ie, their concentrations
%		are provided a-priori as time-varying functions to
%		the simulation; no differential equations are added
%		to the RRE system for them).
%		These must be a subset of reactionsystem.reactants.
%	Example: {'X'};
% reactionsystem.reactions: cell array of reaction structures R_i.
%	Example: {R1, R2, R3}
%	- each reaction structure R should contain the following fields:
%	  - R.kF: forward rate
%	  - R.kR: reverse rate
%	  - R.LHSstoichiometries: row of +ve integers representing LHS stoichiometries
%	  - R.RHSstoichiometries: row of +ve integers representing RHS stoichiometries
%	- Example: for the reaction A + B -> 2B (with reactants as above):
%	  - R.kF = 1, R.kR = 0
%	  - R.LHSstoichiometries = [1 1 0 1]
%	  - R.RHSstoichiometries = [0 2 0 0]
% reactionsystem.reactionlabels: cell array of reaction names.
%	- Example: {'R1', 'R2', 'R3'}
%	
%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%

% pull in virtual base class:
	DAE = DAEAPI_common_skeleton();
% version, help string: 
	DAE.version = 'DAEAPI v6.2+';
	DAE.Usage = help('RRE_EqnEngine');
	if nargin < 2
		DAE.uniqIDstr = '';
		reactionsystem = uniqIDstr;
	else
		DAE.uniqIDstr = uniqIDstr;
	end
	%
%data: store problem parameters, assign inputs, precompute stuff

	% store reactionsystem
	DAE.reactionsystem = reactionsystem;

	% remove input_reactants from reactants to produce list of unknowns
	indices = ones(length(reactionsystem.reactants),1);
	input_idx = 0;
	DAE.input_indices_in_reactants = [];
	for inp = reactionsystem.input_reactants
		input_idx = input_idx + 1;
	        idx_in_reactants = find(strcmp(inp, reactionsystem.reactants));
	        if length(idx_in_reactants) ~= 1
	                fprintf(2,'input_reactant %s not found exactly once in reactants\n', inp);
	                return;
	        end
	        indices(idx_in_reactants) = 0;
		DAE.input_indices_in_reactants(input_idx) = idx_in_reactants; % inputnames = reactants(input_indices_in_reactants)
									      % 	   == input_reactants
	end
	unkname_indices =find(indices ~= 0); 
	DAE.unkname_indices_in_reactants = unkname_indices; % unknames = reactants(unkname_indices_in_reactants)
	DAE.unknameList = {reactionsystem.reactants{unkname_indices}};
	
	% set up name and parameter lists
	DAE.unknameList = strcat('[', DAE.unknameList, ']');
	DAE.eqnnameList = strcat('d/dt', DAE.unknameList);
	if length(reactionsystem.input_reactants) > 0
		DAE.inputnameList = strcat('[', reactionsystem.input_reactants, ']');
	else
		DAE.inputnameList = {};
	end
	DAE.parmnameList =  setup_parmnames(reactionsystem);
	DAE.parm_defaults = setup_parmdefaults(reactionsystem);

	% set up DAE.stoichiometry_matrix
	for i=1:length(reactionsystem.reactions)
		% we treat LHS stoichiometries as negative by convention
		% drop the input_reactants, keeping only the reactant unknowns
		LHSstoich = DAE.reactionsystem.reactions{i}.LHSstoichiometries(unkname_indices);
		RHSstoich = DAE.reactionsystem.reactions{i}.RHSstoichiometries(unkname_indices);
	
		DAE.stoichiometry_matrix(i,:) = RHSstoich - LHSstoich;
	end

	% transpose it: now each row corresponds to a reactant, each col
	% to a reaction; hence 
	% d/dt (all reactants) = stoichiometry_matrix * rate_vector;
	DAE.stoichiometry_matrix = DAE.stoichiometry_matrix.';

	% data: current values of parameters, can be changed by setparms
	DAE.parms = parmdefaults(DAE); % parmdefaults just returns parm_defaults
	%
	DAE.uQSSvec = 'unassigned'; % should become a real scalar/vector
	DAE.utfunc = 'unassigned'; % should become a function call
	DAE.utargs = 'unassigned'; % should become a structure
	DAE.Uffunc = 'unassigned'; % should become a function call
	DAE.Ufargs = 'unassigned'; % should become a structure
	%
	%
% sizes: 
	DAE.nunks = @nunks;
	DAE.neqns = @neqns;
	DAE.ninputs = @ninputs;
	DAE.noutputs = @noutputs;
	%
% f, q: 
	DAE.f_takes_inputs = 1;
	DAE.f = @f;
	DAE.q = @q;
	%
% df, dq
	DAE.df_dx = @df_dx;
	DAE.dq_dx = @dq_dx;
	DAE.df_du = @df_du;
	%
% input-related functions
	%
	DAE.B = @B;
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
	DAE.getparms  = @default_getparms_DAE;
	DAE.setparms  = @default_setparms_DAE;
	% first derivatives with respect to parameters - for sensitivities
	%DAE.df_dp  = @df_dp; % not implemented yet
	%DAE.dq_dp  = @dq_dp; % not implemented yet
	%
% helper functions exposed by DAE
	DAE.internalfuncs = @internalfuncs;
	%
% functions for supporting noise
	% 
	DAE.nNoiseSources = @nNoiseSources;
	DAE.NoiseSourceNames = @NoiseSourceNames;
	DAE.NoiseStationaryComponentPSDmatrix = 'undefined';% @NoiseStationaryComponentPSDmatrix;
	DAE.m = 'undefined'; %@m;
	DAE.dm_dx = 'undefined'; %@dm_dx;
	DAE.dm_dn = 'undefined'; %@dm_dn;
%
end
% end DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
	out = length(DAE.eqnnameList); % one d/dt equation for each
end
% end nunks(...)

function out = neqns(DAE)
	out = nunks(DAE);
end
% end neqns(...)

function out = ninputs(DAE)
	out = length(DAE.inputnameList); 
end
% end ninputs(...)

function out = noutputs(DAE)
	out = nunks(DAE); % all 
end
% end noutputs(...)

function out = nparms(DAE)
	out = length(DAE.parmnameList);
end
% end nparms(...)

function out = nNoiseSources(DAE)
	out = 0; % no noise support yet
end
% end nNoiseSources(...)

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
	out = DAE.uniqIDstr;
end
% end daename()

function out = daename(DAE)
	out = ['RRE for ', DAE.reactionsystem.name];
end
% end daename()

% unknames is in unknames.m

% eqnnames is in eqnnames.m

function out = inputnames(DAE)
	out = DAE.inputnameList;
end
% end inputnames()

function out = outputnames(DAE)
	out = unknames_DAEAPI(DAE);
end
% end outputnames()

% parmnames is in parmnames.m

function out = NoiseSourceNames(DAE)
	out = {};
end
% end NoiseSourceNames()

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m


%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
	parmvals = DAE.parm_defaults;
end
% end parmdefaults(...)

% getparms is in getparms.m
% setparms is in setparms.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = f(x, u, DAE)
	
	all_reactant_concs(DAE.unkname_indices_in_reactants,1) = x;
	if ~isempty(DAE.input_indices_in_reactants)
		all_reactant_concs(DAE.input_indices_in_reactants,1) = u;
	end

	ratevec = forwardratefunc(all_reactant_concs, DAE);
	stoichmat = stoichmatfunc(DAE);

	out = stoichmat*ratevec;
end
% end f(...)

function out = q(x, DAE)
	out = -x;
end
% end q(...)

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Jf = df_dx(x, u, DAE)

	all_reactant_concs(DAE.unkname_indices_in_reactants,1) = x;
	all_reactant_concs(DAE.input_indices_in_reactants,1) = u;

	use_finite_diffs = 0;

	if 1 == use_finite_diffs
		n = nunks(DAE);
		delta = 1e-5;
		deltaxs = ones(n,1)*delta;

		fxnom = f(x, DAE); % fxnom is a column vec
		for i=1:n
			xp = x; xp(i) = xp(i) + deltaxs(i); % perturb ith comp.
			fx = f(xp, DAE); % fx is col
			Jf(:,i) = (fx-fxnom)/deltaxs(i);
		end
	else % 0==use_finite_diffs
		dR = dforwardratefunc(all_reactant_concs, DAE);

		% drop derivatives wrt inputs
		dR = dR(:,DAE.unkname_indices_in_reactants);

		stoichmat = stoichmatfunc(DAE);
		Jf = stoichmat*dR;
	end
end
% end df_dx(...)

function Jfu = df_du(x, u, DAE)
	all_reactant_concs(DAE.unkname_indices_in_reactants,1) = x;
	all_reactant_concs(DAE.input_indices_in_reactants,1) = u;

	use_finite_diffs = 0;

	dR = dforwardratefunc(all_reactant_concs, DAE);

	% drop derivatives wrt inputs
	dR = dR(:,DAE.input_indices_in_reactants);

	stoichmat = stoichmatfunc(DAE);
	Jfu = stoichmat*dR;
end
% end df_dx(...)

function Jq = dq_dx(x, DAE)
	n = nunks(DAE);
	Jq = -eye(n);
end
% end dq_dx(...)

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
	out = []; % not used when f_takes_inputs == 1
end
% end B(...)

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
	n = nunks(DAE);
	out = speye(n,n);
end
% end C(...)

function out = D(DAE)
%function out = D(x, DAE)
	out = sparse(nunks(DAE),ninputs(DAE));
end
% end D(...)


%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE)
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = zeros(nunks(DAE),1); % not really relevant
end
%end QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE)
	newdx = dx; % no limiting
end
% end NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE)
	% in the same order as for NoiseSourceNames
	% returns a square PSD matrix of size nNoiseSources
	out = [];
	% unit PSDs; all the action is moved to m(x,n)
end
%end NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
	% M is of size neqns. n is of size nNoiseSources
	%
	out = [];
end
% end m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
	Jm = [];
end
% end dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
	M = [];
end
% end dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
	ifs.show_reactions = @show_reactions;
	ifs.show_reactions_Usage = 'feval(DAE.internalfuncs.show_reactions, DAE)';
	ifs.stoichmatfunc = @stoichmatfunc;
	ifs.stoichmatfunc_Usage = 'feval(DAE.internalfuncs.stoichmatfunc, DAE)';
	ifs.forwardratefunc = @forwardratefunc;
	ifs.forwardratefuncUsage = 'feval(forwardratefunc, x, DAE)';
	ifs.dforwardratefunc = @dforwardratefunc;
	ifs.dforwardratefuncUsage = 'feval(dforwardratefunc, x, DAE)';
end
% end internalfuncs

function stoichmat = stoichmatfunc(DAE)
	stoichmat = DAE.stoichiometry_matrix;
end
% end stoichmatfunc

function forwardrates = forwardratefunc(all_reactant_concs, DAE)
	for i=1:length(DAE.reactionsystem.reactions)
		reaction = DAE.reactionsystem.reactions{i};

		frate = DAE.parms{2*i-1}; % reaction.kF;
		for j=find(reaction.LHSstoichiometries ~= 0) % TODO: check that this is nonempty
			s_j = reaction.LHSstoichiometries(j);
			frate = frate*all_reactant_concs(j,1)^s_j;
		end

		rrate = DAE.parms{2*i}; % reaction.kR;
		for j=find(reaction.RHSstoichiometries ~= 0) % TODO: check that this is nonempty
			s_j = reaction.RHSstoichiometries(j);
			rrate = rrate*all_reactant_concs(j,1)^s_j;
		end
		forwardrates(i,1) = frate - rrate;
	end
end
% end forwardratesfunc

function dR = dforwardratefunc(all_reactant_concs, DAE)
	for i=1:length(DAE.reactionsystem.reactions)
		reaction = DAE.reactionsystem.reactions{i};

		frate = DAE.parms{2*i-1}; % reaction.kF;
		dfrate_dxu = zeros(1,length(all_reactant_concs));
		for j=find(reaction.LHSstoichiometries ~= 0) % TODO: check that this is nonempty
			s_j = reaction.LHSstoichiometries(j);
			%frate = frate*x(j,1)^s_j;
			%
			%dfrate_dxk = dfrate_dxk*x(j,1)^s_j + (k==j)*frate*s^j*x(j,1)^(s_j-1);
			% 		                              ^ old value
			dfrate_dxu(1,:)= dfrate_dxu(1,:).*all_reactant_concs(j,1)^s_j;
			dfrate_dxu(1,j) = dfrate_dxu(1,j) + frate*s_j*all_reactant_concs(j,1)^(s_j-1);
			frate = frate*all_reactant_concs(j,1)^s_j; % update for use in the next iteration
		end

		rrate = DAE.parms{2*i}; % reaction.kR;
		drrate_dxu = zeros(1,length(all_reactant_concs));
		for j=find(reaction.RHSstoichiometries ~= 0) % TODO: check that this is nonempty
			s_j = reaction.RHSstoichiometries(j);
			drrate_dxu(1,:)= drrate_dxu(1,:).*all_reactant_concs(j,1)^s_j;
			drrate_dxu(1,j) = drrate_dxu(1,j) + rrate*s_j*all_reactant_concs(j,1)^(s_j-1);
			rrate = rrate*all_reactant_concs(j,1)^s_j;
		end

		dR(i,:) = dfrate_dxu - drrate_dxu;
	end
end
% end dforwardratefunc
%%%%%%%%%%%%%%%% END INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
function rnames = show_reactions(DAE)
	reactants = DAE.reactionsystem.reactants;
	reactions = DAE.reactionsystem.reactions;
	rlabels = DAE.reactionsystem.reactionlabels;

	if length(rlabels) ~= length(reactions)
		fprintf(2,'error: lengths of reactions and reactionlabels are different\n');
		return;
	end

	for i = 1:length(rlabels)
		reaction = reactions{i};
		label = rlabels{i};

		% build LHS expression
		LHSexpr = '';
		for j = find(reaction.LHSstoichiometries ~= 0)
			s = reaction.LHSstoichiometries(j);
			reactantname = reactants{j};
			if length(LHSexpr) > 0
				%LHSexpr = strcat(LHSexpr, ' + '); strcat deblanks the expression
				LHSexpr = [LHSexpr, ' + '];
			end
			if 1 == s
				ss = '';
			else
				ss = num2str(s);
			end
			LHSexpr = [LHSexpr, ss, reactantname];
		end

		% build RHS expression
		RHSexpr = '';
		for j = find(reaction.RHSstoichiometries ~= 0)
			s = reaction.RHSstoichiometries(j);
			reactantname = reactants{j};
			if length(RHSexpr) > 0
				RHSexpr = [RHSexpr, ' + '];
			end
			if 1 == s
				ss = '';
			else
				ss = num2str(s);
			end
			RHSexpr = [RHSexpr, ss, reactantname];
		end

		% build the arrow sign and the kF/kR labels
		arrowsign = '';
		k2label = ''; % reverse direction coeff
		k1label = ''; % forward direction coeff
		kF = DAE.parms{2*i-1};
		kR = DAE.parms{2*i};
		if reaction.kR > 0
			arrowsign = [arrowsign, '<'];
			k2label = blanks(length(LHSexpr)+length(label)+3);
			k2label = [k2label, 'kR=', num2str(reaction.kR,'%g')];
		end
		arrowsign = [arrowsign, '--'];
		if reaction.kF > 0
			arrowsign = [arrowsign, '>'];
			k1label = blanks(length(LHSexpr)+length(label)+3);
			k1label = [k1label, 'kF=', num2str(reaction.kF,'%g')];
		end

		% put together rnames{i}
		thename = '';
		if reaction.kF > 0
			thename = [k1label, '\n'];
		end
		thename = [thename, label, ': ', LHSexpr, ' ', arrowsign, ' ', RHSexpr, '\n'];
		if reaction.kR > 0
			thename = strcat(thename, k2label, '\n');
		end

		rnames{i} = thename;
	end
end

function pnames = setup_parmnames(reactionsystem)
	reactions = reactionsystem.reactions;
	rlabels = reactionsystem.reactionlabels;

	j = 0;
	for i = 1:length(reactions)
		reaction = reactions{i};
		label = rlabels{i};
		j = j+1;
		pnames{j} = strcat(label, '.kF');
		j = j+1;
		pnames{j} = strcat(label, '.kR');
	end
end

function parmdflts = setup_parmdefaults(reactionsystem)
	reactions = reactionsystem.reactions;

	j = 0;
	for i = 1:length(reactions)
		reaction = reactions{i};
		j = j+1;
		parmdflts{j} = reaction.kF;
		j = j+1;
		parmdflts{j} = reaction.kR;
	end
end

%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
