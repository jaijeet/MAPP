function cktnetlist = crossCoupledLCoscSH_ckt()
%function cktnetlist = crossCoupledLCoscSH_ckt()
%This function returns a cktnetlist structure for a cross-coupled
%diffpair based LC oscillator made of Shichman Hodges MOS devices. 
%
%It is built on SHdiffpair_ckt.m.
%
%Examples
%--------
%
%   DAE = MNA_EqnEngine(crossCoupledLCoscSH_ckt());
%   if 0 == 1 % the DAE's L and C leads to a very difficult to solve
%             % periodic problem. See the notes within this block.
%      DAE = DAE.setparms('rLR', 1e10, DAE);
%      OP = op(DAE);
%      xDC = OP.getsolution(OP);
%      uDC = DAE.uDC(DAE);
%      
%      G = DAE.df_dx(xDC, uDC, DAE);
%      C = DAE.dq_dx(xDC, DAE);
%      A = inv(G)*C;
%      eig(A) % look for unstable poles and their real parts
%   
%      if 0 == 1
%          % L=1e-8 (as 2 series lL and lR) and C=0.5e-7 leads to a very
%          % interesting situation where the
%          % real and imaginary parts of the oscillatory eigenmode are very
%          % widely separated:  -3.535527845273293e-10 + 9.999941000040222e-08i.
%          % With a stiffly stable method, therefore, we need to take steps
%          % smaller than 3.535527845273293e-10 (say 1e-11), else the growing
%          % oscillatory mode will be falsely stablized. But the time period of
%          % oscillation is 2*pi times the imaginary part, ie, 6.28e-7. This is
%          % a separation of about 5 orders of magnitude => 100000 timesteps
%          % per cycle! But unless such small timesteps are used,
%          % transient/shooting will find only the DC % solution. (Try it).
%          %
%          % This does the job:
%          TR = transient(DAE, xDC + [-1;-1;-0.5;0;0;0;0], 0, 1e-11, 7e-7, 0); 
%          % it takes a very long time, but shows oscillation with a period
%          % of about 6.25e-7. 
%          %
%          % We can't use TRAP with larger timesteps because this is a DAE and
%          % the randomly chosen initial condition above leads to fake DAE
%          % oscillation of "algebraic" nodes.
%      else
%          % xinit captured from the end of the above long simulation:
%          % this should be DAE-consistent, so we can use the perfectly
%          % A-stable TRAP with longer timesteps.
%          xinit = [4.017094661154794e+00; ...
%                   4.806598327876282e+00; ...
%                   5.193401565993343e+00; ...
%                   5.000000000000000e+00; ...
%                   -1.000000000922323e-02; ...
%                   3.410938639128560e-01; ...
%                   -3.310938639036328e-01]
%          TR = transient(DAE, xinit, 0, 1e-9, 1e-6, 0, 'method', 'TRAP'); 
%          TR2 = transient(DAE, xinit, 0, 1e-8, 1e-6, 0, 'method', 'GEAR2'); 
%      end
%      TR.plot(TR);
%      TR2.plot(TR2);
%   
%      SHparms = defaultShootingParms();
%      SHparms.Nsteps = 3000; % 6.28e-7/3000 ~ 2.0e-10 < 3.5e-10 (real part of
%                             % oscillatory eigenmode).                     
%      TRmethods = LMSmethods();
%      SHparms.TRmethod = TRmethods.GEAR2; % TRAP makes the DAE modes
%                                          % persist exactly, resulting in
%                                          % fake oscillatory modes which are
%                                          % probably messing with the shooting
%                                          % NR. Stiffly stable methods zero out
%                                          % the DAE modes.
%      SHparms.tranparms.stepControlParms.doStepControl = 0; % do not increase step
%      % relax periodicity_reltol and abstol
%      SHparms.NRparms.reltol = 1e-3;
%      SHparms.NRparms.abstol = 1e-8;
%      SH = Shooting(DAE, SHparms, 1);
%      SH = SH.solve(SH, xinit, 6.2893e-07); % this is a tough one - shooting
%                                            % seems to find only the DC solution
%      SH.plot(SH)
%   end % 0 == 1
%
%   % making L larger and C smaller seems to reduce the difference between
%   % the real and imaginary parts of the unstable DC eigenvalue; the
%   % oscillator starts up strongly. Makes sense since the increased
%   % inductance should make the voltages at nDL and nDR swing more; reducing
%   % C allows less current to bleed away through it.
%   DAE = DAE.setparms('lR', 0.5e-6, DAE);
%   DAE = DAE.setparms('lL', 0.5e-6, DAE);
%   DAE = DAE.setparms('C', 1e-10, DAE);
%
%   OP = op(DAE);
%   xDC = OP.getsolution(OP);
%   uDC = DAE.uDC(DAE);
%   
%   G = DAE.df_dx(xDC, uDC, DAE);
%   C = DAE.dq_dx(xDC, DAE);
%   A = inv(G)*C;
%   eig(A) % look for unstable poles and their real parts
%   
%   T = 5.879733600659896e-08; % from the DC eigenvalue - works (8 NR iters)
%   T = 6.283185307179586e-08; % 2*pi*sqrt(L*C) % 13 NR iters!
%   TR = transient(DAE, xDC + [-1;-1;-0.5;0;0;0;0], 0, T/100, 10*T, 0); 
%   TR.plot(TR);
%   [tpts, vals] = TR.getsolution(TR);
%
%   xinit = vals(:, end);
%
%   SHparms = defaultShootingParms();
%   SHparms.Nsteps = 250; 
%   TRmethods = LMSmethods();
%   SHparms.TRmethod = TRmethods.GEAR2; 
%   SHparms.tranparms.stepControlParms.doStepControl = 0; % do not increase step
%   %SHparms.NRparms.reltol = 1e-3;
%   %SHparms.NRparms.abstol = 1e-8;
%   SH = Shooting(DAE, SHparms, 1);
%   SH = SH.solve(SH, xinit, T); 
%   SH.plot(SH);
%   SH.plot(SH, StateOutputs(DAE));
%   
%   SHsol = SH.getsolution(SH);
%   M = SHsol.MonodromyMatrixAtSolution(1:7, 1:7);
%   eig(M) % Floquet multipliers
%   

