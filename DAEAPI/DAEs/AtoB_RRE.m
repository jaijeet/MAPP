function DAE = AtoB_RRE()
%author: J. Roychowdhury, 2012/05/24
% A <--> B reaction system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Just a simple test of RRE_EqnEngine
%	
%	A <-> B
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% name
	reactionsystemname = 'A <-> B';

	% reactants (names)
	reactants = {'A', 'B'};

	% input reactants
	input_reactants = {};

	% list of reactions
	% R1: A <-> B
	R1.LHSstoichiometries = [1 0];
	R1.RHSstoichiometries = [0 1];
	R1.kF = 1.0; R1.kR = 0.5;

	reactions = {R1};
	reactionlabels = {'R1'};

	reactionsystem.name = reactionsystemname;
	reactionsystem.reactants = reactants;
	reactionsystem.input_reactants = input_reactants;
	reactionsystem.reactions = reactions;
	reactionsystem.reactionlabels = reactionlabels;

	DAE = RRE_EqnEngine('', reactionsystem);
end
