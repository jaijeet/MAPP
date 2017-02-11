function test = MAPPtest_STA_vsrc_diode_AC

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_STAEqnEngine_vsrc_diode_DC_AC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	STAEqnEngine_vsrc_diode; % sets up DAE (DAEAPI script)
	constonefuncH = @(f, args) 1;
	DAE = feval(DAE.set_uLTISSS, 'v1:::E', constonefuncH, [], DAE);


	DAE = feval(DAE.set_uQSS, 'v1:::E', 1, DAE);
    test.DAE = DAE;
    test.name='STA_vsrc_diode_AC';
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'STA_vsrc_diode_AC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE

    % Simulation-related parameters
    % test.args.initGuess=feval(test.DAE.QSSinitGuess, udcop, test.DAE);
    test.args.initGuess= [1; 1; 1; 1; 0; 0.6];

    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e18; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
end
