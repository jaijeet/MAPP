function oobj = dcsweep(DAE, initguess, inpORparmNAME, inpORparmRange, ...
                                 inpORparm, init, limiting)
%function QSSsweepObj = dcsweep(DAE, initguess, inpORparmNAME, ...
%                       inpORparmRange, IsInpORparm, init, limiting)
%
%Run a DC sweep analysis on DAE with respect to one input or parameter.
%
%dcsweep calls QSS' solve method multiple times while stepping a specified
%input or parameter of the DAE. It returns a QSSsweep object, whose plot,
%getsolution and print methods can be used to examine the results.
%
%Arguments:
%
% - DAE:       A DAEAPI object. See DAEAPI.
%
% - initguess: initial guess for the Newton-Raphson (NR) method.  If set to
%              [], the DAE's QSSinitGuess() function is used to obtain an
%              initial guess. If that is not set up properly, a vector of
%              zeros is used as a last resort (though this is typically a very
%              bad choice of initial guess for NR).
%
% - inpORparmNAME: the name of an input to the DAE (from feval(DAE.inputnames,
%              DAE)) or a parameter of the DAE (from feval(DAE.parmnames,DAE)).
%              This input or parameter will be swept.
%
% - inpORparmRange: an array of values to step inpORparmNAME through. Eg,
%              -0.5:0.1:0.5 or 10:-0.1:9. Need not be monotonic or "continuous",
%              but continuity is recommended for convergence.
%
% - IsInpORparm: (usually optional) use to specify whether inpORparmNAME is an 
%              input or a parameter: 1 => input, 0 => parameter. Needed only
%              for disambiguation if the same string inputORparmNAME is both
%              an input and a parameter of the DAE.
%
% - init:      (optional) use ModSpec/DAEAPI device initialization for NR 
%              (default = 1).  Try setting to 0 if you have a good initguess
%              and the first point of dcsweep is not converging.
%
% - limiting:  (optional) use ModSpec/DAEAPI device limiting for NR 
%              (default = 1).  Try setting to 0 if you have a good initguess
%              and the first point of dcsweep is not converging.
%
%
%Return values:
%
% - QSSsweepObj: The QSSsweep object created. How to use it:
%
%
%              feval(QSSsweepObj.plot, QSSsweepObj); % plot sweep solutions
%
%              [inpORparmVALS, solutions] = feval(QSSsweepObj.getsolution, ...
%                                                                  QSSsweepObj);
%                % inpORparmVALS: the values of inputORparmNAME used in
%                             for the sweep (a row vector).
%                % solutions: the solutions of the sweep, as a matrix. The
%                             jth column solutions(:,j) is the QSS solution
%                             for the jth entry of inpORparmVALS (it is of
%                             size feval(DAE.nunks, DAE)). The ith row
%                             solutions(i,:) are the QSS solutions of the ith
%                             DAE unknown (from feval(DAE.unknames, DAE)), for
%                             all values of inpORparmVALS.
%
%              % feval(QSSsweepObj.print, QSSsweepObj); % print sweep solutions
%              % TODO: not implemented yet
%
%Examples
%--------
%
% %%%%%%%%% Example 1 %%%%%%%%%%%%%%
% DAE = vsrcRLCdiode_daeAPIv6(); % set up the DAE
% feval(DAE.inputnames, DAE) % will show the available inputs for the DAE
%
% swp = dcsweep(DAE, [], 'E', -1:0.04:1);
% % print and plot
% feval(swp.plot, swp); % this plots all DAE outputs = all DAE unknowns
% % feval(swp.print, swp); % not implemented yet
%
% % get DC sweep solutions and plot VC-Vin curve
% [Vins, sols] = swp.getSolution(swp);
% vCidx = DAE.unkidx('vC', DAE);
% plot(Vins, sols(vCidx, :), '-r.', 'LineWidth', 2);
% xlabel('Vin'); ylabel('VC:voltage across the capacitor');
% grid on; box on;
%
% %%%%%%%%% Example 2 (char curve of MVS transistor with Vgs fixed to 1V) %%%%%
% ntlst = MVS_char_curves_ckt(); ntlst=add_output(ntlst, 'i(Vdd)', -1);
% DAE = MNA_EqnEngine(ntlst);
% feval(DAE.inputnames, DAE) % will show the available inputs for the DAE
%
% DAE = feval(DAE.set_uQSS, 'Vgg:::E', 1.0);
%
% % run a sweep vs Vdd
% swp = dcsweep(DAE, [], 'Vdd:::E', 0:0.1:3);
%
% % plot
% feval(swp.plot, swp); % 
%
%See also
%--------
%
% dcsweep2, op, QSS, NR, transient, ac, DAEAPI.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% setup skeleton: data and function pointers
	oobj.allstepvals = inpORparmRange; 
    oobj.solutions = [];
	oobj.solvalid = 0;
	% oobj.print = @dcsweep_print; % below
	oobj.plot = @dcsweep_plot; % below
	oobj.getsolution = @dcsweep_getsolution; % below
	oobj.getSolution = @dcsweep_getsolution; 

	idx = find(strcmp(inpORparmNAME, feval(DAE.inputnames, DAE)));

	oobj.inpORparm = -1; % dummy value, just to define oobj.inpORparm
	if 1 == length(idx)
		oobj.inpORparm = 1; % input
		oobj.inpORparmidx = idx;
	elseif length(idx) > 1
		error('dcsweep: input name %s found more than once amongst DAE inputs (DAE definition error)');
	end

	if nargin > 4 && ~(0 == inpORparm || 1 == inpORparm)
		error('dcsweep: optional argument inpORparm, if specified, must be either 1 or 0 (you supplied %d)', inpORparm);
	end

	idx2 = find(strcmp(inpORparmNAME, feval(DAE.parmnames, DAE)));
	if 1 == length(idx2)
		if 1 == oobj.inpORparm % already found as an input
			if nargin > 4 % inpORparm specified in call
				oobj.inpORparm = inpORparm;
				if 0 == inpORparm
					oobj.inpORparmidx = idx2;
				end
			else
				error('\ndcsweep: %s is both an input and a parameter. Please specify the inpORparm argument.', inpORparmNAME);
			end
		else
			oobj.inpORparm = 0; % parameter
			oobj.inpORparmidx = idx2;
		end
	elseif length(idx2) > 1
		error('dcsweep: parameter name %s found more than once amongst DAE parameters (DAE definition error)', inpORparmNAME);
	end

	if -1 == oobj.inpORparm
		error('dcsweep: %s not found amongst DAE inputs or parameters.', inpORparmNAME);
	end

	oobj.inpORparmNAME = inpORparmNAME;

    if (nargin < 6) || isempty(init)
        init = 1;
    end

    if (nargin < 7) || isempty(limiting)
        limiting = 1;
    end

	% NParms
        NRparms = defaultNRparms();
        NRparms.maxiter = 100;
        NRparms.reltol = 1e-5;
        NRparms.abstol = 1e-10;
        NRparms.residualtol = 1e-10;
        NRparms.limiting = limiting;
        NRparms.init = init;
        NRparms.dbglvl = 1; % minimal output
        NRparms.method = 1;


        if isempty(initguess)
                initguess = zeros(feval(DAE.nunks,DAE),1);
                fprintf(2,'dcsweep: no initguess provided for DC sweep initial point;\n using zero vector.\n');
        end

	i = 1;
	while i <= length(oobj.allstepvals)
		curval = oobj.allstepvals(i);
		if 1 == oobj.inpORparm
			DAE = feval(DAE.set_uQSS, inpORparmNAME, curval, DAE);
		else
			DAE = feval(DAE.setparms, inpORparmNAME, curval, DAE);
		end
        oobj.QSSobj = QSS(DAE, NRparms);
        oobj.QSSobj = feval(oobj.QSSobj.solve, initguess, oobj.QSSobj);
        [sol, iters, success] = feval(oobj.QSSobj.getSolution, oobj.QSSobj);

		if (success ~= 1) || sum(NaN == sol)
			% try with device initialization
			if 0 == NRparms.init || 0 == NRparms.limiting
				NRparms.init = 1;
				NRparms.limiting = 1;
				continue;
			end
			% declare failure
			fprintf(1, 'QSS failed at %s=%g\nre-running with NR progress enabled\n', inpORparmNAME, curval);
			NRparms.dbglvl = 2;
			oobj.QSSobj = feval(oobj.QSSobj.setNRparms, NRparms, ...
			                   oobj.QSSobj);
			oobj.QSSobj = feval(oobj.QSSobj.solve, initguess, ...
					    oobj.QSSobj);
			error('aborting DC sweep due to QSS failure.');
		else
			fprintf(1, '\t\tsolve succeeded at %s=%g\n',...
				   			inpORparmNAME, curval);
			oobj.solutions(:,i) = sol;
			oobj.inputs(:,i) = feval(DAE.uQSS, DAE);
			initguess = sol;
			i = i+1;
		end
	end

	oobj.solvalid = 1;
