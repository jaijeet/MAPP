function cktnetlist = SHdiffpair_ckt()
%function cktnetlist = SHdiffpair_ckt()
%This function returns a cktnetlist structure for a differential pair circuit
%made of Shichman Hodges MOS devices. 
%
%The circuit
%   An ideal-ish differential pair using Shichman Hodges MOS devices. The 
%   source nodes of 2 N-type MOSFETs are connected at node nS (node voltage
%   e_nS). 
%   An ideal current source of DC value IS drains node S. The drain of the
%   MOSFET on the left is connected to node nDL (node voltage e_nDL); that of
%   the one on the right to node nDR (node voltage e_nDR). Resistors rL and rR
%   connect from VDD to nodes nDL and nDR, respectively; similarly with
%   capacitors CL and CR. 
%
%To see the schematic of this circuit, run:
%
% showimage('SHdiffpair.jpg');
%
%To see the script that runs DC, AC and transient simulations on this circuit,
%you can run:
%
% edit run_SHdiffpair_ckt_DCop_AC_transient.m;
%     or
% type run_SHdiffpair_ckt_DCop_AC_transient.m;
%
%Examples
%--------
%
% run_SHdiffpair_ckt_DCop_AC_transient;
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts,
% run_SHdiffpair_ckt_DCop_AC_transient

%
% Author: Tianshi Wang, 2013/09/28
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % ckt name
    cktnetlist.cktname = 'MOS (SH) diffpair with Vin- grounded';
    % nodes (names)
    cktnetlist.nodenames = {'nS', 'nDL', 'nDR', 'nDD', 'Vin'}; % non-ground 
                                % nodes
    cktnetlist.groundnodename = 'gnd';

    % circuit element values
    VDD = 5.0; % 5V
    VinDC = 0; % DC input value of Vin
    vinoft = @(t, args) args.A*sin(2*pi*args.f*t + args.phi); % transient 
                                                   % input function for Vin
    vinargs.A = 1; vinargs.f = 1e3; vinargs.phi = 0; % arguments for
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
    cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'ML', ...
                  {'nDL', 'Vin', 'nS'}, {{'Beta', 1e-2}});
    cktnetlist = add_element(cktnetlist, SH_MOS_ModSpec(), 'MR', ...
                  {'nDR', 'gnd', 'nS'}, {{'Beta', 1e-2}});
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'Vin', 'gnd'}, {},         {{'E', {'DC', VinDC}, {'AC' 1}, {'tr', vinoft, vinargs}}});
    %                              ^          ^           ^           ^        ^                    ^      ^        ^
    %                           cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient values of internal sources
    %                                                         []=defaults,     optional args
    cktnetlist = add_element(cktnetlist, isrcModSpec(), 'IS', {'nS', 'gnd'}, {},         {{'I', {'DC', IS}}});
    %                        ^          ^           ^           ^       ^                  ^      ^        ^
    %                     cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient values of internal sources
    %                                                 []=defaults,     optional args
    cktnetlist = add_output(cktnetlist, 'nDL', 'nDR', 'nDL-nDR');
    cktnetlist = add_output(cktnetlist, 'Vin');
end
