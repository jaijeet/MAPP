function parmvals = getparms(firstarg, secondarg)
%function parmvals = getparms(firstarg, secondarg)
%This function returns the values of all defined parameters of a DAE
%INPUT args:
%   if nargin ==2   
%       firstarg         - DAE parms name (cell array)
%       secondarg        - DAEAPI object/structure describing a DAE
%   if nargin == 1
%       firstarg         - DAEAPI object/structure describing a DAE
%OUTPUTs:
%   if nargin ==2   
%       parmvals         - values as DAE parameters specified in first args
%                          (cell array)
%   if nargin == 1
%       parmvals         - values of all defined DAE parameters
%                          (cell array)
%
%EXAMPLE:
% call as: parmvals = getparms(DAE)
%   - returns values of all defined parameters
% OR as parmval = getparms(parmname, DAE)
%         ^                   ^         
%       value               string
% OR as parmvals = getparms(parmnames, DAE)
%         ^                     ^ 
%    cell array            cell array
	if 2 == nargin
		DAE = secondarg;
		if (1 == isa(firstarg, 'cell'))
			% getparms(parmnames, DAE)
			parmnames = firstarg;
		else
			% getparms(parmname, DAE)
			parmnames{1} = firstarg;
		end
		pnames = feval(DAE.parmnames, DAE);

		for i = 1:length(parmnames);
            pname = parmnames{i};
            pidx = find(~cellfun(@isempty, regexp(pnames, sprintf('^%s', pname))));
			if (length(pidx) < 1)
				fprintf(1, 'parameter starting with %s not found in DAE.\n', pname);
				parmvals = {};
                return;
			elseif (length(pidx) > 1)
                exactmatch = find(strcmp(pname, pnames));
                if 1 == length(exactmatch)
                    pidx = exactmatch; % parm name matched exactly, don't worry about other partial matches
                elseif length(exactmatch) > 1
                    fprintf(1, 'parameter %s multiply defined. Please fix DAE.parmnames()!\n', pname);
				    parmvals = {};
                    return;
                else
                    fprintf(1, 'parameter starting with %s has multiple matches:\n', pname);
                    for j=1:length(pidx)
                        fprintf('%s\n', pnames{pidx(j)});
                    end
                    fprintf(1, 'Please add more characters to the parameter name to make unique.\n');
				    parmvals = {};
                    return;
                end
			end
			parmvals{i} = DAE.parms{pidx};

		end

		if (0 == isa(firstarg, 'cell'))
			parmvals = parmvals{1}; % return non-cell
		end
	elseif 1 == nargin
		DAE = firstarg;
		parmvals = DAE.parms;
	else
		error('getparms takes 1 or 2 arguments');
	end
end % getparms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
