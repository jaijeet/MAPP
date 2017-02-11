function outDAE = set_utransient(firstarg, secondarg, thirdarg, fourtharg)
%function outDAE = set_utransient(utfunc, utargs, DAE);
%	 			    ^
%                         func (handle) returning all ckt inputs as a vector
% 	or
%function outDAE = set_utransient(inputname, utfunc, 	utargs, DAE);
%				     ^          ^
%			        string     func returning
%	                                   scalar output
%
%Sets transient inputs to a DAE.
%
%utfunc should be a function handle callable as (t represents time):
%	feval(utfunc, t, utargs)
%returning a real column vector of size feval(DAE.ninputs, DAE) in the
%first form above, or a real scalar in the second form. utargs can be 
%anything usable by utfunc as its second argument.
%
%Examples
%--------
%
% % set up DAE
% nsegs = 1; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
% 
% % set transient input to the DAE
% utargs.A = 1; utargs.f=1e3; utargs.phi=0;
% utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
% feval(DAE.inputnames, DAE)
% % second form
% DAE = feval(DAE.set_utransient, 'line driving voltage: E(t)', utfunc, ...
%             utargs, DAE);
% % first form
% DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
%
%
%See also
%--------
%
% utransient, transient, LMS.
%
%Notes:
%
%1. The first form above sets DAE.vector_utfunc and resets DAE.utfunc_updates
%   to empty.
%
%2. The second form above (scalar utfuncs) updates DAE.utfunc_updates with
%   data for overriding parts of the ckt u vector. As noted above, whenever a
%   vector utfunc is set for the entire circuit, all scalar utfuncs that may
%   have been set before are deleted.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	if (nargin < 3) || (nargin > 4)
	   fprintf(2,'set_utransient requires 3 or 4 arguments\n');
	   return;
	end

	if 3 == nargin
		% set_utransient(utfunc, utargs, DAE)
		DAE = thirdarg;
		utfunc = firstarg;
		utargs = secondarg;
		DAE.utfunc_updates.vector_utfunc = utfunc;
		DAE.utfunc_updates.vector_utfunc_args = utargs;
		DAE.utfunc_updates.indices = []; % wipe out any previous
					         % scalar utfuncs
		DAE.utfunc_updates.utfunclist = {}; % wipe out any previous
						    % scalar utfuncs
		DAE.utfunc_updates.utargslist = {}; % wipe out any previous
						    % scalar utfuncs
		outDAE = DAE;
		return;
	end % 3 == nargin
	% below: 4 == nargin

	DAE = fourtharg;
	if (1 == isa(firstarg, 'cell'))
		fprintf(2, 'set_utransient only supports setting 1 input at a time:\n')
		fprintf(2, '\targument inputname should be a string.\n')
		return;
	else
		% set_utransient(inputname, utfunc, utargs, DAE)
		inputname = firstarg;
		utfunc = secondarg;
		utargs = thirdarg;
	end

	idx_in_cktu = find(strcmp(inputname, feval(DAE.inputnames,DAE)));
	if length(idx_in_cktu) ~= 1
		fprintf(2, 'set_utransient: input %s not found exactly once amonst ckt inputs\n', inputname);
		return;
	end

	idx_already_there = find(idx_in_cktu == DAE.utfunc_updates.indices);
	if 0 == length(idx_already_there)
		DAE.utfunc_updates.indices(end+1) = idx_in_cktu;
		DAE.utfunc_updates.utfunclist{end+1} = utfunc;
		DAE.utfunc_updates.utargslist{end+1} = utargs;
	elseif 1 == length(idx_already_there)
		DAE.utfunc_updates.utfunclist{idx_already_there} = utfunc;
		DAE.utfunc_updates.utargslist{idx_already_there} = utargs;
	else
		fprintf(2, 'set_utransient: this can''t happen!\n');
		return;
	end

	outDAE = DAE;
end % set_utransient
