function outDAE = set_uQSS(firstarg, secondarg, thirdarg)
%function outDAE = set_uQSS(qssvec, DAE);
%	 			  ^
%                              vector of values for all ckt inputs
% 	or
%function outDAE = set_uQSS(inputname, inputval, DAE);
%				  ^          ^
%			        string     scalar
%	or
%function outDAE = set_uQSS(inputnames, inputvals, DAE);
%				  ^          ^
%			        cell array  vector of values
%	                        of strings
%
%Sets QSS/DC input values for a DAE.
%
%Examples
%--------
%
% DAE = vsrcRLCdiode_daeAPIv6();
% feval(DAE.inputnames, DAE)
% DAE = feval(DAE.set_uQSS, 'E', -1, DAE); % set DC value of E to -1V
% feval(DAE.uQSS, DAE)
%
% feval(DAE.ninputs, DAE) % = 1
% DAE = feval(DAE.set_uQSS, -1, DAE); % set DC value of all inputs
%
%See also
%--------
%
% uQSS, utransient, set_utransient, uLTISSS, set_uLTISSS
%
%Notes:
%
%1. All forms above set up or override DAE.uQSSvec_updates.
%   DAE.uQSSvec_default is not touched by this function (it is set during
%   DAE setup). This is different from the way it is done in 
%   {,set_}u{transient,LTISSS}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%updates DAE.uQSSvec_updates with new values for uQSSvec for the scalar inputs
%specified
	if (nargin < 2) || (nargin > 3)
	   fprintf(2,'set_uQSS requires 2 or 3 arguments\n');
	   return;
	end

	if 2 == nargin
		% set_uQSS(qssvec, DAE)
		DAE = secondarg;
		inputnames = feval(DAE.inputnames,DAE);
		for i=1:length(firstarg)
			inputvals{i} = firstarg(i);
		end
	else % 3 == nargin
		DAE = thirdarg;
		if (1 == isa(firstarg, 'cell'))
			% set_uQSS(inputnames, inputvals, DAE)
			inputnames = firstarg;
			inputvals = secondarg;
		else
			% set_uQSS(inputname, inputval, DAE)
			inputnames{1} = firstarg;
			inputvals{1} = secondarg;
		end
	end

	nIN = length(inputnames);
	nIV = length(inputvals);
	if nIN ~= nIV
	   fprintf(2,'set_uQSS: inputnames and inputvals are not of the same size\n');
	   return;
	end

	all_input_names = feval(DAE.inputnames,DAE);
	for i=1:nIN
		inpname = inputnames{i};
		inpval = inputvals(i);
		idx_in_cktu = find(strcmp(inpname, all_input_names));
		if length(idx_in_cktu) ~= 1
			fprintf(2, 'set_uQSS: input %s not found exactly once amonst ckt inputs\n', inpname);
			return;
		end

		idx_already_there = find(idx_in_cktu == DAE.uQSSvec_updates.indices);
		if 0 == length(idx_already_there)
			DAE.uQSSvec_updates.indices(end+1) = idx_in_cktu;
			DAE.uQSSvec_updates.values(end+1) = inpval{:}; % inpval is a 1x1 cell, not numeric
		elseif 1 == length(idx_already_there)
			DAE.uQSSvec_updates.values(idx_already_there) = inpval{:}; % inpval is a 1x1 cell, not numeric
		else
			fprintf(2, 'set_uQSS: this can''t happen!\n');
			return;
		end
	end

	outDAE = DAE;
end % set_uQSS
