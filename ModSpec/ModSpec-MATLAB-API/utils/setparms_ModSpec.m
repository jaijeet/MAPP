function outMOD = setparms_ModSpec(firstarg, secondarg, thirdarg)
%function outMOD = setparms_ModSpec(firstarg, secondarg, thirdarg)
%This function updates the parm values for a ModSpec model.
%INPUT args:
%if nargin == 3
%   firstarg        - cell array containing ModSpec model parm names to be
%                     updated
%   secondarg       - new values of ModSpec parms to be updated (cell array)
%   thirdarg        - ModSpec model
%
%   OR
%
%   firstarg        - model parm name (string)
%   secondarg       - model parm value
%   thirdarg        - ModSpec model
%
%if nargin == 2
%   firstarg        - cell array containing values for all the parameters of
%                     a ModSpec model
%   secondarg       - ModSpec model
%
%   OR
%
%   firstarg        - double cell array containing {'parmname', parmval} pairs
%   secondarg       - ModSpec model
%
%OUTPUT:
%   outMOD          - updated ModSpec model with new parameter values
%
%EXAMPLE:
% call as: outMOD = setparms(allparmvals, MOD)
%                              ^     
%                       cell array with values of all defined parameters
% OR as outMOD = setparms(parmname, newval, MOD)
%                            ^         ^
%                          string    value
% OR as outMOD = setparms(pnames, newvals, MOD)
%                            ^         ^
%                            cell arrays
%
% OR as outMOD = setparms(  {{'pname1', pval1}, {'pname2', pval2}, ..}  , MOD)
%
% sets up or changes outMOD.parm_vals; 
% relies on MOD.parmnames(), MOD.nparms(), MOD.ModelName()
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2015/06/10 and before.                             %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if 3 == nargin
		MOD = thirdarg;
        if isempty(firstarg)
            outMOD = MOD;
            warning('setparms_ModSpec: empty first argument, no parameters changed');
            return;
        end
		if (1 == isa(firstarg, 'cell'))
			% setparms(pnames, newvals, MOD)
			pnames = firstarg;
			newvals = secondarg;
		else
			% setparms(parmname, newval, MOD)
			pnames{1} = firstarg;
			newvals{1} = secondarg;
		end
	elseif 2 == nargin
		MOD = secondarg;
        if isempty(firstarg)
            outMOD = MOD;
            warning('setparms_ModSpec: empty first argument, no parameters changed');
            return;
        end

        % firstarg must be a cell array, just assuming that

        if feval(MOD.nparms, MOD) ~= length(firstarg)
            % we have {{pname1, pval1}, {pname2, pval2}, ...} pairs
			for i=1:length(firstarg)
                thepair = firstarg{i};
                pnames{i} = thepair{1};
			    newvals{i} = thepair{2};
            end
        else % possible ambiguity: firstarg could be allparmvals
             % or it could be { parm val pairs }. 
             % Trying to disambiguate:
             for i=1:length(firstarg)
                maybethepair = firstarg{i};
                if ~isa(maybethepair, 'cell') || 2 ~= length(maybethepair)
                % ie, it is not a cell array, or it is a cell array of length not 2
                    % it is definitely allparmvals
			        MOD.parm_vals = firstarg; % bad coding practice, a la
                                              % Fortran, but what the hell
		            outMOD = MOD;
                    return;
                end
             end
             % if we are here, then ambiguity persists
             is_parmval_pairs = 0; % could still be allparmvals,
                                   % but every parameter value must be
                                   % a cell array of length 2!
             parmdefaults = feval(MOD.parmdefaults, MOD);
             for i=1:length(parmdefaults)
                if ~isa(parmdefaults{i}, 'cell') || 2 ~= length(parmdefaults{i})
                    % parmdefaults{i} does NOT look like a cell array of length 2
                    is_parmval_pairs = 1; % definitely parmval pairs
                    break;
                end
             end
             if 1 == is_parmval_pairs
                for i=1:length(firstarg)
                    thepair = firstarg{i};
                    pnames{i} = thepair{1};
			        newvals{i} = thepair{2};
                end
             else % still ambiguity - extremely unlikely but possible:
                  % every parameter value is a cell array of length 2,
                  % AND firstarg has exactly nparms entries. Although
                  % we could check further (eg, check against parmnames),
                  % this case is so unlikely that we don't bother but
                  % issue an "ambiguity error".
                error('setparms_ModSpec: ambiguous first argument: are you specifying\nparameters pairwise (ie, {{name1, val1}, {name2, val2}, ..}) or are you specifying\nall parameter values at once (they all happen to be cell arrays of\nlength 2!)? Please change your call to disambiguate.');
             end
        end
	else % nargin != 2 or 3
		error('setparms_ModSpec takes 2 or 3 arguments');
	end
	allparmnames = feval(MOD.parmnames, MOD);

    % pnames and newvals have now been set up correctly by the above
	for i = 1:length(pnames);
		pname = pnames{i};
		pidx = find(strcmp(pname, allparmnames));
		if (length(pidx) < 1)
			fprintf(2, 'parameter %s not found in model %s.\n', pname, ...
                       feval(MOD.ModelName, MOD));
			return;
		elseif (length(pidx) > 1)
			fprintf(2, 'parameter %s seems to be multiply defined. Please fix MOD.parmnames()!\n', ...
				pname);
			return;
		end

		MOD.parm_vals{pidx} = newvals{i};
	end
	outMOD = MOD;
end % setparms_ModSpec for overloading setparms
