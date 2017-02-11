function cktnetlist = BJTdiffpair_ckt()
%function cktnetlist = BJTdiffpair_ckt()
%This function returns a cktnetlist structure for a BJT differential pair
%circuit.
% 
%The circuit
%  An ideal-ish differential pair using Ebers Moll BJTs. The emitters of 2 BJTs
%  are connected at node nE (node voltage e_nE). An ideal current source of DC
%  value IE drains node E. The collector of the BJT on the left is connected to
%  node nCL; that of the one on the right to node nCR (node voltage e_nCR).
%  Resistors rL and rR connect from VCC to nodes nCL and nCR, respectively;
%  similarly with capacitors CL and CR. 
%  
%  The BJT on the left has its base connected to Vin; that of the one on the
%  right connects to ground. The circuit is, therefore, not perfectly
%  symmetric.
%
%  A sinusoidal transient input at frequency 1kHz is included in the circuit.
%
%Examples
%--------
%
% % set up DAE
% DAE =  MNA_EqnEngine(BJTdiffpair_ckt());
%
% % list all unknown names
% DAE.unknames(DAE) % equivalent to feval(DAE.unknames, DAE)
%
% % list all output names
% DAE.outputnames(DAE) % equivalent to feval(DAE.outputnames, DAE)
%
% % set up state outputs "manually"
% souts = StateOutputs(DAE);
% souts = souts.DeleteAll(souts);
% souts = souts.Add({'e_nCL', 'e_nCR', 'e_Vin', 'e_nE'}, souts);
%
% % run a DC operating point analysis
% dcop = dot_op(DAE);
% % print DC operating point
% feval(dcop.print, dcop);
%
% % run a DC DC sweep
% % feval(DAE.inputnames, DAE) shows 3 inputs: 'VCC:::E', 'Vin:::E', 'IE:::I'
% swp = dot_dcsweep(DAE, [], 'Vin:::E', -0.25:0.01:0.25);
% feval(swp.plot, swp);
%
% % get DC operating point solution vector
% qssSol = feval(dcop.getsolution, dcop);
%
% % AC analysis @ DC operating point; plot both DAE-defined and state outputs
% sweeptype = 'DEC'; fstart=1; fstop=1e5; nsteps=10;
% ltisss = dot_ac(DAE, qssSol, feval(DAE.uQSS, DAE), fstart, fstop,...
% nsteps, sweeptype);
% % plot frequency sweeps of system outputs
% feval(ltisss.plot, ltisss); % plot DAE-defined outputs
% feval(ltisss.plot, ltisss, souts); % plot state outputs
%
% % run transient and plot (both DAE-defined and state outputs)
% tstart = 0; tstep = 1e-5; tstop = 2e-3;
% TransObj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
% feval(TransObj.plot, TransObj); % plot DAE-defined outputs 
% feval(TransObj.plot, TransObj, souts); % plot state outputs
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts,

%
%Author: Tianshi Wang, 2012/11/20
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % ckt name
    cktnetlist.cktname = 'BJT diffpair with Vin- grounded';
    % nodes (names)
    cktnetlist.nodenames = {'nE', 'nCL', 'nCR', 'nCC', 'Vin'}; % non-ground 
                                % nodes
    cktnetlist.groundnodename = 'gnd';

    % circuit element values
    VCC = 5.0; % 5V
    VinDC = 0; % DC input value of Vin
    vinoft = @(t, args) args.A*sin(2*pi*args.f*t + args.phi); % transient 
                                                   % input function for Vin
    vinargs.A = 1; vinargs.f = 1e3; vinargs.phi = 0; % arguments for
                             % transient function
    IE = 2e-3;
    rL = 2000;
    rR = 2000;
    CL = 0.5e-6;
    CR = 0.5e-6;
    % BJT parameters (these are default values for EbersMoll_BJT_ModSpec.m)
    %{ 
    default values of the parameters are:
    IsF = 1e-12; VtF = 0.025;
    IsR = 1e-12; VtR = 0.025;
    alphaF = 0.99; alphaR = 0.5;
    %}
    IsF = 1e-12;
    alphaF = 0.99;

    %{
    vM = vsrcModSpec();
        DCval = 1.0;
        tranfuncargs.A = 1; tranargs.f = 1e3; tranargs.phi = 0;
    %}

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VCC', {'nCC', 'gnd'}, {},         {{'E' {'DC', VCC}}});
    %                         ^         ^            ^          ^          ^                  ^
    %                      cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient/AC values of internal sources
    %                                                 []=defaults,     optional args

    cktnetlist = add_element(cktnetlist, resModSpec(), 'rL', {'nCC', 'nCL'}, ...
                      {{'R', rL}}, {});
    cktnetlist = add_element(cktnetlist, resModSpec(), 'rR', {'nCC', 'nCR'}, ...
                  rR, {});
    cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', {'nCC', 'nCL'}, ...
                      {{'C', CL}});
    cktnetlist = add_element(cktnetlist, capModSpec(), 'CR', {'nCC', 'nCR'}, CR);
    cktnetlist = add_element(cktnetlist, EbersMoll_BJT_ModSpec(), 'QL', ...
                  {'nCL', 'Vin', 'nE'}, {{'IsF', IsF}, ...
                  {'alphaF', alphaF}});
    cktnetlist = add_element(cktnetlist, EbersMoll_BJT_ModSpec(), 'QR', ...
                  {'nCR', 'gnd', 'nE'}, {{'IsF', IsF}, ...
                  {'alphaF', alphaF}});
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'Vin', 'gnd'}, {},         {{'E', {'DC', VinDC}, {'AC' 1}, {'tr', vinoft, vinargs}}});
    %                               ^          ^           ^           ^        ^                    ^      ^        ^
    %                            cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient values of internal sources
    %                                                 []=defaults,     optional args
    cktnetlist = add_element(cktnetlist, isrcModSpec(), 'IE', {'nE', 'gnd'}, {},         {{'I', {'DC', IE}}});
    %                             ^          ^           ^           ^       ^                  ^      ^        ^
    %                          cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient values of internal sources
    %                                                 []=defaults,     optional args

    cktnetlist = add_output(cktnetlist, 'Vin');
    cktnetlist = add_output(cktnetlist, 'nE');
    cktnetlist = add_output(cktnetlist, 'nCL');
    cktnetlist = add_output(cktnetlist, 'nCR');
    cktnetlist = add_output(cktnetlist, 'nCL', 'nCR');
    cktnetlist = add_output(cktnetlist, 'i(Vin)', 1e5);


%    DAE = MNA_EqnEngine('BJTdiffpair', cktnetlist); % we do this elsewhere
end
