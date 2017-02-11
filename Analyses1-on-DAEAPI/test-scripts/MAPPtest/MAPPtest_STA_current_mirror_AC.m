function test =  MAPPtest_STA_current_mirror_AC()

	% Author: Bichen Wu
	% Date: 05/06/2014
	% Moved from test_STAEqnEngine_current_mirror_DC_tran.m
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	test.DAE = STA_EqnEngine(current_mirror_ckt());
    test.name = 'STA_current_mirror_AC'; % Type of analysis
    test.analysis = 'AC'; % Type of analysis
    test.refFile = 'STA_current_mirror_AC.mat';
    % If the analysis is AC, then setup the uLTISSS for the
    % circuit DAE
    Ufargs.string = 'no args used'; % 
    Uffunc = @(f, args) 1; % constant U(j 2 pi f) \equiv 1
    %test.DAE = feval(test.DAE.set_uLTISSS,'I0:::I', Uffunc, Ufargs, test.DAE);
	%udcop = [0];
    %test.DAE = feval(test.DAE.set_uQSS, udcop, test.DAE);
    test.DAE = feval(test.DAE.set_uLTISSS, 'I0:::I',Uffunc, Ufargs, test.DAE);
	Xinit = zeros(feval(test.DAE.nunks, test.DAE),1);


    % Simulation-related parameters
    test.args.initGuess=Xinit;
    test.args.sweeptype = 'DEC'; % Sweeptype 
    test.args.fstart = 1; % Start frequency
    test.args.fstop = 1e10; % Stop frequency 
    test.args.nsteps = 50; % No. of steps

end
