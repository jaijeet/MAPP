function test = MAPPtest_vsrc_diode_AC()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from run_SHdiffpair_ckt_DCop_AC_transient.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	MNAEqnEngine_vsrc_diode; % sets up DAE (DAEAPI script)
	constonefuncH = @(f, args) 1;
	DAE = feval(DAE.set_uLTISSS, 'v1:::E', constonefuncH, [], DAE);

    test.DAE = DAE;
    test.name='vsrc_diode_AC';
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'vsrc_diode_AC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE

    % test.args.initGuess=feval(test.DAE.QSSinitGuess, udcop, test.DAE);
    test.args.initGuess=[ 1; 0; 0.6];

    % Simulation-related parameters
    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e5; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
end
