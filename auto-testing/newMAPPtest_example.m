function newTest = newMAPPtest_example()
    % Circuit DAE. 
    MNAEqnEngine_vsrc_diode;
    newTest.DAE =  DAE;
    newTest.analysis = 'AC'; % Type of analysis
    newTest.refFile = 'vsrcDiodeAC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE
    Ufargs.string = 'no args used'; % 
    Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
    newTest.DAE = feval(newTest.DAE.set_uQSS, [1], newTest.DAE);
    newTest.DAE = feval(newTest.DAE.set_uLTISSS, 'v1:::E', Uffunc, Ufargs, newTest.DAE);

    % Simulation-related parameters
    newTest.args.initGuess=[1;0;0.6];
    newTest.args.sweeptype = 'DEC'; % Sweeptype 
    newTest.args.fstart = 1; % Start frequency
    newTest.args.fstop = 1e18; %2; % Stop frequency 
    newTest.args.nsteps = 5; %5 20; % No. of steps
    %Necessary when running MAPPtest in update mode. Ortherwise the data is
    %saved in the current dir.
    newTest.whereToSaveData='/home/bichen/share/research/MAPP/MAPP-svn/bichen-branches/off-trunk-r144/Analyses1-on-DAEAPI/test-data/';
    newTest.name='vsrcDiode_AC';

