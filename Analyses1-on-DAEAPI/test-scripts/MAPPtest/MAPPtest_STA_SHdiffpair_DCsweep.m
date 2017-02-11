function test = STA_SHdiffpair_DCsweep()

    % Author: Bichen Wu
    % Date: 05/06/2014
    % Moved from test_STAEqnEngine_SH_MOSdiffpair_DC_AC_tran.m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE
    STAEqnEngine_SH_MOSdiffpair;
    DAE = feval(DAE.set_uQSS, 'Vin:::E', 0, DAE);
    DAE = feval(DAE.set_uQSS, 'vdd:::E', 5, DAE);
    DAE = feval(DAE.set_uQSS, 'IS:::I', 2e-3, DAE);
    test.DAE = DAE;
    test.name = 'STA_SHdiffpair_DCsweep'; % Type of analysis
    test.analysis = 'DCsweep'; % Type of analysis
    test.refFile = 'STA_SHdiffpair_DCsweep.mat';

    % Simulation time-related parameters
    test.args.NRparms = defaultNRparms();
    test.args.NRparms.maxiter = 100;
    test.args.NRparms.reltol = 1e-5;
    test.args.NRparms.abstol = 1e-10;
    test.args.NRparms.residualtol = 1e-10;
    test.args.NRparms.dbglvl = 0; % minimal output

    test.args.comparisonAbstol = 1e-9;
    test.args.comparisonReltol = 1e-3;
    test.args.initGuess = [ 5.0000; 4.9999; 1.0001; -0.7472; -1.0000; ...
                            5.0000; -1.0000; -0.7472; 0.0001; 0.0001; ...
                            3.9999; 3.9999; 5.7471; -0.2528; 1.7473; ...
                            0.7472; -0.0020; 0; 0.0020; 0.0000; 0;...
                            0.0020; 0; 0.0000; 0; 0.0020; 0];

    N = 21;
    VinMAX = 1;
    Vins = VinMAX*((0:N)/N*2-1); Vins = Vins';
    Vds = 5*ones(N+1,1);
    Is = 2e-3*ones(N+1,1);

    test.args.QSSInputs = [Vds, Vins, Is];

end

