function success = check_DAE(DAE)
%function success = check_DAE(DAE)
%
%Runs simple checks on a DAE to verify that its functions evaluate, that the
%sizes of arguments and return values are correct, etc..
%
%help MAPPdaes or help DAEAPI_wrapper for examples of use.
%
%See also
%--------
%
%MAPPdaes, DAEAPI_wrapper, init_DAE, add_to_DAE, finish_DAE, DAEAPI.
%

% 
% Author: Tianshi Wang, 2014-07-19
%
%<TODO> Placeholder --</TODO>
%
%Arguments:
%
%Return values:
%
%Examples
%--------
%TODO
%
%See also
%--------
%TODO
%

% Notes: what to check

% % name, version, descriptions, etc.
%   .version
%   .uniqID
%   .daename

% % parameter access
%   .nparms
%   .parmnames
%   .renameParms %TODO: how to check? Is it used at all?
%   .parmdefaults
%    * length(parmnames) == length(parmdefaults) == nparms
%   .getparms %TODO: how should we check it?
%   .setparms %TODO: how should we check it?

% % variable name, numbers
%   .nunks
%   .neqns
%   .ninputs
%   .noutputs
%   .nNoiseSources
%   .unknames
%    * length(unknames) == nunks
%   .eqnnames
%    * length(eqnnames) == neqns
%   .renameUnks %TODO: how to check? Is it used at all?
%   .renameEqns %TODO: how to check? Is it used at all?
%   .time_units
%   .inputnames
%    * length(inputnames) == ninputs
%   .outputnames
%    * length(outputnames) == noutputs
%   .NoiseSourceNames
%    * length(NoiseSourceNames) == nNoiseSources
%
% % core functions
%   .f_takes_inputss
%   .f
%   .q
%   .df_dx
%   .df_du
%   .dq_dx
%    * check each one's size
%   .B

% % input-related %TODO: how to check?
%   .uQSS
%   .set_uQSS
%   .utransient
%   .set_utransient
%   .uLTISSS
%   .set_uLTISSS
%   .uHB
%   .set_uHB

% % output-related
%   .C
%   .D
%    * check each one's size

% % init/limiting-related
%   .support_initlimiting
%   .limitedvarnames (function handle).
%   .nlimitedvars (function handle).
%   .xTOxlim (function handle).
%   .xTOxlimMatrix (function handle).
%   .NRlimiting (function handle).
%   .NRinitGuess (function handle).
%   calling syntax of core functions:
%       .f
%       .q
%       .df_dx
%       .df_du
%       .dq_dx

% % noise-related %TODO: not checked
%DAE.NoiseStationaryComponentPSDmatrix
%DAE.m
%DAE.dm_dx
%DAE.dm_dn


