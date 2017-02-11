function DAE = MNA_EqnEngine(uniqIDstr, circuitdata) % DAEAPIv6.2+delta
%function DAE = MNA_EqnEngine(uniqIDstr, circuitdata) % DAEAPIv6.2+delta
%Modified Nodal Analysis equation engine
%author: J. Roychowdhury 2012/05/01-08, 2012/07/20-22, 2012/10/20
%        T. Wang 2013/09/15, 2013/12/25, 2014/07/09, 2016/09/30
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: document how to use this, with examples
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
% Notes:
%
%
% unknown ordering convention:
% - first, all node voltages e, corresponding to each non-ground node
% - the remaining unknowns are grouped for each device:
%   - first, current unknowns from the device's otherIOs
%   - next, the device's internal unknowns
%
% equation ordering convention:
% - first, all node KCLs, corresponding to each non-ground node
% - the remaining unknowns are grouped for each device:
%   - first, KVL equations corresponding to voltage explicit outputs
%   - next, the device's implicit equations
%
%
%{
 ---- recap of device API: 
      - see comments in ModSpec_skeleton_core.m

 ---- how does the network set up vecX and vecY for the device? -----
   - for MNA:
     - look through the otherIOs, which specifies vecX:
       - if an otherIO is of type v, it is a branch voltage. find its index in otherIOs (idx2),
     find the node defining the branch (using NIL.IOnodeNames and NIL.IOtypes), and store the
     index of this node's voltage in the circuit
     unknown vector x as DAE.circuitdata.elements{i}.v_otherIO_nodeindices_into_x(idx2) 
       - if an otherIO is of type i, then first allocate a network unknown for the current (ie, increase
     the circuit unk vector x). Put the index of this ckt unknown in 
     DAE.circuitdata.elements{i}.i_otherIO_indices_into_x(idx2), where idx2 is the otherIO's index in otherIOs.

     - then look through the internal unknowns (which specify vecY) and allocate unknowns
       for them in the circuit vector x. Indices to these circuit unknowns are stored as
       DAE.circuitdata.elements{i}.intunk_indices_into_x(idx), where InternalUnkNames(idx) is the name of the
       internal unknown.

   - for ST:
     - similar to MNA, except that it should allocate branch voltage and current unknowns
       for all the IOs, not just otherIOs.

 ---- how does the network use the outputs from the device? -----
     - first, the explicit outputs vecZ:
       - for MNA: 
     - if an explicit output is of type 'i', this is a branch current; find the
       corresponding node (using NIL.IOnodeNames and NIL.IOtypes), from which find the index
       of the KCL equation for the node, and store it (as 
       DAE.circuitdata.elements{i}.i_explicitOutPut_KCLindices_into_fq(idx2), where ExplicitOutputNames(idx2) is the
       name of the unknown). At eval time, the corresponding explicit output is added to the circuit
       KCL's f and q vectors, and subtracted from the KCL for the device's reference node. 
     - if an explicit output is of type 'v', this is a branch voltage; find the
       corresponding node (using NIL.IOnodeNames and NIL.IOtypes), from which find the index
       of the corresponding node voltage in the circuit vector x (and also that of the reference node). 
       Store this index as DAE.circuitdata.elements{i}.v_explicitOutPut_KVLnodeindices_into_x(idx2), 
       where ExplicitOutputNames(idx2) is the name of the unknown).
       Also, add a circuit KVL equation of the form eNode-eREF - the_v_output = 0; and keep the index
       of this circuit equation as DAE.circuitdata.elements{i}.v_explicitOutPut_KVLindices_into_fq(idx2).
       At eval time :
       - use the above stored indices to get eNode (and eRef) from x, compute
         eNode-eREF - the_v_output, and put the result in the appropriate circuit KCL's f component, using
         the stored index to this circuit equation.
       - 
       - for ST: 
     - if of type 'i', then it should form/eval the network level equation i_br - value
       - it needs to link the appropriate network unknown i_br for this explicit output
     - if of type 'v', then it should form/eval the network level equation v_br - value
       - it needs to link the appropriate network unknown v_br for this explicit output

     - then, the implicit equations:
       - for MNA/ST/anything else: 
     - for each implicit equation (in ImplicitEquationNames), allocate a circuit equation, and
       store the index for the equation in DAE.circuitdata.elements{i}.implicitEqn_indices_into_fq(idx2).
       the network should already have allocated these equations: just add the returned
       values to them. These do not depend on the formulation.

 ---- rewriting the equations using gather/scatter matrices (for MNA)
      (gathering vecX, vecY, vecU from x and u, scattering vecZ and vecW
       into system f/q)

     - gather: set up vecX, vecY, vecU from x and u 
       - denote vecX = A_X * x, and vecY = A_Y * x. A_X and A_Y are sparse incidence matrices (just
     with 1 and -1 entries). These should be set up in the constructor.
     - (strictly speaking, if vecX = some nonlinear function of x, we are really interested
       in dvecX_dx; call this A_X. Similarly for vecY. But we don't have this for circuits).

       - similarly, the device input vector vecU = A_U*u, where u are the inputs of the entire
     system. A_U should also be set up in the constructor.

     - scatter: once we have vecZ and vecW, scatter them into the system's f/u. We also need
       to add the KCL contribs of 'i'-type otherIOs in vecX.
       
       - 'i'-type otherIOs in vecX:
     - each 'i'-type otherIO has a branch current unknown associated with it; this
       needs to be added/subtracted to the KCL equations of the nodes it is connected to.
       Let k be the index (in vecX) of the i-type otherIO, 
       ipk the index (in f) of its positive node's KCL, and ipn the index (in f) of its
       negative node's (ie, the device's reference node's) KCL. Then we have:

       f += (e_ipk - e_ipn)*e_k^T*vecX
       q += 0 (no contribution to the q component)

       - doing this for all relevant ks = k1, k2, ... corresponding to 'i'-type otherIOs,
         we get:
         f += [e_ipk1-e_ipn, 0vec, 0vec, ..., e_ipk2-e_ipn, 0vec, ...] * vecX
         - define A_fX = [e_ipk1-e_ipn, 0vec, 0vec, ..., e_ipk2-e_ipn, 0vec, ...], we have
           f += A_fX * vecX
           - A_fx should be set up in the constructor

       - vecZ: once vecZ is obtained, it is used in three ways

     - if the kth explicit output is of type 'i', you add/subtract it to two KCL equations with 
       indices ik/jk in the system f/q. This can be written as some f += (e_ik-e_jk) * e_k^T * vecZ, 
       where e_ik/jk are unit vectors of size neqns, and e_k is a unit vector of size l. The Jacobian
       contribution for this is:
       f += (e_ik-e_jk)*e_k^T*vecZf. Similarly for q. 
       - doing this for all relevant k (ie, those that correspond to 'i' outputs), you get
         - define A_Zi = [e_ik1-ejk1, 0vec, 0vec, ..., e_ik2-ejk2, 0vec, ...] for relevant k1, k2
           - this should be set up in the constructor
         - f += A_Zi * vecZf;
         - similarly for q

     - if the explicit output k is of type 'v', then a KVL equation of the form eNode-eREF - the_v_output 
       has been added to the system - this equation has some index ik. 
       Let idxk and j be the indices of eNode and eRef in x, respectively. Then
       the Jacobian entries for this equation are:
       - f += e_ik *((e_idxk^T - e_j^T)*x - e_k^T*vecZ)
       - doing this for all relevant k (ie, those that correspond to 'v' outputs), we get
         - call A_Zv = [e_ik1, 0vec, ..., e_ik2, 0vec, ...] for all relevant k1, k2, etc.
         - call A_Zve = [e_idxk1^T - e_j^T; 0vec^T, ..., e_idxk2^T - e_j^T; 0vec^T, ...] for all relevant k1, k2, etc.
         - f += A_Zv* (A_Zve*x - vecZf);
         - q += -A_Zv*vecZq (there is no A_Zv*A_Zve*x component)

       - vecW: once vecW is obtained, each entry corresponds to a separate equation in f/q.
     For the kth entry in vecW, k=1,...,n-l+m, let ik be the index of the corresponding
     implicit equation in f/q. Define:
     - A_W = [e_i1, e_i2, ...] (should be precompted and stored in the constructor), then we have 
     - f += A_W*vecW
     - similarly with q

 ---- setting up the circuit Jacobians Jqx, Jfx, Jqu, Jfu (for MNA)

     - for the ExplicitOutputs vecZ, we have:
       - for all the type 'i' outputs:
     - f += A_Zi * vecZf, with vecZf = fe(vecX, vecY, vecU), vecX = A_X * x, vecY = A_Y*x, vecU = A_U*u
       hence we have:
       - Jfx += A_Zi * (dfe_dvecX*A_X + dfe_dvecY*A_Y) 
       - similarly for Jqx
       - Jfu += A_Zi * dfe_dvecU*A_U
       - Jqu is always zero, since q does not depend on u

       - for all the type 'v' outputs:
     - f += A_Zv*(A_Zve*x - vecZf)
     - q += -A_Zv*vecZq 
     - hence we have:
       - Jfx += A_Zv*A_Zve - A_Zv*(dfe_dvecX*A_X + dfe_dvecY*A_Y) 
       - Jqx += -A_Zv*(dqe_dvecX*A_X + dqe_dvecY*A_Y)
       - Jfu += - A_Zv*dfe_dvecU*A_U
       - Jqu is always zero

     - for the ImplicitEquations vecW, we have
       - f += A_W*vecW, with vecW = fi(vecX, vecY, vecU), vecX = A_X * x, vecY = A_Y*x, vecU = A_U*u
       - hence we have:
     - Jfx += A_W*(dfi_dvecX*A_X + dfi_dvecY*A_Y)
     - similarly for Jqx
     - Jfu += A_W*dfi_dvecU*A_U 
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Changelog:
%---------
%2016/09/30: Tianshi Wang <tianshi@berkeley.edu>: small changes to speed it up
%2014/05/13: Bichen Wu <bichen@berkeley.edu>: Added function fqJ() that returns
%             f, q, dfdx, dqdx,, dfdxlim, dqdxlim, dfdu all at once to reduce
%             redundant calling of element functions to improve efficiency.
%2013/12/25: Tianshi Wang <tianshi@berkeley.edu>: nargin checks for backward
%            compatibility with old analyses
%2013/09/15: Tianshi Wang <tianshi@berkeley.edu>: added init/limiting
%2012/05/01-08, 2012/07/20-22, 2012/10/20:
%            Jaijeet Roychowdhury <jr@berkeley.edu>


%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
    DAE = DAEAPI_skeleton_core(); %
    DAE = DAEAPI_common_add_ons(DAE); %
    DAE = DAEAPI_input_add_ons(DAE); %
% version, help string, ID, store circuitdata: 
    DAE.version = 'DAEAPIv6.2';
    DAE.Usage = help('MNA_EqnEngine');
    if nargin < 1 || nargin > 2
        fprintf(2, 'Usage: DAE = MNA_EqnEngine(uniqIDstr, circuitdata)\n or\nDAE = MNA_EqnEngine(circuitdata)');
    elseif 1 == nargin
        DAE.uniqIDstr = '';
        DAE.circuitdata = uniqIDstr;
    else
        DAE.uniqIDstr = uniqIDstr;
        DAE.circuitdata = circuitdata;
    end
    %


    % start with the nodes in the circuit: set up node voltage unknowns and KCL equations. Initialize
    % ckt input and parameter related data

    % process groundnodename - it might be a cell array, by mistake
    if iscell(DAE.circuitdata.groundnodename)
        if 1 == length(DAE.circuitdata.groundnodename)
            DAE.circuitdata.groundnodename = DAE.circuitdata.groundnodename{1};
        end
    end
    if ~ischar(DAE.circuitdata.groundnodename)
        error('circuitdata.groundnodename should be a string; it is not.');
    end

    % check if groundnodename was included in nodenames; if so, remove it
    nnms = DAE.circuitdata.nodenames;
    nnms(cellfun(@(nnms) strcmp(nnms,DAE.circuitdata.groundnodename),nnms))=[]; 

    DAE.circuitdata.nodenames = nnms; % now unique and without groundnodename
    
    n_unks = length(DAE.circuitdata.nodenames); % node voltage unknowns
    n_eqns = length(DAE.circuitdata.nodenames); % node KCLs
    unk_names = strcat('e_', DAE.circuitdata.nodenames); % names of node voltage unknowns
    eqn_names = strcat('KCL_', DAE.circuitdata.nodenames); % names of KCL equations for the nodes

    n_inputs = 0;
    input_names = {};

    n_limitedvars = 0;
    limitedvar_names = {};

    n_parms = 0;
    parm_names = {};
    parm_default_vals = {};

    element_names = {};

    DAE.separatorString = ':::'; % a string that goes between element names and element parm/unknown/eqn etc.
                     % names when forming circuit-level names from element-level names.
                     % it MUST be unique enough not to appear in any string it helps concatenate,
                     % otherwise strfind in, eg, getparms, setparms, etc., will fail
                     % '-->' or '|->' might also be good choices

    % iterate through the elements, adding current and internal unknowns, limited variables, KVL and implicit equations
    for i = 1:length(DAE.circuitdata.elements);
        el = DAE.circuitdata.elements{i};
        elModel = el.model; % there is a separate one for each device
        elname = el.name;
        elNodes = el.nodes;
        elParms = el.parms;
        prefix = sprintf('%s%s', elname, DAE.separatorString);

        % set up the unknowns and equations. n_unks, n_eqns, etc. can be set up here

        % first, set model/device parameters: unks/eqns/etc. may depend on their values
        % TEMP DEBUG
        %fprintf(1, 'MNA_EqnEngine debug: setparms for %s about to be called.\n', elname);
        if ~isempty(elParms)
            elModel_w_updated_parms = feval(elModel.setparms, elParms, elModel);
            DAE.circuitdata.elements{i}.model = elModel_w_updated_parms;
        else
            DAE.circuitdata.elements{i}.model = elModel;
        end
        %fprintf(1, 'MNA_EqnEngine debug: done with setparms for %s.\n', elname);

        % set up a simple cell array of all element names - helps find the index in DAE.circuitdata.elements{:}
        % from an element name
        element_names{i} = elname;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % set up circuit unknowns in x, and create pointers to the circuit unknown x to help set up 
        % device unknowns vecX and vecY at eval time. In particular, set up the following:
        %     DAE.circuitdata.elements{i}.node_voltage_indices_into_x(:)
        %     DAE.circuitdata.elements{i}.refnode_index_into_x
        %    DAE.circuitdata.elements{i}.v_otherIO_nodeindices_into_x(:)
        %    DAE.circuitdata.elements{i}.i_otherIO_indices_into_x
        %    DAE.circuitdata.elements{i}.internal_unk_indices_into_x

        %% look through the device's nodes, allocate node voltages in x, and make links to x vector unknowns
        nodenames_internal = feval(elModel.NIL.NodeNames, elModel);
        if length(elNodes) ~= length(nodenames_internal)
            error(sprintf('length of device %s''s internal node list different from that of its external node connections', ...
                elname));
        end
        for j = 1:length(elNodes)
            node = elNodes{j};
            idx = find(strcmp(node, DAE.circuitdata.nodenames)); % index of node voltage in x
            if 1 == length(idx)
                DAE.circuitdata.elements{i}.node_voltage_indices_into_x(j) = idx;
                % use: iterate through (index j) elModel.NodeNames, then
                % x(node_voltage_indices_into_x(j)) is the node voltage
            elseif 1==strcmp(node, DAE.circuitdata.groundnodename) % it's the ground node
                DAE.circuitdata.elements{i}.node_voltage_indices_into_x(j) = 0;
            else
                error(sprintf('node %s not found exactly once amongst circuit nodes', node));
            end
        end

        % set up the link to the x vector for the device's reference node
        refnode = feval(elModel.NIL.RefNodeName, elModel);
        refnodeidx_internal = find(strcmp(refnode, nodenames_internal));
        if 1 ~= length(refnodeidx_internal)
            error(sprintf('reference node %s for device %s not found exactly once amongst device''s node list', refnode, elname));
        end
        refnodeidx_in_x = find(strcmp(elNodes{refnodeidx_internal}, DAE.circuitdata.nodenames)); 
        if 1 == length(refnodeidx_in_x)
            DAE.circuitdata.elements{i}.refnode_index_into_x = refnodeidx_in_x;
        elseif 1==strcmp(node, DAE.circuitdata.groundnodename)
            DAE.circuitdata.elements{i}.refnode_index_into_x = 0;
        else
            error(sprintf('reference node %s of device %s not found exactly once in circuit nodes', ... 
                elname, refnode));
        end
        % use: x(refnode_index_into_x) is node voltage of the device's reference node
        % subtract this from other node values to find branch voltages

        %% for vecX: look through otherIOs, act depending on type: 'v' or 'i'
        ioNames = feval(elModel.IOnames, elModel);
        ioTypes = feval(elModel.NIL.IOtypes, elModel);
        ioNodeNames = feval(elModel.NIL.IOnodeNames, elModel);
        otherIOnames = feval(elModel.OtherIONames, elModel);
        for oio = otherIOnames
            idx_in_IOs = find(strcmp(oio, ioNames));
            if 1 ~= length(idx_in_IOs)
                error(sprintf('otherIO %s found more than once in device %s''s IOs', ...
                    oio, elname));
            end
            IOnodeName = ioNodeNames{idx_in_IOs};
            int_idx_of_node = find(strcmp(IOnodeName, nodenames_internal));
            idx_in_otherIOs = find(strcmp(oio, otherIOnames));
            idx2 = idx_in_otherIOs; % for brevity in the following
            if 1==strcmp('v', ioTypes{idx_in_IOs})
                % we have a branch voltage otherIO
                DAE.circuitdata.elements{i}.v_otherIO_nodeindices_into_x(idx2) = ...
                    DAE.circuitdata.elements{i}.node_voltage_indices_into_x(int_idx_of_node);
                % use: iterate through otherIOs (index idx2), if of type 'v', then get its value
                %      as x(v_otherIO_nodeindices_into_x(idx2)) - x(refnode_index_into_x)
            elseif 1==strcmp('i', ioTypes{idx_in_IOs})
                % we have a branch current otherIO
                % add a current unknown to the circuit unk vector x
                n_unks = n_unks + 1;
                unk_names{n_unks} = sprintf('%s%s', prefix, oio{:}); % for 
                                             % some reason oio is a 1x1
                                             % cell, not a string
                %unk_names = {unk_names{:}, sprintf('%s%s', prefix, oio)};

                % store the index of this new unknown
                DAE.circuitdata.elements{i}.i_otherIO_indices_into_x(idx2) = n_unks;
                % use: go through otherIOs (index idx2), if of type 'i', then get its value
                %      as x(i_otherIO_indices_into_x(idx2))

                % store the index (into x) of the current branch's node, which doubles as the
                % index for the node's KCL equation. This will be needed for adding this
                % current unknown to the KCL equation of its node.
                DAE.circuitdata.elements{i}.i_otherIO_KCL_index_into_fq(idx2)  = ...
                    DAE.circuitdata.elements{i}.node_voltage_indices_into_x(int_idx_of_node);
            end
        end

        %% for vecY: add unknowns (and links) for the device's internal unknowns
        intUnkNames = feval(elModel.InternalUnkNames, elModel);
        if length(intUnkNames) > 0
            intUnkNames = strcat(prefix, intUnkNames);
            unk_names = {unk_names{:}, intUnkNames{:}};
            n_intUnks = length(intUnkNames);
            DAE.circuitdata.elements{i}.intunk_indices_into_x = (n_unks+1):(n_unks+n_intUnks);
            % use: vecY = x(internal_unk_indices_into_x(:))
            n_unks = n_unks + n_intUnks;
        else
            DAE.circuitdata.elements{i}.intunk_indices_into_x = [];
        end 
        %% set up limited variables
        if 1 == elModel.support_initlimiting
            limitedVarNames = feval(elModel.LimitedVarNames, elModel);
            if length(limitedVarNames) > 0
                limitedVarNames = strcat(prefix, limitedVarNames);
                limitedvar_names = {limitedvar_names{:}, limitedVarNames{:}};
                nlimitedVar = length(limitedVarNames);
                DAE.circuitdata.elements{i}.limitedvar_indices_into_xlim = (n_limitedvars+1):(n_limitedvars+nlimitedVar);
                % use: vecLim = xlim(limitedvar_indices_into_xlim(:))
                n_limitedvars = n_limitedvars + nlimitedVar;
            else
                DAE.circuitdata.elements{i}.limitedvar_indices_into_xlim = [];
            end 
        end
        % done setting up unknowns and unknown pointers
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % set up circuit equations f/q, and create pointers to device outputs vecZ and device f/q equations
        % for use at eval time. In particular, set up the following pointers:
        %
        % DAE.circuitdata.elements{i}.i_otherIO_KCL_index_into_fq (set up above, with unknowns)
        % DAE.circuitdata.elements{i}.refnodeKCL_index_into_fq
        % DAE.circuitdata.elements{i}.i_ExplicitOutput_KCLindices_into_fq
        % DAE.circuitdata.elements{i}.v_ExplicitOutput_KVLnodeindices_into_x(idx2)
        % DAE.circuitdata.elements{i}.v_ExplicitOutput_KVLindices_into_fq
        % DAE.circuitdata.elements{i}.ImplicitEqn_indices_into_fq

        % NOTE: DAE.circuitdata.elements{i}.refnode_index_into_x is also the index of the reference node's KCL
        % in the circuit's f/q:
        DAE.circuitdata.elements{i}.refnodeKCL_index_into_fq = DAE.circuitdata.elements{i}.refnode_index_into_x;

        %% look through explicitOutputs and act depending on whether branch voltage or current
        eoNames = feval(elModel.ExplicitOutputNames, elModel);
        neoi = 0; % number of 'i' type explicit outputs
        neov = 0; % number of 'v' type explicit outputs
        for eo = eoNames
            % find idx of eo in IOnames
            idx_in_IOs = find(strcmp(eo, ioNames));
            if 1 ~= length(idx_in_IOs)
                error(sprintf('explicit output %s not found exactly once in device %s', ...
                    eo, elname));
            else
                % action depends on the type of the explicit output: i or v
                IOnodeName = ioNodeNames{idx_in_IOs};
                int_idx_of_node = find(strcmp(IOnodeName, nodenames_internal));
                idx_of_nodevoltage_in_x= DAE.circuitdata.elements{i}.node_voltage_indices_into_x(...
                                                      int_idx_of_node);
                idx_into_ExplicitOutputNames = find(strcmp(eo,eoNames));
                idx2 = idx_into_ExplicitOutputNames; % to make long lines shorter
                if 1==strcmp(ioTypes(idx_in_IOs), 'i')
                    % eo is a branch current: find its KCL node index and store it
                    idx_of_nodeKCL_in_fq = idx_of_nodevoltage_in_x; % we use the convention
                        % that the same idx is used for a node's voltage unknown in x and its
                        % KCL equation in f/q
                    DAE.circuitdata.elements{i}.i_ExplicitOutput_KCLindices_into_fq(idx2) = ...
                                                idx_of_nodeKCL_in_fq;
                    neoi = neoi + 1;
                elseif 1==strcmp(ioTypes(idx_in_IOs), 'v')
                    % eo is a branch voltage: add an equation of the form
                    % eNode-eRefNode - value = 0; store the index of this equation;
                    % also store index of eNode in x;
                    n_eqns = n_eqns + 1;
                    eqnname = sprintf('KVL_%s_%s', elname, eo{:}); % eo is a 1x1 cell, not string
                    eqn_names = {eqn_names{:}, eqnname};
                    DAE.circuitdata.elements{i}.v_ExplicitOutput_KVLindices_into_fq(idx2) = n_eqns;
                    DAE.circuitdata.elements{i}.v_ExplicitOutput_KVLnodeindices_into_x(idx2) = ...
                        idx_of_nodevoltage_in_x;
                    neov = neov + 1;
                else
                    error(sprintf('explicit output %s not of type i or v in %s', eo, elname));
                end
            end
        end
        if neoi + neov ~= length(eoNames)
            error(sprintf('%s: numbers of type i and type v explicit outputs do not add up correctly.', elname));
        end
        % these are not really needed later
        %DAE.circuitdata.elements{i}.neoi = neoi;
        %DAE.circuitdata.elements{i}.neov = neov;

        %% look through ImplicitEquations and add equations, store indices for the equations in ckt f/q
        ieNames = feval(elModel.ImplicitEquationNames, elModel);
        nIEs = length(ieNames);
        if nIEs > 0
            DAE.circuitdata.elements{i}.ImplicitEqn_indices_into_fq = (n_eqns+1):(n_eqns+nIEs);
            tmp = strcat(prefix, ieNames);
            [eqn_names{(n_eqns+1):(n_eqns+nIEs)}] = tmp{:}; %[X{:}] = Y{:} is the right syntax, see help cell
            n_eqns = n_eqns + nIEs;
        else
            DAE.circuitdata.elements{i}.ImplicitEqn_indices_into_fq = [];
        end
        % done setting up equations and pointers to f/q
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % set up circuit inputs and related indices for access
        %% iterate through device's uNames
        uNames = feval(elModel.uNames, elModel);
        nUs = length(uNames);
        if nUs > 0
            tmp = strcat(prefix, uNames);
            [input_names{(n_inputs+1):(n_inputs+nUs)}] = tmp{:};
            DAE.circuitdata.elements{i}.u_indices_into_cktu = (n_inputs+1):(n_inputs+nUs);
            n_inputs = n_inputs + nUs;
        else
            DAE.circuitdata.elements{i}.u_indices_into_cktu = [];
        end
            
        % TODO: look at elements{i}.udata and do something useful with it
        % here

        % done setting up circuit inputs and related indices
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % set up all circuit parameters and access functions into the devices
        %% iterate through device's uNames
        pNames = feval(elModel.parmnames, elModel);
        nPs = length(pNames);
        if nPs > 0
            tmp = strcat(prefix, pNames);
            [parm_names{(n_parms+1):(n_parms+nPs)}] = tmp{:};
            n_parms = n_parms + nPs;
            device_parmdefaults = feval(elModel.parmdefaults, elModel);
            parm_default_vals = {parm_default_vals{:}, device_parmdefaults{:}};
        else
            device_parmdefaults = {};
        end
        % done setting up circuit parameters and access functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    %% 2nd pass through all devices to set up data for gather and scatter 
    %% (gathering vecX, vecY, vecU from x and u, scattering vecZ and vecW
    %% into system f/q, adding 'i' type otherIOs to the appropriate KCLs)
    %%
    %% (We need a 2nd pass because we need info about n_unks, n_eqns, n_inputs
    %%  for setting up the incidence matrices)
    for i = 1:length(DAE.circuitdata.elements);
        el = DAE.circuitdata.elements{i};
        elModel = el.model; % there is a separate one for each device
        elname = el.name;

        % begin set up A_X, A_fX
        otherIOnames = feval(elModel.OtherIONames, elModel);
        ioNames = feval(elModel.IOnames, elModel);
        ioTypes = feval(elModel.NIL.IOtypes, elModel);
        A_X = sparse(length(otherIOnames), n_unks);
        A_fX = sparse(n_eqns, length(otherIOnames));
        refnode_idx = el.refnode_index_into_x;
        for idx2 = 1:length(otherIOnames)
            oio = otherIOnames{idx2};
            idx_in_IOs = find(strcmp(oio, ioNames));

            if 1==strcmp('v', ioTypes{idx_in_IOs})
                % branch voltage otherIO: x(el.v_otherIO_nodeindices_into_x(idx2)) - x(el.refnode_index_into_x)
                if el.v_otherIO_nodeindices_into_x(idx2) ~= refnode_idx
                    if el.v_otherIO_nodeindices_into_x(idx2) > 0 % not the ground node
                        A_X(idx2,el.v_otherIO_nodeindices_into_x(idx2)) = 1;
                    end
                    if refnode_idx > 0
                        A_X(idx2, refnode_idx) = - 1;
                    end
                end
            elseif 1==strcmp('i', ioTypes{idx_in_IOs})
                % branch current otherIO
                % index in x of the current unknown is el.i_otherIO_indices_into_x(idx2)
                A_X(idx2, el.i_otherIO_indices_into_x(idx2)) = 1;

                % index (into f) of the branch current's positive node KCL is el.i_otherIO_KCL_index_into_fq(idx2)
                if el.i_otherIO_KCL_index_into_fq(idx2) ~= refnode_idx
                    if el.i_otherIO_KCL_index_into_fq(idx2) > 0
                        A_fX(el.i_otherIO_KCL_index_into_fq(idx2), idx2) = 1;
                    end
                    % index (into f) of the branch's negative-node KCL (always the device's reference node) is  refnode_idx
                    if refnode_idx > 0
                        A_fX(refnode_idx, idx2) = -1;
                    end
                end
            end
        end % idx2=1:length(otherIOnames)
        % end set up A_X, A_fX

        % begin set up A_Y
        intUnkNames = feval(elModel.InternalUnkNames, elModel);
        A_Y = sparse(length(intUnkNames), n_unks);
        for idx2 = 1:length(intUnkNames)
            A_Y(idx2, el.intunk_indices_into_x(idx2)) = 1;
        end
        % end set up A_Y

        % begin set up A_Xlim
        if 1 == elModel.support_initlimiting
            limitedVarNames = feval(elModel.LimitedVarNames, elModel);
            A_Xlim = sparse(length(limitedVarNames), n_limitedvars);
            for idx2 = 1:length(limitedVarNames)
                A_Xlim(idx2, el.limitedvar_indices_into_xlim(idx2)) = 1;
            end
        end
        % end set up A_Xlim

        % begin set up A_U
        uNames = feval(elModel.uNames, elModel);
        A_U = sparse(length(uNames), n_inputs);
        for idx2 = 1:length(uNames)
            A_U(idx2, el.u_indices_into_cktu(idx2)) = 1;
        end
        % end set up A_U

        % begin set up A_Zi, A_Zv and A_Zve
        refnodeKCL_index_into_fq = el.refnodeKCL_index_into_fq;
        eoNames = feval(elModel.ExplicitOutputNames, elModel);
        A_Zi = sparse(n_eqns, length(eoNames)); 
        A_Zv = sparse(n_eqns, length(eoNames)); 
        A_Zve = sparse(length(eoNames), n_unks); 
        for idx2 = 1:length(eoNames)
            % find idx of eo in IOnames
            eo = eoNames{idx2};
            idx_in_IOs = find(strcmp(eo, ioNames));

            if 1==strcmp(ioTypes(idx_in_IOs), 'i')
                % 'i' type (branch current) explicit output: needs to be added to KCLs
                % index of KCL eqn of positive node is el.i_ExplicitOutput_KCLindices_into_fq(idx2)
                if el.i_ExplicitOutput_KCLindices_into_fq(idx2) ~= el.refnodeKCL_index_into_fq
                    if el.i_ExplicitOutput_KCLindices_into_fq(idx2) > 0 % ie, not the (KCL of the) ground node
                        A_Zi(el.i_ExplicitOutput_KCLindices_into_fq(idx2), idx2) = 1;
                    end
                    % index of KCL eqn of -ve node is el.refnodeKCL_index_into_fq
                    if el.refnodeKCL_index_into_fq > 0
                        A_Zi(el.refnodeKCL_index_into_fq, idx2) = -1;
                    end
                end
            elseif 1==strcmp(ioTypes(idx_in_IOs), 'v')
                % 'v' type (branch voltage) explicit output: there's a KVL eqn for it,
                % eNode-eRefNode - value_from_Z = 0; 
                % the index of this equation in f/q is el.v_ExplicitOutput_KVLindices_into_fq(idx2)
                A_Zv(el.v_ExplicitOutput_KVLindices_into_fq(idx2), idx2) = 1;

                % the index (into x) of the positive node of the branch is el.v_ExplicitOutput_KVLnodeindices_into_x(idx2)
                if el.v_ExplicitOutput_KVLnodeindices_into_x(idx2) ~= el.refnode_index_into_x
                    if el.v_ExplicitOutput_KVLnodeindices_into_x(idx2) > 0
                        A_Zve(idx2,el.v_ExplicitOutput_KVLnodeindices_into_x(idx2)) = 1;
                    end
                    % the index (into x) of the -ve node of the branch is el.refnode_index_into_x
                    if el.refnode_index_into_x > 0
                        A_Zve(idx2,el.refnode_index_into_x) = -1;
                    end
                end
            else
                error(sprintf('explicit output %s not of type i or v in %s', eo, elname));
            end
        end
        % end set up A_Zi, A_Zv and A_Zve

        % begin set up A_W
        ieNames = feval(elModel.ImplicitEquationNames, elModel);
        A_W = sparse(n_eqns, length(ieNames));
        for idx2 = 1:length(ieNames)
            % the index of the equation is el.ImplicitEqn_indices_into_fq(idx2)
            A_W(el.ImplicitEqn_indices_into_fq(idx2), idx2) = 1;
        end
        % end set up A_W

        % store Jacobian data
        DAE.circuitdata.elements{i}.A_X = A_X;
        DAE.circuitdata.elements{i}.A_fX = A_fX;
        DAE.circuitdata.elements{i}.A_Y = A_Y;
        if 1 == elModel.support_initlimiting
            DAE.circuitdata.elements{i}.A_Xlim = A_Xlim;
        end
        DAE.circuitdata.elements{i}.A_U = A_U;
        DAE.circuitdata.elements{i}.A_Zi = A_Zi;
        DAE.circuitdata.elements{i}.A_Zv = A_Zv;
        DAE.circuitdata.elements{i}.A_Zve = A_Zve;
        DAE.circuitdata.elements{i}.A_W = A_W;
    end % 2nd pass through all devices

    % a small 3rd pass to set up x_to_xlim_matrix, can be integrated into 2nd pass, but efficiency is affected only trivially
    x_to_xlim_matrix = zeros(n_limitedvars, n_unks);
    for i = 1:length(DAE.circuitdata.elements);
        el = DAE.circuitdata.elements{i};
        elModel = el.model; % there is a separate one for each device
        % vecLim = vecXYtoLimitedVarsMatrix * [vecX;vecY];
        % vecLim = el.A_Xlim * xlim;
        % vecX = el.A_X * x;
        % vecY = el.A_Y * x;
        if 1 == elModel.support_initlimiting
            vecXY_to_vecLim = feval(el.model.vecXYtoLimitedVarsMatrix , el.model);
            if ~isempty(vecXY_to_vecLim)
                x_to_xlim_matrix = x_to_xlim_matrix + el.A_Xlim.'*vecXY_to_vecLim*[el.A_X;el.A_Y];
            end
        end
    end %  3rd pass through all devices



    %% store stuff set up above in DAE

    % DAE.circuitdata.elements{:} have already been updated above

    % name
    DAE.dae_name = sprintf('MNA DAE for %s', DAE.circuitdata.cktname);

    % list of elements
    DAE.element_names = element_names;

    % unks
    DAE.n_unks = n_unks;
    DAE.unk_names = unk_names;

    % eqns
    DAE.n_eqns = n_eqns;
    DAE.eqn_names = eqn_names;

    % limited vars
    DAE.n_limitedvars = n_limitedvars;
    DAE.limitedvar_names = limitedvar_names;

    DAE.x_to_xlim_matrix = x_to_xlim_matrix;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inputs
    DAE.n_inputs = n_inputs;
    DAE.input_names = input_names;

    % the rest pulled in from DAEAPI_input_add_ons

    % parameters
    DAE.n_parms = n_parms;
    DAE.parm_names = parm_names;
    DAE.parm_default_vals = parm_default_vals;

    % set up DAE outputs from circuitdata.outputs
    % walk through circuitdata.outputs and set up: 
    % - DAE.output_names (cell array)
    % - DAE.output_matrix - the C matrix
    [DAE.output_names,DAE.output_matrix]=DAE_outputs_from_circuitdata(DAE, ...
                                           'MNA');
    DAE.n_outputs = length(DAE.output_names);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up the standard DAEAPI function pointers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sizes: 
    DAE.nunks = @nunks;
    DAE.neqns = @neqns;
    DAE.ninputs = @ninputs;
    DAE.noutputs = @noutputs;
    DAE.nlimitedvars = @nlimitedvars; 
    %
