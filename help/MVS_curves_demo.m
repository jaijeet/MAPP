%Create circuit
%--------------
%1. First, we put an MVS NMOS in a circuit, with its gate and drain driven by
%   Vdd and Vgg respectively. Copy and paste the code below in the command
%   window:
%   >> clear cktnetlist;
%      cktnetlist.cktname = 'MVS MOS model: characteristic-curves';
%      cktnetlist.nodenames = {'drain', 'gate'};
%      cktnetlist.groundnodename = 'gnd';
%
%      % Vdd
%      cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vdd',...
%          {'drain', 'gnd'}, {}, {{'DC', 1}});
%
%      % Vgg
%      cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vgg',...
%          {'gate', 'gnd'}, {}, {{'DC', 1}});
%
%      % MVS NMOS with default parms
%      cktnetlist = add_element(cktnetlist, MVS_1_0_1_ModSpec, 'NMOS',...
%          {'drain', 'gate', 'gnd', 'gnd'});
%
%
%Initiate analyses
%-----------------
%1. set up DAE
%   >> DAE = MNA_EqnEngine(cktnetlist);
% 
%2. DC analysis
%   >> dcop = op(DAE);
%      dcop.print(dcop);
%      qssSol = dcop.getSolution(dcop);
% 
%3. double DC sweep using a for loop
%   >> VGBs = 0:0.1:1;
%      VDBs = -0.5:0.2:1.5;
%      IDs = zeros(length(VGBs), length(VDBs));
%
%      % list all circuit unknowns
%      DAE.unknames(DAE)
%
%      % find out Id's indice (current through vsrc) in solution vector
%      idx = unkidx_DAEAPI('Vdd:::ipn', DAE)
%      
%      % run DC sweep in a for loop
%      for c = 1:length(VGBs)
%          DAE = DAE.set_uQSS('Vgg:::E', VGBs(c), DAE);
%          swp = dcsweep(DAE, [], 'Vdd:::E', VDBs);
%          [pts, Sols] = swp.getsolution(swp);
%          IDs(c, :) = - Sols(idx, :);
%      end % Vgg
%      
%      % 3-D plot
%      figure; surf(VDBs, VGBs, IDs);
%      xlabel('Vdd (V)'); ylabel('Vgg (V)'); zlabel('Id (A)');
%      title('N-type MVS device: Id vs Vgs and Vds (DC analysis)');
%
%      % return to this demo
%      MVS_curves_demo;
%
%4. AC analysis
%   >> % list all circuit inputs
%      DAE.inputnames(DAE)
%      % set AC analysis input as a function of frequency
%      Ufargs.string = 'no args used'; 
%      Uffunc = @(f, args) 1; % constant U(j 2 pi f) = 1
%      DAE = feval(DAE.set_uLTISSS, 'Vgg:::E', Uffunc, Ufargs, DAE);
%
%      % run the AC analysis
%      sweeptype = 'DEC'; fstart=1e6; fstop=1e14; nsteps=10;
%      uDC = feval(DAE.uQSS, DAE);
%      ACobj = ac(DAE, qssSol, uDC, fstart, fstop, nsteps, sweeptype);
%
%      % plot frequency sweeps of system outputs (overlay all on 1 plot)
%      feval(ACobj.plot, ACobj);

help MVS_curves_demo;
