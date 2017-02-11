function DAE = Soloveichik_ABC_oscillator_stabilized()
%author: J. Roychowdhury, 2012/05/21
% David Soloveichik's ABC oscillator, stabilized
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Reaction System
%	David Soloveichik's ABC oscillator, stabilized
%	X is a regular reactant
%	
%	A + 2B -> 3B
%	B + C  -> 2C
%	C + A  -> 2A
%	A + X  -> X	
%	    X  -> A + X
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
	reactionsystemname = 'DS'' ABC oscillator, stabilized';

	% reactants (names)
	reactants = {'A', 'B', 'C', 'X'};

	% input reactants (names)
	input_reactants = {};

	k = 1;

	% list of reactions
	% R1: A + 2B -> 3B
	R1.LHSstoichiometries = [1 2 0 0];
	R1.RHSstoichiometries = [0 3 0 0];
	R1.kF = k; R1.kR = 0;

	% R2: B + C -> 2C
	R2.LHSstoichiometries = [0 1 1 0];
	R2.RHSstoichiometries = [0 0 2 0];
	R2.kF = k; R2.kR = 0;

	% R3: C + A -> 2A
	R3.LHSstoichiometries = [1 0 1 0];
	R3.RHSstoichiometries = [2 0 0 0];
	R3.kF = k; R3.kR = 0;


	%{
	email from DS, 2012/05/25
	I believe adding the following reactions works:
	a + b + c -> x
	a -> x
	x -> a
	The rate of the last reaction has to be larger than some threshold. If all other
	rate constants are 1, then 2 works nicely, for example.

	Another solution:
	(sample trace attached starting at a=1.2, b=1, c=1, all rate constants 1)
	a + 2 b -> 3 b
	b + c -> 2 c
	c + a -> 2 a
	x -> a
	a -> x

	By the way, the first reaction above can be separated into 2 second-order
	+reactions if one doesn't like third-order reactions:
	a + b -> a' + b
	a' + b -> 2 b
	%}

	% R5: A + X -> X
	R5.LHSstoichiometries = [1 0 0 1];
	R5.RHSstoichiometries = [0 0 0 1];
	R5.kF = k; R5.kR = 0;


	% R6: X -> A  + X
	R6.LHSstoichiometries = [0 0 0 1];
	R6.RHSstoichiometries = [1 0 0 1];
	R6.kF = k; R6.kR = 0;


	%{ these don't work:
	k2 = 0.01;

	% R4: 3A + 3B + 3C -> X
	R4.LHSstoichiometries = [3 3 3 0];
	R4.RHSstoichiometries = [0 0 0 1];
	R4.kF = k2; R4.kR = 0;

	%{
	% R4: 3A -> X
	R4.LHSstoichiometries = [3 0 0 0];
	R4.RHSstoichiometries = [0 0 0 1];
	R4.kF = k2; R4.kR = 0;

	% R5: 3B -> X
	R5.LHSstoichiometries = [0 3 0 0];
	R5.RHSstoichiometries = [0 0 0 1];
	R5.kF = k2; R5.kR = 0;

	% R6: 3C -> X
	R6.LHSstoichiometries = [0 0 3 0];
	R6.RHSstoichiometries = [0 0 0 1];
	R6.kF = k2; R6.kR = 0;

	k3 = 0.0001;

	% R7: X -> A + B + C
	R7.LHSstoichiometries = [0 0 0 1];
	R7.RHSstoichiometries = [1 1 1 0];
	R7.kF = k3; R7.kR = 0;
	%}


	%{
	reactions = {R1, R2, R3, R4, R5, R6, R7};
	reactionnames = {'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7'};
	reactions = {R1, R2, R3, R4, R7};
	reactionnames = {'R1', 'R2', 'R3', 'R4',  'R7'};
	%}
	reactions = {R1, R2, R3, R5, R6};
	reactionnames = {'R1', 'R2', 'R3', 'R5', 'R6'};

	reactionsystem.name = reactionsystemname;
	reactionsystem.reactants = reactants;
	reactionsystem.input_reactants = input_reactants;
	reactionsystem.reactions = reactions;
	reactionsystem.reactionlabels = reactionnames;

	DAE = RRE_EqnEngine(reactionsystem);
end
