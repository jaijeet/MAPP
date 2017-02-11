function test = MAPPtest_MNA_DAAV6_AC()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_MNAEqnEngine_DAAV6_P_N_AC.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    % Circuit DAE. 
	MNAEqnEngine_DAAV6_P_N_devices; % DAEAPI script that sets up DAE
	DAE = feval(DAE.set_uQSS, 'vgsN:::E', 1.2, DAE);
	DAE = feval(DAE.set_uQSS, 'vgsP:::E', 1.2, DAE);

	DAE = feval(DAE.set_uQSS, 'vddP:::E', 1.2, DAE);
	DAE = feval(DAE.set_uQSS, 'vddN:::E', 1.2, DAE);

	constonefuncH = @(f, args) 1;
	DAE = feval(DAE.set_uLTISSS, 'vgsN:::E', constonefuncH, [], DAE);
	DAE = feval(DAE.set_uLTISSS, 'vgsP:::E', constonefuncH, [], DAE);



    test.DAE = DAE;
    test.name='MNA_DAAV6_AC';
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'MNA_DAAV6_AC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE

    % Simulation-related parameters
    % test.args.initGuess=feval(test.DAE.QSSinitGuess, udcop, test.DAE);
    test.args.initGuess=[ 1.2000; 1.2000; 1.2000; 0; -0.0009; -0.0016; 0; 0; ...
						  1.0709; 0.1291; -1.0808; -0.1192];


    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e15; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
end