%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %===========================================================
    % % name, version, descriptions, etc.
    %-----------------------------------------------------------
    % daename
    test.daename = feval(DAE.daename, DAE);
    fprintf(1, 'daename: %s\n', test.daename);
    %-----------------------------------------------------------
    % version
    % test.vs = feval(DAE.version, DAE);
    % TODO: why version is string instead of function handle?
    test.vs = DAE.version;
    fprintf(1, 'DAE version: ''%s''\n', test.vs);
    %-----------------------------------------------------------
    % uniqID
    test.uniqID = feval(DAE.uniqID, DAE);
    fprintf(1, 'description: %s\n', test.uniqID);
    %===========================================================

    %===========================================================
    % % parameter access
    %-----------------------------------------------------------
    % parmnames
    test.parmnames = feval(DAE.parmnames, DAE);
    fprintf(1, 'parmnames: %s\n', cell2str(test.parmnames));
    %-----------------------------------------------------------
    % run parmdefaults
    % TODO: no proper printing routine for parmdefault values that supports ANY
    % type: matrix, string, scalar, function handle, etc.
    test.parmdefaults = feval(DAE.parmdefaults, DAE);
    % fprintf(1, 'parmdefaults: %s\n', cell2str(test.parmdefaults));
    %-----------------------------------------------------------
    % nparms
    test.nparms = feval(DAE.nparms, DAE);
    fprintf(1, 'nparms: %s\n', num2str(test.nparms));
    %-----------------------------------------------------------
    % check nparms matches sizes of parmnames, parmdefaults
    fprintf(1, '* Is nparms = length(parmnames) = length(parmdefaults)?  ');
    if length(test.parmnames) == test.nparms && ...
       length(test.parmnames) == test.nparms       
        fprintf(1, 'Yes\n');
    else
        error('nparms doens''t match parmnames or parmdefaults!');
    end 
    %===========================================================

    %===========================================================
    % % variable name and index functions:
    %-----------------------------------------------------------
    % unknames
    test.unknames = feval(DAE.unknames, DAE);
    fprintf(1, 'unknames: %s\n', cell2str(test.unknames));
    %-----------------------------------------------------------
    % nunks
    test.nunks = feval(DAE.nunks, DAE);
    fprintf(1, 'nunks: %s\n', num2str(test.nunks));
    %-----------------------------------------------------------
    %    * length(unknames) == nunks
    fprintf(1, '* Is length(unknames) == nunks?  ');
    if length(test.unknames) == test.nunks
        fprintf(1, 'Yes\n');
    else
        error('nunks doesn''t match size of unknames!');
    end 
    %-----------------------------------------------------------
    % eqnnames
    test.eqnnames = feval(DAE.eqnnames, DAE);
    fprintf(1, 'eqnnames: %s\n', cell2str(test.eqnnames));
    %-----------------------------------------------------------
    % neqns
    test.neqns = feval(DAE.neqns, DAE);
    fprintf(1, 'neqns: %s\n', num2str(test.neqns));
    %-----------------------------------------------------------
    %    * length(eqnnames) == neqns
    fprintf(1, '* Is length(eqnnames) == neqns?  ');
    if length(test.eqnnames) == test.neqns
        fprintf(1, 'Yes\n');
    else
        error('neqns doesn''t match size of eqnnames!');
    end 
    %-----------------------------------------------------------
    % inputnames
    test.inputnames = feval(DAE.inputnames, DAE);
    fprintf(1, 'inputnames: %s\n', cell2str(test.inputnames));
    %-----------------------------------------------------------
    % ninputs
    test.ninputs = feval(DAE.ninputs, DAE);
    fprintf(1, 'ninputs: %s\n', num2str(test.ninputs));
    %-----------------------------------------------------------
    %    * length(inputnames) == ninputs
    fprintf(1, '* Is length(inputnames) == ninputs?  ');
    if length(test.inputnames) == test.ninputs
        fprintf(1, 'Yes\n');
    else
        error('ninputs doesn''t match size of inputnames!');
    end 
    %-----------------------------------------------------------
    % outputnames
    test.outputnames = feval(DAE.outputnames, DAE);
    fprintf(1, 'outputnames: %s\n', cell2str(test.outputnames));
    %-----------------------------------------------------------
    % noutputs
    test.noutputs = feval(DAE.noutputs, DAE);
    fprintf(1, 'noutputs: %s\n', num2str(test.noutputs));
    %-----------------------------------------------------------
    %    * length(outputnames) == noutputs
    fprintf(1, '* Is length(outputnames) == noutputs?  ');
    if length(test.outputnames) == test.noutputs
        fprintf(1, 'Yes\n');
    else
        error('noutputs doesn''t match size of outputnames!');
    end 
    %-----------------------------------------------------------
    % NoiseSourceNames
    test.NoiseSourceNames = feval(DAE.NoiseSourceNames, DAE);
    fprintf(1, 'NoiseSourceNames: %s\n', cell2str(test.NoiseSourceNames));
    %-----------------------------------------------------------
    % nNoiseSources
    test.nNoiseSources = feval(DAE.nNoiseSources, DAE);
    fprintf(1, 'nNoiseSources: %s\n', num2str(test.nNoiseSources));
    %-----------------------------------------------------------
    %    * length(NoiseSourceNames) == nNoiseSources
    fprintf(1, '* Is length(NoiseSourceNames) == nNoiseSources?  ');
    if length(test.NoiseSourceNames) == test.nNoiseSources
        fprintf(1, 'Yes\n');
    else
        error('nNoiseSources doesn''t match size of NoiseSourceNames!');
    end 
    %-----------------------------------------------------------
    % time_units
    test.time_units = DAE.time_units;
    fprintf(1, 'time_units: %s\n', test.time_units);
    %-----------------------------------------------------------

    %===========================================================
    %
    %  % Core model functions
    %   .f_takes_inputss
    %   .f
    %   .q
    %     * check f/q's size == neqns
    %   .df_dx
    %   .df_du
    %   .dq_dx
    %    * check each one's size
    %   .B
    %===========================================================

	rand('seed',  etime(clock, [1900, 1, 1, 0, 0, 0]));
	x = rand(test.nunks,1);
	u = rand(test.ninputs,1);

    %===========================================================
	% f
	%-----------------------------------------------------------
    % f_takes_inputs
    test.f_takes_inputs = DAE.f_takes_inputs;
    fprintf(1, 'f_takes_inputs: %d\n', test.f_takes_inputs);
	%-----------------------------------------------------------
	if 1 == test.f_takes_inputs

		%-----------------------------------------------------------
		% f(x, u)
		fprintf(1, 'running fx=f(x,u)\n');
		test.fx = feval(DAE.f, x, u, DAE);
		% test.fx
		%-----------------------------------------------------------
		% f's size
		fprintf(1, '* Is f''s size correct?  ');
		if size(test.fx, 1) == test.neqns && ...
		   size(test.fx, 2) <= 1
			fprintf(1, 'Yes\n');
		else
			error('f''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% df_dx(x, u) 
		fprintf(1, 'running dfdx=df_dx(x,u)\n');
		test. dfdx = feval(DAE.df_dx, x, u, DAE);
		% test.dfdx
		%-----------------------------------------------------------
		% df_dx's size
		fprintf(1, '* Is df_dx''s size correct?  ');
		if size(test.dfdx, 1) == test.neqns && ...
		   size(test.dfdx, 2) == test.nunks
			fprintf(1, 'Yes\n');
		else
			error('df_dx''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% df_du(x, u) 
		fprintf(1, 'running dfdu=df_du(x,u)\n');
		test.dfdu = feval(DAE.df_du, x, u, DAE);
		% test.dfdu
		%-----------------------------------------------------------
		% df_du's size
		fprintf(1, '* Is df_du''s size correct?  ');
		if size(test.dfdu, 1) == test.neqns && ...
		   size(test.dfdu, 2) == test.ninputs
			fprintf(1, 'Yes\n');
		else
			error('df_du''s size is not correct!');
		end 

	else % 0 == test.f_takes_inputs

		%-----------------------------------------------------------
		% f(x)
		fprintf(1, 'running fx=f(x)\n');
		test.fx = feval(DAE.f, x, DAE);
		% test.fx
		%-----------------------------------------------------------
		% f's size
		fprintf(1, '* Is f''s size correct?  ');
		if size(test.fx, 1) == test.neqns && ...
		   size(test.fx, 2) <= 1
			fprintf(1, 'Yes\n');
		else
			error('f''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% df_dx(x) 
		fprintf(1, 'running dfdx=df_dx(x)\n');
		test. dfdx = feval(DAE.df_dx, x, DAE);
		% test.dfdx
		%-----------------------------------------------------------
		% df_dx's size
		fprintf(1, '* Is df_dx''s size correct?  ');
		if size(test.dfdx, 1) == test.neqns && ...
		   size(test.dfdx, 2) == test.nunks
			fprintf(1, 'Yes\n');
		else
			error('df_dx''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% B
        fprintf(1, 'B:\n');
		test.B = feval(DAE.B, DAE);
		% test.B
		%-----------------------------------------------------------
		% B's size
		fprintf(1, '* Is B''s size correct?  ');
		if (size(test.B, 1) == test.neqns && ...
		   size(test.B, 2) == test.ninputs) ...
		   || isempty(test.B) % TODO: many existing DAEs use  B = []
			fprintf(1, 'Yes\n');
		else
			error('B''s size is not correct!');
		end 
	end

	%-----------------------------------------------------------
	% q(x)
	fprintf(1, 'running qx=q(x)\n');
	test.qx = feval(DAE.q, x, DAE);
	% test.qx
	%-----------------------------------------------------------
	% q's size
	fprintf(1, '* Is q''s size correct?  ');
	if size(test.qx, 1) == test.neqns && ...
	   size(test.qx, 2) <= 1
		fprintf(1, 'Yes\n');
	else
		error('q''s size is not correct!');
	end 

	%-----------------------------------------------------------
	% dq_dx(x) 
	fprintf(1, 'running dqdx=dq_dx(x)\n');
	test. dqdx = feval(DAE.dq_dx, x, DAE);
	% test.dqdx
	%-----------------------------------------------------------
	% dq_dx's size
	fprintf(1, '* Is dq_dx''s size correct?  ');
	if size(test.dqdx, 1) == test.neqns && ...
	   size(test.dqdx, 2) == test.nunks
		fprintf(1, 'Yes\n');
	else
		error('dq_dx''s size is not correct!');
	end 
    %===========================================================

    %===========================================================
	% % output-related
    %-----------------------------------------------------------
    % C
    fprintf(1, 'C: \n');
    test.C = feval(DAE.C, DAE);
	% test.C
	%-----------------------------------------------------------
	% C's size
	fprintf(1, '* Is C''s size correct?  ');
	if (size(test.C, 1) == test.noutputs && ...
	   size(test.C, 2) == test.nunks) ...
		   || isempty(test.C) % TODO: many existing DAEs use C = []
		fprintf(1, 'Yes\n');
	else
		error('C''s size is not correct!');
	end 
    %-----------------------------------------------------------
    % D
    fprintf(1, 'D: \n');
    test.D = feval(DAE.D, DAE);
	% test.D
    %-----------------------------------------------------------
	% D's size
	fprintf(1, '* Is D''s size correct?  ');
	if (size(test.D, 1) == test.noutputs && ...
	   size(test.D, 2) == test.ninputs) ...
		   || isempty(test.D) % TODO: many existing DAEs use D = []
		fprintf(1, 'Yes\n');
	else
		error('D''s size is not correct!');
	end 
	%===========================================================

	%===========================================================
	% % init/limiting-related
	%-----------------------------------------------------------
	if 1 == DAE.support_initlimiting
		%===========================================================
		% % init/limiting related data members
		%-----------------------------------------------------------
		% limitedvarnames
		test.limitedvarnames = feval(DAE.limitedvarnames, DAE);
		fprintf(1, 'limitedvarnames: %s\n', cell2str(test.limitedvarnames));
		%-----------------------------------------------------------
		% nlimitedvars
		test.nlimitedvars = feval(DAE.nlimitedvars, DAE);
		fprintf(1, 'nlimitedvars: %s\n', num2str(test.nlimitedvars));
		%-----------------------------------------------------------
		%    * length(limitedvarnames) == nlimitedvars
		fprintf(1, '* length(limitedvarnames) == nlimitedvars');
		if length(test.limitedvarnames) == test.nlimitedvars
			fprintf(1, 'Yes\n');
		else
			error('nlimitedvars doesn''t match size of limitedvarnames!');
		end 
		%-----------------------------------------------------------
		% xTOxlimMatrix
		fprintf(1, 'xTOxlimMatrix:');
		test.xTOxlimMatrix = feval(DAE.xTOxlimMatrix, DAE);
        test.xTOxlimMatrix
		%-----------------------------------------------------------
		% test whether xTOxlimMatrix is of correct size
		fprintf(1, '* Is xTOxlimMatrix''s size correct?  ');
		if size(test.xTOxlimMatrix, 1) == test.nlimitedvars && ...
		   size(test.xTOxlimMatrix, 2) == test.nunks
			fprintf(1, 'Yes\n');
		else
			error('xTOxlimMatrix''s size is not correct!');
		end 
		%===========================================================

		%===========================================================
		% % init/limiting related function members
		%-----------------------------------------------------------
		% run xTOxlim(x) 
		fprintf(1, 'running xlim=xTOxlim(x)\n');
		test.xlim = feval(DAE.xTOxlim, x, DAE);
		%-----------------------------------------------------------
		% xlim's size
		fprintf(1, '* Is xTOxlim''s size correct?  ');
		if size(test.xlim, 1) == test.nlimitedvars && ...
		   size(test.xlim, 2) <= 1
			fprintf(1, 'Yes\n');
		else
			error('xTOxlim''s size is not correct!');
		end 
		%-----------------------------------------------------------
		% run NRinitGuess(vecU) 
		fprintf(1, 'running xlimInit=NRinitGuess(u)\n');
		test.xlimInit = feval(DAE.NRinitGuess, u, DAE);
		%-----------------------------------------------------------
		% xlimInit's size
		fprintf(1, '* Is NRinitGuess''s size correct?  ');
		if size(test.xlimInit, 1) == test.nlimitedvars && ...
		   size(test.xlimInit, 2) <= 1
			fprintf(1, 'Yes\n');
		else
			error('NRinitGuess''s size is not correct!');
		end 
		%-----------------------------------------------------------
	    xlimOld = rand(test.nlimitedvars,1);
		%-----------------------------------------------------------
		% run NRlimiting(x, xlimOld, u) 
		fprintf(1, 'running xlimNew=limiting(x,xlimOld,u)\n');
		test.xlimNew = feval(DAE.NRlimiting, x, xlimOld, u, DAE);
		%-----------------------------------------------------------
		% xlimNew's size
		fprintf(1, '* Is NRlimiting''s size correct?  ');
		if size(test.xlimNew, 1) == test.nlimitedvars && ...
		   size(test.xlimNew, 2) <= 1
			fprintf(1, 'Yes\n');
		else
			error('NRlimiting''s size is not correct!');
		end 
		%-----------------------------------------------------------
		% dNRlimiting_dx(x, xlimOld, u) 
		fprintf(1, 'running dqdx=dNRlimiting_dx(x,xlimOld,u)\n');
		test.dNRlimiting_dx = feval(DAE.dNRlimiting_dx, x, xlimOld, u, DAE);
		% test.dNRlimiting_dx
		%-----------------------------------------------------------
		% dNRlimiting_dx's size
		fprintf(1, '* Is dNRlimiting_dx''s size correct?  ');
		if size(test.dNRlimiting_dx, 1) == test.nlimitedvars && ...
		   size(test.dNRlimiting_dx, 2) == test.nunks
			fprintf(1, 'Yes\n');
		else
			error('dNRlimiting_dx''s size is not correct!');
		end 
		%===========================================================

	    xlim = rand(test.nlimitedvars,1);

		%===========================================================
		%  % Core model functions with new calling syntax (with xlim)
		%   .f_takes_inputss
		%   .f
		%   .q
		%     * check f/q's size == neqns
		%   .df_dx
		%   .df_du
		%   .dq_dx
		%    * check each one's size
		%   .B
		%===========================================================

		%===========================================================
		% f
		%-----------------------------------------------------------
		if 1 == test.f_takes_inputs

			%-----------------------------------------------------------
			% f(x, xlim, u)
			fprintf(1, 'running fx=f(x,xlim,u)\n');
			test.fx = feval(DAE.f, x, xlim, u, DAE);
			% test.fx
			%-----------------------------------------------------------
			% f's size
			fprintf(1, '* Is f''s size correct?  ');
			if size(test.fx, 1) == test.neqns && ...
			   size(test.fx, 2) <= 1
				fprintf(1, 'Yes\n');
			else
				error('f''s size is not correct!');
			end 

			%-----------------------------------------------------------
			% df_dx(x, xlim, u) 
			fprintf(1, 'running dfdx=df_dx(x,xlim,u)\n');
			test. dfdx = feval(DAE.df_dx, x, xlim, u, DAE);
			% test.dfdx
			%-----------------------------------------------------------
			% df_dx's size
			fprintf(1, '* Is df_dx''s size correct?  ');
			if size(test.dfdx, 1) == test.neqns && ...
			   size(test.dfdx, 2) == test.nunks
				fprintf(1, 'Yes\n');
			else
				error('df_dx''s size is not correct!');
			end 

			%-----------------------------------------------------------
			% df_du(x, xlim, u) 
			fprintf(1, 'running dfdu=df_du(x,xlim,u)\n');
			test.dfdu = feval(DAE.df_du, x, xlim, u, DAE);
			% test.dfdu
			%-----------------------------------------------------------
			% df_du's size
			fprintf(1, '* Is df_du''s size correct?  ');
			if size(test.dfdu, 1) == test.neqns && ...
			   size(test.dfdu, 2) == test.ninputs
				fprintf(1, 'Yes\n');
			else
				error('df_du''s size is not correct!');
			end 

			%-----------------------------------------------------------
			% df_dxlim(x, xlim, u) 
			fprintf(1, 'running dfdxlim=df_dxlim(x,xlim,u)\n');
			test.dfdxlim = feval(DAE.df_dxlim, x, xlim, u, DAE);
			% test.dfdxlim
			%-----------------------------------------------------------
			% df_dxlim's size
			fprintf(1, '* Is df_dxlim''s size correct?  ');
			if size(test.dfdxlim, 1) == test.neqns && ...
			   size(test.dfdxlim, 2) == test.nlimitedvars
				fprintf(1, 'Yes\n');
			else
				error('df_dxlim''s size is not correct!');
			end 

		else % 0 == test.f_takes_inputs

			%-----------------------------------------------------------
			% f(x, xlim)
			fprintf(1, 'running fx=f(x,xlim)\n');
			test.fx = feval(DAE.f, x, xlim, DAE);
			% test.fx
			%-----------------------------------------------------------
			% f's size
			fprintf(1, '* Is f''s size correct?  ');
			if size(test.fx, 1) == test.neqns && ...
			   size(test.fx, 2) <= 1
				fprintf(1, 'Yes\n');
			else
				error('f''s size is not correct!');
			end 

			%-----------------------------------------------------------
			% df_dx(x,xlim) 
			fprintf(1, 'running dfdx=df_dx(x,xlim)\n');
			test. dfdx = feval(DAE.df_dx, x, xlim, DAE);
			% test.dfdx
			%-----------------------------------------------------------
			% df_dx's size
			fprintf(1, '* Is df_dx''s size correct?  ');
			if size(test.dfdx, 1) == test.neqns && ...
			   size(test.dfdx, 2) == test.nunks
				fprintf(1, 'Yes\n');
			else
				error('df_dx''s size is not correct!');
			end 

			%-----------------------------------------------------------
			% df_dxlim(x, xlim) 
			fprintf(1, 'running dfdxlim=df_dxlim(x,xlim)\n');
			test.dfdxlim = feval(DAE.df_dxlim, x, xlim, DAE);
			% test.dfdxlim
			%-----------------------------------------------------------
			% df_dxlim's size
			fprintf(1, '* Is df_dxlim''s size correct?  ');
			if size(test.dfdxlim, 1) == test.neqns && ...
			   size(test.dfdxlim, 2) == test.nlimitedvars
				fprintf(1, 'Yes\n');
			else
				error('df_dxlim''s size is not correct!');
			end 

		end % f_takes_inputs

		%-----------------------------------------------------------
		% q(x, xlim)
		fprintf(1, 'running qx=q(x,xlim)\n');
		test.qx = feval(DAE.q, x, xlim, DAE);
		% test.qx
		%-----------------------------------------------------------
		% q's size
		fprintf(1, '* Is q''s size correct?  ');
		if size(test.qx, 1) == test.neqns && ...
		   size(test.qx, 2) <= 1
			fprintf(1, 'Yes\n');
		else
			error('q''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% dq_dx(x,xlim) 
		fprintf(1, 'running dqdx=dq_dx(x,xlim)\n');
		test. dqdx = feval(DAE.dq_dx, x, xlim, DAE);
		% test.dqdx
		%-----------------------------------------------------------
		% dq_dx's size
		fprintf(1, '* Is dq_dx''s size correct?  ');
		if size(test.dqdx, 1) == test.neqns && ...
		   size(test.dqdx, 2) == test.nunks
			fprintf(1, 'Yes\n');
		else
			error('dq_dx''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% dq_dxlim(x, xlim) 
		fprintf(1, 'running dqdxlim=dq_dxlim(x,xlim)\n');
		test.dqdxlim = feval(DAE.dq_dxlim, x, xlim, DAE);
		% test.dqdxlim
		%-----------------------------------------------------------
		% dq_dxlim's size
		fprintf(1, '* Is dq_dxlim''s size correct?  ');
		if size(test.dqdxlim, 1) == test.neqns && ...
		   size(test.dqdxlim, 2) == test.nlimitedvars
			fprintf(1, 'Yes\n');
		else
			error('dq_dxlim''s size is not correct!');
		end 
		%===========================================================
	end % support_initlimiting flag

    %===========================================================
    %
    %  % Core model functions
    %   .f_takes_inputss
    % 
    %   .fq(x, u, flag, DAE) with full flag
    %   .fqJ(x, u, flag, DAE) with full flag
    % 
    %   .fq(x, xlim, u, flag, DAE) with full flag
    %   .fqJ(x, xlim, u, flag, DAE) with full flag
    %===========================================================

    %===========================================================
	% fq
	%-----------------------------------------------------------
	flag.f = 1; flag.q = 1; 
	if 1 == test.f_takes_inputs
		fprintf(1, 'running [fq_f, fq_q] = fq(x, u, flag)\n');
		[fq_f, fq_q] = feval(DAE.fq, x, u, flag, DAE);
	else % 0 == test.f_takes_inputs
		fprintf(1, 'running [fq_f, fq_q] = fq(x, flag)\n');
		[fq_f, fq_q] = feval(DAE.fq, x, flag, DAE);
	end

	%-----------------------------------------------------------
	% fq_f's size
	fprintf(1, '* Is fq_f''s size correct?  ');
	if size(fq_f, 1) == test.neqns && ...
	   size(fq_f, 2) <= 1
		fprintf(1, 'Yes\n');
	else
		error('fq_f''s size is not correct!');
	end 

	%-----------------------------------------------------------
	% fq_q's size
	fprintf(1, '* Is fq_q''s size correct?  ');
	if size(fq_q, 1) == test.neqns && ...
	   size(fq_q, 2) <= 1
		fprintf(1, 'Yes\n');
	else
		error('fq_q''s size is not correct!');
	end 
    %===========================================================

    %===========================================================
	% fqJ
	%-----------------------------------------------------------
	flag.f = 1; flag.q = 1; flag.dfdx = 1; flag.dqdx = 1; 
	if 1 == test.f_takes_inputs
		flag.dfdu = 1;
		fprintf(1, 'running fqJ = fqJ(x, u, flag)\n');
		fqJout = feval(DAE.fqJ, x, u, flag, DAE);
	else % 0 == test.f_takes_inputs
		fprintf(1, 'running fqJ = fqJ(x, flag)\n');
		fqJout = feval(DAE.fqJ, x, flag, DAE);
	end

	%-----------------------------------------------------------
	% fqJ_f's size
	fqJ_f = fqJout.f;
	fprintf(1, '* Is fqJ_f''s size correct?  ');
	if size(fqJ_f, 1) == test.neqns && ...
	   size(fqJ_f, 2) <= 1
		fprintf(1, 'Yes\n');
	else
		error('fqJ_f''s size is not correct!');
	end 

	%-----------------------------------------------------------
	% fqJ_dfdx's size
	fqJ_dfdx = fqJout.dfdx;
	fprintf(1, '* Is fqJ_dfdx''s size correct?  ');
	if size(fqJ_dfdx, 1) == test.neqns && ...
	   size(fqJ_dfdx, 2) == test.nunks
		fprintf(1, 'Yes\n');
	else
		error('fqJ_dfdx''s size is not correct!');
	end 

	if 1 == test.f_takes_inputs
		%-----------------------------------------------------------
		% fqJ_dfdu's size
		fqJ_dfdu = fqJout.dfdu;
		fprintf(1, '* Is fqJ_dfdu''s size correct?  ');
		if size(fqJ_dfdu, 1) == test.neqns && ...
		   size(fqJ_dfdu, 2) == test.ninputs
			fprintf(1, 'Yes\n');
		else
			error('fqJ_dfdu''s size is not correct!');
		end 
	end

	%-----------------------------------------------------------
	% fqJ_q's size
	fqJ_q = fqJout.q;
	fprintf(1, '* Is fqJ_q''s size correct?  ');
	if size(fqJ_q, 1) == test.neqns && ...
	   size(fqJ_q, 2) <= 1
		fprintf(1, 'Yes\n');
	else
		error('fqJ_q''s size is not correct!');
	end 

	%-----------------------------------------------------------
	% fqJ_dqdx's size
	fqJ_dqdx = fqJout.dqdx;
	fprintf(1, '* Is fqJ_dqdx''s size correct?  ');
	if size(fqJ_dqdx, 1) == test.neqns && ...
	   size(fqJ_dqdx, 2) == test.nunks
		fprintf(1, 'Yes\n');
	else
		error('fqJ_dqdx''s size is not correct!');
	end 

	if 1 == DAE.support_initlimiting
		%===========================================================
		% fq
		%-----------------------------------------------------------
		flag.f = 1; flag.q = 1; 
		if 1 == test.f_takes_inputs
			fprintf(1, 'running [fq_f, fq_q] = fq(x, xlim, u, flag)\n');
			[fq_f, fq_q] = feval(DAE.fq, x, xlim, u, flag, DAE);
		else % 0 == test.f_takes_inputs
			fprintf(1, 'running [fq_f, fq_q] = fq(x, xlim, flag)\n');
			[fq_f, fq_q] = feval(DAE.fq, x, xlim, flag, DAE);
		end

		%-----------------------------------------------------------
		% fq_f's size
		fprintf(1, '* Is fq_f''s size correct?  ');
		if size(fq_f, 1) == test.neqns && ...
		   size(fq_f, 2) <= 1
			fprintf(1, 'Yes\n');
		else
			error('fq_f''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% fq_q's size
		fprintf(1, '* Is fq_q''s size correct?  ');
		if size(fq_q, 1) == test.neqns && ...
		   size(fq_q, 2) <= 1
			fprintf(1, 'Yes\n');
		else
			error('fq_q''s size is not correct!');
		end 
		%===========================================================

		%===========================================================
		% fqJ
		%-----------------------------------------------------------
		flag.f = 1; flag.q = 1; flag.dfdx = 1; flag.dqdx = 1; 
		flag.dfdxlim = 1; flag.dqdxlim = 1; 
		if 1 == test.f_takes_inputs
			flag.dfdu = 1;
			fprintf(1, 'running fqJ = fqJ(x, xlim, u, flag)\n');
			fqJout = feval(DAE.fqJ, x, xlim, u, flag, DAE);
		else % 0 == test.f_takes_inputs
			fprintf(1, 'running fqJ = fqJ(x, xlim, flag)\n');
			fqJout = feval(DAE.fqJ, x, xlim, flag, DAE);
		end

		%-----------------------------------------------------------
		% fqJ_f's size
		fqJ_f = fqJout.f;
		fprintf(1, '* Is fqJ_f''s size correct?  ');
		if size(fqJ_f, 1) == test.neqns && ...
		   size(fqJ_f, 2) <= 1
			fprintf(1, 'Yes\n');
		else
			error('fqJ_f''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% fqJ_dfdx's size
		fqJ_dfdx = fqJout.dfdx;
		fprintf(1, '* Is fqJ_dfdx''s size correct?  ');
		if size(fqJ_dfdx, 1) == test.neqns && ...
		   size(fqJ_dfdx, 2) == test.nunks
			fprintf(1, 'Yes\n');
		else
			error('fqJ_dfdx''s size is not correct!');
		end 

		if 1 == test.f_takes_inputs
			%-----------------------------------------------------------
			% fqJ_dfdu's size
			fqJ_dfdu = fqJout.dfdu;
			fprintf(1, '* Is fqJ_dfdu''s size correct?  ');
			if size(fqJ_dfdu, 1) == test.neqns && ...
			   size(fqJ_dfdu, 2) == test.ninputs
				fprintf(1, 'Yes\n');
			else
				error('fqJ_dfdu''s size is not correct!');
			end 
		end

		%-----------------------------------------------------------
		% fqJ_dfdxlim's size
		fqJ_dfdxlim = fqJout.dfdxlim;
		fprintf(1, '* Is fqJ_dfdxlim''s size correct?  ');
		if size(fqJ_dfdxlim, 1) == test.neqns && ...
		   size(fqJ_dfdxlim, 2) == test.nlimitedvars
			fprintf(1, 'Yes\n');
		else
			error('fqJ_dfdxlim''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% fqJ_q's size
		fqJ_q = fqJout.q;
		fprintf(1, '* Is fqJ_q''s size correct?  ');
		if size(fqJ_q, 1) == test.neqns && ...
		   size(fqJ_q, 2) <= 1
			fprintf(1, 'Yes\n');
		else
			error('fqJ_q''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% fqJ_dqdx's size
		fqJ_dqdx = fqJout.dqdx;
		fprintf(1, '* Is fqJ_dqdx''s size correct?  ');
		if size(fqJ_dqdx, 1) == test.neqns && ...
		   size(fqJ_dqdx, 2) == test.nunks
			fprintf(1, 'Yes\n');
		else
			error('fqJ_dqdx''s size is not correct!');
		end 

		%-----------------------------------------------------------
		% fqJ_dqdxlim's size
		fqJ_dqdxlim = fqJout.dqdxlim;
		fprintf(1, '* Is fqJ_dqdxlim''s size correct?  ');
		if size(fqJ_dqdxlim, 1) == test.neqns && ...
		   size(fqJ_dqdxlim, 2) == test.nlimitedvars
			fprintf(1, 'Yes\n');
		else
			error('fqJ_dqdxlim''s size is not correct!');
		end 
	end % support_initlimiting

	fprintf(1, '\n check_DAE terminated successfully.\n');
end % check_DAE