% fqJ:
    DAE.fq = @DAE_fq;
    DAE.fqJ = @DAE_fqJ;
% f, q: 
    DAE.f_takes_inputs = 1;
    DAE.support_initlimiting = 1;
    DAE.f = @f;
    DAE.q = @q;
    %
% df, dq
    %DAE.df_dx = @df_dx_DAEAPI_auto;
    DAE.df_dx = @df_dx;
    %DAE.df_du = @df_du_DAEAPI_auto;
    DAE.df_du = @df_du;
    %DAE.df_dxlim = @df_dxlim_DAEAPI_auto;
    DAE.df_dxlim = @df_dxlim;
    %DAE.dq_dx = @dq_dx_DAEAPI_auto;
    DAE.dq_dx = @dq_dx;
    %DAE.dq_dxlim = @dq_dxlim_DAEAPI_auto;
    DAE.dq_dxlim = @dq_dxlim;
    %
% input-related functions
    % input-related functions are all overloaded (not using the default DAEAPI ones)
    %
    DAE.B = @B;
    %
% output-related functions
    DAE.C = @C;
    DAE.D = @D;
    %
% names
    DAE.uniqID   = @uniqID;
    DAE.daename   = @daename;
    DAE.unknames  = @unknames; % local, see below
    DAE.eqnnames  = @eqnnames; % local, see below
    DAE.inputnames  = @inputnames;
    DAE.limitedvarnames = @limitedvarnames;
    DAE.outputnames  = @outputnames;
    DAE.renameUnks = @renameUnks_DAEAPI;
    DAE.renameEqns = @renameEqns_DAEAPI;
    DAE.renameParms = @renameParms_DAEAPI;
    %
    DAE.time_units = 'sec'; % unit of time. Used for plot labels, mainly.
    %
    DAE.support_initlimiting = 1;
