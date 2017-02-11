function test10 = MAPPtest_MNAEqnEngine_vsrc_diode_AC()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %AC Test Case 4: vsrc-diode
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    MNAEqnEngine_vsrc_diode;
    test10.DAE =  DAE;
    test10.name='MNAEqnEngine_vsrc_diode: AC';
    test10.analysis = 'AC'; % Type of analysis
    test10.refFile = 'vsrcDiodeAC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE
    Ufargs.string = 'no args used'; % 
    Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
    test10.DAE = feval(test10.DAE.set_uQSS, [1], test10.DAE);
    test10.DAE = feval(test10.DAE.set_uLTISSS, 'v1:::E', Uffunc, Ufargs, test10.DAE);

    % Simulation-related parameters
    test10.args.initGuess=[1;0;0.6];
    test10.args.sweeptype = 'DEC'; % Sweeptype 
    test10.args.fstart = 1; % Start frequency
    test10.args.fstop = 1e18; %2; % Stop frequency 
    test10.args.nsteps = 5; %5 20; % No. of steps
    % test10.whereToSaveData='/home/bichen/share/research/MAPP/MAPP-svn/bichen-branches/bichen-wkcpy-off-trunk-r130/Analyses1-on-DAEAPI/test-data/dataUpdate/';
	% TODO: above is commented by tianshi, easiest way for the moment is use current directory to save data
end
