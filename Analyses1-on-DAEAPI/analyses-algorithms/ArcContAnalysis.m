function outObj = ArcContAnalysis(DAE, lambdaName, InputOrParm)
%function outObj = ArcContAnalysis(DAE, lambdaName, InputOrParm)
%This is a driver/usability layer around ArcCont, which does most
%of the real work for arclength continuation.
%
%DAE: DAE object to run continuation on
%lambdaName: name of (scalar) input or parameter to treat as lambda
%InputOrParm: 1 if lambdaName is an input; 0 if it is a parameter.
%
%methods:
%- solve
%- getsolution
%- plotVsArcLen
%[figh, newlegends, colindex] = plot==plotVsLambda(ACAobj, ...
%                                        stateoutputs=[], lgndprefix='', ...
%                                        linetype='.-', ...
%                                        figh=[], legends={}, colindex=0)
%
%data:
%- ACobj: an ArcCont object
%- parms: copy of ACobj.ArcContParms, possibly with modifications
%- solution: solution of the homotopy (valid only after solve called and if 
%  it succeeds)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2011/11/25                                         %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%%               reserved.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	outObj.DAE = DAE;
	outObj.InputOrParm = InputOrParm;
	outObj.lambdaName = lambdaName;

	% check that lambdaName exists in the DAE, store its index
	if 1 == InputOrParm 
		allnames = feval(DAE.inputnames, DAE);
	else
		allnames = feval(DAE.parmnames, DAE);
	end
	idx = find(strcmp(lambdaName, allnames));
	if isempty(idx) || length(idx) > 1
		error('ArcContAnalysis: %s not found exactly once in DAE''s inputs or parameters');
	end
	outObj.lambdaIdx = idx;

	if 0 == InputOrParm
		% create and store a parmObj with the lambda parameter - used in dfq_dp
		outObj.parmObj = Parameters(DAE);
		outObj.parmObj = feval(outObj.parmObj.DeleteAll, outObj.parmObj);
		outObj.parmObj = feval(outObj.parmObj.Add, {lambdaName}, outObj.parmObj);
	end

	%{
	% check that DAE.uQSSvec_default is of numeric type
	% TOFIX: this check is not DAEAPI compliant
	if ~isa(DAE.uQSSvec_default, 'numeric')
		error('ArcContAnalysis: DAE.uQSSvec_default is not set up (not of numeric type)');
	end
	%}

	% copy default parameters for ArcCont
	ACobj = ArcCont([], [], []); % empty ArcCont object, but has default parms defined
	parms = ACobj.ArcContParms;

	% set up g(x,lambda) for ArcCont
		% done in g and dg_dxLambda

	% set up return function handles and data
	outObj.parms = parms;
	outObj.solve = @ArcContAnalSolve;
	outObj.getsolution = @(obj) obj.solution;
	outObj.plotVsArcLen = @ACAplotVsArcLen;
	outObj.plot = @ACAplotVsLambda;
	%outObj.plotVsLambda = ???
	outObj.solution = 'undefined';
end % ArcContAnalysis

function out = ACA_g(y, ArcContAnalObj)
	lambda = y(end,1);
	x = y(1:(end-1),1);

	DAE = ArcContAnalObj.DAE;

	u = feval(DAE.uQSS, DAE);
	if 1 == ArcContAnalObj.InputOrParm
		u(ArcContAnalObj.lambdaIdx,1) = lambda;
		DAE = feval(DAE.set_uQSS, u, DAE);
	else
		DAE = feval(DAE.setparms, ArcContAnalObj.lambdaName, lambda, DAE);
	end


	if 1 == ArcContAnalObj.DAE.f_takes_inputs
		out = feval(DAE.f, x, u, DAE);
	else
		B = feval(DAE.B, DAE);
		out = feval(DAE.f, x, DAE) + B*u;
	end
end % g(y, args)

