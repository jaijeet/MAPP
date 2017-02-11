%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2011/sometime
%
%<TODO>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





DAE1_unknames = {'a', 'b', 'c', 'd', 'e'}; % 5
DAE2_unknames = {'z', 'y', 'x', 'v', 'u', 't', 's'}; % 7

DAE1_nodes = {'a', 'd'};
DAE2_nodes = {'u', 'x'};

uniqID1 = '1';
uniqID2 = '2';

[mergedUnknames, DAE1unkIdxs, DAE2unkIdxs, ...
	mergedcommonIdxs, commonIdxs1, commonIdxs2, mergedOtherIdxs1, otherIdxs1, mergedOtherIdxs2, otherIdxs2] = ...
		merge_names_setup_idxs(DAE1_nodes, DAE2_nodes, DAE1_unknames, DAE2_unknames, uniqID1, uniqID2);

x = 1:(length(DAE1_unknames)+length(DAE2_unknames)-length(DAE1_nodes));


DAE1_unknames
DAE2_unknames
DAE1_nodes
DAE2_nodes
mergedUnknames
DAE1unkIdxs
DAE2unkIdxs

fprintf(2, 'x1 = x([ '); fprintf(2, '%d ', DAE1unkIdxs); fprintf(2, ']):\n');
x1 = x(DAE1unkIdxs)

fprintf(2, 'x2 = x([ '); fprintf(2, '%d ', DAE2unkIdxs); fprintf(2, ']):\n');
x2 = x(DAE2unkIdxs)


fprintf(2, 'x2([ '); fprintf(2, '%d ', commonIdxs2); fprintf(2, ']) = x(['); fprintf(2, '%d ', mergedcommonIdxs); fprintf(2, ']):\n');
x2(commonIdxs2) = x(mergedcommonIdxs)

fprintf(2, 'x2([ '); fprintf(2, '%d ', otherIdxs2); fprintf(2, ']) = x(['); fprintf(2, '%d ', mergedOtherIdxs2); fprintf(2, ']):\n');
x2(otherIdxs2) = x(mergedOtherIdxs2)

fprintf(2, 'x1([ '); fprintf(2, '%d ', commonIdxs1); fprintf(2, ']) = x(['); fprintf(2, '%d ', mergedcommonIdxs); fprintf(2, ']):\n');
x1(commonIdxs1) = x(mergedcommonIdxs)

fprintf(2, 'x1([ '); fprintf(2, '%d ', otherIdxs1); fprintf(2, ']) = x(['); fprintf(2, '%d ', mergedOtherIdxs1); fprintf(2, ']):\n');
x1(otherIdxs1) = x(mergedOtherIdxs1)
