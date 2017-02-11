function test = MAPPtest_BJTdiffpair_DAEAPIv6_DCsweep()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DC Sweep Test Case 1: BJT differential pair
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circuit DAE. 
    test.DAE =  BJTdiffpair_DAEAPIv6('BJTdiffpair_DAEAPIv6');
    test.name='BJTdiffpair_DAEAPIv6_DCsweep';
    %MNAEqnEngine_vsrc_diode; test.DAE = DAE;
    test.analysis = 'DCSweep'; % Type of analysis
    test.refFile = 'BJTDiffPairDCSweep.mat';

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

    % test.args.initGuess = feval(test.DAE.QSSinitGuess, test.DAE);
    test.args.initGuess = [3;3;-0.7;0];
    %test.args.initGuess=[1;0;0.6];

    test.args.QSSInputs = [-0.2:0.01:0.2]'; % CRITICAL: Should be a vector/column array
    %Temp line by Bichen 
    % test.whereToSaveData='/home/bichen/share/research/MAPP/MAPP-svn/bichen-branches/bichen-wkcpy-off-trunk-r130/Analyses1-on-DAEAPI/test-data/dataUpdate/';
    %test.whereToSaveData='./';
    %test.args.QSSInputs = -0.2 ;

    % HOW TO CREATE QSSInputs
    % EXAMPLE
    %                  DAEinput1  DAEinput2  DAEinput2  ...  DAEinputn  
    % QSSInputs = [      1.3          1.4        2.3    ...   5.4      ;  | --> step (1) init guess is test.arg.initGuess
    %                    1.4          1.4        2.3    ...   5.4      ;  | --> step (2) init guess is the solution from step 1
    %                    1.4          1.5        2.4    ...   5.6      ;  |
    %                    ...          ...        ...    ...   ...      ;  | --> Sweep through these values (steps)
    %                    1.4          1.5        3.3    ...   5.6      ;  | --> init guess for NR at nth step is the solution from (n-1)th step
    %                    1.3          1.5        3.4    ...   5.6      ;  |
    %             ];
    %
    % TIPS: Each row (other than first) should be numerically close (expand this?) its previous step.
    % Size(QSSInputs) = [ no. of sweep steps, no. of DAE inputs];

    % save it in the output structure
end
