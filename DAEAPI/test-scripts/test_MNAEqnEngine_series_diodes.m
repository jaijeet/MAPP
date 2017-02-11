function ok = test_MNAEqnEngine_series_diodes(arg)
% test-script for MNAEqnEngine_series_diodes 
% Test all DAEAPI functions of a diode-diode DAE
%author: J. Roychowdhury, 2012/05/01-08
%        Tianshi Wang 2012-11-20
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- two ModSpec diodes (including an internal node) in series:
%
%  gnd -|<|- n1 -|>|- n2
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
cktname = '2 diodes in series';

% nodes (names)
nodes = {'1', '2'};
ground = 'gnd';

% list of elements 
d1M = diodeModSpec('d1'); % diode element
d2M = diodeModSpec('d2'); % diode element

% element node connectivities
d1nodes = {'1', ground}; % p, n
d2nodes = {'1', '2'}; % p, n

% element parameters
dParms = feval(d1M.parmdefaults, d1M);

%dElement = {'diode', dModel, dNodes, dParms};
d1Element.name = 'd1'; d1Element.model = d1M; 
	d1Element.nodes = d1nodes; d1Element.parms = dParms;
d2Element.name = 'd2'; d2Element.model = d2M; 
	d2Element.nodes = d2nodes; d2Element.parms = dParms;


% set up circuitdata structure containing all the above
% contains: nodenames, groundnodename(s), elements
% each element contains: name, ModSpecModel, nodes, parms
circuitdata.cktname = cktname; % all non-ground nodes
circuitdata.nodenames = nodes; % all non-ground nodes
circuitdata.groundnodename = ground;
circuitdata.elements = {d1Element, d2Element};

% set up and return a DAE of the MNA equations for the circuit
DAE = MNA_EqnEngine('diode-diode', circuitdata);

if nargin ~= 0 && strcmp(class(arg), 'char') && strcmp(arg, 'update')
	% update
	[filename, is_new] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_series_diodes', 'update');
	if is_new
		load(filename); % get ref in the workspace
		n_dtests = length(ref.dtests);
		% add more specific dynamic test cases for MNAEqnEngine_series_diodes
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
		% add random test cases for MNAEqnEngine_series_diodes
		ref.rtests{1} = 1;
		% save ref
		save(filename, 'ref');
	[filename, is_new] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_series_diodes', 'update');
	end
    ok = 1;
else 
	% no update
	[filename, is_new, ok] = run_DAEAPI_functions(DAE, 'MNAEqnEngine_series_diodes');
end

