%vsrcRCL_demo   - walks you through defining a simple circuit consisting of a
%                 voltage source, resistor, capacitor and inductor (these
%                 devices are amongst those pre-defined in MAPP) and 
%                 running DC and transient analyses on it.
%
%               - to see the schematic of this circuit, run
%                 >> showimage(which('vsrcRCL_demo.jpg'));
%
%               - to start this demo, run
%                 >> vsrcRCL_demo;
% 
%See also
%--------
%MAPPquickstart_cktdemos

%Changelog:
%2015/01/22: JR: updated to show the use of add_output. In the process, made
%            a number of other improvements to this and
%            vsrcRCL_demo_internal_printing.m
%Original author: Tianshi Wang (who did not bother to note this fact, nor the
%                 date, here)

global isOctave;
if 0 == isOctave
    pause on;
end
clear;
fprintf('\n');
fprintf('%% This script creates a circuit netlist for a vsrc-R-C-L circuit.\n');
fprintf('%% press Enter to continue:\n');
fprintf('\n');
pause;

fprintf('%% start by defining a name for the ckt\n');
fprintf('cktnetlist.cktname = ''vsrc-R-C-L'';\n');
fprintf('%% press Enter to execute the above and show cktnetlist:\n');
pause;

%ckt name
cktnetlist.cktname = 'vsrc-R-C-L';
cktnetlist

fprintf('\n');
fprintf('%% enter all the nodes (names) in the circuit:\n');
fprintf('cktnetlist.nodenames = {''n1'', ''n2'', ''n3''}; %% non-ground nodes\n');
fprintf('cktnetlist.groundnodename = ''gnd'';\n');
fprintf('%% press Enter to execute the above and show cktnetlist:\n');
pause;

% nodes (names)
cktnetlist.nodenames = {'n1', 'n2', 'n3'}; % non-ground nodes
cktnetlist.groundnodename = 'gnd';
cktnetlist


fprintf('\n');
fprintf('%% add a resistor between nodes n1 and n2:\n');
fprintf('cktnetlist = add_element(cktnetlist, resModSpec(), ''R1'', {''n1'',''n2''}, {{''R'', 1}});\n');
fprintf('%%                            ^           ^          ^     ^^^^^^^^^     ^^^^^^\n');
fprintf('%%                        cktnetlist resistor-model name       nodes    parameter ''R'' set to 1\n');
fprintf('%% press Enter to execute the above and show cktnetlist:\n');
pause;

% adding a resistor
cktnetlist = add_element(cktnetlist, resModSpec(), 'R1', {'n1','n2'}, {{'R',1}});
cktnetlist

fprintf('\n');
fprintf('%% add a capacitor between nodes n2 and n3, with name C1 and capacitance 1e-6:\n');
fprintf('cktnetlist = add_element(cktnetlist, capModSpec(), ''C1'', {''n2'',''n3''}, 1e-6);\n');
fprintf('%%                                                                     ^^^^\n');
fprintf('%%                       note simpler syntax if device has only 1 parameter\n');
fprintf('%% press Enter to execute the above and show cktnetlist:\n');
pause;

% adding a capacitor
cktnetlist = add_element(cktnetlist, capModSpec(), 'C1', {'n2','n3'}, 1e-6);
cktnetlist

fprintf('\n');
fprintf('%% add an inductor between nodes n3 and ground. Name: L1; inductance 1e-6:\n');
fprintf('cktnetlist = add_element(cktnetlist, indModSpec(), ''L1'', {''n3'',''gnd''}, 1e-6);\n');
fprintf('%% press Enter to execute the above and show cktnetlist:\n');
pause;

% adding an inductor
cktnetlist = add_element(cktnetlist, indModSpec(), 'L1', {'n3','gnd'}, 1e-6);
cktnetlist

fprintf('\n');
fprintf('%% add a voltage source between nodes n1 and ground, named V1;\n');
fprintf('%% assign it a DC value of 1V:\n');
fprintf('cktnetlist = add_element(cktnetlist, vsrcModSpec(), ''V1'', {''n1'',''gnd''},    {},      {{''E'', {''DC'', 1.0}}});\n');
fprintf('%%                                                                          ^^         ^^^\n');
fprintf('%%                                         voltage src model has no parameters     this voltage source defines a circuit input named ''V1:::E''\n');
fprintf('%%A simpler syntax also works: cktnetlist = add_element(cktnetlist, vsrcModSpec(), ''V1'', {''n1'',''gnd''}, {''DC'', 1.0});\n');
fprintf('%%(you can also define AC, transient, etc., inputs -- help vsrcModSpec for an example.)\n');
fprintf('%% press Enter to execute the above and show cktnetlist:\n');
pause;

