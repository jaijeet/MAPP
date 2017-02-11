function ok = test_MNAEqnEngine_vsrc(arg)
% test-script for MNAEqnEngine_vsrc 
%author: J. Roychowdhury, 2012/05/01-08
%        Tianshi Wang 2012-11-20
%
%Test all DAEAPI functions of a voltage source DAE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	- a ModSpec voltage source between node 1 and gnd
%
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


% ckt name
cktname = 'a single voltage source';

% nodes (names)
nodes = {'1'};
ground = 'gnd';

% list of elements 
v1M = vsrcModSpec('d1'); % vsrc element

% element node connectivities
v1nodes = {'1', ground}; % p, n

v1Element.name = 'v1'; v1Element.model = v1M; 
	v1Element.nodes = v1nodes; v1Element.parms = {};


% set up circuitdata structure containing all the above
% contains: nodenames, groundnodename(s), elements
% each element contains: name, ModSpecModel, nodes, parms
circuitdata.cktname = cktname; % all non-ground nodes
circuitdata.nodenames = nodes; % all non-ground nodes
circuitdata.groundnodename = ground;
circuitdata.elements = {v1Element};

% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine('single vsrc', circuitdata);

if nargin ~= 0 && strcmp(class(arg), 'char') && strcmp(arg, 'update')
	% update
	[filename, is_new] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_vsrc', 'update');
	if is_new
		load(filename); % get ref in the workspace
		n_dtests = length(ref.dtests);
		% add more specific dynamic test cases for MNAEqnEngine_vsrc
		% add all zeros
		ref.dtests{n_dtests+1}.x = zeros(ref.nunks,1); 
		ref.dtests{n_dtests+1}.xlim = zeros(ref.nlimitedvars,1); 
		ref.dtests{n_dtests+1}.xlimOld = -ones(ref.nlimitedvars,1); 
		ref.dtests{n_dtests+1}.u = zeros(ref.ninputs,1); 
		% add all -1s
		ref.dtests{n_dtests+2}.x = -ones(ref.nunks,1); 
		ref.dtests{n_dtests+2}.xlim = ones(ref.nlimitedvars,1); 
		ref.dtests{n_dtests+2}.xlimOld = -ones(ref.nlimitedvars,1); 
		ref.dtests{n_dtests+2}.u = -ones(ref.ninputs,1); 
		% add random test cases for MNAEqnEngine_vsrc
		ref.rtests{1} = 1;
		% save ref
		save(filename, 'ref');
	[filename, is_new] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_vsrc', 'update');
	end
    ok = 1;
else 
	% no update
	[filename, is_new, ok] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_vsrc');
end

