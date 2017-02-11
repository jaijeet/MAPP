function DAE = Soloveichik_ABC_oscillator()
%function DAE = Soloveichik_ABC_oscillator()
%David Soloveichik's oscillator (old)
%author: J. Roychowdhury, 2012/05/21
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Reaction System
%	David Soloveichik's oscillator:
%	
%	A + B -> 2B
%	B + C -> 2C
%	C + A -> 2A
%
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
	reactionsystemname = 'A + B -> 2B; B + C -> 2C; C + A -> 2A';

	% reactants (names)
	reactants = {'A', 'B', 'C'};

	k = 1;

	% list of reactions
	% R1: A + B -> 2B
	R1.LHSstoichiometries = [1 1 0];
	R1.RHSstoichiometries = [0 2 0];
	R1.kF = k; R1.kR = 0;

	% R2: B + C -> 2C
	R2.LHSstoichiometries = [0 1 1];
	R2.RHSstoichiometries = [0 0 2];
	R2.kF = k; R2.kR = 0;

	% R3: C + A -> 2A
	R3.LHSstoichiometries = [1 0 1];
	R3.RHSstoichiometries = [2 0 0];
	R3.kF = k; R3.kR = 0;

	reactions = {R1, R2, R3};
	reactionnames = {'R1', 'R2', 'R3'};

	reactionsystem.name = reactionsystemname;
	reactionsystem.reactants = reactants;
	reactionsystem.reactions = reactions;
	reactionsystem.reactionlabels = reactionnames;

	DAE = RRE_EqnEngine(reactionsystem);
end
