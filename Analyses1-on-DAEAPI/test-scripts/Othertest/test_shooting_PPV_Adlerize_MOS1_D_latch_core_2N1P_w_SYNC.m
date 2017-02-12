%Author: Jaijeet Roychowdhury <jr@berkeley.edu> 2012/05/sometime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: J. Roychowdhury.
% Copyright (C) 2008-2012 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Changelog
%---------
%2014/07/15: Tianshi Wang <tianshi@berkeley.edu>: changed to
%                MOS1_D_latch_core_2N1P
%2011/05/sometime: Jaijeet Roychowdhury <jr@berkeley.edu>

DAE = MNA_EqnEngine(MOS1_D_latch_core_2N1P_w_SYNC_ckt);

% set DC and transient inputs for VDD
DAE = feval(DAE.set_uQSS, 'Vdd:::E', 3, DAE);
DAE = feval(DAE.set_uQSS, 'V1:::E', 3, DAE);
DAE = feval(DAE.set_uQSS, 'V2:::E', 0, DAE);
DAE = feval(DAE.set_uQSS, 'ISYNC:::I', 0, DAE);

% set up oscillator shooting with default parms
isOsc = 1;
shootparms = defaultShootingParms();
TRmethods = LMSmethods();
shootparms.TRmethod = TRmethods.GEAR2;
shootparms.Nsteps = 400; % 100, 200, 300, 400 all flatten out the PSS response
                         % using GEAR2
shoot = Shooting(DAE, shootparms, isOsc);

% run shooting with initial guess
% xinit = [3.000000000000000
%          2.472486791582520
%          2.449129771463976
%          0.317134890019311
%          0.305597076749999
%          3.000000000000000
%          0
%          1.639167010823606
%          0.588453618970799
%          1.501480701671551
%          1.200000000000000
%          1.824162263860840
%          1.797621035981672
%          -0.002112286673780
%          -0.000003563144655
%          0.000005527764436];
% xinit =[3.000000000000000
%         1.892302620302889
%         1.884820688543712
%         2.031938758531582
%         0.000014071079205
%         3.000000000000000
%         0
%         1.653244142805435
%         0.445303717862608
%         1.500600344287899
%         1.200000000000000
%         1.630767540100963
%         1.620669201867841
%         -0.001946181072472
%         -0.000004149189272
%         0.000004941719818];
xinit =[3.000000000000000
        2.244942672690298
        2.227897355731930
        1.099566280931969
        0.041456070337620
        3.000000000000000
        -0.000000000000000
        1.643461703374733
        0.531559821454852
        1.501135560224695
        1.200000000000000
        1.748320574638348
        1.728247605163640
        -0.001963308402312
        -0.000003792967956
        0.000005297941135];
% xinit = zeros(DAE.nunks(DAE), 1);
% xinit(2) = 3;
T = 8.293748767457602e-05;

shoot = feval(shoot.solve, shoot, xinit, T);

souts = StateOutputs(DAE);

% plot results
[thefig, legends] = feval(shoot.plot, shoot, souts);

% compute the PPV
shootsol = feval(shoot.getsolution, shoot);
ppv = compute_PPV_TD(shootsol, DAE);

% plot the PPV
feval(ppv.plot, ppv);

% Adlerization
b_FD_twoD = zeros(4, 7);
b_FD_twoD(1, :) = [0 0 0 0 0 0 0];
% b_FD_twoD(2, :) = [-1.5 -1.5/2 0 0 -1.5/2 0 0];
b_FD_twoD(2, :) = [0 0 0 0 0 0 0];
% b_FD_twoD(3, :) = [1.5 1.5/2 0 0 1.5/2 0 0];
b_FD_twoD(3, :) = [0 0 0 0 0 0 0];
b_FD_twoD(4, :) = 100e-6*[0 0 1 0 0 1 0];
adler = Adlerize(ppv, b_FD_twoD, 12e3); 
[fig, titlestr, labels] = feval(adler.plot, adler);
figure(fig); hold on;
titlestr = sprintf('\n%s', titlestr);
title(titlestr);

%{
trans = run_transient_GEAR2(adler.AdlerDAE, 0.9, 0,  1e-6, 4*3e-4);
fig = feval(trans.plot, trans);
figure(fig);
title('OBSOLETE: Adlerized DAE for 2nd-harmonic IL, amplitude 1.2e-2: transient with IC=0.9');

trans = run_transient_GEAR2(adler.AdlerDAE, 0.4, 0,  1e-6, 4*3e-4);
fig = feval(trans.plot, trans);
figure(fig);
title('Adlerized DAE for 2nd-harmonic IL, amplitude 1.2e-2: transient with IC=0.4');

b_FD_twoD = [0 0 0 0 0 0 0; 0 0 1 0 0 1 0; 0 0 1 0 0 1 0]; adler = Adlerize(ppv, b_FD_twoD*1.5, 16e3); 
[fig, titlestr, labels] = feval(adler.plot, adler);
figure(fig); hold on;
titlestr = sprintf('2nd-harmonic injection, amplitude 1.0e-2\n%s', titlestr);
title(titlestr);

trans = run_transient_GEAR2(adler.AdlerDAE, 0.9, 0,  1e-6, 4*3e-4);
fig = feval(trans.plot, trans);
figure(fig);
title('Adlerized DAE for 2nd-harmonic IL, amplitude 1.0e-2: transient with IC=0.9');
%}
