function MOD = attach_spin_NIL(MOD)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Network Interface Layer (for SPIN) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic name and outputtype functions:
	% for the Network Level
	MOD.spinNIL.node_names = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
	MOD.spinNIL.NodeNames = @(MOD) MOD.spinNIL.node_names; 

% Note: every spin quantity is a 3-vector
	% trying to think of this NIL via an example:
	% network quantities (nodes): alpha, beta
	% IOs => is_alpha, is_beta, es_alpha, es_beta (2 nodes => 4 IO quantities, ie, a 2-port; EE would have been a 1-port)
	%     - let's say all quantities are implicit, so we need two equations in all the IOs
	% We do have the concept of spin potential and spin current, and the KCL/KCL at a node are essentially identical
	% to the EE NIL (except that it is a 3-vector)
	% Let's try a few cases:
	% - the simple ferromagment: is_alpha and is_beta are explicit outputs: is_* = f(es_*)
	%   - if you connect three of the together at a "node", then the KCL will be f_1(es1_*) + f_2(es2_*) + f3_(es3*)
	%   - for an MNA formulation es* are all system unknowns; is* are not if you can help it.
	%   - there is no KVL, because you are not reducing n "node voltages" to n-1 branch voltages that alone determine
	%     all the "branch currents"
	%   - however, there is a simple network constraint for node voltages at a node
	% - the spin-current-controlled ferromagment: es_alpha and es_beta are explicit outputs: es_* = f(is_*)
	%   - if you connect three of the together at a "node", then the KCL will need to to declare is*, which will have to be added
	%     to the system unknowns
	%   - therefore it makes sense to have an io_nodenames, which maps back from each IOname to its corresponding node
	%     - this will be useful, if eg, it turns that a spin voltage is an explicit output, or some spin current 
	%       is not an explicit output. Because this will help us figure out in the equation engine that we need to add
	%       an extra unknown in the overall system

	MOD.spinNIL.io_types = {'UNDEFINED:', 'cell', 'array', 'of', 'strings', '''v''', 'or', '''i'''};
	MOD.spinNIL.IOtypes = @(MOD) MOD.spinNIL.io_types;
		% for example, if there are 3 spin nodes, there should be this should be of size 6: eg, 'v', 'v', 'v', 'i', 'i', 'i';
		% each one stands for a 3-vector; the real size of IOs is 18
		% this is used to map
	MOD.spinNIL.io_nodenames = {'UNDEFINED:', 'cell', 'array', 'of', 'strings'};
	MOD.spinNIL.IOnodeNames = @(MOD) MOD.spinNIL.io_nodenames;
		% for EE, this is used to map back from each IOname to its node (because IOs for EE are just the branch voltage
		% and current from a given node to the ref node).
		% we'll see what sense this makes for spin later
		% for example, if there are 3 spin nodes => 6 IOs,  then this should be of size 6, eg, {'alpha', 'beta' 'gamma', 'alpha', 'beta' 'gamma'}
		% - which means, eg: IO(1) is for node alpha (io_types = 'v'); IO(4) is also for node alpha, io_type = 'i'

	% IOnames at the core-level is auto-generated from NodeNames and RefNodeName. The IOs are all the
	% branch voltages (from each node to refnode), followed by all the branch currents:
	% 	foreach nn=NodeName (except refnodename): IOnames = {v_nn_RefNodeName, i_nn_RefNodeName}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Network Interface Layer (for spin) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
