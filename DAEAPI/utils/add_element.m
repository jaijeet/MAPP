function cktdata = add_element(cktdata, MOD, elname, nodes, parms, uinfo)
%function cktnetlistout = add_element(cktnetlist, MODorSUBCKT, elname, nodes,...
%                                                             parms, uinfo)
%This function adds an element to a circuit netlist structure; returns the
%updated version.
%
%The element can either be a device's ModSpec model, or a subcircuit structure.
%When add_element is used for a subcircuit, it is equivalent to add_subcircuit.
%For more information on defining and using subcircuits, see
%   >> help add_subcircuit;
%
%Arguments:
%
% - cktnetlist: the circuit netlist structure to be updated.
%
% - MODorSUBCKT: ModSpec model object (structure) for the device to be added
%            or subcktnetlist for the subcircuit to be added.
%
%            When add_element is used for a subcircuit, it is equivalent to
%            add_subcircuit. Run "help add_subcircuit;" for more information.
%
% - elname:  name of the element (string)
%
% - nodes:   list of circuit nodes the element is connected to (specified as
%            a cell array of strings). Must match the number of nodes for the
%            ModSpec device MOD, and be in the same order as in the ModSpec's
%            definition.
%
% - parms:   cell array of parameter-name,value pairs: 
%                {{'parmname1', val1}, {'parmname2', val2}, ... } 
%            if absent or [], defaults (from ModSpec definition) used.
%            - also supports a special form for models that have only one 
%              parameter (like R, L, C), with parms a single value.
%
% - uinfo:   a list of lists of independent source (u) information for the
%            device, in the format {u1info, u2info, ...}. Each uinfo has the
%            format (but there are special simple forms if the device has only
%            one u input, see below):
%
%            uiinfo = {srcname, spec1, spec2, ...}, where:
%
%                - srcname is a string that should exactly match 
%                  ModSpec's internal name for the src. Eg, for indep
%                  voltage sources, srcname should equal 'E'; for indep
%                  current sources, srcname should equal 'I'.
%
%                - each specj is a cell array with one of the following 
%                  formats:
%
%                  - {'DC' DCval}
%                    - where DCval is a real number (the DC value).
%
%                  - {'AC' ACval} OR {'AC' ACfunc ACargs}
%                    - ACval should be a complex number (the AC input value)
%                    - ACfunc should be a function handle of the form:
%                      ACfunc = @(f, ACargs) <return scalar complex number>
%                      - f represents frequency
%                        - ACargs is a structure containing any data needed by
%                          ACfunc
%
%                  - {'TRAN' tranfunc tranargs}
%                    - tranfunc = @(t, tranargs) should be a scalar real 
%                      function handle with two arguments: t and tranargs
%                      - t represents time
%                      - tranargs is a structure containing any data
%                        needed by tranfunc
%
%            - if there is only 1 u input for the device (ie,
%              1 == feval(MOD.uNames, MOD), then uinfo can have simpler
%              special forms that do not require srcname:
%              
%              1. uinfo = spec1
%                 where spec1 is a cell array of the format specj, described
%                 above.
%                 Example: uinfo = {'TRAN' tranfunc tranargs}
%
%              2. uinfo = {spec1, spec2, ...}
%                 with specj of the format described above.
%                 Example: uinfo = {{'DC' DCval} {'TRAN' tranfunc tranargs}}
%
%
%Return values:
%
% - cktnetlist: updated circuit netlist structure with the device added.
%
%Examples
%--------
%  clear ntlst;
%  ntlst.cktname = 'gnd-vsrc1-n1-R-n2-C-n3-L-n4-vsrc2-n5-vsrc3-gnd';
%  % nodes (names)
%  ntlst.nodenames = {'1', '2', '3', '4', '5'}; % non-ground nodes
%  ntlst.groundnodename = 'gnd';
%
%  vM = vsrcModSpec();
%  DCval = 1.0;
%  tranfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
%  tranargs.A = 1; tranargs.f = 1e3; tranargs.phi = 0;
%
%  %                ntlst, ModSpec model, name     nodes,    parameters
%  %                    |     |            |          |   []/{} =defaults
%  %                    |     |            |          |          |   
%  %                    v     v            v          v          v   
%  ntlst = add_element(ntlst, vM,       'vsrc1',  {'1', 'gnd'},  {}, ... 
%      {{'E' {'DC',DCval} {'AC' (1+1i)/sqrt(2)} {'TRAN',tranfunc,tranargs}}});
%  %      ^          ^             ^                      ^
%  %      |          |             |                      |
%  %   internal   DC/AC/transient settings for internal sources
%  %    source
%  %    name
%
%  ntlst = add_element(ntlst, resModSpec(), 'r1', {'1', '2'}, ...
%                       {{'R', 1000}}, {});
%
%  ntlst = add_element(ntlst, capModSpec(), 'c1', {'2', '3'}, ...
%                       1e-6, {});
%
%  ntlst = add_element(ntlst, indModSpec(), 'l1', {'3', '4'}, ...
%                       5e-2);
%
%  %                ntlst, ModSpec model, name     nodes,    parameters
%  %                    |     |            |          |   []/{} =defaults
%  %                    |     |            |          |          |   
%  %                    v     v            v          v          v   
%  ntlst = add_element(ntlst, vM,       'vsrc2',  {'4', '5'},   {}, ... 
%      {{'DC',DCval} {'AC' (1+1i)/sqrt(2)} {'TRAN',tranfunc,tranargs}});
%  %        ^             ^                      ^
%  %        |             |                      |
%  %     DC/AC/transient settings for single internal source
%  %  
%  %  
%  %                ntlst, ModSpec model, name     nodes,    parameters
%  %                    |     |            |          |   []/{} =defaults
%  %                    |     |            |          |          |   
%  %                    v     v            v          v          v   
%  ntlst = add_element(ntlst, vM,       'vsrc3',  {'5', 'gnd'}, {}, ... 
%      {'DC',DCval});
%  %        ^             
%  %        |            
%  %  DC value of single internal source
%  %  
% 
% DAE = MNA_EqnEngine(ntlst);
% 
%  % Now you can run any MAPP analysis on DAE (see MAPPanalyses).
%
%See also
%--------
%
% add_output, add_subcircuit, MAPPcktnetlists, MAPPanalyses, 
%   MNA_EqnEngine[TODO], DAE_concepts, DAEAPI



% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2013/05/17, 2013/09/20, 2015/05/22                 %
%%         Tianshi, Aadithya please add your entries!                          %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%%               reserved.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ~isfield(MOD, 'fe')
        cktdata = add_subcircuit(cktdata, MOD, elname, nodes, parms, uinfo); % Tianshi TODO: check for duplicate element/subckt names
    else
        if ~isfield(cktdata, 'all_element_names')
            cktdata.all_element_names{1} = elname;
        else
            strcmpout = strcmp(elname, cktdata.all_element_names);
            if 0 ~= sum(strcmpout)
                error('add_element:DUPLICATE_ELEMENT_NAME', 'element %s already defined in cktnetlist - aborting add_element\n', ...
                        elname);
            else
                cktdata.all_element_names{end+1} = elname;
            end
        end
        the_element.name = elname;
        the_element.model = MOD;

        % check cktdata.nodenames
        unique_node_names = unique(cktdata.nodenames);
        if length(unique_node_names) ~= length(cktdata.nodenames)
            error('add_element:DUPLICATE_DECLARED_NODE', 'there seems to be a repeated node name in cktdata.nodenames - aborting.\n');
        end
        if isfield(cktdata, 'groundnodename')
            unique_node_names{end+1} = cktdata.groundnodename;
        end
        unique_node_names = unique(unique_node_names);
        for node = nodes
            strcmpout = strcmp(node, unique_node_names);
            if 0 == sum(strcmpout)
                error('add_element:NODE_NOT_FOUND', 'element %s: node %s not declared in cktnetlist.nodenames or as cktnetlist.groundnodename - aborting.\n', ...
                        elname, node);
            end
        end
        the_element.nodes = nodes; 
        modelname = feval(MOD.ModelName, MOD);

        if nargin < 5 || isempty(parms)
                % use model defaults
                the_element.parms = feval(MOD.parmdefaults, MOD);
        else
                % supporting {{'parm1', val1}, {'parm2', val2}, ...} settings
                % first set all parameters to default values
                parmnames = feval(MOD.parmnames, MOD);
                nparms = length(parmnames);
                % first set all parameters to default values
                if iscell(parms)
                        the_element.parms = feval(MOD.parmdefaults, MOD);
                        for i = 1:length(parms)
                                parmvalpair = parms{i};
                                if 0 == iscell(parmvalpair) || ...
                                                2 ~= length(parmvalpair)
                                        error('%s: %dth parameter specification incorrect: not cell array of form {parmname, val}', elname, i);
                                end
                                pname = parmvalpair{1};
                                pval = parmvalpair{2};
                                idx = find(strcmp(parmnames, pname));
                                if 0 == length(idx)
                                        error('%s: parameter %s not available for model %s', elname, pname, modelname);
                                elseif 1 == length(idx)
                                        the_element.parms{idx} = pval;
                                else
                                        error('%s: model %s definition error: parameter %s defined more than once', elname, modelname, pname);
                                end
                        end
                else % special form: just one value
                        if 1==length(parms) && 1==nparms
                                the_element.parms = {parms};
                        else
                                error('%s: model %s has %d parameters but special form with one un-identified value (%g) used.\n', elname, modelname, nparms, parms);
                        end
                end
        end

        if 6 == nargin
                ninfos = length(uinfo);
                unames = feval(MOD.uNames, MOD);
                if 1 == length(unames)
                        % detect special forms if only 1 input, convert to normal form
                        % 1. {{'DC' dcval} {'AC' acmag acphase} {'tran' tranfunch funcargs}}
                        % 2. {'DC' dcval} or {'AC' acmag acphase} or {'tran' tranfunch funcargs}
                        % (instead of {{'E' {'DC' dcval} {'AC' acmag acphase} {'tran' tranfunch funcargs}}})
                        the_uname = unames{1};
                        if 1 == ninfos
                                % could be 
                                % - {{'E' {'DC' dcval} {'AC' acmag acphase} {'tran' tranfunch funcargs}}}
                                %   or {{'DC' dcval}}
                                % - NOT {'DC' dcval} - this is of size 2
                                %   or {{'DC' dcval} {'AC' acmag acphase}}
                                uinfo1 = uinfo{1};
                                uinfo1first = uinfo1{1};
                                if ~strcmp(uinfo1first, the_uname) % uinfo1 is {'DC' dcval} or {'AC', ...} or {'tran", ...}
                                        uinfo = {{the_uname, uinfo1}};
                                else % uinfo1 is {'E' {'DC' dcval} {'AC' acmag acphase} {'tran' tranfunch funcargs}}
                                    % do nothing
                                end
                        else % ninfos > 1
                             % could be 
                             % - {'DC' dcval} - single specification, this is of size 2
                             %   or {{'DC' dcval} {'AC' acmag acphase} ... } (more than one specification
                             % - NOT {{'E' {'DC' dcval} {'AC' acmag acphase} {'tran' tranfunch funcargs}}}
                             %   or {{'DC' dcval}}
                             uinfo1 = uinfo{1}; % either 'DC'/'AC'/etc., OR a cell: {'DC', dcval}
                             if ischar(uinfo1) % uinfo is like {'DC' dcval}
                                     uinfo = {{the_uname, uinfo}};
                             elseif iscell(uinfo1) % uinfo is like {{'DC' dcval} {'AC' acmag acphase} ... } 
                                     uinfo = {{the_uname, uinfo{:}}};
                             else % illegal
                                     error('add_element: uinfo1 is of illegal type.');
                             end
                        end
                end
                ninfos = length(uinfo);
                the_element.udata = {};
                for i=1:ninfos
                        the_data = uinfo{i}; %  the_data looks like {'E' {'DC' dcval} {'AC' acmag acphase} {'tran' tranfunch funcargs}}
                        the_data_len = length(the_data);
                        uname = the_data{1}; % eg, 'E' or 'I'
                        idx = find(strcmp(unames, uname)); % is it defined?
                        if 0 == length(idx)
                                error('%s: uName %s not available for model %s', elname, uname, modelname);
                        elseif 1 == length(idx)
                                uidata.uname = uname; % eg, 'E' or 'I'
                        else
                                error('%s: model %s definition error: uName %s defined more than once', elname, modelname, uname);
                        end

                        % support of {'E', {'DC/QSS', dcval}, {'AC/LTISSS', ACmag, ACphase}, }{'transient', tranfunc, funcargs} entries
                        for j=2:the_data_len
                                inputspec = the_data{j}; % {'DC', dcval} or {'AC', ACmag, ACphase}
                                                         % or {'tran', tranfunc, funcargs}
                                speclen = length(inputspec);
                                if ~iscell(inputspec) || 0 == speclen 
                                        error('%s: expecting DC/AC/tran input specification in a cell', elname);
                                end

                                analysistype = inputspec{1};
                                if ~ischar(analysistype) 
                                        error('%s: expecting a string (''DC'', ''AC'' or ''tran'') for the input specification', elname);
                                end

                                switch upper(analysistype) % case insensitive
                                  case {'DC', 'QSS', 'UQSS'}
                                          if 2 ~= speclen
                                                error('%s: expecting exactly one argument DCVAL for DC input specification', elname);
                                        end
                                        uidata.QSSval = inputspec{2};
                                  case {'AC', 'LTISSS', 'ULTISSS'}
                                          % valid syntaxes are: {'AC' <complex number>},  {'AC', @(f,args) <scalar complex number>, args}
                                        %                     {'AC', @(f,args) <scalar complex number>} (args assumed = [])
                                          if speclen < 2 || speclen > 3
                                                error('%s: expecting 1 or 2 arguments in AC input specification', elname);
                                        end
                                        
                                        % first argument: numeric or function handle
                                        if isnumeric(inputspec{2})
                                                uidata.uLTISSS = @(f, args) inputspec{2}; % constant with frequency
                                                uidata.uLTISSSargs = [];
                                                  if speclen > 2 
                                                        error('%s: more than 1 argument in AC input specification when first arg has numeric type', elname);
                                                end
                                        elseif isa(inputspec{2}, 'function_handle')
                                                uidata.uLTISSS = inputspec{2};
                                        else
                                                error('%s: AC input specification is neither numeric nor a function handle', elname);
                                        end

                                        if 3 == speclen % an args argument is provided
                                                uidata.uLTISSSargs = inputspec{3};
                                        else % not provided
                                                uidata.uLTISSSargs = [];
                                        end
                                  case {'TR', 'TRAN', 'TRANSIENT', 'UTRANSIENT'}
                                          % valid syntaxes are: {'tr', @(t,args) <real-function>, args}, or
                                        %                     {'tr', @(t,args) <real-function>} (args assumed = [])
                                          if speclen < 2 || speclen > 3
                                                error('%s: expecting 1 or 2 arguments in TRANSIENT input specification', elname);
                                        end
                                        
                                        % first argument: function handle
                                        if isa(inputspec{2}, 'function_handle')
                                                uidata.utransient = inputspec{2};
                                        else
                                                error('%s: TRANSIENT input specification is not a function handle', elname);
                                        end

                                        if 3 == speclen % an args argument is provided
                                                uidata.utransientargs = inputspec{3};
                                        else % not provided
                                                uidata.utransientargs = [];
                                        end
                                  otherwise
                                        error('%s: only input specifications of type DC/QSS/uQSS/AC/LTISSS/uLTISSS/TR/TRAN/TRANSIENT/uTRANSIENT are supported', elname);
                                end
                        end
                        the_element.udata{i} = uidata;
                end
        end

        if isfield(cktdata, 'elements')
                nelems = length(cktdata.elements);
                cktdata.elements{nelems+1} = the_element;
        else
                cktdata.elements = {the_element};
        end

        cktdataout = cktdata;
    end % subcircuit or element
end
%Author: J. Roychowdhury, 2013/05/17, 2013/09/20
