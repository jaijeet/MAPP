function DAE = STA_EqnEngine(uniqIDstr, circuitdata) % DAEAPIv6.2+delta
%function DAE = ST_EqnEngine(uniqIDstr, circuitdata) % DAEAPIv6.2+delta
% Sparse Tableau equation engine
%author: Bichen Wu 2013/10/28-31 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: document how to use this, with examples
%
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


	% start with the nodes in the circuit: set up node voltage unknowns and KCL equations. Initialize
	% ckt input and parameter related data

	% node voltages	unk
	n_e_unks = length(DAE.circuitdata.nodenames); 
	e_unk_names = strcat('e_', DAE.circuitdata.nodenames); 
	% branch voltage unk
	n_vbr_unks = 0;
	vbr_unk_names = {};
	% branch current unk
	n_ibr_unks = 0;
	ibr_unk_names = {};
	% internal unk
	n_int_unks = 0;
	int_unk_names = {};
	% exp unk
	n_exp_unks = 0;
	exp_unk_names = {};
	% imp unk
	n_imp_unks = 0;
	imp_unk_names = {};

	% node KCLs
	n_KCL_eqns = length(DAE.circuitdata.nodenames); 
	KCL_eqn_names = strcat('KCL_', DAE.circuitdata.nodenames); 
	% branch KVLs
	n_KVL_eqns = 0;
	KVL_eqn_names = {};
	% Branch constitutive relations
	n_BCR_eqns = 0;
	BCR_eqn_names = {};
	% Internal BCRs
	n_int_eqns = 0;
	int_eqn_names = {};
	% BCR exp
	n_exp_eqns = 0;
	exp_eqn_names = {};
	% BCR imp
	n_imp_eqns = 0;
	imp_eqn_names = {};

	n_inputs = 0;
	input_names = {};

	n_limitedvars = 0;
	limitedvar_names = {};

	n_parms = 0;
	parm_names = {};
	parm_default_vals = {};

	element_names = {};

	DAE.separatorString = ':::'; 

	% 1st iteration through the elements, constructing unk X. 
	for i = 1:length(DAE.circuitdata.elements);
		el = DAE.circuitdata.elements{i};
		elModel = el.model; % there is a separate one for each device
		elname = el.name;
		elNodes = el.nodes;
		elParms = el.parms;
		prefix = sprintf('%s%s', elname, DAE.separatorString);

        if ~isempty(elParms)
		    elModel_w_updated_parms = feval(elModel.setparms, elParms, elModel);
		    DAE.circuitdata.elements{i}.model = elModel_w_updated_parms;
        else
		    DAE.circuitdata.elements{i}.model = elModel;
        end


		% set up a simple cell array of all element names - helps find the index in DAE.circuitdata.elements{:}
		% from an element name
		element_names{i} = elname;

		%% look through the device's nodes assign idx, allocate node voltages in x 
		nodenames_internal = feval(elModel.NIL.NodeNames, elModel);
		if length(elNodes) ~= length(nodenames_internal)
			error(sprintf('length of device %s''s internal node list different from that of its external node connections', ...
				elname));
		end
		for j = 1:length(elNodes)
			node = elNodes{j};
			idx = find(strcmp(node, DAE.circuitdata.nodenames)); % index of node voltage in x
			if 1 == length(idx)
				DAE.circuitdata.elements{i}.node_idx(j) = idx;
			elseif 1==strcmp(node, DAE.circuitdata.groundnodename) % it's the ground node
				DAE.circuitdata.elements{i}.node_idx(j) = 0;
			else
				error(sprintf('node %s not found exactly once amongst circuit nodes', node));
			end
		end

		% set up the idx to the the device's reference node
		refnode = feval(elModel.NIL.RefNodeName, elModel);
		refnodeidx_internal = find(strcmp(refnode, nodenames_internal));
		if 1 ~= length(refnodeidx_internal)
			error(sprintf('reference node %s for device %s not found exactly once amongst device''s node list', refnode, elname));
		end
		refnodeidx_in_x = find(strcmp(elNodes{refnodeidx_internal}, DAE.circuitdata.nodenames)); 
		if 1 == length(refnodeidx_in_x)
			DAE.circuitdata.elements{i}.refnode_idx = refnodeidx_in_x;
		elseif 1==strcmp(node, DAE.circuitdata.groundnodename)
			DAE.circuitdata.elements{i}.refnode_idx = 0;
		else
			error(sprintf('reference node %s of device %s not found exactly once in circuit nodes', ... 
				elname, elNodes{refnodeidx_internal}));
		end

		%% for IOs: look through otherIOs, act depending on type: 'v' or 'i'
		ioNames = feval(elModel.IOnames, elModel);
		ioTypes = feval(elModel.NIL.IOtypes, elModel);
		ioNodeNames = feval(elModel.NIL.IOnodeNames, elModel);
		otherIOnames = feval(elModel.OtherIONames, elModel);
		expONames = feval(elModel.ExplicitOutputNames, elModel);
		for io = ioNames
			idx_in_EOs = find(strcmp(io,expONames));
			if 1 == length(idx_in_EOs)
				exp_unk_names = {exp_eqn_names{:},io{:}};
				n_exp_eqns = n_exp_eqns + 1;
				n_exp_unks = n_exp_unks + 1;
			end
			idx_in_IOs = find(strcmp(io, ioNames));
			if 1==strcmp('v', ioTypes{idx_in_IOs})
				vname = io{:};
				iname = io{:}; 
				iname(1) = 'i';
				bname = iname(2:end);

				n_vbr_unks = n_vbr_unks + 1;
				n_ibr_unks = n_ibr_unks + 1;
				n_KVL_eqns = n_KVL_eqns + 1;
				n_BCR_eqns = n_BCR_eqns + 1;

				vbr_unk_names{n_vbr_unks} = sprintf('%s%s',prefix,vname);
				ibr_unk_names{n_ibr_unks} = sprintf('%s%s',prefix,iname);
				KVL_eqn_names{n_KVL_eqns} = sprintf('%s%s',prefix,vname);
				BCR_eqn_names{n_BCR_eqns} = sprintf('%s%s',prefix,bname);

				DAE.circuitdata.elements{i}.IO2br(idx_in_IOs) = n_vbr_unks;

				% This ensures that v and i corresponding to the same port 
				% has the same branch idx
				i_idx_in_IOs = find(strcmp(iname,ioNames));
				if length(i_idx_in_IOs) ~= 1
					error(sprintf('could not find corresponding %s for %s\n',...
					iname, vname));
				end
				DAE.circuitdata.elements{i}.IO2br(i_idx_in_IOs) = n_ibr_unks;
			end
		end

		
		%% for vecY: add unknowns (and links) for the device's internal unknowns
		intUnkNames = feval(elModel.InternalUnkNames, elModel);

		if length(intUnkNames) > 0
			intUnkNames = strcat(prefix, intUnkNames);
			intEqnNames = strcat(prefix, intUnkNames);

			n_intUnks = length(intUnkNames);
			n_intEqns = length(intUnkNames);

			int_unk_names = {int_unk_names{:},intUnkNames{:}};
			int_eqn_names = {int_eqn_names{:},intEqnNames{:}};
			DAE.circuitdata.elements{i}.IU2int = (n_int_unks+1):(n_int_unks+n_intUnks);
			n_int_unks = n_int_unks + n_intUnks;
			n_int_eqns = n_int_eqns + n_intEqns;
		else
			DAE.circuitdata.elements{i}.IU2int = [];
		end 

		% BCRimp
		impEqnNames = feval(elModel.ImplicitEquationNames, elModel);
		n_imp_eqns = n_imp_eqns + length(impEqnNames);
		n_imp_unks = n_imp_unks + length(impEqnNames);

		% done setting up unknowns and unknown pointers
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		if 1 == elModel.support_initlimiting
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% set up limited variables
			limitedVarNames = feval(elModel.LimitedVarNames, elModel);
			if length(limitedVarNames) > 0
				limitedVarNames = strcat(prefix, limitedVarNames);
				limitedvar_names = {limitedvar_names{:}, limitedVarNames{:}};
				nlimitedVar = length(limitedVarNames);
				DAE.circuitdata.elements{i}.limVar2xlim = (n_limitedvars+1):(n_limitedvars+nlimitedVar);
				% use: vecLim = xlim(limvar2xlim(:))
				n_limitedvars = n_limitedvars + nlimitedVar;
			else
				DAE.circuitdata.elements{i}.limVar2xlim = [];
			end 
			% End setting up limited variables
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		end

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% set up circuit inputs and related indices for access
		%% iterate through device's uNames
		uNames = feval(elModel.uNames, elModel);
		nUs = length(uNames);
		if nUs > 0
			tmp = strcat(prefix, uNames);
			[input_names{(n_inputs+1):(n_inputs+nUs)}] = tmp{:};
			DAE.circuitdata.elements{i}.U2U = (n_inputs+1):(n_inputs+nUs);
			n_inputs = n_inputs + nUs;
		else
			DAE.circuitdata.elements{i}.U2U = [];
		end

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% set up all circuit parameters and access functions into the devices
		%% iterate through device's pNames
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

	n_unks = n_e_unks + n_ibr_unks + n_vbr_unks + n_int_unks;
	unk_names = {e_unk_names{:}, vbr_unk_names{:}, ibr_unk_names{:}, int_unk_names{:}};
	n_eqns = n_KCL_eqns + n_KVL_eqns + n_BCR_eqns + n_int_eqns;
	eqn_names = {KCL_eqn_names{:}, KVL_eqn_names{:}, BCR_eqn_names{:}, int_eqn_names{:}};
    
	% Second iter, constructing incident matrix A
	% ordering the eval function
	idx_exp_eqns = 0;
	idx_imp_eqns = 0;
	A = sparse(n_e_unks, n_ibr_unks);
	for i = 1:length(DAE.circuitdata.elements)
		el = DAE.circuitdata.elements{i};
		elModel = el.model; % there is a separate one for each device
		elname = el.name;
		elNodes = el.nodes;
		elParms = el.parms;
		prefix = sprintf('%s%s', elname, DAE.separatorString);

		%% for vecX: look through otherIOs, act depending on type: 'v' or 'i'
		ioNames = feval(elModel.IOnames, elModel);
		ioTypes = feval(elModel.NIL.IOtypes, elModel);
		ioNodeNames = feval(elModel.NIL.IOnodeNames, elModel);
		otherIOnames = feval(elModel.OtherIONames, elModel);
		refnode_idx = el.refnode_idx;
		nodenames_internal = feval(elModel.NIL.NodeNames, elModel);
		expONames = feval(elModel.ExplicitOutputNames, elModel);

		for io = ioNames
			idx_in_IOs = find(strcmp(io, ioNames));
			IOnodeName = ioNodeNames{idx_in_IOs};
			int_idx_of_node = find(strcmp(IOnodeName, nodenames_internal));
			if 1==strcmp('i', ioTypes{idx_in_IOs})
				if el.node_idx(int_idx_of_node) ~= 0
					A(el.node_idx(int_idx_of_node), el.IO2br(idx_in_IOs)) = 1;
				end
				if refnode_idx ~= 0
					A(refnode_idx,el.IO2br(idx_in_IOs)) = -1;
				end
			end
        end

		% A_X
		A_X = sparse(length(otherIOnames), n_unks);
		for idx2 = 1:length(otherIOnames)
			oio = otherIOnames(idx2);
			idx_in_IOs = find(strcmp(oio,ioNames));
			if 1==strcmp('i', ioTypes{idx_in_IOs})
				idx_X = n_e_unks + n_vbr_unks + el.IO2br(idx_in_IOs);
				A_X(idx2,idx_X) = 1;
            elseif 1==strcmp('v', ioTypes{idx_in_IOs})
				idx_X = n_e_unks + el.IO2br(idx_in_IOs);
				A_X(idx2,idx_X) = 1;
			end
        end
        
		% A_Z
		% A_BCRexp
		A_Z = sparse(length(expONames), n_unks);
		BCRexp = sparse(n_eqns, length(expONames));
		for idx2 = 1:length(expONames)
			eo = expONames(idx2);
			idx_in_IOs = find(strcmp(eo,ioNames));
			if 1==strcmp('i', ioTypes{idx_in_IOs})
				idx_X = n_e_unks + n_vbr_unks + el.IO2br(idx_in_IOs);
				A_Z(idx2,idx_X) = 1;
            elseif 1==strcmp('v', ioTypes{idx_in_IOs})
				idx_X = n_e_unks + el.IO2br(idx_in_IOs);
				A_Z(idx2,idx_X) = 1;
			end
			idx_exp_eqns = idx_exp_eqns + 1;
			idx_BCR =  n_e_unks + n_vbr_unks + idx_exp_eqns;
			BCRexp(idx_BCR,idx2) = 1;
		end
		% A_Y
		intUnkNames = feval(elModel.InternalUnkNames, elModel);
		A_Y = sparse(length(intUnkNames), n_unks);
		for idx2 = 1:length(intUnkNames)
			idx_X =  n_e_unks + 2 * n_vbr_unks + el.IU2int(idx2);
			A_Y(idx2, idx_X) = 1;
        end

		% A_BCRimp
		impEqnNames = feval(elModel.ImplicitEquationNames, elModel);
		BCRimp = sparse(n_eqns,length(impEqnNames));
		for ix2 = 1:length(impEqnNames)
			idx_imp_eqns = idx_imp_eqns + 1;
			idx_BCRimp = n_e_unks + n_vbr_unks + n_exp_eqns + idx_imp_eqns;
			BCRimp(idx_BCRimp,idx2) = 1;
		end

		if 1 == elModel.support_initlimiting
			% A_Xlim
			limitedVarNames = feval(elModel.LimitedVarNames, elModel);
			A_Xlim = sparse(length(limitedVarNames), n_limitedvars);
			for idx2 = 1:length(limitedVarNames)
				A_Xlim(idx2, el.limVar2xlim(idx2)) = 1;
			end
		end

		% A_U
		uNames = feval(elModel.uNames, elModel);
		A_U = sparse(length(uNames), n_inputs);
		for idx2 = 1:length(uNames)
			A_U(idx2, el.U2U(idx2)) = 1;
        end

    
		% store Jacobian data
		DAE.circuitdata.elements{i}.A_X = A_X;
		DAE.circuitdata.elements{i}.A_Y = A_Y;
		DAE.circuitdata.elements{i}.A_Z = A_Z;
		if 1 == elModel.support_initlimiting
			DAE.circuitdata.elements{i}.A_Xlim = A_Xlim;
		end
		DAE.circuitdata.elements{i}.A_U = A_U;
		DAE.circuitdata.elements{i}.BCRexp = BCRexp;
		DAE.circuitdata.elements{i}.BCRimp = BCRimp;
        
    end

	% 3rd iter to set up x_to_xlim_matrix, can be integrated into 2nd pass, but efficiency is affected only trivially
	x_to_xlim_matrix = zeros(n_limitedvars, n_unks);
	for i = 1:length(DAE.circuitdata.elements);
		el = DAE.circuitdata.elements{i};
		elModel = el.model; % there is a separate one for each device
		if 1 == elModel.support_initlimiting
			% vecLim = vecXYtoLimitedVarsMatrix * [vecX;vecY];
			% vecLim = el.A_Xlim * xlim;
			% vecX = el.A_X * x;
			% vecY = el.A_Y * x;
			vecXY_to_vecLim = feval(el.model.vecXYtoLimitedVarsMatrix , el.model);
			if ~isempty(vecXY_to_vecLim)
				x_to_xlim_matrix = x_to_xlim_matrix + el.A_Xlim.'*vecXY_to_vecLim*[el.A_X;el.A_Y];
			end
		end
	end %  3rd pass through all devices

	%% store stuff set up above in DAE

	% DAE.circuitdata.elements{:} have already been updated above

	% name
	DAE.dae_name = sprintf('STA DAE for %s', DAE.circuitdata.cktname);

	% list of elements
	DAE.element_names = element_names;

	% unks
	DAE.n_nodes = n_e_unks;
	DAE.n_branches = n_ibr_unks;
	DAE.n_int = n_int_unks;
	DAE.n_unks = n_unks;
	DAE.unk_names = unk_names;
	

	% incidence matrix
	DAE.A = A;

	% eqns
	DAE.n_eqns = n_eqns;
	DAE.eqn_names = eqn_names;
	DAE.n_exp_eqns = n_exp_eqns;
	DAE.n_imp_eqns = n_imp_eqns;

	% limited vars
	DAE.support_initlimiting = 1;
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
                                            'STA');

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
% f, q: 
	DAE.f_takes_inputs = 1;
	DAE.f = @f;
	DAE.q = @q;
    DAE.fq = @default_fq;
    DAE.fqJ = @default_fqJ;
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
% QSS initial guess support
	DAE.NRinitGuess = @NRinitGuess;
	%