function Jout = ACA_dg_dxLambda(y, ArcContAnalObj)
	lambda = y(end,1);
	x = y(1:(end-1),1);

	DAE = ArcContAnalObj.DAE;

	u = feval(DAE.uQSS, DAE);
	if 1 == ArcContAnalObj.InputOrParm
		u(ArcContAnalObj.lambdaIdx) = lambda;
		DAE = feval(DAE.set_uQSS, u, DAE);
	else
		DAE = feval(DAE.setparms, ArcContAnalObj.lambdaName, lambda, DAE);
	end


	if 1 == ArcContAnalObj.DAE.f_takes_inputs
		Jx = feval(DAE.df_dx, x, u, DAE);
		if 1 == ArcContAnalObj.InputOrParm
			Ju = feval(DAE.df_du, x, u, DAE);
			Jout = [Jx, Ju(:, ArcContAnalObj.lambdaIdx)];
		else
			Jlambda = feval(DAE.dfq_dp, x, u, ArcContAnalObj.parmObj, 'f', DAE);
			Jout = [Jx, Jlambda];
		end
	else
		Jx = feval(DAE.df_dx, x, DAE);
		if 1 == ArcContAnalObj.InputOrParm
			B = feval(DAE.B, DAE);
			Jout = [Jx, B(:, ArcContAnalObj.lambdaIdx)];
		else
			Jlambda = feval(DAE.dfq_dp, x, [], ArcContAnalObj.parmObj, 'f', DAE);
			Jout = [Jx, Jlambda];
		end
	end
end % dg_dxLambda

function outObj = ArcContAnalSolve(ArcContAnalObj, initguess, startLambda, stopLambda, initLambdaStep)
	% set up the ArcCont object (do this last)
	if nargin < 3
		startLambda = 0;
	end
	ArcContAnalObj.parms.StartLambda = startLambda;
	if nargin < 4
		stopLambda = 1;
	end
	ArcContAnalObj.parms.StopLambda = stopLambda;
	if nargin < 5
		initLambdaStep = 1e-3;
	end
	%parms.NRparms.maxiter = 100;
	%parms.NRparms.dbglvl = 3;
	ArcContAnalObj.parms.initDeltaLambda = initLambdaStep;

	ArcContObj = ArcCont(@ACA_g, @ACA_dg_dxLambda, ArcContAnalObj, ArcContAnalObj.parms);

	ArcContObj = feval(ArcContObj.solve, ArcContObj, initguess);
	[solution.spts, solution.yvals, solution.finalSol] = feval(ArcContObj.getsolution, ArcContObj);

	ArcContAnalObj.solution = solution;
	outObj = ArcContAnalObj;
end % ArcContAnalSolve

function [figh, onames, colindex] = ACAplotVsArcLen(ACAobj, stateoutputs, lgndprefix, linetype, figh, legends, colindex)
	% begin plothelper
	if ischar(ACAobj.solution);
		error('ACAplot: run solve successfully first');
	end

	DAE = ACAobj.DAE;
	if nargin < 2 || 0 == sum(size(stateoutputs));
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

	if nargin < 3 || 0 == sum(size(lgndprefix))
		lgndprefix = '';
	end

	if nargin < 4 || 0 == sum(size(linetype));
		linetype = '.-';
	end

	if nargin < 5 || 0 == sum(size(figh))
		figh = figure;
	else
		figh = figure(figh);
	end

	if nargin < 6 || 0 == sum(size(legends))
		legends = {};;
	end

	if nargin < 7 || 0 == sum(size(colindex))
		colindex = 0;
	end


	ninputs = feval(DAE.ninputs, DAE);
	lambdas = ACAobj.solution.yvals(end,:); % row of all lambdas in the track
	if ninputs > 0
		us = feval(DAE.uQSS, DAE); % single vector
		if 1 == ACAobj.InputOrParm
			us = us * ones(1,length(ACAobj.solution.spts)); 
			us(ACAobj.lambdaIdx,:) = lambdas;
		end
	end
	hold on;
	% end plothelper

	for i=1:size(C,1)
		c = C(i,:);
		plotvals = c*ACAobj.solution.yvals(1:(end-1),:);
		if ninputs > 0
			d = D(i,:);
			plotvals = plotvals + d*us;
		end
		colindex = colindex+1;
		thiscol = getcolorfromindex(gca,colindex);
		plot(ACAobj.solution.spts, plotvals, linetype, 'color', thiscol);
	end
	% plot lambda(s)
	colindex = colindex+1;
	thiscol = getcolorfromindex(gca,colindex);
	plot(ACAobj.solution.spts, lambdas, linetype, 'color', 'k');

	for i=1:length(onames)
			onames{i} = escape_special_characters(onames{i});
    end

	if (0 == strcmp('', lgndprefix))
		for i=1:length(onames)
			onames{i} = escape_special_characters(sprintf('%s: %s', ...
                                lgndprefix, onames{i}));
		end
	end

	if length(legends) > 0
		onames = {legends{:}, onames{:}};
	end
	onames = {onames{:}, escape_special_characters(sprintf('lambda=%s', ...
                                                ACAobj.lambdaName))};

	legend(onames, 'Location', 'BestOutside');
	xlabel 's (arc length)';
	ylabel 'values';
	grid on; axis tight;
    titlestr = sprintf('%s: arclength continuation track', ...
                            feval(DAE.daename, DAE));
    titlestr = escape_special_characters(titlestr);
	title(titlestr);
