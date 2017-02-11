%Describing circuits (MAPP's netlist format)
%-------------------------------------------
%
%MAPP has a simple syntax for entering circuits using a purely text-based
%format -- similar to SPICE netlists
%(http://bwrcs.eecs.berkeley.edu/Classes/IcBook/SPICE/), but using the MATLAB
%language. The netlist is stored as a structure (named, say, cktnetlist). The
%following fields of cktnetlist should first be set up:
%
%  .cktname:        A name for the circuit (a string). Eg, 'myckt'.
%  .nodenames:      A list (cell array) of strings with the names of all
%                   (non-ground) nodes. Eg., {'n1', '2', 'node3'}.
%  .groundnodename: The name of the ground node (a string). Eg, 'gnd'.
%
%cktnetlist has a number of other fields which contain element and
%connectivity information, but instead of setting those up directly, it is best
%to use the MAPP function add_element.
%For example, after you have set up the above fields of cktnetlist, you could
%add a resistor (with MAPP model resModSpec, of value 500ohms, between nodes
%'n1' and '2', with name 'R1') to cktnetlist by:
%
% cktnetlist=add_element(cktnetlist, resModSpec(), 'R1', {'n1', '2'}, 500);
%
%You can add any device supported by MAPP using add_element. For more details
%and complete circuit examples, see add_element. To see what devices are
%supported by MAPP, see MAPPbuiltinDevices.
%
%Once you have added all the elements you want to cktnetlist, you can 
%select node voltages and branch currents as outputs for printing/plotting,
%using add_output. For example, if you want to add an output that equals 1.5x
%the difference between the node voltages at n1 and 2:
%
% cktnetlist=add_output(cktnetlist, 'n1', '2', 1.5);
%
%If you don't add any outputs, every unknown in the equation system for
%your circuit will be considered an output. help add_output for details and
%more examples.
%
%It is also possible to define and use subcircuits - see add_subcircuit for
%details.
%
%Once you have added all the nodes, elements, and outputs you want,
%you can convert cktnetlist to a DAE (MAPP's fundamental mathematical
%representation for any circuit or system, see DAE[TODO]) simply by:
%
% DAE = MNA_EqnEngine(cktnetlist); % sets up a Modified Nodal Analysis DAE
%   or
% DAE = STA_EqnEngine(cktnetlist); % sets up a Sparse Tableau DAE
%
%(see MNA_EqnEngine[TODO] and STA_EqnEngine[TODO] for details).
%
%Now you can run any of MAPP's analyses on the DAE. See MAPPanalyses for
%details and examples.
%
%Example
%-------
%
%% This is the code of vsrcRCL_ckt.m - see help vsrcRCL_ckt
%% ckt name
%cktnetlist.cktname = 'gnd-vsrc-n1-R-n2-C-n3-L-gnd';
%% nodes (names)
%cktnetlist.nodenames = {'1', '2', '3', 'gnd'}; 
%cktnetlist.groundnodename = 'gnd'; % 
%
%vM = vsrcModSpec();
%   DCval = 0;
%   tranfunc = @(t, args) args.offset + args.A * pulse(t, args.td, ...
%                                            args.thi, args.tfs, args.tfe);
%   tranfuncargs.A = 1; tranfuncargs.td = 0.2e-3; tranfuncargs.thi = 0.21e-3;
%   tranfuncargs.tfs = 0.6e-3; tranfuncargs.tfe = 0.61e-3;
%   tranfuncargs.offset = 0;
%cktnetlist = add_element(cktnetlist, vM, 'vsrc1', {'1', 'gnd'}, {}, ...
%                   {{'E', {'dc', DCval}, {'tran', tranfunc, tranfuncargs}}});
%
%cktnetlist = add_element(cktnetlist, resModSpec(), 'r1', {'1', '2'}, ...
%                                                           {{'R',1e3}}, {});
%cktnetlist = add_element(cktnetlist, capModSpec(), 'c1', {'3', '2'}, 1e-8, {});
%cktnetlist = add_element(cktnetlist, indModSpec(), 'l1', {'3', 'gnd'}, 3e-2);
%
%cktnetlist = add_output(cktnetlist, '1'); % node voltage of '1'
%cktnetlist = add_output(cktnetlist, 'e(3)', [], 'vout'); % node voltage 
%                                           % of '3', with output name vout
%cktnetlist = add_output(cktnetlist, 'i(vsrc1)', 1000);
%                                  % current through vsrc1, scaled by 1000
%
%
%See also
%--------
% MAPPcktExamples, add_element, add_output, add_subcircuit, MAPPquickstart,
% MAPPdevices, MAPPanalyses, MAPPbuiltinDevices, cktnetlist_lowlevel[TODO],
% DAEAPI, DAE_concepts
%
