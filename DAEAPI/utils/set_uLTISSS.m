function outDAE = set_uLTISSS(firstarg, secondarg, thirdarg, fourtharg)
%function outDAE = set_uLTISSS(Uffunc, Ufargs, DAE);
%	 			       ^
%                          func (handle) returning all ckt inputs as a vector
% 	or
%function outDAE = set_uLTISSS(inputname, 	Uffunc, 	Ufargs, DAE);
%				        ^          ^
%			             string     func returning
%	                                        scalar output
%	or
%
%Sets LTISSS/AC analysis inputs to a DAE.
%
%Uffunc should be a function handle callable as (f represents frequency):
%	feval(Uffunc, f, Ufargs)
%returning a complex column vector of size feval(DAE.ninputs, DAE) in the
%first form above, or a complex scalar in the second form. Ufargs can be 
%anything usable by Uffunc as its second argument.
%
%Examples
%--------
%
% nsegs = 5; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
%
% % set AC analysis input as a function of frequency
% Ufargs.string = 'no args used';; % 
% Uffunc = @(f, args) ones(size(f)); % constant U(j 2 pi f) \equiv 1
% % first form above
% DAE = feval(DAE.set_uLTISSS, Uffunc, Ufargs, DAE);
% % second form above
% feval(DAE.inputnames, DAE)
% DAE = feval(DAE.set_uLTISSS, 'line driving voltage: E(t)', Uffunc, ...
%								Ufargs, DAE);
%
%See also
%--------
%
% uLTISSS, ac, LTISSS.
%
%Notes:
%
%1. The first form above sets DAE.vector_Uffunc and resets DAE.Uffunc_updates
%   to empty.
%
%2. The second form above (scalar Uffuncs) updates DAE.Uffunc_updates with
%   data for overriding parts of the ckt u vector. As noted above, whenever a
%   vector Uffunc is set for the entire circuit, all scalar Uffuncs that may
%   have been set before are deleted.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	if (nargin < 3) || (nargin > 4)
	   fprintf(2,'set_uLTISSS requires 3 or 4 arguments\n');
	   return;
	end

	if 3 == nargin
		% set_uLTISSS(Uffunc, Ufargs, DAE)
		DAE = thirdarg;
		Uffunc = firstarg;
		Ufargs = secondarg;
		DAE.Uffunc_updates.vector_Uffunc = Uffunc;
		DAE.Uffunc_updates.vector_Uffunc_args = Ufargs;
		DAE.Uffunc_updates.indices = []; % wipe out any previous scalar Uffuncs
		DAE.Uffunc_updates.Uffunclist = {}; % wipe out any previous scalar Uffuncs
		DAE.Uffunc_updates.Ufargslist = {}; % wipe out any previous scalar Uffuncs
		outDAE = DAE;
		return;
	end % 3 == nargin
	% below: 4 == nargin

	DAE = fourtharg;
	if (1 == isa(firstarg, 'cell'))
		fprintf(2, 'set_uLTISSS supports setting only 1 input at a time\n')
		return;
	else
		% set_uLTISSS(inputname, Uffunc, Ufargs, DAE)
		inputname = firstarg;
		Uffunc = secondarg;
		Ufargs = thirdarg;
	end

	idx_in_cktu = find(strcmp(inputname, feval(DAE.inputnames,DAE)));
	if length(idx_in_cktu) ~= 1
		fprintf(2, 'set_uLTISSS: input %s not found exactly once amonst ckt inputs\n', inputname);
		return;
	end

	idx_already_there = find(idx_in_cktu == DAE.Uffunc_updates.indices);
	if 0 == length(idx_already_there)
		DAE.Uffunc_updates.indices(end+1) = idx_in_cktu;
		DAE.Uffunc_updates.Uffunclist{end+1} = Uffunc;
		DAE.Uffunc_updates.Ufargslist{end+1} = Ufargs;
	elseif 1 == length(idx_already_there)
		DAE.Uffunc_updates.Uffunclist{idx_already_there} = Uffunc;
		DAE.Uffunc_updates.Ufargslist{idx_already_there} = Ufargs;
	else
		fprintf(2, 'set_uLTISSS: this can''t happen!\n');
		return;
	end

	outDAE = DAE;
end % set_uLTISSS
