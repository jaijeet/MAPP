function ok = test_MNAEqnEngine_isrc(arg)
% test-script for MNAEqnEngine_isrc 
%author: J. Roychowdhury, 2012/05/01-08
%        Tianshi Wang 2012-11-20
%
%Test all DAEAPI functions of a current source DAE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Circuit: 
%	- a ModSpec current source between node 1 and gnd
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
cktname = 'a single isrc';

% nodes (names)
nodes = {'1'};
ground = 'gnd';

% list of elements 
M = isrcModSpec('i1'); % vsrc element

% element node connectivities
nodes2 = {'1', ground}; % p, n

Element.name = 'i1'; Element.model = M; 
	Element.nodes = nodes2; Element.parms = {};


% set up circuitdata structure containing all the above
% contains: nodenames, groundnodename(s), elements
% each element contains: name, ModSpecModel, nodes, parms
circuitdata.cktname = cktname; % all non-ground nodes
circuitdata.nodenames = nodes; % all non-ground nodes
circuitdata.groundnodename = ground;
circuitdata.elements = {Element};

% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine('single isrc', circuitdata);

if nargin ~= 0 && strcmp(class(arg), 'char') && strcmp(arg, 'update')
	% update
	[filename, is_new] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_isrc', 'update');
	if is_new
		load(filename); % get ref in the workspace
		n_dtests = length(ref.dtests);
		% add more specific dynamic test cases for MNAEqnEngine_isrc
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
		% add random test cases for MNAEqnEngine_isrc
		ref.rtests{1} = 1;
		% save ref
		save(filename, 'ref');
	[filename, is_new] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_isrc', 'update');
	end
    ok = 1;
else 
	% no update
	[filename, is_new, ok] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_isrc');
end

