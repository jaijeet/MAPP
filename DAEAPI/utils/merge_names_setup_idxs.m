function [mergedUnknames, DAE1unkIdxs, DAE2unkIdxs, mergedCommonIdxs, commonIdxs1, commonIdxs2, ...
	mergedOtherIdxs1, otherIdxs1, mergedOtherIdxs2, otherIdxs2] = ...
		merge_names_setup_idxs(DAE1_nodes, DAE2_nodes, DAE1_unknames, DAE2_unknames, uniqID1, uniqID2)
% Usage examples:
%
% x1 = x(DAE1unkIdxs)
% x2 = x(DAE2unkIdxs)
% x(mergedCommonIdxs) = x1(commonIdxs1), or x1(commonIdxs1) = x(mergedCommonIdxs)
% x(mergedCommonIdxs) = x2(commonIdxs2), or x2(commonIdxs2) = x(mergedCommonIdxs)
% x(mergedOtherIdxs1) = x1(otherIdxs1), or x1(otherIdxs1) = x(mergedOtherIdxs1)
% x(mergedOtherIdxs2) = x2(otherIdxs2), or x2(otherIdxs2) = x(mergedOtherIdxs2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	% basic checks
	nConnects = length(DAE1_nodes);

	if nConnects ~= length(DAE2_nodes)
		error('DAE1_nodes not the same size as DAE2_nodes');
	end


	% make a table of nodes1 idxs vs nodes2 idxs
	%{
	unktable = zeros(nConnects, 2);
	for i = 1:nConnects
		nm2 = DAE2_nodes{i};
		nm1 = DAE1_nodes{i};
		idx1 = find(strcmp(DAE1_unknames, nm1));
		if 1 ~= length(idx1) 
			error(sprintf('unk name %s does not appear exactly once in DAE1''s unknames.', nm1));
		end

		idx2 = find(strcmp(DAE2_unknames, nm2));
		if 1 ~= length(idx2) 
			error(sprintf('unk name %s does not appear exactly once in DAE2''s unknames.', nm2));
		end
		unktable(i,1) = idx1;
		unktable(i,2) = idx2;
	end

	% check for repeated indexes: not allowed
	if nConnects ~= length(unique(unktable(:,1)))
		error('nodes to connect not unique for DAE1');
	end
	if nConnects ~= length(unique(unktable(:,2)))
		error('nodes to connect not unique for DAE2');
	end
	%}

	% keep the 1st DAE's unk names; drop the connected ones of the second DAE
	% use the table to define the order of DAE unknowns
	nunks1 = length(DAE1_unknames);
	nunks2 = length(DAE2_unknames);
	DAE1unkIdxs = 1:nunks1; % x1 can be obtained as x(DAE1unkIdxs)
	j = 0;
	k = 0;
	uniqID1 = strcat(uniqID1, '.');
	uniqID2 = strcat(uniqID2, '.');
	mergedUnknames = strcat(uniqID1, DAE1_unknames);
	for i = 1:nunks2
		nm2 = DAE2_unknames{i};
		unk_idx_connects = find( strcmp(nm2, DAE2_nodes) );
		if 1 == length(unk_idx_connects)  % nm2 is one of DAE2's connected nodes
			k = k+1;
			nm1 = DAE1_nodes{unk_idx_connects}; % nm1 is the DAE1 node nm2 is connected to
			unk_idx1 = find( strcmp(nm1, DAE1_unknames) );
			if 1 == length(unk_idx1)
				DAE2unkIdxs(i) = unk_idx1;
				commonIdxs1(k) = unk_idx1;
			else
				error(sprintf('DAE1_node %s does not appear in DAE1_unknames', nm1));
			end
			% x2(commonIdxs2) = x(mergedCommonIdxs)
			mergedCommonIdxs(k) = unk_idx1;
			commonIdxs1(k) = unk_idx1;
			commonIdxs2(k) = i;
		elseif 0 == length(unk_idx_connects)
			j = j+1;
			DAE2unkIdxs(i) = nunks1+j;
			% x2(otherIdxs2) = x(mergedOtherIdxs2)
			mergedOtherIdxs2(j) = nunks1+j;
			mergedUnknames{nunks1+j} = strcat(uniqID2, nm2);
			otherIdxs2(j) = i;
		else
			error(sprintf('%s found more than once in DAE2_nodes', nm2));
		end
	end
	otherIdxs1 = setdiff(1:nunks1,commonIdxs1);
	mergedOtherIdxs1 = otherIdxs1;
% end of merged_names_idxs
