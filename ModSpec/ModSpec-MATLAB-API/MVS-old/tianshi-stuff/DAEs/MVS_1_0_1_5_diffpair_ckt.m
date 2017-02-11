function cktnetlist = MVS_1_0_1_5_diffpair_ckt()
%function cktnetlist = MVS_1_0_1_5_diffpair_ckt()
% TODO: help strings obsolete.
%This function returns a cktnetlist structure for a differential pair circuit
% 
%The circuit
%   An ideal-ish differential pair using Shichman-Hodges MOS devices. The 
%   source nodes of 2 N-type MOSFETs are connected at node nE (node voltage eE). 
%   An ideal current source of DC value IE drains node E. The drain of the
%   MOSFET on the left is connected to node nCL (node voltage eCL); that of the
%   one on the right to node nCR (node voltage eCR). Resistors rL and rR connect
%   from VCC to nodes nCL and nCR, respectively; similarly with capacitors CL
%   and CR. 
%
%To see the schematic of this circuit, run:
%
% showimage('SHdiffpair.jpg');
%
%Examples
%--------
%
% run_SHdiffpair_ckt_DCop_AC_transient
%
%See also
%--------
% 
% add_element, supported_ModSpec_devices[TODO], DAEAPI[TODO], DAE[TODO]
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

	MVS_Model = MVS_1_0_1_5_ModSpec();

    % ckt name
    cktnetlist.cktname = 'MOS (SH) diffpair with Vin- grounded';
    % nodes (names)
    cktnetlist.nodenames = {'nE', 'nCL', 'nCR', 'nCC', 'Vin'}; % non-ground 
                                % nodes
    cktnetlist.groundnodename = 'gnd';

    % circuit element values
    VCC = 1.0; % 5V
    VinDC = 0; % DC input value of Vin
    vinoft = @(t, args) args.A*sin(2*pi*args.f*t + args.phi); % transient 
                                                   % input function for Vin
    vinargs.A = 1; vinargs.f = 1e9; vinargs.phi = 0; % arguments for
                             % transient function
    IE = 2e-3; % 2mA
    rL = 1000; % 2kOhms
    rR = 1000; % 2kOhms
    CL = 1e-12; % 1uF
    CR = 1e-12; % 1uF

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'VCC', {'nCC', 'gnd'}, {},         {{'E' {'DC', VCC}}});
    %                             ^         ^            ^          ^          ^                  ^
    %                          cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient/AC values of internal sources
    %                                                     []=defaults,     optional args

    cktnetlist = add_element(cktnetlist, resModSpec(), 'rL', {'nCC', 'nCL'}, ...
                      {{'R', rL}}, {});
    cktnetlist = add_element(cktnetlist, resModSpec(), 'rR', {'nCC', 'nCR'}, ...
                  rR, {});
    cktnetlist = add_element(cktnetlist, capModSpec(), 'CL', {'nCC', 'nCL'}, ...
                      {{'C', CL}});
    cktnetlist = add_element(cktnetlist, capModSpec(), 'CR', {'nCC', 'nCR'}, CR);
    cktnetlist = add_element(cktnetlist, MVS_Model(), 'ML', ...
                  {'nCL', 'Vin', 'nE', 'nE'}, []);
    cktnetlist = add_element(cktnetlist, MVS_Model(), 'MR', ...
                  {'nCR', 'gnd', 'nE', 'nE'}, []);
    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'Vin', {'Vin', 'gnd'}, {},         {{'E', {'DC', VinDC}, {'AC' 1}, {'tr', vinoft, vinargs}}});
    %                              ^          ^           ^           ^        ^                    ^      ^        ^
    %                           cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient values of internal sources
    %                                                         []=defaults,     optional args
    cktnetlist = add_element(cktnetlist, isrcModSpec(), 'IE', {'nE', 'gnd'}, {},         {{'I', {'DC', IE}}});
    %                        ^          ^           ^           ^       ^                  ^      ^        ^
    %                     cktnetlist, ModSpec model, name       nodes  , parameters,    DC/transient values of internal sources
    %                                                 []=defaults,     optional args

%    DAE = MNA_EqnEngine('SHdiffpair', cktnetlist); % we do this elsewhere
end