% adding a voltage source
%cktnetlist = add_element(cktnetlist, vsrcModSpec, 'V1', {'n1','gnd'}, {},...
%                        {{'E', {'DC', 1.0}}});
cktnetlist = add_element(cktnetlist, vsrcModSpec, 'V1', {'n1','gnd'}, {},...
                        {'DC', 1.0});
%                         ^
%           DC/transient/AC values of internal source V1:::E
cktnetlist

fprintf('\n');
fprintf('%% (OPTIONAL) next, we will define 3 outputs for printing/plotting.\n');
fprintf('%% (if no outputs are defined, all ckt unknowns are considered outputs):\n');
fprintf('cktnetlist = add_output(cktnetlist, ''n3'')\n');
fprintf('%%                                    ^^\n');
fprintf('%%                node voltage of n3 - can also be written ''e(n3)''\n');
fprintf('cktnetlist = add_output(cktnetlist, ''e(n2)'', ''n3'')\n');
fprintf('%%                                    ^^^^^^^^^^^\n');
fprintf('%%  difference between two node voltages: e(n2)-e(n3)\n');
fprintf('cktnetlist = add_output(cktnetlist, ''i(L1)'', 2.5)\n');
fprintf('%%                                    ^^^^^^^^^^^\n');
fprintf('%%                              2.5*(the current through L1)\n');
fprintf('%% press Enter to execute the above and show cktnetlist:\n');
pause;

cktnetlist = add_output(cktnetlist, 'n3');
cktnetlist = add_output(cktnetlist, 'e(n2)', 'n3');
cktnetlist = add_output(cktnetlist, 'i(L1)', 2.5);
cktnetlist

fprintf('%% cktnetlist as set up above is just a MATLAB structure; you can\n');
fprintf('%% examine it by, eg, just typing ''cktnetlist'' at the MATLAB prompt.\n');
fprintf('%% The elements above (R1, C1, L1, V1) are all in cktnetlist.elements.\n');
fprintf('%% A convenient way to examine this is:\n');
fprintf('celldisp(cktnetlist.elements)\n');
fprintf('%% press Enter to execute this:\n');
pause;
celldisp(cktnetlist.elements)

fprintf('%% cktnetlist can be now converted into a Differential Algebraic Equation\n');
fprintf('%% (DAE), on which analyses like DC, transient and AC be run.\n');
fprintf('%% press Enter to see do-it-yourself instructions for these:\n');
pause;

help vsrcRCL_demo_internal_printing; %same as below, keep them consistent or
                                     %delete comments below
                                     %use help system to avoid some fprintf()
                                     %commands

%-------------------------------------------------------------------------------
%Now we have a circuit. The circuit's information is stored in a MATLAB
%structure called cktnetlist, which can later be used in analyses.
%   (optional) to see the structure of cktnetlist, run:
%   >> cktnetlist
%   >> celldisp(cktnetlist.elements)
%
%Run analyses
%------------
%
%1. Convert the circuit into a Differential Algebraic Equation (DAE):
%   >> DAE = MNA_EqnEngine(cktnetlist);
%
%2. Calculate a DC operating point of the circuit:
%   >> dcop = op(DAE);
%      % Print operating point information:
%      feval(dcop.print, dcop);
%
%3. Run a transient simulation:
%   >> xinit = zeros(feval(DAE.nunks, DAE), 1); % zero-state step response
%      tstart = 0; tstep = 1e-7; tstop = 1.5e-5;                
%      TRANobj = transient(DAE, xinit, tstart, tstep, tstop);
%      % Plot transient simulation results:
%      feval(TRANobj.plot, TRANobj);
%
%4. Rerun transient simulation with a different input:
%   >> % Display DAE's inputs:
%        feval(DAE.inputnames, DAE)
%      % Define a transient function for V1:::E:
%        tranfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
%        tranfuncargs.A = 1; tranfuncargs.f = 1e5; tranfuncargs.phi = 0;
%      % Set DAE's transient input:
%        DAE = feval(DAE.set_utransient, tranfunc, tranfuncargs, DAE);
%      % rerun transient simulation and plot:
%        TRANobj = transient(DAE, xinit, tstart, tstep, tstop);
%        feval(TRANobj.plot, TRANobj);
%
%5. Get back to MAPPquickstart_cktdemos
%   >> help MAPPquickstart_cktdemos;
%
%See also
%--------
%
% add_element, MAPPcktnetlists, MAPPanalyses, DAE_concepts, op,
% transient, MAPPquickstart_cktdemos
