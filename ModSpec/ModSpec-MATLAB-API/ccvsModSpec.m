function MOD = ccvsModSpec(uniqID)
%function MOD = ccvsModSpec(uniqID)
%This function returns a ModSpec model for ideal current-controlled voltage
%sources.
%
%Arguments:
% - uniqID: (optional) a unique identification string. Eg, 'H1'
%
%Return values:
% - MOD:    a ModSpec object for a current-controlled voltage source.
%           help ModSpec for more information about ModSpec.
%
%Model information
%-----------------
%
% - nodes and their names: 
%   - {'p', 'n', 'pc', 'nc'} (p, n, p-control, n-control).
%
% - parameters and their default values:
%   - 'gain' (gain of ccvs): 1.
%
%Lower-level Model information
%-----------------------------
%
% 1. variables:
% - IO name(s):                      vpnc, vnnc, vpcnc, ipnc, innc, ipcnc
% - explicit output name(s) (vecZ):  vpcnc, vpnc, ipnc
% - other IO name(s) (vecX):         ipcnc, vnnc, innc
% - implicit unknown name(s) (vecY): {}
% - input name(s) (vecU):            {}
%
% 2. equations:
% - equations derivation:
%    vpcnc = 0
%    gain*vpcnc-vpn = 0  -->  vpnc = gain*vpcnc + vnnc
%    ipnc = -innc             
% - fe = [0;
%        gain*vpcnc + vnnc;
%        -innc];
% - qe = [0;0;0];
%
%
%Examples
%--------
% % adding a ccvs with gain equal to 0.5
% cktdata = add_element(cktdata, ccvsModSpec(), 'H1', ...
%           {'np', 'nn', 'npc', 'nnc'}, {'gain', 0.5}, {});
%
%See also
%--------
% 
% add_element, circuitdata[TODO], ModSpec, supported_ModSpec_devices[TODO],
% DAEAPI, DAE_concepts
%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%change log:
%-----------
%2014/05/13: Bichen Wu <bichen@berkeley.edu> Added the function handle of fqei
%            and fqeiJ to reduce redundant calling of f/q functions and to
%            improve efficiency

% Author: Bichen Wu   2013/11/21

% use the common ModSpec skeleton, sets up fields and defaults
    MOD = ModSpec_common_skeleton();

% set up data members defined in ModSpec_common_skeleton. These are
% used by the API functions defined there.

% uniqID
    if nargin < 1
        MOD.uniqID = '';
    else
        MOD.uniqID = uniqID;
    end

    MOD.model_name = 'ccvs';
    MOD.model_description = 'ideal current controlled voltage source';

    MOD.parm_names = {'gain'};
    MOD.parm_defaultvals = {1};
    MOD.parm_vals = MOD.parm_defaultvals; % current values of parms

    MOD.explicit_output_names = {'vpcnc', 'vpnc', 'ipnc'};
    MOD.internal_unk_names = {};
    MOD.implicit_equation_names = {};
    MOD.u_names = {};

    MOD.NIL.node_names = {'p', 'n', 'pc', 'nc'};
    MOD.NIL.refnode_name = 'nc';

    % MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
    % MOD.NIL.io_nodenames are set up by this helper function
    MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);


% Core functions: qi, fi, qe, fe: 
    MOD.fqei = @fqei;

% Newton-Raphson initialization support

% Newton-Raphson limiting support

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % ccvs MOD constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE DEVICE EVAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%
function [fe, qe, fi, qi] = fqei(vecX, vecY, vecU, flag, MOD)

    if ~isfield(flag,'fe')
        flag.fe =0;
    end
    if ~isfield(flag,'qe')
        flag.qe =0;
    end
    if ~isfield(flag,'fi')
        flag.fi =0;
    end
    if ~isfield(flag,'qi')
        flag.qi =0;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set up scalar variables for the parms, vecX, vecY and u

    % create variables of the same names as the parameters and assign
    % them the values in MOD.parms
    % ideally, this should be a macro
    %     - could do this using a string and another eval()
    pnames = feval(MOD.parmnames,MOD);
    for i = 1:length(pnames)
        evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
        eval(evalstr);
    end
    % for this device, this should set up a MATLAB variable R

    % similarly, get values from vecX, named exactly the same as otherIOnames
    % get otherIOs from vecX
    oios = feval(MOD.OtherIONames,MOD);
    for i = 1:length(oios)
        evalstr = sprintf('%s = vecX(i);', oios{i});
        eval(evalstr); % should be OK for vecvalder
    end
    % for this device, this should set up vpn

    % do the same for vecY from internalUnknowns
    % get internalUnknowns from vecY
    iunks = feval(MOD.InternalUnkNames,MOD);
    for i = 1:length(iunks)
        evalstr = sprintf('%s = vecY(i);', iunks{i});
        eval(evalstr); % should be OK for vecvalder
    end
    % for this device, this should set up vin

    % end setting up scalar variables for the parms, vecX, vecY and vecU
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if flag.fe == 1
        fe = [0;
              gain*ipcnc + vnnc;
              -innc];
    else
        fe = [];
    end

    if flag.qe == 1
        qe = [0;0;0];
    else
        qe = [];
    end

    fi = [];
    qi = [];
end % fqei

%%%%%%%%%%%%%%%%%%%%%%% NETWORK INTERFACE LAYER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% ANALYSIS-SPECIFIC INPUT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% EQN and UNK SCALING SUPPORT %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
