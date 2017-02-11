function DAE = MNA_EqnEngine(uniqIDstr, circuitdata) % DAEAPIv6.2+delta
%function DAE = MNA_EqnEngine(uniqIDstr, circuitdata) % DAEAPIv6.2+delta
%This is MNA_EqnEngine of SVN version r26, prior to the changes in r27
%- it is kept separately for testing and comparisons.
%author: J. Roychowdhury, 2012/05/01-08, 2012/07/23
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: document how to use this, with examples
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%% Begin main function: DAE "constructor" %%%%%%%%%%%%%%%%%%%%%
% pull in virtual base class:
	DAE = DAEAPI_skeleton_core(); %
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

	% set up the unknowns and equations. n_unks, n_eqns, etc. can be set up here
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

	%{
	recap of device API: THIS WILL BECOME THE API DOCUMENTATION
	 vectors and equations:
	 - vecX: a Core level vector: size 2n-l = nOtherIOs
	 	- these are the IO unknowns for the core equation system
	 - vecZ: Core-level vector of all the explicit outputs - size l = nExplicitOutputs
	 - vecY: Core-level vector of all the internal unknowns - size m = nInternalUnksEqns
	 - Core: Explicit Output Equations (size l = nExplicitOutputs):
	 	vecZ = qedot(vecX,vecY,parms) + fe(vecX,vecY,parms,u(t)) %(e denotes explicit)
	       	or
	       vecZ = qedot(vecX,vecY,parms) + fe(vecX,vecY,parms) + be(parms,u(t)) 
	 - Core: Implicit Equations: size n+m-l = nImplicitEquations
	 	vecW = qidot(vecX,vecY,parms) + fi(vecX,vecY,parms,u(t)) = 0 % (i denotes implicit)
	       	or 
	 	vecW = qidot(vecX,vecY,parms) + fi(vecX,vecY,parms) + bi(parms,u(t)) = 0 

	 ---- device inputs and outputs ----
	   - to call the device, the network needs to supply it with:
	     a) vecX: a vector of size 2n-l (= nOtherIOs), representing all IOs that are not
	     	 explicit outputs. 
	     b) vecY: a vector of size m (= nInternalUnksEqns), representing the device's internal unknowns
	        This is vecY.

	   - once the device is called, it returns to the network:
	     a) vecZ: l (= nExplicitOutputs) explicit output values
	        - in 2 separate parts: an f part and a q part
	     b) vecW: n+m-l (= nImplicitEquations) values for the implicit equations
	        - f and q parts

	 ---- electrical network interface layer quantities ----
	 - the device's view of the electrical network it connects to, implemented partly through its
	   Network Interface Layer, is:
	   - there are n+1 nodes (internal names given by NIL.NodeNames)
	   - there is an internal reference node (given by NIL.RefNodeName)
	   - the above implicitly define n branch voltage quantities and n branch current quantities:
	     - the Core level IOnames are exactly these, in the order 
	     		{ {v_NodeNames_RefNodeName}, {i_NodeNames_RefNodeName}}
		- NIL.IOnodenames and NIL.IOtypes specify this order: 
			- if IOnames(idx) is an IO, then NIL.IOnodenames(idx) is the nodeName the branch starts
			  from (the other is always RefNode), and NIL.IOtypes(idx) returns 'v' or 'i', telling
			  you whether it is the branch voltage or branch current
	   - l of the IOs are explicit outputs; their names are given by ExplicitOutputNames
	     - the order of ExplicitOutputNames specifies the order of vecZ
	     - ExplicitOutputNames are taken out (in place) from IOnames to produce OtherIONames, 
	       which specifies the order of vecX
	   - finally, there are m internal unknowns, given by InternalUnkNames


	 ---- how does the network set up vecX and vecY for the device? -----
	   - for MNA:
	     - look through the otherIOs, which specifies vecX:
	       - if an otherIO is of type v, it is a branch voltage. find its index in otherIOs (idx2),
	         find the node defining the branch
	         (using NIL.IOnodeNames and NIL.IOtypes), and store the index of this node's voltage in the circuit
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
		   At eval time, use the above stored indices to get eNode (and eRef) from x, compute
		   eNode-eREF - the_v_output, and put the result in the appropriate circuit KCL's f component, using
		   the stored index to this circuit equation.
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
	%}

	% start with the nodes in the circuit: set up node voltage unknowns and KCL equations. Initialize
	% ckt input and parameter related data
	
	n_unks = length(DAE.circuitdata.nodenames); % node voltage unknowns
	n_eqns = length(DAE.circuitdata.nodenames); % node KCLs
	unk_names = strcat('e_', DAE.circuitdata.nodenames); % names of node voltage unknowns
	eqn_names = strcat('KCL_', DAE.circuitdata.nodenames); % names of KCL equations for the nodes

	n_inputs = 0;
	input_names = {};

	n_parms = 0;
	parm_names = {};
	parm_default_vals = {};

	element_names = {};

	DAE.separatorString = ':::'; % a string that goes between element names and element parm/unknown/eqn etc.
				     % names when forming circuit-level names from element-level names.
				     % it MUST be unique enough not to appear in any string it helps concatenate,
				     % otherwise strfind in, eg, getparms, setparms, etc., will fail
				     % '-->' or '|->' might also be good choices

	% iterate through the elements, adding current and internal unknowns, KVL and implicit equations
	for i = 1:length(DAE.circuitdata.elements);
		el = DAE.circuitdata.elements{i};
		elModel = el.model; % there is a separate one for each device
		elname = el.name;
		elNodes = el.nodes;
		elParms = el.parms;
		prefix = sprintf('%s%s', elname, DAE.separatorString);

		% first, set model/device parameters: unks/eqns/etc. may depend on their values
		elModel_w_updated_parms = feval(elModel.setparms, elParms, elModel);
		DAE.circuitdata.elements{i}.model = elModel_w_updated_parms;

		% set up a simple cell array of all element names - helps find the index in DAE.circuitdata.elements{:}
		% from an element name
		element_names{i} = elname;

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% set up circuit unknowns in x, and create pointers to the circuit unknown x to help set up 
		% device unknowns vecX and vecY at eval time. In particular, set up the following:
		% 	DAE.circuitdata.elements{i}.node_voltage_indices_into_x(:)
		% 	DAE.circuitdata.elements{i}.refnode_index_into_x
		%	DAE.circuitdata.elements{i}.v_otherIO_nodeindices_into_x(:)
		%	DAE.circuitdata.elements{i}.i_otherIO_indices_into_x
		%	DAE.circuitdata.elements{i}.internal_unk_indices_into_x

		%% look through the device's nodes, allocate node voltages in x, and make links to x vector unknowns
		nodenames_internal = feval(elModel.NIL.NodeNames, elModel);
		if length(elNodes) ~= length(nodenames_internal)
			error(sprintf('length of device %s''s internal node list different from that of its external node connections', elname));
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
		% use: % x(refnode_index_into_x) is node voltage of the device's reference node
		% subtract this from other node values to find branch voltages

		%% look through otherIOs, act depending on type: 'v' or 'i'
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
				unk_names{n_unks} = sprintf('%s%s', prefix, oio{:}); % for some reason oio is a 1x1
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

		%% add unknowns (and links) for the device's internal unknowns
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
				else
					error(sprintf('explicit output %s not of type i or v in %s', eo, elname));
				end
			end
		end

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

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% inputs
	DAE.n_inputs = n_inputs;
	DAE.input_names = input_names;

	% the rest pulled in from DAEAPI_input_add_ons

	% parameters
	DAE.n_parms = n_parms;
	DAE.parm_names = parm_names;
	DAE.parm_default_vals = parm_default_vals;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% set up the standard DAEAPI function pointers

	%
