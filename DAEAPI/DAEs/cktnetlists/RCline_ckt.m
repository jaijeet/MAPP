function cktnetlist = RCline_ckt(n, R, C)
%function cktnetlist = RCline_ckt(n, R, C)
%This function returns a cktnetlist structure for an n-stage RC line
%fed by a voltage source v1(t) on the left of the first stage, and a
%current source I(t) in parallel with the last capactor.
%
%R and C in the arguments can either be scalars, or size-n arrays
%containing the values of R and C for each stage. Scalars indicate
%identical values for all stages.
%
%If not provided, n=1, R=1k, and C=1e-6 are assumed.
% 
%The circuit (ASCII art):
%
%           --<R1>-----<R2>---...--<Rn>---------
%           |       |        |           |     |
%           |       | C1     | C2        | Cn  |
%         -----    ---      ---         ---   / \ I(t)
%   v1(t)  ---     ---      ---         ---   \ /
%           |       |        |           |     |
%          ---     ---      ---         ---   ---
%          ///     ///      ///         ///   ///
%
%No inputs are set for v1 and In. Use set_uQSS, set_utransient,
%etc. to set them before simulation.
%
%No ckt outputs are set => all unknowns will be outputs.
%
%Examples
%--------
%
% % set up DAE
% DAE = MNA_EqnEngine(RCline_ckt(3));
%
% % set DC, AC, and transient inputs
% uDC = [1; 1e-3];
% DAE = feval(DAE.set_uQSS, uDC, DAE); % DC inputs
% DAE = feval(DAE.set_uLTISSS, @(f, args) [1; 0], [], DAE); % AC inputs
% DAE = feval(DAE.set_utransient, @(t, args) [sin(2*pi*1000*t); ...
%                   1e-3*pulse(t/1e-2, 0.1, 0.2, 0.6, 0.7)], [], DAE);
%
% % DC analysis
% OP = op(DAE);
% feval(OP.print, OP);
% dcsol = feval(OP.getsolution, OP);
%
% % AC analysis
% AC = ac(DAE, dcsol, [1; 1e-3], 1, 1e5, 10, 'DEC');
% feval(AC.plot, AC);
%
% % run transient simulation
% tstart = 0; tstep = 0.25e-4; tstop = 0.03;
% TR = transient(DAE, dcsol, tstart, tstep, tstop);
% feval(TR.plot, TR);
%
%
%See also
%--------
% 
% add_element, add_output, MAPPcktnetlists, cktnetlist_lowlevel,
% supported_ModSpec_devices[TODO], DAEAPI, DAE_concepts, dot_op, dot_transient 

%
%Changelog:
%Author: Jaijeet Roychowdhury, 2016/03/05
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin < 3
        C = 1e-6;
    end

    if nargin < 3
        R = 1e3;
    end

    if nargin < 1
        n = 1;
    end

    if 1 == length(R) 
        R = R*ones(1,n);
    end

    if 1 == length(C) 
        C = C*ones(1,n);
    end

    if length(R) ~= n 
        error('R is not of size n=%d', n);
    end

    if length(C) ~= n 
        error('C is not of size n=%d', n);
    end


	% ckt name
	cktnetlist.cktname = sprintf('RC line with %d stages', n);
	% nodes (names)
	for i=1:(n+1)
        cktnetlist.nodenames{i} = sprintf('%d', i);
    end
	cktnetlist.groundnodename = 'gnd'; % 


	cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'v1', {'1', 'gnd'});
    for i=1:n
	    cktnetlist = add_element(cktnetlist, resModSpec(), sprintf('R%d', i), {sprintf('%d',i+1), sprintf('%d',i)}, R(i));
	    cktnetlist = add_element(cktnetlist, capModSpec(), sprintf('C%d', i), {sprintf('%d',i+1), 'gnd'}, C(i));
    end
	cktnetlist = add_element(cktnetlist, isrcModSpec(), 'I', {sprintf('%d', n+1), 'gnd'});

    %cktnetlist = add_output(cktnetlist, '1'); % node voltage of '1'
    %cktnetlist = add_output(cktnetlist, 'e(3)', [], 'vout'); % node voltage 
    %                                          % of '3', with output name vout
    %cktnetlist = add_output(cktnetlist, 'i(vsrc1)', 1000);
    %                                    % current through vsrc1, scaled by 1000
