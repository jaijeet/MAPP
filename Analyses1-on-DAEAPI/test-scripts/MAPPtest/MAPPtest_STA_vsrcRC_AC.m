function test = MAPPtest_STA_vsrcRC_AC

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_STAEqnEngine_vsrcRC_DC_AC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	STAEqnEngine_vsrcRC; % sets up DAE (a DAEAPI script)
	constonefuncH = @(f, args) 1;
	DAE = feval(DAE.set_uLTISSS, 'v1:::E', constonefuncH, [], DAE);


    test.DAE = DAE;
    test.name='STA_vsrcRC_AC';
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'STA_vsrcRC_AC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE

    % test.args.initGuess=feval(test.DAE.QSSinitGuess, udcop, test.DAE);
    test.args.initGuess=[];

    % Simulation-related parameters
    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e5; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
end
