%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2009/sometime
% Test script for running transient analysis for a parallel LC circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






useProvidedFE = 0; % 1 => try out the provided FE implementation
tstart = 0; tstop = 2e-6;  tstep = 1.5e-9; % fill tstep in

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DO NOT CHANGE THIS SECTION %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "Read in" the DAE
DAE = parallelLC('||rlcdiode'); 

% set input

% set initial conditions for transient
%xinit(1) = -3; % Volts
xinit = [];
xinit(1) = 0.5; % Volts
xinit(2) = 0;  % Amps
xinit = reshape(xinit, [],1); % making sure xinit is a column vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% END: DO NOT CHANGE THIS SECTION %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create transient analysis objects for BE, FE, TRAP
if (0 == useProvidedFE)
	% this is how JR's implementation is exercised. Yours could be similar.
	TransObjBE = LMS(DAE); % default method is BE
	TRmethod = TransObjBE.TRmethod; LMStranparms = TransObjBE.tranparms;
	LMStranparms.stepControlParms.doStepControl = 0; % uniform timesteps only.
	TransObjFE = LMS(DAE,TransObjBE.FEparms, LMStranparms); 
	TransObjTRAP = LMS(DAE,TransObjBE.TRAPparms, LMStranparms); 
else
	% the supplied FE code can be called like this
	TransObjFE = FE(DAE);
end


% run timestepping using transient objects
if (0 == useProvidedFE)
	TransObjBE = feval(TransObjBE.solve, TransObjBE, xinit, tstart, ...
				tstep, tstop);
	TransObjFE = feval(TransObjFE.solve, TransObjFE, xinit, tstart, ...
				tstep, tstop);
	TransObjTRAP = feval(TransObjTRAP.solve, TransObjTRAP, xinit, ...
				tstart, tstep, tstop);
else
	TransObjFE = feval(TransObjFE.solve, TransObjFE, xinit, tstart, ...
				tstep, tstop);
end

% plot waveforms
  % note: method plot is not implemented for the provided FE example,
  % but you should implement a plot method for your LMS routine, similar
  % in calling syntax to the lines below.
if (0 == useProvidedFE)
	% BE plots
	[thefig, legends] = feval(TransObjBE.plot, TransObjBE, [], 'BE'); % BE
	% FE plots, overlaid
	[thefig, legends] = feval(TransObjFE.plot, TransObjFE,  [], 'FE', 'rx-', ...
					thefig, legends); 
	% TRAP plots, overlaid
	[thefig, legends] = feval(TransObjTRAP.plot, TransObjTRAP, [], ...
					'TRAP', 'ko-', thefig, legends); 
	title('BE, FE and TRAP on parallelRLCdiode');
end
