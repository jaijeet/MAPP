function test = MAPPtest_MNA_MVS_1_0_1_char_curves_DCsweep()


	% Moved from MAPPtest_MNA_MVS_char_curves_DCsweep
	% which is moved from test_MNAEqnEngine_MVS_char_curves.m
	% original author: Bichen Wu
	% Date: 05/06/2014
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 

%Changelog:
%---------
%2014-06-19: Tianshi Wang <tianshi@berkeley.edu>: changed from MVSModSpec to
%                                                 MVS_1_0_1
%2014-05-06: Bichen Wu <bichen@berkeley.edu>:
%                                       MAPPtest_MNA_MVS_char_curves_DCsweep
%

    DAE = MNA_EqnEngine( MVS_char_curves_ckt);
	
	VDBs = -0.5:0.2:1.5; VDBs = VDBs.';
	VGBs = 0.5*ones(length(VDBs),1); %TODO: no 2D sweep testing?
    test.args.QSSInputs = [VDBs, VGBs];
	test.args.initGuess = [];

    test.DAE = DAE;
    test.name='MNA_MVS_1_0_1_DCsweep';
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'MNA_MVS_1_0_1_DCSweep.mat';

    % Simulation time-related parameters
    test.args.NRparms = defaultNRparms();
    test.args.NRparms.maxiter = 100;
    test.args.NRparms.reltol = 1e-5;
    test.args.NRparms.abstol = 1e-10;
    test.args.NRparms.residualtol = 1e-10;
    test.args.NRparms.limiting = 0;
    test.args.NRparms.dbglvl = 0; % minimal output

    test.args.comparisonAbstol = 1e-9;
    test.args.comparisonReltol = 1e-3;

   end
