function oobj = dcsweep2(DAE, initguess, inpORparm1NAME, ...
                                inpORparm1Range, IsInpORparm1, ...
                                inpORparm2NAME,inpORparm2Range,IsInpORparm2, ...
                                init, limiting)
%function QSSsweep2Obj = dcsweep2(DAE, initguess, inpORparm1NAME, 
%                                inpORparm1Range, IsInpORparm1, ...
%                                inpORparm2NAME,inpORparm2Range,IsInpORparm2,...
%                                init, limiting)
%
%Run a DC sweep analysis on DAE with respect to two inputs/parameters.
%
%dcsweep2 calls QSS' solve method multiple times while stepping a specified input
%or parameter of the DAE. It returns a QSSsweep2 object, whose plot, plot3,
%getsolution and print methods can be used to examine the results.
%
%Arguments:
%
% - DAE:       A DAEAPI object. See DAEAPI.
%
% - initguess: initial guess for the Newton-Raphson (NR) method.  If set to
%              [], a vector of zeros is used as a last resort (though this is
%              typically a very bad choice of initial guess for NR, unless
%              init and limiting are active - see below).
%
% - inpORparm1NAME: the name of an input to the DAE (from feval(DAE.inputnames,
%              DAE)) or a parameter of the DAE (from feval(DAE.parmnames,DAE)).
%              This input or parameter will be swept.
%
% - inpORparm1Range: an array of values to step inpORparm1NAME through. Eg,
%              -0.5:0.1:0.5 or 10:-0.1:9. Need not be monotonic or "continuous",
%              but continuity is recommended for convergence.
%
% - IsInpORparm1: (usually optional) use to specify whether inpORparm1NAME is an
%              input or a parameter: 1 => input, 0 => parameter. Needed only for
%              disambiguation if the same string inputORparm1NAME is both an
%              input and a parameter of the DAE.
%
% - inpORparm2NAME: like inpORparm2NAME, but for the second sweep input/parameter.
%
% - inpORparm2Range: like inpORparm1Range, but for the second input/parameter.
%
% - IsInpORparm2: (optional unless init/limit specified) like IsInpORparm1, but 
%              for the second sweep input/parameter. Use [] if not specifying
%              but followed by init/limit arguments (see below).
%
% - init:      (optional unless limit specified) use ModSpec/DAEAPI device 
%              initialization for NR (default = 1).  Try setting to 0 if you have
%              a good initguess and the first point of dcsweep is not converging.
%              Use [] to select the default if specifying limit (see below).
%
% - limiting:  (optional) use ModSpec/DAEAPI device limiting for NR 
%              (default = 1).  Try setting to 0 if you have a good initguess
%              and the first point of dcsweep is not converging.
%
%
%Return values:
%
% - QSSsweep2Obj: The QSSsweep2 object created. How to use it:
%
%
%              feval(QSSsweep2Obj.plot, QSSsweepObj2, threeD): plot sweep 
%                   results as 2D (threeD not specified, or specified but not = 3
%                   or '3') or 3D (threeD='3' or 3).  Creates a separate figure
%                   for each output. 
%                   
%                   For 2D plots, each figure consists of multiple plot traces,
%                   one for each value of inpORparm2NAME, i.e., each trace plots
%                   the output against inpORparm1NAME for one value of
%                   inpORparm2NAME. Each figure is in the format of, typical BJT
%                   or MOS characteristic curves. To interchange inpORparm1NAME
%                   and inpORparm2NAME in 2D plotting, set threeD to anything
%                   except 0, 3, and '3'.
%                   
%                   3D plots use MATLAB's surf().
%
%              [inpORparm1VALS, inpORparm2VALS, solutions] = ...
%                           feval(QSSsweep2Obj.getsolution, QSSsweep2Obj);
%                inpORparm1VALS: the values of inputORparm1NAME used in
%                             for the sweep (a row vector).
%                inpORparm2VALS: the values of inputORparm2NAME used in
%                             for the sweep (a row vector).
%                solutions: the solutions of the sweep as a 3D matrix.
%                             Solutions(:,i,j) is the QSS solution
%                             for the ith value of inpORparm1VALS and jth value
%                             of inpORparm2VALS (it is of size feval(DAE.nunks,
%                             DAE)). The matrix solutions(k,:,:) are the QSS
%                             solutions of the kth DAE unknown (from
%                             feval(DAE.unknames, DAE)), for
%                             all values of inpORparm1VALS and inpORparm2VALS.
%
%              % feval(QSSsweep2Obj.print, QSSsweep2Obj); % print sweep solutions
%              % TODO: not implemented yet
%
%Examples
%--------
% ntlst = MVS_char_curves_ckt(); ntlst=add_output(ntlst, 'i(Vdd)', -1);
% DAE = MNA_EqnEngine(ntlst);
% feval(DAE.inputnames, DAE) % will show the available inputs for the DAE
%
% % run a sweep vs Vdd and Vgg
% swp = dcsweep2(DAE, [], 'Vdd:::E', 0:0.1:3, 'Vgg:::E', 0:0.1:1);
%
% % plots
% feval(swp.plot, swp); % 2D plot: output vs Vdd, each curve for one value of Vgg
% feval(swp.plot, swp, 1); % 2D plot: Vgg/Vdd interchanged for plotting
% feval(swp.plot, swp, 3); % 3D plot
% % feval(swp.print, swp); % not implemented yet
%
% % run another sweep: vs Vdd and the width parameter of the MOS device
% DAE.parmnames(DAE) % shows the names of all parameters
% swp = dcsweep2(DAE, [], 'Vdd:::E', 0:0.1:3, 'NMOS:::W', [0.5,1,1.5,2]*1e-4);
%
% % plots
% feval(swp.plot, swp); % 2D plot: output vs Vdd, each curve for one value of W
% feval(swp.plot, swp, 1); % 2D plot: W/Vdd interchanged for plotting
% feval(swp.plot, swp, 3); % 3D plot
%
%
% % get solutions for all unknowns
% [Vdds, Ws, all_unk_vals] = swp.getSolution(swp);
% % all_unk_vals is a 3D matrix
%
% % plot the 6rd DAE unknown as a 3D graph (DAE.unknames(DAE) shows its name).
% figure();
% surf(Ws, Vdds, squeeze(all_unk_vals(6, :, :))); 
% xlabel('Ws'); ylabel('Vdds'); zlabel('Vsib'); 
% title('voltage at internal source node'); view(3);
%
%See also
%--------
%
% dcsweep, op, QSS, NR, transient, ac, DAEAPI.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2016 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin < 6
        error('dcsweep2 requires at least 6 arguments.');
    end

	% setup skeleton: data and function pointers
    oobj.solutions = [];
	oobj.solvalid = 0;
	% oobj.print = @dcsweep_print; % below
	oobj.plot = @dcsweep2_plot; % below
	% oobj.plot3 = @dcsweep2_plot3; % below
	oobj.getsolution = @dcsweep2_getsolution; % below
	oobj.getSolution = @dcsweep2_getsolution; 

    %%%%%%%%%%%% begin setting up inpORparm1
	idx1 = find(strcmp(inpORparm1NAME, feval(DAE.inputnames, DAE)));

	oobj.IsInpORparm1 = -1; % dummy value, just to define oobj.IsInpORparm2
	if 1 == length(idx1)
		oobj.IsInpORparm1 = 1; % input
		oobj.inpORparm1idx = idx1;
	elseif length(idx1) > 1
		error('dcsweep2: input name %s found more than once amongst DAE inputs (DAE definition error)');
	end

	if isnumeric(IsInpORparm1) && (~isempty(IsInpORparm1)) && ~(0 == IsInpORparm1 || 1 == IsInpORparm1)
		error('dcsweep2: mostly optional argument IsInpORparm1, if specified, must be either 1 or 0 or [] (you supplied %d)', IsInpORparm1);
	end

	idx1_2 = find(strcmp(inpORparm1NAME, feval(DAE.parmnames, DAE)));
	if 1 == length(idx1_2)
		if 1 == oobj.IsInpORparm1 % already found as an input
			if isnumeric(IsInpORparm1) && (~isempty(IsInpORparm1)) % IsInpORparm1 specified in call
				oobj.IsInpORparm1 = IsInpORparm1;
				if 0 == IsInpORparm1
					oobj.inpORparm1idx = idx1_2;
				end
			else
				error('\ndcsweep: %s is both an input and a parameter. Please specify the IsInpORparm1 argument.', inpORparm1NAME);
			end
		else
			oobj.IsInpORparm1 = 0; % parameter
			oobj.inpORparm1idx = idx1_2;
		end
	elseif length(idx1_2) > 1
		error('dcsweep: parameter name %s found more than once amongst DAE parameters (DAE definition error)', inpORparm1NAME);
	end

	if -1 == oobj.IsInpORparm1
		error('dcsweep: %s not found amongst DAE inputs or parameters.', inpORparm1NAME);
	end

	oobj.inpORparm1NAME = inpORparm1NAME;
    %%%%%%%%% end setting up inpORparm1


    %%%%%%%%%%%% begin setting up inpORparm2

    % rename args if IsInpORparm1 was not specified
	if ~isnumeric(IsInpORparm1) || isempty(IsInpORparm1) % IsInpORparm1 NOT specified in call
        if nargin > 8 % limiting has been specified
            limiting = init;
        else
            limiting = [];
        end
        if nargin > 7 % init has been specified
            init = IsInpORparm2;
        else
            init = [];
        end
        if nargin > 6 % IsInpORparm2 has been specified
            IsInpORparm2 = inpORparm2Range;
        else
            IsInpORparm2 = [];
        end
        inpORparm2Range = inpORparm2NAME;
        inpORparm2NAME = IsInpORparm1;
    else % IsInpORparm1 WAS specified in call
        % no renaming necessary, but we set up limiting, init and IsInpORparm2
	    if nargin <= 9 % limiting not specified
            limiting = [];
        end
	    if nargin <= 8 % init not specified
            init = [];
        end
	    if nargin <= 7 % IsInpORparm2 not specified
            IsInpORparm2 = [];
        end
    end % rename args

	idx2 = find(strcmp(inpORparm2NAME, feval(DAE.inputnames, DAE)));

	oobj.IsInpORparm2 = -1; % dummy value, just to define oobj.IsInpORparm2
	if 1 == length(idx2) % found as an input
		oobj.IsInpORparm2 = 1; % input
		oobj.inpORparm2idx = idx2;
	elseif length(idx2) > 1
		error('dcsweep2: input name %s found more than once amongst DAE inputs (DAE definition error)');
	end

	if (~isempty(IsInpORparm2)) && ~(0 == IsInpORparm2 || 1 == IsInpORparm2)
            error('dcsweep2: IsInpORparm2, if specified, must be either 1 or 0 or [] (you supplied %d)', IsInpORparm2);
    end

	idx2_2 = find(strcmp(inpORparm2NAME, feval(DAE.parmnames, DAE)));
	if 1 == length(idx2_2) % found as a parameter
		if 1 == oobj.IsInpORparm2 % was also found as an input
			if ~isempty(IsInpORparm2) % IsInpORparm2 is 0 or 1
				oobj.IsInpORparm2 = IsInpORparm2;
				if 0 == IsInpORparm2
					oobj.inpORparm2idx = idx2_2;
				end
			else
				error('\ndcsweep: %s is both an input and a parameter. Please specify the IsInpORparm2 argument.', inpORparm2NAME);
			end
		else % was not found as an input
			oobj.IsInpORparm2 = 0; % parameter
			oobj.inpORparm1idx = idx2_2;
		end
	elseif length(idx2_2) > 1
		error('dcsweep: parameter name %s found more than once amongst DAE parameters (DAE definition error)', inpORparm2NAME);
	end

	if -1 == oobj.IsInpORparm2
		error('dcsweep: %s not found amongst DAE inputs or parameters.', inpORparm2NAME);
	end

	oobj.inpORparm2NAME = inpORparm2NAME;
    %%%%%%%%%%%%%%%%%%%%%%%%%% end setting up inpORparm2



    if isempty(init)
        init = 1;
    end

    if isempty(limiting)
        limiting = 1;
    end

	oobj.allstepvals1 = inpORparm1Range;
	oobj.allstepvals2 = inpORparm2Range;

	% NRParms
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
            fprintf(2,'dot_dcsweep: no initguess provided for DC sweep initial point;\n using zero vector.\n');
    end

	i = 1;  
	while i <= length(oobj.allstepvals1)
        curval1 = oobj.allstepvals1(i);
        if 1 == oobj.IsInpORparm1
            DAE = feval(DAE.set_uQSS, inpORparm1NAME, curval1, DAE);
        else
            DAE = feval(DAE.setparms, inpORparm1NAME, curval1, DAE);
        end
        j = 1;
	    while j <= length(oobj.allstepvals2)
            curval2 = oobj.allstepvals2(j);
            if 1 == oobj.IsInpORparm2
                DAE = feval(DAE.set_uQSS, inpORparm2NAME, curval2, DAE);
            else
                DAE = feval(DAE.setparms, inpORparm2NAME, curval2, DAE);
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
                fprintf(1, 'QSS failed at %s=%g, %s=%g\nre-running with NR progress enabled\n', inpORparmNAME1, curval1, inpORparmNAME2, curval2);
                NRparms.dbglvl = 2;
                oobj.QSSobj = feval(oobj.QSSobj.setNRparms, NRparms, ...
                                   oobj.QSSobj);
                oobj.QSSobj = feval(oobj.QSSobj.solve, initguess, ...
                            oobj.QSSobj);
                error('aborting DC sweep due to QSS failure.');
            else
                fprintf(1, '\t\tsolve succeeded at (%s,%s)=(%g,%g)\n',...
                                inpORparm1NAME, inpORparm2NAME, curval1, curval2);
                oobj.solutions(:,i,j) = sol;
                oobj.inputs(:,i,j) = feval(DAE.uQSS, DAE);
                if 1 == j
                    prev_sol_at_j_EQ_1 = sol;
                end
                initguess = sol;
                j = j+1;
            end
	    end % while j
        i = i+1;
        initguess = prev_sol_at_j_EQ_1;
	end % while i

	oobj.solvalid = 1;
