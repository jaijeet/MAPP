function outDAE = set_uMultitime(firstarg, secondarg, thirdarg, fourtharg)
%function outDAE = set_uMultitime(uMtfunc, uMtargs, DAE);
%	 			    ^
%                         func (handle) returning all ckt inputs as a vector
% 	or
%function outDAE = set_uMultitime(inputname, uMtfunc, uMtargs, DAE);
%				     ^          ^
%			        string     func returning
%	                                   scalar output
%
%Sets multitime inputs for a DAE. These inputs are used by MPDE-based analyses.
%
%uMtfunc should be a function handle callable as:
%	feval(uMtfunc, [t1, t2, ..., tm] , uMtargs)
%t1, ..., tm represent m artificial time scales. uMtfunc should return a real
%column vector of size feval(DAE.ninputs, DAE) in the first form above, or a
%real scalar in the second form. uMtargs can be anything usable by uMtfunc as
%its second argument.
%
%Examples
%--------
%
% % set up DAE
% nsegs = 1; R = 1e3; C = 1e-6;
% DAE =  RClineDAEAPIv6('', nsegs, R, C);
% 
% % set multitime input to the DAE
% uMtargs.A1 = 1; uMtargs.A2 = 1; uMtargs.f1=1e3; uMtargs.f2=1e1;
% uMtfunc = @(t1t2, args) args.A1*sin(2*pi*args.f1*t1t2(1)) + ...
%                         args.A2*sin(2*pi*args.f2*t1t2(2));
% feval(DAE.inputnames, DAE)
% % second form
% DAE = feval(DAE.set_uMultitime, 'line driving voltage: E(t)', uMtfunc, ...
%             uMtargs, DAE);
% % first form
% DAE = feval(DAE.set_uMultitime, uMtfunc, uMtargs, DAE);
%
%
%See also
%--------
%
% uMultitime.
%
%Notes:
%
%1. The first form above sets DAE.vector_uMtfunc and resets DAE.uMtfunc_updates
%   to empty.
%
%2. The second form above (scalar uMtfuncs) updates DAE.uMtfunc_updates with
%   data for overriding parts of the ckt u vector. As noted above, whenever a
%   vector uMtfunc is set for the entire circuit, all scalar uMtfuncs that may
%   have been set before are deleted.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if (nargin < 3) || (nargin > 4)
	   fprintf(2,'set_uMultitime requires 3 or 4 arguments\n');
	   return;
	end

	if 3 == nargin
		% set_uMultitime(uMtfunc, uMtargs, DAE)
		DAE = thirdarg;
		uMtfunc = firstarg;
		uMtargs = secondarg;
		DAE.uMtfunc_updates.vector_uMtfunc = uMtfunc;
		DAE.uMtfunc_updates.vector_uMtfunc_args = uMtargs;
		DAE.uMtfunc_updates.indices = []; % wipe out any previous
					         % scalar uMtfuncs
		DAE.uMtfunc_updates.uMtfunclist = {}; % wipe out any previous
						    % scalar uMtfuncs
		DAE.uMtfunc_updates.uMtargslist = {}; % wipe out any previous
						    % scalar uMtfuncs
		outDAE = DAE;
		return;
	end % 3 == nargin
	% below: 4 == nargin

	DAE = fourtharg;
	if (1 == isa(firstarg, 'cell'))
		fprintf(2, 'set_uMultitime only supports setting 1 input at a time:\n')
		fprintf(2, '\targument inputname should be a string.\n')
		return;
	else
		% set_uMultitime(inputname, uMtfunc, uMtargs, DAE)
		inputname = firstarg;
		uMtfunc = secondarg;
		uMtargs = thirdarg;
	end

	idx_in_cktu = find(strcmp(inputname, feval(DAE.inputnames,DAE)));
	if length(idx_in_cktu) ~= 1
		fprintf(2, 'set_uMultitime: input %s not found exactly once amonst ckt inputs\n', inputname);
		return;
	end

	idx_already_there = find(idx_in_cktu == DAE.uMtfunc_updates.indices);
	if 0 == length(idx_already_there)
		DAE.uMtfunc_updates.indices(end+1) = idx_in_cktu;
		DAE.uMtfunc_updates.uMtfunclist{end+1} = uMtfunc;
		DAE.uMtfunc_updates.uMtargslist{end+1} = uMtargs;
	elseif 1 == length(idx_already_there)
		DAE.uMtfunc_updates.uMtfunclist{idx_already_there} = uMtfunc;
		DAE.uMtfunc_updates.uMtargslist{idx_already_there} = uMtargs;
	else
		fprintf(2, 'set_uMultitime: this can''t happen!\n');
		return;
	end

	outDAE = DAE;
end % set_uMultitime