end % of function plotVsArcLen


function [figh, newlegends, colindex] = ACAplotVsLambda(ACAobj, ...
                                        stateoutputs, ...
                                        lgndprefix, ...
                                        linetype, ...
                                        figh, legends, colindex, ...
                                        varargin)

	% begin plothelper
	if ischar(ACAobj.solution);
		error('ACAplot: run solve successfully first');
	end

	DAE = ACAobj.DAE;
	if nargin < 2 || isempty(stateoutputs);
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

	if nargin < 3 || isempty(lgndprefix)
		lgndprefix = '';
	end

	if nargin < 4 || isempty(linetype);
		linetype = '.-';
	end

	if nargin < 5 || isempty(figh)
		figh = figure;
	else
		figure(figh); hold on;
	end

	if nargin < 6 || isempty(legends)
		legends = {};
	end

	if nargin < 7 || isempty(colindex)
		colindex = 0;
	end


	ninputs = feval(DAE.ninputs, DAE);
	lambdas = ACAobj.solution.yvals(end,:); % row of all lambdas in the track
	if ninputs > 0
		us = feval(DAE.uQSS, DAE); % single vector
		if 1 == ACAobj.InputOrParm
			us = us * ones(1,length(ACAobj.solution.spts)); 
			us(ACAobj.lambdaIdx,:) = lambdas;
		end
	end

	for i=1:size(C,1)
		c = C(i,:);
		plotvals = c*ACAobj.solution.yvals(1:(end-1),:);
		if ninputs > 0
			d = D(i,:);
			plotvals = plotvals + d*us;
		end
		colindex = colindex+1;
		thiscol = getcolorfromindex(gca,colindex);
		plot(lambdas, plotvals, linetype, 'color', thiscol); hold on;
	end

	for i=1:length(onames)
			onames{i} = escape_special_characters(onames{i});
    end

	if (0 == strcmp('', lgndprefix))
		for i=1:length(onames)
			onames{i} = escape_special_characters(sprintf('%s: %s', ...
                                                    lgndprefix, onames{i}));
		end
	end

	if length(legends) > 0
		newlegends = {legends{:}, onames{:}};
	else
		newlegends = onames;
	end

	legend(newlegends, 'Location', 'BestOutside');
	xlabel(escape_special_characters(sprintf('lambda=%s', ...
                                                ACAobj.lambdaName)));
	ylabel 'values';
	grid on; axis tight;
	title(escape_special_characters(...
            sprintf('%s: arclength continuation: outputs vs %s', ...
			feval(DAE.daename, DAE), ...
			sprintf('lambda=%s', ACAobj.lambdaName))) ...
         );

    hold off;
	% do a 3D plot: only if there are 2 outputs
	if 2 == size(C,1)
		figure;
		plotvals1 = C(1,:)*ACAobj.solution.yvals(1:(end-1),:);
		plotvals2 = C(2,:)*ACAobj.solution.yvals(1:(end-1),:);
		if ninputs > 0
			plotvals1 = plotvals1 + D(1,:)*us;
			plotvals2 = plotvals2 + D(2,:)*us;
		end
		plot3(lambdas, plotvals1, plotvals2, linetype);
		xlabel 'lambda';
		ylabel(onames{1});
		zlabel(onames{2});
		title(escape_special_characters(...
                sprintf('%s: arclength continuation: %s and %s vs %s', ...
                    feval(DAE.daename, DAE), 'lambda', onames{1}, ...
                    onames{2})) ...
             );
		grid on; axis tight;
	end
end % of function ACAplotVsLambda
