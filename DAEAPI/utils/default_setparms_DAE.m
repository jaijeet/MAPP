function outDAE = setparms(firstarg, secondarg, thirdarg)
%function outDAE = setparms(firstarg, secondarg, thirdarg)
%This function sets new values of parameters of a DAE.
%INPUT args:
%   if nargin == 3   
%       firstarg        - DAE parms name (cell array)
%       secondarg       - new values of parameters specified in firstarg
%                         (cell array)
%       thirdarg        - DAEAPI object/structure describing a DAE
%   if nargin ==2   
%       firstarg         - new values of all parameters
%       secondarg        - DAEAPI object/structure describing a DAE
%OUTPUTs:
%       outDAE           - updated DAE with new parms values 
%
%EXAMPLE:
% call as: outDAE = setparms(parms, DAE)
%                              ^     
%              cell array with values of all defined parameters
% OR as outDAE = setparms(parmname, newval, DAE)
%                            ^         ^
%                          string    value
% OR as outDAE = setparms(parmnames, newvals, DAE)
%                            ^         ^
%                            cell arrays
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

		pnames = feval(DAE.parmnames, DAE);
		for i = 1:length(parmnames);
            pname = parmnames{i};
            pidx = find(~cellfun(@isempty, regexp(pnames, sprintf('^%s', pname))));
			if (length(pidx) < 1)
				fprintf(1, 'parameter starting with %s not found in DAE.\n', pname);
                outDAE = DAE;
                return;
			elseif (length(pidx) > 1)
                exactmatch = find(strcmp(pname, pnames));
                if 1 == length(exactmatch)
                    pidx = exactmatch; % parm name matched exactly, don't worry about other partial matches
                elseif length(exactmatch) > 1
                    fprintf(1, 'parameter %s multiply defined. Please fix DAE.parmnames()!\n', pname);
                    outDAE = DAE;
                    return;
                else
                    fprintf(1, 'parameter starting with %s has multiple matches:\n', pname);
                    for j=1:length(pidx)
                        fprintf('%s\n', pnames{pidx(j)});
                    end
                    fprintf(1, 'Please add more characters to the parameter name to make unique.\n');
                    outDAE = DAE;
                    return;
                end
			end

			DAE.parms{pidx} = newvals{i};
		end
	elseif 2 == nargin
		DAE = secondarg;
		parms = firstarg;
		DAE.parms = parms;
	else
		error('setparms takes 1, 2 or 3 arguments');
	end
	outDAE = DAE;
end
% end setparms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





