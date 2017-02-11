function outMOD = setup_IOnames_otherIOnames_IOtypes_IOnodenames(MOD)
%function outMOD = setup_IOnames_otherIOnames_IOtypes_IOnodenames(MOD)
%This function performs the initial set-up for a ModSpec object.
%set up MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types, MOD.NIL.io_nodenames 
%
%INPUT args:
%   MOD         - partial ModSpec object
%
%OUTPUT
%   outMOD      - updated ModSpec object with new fields (IO_names,
%                 OtherIO_names, NIL.io_types, NIL.io_nodenames)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% one-time set up for MOD.IO_names, MOD.OtherIO_names,
%% 	MOD.NIL.io_types, MOD.NIL.io_nodenames
%% uses: MOD.NIL.RefNodeName, MOD.NIL.NodeNames, MOD.ExplicitOutputNames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	% first "zero" out the things to be set up 
	MOD.IO_names = {};
	MOD.OtherIO_names = {};
	MOD.NIL.io_types = {};
	MOD.NIL.io_nodenames = {};

	% set up IO_names
	refname = feval(MOD.NIL.RefNodeName, MOD);
	nodes = feval(MOD.NIL.NodeNames, MOD);
	% drop ref node for node list
	idx = find(strcmp(refname, nodes));
	if length(idx) ~= 1
		fprintf(2, 'error: device %s''s reference node %s not found exactly once in NIL.NodeNames.\n', ...
			feval(MOD.name, MOD), refname);
		return;
	end
	non_ref_idxs = find(~strcmp(refname, nodes));
	nodes = {nodes{non_ref_idxs}};
	nn = length(nodes);
	for i=1:nn
		MOD.IO_names{i} = sprintf('v%s%s', nodes{i}, refname);
		MOD.NIL.io_types{i} = 'v';
		MOD.NIL.io_nodenames{i} = nodes{i};
		MOD.IO_names{i+nn} = sprintf('i%s%s', nodes{i}, refname);
		MOD.NIL.io_types{i+nn} = 'i';
		MOD.NIL.io_nodenames{i+nn} = nodes{i};
	end

	% set up OtherIO_names
	eios = feval(MOD.ExplicitOutputNames, MOD);
	indices = ones(length(MOD.IO_names),1);
	for eio = eios
		idx_in_IOs = find(strcmp(eio, MOD.IO_names));
		if length(idx_in_IOs) ~= 1
			fprintf(2,'%s: explicitIO %s not found exactly once in IOs\n', feval(MOD.name, MOD), eio);
			return;
		end
		indices(idx_in_IOs) = 0;
	end
	otherIO_indices = find(indices ~= 0);
	MOD.OtherIO_names = {MOD.IO_names{otherIO_indices}};
	outMOD = MOD;
end % setup_IOnames_otherIOnames