%
% Author: Jaijeet Roychowdhury, 2016/03/06
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % ckt name
    cktnetlist.cktname = 'cross-coupled LC oscillator with SH MOS devices';
    % nodes (names)
    cktnetlist.nodenames = {'nS', 'nDL', 'nDR', 'nDD'}; % non-ground 
                                % nodes
    cktnetlist.groundnodename = 'gnd';

    % circuit element values
    VDD = 5.0; % 5V
    IS = 10e-3; % 10mA
    lL = 0.5e-7; % 
    lR = 0.5e-7; % 
    C = 1e-7; % 0.1uF
    % natural frequency of osc ~1.59Mhz with these parameters.
    rLR = 1e3; % Q factor = R/sqrt(L/C) (ie, R/char impedance) = R/0.1


    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VDD', {'nDD', 'gnd'}, {},         {{'E' {'DC', VDD}}});
    %                             ^         ^            ^          ^          ^                  ^
    %                          cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient/AC values of internal sources
    %                                                     []=defaults,     optional args

    cktnetlist = add_element(cktnetlist, indModSpec(), 'lL', {'nDD', 'nDL'}, lL);
    cktnetlist = add_element(cktnetlist, indModSpec(), 'lR', {'nDD', 'nDR'}, lR);
    cktnetlist = add_element(cktnetlist, capModSpec(), 'C', {'nDL', 'nDR'}, C);
    cktnetlist = add_element(cktnetlist, resModSpec(), 'rLR', {'nDL', 'nDR'}, rLR);
    cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'ML', ...
                  {'nDL', 'nDR', 'nS'}, {{'Beta', 2e-2}});
    cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'MR', ...
                  {'nDR', 'nDL', 'nS'}, {{'Beta', 2e-2}});
    cktnetlist = add_element(cktnetlist, isrcModSpec(), 'IS', {'nS', 'gnd'}, {},         {{'I', {'DC', IS}}});
    %                        ^          ^           ^           ^       ^                  ^      ^        ^
    %                     cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient values of internal sources
    %                                                 []=defaults,     optional args
    cktnetlist = add_output(cktnetlist, 'nDL', 'nDR', 'nDL-nDR');
    cktnetlist = add_output(cktnetlist, 'nS');
end