end % dcsweep "constructor"

function [pts, vals] = dcsweep_getsolution(oobj)
%function [pts, vals] = dcsweep_getsolution(oobj)
%Private method of dcsweep. See dcsweep for usage.
	if 1 == oobj.solvalid
		pts = oobj.allstepvals;
		vals = oobj.solutions;
	else
		error('dcsweep solution not valid');
	end
end % dcsweep_getsolution

function figs = dcsweep_plot(oobj)
%function figs = dcsweep_plot(oobj)
%Private method of dcsweep. See dcsweep for usage.
%TODO: support stateoutputs and DAE-defined outputs (via C and D). Also
%support one plot or multiple plots, and returning the figure handle if one
%plot. At the moment, plots all DAE unknowns in separate plots.

	if 0 == oobj.solvalid
		error('dcsweep solution not valid');
	end
	names = feval(oobj.QSSobj.DAE.outputnames, oobj.QSSobj.DAE);
	DAEname = feval(oobj.QSSobj.DAE.daename, oobj.QSSobj.DAE);

    % TODO: no StateOutputs support yet, just DAE-defined outputs
    C = feval(oobj.QSSobj.DAE.C, oobj.QSSobj.DAE);
    D = feval(oobj.QSSobj.DAE.D, oobj.QSSobj.DAE);
    outputvals = C*oobj.solutions + D*oobj.inputs;

    figure(); hold on;
	xlabel(oobj.inpORparmNAME);
    ylabel('output values');

	for i = 1:length(names)
        col = getcolorfromindex(gca, i);
	    plot(oobj.allstepvals, outputvals(i,:), '.-', 'Color', col);
        names{i} = escape_special_characters(names{i});
    end
    legend(names);
    grid on; axis tight;
    title(escape_special_characters(...
            sprintf('%s: DC sweep: DAE outputs vs %s', DAEname, ...
                    oobj.inpORparmNAME) ...
         ));
	drawnow;

    %{
    OLD: plot all outputs in separate figures
	for i = 1:length(names)
		figs{i} = figure();
		plot(oobj.allstepvals, oobj.solutions(i,:), 'b.-');
		xlabel(oobj.inpORparmNAME);
		ylabel(names{i});
		grid on; axis tight;
		title(sprintf('%s: DC sweep of %s vs %s', ...
			DAEname, names{i}, oobj.inpORparmNAME));
		drawnow;
	end
    %}
end % dcsweep_plot
