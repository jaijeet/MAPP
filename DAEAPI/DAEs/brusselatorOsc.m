function DAE = brusselatorOsc()
%function DAE = brusselatorOsc()
% Brusselator oscillator
%author: J. Roychowdhury, 2012/06/10
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Reaction System (from Wikipedia's Brusselator page)
%
%	A       ->  X
%	2X + Y  ->  3X
%	B  + X  ->  Y + D
%	     X  ->  E
%
% only X and Y are dynamical reactants. A and B are inputs (also D and E, trivially)
%
% for unit rate constants on all reactions, this becomes an oscillator with
% a stable limit cycle when [B] > 1 + [A]^2.
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
	reactionsystemname = 'Brusselator';

	% reactants (names)
	reactants = {'X', 'Y', 'A', 'B', 'D', 'E'};

	% input reactants (names)
	input_reactants = {'A', 'B', 'D', 'E'};

	k = 1;

	% list of reactions
	% R1: A -> X
	R1.LHSstoichiometries = [0 0 1 0 0 0];
	R1.RHSstoichiometries = [1 0 0 0 0 0];
	R1.kF = k; R1.kR = 0;

	% R2: 2X + Y -> 3X
	R2.LHSstoichiometries = [2 1 0 0 0 0];
	R2.RHSstoichiometries = [3 0 0 0 0 0];
	R2.kF = k; R2.kR = 0;

	% R3: B + X -> Y + D
	R3.LHSstoichiometries = [1 0 0 1 0 0];
	R3.RHSstoichiometries = [0 1 0 0 1 0];
	R3.kF = k; R3.kR = 0;

	% R4: X -> E
	R4.LHSstoichiometries = [1 0 0 0 0 0];
	R4.RHSstoichiometries = [0 0 0 0 0 1];
	R4.kF = k; R4.kR = 0;

	reactions = {R1, R2, R3, R4};
	reactionnames = {'R1', 'R2', 'R3', 'R4'};

	reactionsystem.name = reactionsystemname;
	reactionsystem.reactants = reactants;
	reactionsystem.input_reactants = input_reactants;
	reactionsystem.reactions = reactions;
	reactionsystem.reactionlabels = reactionnames;

	DAE = RRE_EqnEngine(reactionsystem);

	% set inputs
	Aconc = 1;    % value taken from Wikipedia diagram
	Bconc = 2.5;  % value taken from Wikipedia diagram

	Atdfunc = @(t, args) Aconc;
	Btdfunc = @(t, args) Bconc;
	zerofunc = @(t, args) 0;

	DAE = feval(DAE.set_uQSS, '[A]', Aconc, DAE);
	DAE = feval(DAE.set_uQSS, '[B]', Bconc, DAE);
	DAE = feval(DAE.set_uQSS, '[D]', 0, DAE);
	DAE = feval(DAE.set_uQSS, '[E]', 0, DAE);

	DAE = feval(DAE.set_utransient, '[A]', Atdfunc, [], DAE);
	DAE = feval(DAE.set_utransient, '[B]', Btdfunc, [], DAE);
	DAE = feval(DAE.set_utransient, '[D]', zerofunc, [], DAE);
	DAE = feval(DAE.set_utransient, '[E]', zerofunc, [], DAE);

	DAE = feval(DAE.set_uHB, '[A]', Atdfunc, [], DAE);
	DAE = feval(DAE.set_uHB, '[B]', Btdfunc, [], DAE);
	DAE = feval(DAE.set_uHB, '[D]', zerofunc, [], DAE);
	DAE = feval(DAE.set_uHB, '[E]', zerofunc, [], DAE);
end
