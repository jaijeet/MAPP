function cktnetlist = MVSxCoupledDiffpairIsrc_ckt()
%function cktnetlist = MVSxCoupledDiffpairIsrc_ckt()
%This function returns a cktnetlist structure for a cross-coupled
% differential pair circuit made of MVS 1.0.1 MOS devices. 
%
%The circuit
%   A cross-coupled ideal-ish differential pair using MVS MOS devices. The 
%   source nodes of 2 N-type MOSFETs are connected at node nS (node voltage
%   e_nS). 
%   An ideal current source of DC value IS drains node S. The drain of the
%   MOSFET on the left is connected to node nDL (node voltage e_nDL); that of
%   the one on the right to node nDR (node voltage e_nDR). Resistors rL and rR
%   connect from VDD to nodes nDL and nDR, respectively; similarly with
%   capacitors CL and CR. The gate of the transistor on the right is connected
%   to the drain of the transistor on the left, and vice-versa -- this is
%   cross coupling. There is a current source Iin between the two drain (or
%   gate) nodes. The voltage across this current source should exhibit
%   hysteresis as the current is swept.
%
%Examples
%--------
%
% DAE =  MNA_EqnEngine(MVSxCoupledDiffpairIsrc_ckt());
%
% % This ckt has DC convergence problems at Iin=-1e-3. The following initguess
% % was found by running a homotopy to -1e-3 starting from 0, as follows:
% % hom = homotopy(DAE, 'Iin:::I', 'input', [], 0, 5e-5, 1e-3, [], 1e-3, -1e-3);
% % homsol = feval(hom.getsolution, hom);
% % initguess = homsol.yvals(1:(end-1),end)
%
% initguess = [ ...
%   0.7520; ...
%   5.0366; ...
%   0.9634; ...
%   5.0000; ...
%  -0.0020; ...
%   4.1844; ...
%   0.1002; ...
%   0.1116; ...
%   0.0998 ...
%   ]
%
% % homotopy wrt an input (Iin)
% hom = homotopy(DAE, 'Iin:::I', 'input', initguess, -1e-3, 5e-5, 1e-3);
% feval(hom.plot, hom);
% souts = StateOutputs(DAE);
% feval(hom.plot, hom, souts);
%
% %% homotopy wrt parameters: 
% % the following init guess (upper bistable state) obtained by 
% % hom = homotopy(DAE, 'Iin:::I', 'input', initguess, -1e-3, 5e-5, 0);
% stateUP = [...
%   1.7863; ...
%   3.8817; ...
%   2.1183; ...
%   5.0000; ...
%  -0.0020; ...
%   2.0395; ...
%   0.0559; ...
%   0.1879; ...
%   0.1441...
%   ];
%
% % lambda = 'ML:::Rs0' (from default 100 up to 3Kohms)
% DAE = MNA_EqnEngine(MVSxCoupledDiffpairIsrc_ckt());
% DAE = feval(DAE.set_uQSS, 'Iin:::I', 0, DAE);
% homMLRs = homotopy(DAE, 'ML:::Rs0', 'param', stateUP, 200, 0.5, 220, 10);
% feval(homMLRs.plot, homMRRs, souts);
%
% % lambda = 'ML:::W' (from default 1e-4 to 1e-6): not very interesting
% homMLW = homotopy(DAE, 'ML:::W', 'param', initguess, 1e-4, 0.5e-6, 1e-6);
% feval(homMLW.plot, homMLW, souts);
%
% DAE = feval(DAE.set_uQSS, 'Iin:::I', -1e-3, DAE);
% homRR = homotopy(DAE, 'rR:::R', 'param', initguess, 2000, 10, 100, 100);
% feval(homRR.plot, homRR, souts);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts,
%
% Author: Jaijeet Roychowdhury, 2015/06/15 (copied MVSdiffpair_ckt and modified)
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % MOS model
	MVS_Model = MVS_1_0_1_ModSpec_vv4(); % swp = dcsweep(DAE, [], 'Vin:::E',
                                       % -3:0.12:3) takes 4.022s
	%MVS_Model = MVS_1_0_1_ModSpec; % swp = dcsweep(DAE, [], 'Vin:::E',
                                     % -3:0.12:3) takes 23.46s
	% MVS_Model = MVS_1_0_1_ModSpec_wrapper; % swp = dcsweep(DAE, [], 
                                             % 'Vin:::E', -3:0.12:3) takes 17.5s
	% ckt name

    % ckt name
    cktnetlist.cktname = 'MOS (MVS) cross coupled diffpair';
    % nodes (names)
    cktnetlist.nodenames = {'nS', 'nDL', 'nDR', 'nDD'}; % non-ground 
                                % nodes
    cktnetlist.groundnodename = 'gnd';

    % circuit element values
    VDD = 5.0; % 5V
    IinDC = 0; % DC input value of Vin
    iinoft = @(t, args) args.A*sin(2*pi*args.f*t + args.phi); % transient 
                                                   % input function for Iin
    iinargs.A = 1e-3; iinargs.f = 1e3; iinargs.phi = 0; % arguments for
                             % transient function
    IS = 2e-3; % 2mA
    rL = 2000; % 2kOhms
    rR = 2000; % 2kOhms
    CL = 1e-7; % 0.1uF
    CR = 1e-7; % 0.1uF

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VDD', {'nDD', 'gnd'}, {},         {{'E' {'DC', VDD}}});
    %                             ^         ^            ^          ^          ^                  ^
    %                          cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient/AC values of internal sources
    %                                                     []=defaults,     optional args

    cktnetlist = add_element(cktnetlist, resModSpec(), 'rL', {'nDD', 'nDL'}, ...
                      {{'R', rL}}, {});
    cktnetlist = add_element(cktnetlist, resModSpec(), 'rR', {'nDD', 'nDR'}, ...
                  rR, {});
    cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', {'nDD', 'nDL'}, ...
                      {{'C', CL}});
    cktnetlist = add_element(cktnetlist, capModSpec(), 'CR', {'nDD', 'nDR'}, CR);
    cktnetlist = add_element(cktnetlist, MVS_Model, 'ML', ...
                  {'nDL', 'nDR', 'nS', 'nS'}, ...
                  {{'Type', 1}, {'W', 1e-4}, {'Lgdr', 32e-7}, {'dLg', 9e-7}, ...
                   {'Cg', 2.57e-6}, {'Beta', 1.8}, {'Alpha', 3.5}, {'etov', 1.3e-3}, ...
                   {'Cif', 0}, {'Cof', 0}, {'phib', 1.2}, {'Gamma', 0}, {'mc', 0.2}, ...
                   {'CTM_select', 1}, {'Rs0', 100}, {'Rd0', 100}, {'n0', 1.68}, ...
                   {'nd', 0.1}, {'vxo', 1.2e7}, {'Mu', 200}, {'Vt0', 0.4}, {'delta', 0.15}...
                  });
    cktnetlist = add_element(cktnetlist, MVS_Model, 'MR', ...
                  {'nDR', 'nDL', 'nS', 'nS'}, ...
                  {{'Type', 1}, {'W', 1e-4}, {'Lgdr', 32e-7}, {'dLg', 9e-7}, ...
                   {'Cg', 2.57e-6}, {'Beta', 1.8}, {'Alpha', 3.5}, {'etov', 1.3e-3}, ...
                   {'Cif', 0}, {'Cof', 0}, {'phib', 1.2}, {'Gamma', 0}, {'mc', 0.2}, ...
                   {'CTM_select', 1}, {'Rs0', 100}, {'Rd0', 100}, {'n0', 1.68}, ...
                   {'nd', 0.1}, {'vxo', 1.2e7}, {'Mu', 200}, {'Vt0', 0.4}, {'delta', 0.15}...
                  });
    cktnetlist = add_element(cktnetlist, isrcModSpec(), 'Iin', {'nDL', 'nDR'}, {},         {{'I', {'DC', IinDC}, {'AC' 1}, {'tr', iinoft, iinargs}}});
    %                              ^          ^           ^           ^        ^                    ^      ^        ^
    %                           cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient values of internal sources
    %                                                         []=defaults,     optional args
    cktnetlist = add_element(cktnetlist, isrcModSpec(), 'IS', {'nS', 'gnd'}, {},         {{'I', {'DC', IS}}});
    %                        ^          ^           ^           ^       ^                  ^      ^        ^
    %                     cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient values of internal sources
    %                                                 []=defaults,     optional args
    cktnetlist = add_output(cktnetlist, 'nDL', 'nDR');
end
