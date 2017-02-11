function parmvals = getparms_ModSpec(firstarg, secondarg)
%function parmvals = getparms_ModSpec(firstarg, secondarg)
%This function accepts a ModSpec model as input and returns values of its
%parameters as output.
%INPUT args:
%if nargin == 2
%   firstarg        - cell array containing ModSpec model parms name
%   secondarg       - ModSpec model
%if nargin == 1
%   firstarg        - ModSpec model    
%
%OUTPUT:
%   parmvals        - parameter values of the ModSpec model
%
%EXAMPLE:
% call as: parmvals = getparms_ModSpec(MOD)
%   - returns values of all defined parameters
% OR as parmval = getparms_ModSpec(parmname, MOD)
%         ^                   ^         
%       value               string
% OR as parmvals = getparms_ModSpec(pnames, MOD)
%         ^                     ^ 
%    cell array            cell array
%
% relies on MOD.parm_vals (data member), MOD.Modname(),  MOD.parmnames()

%author: J. Roychowdhury.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





	if 2 == nargin
		MOD = secondarg;
		if (1 == isa(firstarg, 'cell'))
			% getparms(pnames, MOD)
			pnames = firstarg;
		else
			% getparms(parmname, MOD)
			pnames{1} = firstarg;
		end
	elseif 1 == nargin
		MOD = firstarg;
		parmvals = MOD.parm_vals;
		return;
	else
		error('getparms_ModSpec takes 1 or 2 arguments');
	end
	allparmnames = feval(MOD.parmnames, MOD);
	% n == 2 case
	for i = 1:length(pnames);
		pname = pnames{i};
		pidx = find(strcmp(pname, allparmnames));
		if (length(pidx) < 1)
			fprintf(2, 'parameter %s not found in model %s.\n', pname, feval(MOD.Modname,MOD));
			parmvals = {};
			return;
		elseif (length(pidx) > 1)
			fprintf(2, 'parameter %s seems to be multiply defined. Please fix MOD.parmnames()!\n', ...
				pname);
			parmvals = {};
			return;
		end

		parmvals{i} = MOD.parm_vals{pidx};
	end
	if (2 == nargin) && (0 == isa(firstarg, 'cell'))
		parmvals = parmvals{1}; % return non-cell
	end
end % getparms_ModSpec