% NR limiting support
 	DAE.NRlimiting = @NRlimiting;
 	DAE.dNRlimiting_dx = @dNRlimiting_dx;
	DAE.xTOxlimMatrix = @(DAEarg) DAEarg.x_to_xlim_matrix;
	DAE.xTOxlim = @(x, DAEarg) feval(DAEarg.xTOxlimMatrix, DAEarg) * x;
	%
% parameter support - see also input- and output-related function sections
	DAE.nparms = @nparms;
	DAE.parmdefaults  = @parmdefaults;
	DAE.parmnames = @parmnames_local;
	DAE.getparms  = @newgetparms; % get parms from elements: don't use default DAEAPI getparms
	DAE.setparms  = @newsetparms; % set parms inside elements: don't use default DAEAPI setparms
	DAE.unkidx = @unkidx_DAEAPI; % from utils
	DAE.eqnidx = @eqnidx_DAEAPI; % from utils
	DAE.inputidx = @inputidx_DAEAPI; % from utils
	DAE.limitedvaridx = @limitedvaridx_DAEAPI; % from utils
	DAE.outputidx = @outputidx_DAEAPI; % from utils

	% first derivatives with respect to parameters - for sensitivities
	% DAE.df_dp  = @df_dp; TBD
	% DAE.dq_dp  = @dq_dp; TBD
	% data: current values of parameters, can be changed by setparms
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
			%	.uname = for example 'E' (for a voltage source), 'I' for a current source
			%	  these are exactly from uNames for the device
			%	.QSSval = for example 1.0 (DC value from spice netlist line)
			%	.utransient = handle to a matlab function ut(t, args) that returns
			%		a scalar double number
			%		- for example dummy = @(t, args) args.A*sin(2*pi*args.f*t);
			%		- .utransient = dummy;
			%	.utransientargs = the args argument that needs to be in utransient
			%		- will typically contain information needed to evaluate
			%		  utransient. Standard SPICE u functions: PWL, sffm, pulse?,
			%		  sine, cos (there are only about 5).
			%	.uLTISSS = handle to a matlab function uf(f, args) that returns
			%	.uLTISSSargs = the args argument that needs to be in uLTISSS
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
    %}
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
function [fqout, dfqout] = fq(x, xlim, u, DAE, f_or_q, x_or_u_or_xlim)
%function [fqout, dfqout] = fq(x, u, DAE, f_or_q, x_or_u)
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

	% Decompose x
	n_nodes = DAE.n_nodes;
	n_branches = DAE.n_branches;
	n_int = DAE.n_int;
	e_unks = x(1:n_nodes);
	% e_unks = reshape(e_unks,n_nodes,1);
	vbr_unks = x(n_nodes + 1 : n_nodes + n_branches);
	% vbr_unks = reshape(vbr_unks,n_branches,1);
	ibr_unks = x(n_nodes + n_branches + 1 : n_nodes + 2 * n_branches);
	% ibr_unks = reshape(ibr_unks,n_branches,1);
	int_unks = x(n_nodes + 2 * n_branches + 1 : n_nodes + 2 * n_branches + n_int);
	% int_unks = reshape(int_unks,n_int,1);

	% f KCL + KVL eqns
	if eff == 1
		% The first n KCLs eqns
		fqout(1:n_nodes) = DAE.A * ibr_unks;
		% The next b KVL eqns
		fqout(n_nodes+1:n_nodes+n_branches) = vbr_unks - DAE.A'*e_unks;
		if 1 == derivs_wanted
			if 1 == ddx
				dfqout(1:n_nodes,n_nodes+n_branches+1:n_nodes+2*n_branches) = DAE.A;
				dfqout(n_nodes+1:n_nodes+n_branches,1:n_nodes) = -DAE.A';
				dfqout(n_nodes+1:n_nodes+n_branches,n_nodes+1:n_nodes+n_branches) = eye(n_branches);
			end
		end
	% q is empty for KCL and KVL
	end

	% loop through the elements
	% BCRs and BCRimps
	elements = DAE.circuitdata.elements;
	nelements = length(elements);
	for i = 1:nelements
		el = DAE.circuitdata.elements{i};
		elModel = el.model; % there is a separate one for each device
		elname = el.name;

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% set up vecX, vecY, vecU for the device
		ioNames = feval(elModel.IOnames, elModel);
		ioTypes = feval(elModel.NIL.IOtypes, elModel);
		otherIONames = feval(elModel.OtherIONames, elModel);
		expONames = feval(elModel.ExplicitOutputNames, elModel);
		intUnkNames = feval(elModel.InternalUnkNames, elModel);
		impEqnNames = feval(elModel.ImplicitEquationNames, elModel);
		% vecX
		vecX = el.A_X * x;
		if 1 == elModel.support_initlimiting
			% veclim
			vecLim = el.A_Xlim * xlim;
		end
		% vecY
		vecY = el.A_Y * x;
		% vecU
		if ~isempty(u)
			idx_U = el.U2U;
			vecU = u(idx_U);
		end
		% vecZ
		vecZ = el.A_Z * x;
		% vecW
		vecW = zeros(length(impEqnNames),1);
	
		%% done setting up vecX, vecY, vecU for the device
		%%%%%%%%%%%%%%%%%%%

		%%%%%%%%%%%%%%%%%%%
		%% BCR and BCRimps
		if 1 == eff
			% BCRs
			if 1 == elModel.support_initlimiting
				vecZ = feval(elModel.fe, vecX, vecY, vecLim, vecU, elModel) - vecZ; 
			else
				vecZ = feval(elModel.fe, vecX, vecY, vecU, elModel) - vecZ; 
			end
			% BCRimps
			if 1 == elModel.support_initlimiting
				vecW = feval(elModel.fi, vecX, vecY, vecLim, vecU, elModel);
			else
				vecW = feval(elModel.fi, vecX, vecY, vecU, elModel);
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
						dvecZ_dvecZ = -eye(length(vecZ));
					if 1 == elModel.support_initlimiting
						dvecW_dvecX = feval(elModel.dfi_dvecX, vecX, vecY, vecLim, vecU, elModel);
						dvecW_dvecY = feval(elModel.dfi_dvecY, vecX, vecY, vecLim, vecU, elModel);
					else
						dvecW_dvecX = feval(elModel.dfi_dvecX, vecX, vecY, vecU, elModel);
						dvecW_dvecY = feval(elModel.dfi_dvecY, vecX, vecY, vecU, elModel);
					end
				elseif 0 == ddx
					if 1 == elModel.support_initlimiting
						dvecZ_dvecU = feval(elModel.dfe_dvecU, vecX, vecY, vecLim, vecU, elModel);
						dvecW_dvecU = feval(elModel.dfi_dvecU, vecX, vecY, vecLim, vecU, elModel);
					else
						dvecZ_dvecU = feval(elModel.dfe_dvecU, vecX, vecY, vecU, elModel);
						dvecW_dvecU = feval(elModel.dfi_dvecU, vecX, vecY, vecU, elModel);
					end
				elseif 2 == ddx
					if 1 == elModel.support_initlimiting
						dvecZ_dvecLim = feval(elModel.dfe_dvecLim, vecX, vecY, vecLim, vecU, elModel);
						dvecW_dvecLim = feval(elModel.dfi_dvecLim, vecX, vecY, vecLim, vecU, elModel);
					end
				end
			end
		else
			% BCRs
			if 1 == elModel.support_initlimiting
				vecZ = feval(elModel.qe, vecX, vecY, vecLim, elModel); 
			else
				vecZ = feval(elModel.qe, vecX, vecY, elModel); 
			end
			% BCRimps
			if 1 == elModel.support_initlimiting
				vecW = feval(elModel.qi, vecX, vecY, vecLim, elModel);
			else
				vecW = feval(elModel.qi, vecX, vecY, elModel);
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
					dvecZ_dvecZ = zeros(length(vecZ));
					if 1 == elModel.support_initlimiting
						dvecW_dvecX = feval(elModel.dqi_dvecX, vecX, vecY, vecLim, elModel);
						dvecW_dvecY = feval(elModel.dqi_dvecY, vecX, vecY, vecLim, elModel);
					else
						dvecW_dvecX = feval(elModel.dqi_dvecX, vecX, vecY, elModel);
						dvecW_dvecY = feval(elModel.dqi_dvecY, vecX, vecY, elModel);
					end
				elseif 0 == ddx
					if 1 == elModel.support_initlimiting
						dvecZ_dvecU = feval(elModel.dqe_dvecU, vecX, vecY, vecLim, elModel);
						dvecW_dvecU = feval(elModel.dqi_dvecU, vecX, vecY, vecLim, elModel);
					else
						dvecZ_dvecU = feval(elModel.dqe_dvecU, vecX, vecY, elModel);
						dvecW_dvecU = feval(elModel.dqi_dvecU, vecX, vecY, elModel);
					end
				elseif 2 == ddx
					if 1 == elModel.support_initlimiting
						dvecZ_dvecLim = feval(elModel.dqe_dvecLim, vecX, vecY, vecLim, elModel);
						dvecW_dvecLim = feval(elModel.dqi_dvecLim, vecX, vecY, vecLim, elModel);
					end
				end
			end
		end

		% Scattering into fq BCRs
		if ~isempty(vecZ)
			fqout = fqout + el.BCRexp * vecZ;
		end
		if ~isempty(vecW)
			fqout = fqout + el.BCRimp * vecW;
		end
		if 1 == derivs_wanted
			if 1 == ddx
				dfqout = dfqout + el.BCRexp * dvecZ_dvecX * el.A_X;	
				dfqout = dfqout + el.BCRexp * dvecZ_dvecY * el.A_Y;	
				dfqout = dfqout + el.BCRexp * dvecZ_dvecZ * el.A_Z;	
				dfqout = dfqout + el.BCRimp * dvecW_dvecX * el.A_X;	
				dfqout = dfqout + el.BCRimp * dvecW_dvecY * el.A_Y;	
			elseif 0 == ddx
				dfqout = dfqout + el.BCRexp * dvecZ_dvecU * el.A_U;
				dfqout = dfqout + el.BCRimp * dvecW_dvecU * el.A_U;
			elseif 2 == ddx
				if 1 == elModel.support_initlimiting
					dfqout = dfqout + el.BCRexp * dvecZ_dvecLim * el.A_Xlim;
					dfqout = dfqout + el.BCRimp * dvecW_dvecLim * el.A_Xlim;
				end
			end
		end
		%% End BCR and BCRimps
		%%%%%%%%%%%%%%%%%%%%%%%%

	end % looping through the elements
