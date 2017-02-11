function DAE = Samoilov_ABC_RRE_system()
%author: J. Roychowdhury, 2014/03/28
% The "simple" system suggested by Michael Samoilov on 2014/04/27
% for trying DAE2FSM/ABCD on.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Reaction System
%	
%	A + Ain(t) + B(t) -> C
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
	reactionsystemname = 'Samoilov ABC system';

	% reactants (names)
	reactants = {'A', 'Ain', 'B', 'C'};

	% input reactants (names)
	input_reactants = {'B', 'Ain'};

	k = 1;

	% list of reactions
	% R1: A + Ain(t) + B(t) -> C
	R1.LHSstoichiometries = [1 1 1 0];
	R1.RHSstoichiometries = [0 0 0 1];
	R1.kF = k; R1.kR = 0;

	reactions = {R1};
	reactionnames = {'R1'};

	reactionsystem.name = reactionsystemname;
	reactionsystem.reactants = reactants;
	reactionsystem.input_reactants = input_reactants;
	reactionsystem.reactions = reactions;
	reactionsystem.reactionlabels = reactionnames;

	DAE = RRE_EqnEngine(reactionsystem);
end
