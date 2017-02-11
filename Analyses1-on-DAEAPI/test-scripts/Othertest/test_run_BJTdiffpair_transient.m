%
% Test script to run transient analysis on a BJT differential pair 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up DAE 
% Important: The argument to function BJTdiffpair_DAEAPIv6 will be used to name
% the .mat file to store the reference data (in case of 'updateReference'/ load
% .mat file (in case of testing anc comparison)
DAE =  BJTdiffpair_DAEAPIv6('BJT-differential-pair');

% set transient input to the DAE
utargs.A = 0.2; utargs.f=1e2; utargs.phi=0; 
utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);

TRmethod = LMSmethods();
LMStranparms = defaultTranParms(); %TransObjBE.tranparms; % has tranparms.NRparms
LMStranparms.NRparms.limiting = 1;

% Set initial condition and simulation time parameters
simparms.xinit = [3; 3; -0.5]; % BE and TRAP both work
simparms.tstart = 0;
simparms.tstep = 10e-5; 
simparms.tstop = 5e-2;


% For updating, uncomment "if 2 ==1" and comment "if 1 ==1"
% For testing, uncomment "if 1 ==1" and comment "if 2==1"
if 1 ==2 
%if 2 == 1
        test_transient(DAE,'TRAP',simparms,LMStranparms);
else
        test_transient(DAE,'TRAP',simparms,LMStranparms,'updateReference');
end