% sizes: 
	DAE.nunks = @nunks;
	DAE.neqns = @neqns;
	DAE.ninputs = @ninputs;
	DAE.noutputs = @noutputs;
	%
% f, q: 
	DAE.f_takes_inputs = 1;
	DAE.f = @f;
	DAE.q = @q;
	%
% df, dq
	DAE.df_dx = @df_dx_DAEAPI_auto;
	DAE.dq_dx = @dq_dx_DAEAPI_auto;
	DAE.df_du = @df_du_DAEAPI_auto;
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
	DAE.unknames  = @unknames;
	DAE.eqnnames  = @eqnnames;
	DAE.inputnames  = @inputnames;
	DAE.outputnames  = @outputnames;
	DAE.renameUnks = @renameUnks_DAEAPI;
	DAE.renameEqns = @renameEqns_DAEAPI;
	DAE.renameParms = @renameParms_DAEAPI;
	%
% QSS initial guess support
	DAE.QSSinitGuess = @QSSinitGuess;
	%
% NR limiting support
	DAE.NRlimiting = @NRlimiting;
	%
% parameter support - see also input- and output-related function sections
	DAE.nparms = @nparms;
	DAE.parmdefaults  = @parmdefaults;
	DAE.parmnames = @parmnames;
	DAE.getparms  = @newgetparms; % get parms from elements: don't use default DAEAPI getparms
	DAE.setparms  = @newsetparms; % set parms inside elements: don't use default DAEAPI setparms
	% first derivatives with respect to parameters - for sensitivities
	% DAE.df_dp  = @df_dp; TBD
	% DAE.dq_dp  = @dq_dp; TBD
	% data: current values of parameters, can be changed by setparms
	%
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

