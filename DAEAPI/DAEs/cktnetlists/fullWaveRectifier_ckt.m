function cktnetlist = fullWaveRectifier_ckt()
%function cktnetlist = fullWaveRectifier_ckt()
%This function returns a cktnetlist structure for a full wave rectifier
%
%The circuit
%   This is a full wave rectifier feeding a load of a resistor and a parallel
%   capacitor.
%   - The output nodes are P and N;
%   - RL is connected between P and N;
%   - CL is also between P and N;
%   - from N, two diodes go to ground and the input Vin, respectively;
%   - at P, two diodes come in from ground and the input Vin, respectively.
%
%To see the schematic of this circuit, run:
%
% showimage('fullWaveRectifier.jpg');
%
%Examples
%--------
%
% % set up DAE
% DAE = MNA_EqnEngine(fullWaveRectifier_ckt());
%
% % DC analysis
% dcop = dot_op(DAE);
% % print DC operating point
% feval(dcop.print, dcop); % print DAE outputs defined using add_output 
%                          % in fullWaveRectifier_ckt.m
%                          % feval(DAE.outputnames, DAE) prints the names
%                          % of the outputs
% feval(DAE.outputnames, DAE)
% % get DC operating point solution vector
% qssSol = feval(dcop.getsolution, dcop);
%
% % run transient simulation
% tstart = 0; tstep = 1e-5; tstop = 3e-3;                     
% TransObj = dot_transient(DAE, qssSol, tstart, tstep, tstop);
%
% % plot DAE-defined outputs
% feval(TransObj.plot, TransObj);
%
% % plot all DAE states
% souts = StateOutputs(DAE);
% %souts = souts.DeleteAll(souts); souts = souts.Add({'e_P', 'e_N'}, souts);
% [figh, legends] = feval(TransObj.plot, TransObj, souts);
%
% % overlay e_N - e_P "manually" on the plot of all DAE states
% [tpts, sols] = TransObj.getSolution(TransObj);
% idxP = DAE.unkidx('e_P', DAE); idxN = DAE.unkidx('e_N', DAE);
% figure(figh); hold on;
% plot(tpts, sols(idxN, :)-sols(idxP, :), '-r.', 'LineWidth', 2);
% legends = {legends{:}, 'e\_N-e\_P'}; legend(legends{:});
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts,
% dot_op, dot_transient 

%
%Author: Tianshi Wang, 2013/09/28
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % ckt name
    cktnetlist.cktname = 'full wave rectifier';
    % nodes (names)
    cktnetlist.nodenames = {'In', 'P', 'N'}; % non-ground nodes
    cktnetlist.groundnodename = 'gnd';

    % circuit element values
    VinDC = 0; % DC input value of Vin
    vinoft = @(t, args) args.A*sin(2*pi*args.f*t + args.phi); % transient 
                                                   % input function for Vin
    vinargs.A = 10; vinargs.f = 1e3; vinargs.phi = 0; % arguments for
                                                      % transient function
    RL = 1000; % 1K
    CL = 1e-6; % 1uF

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', ...
                 {'In', 'gnd'}, {}, {{'E', {'DC', VinDC}, {'AC' 1}, ...
                 {'tr', vinoft, vinargs}}});
    cktnetlist = add_element(cktnetlist, resModSpec(), 'RL', {'P', 'N'}, RL);
    cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', {'P', 'N'}, CL);
    cktnetlist = add_element(cktnetlist, diodeModSpec(), 'diode-InP', ...
                             {'In','P'}, []);
    cktnetlist = add_element(cktnetlist, diodeModSpec(), 'diode-NIn', ...
                             {'N','In'}, []);
    cktnetlist = add_element(cktnetlist, diodeModSpec(), 'diode-gndP', ...
                             {'gnd','P'},[]);
    cktnetlist = add_element(cktnetlist, diodeModSpec(), 'diode-Ngnd', ...
                             {'N','gnd'},[]);

    cktnetlist = add_output(cktnetlist, 'In'); % e(In)
    cktnetlist = add_output(cktnetlist, 'e(P)', 'e(N)'); % e(P)-e(N)
    cktnetlist = add_output(cktnetlist, 'i(Vin)', 1000); % current through
                                        % Vin, scaled by 1000
end
