function allnamesout = rename_names_DAEAPI(allnames, rename_from, rename_to)
%function allnamesout = rename_names(allnames, rename_from, rename_to)
%INPUT args:
%   allnames            - the complete list of names (cell array)
%   rename_from         - the list of names to be changed in allnames (cell
%                         array)
%   rename_to           - the list of new names (cell array)
%OUTPUT:
%   allnamesout         - the new complete list of names (cell array)
%
%all arguments should be cell arrays of strings. rename_from and rename_to
%should have the same length there should be no repetitions in any of the
%arguments; this function will check that there are no repetitions in
%allnamesout.

	nfrom = length(rename_from);
	nto = length(rename_to);
	nall = length(allnames);

	if nfrom ~= nto
		error('rename_names: rename_from and rename_to not the same length');
	end

	if nall < nfrom
		error('rename_names: allnames has fewer entries than rename_from/rename_to');
	end


	uniqout = unique(allnames);
	if length(uniqout) ~= nall
		error(sprintf('rename_names: allnames contains repeated names'));
	end

	allnamesout = allnames;

	if 0 == nfrom 
		return;
	end

	uniqout = unique(rename_from);
	if length(uniqout) ~= nfrom
		error(sprintf('rename_names: rename_from contains repeated names'));
	end

	uniqout = unique(rename_to);
	if length(uniqout) ~= nto
		error(sprintf('rename_names: rename_to contains repeated names'));
	end


	for i=1:nfrom
		nm_orig = rename_from{i};
		idx = find(strcmp(nm_orig, allnames));
		if 1 ~= length(idx)
			error(sprintf('rename_names: %s not found exactly once in allnames', nm_orig));
			return;
		end
		nm_to = rename_to{i};
		allnamesout{idx} = nm_to;
	end

	uniqout = unique(allnamesout);
	if length(uniqout) ~= nall
		error(sprintf('rename_names: list of new names (somehow) contains repeated names'));
	end
% end of rename_names