function out = noutputs(DAE)
	% this comes from the user/netlist, of course, but for the moment, all unknowns
	out = DAE.n_unks;
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
%	% why a separate setup_unknames and unknames? forgotten
%	% these specify the order of the DAE's x vector
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

function out = outputnames(DAE)
	% for the moment, all unks are outputs
	out = DAE.unk_names;
end % outputnames()

%parmnames is in parmnames.m
%function out = setup_parmnames(DAE)
	% why a separate setup_parmnames and parmnames? forgotten
function out = parmnames(DAE)
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
		pidx = find(strcmp(pname, DAE.parm_names));
		if (length(pidx) < 1)
			fprintf(1, 'parameter %s not found in DAE.\n', pname);
			parmvals = {};
			return;
		elseif (length(pidx) > 1)
			fprintf(1, 'parameter %s seems to be multiply defined. Please fix DAE.parmnames()!\n', ...
				pname);
			parmvals = {};
			return;
		else
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
		pidx = find(strcmp(pname, DAE.parm_names));
		if (length(pidx) < 1)
			fprintf(1, 'parameter %s not found in DAE.\n', pname);
			outDAE = DAE;
			return;
		elseif (length(pidx) > 1)
			fprintf(1, 'parameter %s seems to be multiply defined. Please fix DAE.parmnames()!\n', pname);
			outDAE = DAE;
			return;
		else
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

			% set parm inside element and update DAE.circuitdata.elements{elidx}.model
			DAE.circuitdata.elements{elidx}.model = feval(elModel.setparms, elParmName, newvals{i}, elModel);
		end
	end

	outDAE = DAE;
end % setparms


