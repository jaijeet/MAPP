function cktnetlist = BJT_with_cap_diffpair_ckt()
%function cktnetlist = BJT_with_cap_diffpair_ckt()
%This function returns a cktnetlist structure for a differential pair circuit
% 
%The circuit
%  An ideal-ish differential pair using Ebers Moll BJTs. The emitters of 2 BJTs
%  are connected at node nE (node voltage eE). An ideal current source of DC
%  value IE drains node E. The collector of the BJT on the left is connected to
%  node nCL; that of the one on the right to node nCR (node voltage eCR).
%  Resistors rL and rR connect from VCC to nodes nCL and nCR, respectively;
%  similarly with capacitors CL and CR. 
%  
%  The BJT on the left has its base connected to Vin; that of the one on the
%  right connects to ground. The circuit is, therefore, not perfectly
%  symmetric.
%
%Examples
%--------
%
% % set up DAE %
% DAE =  MNA_EqnEngine(BJT_with_cap_diffpair_ckt());
%
% % DC analysis %
% dcop = dot_op(DAE);
% % print DC operating point %
% feval(dcop.print, dcop);
% % get DC operating point solution vector %
% qssSol = feval(dcop.getsolution, dcop);
%
% % AC analysis @ DC operating point %
% sweeptype = 'DEC'; fstart=1; fstop=1e5; nsteps=10;
% ltisss = dot_ac(DAE, qssSol, feval(DAE.uQSS, DAE), fstart, fstop,...
% nsteps, sweeptype);
% % plot frequency sweeps of system outputs %
% feval(ltisss.plot, ltisss);
%
% % run transient and plot %
% tstart = 0; tstep = 1e-5; tstop = 2e-3;
% TransObj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
% feval(TransObj.plot, TransObj);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]

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
    IE = 2e-3; % 2mA
    rL = 2000; % 2kOhms
    rR = 2000; % 2kOhms
    CL = 1e-6; % 1uF
    CR = 1e-6; % 1uF
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
    cktnetlist = add_element(cktnetlist, EbersMoll_BJT_With_Capacitor_ModSpec(), 'QL', ...
                  {'nCL', 'Vin', 'nE'}, {{'IsF', IsF}, ...
                  {'alphaF', alphaF}});
    cktnetlist = add_element(cktnetlist, EbersMoll_BJT_With_Capacitor_ModSpec(), 'QR', ...
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

%    DAE = MNA_EqnEngine('BJTdiffpair', cktnetlist); % we do this elsewhere
end
