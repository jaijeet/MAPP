function MOD = attach_ee_NIL(MOD)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Network Interface Layer (for EE devices) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic name and outputtype functions:
%% Network Interface Layer functions (for EE devices)
%
%  % basic name and outputtype functions:
%    .NIL.NodeNames: (function handle) returning a  cell array of size
%                       nNodes, containing names of the device's external nodes.
%                       The order specifies the node order in cktdata and
%                       add_elment(). Should be set up manually be the model
%                       writer.
%                       Use: extnodes = feval(MOD.NIL.NodeNames, MOD)
%
%    .NIL.RefNodeName: (function handle) returning the name (string) of the
%                       device's local reference node, with respect to which
%                       branch voltages are calculated. This should be one of
%                       the NodeNames.
%                       Use: localrefnode = feval(MOD.NIL.RefNodeName, MOD)
%
%       Note: IOnames at the core level is auto-generated using NodeNames and 
%             RefNodeName -- the IOs are all the branch voltages (from each
%             node to refnode), followed by all the branch currents: 
%                  foreach nn=NodeName (except refnodename): 
%                                IOnames = {v_nn_RefNodeName, i_nn_RefNodeName};
%
%    .NIL.IOnodeNames: (function handle) returning a cell array of strings
%                       (corresponding to IOnames) that lists the node (ie,
%                       one of NodeNames) to which the IO (ie, the branch 
%                       voltage or current) corresponds. Eg, if the IO is vgb
%                       or igb (with b being the reference node), then its
%                       IOnodeName is g.
%                       Use: ionodenames = feval(MOD.NIL.IOnodeNames, MOD)
%
%    .NIL.IOtypes: (function handle) returning a cell array of strings,
%                    with each entry either 'v' or 'i', corresponding to
%                each entry of IOnames. Indicates whether the IO is a
%                voltage branch or a current branch.
%                       Use: iotypes = feval(MOD.NIL.IOtypes, MOD)

    % for the Network Level
    MOD.NIL.node_names = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
    MOD.NIL.refnode_name = 'UNDEFINED: string';
    MOD.NIL.io_types = {'UNDEFINED:', 'cell', 'array', 'of', 'strings',...
                        '''v''', 'or', '''i'''};
    MOD.NIL.io_nodenames = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
    %
    MOD.NIL.NodeNames = ['UNDEFINED: function handle returning a cell', ...
                'array of strings']; % cell array of size nNodes,
                                     % containing names of the device's nodes
                                     % the order specifies, eg, the SPICE
                                     % syntax node order should be written
                                     % manually

    MOD.NIL.RefNodeName = 'UNDEFINED: function handle returning a string';
        % string containing the name of the device's internal 
        % reference node, with respect to which branch voltages are calculated.
        % This should be one of the NodeNames.

    % IOnames at the core-level is auto-generated from NodeNames and
    % RefNodeName. The IOs are all the branch voltages (from each node to
    % refnode), followed by all the branch currents: foreach nn=NodeName
    % (except refnodename): IOnames = {v_nn_RefNodeName, i_nn_RefNodeName}

    MOD.NIL.IOnodeNames = ['UNDEFINED: function handle returning a cell', ...
                           'array of strings']; 
    % a cell array (corresponding to IOnames) the lists the node (from
    % NodeNames) to which the IO (ie, the branch voltage or current)
    % corresponds. Eg, if the IO is vgb or igb (with b being the reference
    % node), then its IOnodeName is g.

    MOD.NIL.IOtypes = ['UNDEFINED: function handle returning a cell array', ...
                       'of strings ''v'' or ''i'''];
                       % a cell array of types ('v' or 'i') for the Core
                       % Device's IOs corresponding to IOnames

    MOD.NIL.NodeNames = @(inMOD) inMOD.NIL.node_names;
    MOD.NIL.RefNodeName = @(inMOD) inMOD.NIL.refnode_name;
    MOD.NIL.IOtypes = @(inMOD) inMOD.NIL.io_types;
    MOD.NIL.IOnodeNames = @(inMOD) inMOD.NIL.io_nodenames;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Network Interface Layer (for EE devices) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
