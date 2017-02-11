function [figh, onames, colindex] = transientPlot(DAE, tpts, vals, ...
         time_units, varargin)
%function [ofigh, olegends, oclrindex] = transientplot(DAE, tpts, vals, ...
%    time_units, stateoutputs, lgndprefix, linetype, figh, legends, ...
%    clrindex, varargin)
%    or
%function [ofigh, olegends, oclrindex] = transientplot(DAE, tpts, vals, ...
%    time_units, 'optionName1', optionVal1, 'optionName2', optionVal2, ...)
%
%NOTE: the most common way of calling transientPlot is via a transient
%analysis plot:
% > tran = dot_transient(DAE, ...);
% > feval(tran.plot, tran, args...) % this calls transientPlot
%The args above to tran.plot are simply the 5th and above transientPlot args,
%ie, you could call:
% > feval(tran.plot, tran, stateoutputs, lgndprefix, linetype, figh, ...
%   legends, clrindex, varargin) 
%
%This utility function transientPlot plots time-domain waveforms for a DAE. It
%can plot multiple waveforms in one figure, with legends, labels, etc.. The
%names of the DAE's outputs or states are used to label the waveforms plotted.
%You can provide standard MATLAB plot options via varargin.  transientPlot
%does not set a title for the plot.
%
%transientPlot can be called multiple times to update an existing figure with
%additional waveforms in a sensible way. It is the workhorse behind LMS.plot,
%which calls it via transient_skeleton::transient_plot().
%
%Arguments:
% - DAE:    A DAEAPI object (used mainly to pick up information about
%           labels, inputs and outputs). See help DAEAPI.
%
% - tpts:   array of timepoints at which data is a available - a row
%           vector.  The number of columns is the number of timepoints.
%
% - vals:   a matrix of time-domain data, with number of colums = the
%           number of timepoints in tpts. Each column of the matrix
%           correponds to a timepoint. The number of rows should equal
%           feval(DAE.nunks, DAE).
%
% In the first calling syntax:
%
% - time_units: a string denoting the units of the numbers in tpts.  defaults
%           to ''; can also be set to [] to use the default.  Used for
%           labelling.
%           Note that as of 2014/08/21, in order to make the second calling
%           syntax work, time_units is not optional anymore. If no time_units
%           is available, set this input as '' or [];
%
% - stateoutputs:   (optional) a structure/object with the format of 
%           StateOutputs(DAE) - see help StateOutputs. If not specified,
%           or set to [], the DAE's defined outputs (y = C*x + D*u) are
%           plotted. If specified, the selected state variables of the DAE
%           are plotted. To plot all state variables, set it to
%           StateOutputs(DAE).
%
% - lgndprefix: (optional) a (typically short) string that is pre-pended
%           to all legends. defaults to '' if unspecified or set to [].
%           Useful when overlaying different data for the same DAE waveform.
%
% - linetype:   (optional) string indicating the line type for MATLAB's plot
%           command - see help plot. Defaults to '.-' if not specified
%           or set to [].
%
% - figh:   (optional) figure handle for a plot to be used. If not
%           specified or set to [], a new plot is created. Typical use is with
%           ofigh returned by a previous call to transientPlot.
%
% - legends:    (optional) a cell array of strings to be used as legends
%           for existing waveforms on a previous plot with figure handle
%           figh. Typical use is to set to olegends from a previous call of
%           transientPlot. If not specified or set to [], no legends are
%           shown. This should be specified if figh is specified, otherwise
%           the legends on the plot will be wrong.
%
% - clrindex:   (optional) an integer representing the index of the colour
%           of the first waveform. Defaults to 0 if not specified or set to
%           [].  Used as argument to getcolorfromindex() to cycle through
%           different colors for different waveforms. Typical use is to set to
%           oclrindex from a previous call of transientPlot.
%
% - varargin:   (optional) any other arguments to MATLAB's plot function.
%           For example:
%               transientPlot(<standard args>, 'LineWidth', 2);
%                                              ^^^^^^^^^^^^^^^
%                                                 varargin
% In the second calling syntax:
%
% Optional comma-separated pairs of optionName-optionVal arguments:
%
% - optionName: string, must be specified inside single quotes (' ').
%       Available optionNames (case-insensitive):
%          'time_units' or 'time_unit'
%          'stateoutputs'
%          'lgndprefix' or 'prefix'
%          'linetype' or 'linestyle'
%          'figh' or 'fighandle'
%          'legends'
%          'clrindex'
%          'PLOTvarargin'
%
% - optionVal: corresponding value for optionName, see the first calling syntax
%              for the description of available values for each optionName.
%          Note that when optionName is 'PLOTvarargin', the optionVal should be
%          a cellarray of all arguments
%
% You can specify several name and value pair arguments in
% any order as optionName1, optionVal1, ..., optionNameN, optionValN.
%
% Example: 'linetype', '-o', 'stateoutputs', StateOutput
%   
%
%Return values:
% - ofigh:  figure handle of the plot. Can be passed (optionally) to a
%           future call to transientPlot().
%
% - olegends:   cell array of strings, suitable for using as argument to
%           Matlab's legend() function. Can be passed (optionally) to a
%           future call to transientPlot().
%
% - oclrindex: an integer representing the index of the last colour used in
%           the current plot. Mainly useful for passing (optionally) to a
%           future call to transientPlot.
%
%Examples
%--------
%% set up DAE
%nsegs = 2; R = 1e3; C = 1e-6;
%DAE =  RClineDAEAPIv6('', nsegs, R, C);
%
%% set transient input to the DAE
%utargs.A = 1; utargs.f=1e3; utargs.phi=0;
%utfunc = @(t, args) args.A*sin(2*pi*args.f*t + args.phi);
%DAE = feval(DAE.set_utransient, utfunc, utargs, DAE);
%
%% set up LMS object
%transobj = LMS(DAE); % default method is BE
%%run the transient
%xinit = [1;0]; tstart = 0; tstep = 10e-6; tstop = 5e-3;
%transobj = feval(transobj.solve, transobj, xinit, tstart, tstep, tstop);
%
%%extract results from transobj and plot using transientPlot
%tpts = transobj.tpts(1,1:transobj.timeptidx);
%vals = transobj.vals(:,1:transobj.timeptidx);
%time_units = DAE.time_units; % can be any string; eg 'seconds'
%souts = StateOutputs(DAE); % [] is a legal value for souts
%[figh, onames, colindex] = transientPlot(DAE, tpts, vals, ...
%           time_units, souts, 'BE (h=10us)', 'o-');     
%
%%run a second transient with a different timestep and init cond.
%%and overlay its results on the plot
%tstep = tstep/10; xinit = [-1;1];
%transobj = feval(transobj.solve, transobj, xinit, tstart, tstep, tstop);
%%overlay the second transient plot on the first one, with a different label
%tpts = transobj.tpts(1,1:transobj.timeptidx);
%vals = transobj.vals(:,1:transobj.timeptidx);
%[figh, onames, colindex] = transientPlot(DAE, tpts, vals, ...
%           time_units, souts, 'BE (h=1us)', '.-', figh, onames, colindex);
%
%%add a title to the plot
%title(sprintf('%s: transient using %s', ...
%       feval(DAE.daename, DAE), feval(transobj.name, transobj)));
%
%See also
%--------
%
% getcolorfromindex, getmarkerfromindex, LMS, transient_skeleton

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin >= 5 && ischar(varargin{1}) % second calling syntax with 'optionName'
	    % defaults
		time_units = '';
		stateoutputs = [];
		lgndprefix = '';
		linetype = '.-';
		figh = [];
		legends = {};;
		colindex = 0;
		PLOTvarargin = {};

	    % assign options
		for c = 1:floor(length(varargin)/2)
			optionName = lower(varargin{2*c-1}); % make it case-insensitive
			optionVal = varargin{2*c};
			if strcmp(optionName, 'time_units') || strcmp(optionName, 'time_unit')
				time_units = optionVal;
			elseif strcmp(optionName, 'stateoutputs')
				stateoutputs = optionVal;
			elseif strcmp(optionName, 'lgndprefix') || strcmp(optionName, 'prefix')
				lgndprefix = optionVal;
			elseif strcmp(optionName, 'linetype') || strcmp(optionName, 'linestyle')
				linetype = optionVal;
			elseif strcmp(optionName, 'figh') || strcmp(optionName, 'fighandle')
				figh = optionVal;
			elseif strcmp(optionName, 'legends')
				legends = optionVal;
			elseif strcmp(optionName, 'colindex')
				colindex = optionVal;
			elseif strcmp(optionName, 'plotvarargin')
				PLOTvarargin = optionVal;
			end
		end

		% post-process stateoutputs to get onames
        if 0 == sum(size(stateoutputs))
            % plot DAE outputs
            C = feval(DAE.C, DAE);
            D = feval(DAE.D, DAE);
            onames = feval(DAE.outputnames, DAE);
        else % plot state outputs specified in stateoutputs
            % set up C, D, onames
            ninps = feval(DAE.ninputs, DAE);
            nunks = feval(DAE.nunks, DAE);
            varidxs = feval(stateoutputs.OutputIndices, stateoutputs);

            D = zeros(length(varidxs), ninps);
            C = sparse([]); C(length(varidxs), nunks)=0;
            for i=1:length(varidxs)
                C(i,varidxs(i)) = 1; 
            end
            onames = feval(stateoutputs.OutputNames, stateoutputs);
        end
    else % first syntax
        if nargin >= 5
            stateoutputs = varargin{1};
        end
		if nargin < 5 || isempty(stateoutputs);
			% plot DAE outputs
			C = feval(DAE.C, DAE);
			D = feval(DAE.D, DAE);
			onames = feval(DAE.outputnames, DAE);
		else % plot state outputs specified in stateoutputs
			% set up C, D, onames
			ninps = feval(DAE.ninputs, DAE);
			nunks = feval(DAE.nunks, DAE);
			D = zeros(nunks, ninps);

			varidxs = feval(stateoutputs.OutputIndices, stateoutputs);
			C = sparse([]); C(length(varidxs), nunks)=0;
			for i=1:length(varidxs)
				C(i,varidxs(i)) = 1;
			end
			onames = feval(stateoutputs.OutputNames, stateoutputs);
		end

        if nargin >= 6
            lgndprefix = varargin{2};
        end
		if nargin < 6 || isempty(lgndprefix)
			lgndprefix = '';
		end

        if nargin >= 7
            linetype = varargin{3};
        end
		if nargin < 7 || isempty(linetype);
			linetype = '.-';
		end

        if nargin >= 8
            figh = varargin{4};
        end
		if nargin < 8 || isempty(figh)
			figh = figure;
		else
			figh = figure(figh);
		end

        if nargin >= 9
            legends = varargin{5};
        end
		if nargin < 9 || isempty(legends)
			legends = {};;
		end

        if nargin >= 10
            colindex = varargin{6};
        end
		if nargin < 10 || isempty(colindex)
			colindex = 0;
		end

        if nargin >= 11
			PLOTvarargin = varargin{11:end};
		else
			PLOTvarargin = {};
        end
	end

    hold on;

    ninputs = feval(DAE.ninputs, DAE);
    % current timepoint term
    if  ninputs > 0
        uts = feval(DAE.utransient, tpts, DAE); % each col is a timepoint
    else
        uts = [];
    end
    for i=1:size(C,1)
        c = C(i,:);
        plotvals = c*vals;
        if ninputs > 0
            d = D(i,:);
            plotvals = plotvals + d*uts;
        end
        colindex = colindex+1;
        thiscol = getcolorfromindex(gca,colindex);
        plot(tpts, plotvals, linetype, 'color', thiscol, PLOTvarargin{:});
    end

    if (0 == strcmp('', lgndprefix))
        for i=1:length(onames)
            onames{i} = escape_special_characters(sprintf('%s: %s', ...
                                lgndprefix, onames{i}));
        end
    else
        for i=1:length(onames)
            onames{i} = escape_special_characters(onames{i});
        end
    end
    % s#_#\_#g
    % onames = strrep(onames, '_', '\_');

    if length(legends) > 0
        onames = {legends{:}, onames{:}};
    end

    %legend(onames, 'Location', 'SouthWest');
    legend(onames, 'Location', 'Best');
    timelabel = 'time';
    if length(time_units) > 0
        timelabel = escape_special_characters(...
                        sprintf('%s (%s)', timelabel, time_units));
    end
    xlabel(timelabel);
    ylabel 'values';
    grid on; axis tight;
end % of function transientPlot
