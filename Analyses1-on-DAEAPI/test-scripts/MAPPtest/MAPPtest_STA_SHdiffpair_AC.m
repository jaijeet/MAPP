function test = MAPPtest_STA_SHdiffpair_AC

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_STAEqnEngine_SH_MOSdiffpair_DC_AC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Circuit DAE. 
	STAEqnEngine_SH_MOSdiffpair;
	DAE = feval(DAE.set_uQSS, 'vdd:::E', 5, DAE);
	DAE = feval(DAE.set_uQSS, 'IS:::I', 2e-3, DAE);
    udcop = [0.2];
	DAE = feval(DAE.set_uQSS, 'Vin:::E', udcop, DAE);
	constfunc = @(f, args) 1;
	DAE = feval(DAE.set_uLTISSS, 'Vin:::E', constfunc, [], DAE);

    test.DAE = DAE;
    test.name='STA_SHdiffpair_AC';
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'STA_SHdiffpair_AC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE

    % Simulation-related parameters
    % test.args.initGuess=feval(test.DAE.QSSinitGuess, udcop, test.DAE);
    test.args.initGuess=[ 0.0119; 0.3371; 0.1622; 0.7943; 0.3112; 0.5285; 0.1656; ...
						  0.6020; 0.2630; 0.6541; 0.6892; 0.7482; 0.4505; 0.0838; ...
						  0.2290; 0.9133; 0.1524; 0.8258; 0.5383; 0.9961; 0.0782; ...
					      0.4427; 0.1067; 0.9619; 0.0046; 0.7749; 0.8173];




    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e5; % Stop frequency 
    test.args.nsteps = 10; % No. of steps
end
