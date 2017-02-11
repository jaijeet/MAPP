function cktnetlist = photoBJT_resistor_ckt()
%function cktnetlist = photoBJT_resistor_ckt()
%
%This function (incomplete) returns a cktnetlist structure for Ming's 
%little photoBJT circuit. 2013/11/07, JR.
% 
%Examples
%--------
%
% % set up DAE %
% DAE =  MNA_EqnEngine(photoBJT_resistor_ckt());
%
% % run transient and plot %
% tstart = 0; tstep = 1e-8; tstop = 1e-6;
% TransObj = dot_transient(DAE, zeros(feval(DAE.nunks, DAE), 1), tstart, ...
%	                                                     tstep, tstop);
% feval(TransObj.plot, TransObj);
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]

%
%Author: Jaijeet Roychowdhury, 2013/11/07
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % ckt name
    cktnetlist.cktname = 'Ming''s AC source - resistor - photoBJT ckt';
    % nodes (names)
    cktnetlist.nodenames = {'nCC', 'nC', 'nB', 'nrB'}; % non-ground nodes
    cktnetlist.groundnodename = 'gnd';

    % circuit element values
    vccoft = @(t, args) args.A*sin(2*pi*args.f*t + args.phi); % transient 
                                                   % input function for Vin
    vccargs.A = 10; vccargs.f = 1e6; vccargs.phi = 0; % arguments for
                             % transient function

    lightargs.freq = 2e6;
    lightargs.offset = -0.8;
    lightargs.ampl = 1.6;
    lightfunc = @(t, args) args.offset + args.ampl*pulse(t*args.freq, ...
    			   0, 0.1, 0.5, 0.6);
    %                      td thi  tfs  tfe

    rL = 1000; % 1kOhm
    rB = 1; % 1Ohm
    cL = 0.2e-9; % 1nF: RC time const 0.2uSec
    % BJT parameters (these are default values for EbersMoll_BJT_ModSpec.m)
    %{ 
    default values of the parameters are:
    IsF = 1e-12; VtF = 0.025;
    IsR = 1e-12; VtR = 0.025;
    alphaF = 0.99; alphaR = 0.5;
    %}
    IsF = 1e-12;
    alphaF = 0.99;

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VCC', ...
        {'nCC', 'gnd'}, {}, {{'E', {'transient', vccoft, vccargs} }});

    cktnetlist = add_element(cktnetlist, resModSpec(), 'rL', {'nCC', 'nC'}, ...
                      {{'R', rL}}, {});

    cktnetlist = add_element(cktnetlist, EbersMoll_BJT_ModSpec(), 'Qphoto', ...
                  {'nC', 'nB', 'gnd'}, {{'IsF', IsF}, {'alphaF', alphaF}});

    cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', {'nC', 'gnd'}, ...
                      {{'C', cL}});

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'light', ...
    	{'nrB', 'gnd'}, {}, {{'E', {'tr', lightfunc, lightargs}}});

    cktnetlist = add_element(cktnetlist, resModSpec(), 'rB', {'nB', 'nrB'}, ...
                      {{'R', rB}}, {});

end