% QSS initial guess support
    DAE.NRinitGuess = @NRinitGuess;
    DAE.QSSinitGuess = @(u, DAEarg) zeros(feval(DAEarg.nunks, DAEarg),1); % default is zeros
    %
% NR limiting support
     DAE.NRlimiting = @NRlimiting;
     DAE.dNRlimiting_dx = @dNRlimiting_dx;
    DAE.xTOxlimMatrix = @(DAEarg) DAEarg.x_to_xlim_matrix;
    DAE.xTOxlim = @(x, DAEarg) feval(DAEarg.xTOxlimMatrix, DAEarg) * x;
    %
% parameter support - see also input- and output-related function sections
    DAE.nparms = @nparms;
    DAE.nparams = @nparms;
    DAE.parmdefaults  = @parmdefaults;
    DAE.paramdefaults  = @parmdefaults;
    DAE.parmnames = @parmnames_local;
    DAE.paramnames = @parmnames_local;
    DAE.getparms  = @newgetparms; % get parms from elements: don't use default DAEAPI getparms
    DAE.getparm  = @newgetparms; % get parms from elements: don't use default DAEAPI getparms
    DAE.getparam  = @newgetparms; % get parms from elements: don't use default DAEAPI getparms
    DAE.getparams  = @newgetparms; % get parms from elements: don't use default DAEAPI getparms
    DAE.setparms  = @newsetparms; % set parms inside elements: don't use default DAEAPI setparms
    DAE.setparm  = @newsetparms; % set parms inside elements: don't use default DAEAPI setparms
    DAE.setparam  = @newsetparms; % set parms inside elements: don't use default DAEAPI setparms
    DAE.setparams  = @newsetparms; % set parms inside elements: don't use default DAEAPI setparms
    DAE.unkidx = @unkidx_DAEAPI; % from utils
    DAE.eqnidx = @eqnidx_DAEAPI; % from utils
    DAE.inputidx = @inputidx_DAEAPI; % from utils
    DAE.limitedvaridx = @limitedvaridx_DAEAPI; % from utils
    DAE.outputidx = @outputidx_DAEAPI; % from utils

    % first derivatives with respect to parameters - for sensitivities
    DAE.dfq_dp  = @dfq_dp_DAEAPI_auto;
    DAE.df_dp  = @df_dp_DAEAPI_auto;
    DAE.dq_dp  = @dq_dp_DAEAPI_auto;
    %