%%%%%%%%%%%%%%%%%%%%%%%%%%%% CORE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fqout = fq(x, u, DAE, f_or_q)
	if 1 == strcmp('f', f_or_q)
		eff = 1;
	elseif 1 == strcmp('q', f_or_q)
		eff = 0;
	else
		error('f_or_q should be either f or q');
	end
	% initialize fqout to zeros: POTENTIAL VECVALDER PROBLEM
	fqout = zeros(DAE.n_eqns,DAE.n_unks)*x; % HACK to make fqout the right-sized vecvalder 
						% if either x or u is a vecvalder - seems to work
	if DAE.n_inputs > 0 && length(u) > 0
		fqout = fqout + zeros(DAE.n_eqns,DAE.n_inputs)*u;
	end
	% loop through the elements
	elements = DAE.circuitdata.elements;
	nelements = length(elements);

	%fprintf(2, 'OLD: looping through all the elements\n');

	for i = 1:nelements
		el = DAE.circuitdata.elements{i};
		elModel = el.model; % there is a separate one for each device
		elname = el.name;
		% 	el.node_voltage_indices_into_x(:)
		% 	el.refnode_index_into_x
		%	el.v_otherIO_nodeindices_into_x(:)
		%	el.i_otherIO_indices_into_x
		%	el.internal_unk_indices_into_x

	%fprintf(2, 'OLD: element %s:\n', elname);
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% set up vecX, vecY, uvals for the device

		% setting up vecX: go through device's otherIOs
		ioNames = feval(elModel.IOnames, elModel);
		ioTypes = feval(elModel.NIL.IOtypes, elModel);
		otherIOnames = feval(elModel.OtherIONames, elModel);
		% get the voltage of the device's internal reference reference node out of x
		if 0 == el.refnode_index_into_x 
			elRefNodeVal = 0;
		else
			elRefNodeVal = x(el.refnode_index_into_x,1); % CHECK IF OK WITH VECVALDER
		end
		refnodeKCLidx = el.refnode_index_into_x; % node voltage idx doubles as node KCL idx
		for oio = otherIOnames
			idx_in_otherIOs = find(strcmp(oio, otherIOnames));
			idx_in_IOs = find(strcmp(oio, ioNames));
			if 1 ~= length(idx_in_IOs)
				error(sprintf('otherIO %s found more than once in device %s''s IOs', ...
					oio, elname));
			end
			if 1==strcmp('v', ioTypes{idx_in_IOs})
				% we have a branch voltage otherIO
				nodevoltage_index_in_x = el.v_otherIO_nodeindices_into_x(idx_in_otherIOs);
				if nodevoltage_index_in_x > 0 % non-ground
					nodevoltage = x(nodevoltage_index_in_x,1); % CHECK VECVALDER
				else
					nodevoltage = 0; % CHECK VECVALDER
				end
				vecX(idx_in_otherIOs,1) = nodevoltage - elRefNodeVal; % CHECK VECVALDER
			elseif 1==strcmp('i', ioTypes{idx_in_IOs})
				% we have a branch current otherIO
				% get the value of the corresponding current unknown from x
				brcurrent_idx_in_x = el.i_otherIO_indices_into_x(idx_in_otherIOs);
				brcurrent = x(brcurrent_idx_in_x,1); % CHECK VECVALDER
				vecX(idx_in_otherIOs,1) = brcurrent; % CHECK VECVALDER

				% get the index (into f/q) of the branch current's node's KCL equation.
				nodeKCLidx = el.i_otherIO_KCL_index_into_fq(idx_in_otherIOs);
				% add KCL contributions from this branch current into f 
				if 1 == eff
					if nodeKCLidx > 0 % ie, not ground node KCL
						fqout(nodeKCLidx,1) = fqout(nodeKCLidx,1) + brcurrent;
					end
					if refnodeKCLidx > 0 % ie, not ground node KCL
						fqout(refnodeKCLidx,1) = fqout(refnodeKCLidx,1) - brcurrent;
					end
				end % no q components here
			end
		end

		%vecX
		%fprintf(2,'fqout after i otherIO contributions: '); fqout

		% setting up vecY
		vecY = x(el.intunk_indices_into_x(:)); % CHECK VECVALDER
		%vecY

		% setting up uvals
		if length(u) > 0 % u can be [] for q calls, in which case uvals won't be needed
			uvals = u(el.u_indices_into_cktu(:)); % CHECK VECVALDER
		else
			uvals = []; % for f calls
		end
		%vecU = uvals

		%% done setting up vecX, vecY, uvals for the device
		%%%%%%%%%%%%%%%%%%%

		% KCL contribs from branch-current otherIOs are already inserted into fqout during i-type
		% otherIO vecX setup

		% compute f/q component of vecZ (explicitOutputs): call fe or qe
	 	% recall: vecZ = qedot(vecX,vecY,parms) + fe(vecX,vecY,parms,u(t)) %(e denotes explicit)
		if 1 == eff
			vecZ = feval(elModel.fe, vecX, vecY, uvals, elModel); % size l = length(ExplicitOutputs)
		else
			vecZ = feval(elModel.qe, vecX, vecY, elModel); % size l = length(ExplicitOutputs)
		end

		%vecZ

		% scatter vecZ into fqout; how depends on whether branch current or branch voltage
		eoNames = feval(elModel.ExplicitOutputNames, elModel);
		for j = 1:length(eoNames)
			% find idx of eo in IOnames
			eo = eoNames{j};
			idx_in_IOs = find(strcmp(eo, ioNames));
			if 1 ~= length(idx_in_IOs)
				error(sprintf('explicit output %s not found exactly once in device %s', ...
					eo, elname));
			end
			% action depends on the type of the explicit output: i or v
			if 1==strcmp(ioTypes(idx_in_IOs), 'i')
				% eo is a branch current: contribute it to its node's KCL and also to the
				% device reference node's KCL.
				fidx = el.i_ExplicitOutput_KCLindices_into_fq(j);
				if fidx > 0 % ie, not ground
					fqout(fidx,:) = fqout(fidx,:) + vecZ(j,:); % CHECK VECVALDER
				end
				if refnodeKCLidx > 0 % ie, not ground
					fqout(refnodeKCLidx,:) = fqout(refnodeKCLidx,:) - vecZ(j,:); % CHECK VECVALDER
				end
			elseif 1==strcmp(ioTypes(idx_in_IOs), 'v')
				% eo is a branch voltage: set up its KVL equation eNode-eRefNode - value = 0; 
				nodeidx = el.v_ExplicitOutput_KVLnodeindices_into_x(j);
				if nodeidx > 0  % ie, not ground
					eNode = x(nodeidx,:);
				else
					eNode = 0;
				end
				fidx = el.v_ExplicitOutput_KVLindices_into_fq(j);
				if 1 == eff % eNode -elRefNodeVal has no q component
					fqout(fidx,:) = fqout(fidx,:) + eNode - elRefNodeVal; % CHECK VECVALDER
				end
				fqout(fidx,:) = fqout(fidx,:) - vecZ(j,:); % CHECK VECVALDER
			else
				error(sprintf('explicit output %s not of type i or v in %s', eo, elname));
			end
		end

		%fprintf(2,'fqout after vecZ contributions added: '); fqout

		%% compute vecW (device's ImplicitEquations): call fi or qi
		% recall: vecW = qidot(vecX,vecY,parms) + fi(vecX,vecY,parms,u(t)) = 0 % (i denotes implicit)

		if length(feval(elModel.ImplicitEquationNames, elModel)) > 0
			if 1 == eff
				vecW = feval(elModel.fi, vecX, vecY, uvals, elModel);
			else
				vecW = feval(elModel.qi, vecX, vecY, elModel);
			end

			%vecW

			%% contribute vecW into fqout
			fqout(el.ImplicitEqn_indices_into_fq(:),1) = fqout(el.ImplicitEqn_indices_into_fq(:),1) + vecW;

			%fprintf(2,'fqout after vecW contributions added: '); fqout
		end 
	end % looping through the elements
end % fq(...)

function fout = f(x, u, DAE)
	fout = fq(x, u, DAE, 'f');
end % f

function qout = q(x, DAE)
	qout = fq(x, [], DAE, 'q');
end % q(...)

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
	out = eye(DAE.n_unks); % all unknowns are outputs
end % C(...)

function out = D(DAE)
	out = zeros(DAE.n_unks, DAE.n_inputs);
end % D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function out = QSSinitGuess(u, DAE) 		% NOT WRITTEN YET
	% in principle, could use some heuristic dependent on the input
	% and the parameters,
	out = zeros(DAE.n_unks,1);
end %QSSinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
function newdx = NRlimiting(dx, xold, u, DAE) 	% NOT WRITTEN YET
	newdx = dx;
end % NRlimiting

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
	k = 1.3806503e-23; % Boltzmann's const
	q = 1.60217646e-19; % electronic charge
	T = 300; % Kelvin; absolute temperature FIXME: this should be a parameter

	n = nunks(DAE);
	nn = nNoiseSources(DAE);
	M = sparse([]); M(nsegs,nsegs) = 0;
	M = M*sqrt(4*k*T/R);
end % dm_dn(x,n,DAE)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS EXPOSED BY API %%%%%%%%%%%%%%%%%%%%%%
function ifs = internalfuncs(DAE)
	ifs = 'No internal functions exposed by this DAE system.';
	%ifs.stoichmatfunc = @stoichmatfunc;
	%ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
end % internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