end % fq(...)

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
				vecU = u(el.U2U(:)); % CHECK VECVALDER
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
				out = out + el.A_Xlim.' * vecLim;  % TODO: need to check
			end
			if 1 == derivs_wanted
				dout = dout + el.A_Xlim.' * dvecLim_dx;
			end
		end
	end % loop through devices
end % init_limiting(...)

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

function [fout, qout] = default_fq(varargin)
%function [fout, qout] = default_fq(x, xlim, u, flag, DAE)
% xlim is optional
    DAE = varargin{end};
	flag = varargin{end-1};
    if 1 == flag.f
		fout = feval(DAE.f, varargin{1:end-2}, DAE);
    else
        fout = [];
    end

    if 1 == flag.q
		if 1 == DAE.f_takes_inputs
			qout = feval(DAE.q, varargin{1:end-3}, DAE);
		else
			qout = feval(DAE.q, varargin{1:end-2}, DAE);
		end
    else
        qout = [];
    end
end % default_fq

function fqJout = default_fqJ(varargin)
%function fqJout = default_fqJ(x, xlim, u, flag, DAE)
% xlim is optional, u is also optional depending on f_takes_inputs
    DAE = varargin{end};
    flag = varargin{end-1};
	if flag.dfdx == 0 && flag.dfdu == 0 && flag.dfdxlim == 0 ...
		&& flag.dqdx == 0 && flag.dqdxlim == 0
        [fqJout.f, fqJout.q] = DAE.fq(varargin{:});
        fqJout.dfdx = [];
        fqJout.dfdxlim = [];
        fqJout.dfdu = [];
        fqJout.dqdx = [];
        fqJout.dqdxlim = [];
    else
		[fq, J] = dfq_dxxlimu_auto(varargin{1:end-2}, DAE);

		fqJout.f = fq.f;
		fqJout.q = fq.q;

        fqJout.dfdx    = J.dfdx;
        fqJout.dfdxlim = J.dfdxlim;
        fqJout.dfdu    = J.dfdu;
        fqJout.dqdx    = J.dqdx;
        fqJout.dqdxlim = J.dqdxlim;
    end
end
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
	out = zeros(length(DAE.output_names), DAE.n_inputs);
end % D(...)

%%%%%%%%%%%%%%%%% QSS/NR INITIAL GUESS SUPPORT %%%%%%%%%%%%%%%%%%%%%%
% function out = NRinitGuess(u, DAE) 		% NOT WRITTEN YET
% 	% in principle, could use some heuristic dependent on the input
% 	% and the parameters,
% 	out = zeros(DAE.n_unks,1);
% end %NRinitGuess

%%%%%%%%%%%%%%%%% NR LIMITING SUPPORT %%%%%%%%%%%%%%%%%%%%%%
% function newdx = NRlimiting(dx, xold, u, DAE) 	% NOT WRITTEN YET
% 	newdx = dx;
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
	% TODO: delete these. only for debug
	ifs.fq = @fq;
	ifs.fqUsage = 'feval(fq, x, u, DAE, f_or_q, x_or_u, init_on, limiting_on, dx)';
	%ifs.stoichmatfunc = @stoichmatfunc;
	%ifs.stoichmatfuncUsage = 'feval(stoichmatfunc, DAE)';
end % internalfuncs

%%%%%%%%%%%%%%%% STUFF BELOW IS NOT PART OF DAE API %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