% set DAE's uQSS, utransient, etc. from element udata (JR, 2012/10/20)
    % now that the DAE is set up, do a third
    % pass through all the elments and run set_uQSS, set_utransient, etc. 
    % on the just-created DAE using info from elements{i}.udata
    for i = 1:length(DAE.circuitdata.elements);
        el = DAE.circuitdata.elements{i};
        elModel = el.model; % there is a separate one for each device
        elname = el.name;

        unames = feval(elModel.uNames, elModel);
        if (length(unames) > 0) && (isfield(el, 'udata'))
            prefix = sprintf('%s%s', elname, DAE.separatorString);
            udata = el.udata; 
            % documentation for each element's udata info: (top down)
            % myelement.udata = {udata1, udata2, etc.}
            %           ^^^^^            ^^^^^^
            %   this name is important;  these names are not important - just for local use
            %
            % udata1, udata2, etc. should contain the following fields (these names are important):
            %    .uname = for example 'E' (for a voltage source), 'I' for a current source
            %      these are exactly from uNames for the device
            %    .QSSval = for example 1.0 (DC value from spice netlist line)
            %    .utransient = handle to a matlab function ut(t, args) that returns
            %        a scalar double number
            %        - for example dummy = @(t, args) args.A*sin(2*pi*args.f*t);
            %        - .utransient = dummy;
            %    .utransientargs = the args argument that needs to be in utransient
            %        - will typically contain information needed to evaluate
            %          utransient. Standard SPICE u functions: PWL, sffm, pulse?,
            %          sine, cos (there are only about 5).
            %    .uLTISSS = handle to a matlab function uf(f, args) that returns
            %    .uLTISSSargs = the args argument that needs to be in uLTISSS
            for j=1:length(udata)
                % Note: even if udata does not an entry for every one of
                % the model's unames, the following should be OK. Because the way DAE.uQSS, DAE.utransient, etc,
                % are implemented (TODO: CHECK THIS AND RECONFIRM), the entire u vector is first set to
                % zero, and then updated for each individual component that is defined - ie, there are sensible
                % defaults.
                udata_j = udata{j};
                uName = udata_j.uname;
                el_uName = strcat(prefix, uName);

                % QSS (DC)
                qssval = 0;
                if isfield(udata_j, 'QSSval')
                    qssval = udata_j.QSSval;
                    DAE = feval(DAE.set_uQSS, el_uName, qssval, DAE);
                    % also set flat waveform at DC val to be the default transient waveform
                    dummy = @(t, args) qssval;
                    DAE = feval(DAE.set_utransient, el_uName, dummy, [], DAE); 
                end

                % transient
                if isfield(udata_j, 'utransient')
                    DAE = feval(DAE.set_utransient, el_uName, udata_j.utransient, udata_j.utransientargs, DAE); 
                end

                % LTISSS (AC)
                if isfield(udata_j, 'uLTISSS')
                    DAE = feval(DAE.set_uLTISSS, el_uName, udata_j.uLTISSS, udata_j.uLTISSSargs, DAE); 
                end

                % YET TODO: HB inputs; multitime inputs, etc..
            end
        end
    end
    % end setting up uQSS, utransient, etc. for the DAE from element udata

