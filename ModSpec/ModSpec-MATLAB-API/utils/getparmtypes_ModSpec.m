function parmtypes = getparmtypes_ModSpec(firstarg, secondarg)
%function parmtypes = getparmtypes_ModSpec(firstarg, secondarg)
% Accepts a ModSpec model as input and returns types of its parameters
% call as: parmtypes = getparmtypes_ModSpec(MOD)
%   - returns types of all defined parameters
% OR as parmtypes = getparmtypes_ModSpec(parmname, MOD)
%         ^                 		    ^         
%       string               		  string
% OR as parmtypes = getparmtypes_ModSpec(parnames, MOD)
%         ^       			    ^ 
%    cell array            	   	cell array
%
% relies on MOD.parm_vals (data member), MOD.parm_types (data member),
%	  MOD.parm_names()
%
%TODO:	should support char, string, int, double, boolean 	
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
		if isempty(MOD.parm_types)
		% no specified parm_types, call matlab's class function
			parmtypes = cellfun(@class, MOD.parm_vals,'UniformOutput',false);
		else
		% return modeller specified parm_types
			parmtypes = MOD.parm_types;
		end
		return;
	else
		error('getparmtypes_ModSpec takes 1 or 2 arguments');
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

		if isempty(MOD.parm_types)
		% no specified parm_types, call matlab's class function
			parmtypes{i} = class(MOD.parm_vals{pidx});
		else
		% return modeller specified parm_types
			parmtypes{i} = MOD.parm_types{pidx};
		end
	end
	if (2 == nargin) && (0 == isa(firstarg, 'cell'))
		parmtypes = parmtypes{1}; % return non-cell
	end
end % getparmtypes_ModSpec