end % dot_dcsweep "constructor"

function [pts1, pts2, vals3D] = dcsweep2_getsolution(oobj)
%function [pts1, pts2, vals3D] = dcsweep2_getsolution(oobj)
%Private method of dcsweep2. See dcsweep for usage.
	if 1 == oobj.solvalid
		pts1 = oobj.allstepvals1;
		pts2 = oobj.allstepvals2;
		vals3D = oobj.solutions;
	else
		error('dcsweep2: solution not valid');
	end
end % dcsweep2_getsolution

function figs = dcsweep2_plot(oobj, threeD)
%function figs = dcsweep2_plot(oobj, threeD)
%Private method of dcsweep2. See dcsweep2 for usage.
%TODO: support stateoutputs. Also support one plot or multiple plots, and
%returning the figure handle if one plot. At the moment, plots all DAE outputs in
%separate plots.

	if 0 == oobj.solvalid
		error('dcsweep2 solution not valid');
	end
	names = feval(oobj.QSSobj.DAE.outputnames, oobj.QSSobj.DAE);
	DAEname = feval(oobj.QSSobj.DAE.daename, oobj.QSSobj.DAE);

    % TODO: no StateOutputs support yet, just DAE-defined outputs
    C = feval(oobj.QSSobj.DAE.C, oobj.QSSobj.DAE);
    D = feval(oobj.QSSobj.DAE.D, oobj.QSSobj.DAE);

    for j = 1:length(oobj.allstepvals2)
        outputvals(:,:,j) = C*oobj.solutions(:,:,j) + D*oobj.inputs(:,:,j);
    end

    if nargin == 2 && (strncmp(threeD, '3',1) || 3==threeD)
        plottype = 1; % 3D
    else
        plottype = 0; % 3D
    end

    if nargin < 2 
        threeD = 0; % => 2D plot without 1/2 reversal
    end

    % 2D: set up labelnames with 1/2 reversal
    if 0 == plottype && threeD == 0
        for j = 1:length(oobj.allstepvals2)
            labelnames{j} = sprintf('%s=%g', oobj.inpORparm2NAME, ...
                                                oobj.allstepvals2(j));
        end
    else
        for j = 1:length(oobj.allstepvals1)
            labelnames{j} = sprintf('%s=%g', oobj.inpORparm1NAME, ...
                                                oobj.allstepvals1(j));
        end
    end

    % 2 or 3D plots
	for i = 1:length(names)
        figure(); hold on;
        if 0 == plottype % 2D
            if 0 == threeD
	            xlabel(oobj.inpORparm1NAME); % no reversal
            else
	            xlabel(oobj.inpORparm2NAME); % reversal
            end
            ylabel(escape_special_characters(names{i}));
        else % 3D
	        ylabel(oobj.inpORparm1NAME);
	        xlabel(oobj.inpORparm2NAME);
            zlabel(escape_special_characters(names{i}));
        end

        if 0 == plottype % 2D
            if 0 == threeD % no reversal
                for j = 1:length(oobj.allstepvals2)
                    col = getcolorfromindex(gca, j);
                    plot(oobj.allstepvals1, outputvals(i,:,j), '.-', ...
                                                                'Color', col);
                end
                title(escape_special_characters(...
                    sprintf('%s: DC sweep: %s vs %s', DAEname, ...
                        names{i}, oobj.inpORparm1NAME)));
            else % reversal
                for j = 1:length(oobj.allstepvals1)
                    col = getcolorfromindex(gca, j);
                    plot(oobj.allstepvals2, squeeze(outputvals(i,j,:)),'.-', ...
                                                                'Color', col);
                end
                title(escape_special_characters(...
                    sprintf('%s: DC sweep: %s vs %s', DAEname, ...
                        names{i}, oobj.inpORparm2NAME)));
            end
            legend(labelnames);
            grid on; axis tight;
        else % 3D
            surf(oobj.allstepvals2, oobj.allstepvals1, ...
                                            squeeze(outputvals(i,:,:)));
            title(escape_special_characters(...
                sprintf('%s: DC sweep of %s vs %s and %s', DAEname, ...
                    names{i}, oobj.inpORparm1NAME, oobj.inpORparm2NAME)));
            grid on; axis tight;
            view(3);
        end
	    drawnow;
    end % for i=names
end % dcsweep2_plot