% helper functions exposed by DAE
    DAE.internalfuncs = @internalfuncs;
    %
% functions for supporting noise
    % 
    DAE.nNoiseSources = @nNoiseSources;
    DAE.NoiseSourceNames = @NoiseSourceNames;
    DAE.NoiseStationaryComponentPSDmatrix = 'undefined'; % @NoiseStationaryComponentPSDmatrix;
    DAE.m = 'undefined'; % @m;
    DAE.dm_dx = 'undefined'; % @dm_dx;
    DAE.dm_dn = 'undefined'; % @dm_dn;
%
end % DAE "constructor"

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIZES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = nunks(DAE)
    out = DAE.n_unks;
end % nunks(...)

function out = neqns(DAE)
    % should be the same as nunks
    out = DAE.n_eqns;
    if out ~= DAE.n_unks
        error('neqns != nunks');
    end
end % neqns(...)

function out = ninputs(DAE)
    out = DAE.n_inputs;
end % ninputs(...)

function out = nlimitedvars(DAE)
    out = DAE.n_limitedvars;
end % nlimitedvars(...)

function out = noutputs(DAE)
    % this comes from the user/netlist, of course, but for the moment, all unknowns
    out = DAE.n_outputs;
end % noutputs(...)

function out = nparms(DAE)
    out = DAE.n_parms;
end % nparms(...)

function out = nNoiseSources(DAE)
    out = 0; % NOT IMPLEMENTED YET
end % nNoiseSources(...)

%renameUnks is in renameUnks.m
%renameEqns is in renameEqns.m
%renameParms is in renameParms.m

%%%%%%%%%%%% NAMES of DAE, UNKS, I/O, EQNS, PARMS, NOISE SOURCES %%%%%%%%%%%%%%
function out = uniqID(DAE)
    out = DAE.uniqIDstr;
end % daename()

function out = daename(DAE)
    out = DAE.dae_name;
end % daename()

%unknames is in unknames.m
%function out = setup_unknames(DAE)
%    % why a separate setup_unknames and unknames? forgotten
%    % these specify the order of the DAE's x vector
function out = unknames(DAE)
    out = DAE.unk_names;
end % unknames()

%eqnnames is in eqnnames.m
%function out = setup_eqnnames(DAE)
    % why a separate setup_eqnnames and eqnnames? forgotten
    % these specify the order of the DAE's f/q vectors

function out = eqnnames(DAE)
    out = DAE.eqn_names;
end % eqnnames()

function out = inputnames(DAE)
    out = DAE.input_names;
end % inputnames()

function out = limitedvarnames(DAE)
    out = DAE.limitedvar_names;
end % limitedvarnames()

function out = outputnames(DAE)
    out = DAE.output_names;
end % outputnames()

%parmnames is in parmnames.m
%function out = setup_parmnames(DAE)
    % why a separate setup_parmnames and parmnames? forgotten
function out = parmnames_local(DAE)
    out = DAE.parm_names;
end % parmnames()

function out = NoiseSourceNames(DAE)
    out = {}; % not supported yet in ModSpec
end % NoiseSourceNames()

%%%%%%%%%%%%%%%%%%%%% PARAMETER SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function parmvals = parmdefaults(DAE)
    parmvals = DAE.parm_default_vals;
end % parmdefaults(...)

% default getparms in getparms.m is not applicable, should be overloaded!
function parmvals = newgetparms(firstarg, secondarg)
% call as: parmvals = getparms(DAE)
%   - returns values of all defined parameters
% OR as parmval = getparms(parmname, DAE)
%         ^                   ^         
%       value               string
% OR as parmvals = getparms(pnames, DAE)
%         ^                     ^ 
%    cell array            cell array
%
    if 2 == nargin
        DAE = secondarg;
        if (1 == isa(firstarg, 'cell'))
            % getparms(pnames, DAE)
            pnames = firstarg;
        else
            % getparms(parmname, DAE)
            pnames{1} = firstarg;
        end
    elseif 1 == nargin
        DAE = firstarg;
        pnames = DAE.parm_names;
    else
        error('getparms takes 1 or 2 arguments');
    end
    for i = 1:length(pnames);
        pname = pnames{i};
        pidx = find(~cellfun(@isempty, regexp(DAE.parm_names, sprintf('^%s', pname))));
        if (length(pidx) < 1)
            fprintf(1, 'parameter starting with %s not found in DAE.\n', pname);
            outDAE = DAE;
            return;
        elseif (length(pidx) > 1)
            exactmatch = find(strcmp(pname, DAE.parm_names));
            if 1 == length(exactmatch)
                pidx = exactmatch; % parm name matched exactly, don't worry about other partial matches
            elseif length(exactmatch) > 1
                fprintf(1, 'parameter %s multiply defined. Please fix DAE.parmnames()!\n', pname);
                outDAE = DAE;
                return;
            else
                fprintf(1, 'parameter starting with %s has multiple matches:\n', pname);
                for j=1:length(pidx)
                    fprintf('%s\n', DAE.parm_names{pidx(j)});
                end
                fprintf(1, 'Please add more characters to the parameter name to make unique.\n');
                outDAE = DAE;
                return;
            end
        end
        pname = DAE.parm_names{pidx}; % the full name, not just the user supplied first part
        % split pname into an element name and a device/model parameter name
        startidx = strfind(pname,DAE.separatorString);
        if 0 == length(startidx) 
            error(sprintf('separator string %s not found in ckt parameter name %s', ...
                DAE.separatorString, pname));
        end
        elname = pname(1:(startidx-1));
        elParmName = pname((startidx+length(DAE.separatorString)):end);

        elidx = find(strcmp(elname, DAE.element_names));
        if 1 ~= length(startidx) 
            error(sprintf('element %s not found exactly once in ckt element list', elname));
        end

        elModel = DAE.circuitdata.elements{elidx}.model;
        parmvals{i} = feval(elModel.getparms, elParmName, elModel);
    end
    if (2 == nargin) && (0 == isa(firstarg, 'cell'))
        parmvals = parmvals{1}; % return non-cell
    end
end % newgetparms for overloading getparms



% default setparms is in setparms.m is not applicable, should be overloaded!
function outDAE = newsetparms(firstarg, secondarg, thirdarg)
% call as: outDAE = setparms(allparmvals, DAE)
%                              ^     
%              cell array with values of all defined parameters
% OR as outDAE = setparms(parmname, newval, DAE)
%                            ^         ^
%                          string    value
% OR as outDAE = setparms(pnames, newvals, DAE)
%                            ^         ^
%                            cell arrays
%
    if 3 == nargin
        DAE = thirdarg;
        if (1 == isa(firstarg, 'cell'))
            % setparms(pnames, newvals, DAE)
            pnames = firstarg;
            newvals = secondarg;
        else
            % setparms(parmname, newval, DAE)
            pnames{1} = firstarg;
            newvals{1} = secondarg;
        end
    elseif 2 == nargin
        DAE = secondarg;
        newvals = firstarg; % cell array
        pnames = DAE.parm_names;
    else
        error('setparms takes 2 or 3 arguments');
    end

    if length(pnames) ~= length(newvals)
        error('setparms: pnames and newvals have different lengths');
    end

    for i = 1:length(pnames);
        pname = pnames{i};
        pidx = find(~cellfun(@isempty, regexp(DAE.parm_names, sprintf('^%s', pname))));
        if (length(pidx) < 1)
            fprintf(1, 'parameter starting with %s not found in DAE.\n', pname);
            outDAE = DAE;
            return;
        elseif (length(pidx) > 1)
            exactmatch = find(strcmp(pname, DAE.parm_names));
            if 1 == length(exactmatch)
                pidx = exactmatch; % parm name matched exactly, don't worry about other partial matches
            elseif length(exactmatch) > 1
                fprintf(1, 'parameter %s multiply defined. Please fix DAE.parmnames()!\n', pname);
                outDAE = DAE;
                return;
            else
                fprintf(1, 'parameter starting with %s has multiple matches:\n', pname);
                for j=1:length(pidx)
                    fprintf('%s\n', DAE.parm_names{pidx(j)});
                end
                fprintf(1, 'Please add more characters to the parameter name to make unique.\n');
                outDAE = DAE;
                return;
            end
        end
        pname = DAE.parm_names{pidx}; % the full name, not just the user supplied first part
        % split pname into an element name and a device/model parameter name
        startidx = strfind(pname, DAE.separatorString);
        if 0 == length(startidx) 
            error(sprintf('separator string %s not found in ckt parameter name %s', ...
                DAE.separatorString, pname));
        end
        elname = pname(1:(startidx-1));
        elParmName = pname((startidx+length(DAE.separatorString)):end);

        elidx = find(strcmp(elname, DAE.element_names));
        if 1 ~= length(startidx) 
            error(sprintf('element %s not found exactly once in ckt element list', elname));
        end

        elModel = DAE.circuitdata.elements{elidx}.model;

        % set parm inside element and update DAE.circuitdata.elements{elidx}.model
        DAE.circuitdata.elements{elidx}.model = feval(elModel.setparms, elParmName, newvals{i}, elModel);
    end

    outDAE = DAE;
