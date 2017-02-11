function outDAE = set_uHB(firstarg, secondarg, thirdarg, fourtharg)
%function outDAE = set_uHB(uHBfunc, uHBargs, DAE);
%	 			       ^
%       func (handle) returning all ckt inputs as a matrix of size ninputs x
%       Nharms
%
% 	or
%function outDAE = set_uHB(inputname, uHBfunc, uHBargs, DAE);
%				  ^          ^
%			      string     func returning
%	                         a row vector of size Nharms
%	or
%
%updates DAE.uHBfunc_updates with data for overriding parts of the ckt u vector
%whenever a vector uHBfunc is set for the entire circuit, all scalar uHBfuncs that may have been set before are
%deleted.
%
%the way uHB operates is as follows:
%- if vector_uHBfunc is set, then it is called first and out is set to its return value; otherwise, 
%  else: uHBfunc_default (which calls the models' uHBfuncs) is called, out is set to its return value
%- then, each scalar uHBfuncs in uHBfunclist is called, and the appropriate entry of out is overwritten
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	if (nargin < 3) || (nargin > 4)
	   fprintf(2,'set_uHB requires 3 or 4 arguments\n');
	   return;
	end

	if 3 == nargin
		% set_uHB(uHBfunc, uHBargs, DAE)
		DAE = thirdarg;
		uHBfunc = firstarg;
		uHBargs = secondarg;
		DAE.uHBfunc_updates.vector_uHBfunc = uHBfunc;
		DAE.uHBfunc_updates.vector_uHBfunc_args = uHBargs;
		DAE.uHBfunc_updates.indices = []; % wipe out any previous scalar uHBfuncs
		DAE.uHBfunc_updates.uHBfunclist = {}; % wipe out any previous scalar uHBfuncs
		DAE.uHBfunc_updates.uHBargslist = {}; % wipe out any previous scalar uHBfuncs
		outDAE = DAE;
		return;
	end % 3 == nargin
	% below: 4 == nargin

	DAE = fourtharg;
	if (1 == isa(firstarg, 'cell'))
		fprintf(2, 'set_uHB supports setting only 1 input at a time\n')
		return;
	else
		% set_uHB(inputname, uHBfunc, uHBargs, DAE)
		inputname = firstarg;
		uHBfunc = secondarg;
		uHBargs = thirdarg;
	end

	idx_in_cktu = find(strcmp(inputname, feval(DAE.inputnames,DAE)));
	if length(idx_in_cktu) ~= 1
		fprintf(2, 'set_uHB: input %s not found exactly once amonst ckt inputs\n', inputname);
		return;
	end

	idx_already_there = find(idx_in_cktu == DAE.uHBfunc_updates.indices);
	if 0 == length(idx_already_there)
		DAE.uHBfunc_updates.indices(end+1) = idx_in_cktu;
		DAE.uHBfunc_updates.uHBfunclist{end+1} = uHBfunc;
		DAE.uHBfunc_updates.uHBargslist{end+1} = uHBargs;
	elseif 1 == length(idx_already_there)
		DAE.uHBfunc_updates.uHBfunclist{idx_already_there} = uHBfunc;
		DAE.uHBfunc_updates.uHBargslist{idx_already_there} = uHBargs;
	else
		fprintf(2, 'set_uHB: this can''t happen!\n');
		return;
	end

	outDAE = DAE;
end % set_uHB
