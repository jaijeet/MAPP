function ok = test_MNAEqnEngine_res(arg)
% test-script for MNAEqnEngine_res 
%author: J. Roychowdhury, 2012/05/01-08
%        Tianshi Wang 2012-11-20
%
%Test all DAEAPI functions of a resistor DAE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	- a ModSpec resistor between node 1 and gnd
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
cktname = 'a single resistor';

% nodes (names)
nodes = {'1'};
ground = 'gnd';

% list of elements 
r1M = resModSpec('r1'); % vsrc element

% element node connectivities
r1nodes = {'1', ground}; % p, n

r1Element.name = 'r1'; r1Element.model = r1M; 
	r1Element.nodes = r1nodes; r1Element.parms = {100};


% set up circuitdata structure containing all the above
% contains: nodenames, groundnodename(s), elements
% each element contains: name, ModSpecModel, nodes, parms
circuitdata.cktname = cktname; % all non-ground nodes
circuitdata.nodenames = nodes; % all non-ground nodes
circuitdata.groundnodename = ground;
circuitdata.elements = {r1Element};

% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine('single resistor', circuitdata);

if nargin ~= 0 && strcmp(class(arg), 'char') && strcmp(arg, 'update')
	% update
	[filename, is_new] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_res', 'update');
	if is_new
		load(filename); % get ref in the workspace
		n_dtests = length(ref.dtests);
		% add more specific dynamic test cases for MNAEqnEngine_res
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
		% add random test cases for MNAEqnEngine_res
		ref.rtests{1} = 1;
		% save ref
		save(filename, 'ref');
	[filename, is_new] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_res', 'update');
	end
    ok = 1;
else 
	% no update
	[filename, is_new, ok] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_res');
end