end % setparms

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fqout, dfqout] = fq(x, xlim, u, DAE, f_or_q, x_or_u_or_xlim)
    if 1 == strcmp('f', f_or_q)
        eff = 1;
    elseif 1 == strcmp('q', f_or_q)
        eff = 0;
    else
        error('f_or_q should be either f or q');
    end

    if nargout > 1
        derivs_wanted = 1;
        if nargin < 6 
            error('dfqout output requested, but x_or_u_or_xlim not specified');
        else
            if 1 == strcmp('x', x_or_u_or_xlim)
                ddx = 1;
            elseif 1 == strcmp('u', x_or_u_or_xlim)
                ddx = 0;
            elseif 1 == strcmp('xlim', x_or_u_or_xlim)
                ddx = 2;
            else
                error('x_or_u_or_xlim should be x or xlim or u');
            end
        end
    else
        derivs_wanted = 0;
    end

    % initialize fqout to zeros: POTENTIAL VECVALDER PROBLEM
    fqout = zeros(DAE.n_eqns,DAE.n_unks)*x; % HACK to make fqout the right-sized vecvalder 
                        % if either x or u is a vecvalder - seems to work
    if DAE.n_inputs > 0 && length(u) > 0
        fqout = fqout + zeros(DAE.n_eqns,DAE.n_inputs)*u;
    end
    fqout = sparse(fqout);

    % set up a sparse matrix of the right size for the derivatives
    if 1 == derivs_wanted
        if 1 == ddx
            dfqout = sparse(DAE.n_eqns, DAE.n_unks);
        elseif 0 == ddx
            dfqout = sparse(DAE.n_eqns, DAE.n_inputs);
        else
            dfqout = sparse(DAE.n_eqns, DAE.n_limitedvars);
        end
    end

    % loop through the elements
    elements = DAE.circuitdata.elements;
    nelements = length(elements);
    for i = 1:nelements
        el = DAE.circuitdata.elements{i};
        elModel = el.model; % there is a separate one for each device
        elname = el.name;
        %     el.node_voltage_indices_into_x(:)
        %     el.refnode_index_into_x
        %    el.v_otherIO_nodeindices_into_x(:)
        %    el.i_otherIO_indices_into_x
        %    el.internal_unk_indices_into_x


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% set up vecX, vecY, vecU for the device
        vecX = el.A_X * x;
        vecY = el.A_Y * x;
        if 1 == elModel.support_initlimiting
            vecLim = el.A_Xlim * xlim;
        end

        % setting up vecU
        if length(u) > 0 % u can be [] for q calls, in which case vecU won't be needed
            vecU = u(el.u_indices_into_cktu(:)); % CHECK VECVALDER
        else
            vecU = []; % for q calls
        end
        % note: the above is equivalent to vecU = A_U*u

        %% done setting up vecX, vecY, vecU for the device
        %%%%%%%%%%%%%%%%%%%

        % KCL contribs from branch-current otherIOs
        if 1 == eff
            fqout = fqout + el.A_fX * sparse(vecX);
            if 1 == derivs_wanted && 1 == ddx
                dfqout = dfqout + el.A_fX * el.A_X;
            end
        end

        % compute f/q component of vecZ (explicitOutputs): call fe or qe
         % recall: vecZ = qedot(vecX,vecY,parms) + fe(vecX,vecY,parms,u(t)) %(e denotes explicit)
        if 1 == eff
            if 1 == elModel.support_initlimiting
                vecZ = feval(elModel.fe, vecX, vecY, vecLim, vecU, elModel); % f: size l = length(ExplicitOutputs)
            else
                vecZ = feval(elModel.fe, vecX, vecY, vecU, elModel); % f: size l = length(ExplicitOutputs)
            end
            if 1 == derivs_wanted
                if 1 == ddx
                    if 1 == elModel.support_initlimiting
                        dvecZ_dvecX = feval(elModel.dfe_dvecX, vecX, vecY, vecLim, vecU, elModel);
                        dvecZ_dvecY = feval(elModel.dfe_dvecY, vecX, vecY, vecLim, vecU, elModel);
                    else
                        dvecZ_dvecX = feval(elModel.dfe_dvecX, vecX, vecY, vecU, elModel);
                        dvecZ_dvecY = feval(elModel.dfe_dvecY, vecX, vecY, vecU, elModel);
                    end
                elseif 0 == ddx % ddu
                    if 1 == elModel.support_initlimiting
                        dvecZ_dvecU = feval(elModel.dfe_dvecU, vecX, vecY, vecLim, vecU, elModel);
                    else
                        dvecZ_dvecU = feval(elModel.dfe_dvecU, vecX, vecY, vecU, elModel);
                    end
                else % ddxlim
                    if 1 == elModel.support_initlimiting
                        dvecZ_dvecXlim = feval(elModel.dfe_dvecLim, vecX, vecY, vecLim, vecU, elModel);
                    end
                end
            end
        else
            if 1 == elModel.support_initlimiting
                vecZ = feval(elModel.qe, vecX, vecY, vecLim, elModel); % q: size l = length(ExplicitOutputs)
            else
                vecZ = feval(elModel.qe, vecX, vecY, elModel); % q: size l = length(ExplicitOutputs)
            end
            if 1 == derivs_wanted
                if 1 == ddx
                    if 1 == elModel.support_initlimiting
                        dvecZ_dvecX = feval(elModel.dqe_dvecX, vecX, vecY, vecLim, elModel);
                        dvecZ_dvecY = feval(elModel.dqe_dvecY, vecX, vecY, vecLim, elModel);
                    else
                        dvecZ_dvecX = feval(elModel.dqe_dvecX, vecX, vecY, elModel);
                        dvecZ_dvecY = feval(elModel.dqe_dvecY, vecX, vecY, elModel);
                    end
                elseif 0 == ddx % ddu
                    dvecZ_dvecU = sparse(length(vecZ), DAE.n_inputs);
                else % ddxlim
                    if 1 == elModel.support_initlimiting
                        dvecZ_dvecXlim = feval(elModel.dqe_dvecLim, vecX, vecY, vecLim, elModel);
                    end
                end
            end
        end

        if 1 == derivs_wanted
            if 1 == ddx
                dvecZ_dx = dvecZ_dvecX * el.A_X + dvecZ_dvecY * el.A_Y;
            elseif 0 == ddx % ddu
                dvecZ_du = dvecZ_dvecU * el.A_U;
            else % ddxlim
                if 1 == elModel.support_initlimiting
                    dvecZ_dxlim = dvecZ_dvecXlim * el.A_Xlim;
                end
            end
        end

        % scatter vecZ into fqout; how depends on whether branch current or branch voltage

        % for the 'i' type outputs: f += A_Zi * vecZf; similarly for q
        if ~isempty(vecZ)
            fqout = fqout + el.A_Zi * sparse(vecZ); 
        end
        if 1 == derivs_wanted
            if 1 == ddx
                dfqout = dfqout + el.A_Zi * dvecZ_dx;
            elseif 0 == ddx % ddu
                dfqout = dfqout + el.A_Zi * dvecZ_du;
            else % ddxlim
                if 1 == elModel.support_initlimiting
                    dfqout = dfqout + el.A_Zi * dvecZ_dxlim;
                end
            end
        end

        % for the 'v' type outputs: 
        %   f += A_Zv* (A_Zve*x - vecZf);
        %   q += -A_Zv*vecZq (there is no A_Zv*A_Zve*x component)
        if ~isempty(vecZ)
            fqout = fqout - el.A_Zv*sparse(vecZ);
        end
        if 1 == eff
            fqout = fqout + el.A_Zv*el.A_Zve*sparse(x);
        end

        if 1 == derivs_wanted
            if 1 == ddx
                dfqout = dfqout - el.A_Zv * dvecZ_dx;
                if 1 == eff
                    dfqout = dfqout + el.A_Zv*el.A_Zve;
                end
            elseif 0 == ddx % ddu
                dfqout = dfqout - el.A_Zv * dvecZ_du;
            else % ddxlim
                if 1 == elModel.support_initlimiting
                    dfqout = dfqout - el.A_Zv * dvecZ_dxlim;
                end
            end
        end

        % compute vecW (device's ImplicitEquations): call fi or qi
        % recall: vecW = qidot(vecX,vecY,parms) + fi(vecX,vecY,parms,u(t)) = 0 % (i denotes implicit)

        nMlpm = length(feval(elModel.ImplicitEquationNames, elModel));
        if nMlpm > 0
            if 1 == eff
                if 1 == elModel.support_initlimiting
                    vecW = feval(elModel.fi, vecX, vecY, vecLim, vecU, elModel);
                else
                    vecW = feval(elModel.fi, vecX, vecY, vecU, elModel);
                end
            else
                if 1 == elModel.support_initlimiting
                    vecW = feval(elModel.qi, vecX, vecY, vecLim, elModel);
                else
                    vecW = feval(elModel.qi, vecX, vecY, elModel);
                end
            end

            %% contribute vecW into fqout
            fqout(el.ImplicitEqn_indices_into_fq(:),1) = fqout(el.ImplicitEqn_indices_into_fq(:),1) + vecW;
            % the above is the same as fqout += el.A_W * vecW

            if 1 == derivs_wanted
                if 1 == eff
                    if 1 == ddx
                        if 1 == elModel.support_initlimiting
                            dvecW_dvecX = feval(elModel.dfi_dvecX, vecX, vecY, vecLim, vecU, elModel);
                            dvecW_dvecY = feval(elModel.dfi_dvecY, vecX, vecY, vecLim, vecU, elModel);
                        else
                            dvecW_dvecX = feval(elModel.dfi_dvecX, vecX, vecY, vecU, elModel);
                            dvecW_dvecY = feval(elModel.dfi_dvecY, vecX, vecY, vecU, elModel);
                        end
                    elseif 0 == ddx % ddu
                        if 1 == elModel.support_initlimiting
                            dvecW_dvecU = feval(elModel.dfi_dvecU, vecX, vecY, vecLim, vecU, elModel);
                        else
                            dvecW_dvecU = feval(elModel.dfi_dvecU, vecX, vecY, vecU, elModel);
                        end
                    else % ddxlim
                        if 1 == elModel.support_initlimiting
                            dvecW_dvecLim = feval(elModel.dfi_dvecLim, vecX, vecY, vecLim, vecU, elModel);
                        end
                    end
                else
                    if 1 == ddx
                        if 1 == elModel.support_initlimiting
                            dvecW_dvecX = feval(elModel.dqi_dvecX, vecX, vecY, vecLim, elModel);
                            dvecW_dvecY = feval(elModel.dqi_dvecY, vecX, vecY, vecLim, elModel);
                        else
                            dvecW_dvecX = feval(elModel.dqi_dvecX, vecX, vecY, elModel);
                            dvecW_dvecY = feval(elModel.dqi_dvecY, vecX, vecY, elModel);
                        end
                    elseif 0 == ddx % ddu
                        dvecW_dvecU = sparse(nMlpm, DAE.n_inputs);
                    else % ddxlim
                        if 1 == elModel.support_initlimiting
                            dvecW_dvecLim = feval(elModel.dqi_dvecLim, vecX, vecY, vecLim, elModel);
                        end
                    end
                end
                if 1 == ddx
                    dvecW_dx = dvecW_dvecX * el.A_X + dvecW_dvecY * el.A_Y;
                    dfqout = dfqout + el.A_W * dvecW_dx;
                elseif 0 == ddx % ddu
                    dvecW_du = dvecW_dvecU * el.A_U;
                    dfqout = dfqout + el.A_W * dvecW_du;
                else % ddxlim
                    if 1 == elModel.support_initlimiting
                        dvecW_dxlim = dvecW_dvecLim * el.A_Xlim;
                        dfqout = dfqout + el.A_W * dvecW_dxlim;
                    end
                end
            end % derivs_wanted
        end % ImplicitEquations
    end % looping through the elements
end % fq(...)


function out = fqJ(x, xlim, u, flag, DAE)

    if ~isfield(flag, 'f')
        flag.f = 0;
    end

    if ~isfield(flag, 'q')
        flag.q = 0;
    end

    if ~isfield(flag, 'dfdx')
        flag.dfdx = 0;
    end

    if ~isfield(flag, 'dqdx')
        flag.dqdx = 0;
    end

    if ~isfield(flag, 'dfdxlim')
        flag.dfdxlim = 0;
    end

    if ~isfield(flag, 'dqdxlim')
        flag.dqdxlim = 0;
    end

    if ~isfield(flag, 'dfdu')
        flag.dfdu = 0;
    end

    % Initialization
    fout = []; 
    qout = [];
    dfdx = [];
    dqdx = [];
    dfdxlim = [];
    dqdxlim = [];
    dfdu = [];

    % initialize fqout to zeros: POTENTIAL VECVALDER PROBLEM
    if flag.f == 1
        fout = zeros(DAE.n_eqns,DAE.n_unks)*x; % HACK to make fqout the right-sized vecvalder 
    end
    if flag.q == 1
        qout = zeros(DAE.n_eqns,DAE.n_unks)*x; % HACK to make fqout the right-sized vecvalder 
    end
    % if either x or u is a vecvalder - seems to work
    if DAE.n_inputs > 0 && length(u) > 0
        if flag.f == 1
            fout = fout + zeros(DAE.n_eqns,DAE.n_inputs)*u;
        end
        if flag.q == 1
            qout = qout + zeros(DAE.n_eqns,DAE.n_inputs)*u;
        end
    end
    if flag.f == 1
        fout = sparse(fout);
    end
    if flag.q == 1
        qout = sparse(qout);
    end

    if flag.dfdx == 1
        dfdx = sparse(DAE.n_eqns, DAE.n_unks);
    end
    if flag.dqdx == 1
        dqdx = sparse(DAE.n_eqns, DAE.n_unks);
    end
    if flag.dfdu == 1
        dfdu = sparse(DAE.n_eqns, DAE.n_inputs);
    end
    % dqdu = sparse(DAE.n_eqns, DAE.n_inputs);
    if flag.dfdxlim == 1
        dfdxlim = sparse(DAE.n_eqns, DAE.n_limitedvars);
    end
    if flag.dqdxlim == 1
        dqdxlim = sparse(DAE.n_eqns, DAE.n_limitedvars);
    end

    % loop through the elements
    elements = DAE.circuitdata.elements;
    nelements = length(elements);
    for i = 1:nelements
        el = DAE.circuitdata.elements{i};
        elModel = el.model; % there is a separate one for each device
        elname = el.name;
        %    el.node_voltage_indices_into_x(:)
        %    el.refnode_index_into_x
        %    el.v_otherIO_nodeindices_into_x(:)
        %    el.i_otherIO_indices_into_x
        %    el.internal_unk_indices_into_x

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% set up vecX, vecY, vecU for the device
        vecX = el.A_X * x;
        vecY = el.A_Y * x;
        if 1 == elModel.support_initlimiting
            vecLim = el.A_Xlim * xlim;
        else
            vecLim = [];
        end

        % setting up vecU
        if length(u) > 0 % u can be [] for q calls, in which case vecU won't be needed
            vecU = u(el.u_indices_into_cktu(:)); % CHECK VECVALDER
        else
            vecU = []; % for q calls
        end
        % note: the above is equivalent to vecU = A_U*u

        %% done setting up vecX, vecY, vecU for the device
        %%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%% Evaluate model %%%%%%%%%%%%%%%%%%%
        elflag.fe = 0;
        elflag.fi = 0;
        elflag.qe = 0;
        elflag.qi = 0;
        nMlpm = length(feval(elModel.ImplicitEquationNames, elModel));

        if flag.f == 1
            elflag.fe = 1;
            if nMlpm > 0
                elflag.fi = 1;
            end
        end
        if flag.q == 1
            elflag.qe = 1;
            if nMlpm > 0
                elflag.qi = 1;
            end
        end

        elflag.J = 1;
        if 1 == elModel.support_initlimiting
            [fqei, J] = feval(elModel.fqeiJ, vecX, vecY, vecLim, vecU, elflag, elModel);
        else
            [fqei, J] = feval(elModel.fqeiJ, vecX, vecY, vecU, elflag, elModel);
        end
        % [fvecZ, qvecZ, fvecW, qvecW] = feval(elModel.fqeiJ, vecX, vecY, vecLim, vecU, elflag, elModel);
        fvecZ = sparse(fqei.fe);
        qvecZ = sparse(fqei.qe);
        fvecW = sparse(fqei.fi);
        qvecW = sparse(fqei.qi);

        fdvecZ_dvecX = J.Jfe.dfe_dvecX; qdvecZ_dvecX = J.Jqe.dqe_dvecX; 
        fdvecW_dvecX = J.Jfi.dfi_dvecX; qdvecW_dvecX = J.Jqi.dqi_dvecX;
        fdvecZ_dvecY = J.Jfe.dfe_dvecY; qdvecZ_dvecY = J.Jqe.dqe_dvecY; 
        fdvecW_dvecY = J.Jfi.dfi_dvecY; qdvecW_dvecY = J.Jqi.dqi_dvecY;

        if 1 == elModel.support_initlimiting
            fdvecZ_dvecXlim = J.Jfe.dfe_dvecLim; qdvecZ_dvecXlim = J.Jqe.dqe_dvecLim;
            fdvecW_dvecXlim = J.Jfi.dfi_dvecLim; qdvecW_dvecXlim = J.Jqi.dqi_dvecLim;
        end
        
        fdvecZ_dvecU = J.Jfe.dfe_dvecU; fdvecW_dvecU = J.Jfi.dfi_dvecU;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % The following parts are mapping the element output to DAE output.
        if flag.f ==1
            fout = fout + el.A_fX * sparse(vecX);
            if ~isempty(fvecZ)
                fout = fout + el.A_Zi * fvecZ; 
                fout = fout - el.A_Zv * fvecZ;
            end
            fout = fout + el.A_Zv*el.A_Zve*sparse(x);
        end

        if flag.q == 1
            if ~isempty(qvecZ)
                qout = qout + el.A_Zi * qvecZ;
                qout = qout - el.A_Zv * qvecZ;
            end
        end

        if flag.dfdx == 1
            dfdx = dfdx + el.A_fX * el.A_X;
            fdvecZ_dx = fdvecZ_dvecX * el.A_X + fdvecZ_dvecY * el.A_Y;
            dfdx = dfdx + el.A_Zi * fdvecZ_dx;
            dfdx = dfdx - el.A_Zv * fdvecZ_dx;
            dfdx = dfdx + el.A_Zv*el.A_Zve;
        end

        if flag.dqdx == 1
             qdvecZ_dx = qdvecZ_dvecX * el.A_X + qdvecZ_dvecY * el.A_Y;
             dqdx = dqdx + el.A_Zi * qdvecZ_dx;
             dqdx = dqdx - el.A_Zv * qdvecZ_dx;
        end

        if flag.dfdu == 1
            fdvecZ_du = fdvecZ_dvecU * el.A_U;
            dfdu = dfdu + el.A_Zi * fdvecZ_du;
            dfdu = dfdu - el.A_Zv * fdvecZ_du;
        end

        if flag.dfdxlim == 1
            if 1 == elModel.support_initlimiting
                fdvecZ_dxlim = fdvecZ_dvecXlim * el.A_Xlim;
                dfdxlim = dfdxlim + el.A_Zi * fdvecZ_dxlim;
                dfdxlim = dfdxlim - el.A_Zv * fdvecZ_dxlim;
            end
        end

        if flag.dqdxlim == 1
            if 1 == elModel.support_initlimiting
                qdvecZ_dxlim = qdvecZ_dvecXlim * el.A_Xlim;
                dqdxlim = dqdxlim + el.A_Zi * qdvecZ_dxlim;
                dqdxlim = dqdxlim - el.A_Zv * qdvecZ_dxlim;
            end
        end

        if nMlpm > 0
            if flag.f == 1
                 fout(el.ImplicitEqn_indices_into_fq(:),1) = fout(el.ImplicitEqn_indices_into_fq(:),1) + fvecW;
            end 
            if flag.q == 1
                qout(el.ImplicitEqn_indices_into_fq(:),1) = qout(el.ImplicitEqn_indices_into_fq(:),1) + qvecW;
            end 

            if flag.dfdx == 1
                 fdvecW_dx = fdvecW_dvecX * el.A_X + fdvecW_dvecY * el.A_Y;
                 dfdx = dfdx + el.A_W * fdvecW_dx;
            end 

            if flag.dqdx == 1
                 qdvecW_dx = qdvecW_dvecX * el.A_X + qdvecW_dvecY * el.A_Y;
                 dqdx = dqdx + el.A_W * qdvecW_dx;
            end 

            if flag.dfdu == 1
                 fdvecW_du = fdvecW_dvecU * el.A_U;
                 dfdu = dfdu + el.A_W * fdvecW_du;
            end 
            % else % ddxlim
            if flag.dfdxlim == 1
                if 1 == elModel.support_initlimiting
                    fdvecW_dxlim = fdvecW_dvecXlim * el.A_Xlim;
                    dfdxlim = dfdxlim + el.A_W * fdvecW_dxlim;
                end
            end 

            if flag.dqdxlim == 1
                if 1 == elModel.support_initlimiting
                    qdvecW_dxlim = qdvecW_dvecXlim * el.A_Xlim;
                    dqdxlim = dqdxlim + el.A_W * qdvecW_dxlim;
                end
            end 
        end % ImplicitEquations
    end % looping through the elements

    out.f = full(fout); 
    out.q = full(qout);
    out.dfdx = dfdx;
    out.dqdx = dqdx;
    out.dfdxlim = dfdxlim;
    out.dqdxlim = dqdxlim;
    out.dfdu = dfdu;
end % fqJ(...)

function [out, dout] = init_limiting(x, xlimOld, u, DAE, init_or_limiting)
    if 1 == strcmp('init', init_or_limiting)
        init = 1;
    elseif 1 == strcmp('limiting', init_or_limiting)
        init = 0;
    else
        error('init_or_limiting should be init or limiting');
    end

    if nargout > 1
        derivs_wanted = 1;
    else
        derivs_wanted = 0;
    end

    % initialize out to zeros: POTENTIAL VECVALDER PROBLEM
    out = zeros(DAE.n_limitedvars,DAE.n_unks)*x; % HACK to make out the right-sized vecvalder 
    if DAE.n_inputs > 0 && length(u) > 0
        out = out + zeros(DAE.n_limitedvars,DAE.n_inputs)*u;
    end

    % set up a sparse matrix of the right size for the derivatives
    if 1 == derivs_wanted
        dout = sparse(DAE.n_limitedvars, DAE.n_unks);
    end

    % loop through the elements
    elements = DAE.circuitdata.elements;
    nelements = length(elements);
    for i = 1:nelements
        el = DAE.circuitdata.elements{i};
        elModel = el.model; % there is a separate one for each device
        elname = el.name;

        if 1 == elModel.support_initlimiting
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% set up vecX, vecY, vecU for the device
            vecX = el.A_X * x;
            vecY = el.A_Y * x;
            if 0 == init % limiting
                vecLimOld = el.A_Xlim * xlimOld;
            end

            % setting up vecU
            if length(u) > 0 % u can be [] for q calls, in which case vecU won't be needed
                vecU = u(el.u_indices_into_cktu(:)); % CHECK VECVALDER
            else
                vecU = []; % for q calls
            end
            %% done setting up vecX, vecY, vecU for the device
            %%%%%%%%%%%%%%%%%%%

            if 0 == init % limiting
                vecLim = feval(elModel.limiting, vecX, vecY, vecLimOld, vecU, elModel);
                if 1 == derivs_wanted
                    dvecLim_dvecX = feval(elModel.dlimiting_dvecX, vecX, vecY, vecLimOld, vecU, elModel);
                    dvecLim_dvecY = feval(elModel.dlimiting_dvecY, vecX, vecY, vecLimOld, vecU, elModel);
                    dvecLim_dx = dvecLim_dvecX * el.A_X + dvecLim_dvecY * el.A_Y;
                end
            else % initialization
                vecLim = feval(elModel.initGuess, vecU, elModel);
            end

            % scatter vecLim into out
            if ~isempty(el.A_Xlim.' * vecLim)
                out = out + el.A_Xlim.' * vecLim;
            end
            if 1 == derivs_wanted
                dout = dout + el.A_Xlim.' * dvecLim_dx;
            end
        end
    end % loop through devices
end % init_limiting(...)

function [fout, qout] = DAE_fq(x, xlim, u, flag, DAE)
    if 4 == nargin
        DAE = flag; flag = u; u = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    flag.dfdx = 0;
    flag.dfdxlim = 0;
    flag.dfdu = 0;
    flag.dqdx = 0;
    flag.dqdxlim = 0;
    out = fqJ(x, xlim, u, flag, DAE);
    fout = out.f;
    qout = out.q;
end % DAE_fq

function out = DAE_fqJ(x, xlim, u, flag, DAE)
    if 4 == nargin
        DAE = flag; flag = u; u = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
        flag.dfdxlim = 1; flag.dqdxlim = 1;
    end
    out = fqJ(x, xlim, u, flag, DAE);
    if 4 == nargin
        out.dfdx = out.dfdx + out.dfdxlim * DAE.xTOxlimMatrix(DAE);
        out.dqdx = out.dqdx + out.dqdxlim * DAE.xTOxlimMatrix(DAE);
        out.dfdxlim = []; 
        out.dqdxlim = [];
    end
end % DAE_fqJ

function fout = f(x, xlim, u, DAE)
    if 3 == nargin
        DAE = u; u = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    fout = fq(x, xlim, u, DAE, 'f', []);
end % f

function qout = q(x, xlim, DAE)
    if 2 == nargin
        DAE = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    qout = fq(x, xlim, [], DAE, 'q', []);
end % q

function dfdx = df_dx(x, xlim, u, DAE)
    if 3 == nargin
        DAE = u; u = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    [fout, dfdx] = fq(x, xlim, u, DAE, 'f', 'x');
    if 3 == nargin
        dfdx = dfdx + ...
               df_dxlim(x, xlim, u, DAE)...
               *feval(DAE.xTOxlimMatrix, DAE);
    end
end % df_dx()

function dfdxlim = df_dxlim(x, xlim, u, DAE)
    [fout, dfdxlim] = fq(x, xlim, u, DAE, 'f', 'xlim');
end % df_dxlim()

function dfdu = df_du(x, xlim, u, DAE)
    if 3 == nargin
        DAE = u; u = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end
    [fout, dfdu] = fq(x, xlim, u, DAE, 'f', 'u');
end % df_du()

function dqdx = dq_dx(x, xlim, DAE)
    if 2 == nargin
        DAE = xlim;
        xlim = feval(DAE.xTOxlim, x, DAE);
    end

    [fout, dqdx] = fq(x, xlim, [], DAE, 'q', 'x');

    if 2 == nargin
        dqdx = dqdx + ...
               dq_dxlim(x, xlim, DAE) ...
               *feval(DAE.xTOxlimMatrix, DAE);
    end
end % dq_dx()

function dqdxlim = dq_dxlim(x, xlim, DAE)
    [fout, dqdxlim] = fq(x, xlim, [], DAE, 'q', 'xlim');
end % dq_dxlim()

function xlim = NRlimiting(x, xlimOld, u, DAE)
    xlim = init_limiting(x, xlimOld, u, DAE, 'limiting');
end % NRlimiting()

function dxlimdx = dNRlimiting_dx(x, xlimOld, u, DAE)
    [xlim, dxlimdx] = init_limiting(x, xlimOld, u, DAE, 'limiting');
end % dNRlimiting_dx()

function xlim = NRinitGuess(u, DAE)
    xlim = init_limiting(zeros(feval(DAE.nunks, DAE), 1), [], u, DAE, 'init');
end % NRinitGuess

%%%%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt x, u %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to be obtained using vecvalder

%%%%%%%%%%%%%%%%%%% FIRST DERIVATIVES wrt parms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% INPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = B(DAE)
    out = []; % not used?
end % B(...)

%{
EVERYTHING NOW MOVED TO DAEAPI_input_add_ons:
Dealing with inputs:

- recap of how it used to be done for DAEPI (the old_u way):
  - uQSS: the DAE keeps a static vector called uQSSvec, which is returned by uQSS and set by set_uQSS
  - utransient: the DAE keeps a function handle called utfunc and an object called utargs. utransient returns
          utfunc(t, utargs), and set_utransient sets utfunc and utargs.
  - uLTISSS: the DAE keeps a function handle Uffunc and an object called Ufargs, operating similarly to utransient

- what we want to do here (this is something we should do for DAEAPI generally):
  - we'd like to enable setting EACH SCALAR INPUT separately
  - we'd also like to be able to set the entire cktu in one shot (as standard DAEAPI does)
  - here's how we are doing it: OBSOLETE, NEEDS UPDATE
    - at constructor time: 
      - default_uQSSvec is populated with the uQSSvecs from the models and kept
      - utfunc is set to default_utfunc, which iterates through the models and evaluates their utransients
      - ditto for default_Uffunc
      - set_uQSS does not touch the models or default_uQSSvec. Instead, it keeps a list of the scalar inputs
        (the updated_inputs list) that have been changed, and their new values.
    - uQSS first populates its return value with default_uQSS, then overwrites the scalar components that
      have been updated by looking at the updated_inputs list, then returns this.
      - similarly, set_utransient does not touch the default_utfunc. Instead, it keeps a list of the scalar inputs
        (the updated_inputs list) that have been changed, their new scalar utfuncs, and the new utargs. 
    - utransient first calls default_utfunc, then overrides the scalar components that have been updated
      by looking at the updated_inputs list and calling each scalar utfunc in there, then returns this.
      - similarly with set_uLTISSS and uLTISSS
%}

%%%%%%%%%%%%%%%%%%%%%% OUTPUT-related functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = C(DAE)
    out = DAE.output_matrix;
end % C(...)

function out = D(DAE)
    out = zeros(DAE.n_outputs, DAE.n_inputs);
end % D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
% function out = NRinitGuess(u, DAE)         % NOT WRITTEN YET
%     % in principle, could use some heuristic dependent on the input
%     % and the parameters,
%     out = zeros(DAE.n_unks,1);
% end %NRinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
% function newdx = NRlimiting(dx, xold, u, DAE)     % NOT WRITTEN YET
%     newdx = dx;
% end % NRlimiting

%%%%%%%%%%%%%%%%%%%%% NOISE SUPPORT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
function out = NoiseStationaryComponentPSDmatrix(f,DAE) % NOT WRITTEN YET, WON'T WORK
    % in the same order as for NoiseSourceNames
    % returns a square PSD matrix of size nNoiseSources
    % NOTE: these should be one-sided PSDs
    m = nNoiseSources(DAE);
    out = speye(m);
    % unit PSDs; all the action is moved to m(x,n)
end %NoiseStationaryComponentPSDmatrix(f,DAE)

function out = m(x,n,DAE)
    % NOTE: m should be for one-sided PSDs
    % M is of size neqns. n is of size nNoiseSources
    %
    M = dm_dn(x,n,DAE);
    out = M*n;
end % m(x,n,DAE)

function Jm = dm_dx(x,n,DAE)
    n = nunks(DAE);
    Jm = sparse([]);
    Jm(n,n) = 0;
end % dm_dx(x,n,DAE)

function M = dm_dn(x,n,DAE)
    % M is of size neqns. n is of size nNoiseSources
    % NOTE: M should be for one-sided PSDs
    %
    n = neqns(DAE);
    m = nNoiseSources(DAE);
    M = sparse(n, m);
end % dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
    ifs = 'No internal functions exposed by this DAE system.';
    % TODO: delete these. only for debug
    ifs.fq = @fq;
    ifs.fqUsage = 'feval(fq, x, u, DAE, f_or_q, x_or_u, init_on, limiting_on, dx)';
    %ifs.stoichmatfunc = @stoichmatfunc;
    %ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
end % internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

