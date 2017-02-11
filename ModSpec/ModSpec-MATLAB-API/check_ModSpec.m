function success = check_ModSpec(MOD, verbose)
%function success = check_ModSpec(MOD, verbose)
%
% This function runs all ModSpec API functions and prints out their results.
% It also does basic sanity check on the input ModSpec object, such as
% checking the return values' sizes.
% If check_ModSpec terminates successfully, it normally indicates the input
% is a valid ModSpec object that is consistent with ModSpecAPI.
% If not, the error it returns is usually useful in debugging the input
% ModSpec.
%
%Arguments:
% - MOD: ModSpec object.
%        Run help ModSpecAPI to see valid data and function fields of a ModSpec
%        object.
%
% - verbose: a flag that controls the printouts.
%            0 --> print only pass or errors.
%            1 --> print the name of each function the script is checking.
%            If not given, verbose is by default 0.
%
%Return values:
% - success: 1 if check_ModSpec terminates successfully.
%
%Examples
%--------
% MOD = resModSpec;
% check_ModSpec(MOD);
%
%See also
%--------
% ModSpecAPI, ModSpec_common_skeleton
%

% Author: Tianshi Wang, 2014-06-18

% Notes: what to check
% % ModelName, name, etc.
%    .ModelName
%    .name
%
% % parameter access
%    .parmnames
%    .parmdefaults
%    .nparms
%     * check nparms matches sizes of parmnames, parmdefaults
%
% % variable name and index functions:
%    .IOnames
%    .ExplicitOutputNames
%    .OtherIONames
%     * check IOnames is ExplicitOutputNames plus OtherIONames
%    .InternalUnkNames
%    .ImplicitEquationNames
%    .uNames
%
%  % Core model functions
%    .fe
%    .qe
%     * check fe/qe's size = size of ExplicitOutputNames
%    .fi
%    .qi
%     * check fi/qi's size = size of ImplicitEquationNames
%    .fqei
%     * a quick check that fqei returns same values as fe/qe/fi/qi
%
%  % Output support
%    .OutputNames
%    .OutputMatrix
%     * check OutputMatrix's size = (size of OutputNames) by
%       (size of ExplicitOutputNames + ImplicitEquationNames)
%
%  % init/limiting support
%    check the following if 1 == .support_initlimiting
%
%    .LimitedVarNames
%    .vecXYtoLimitedVarsMatrix
%    .vecXYtoLimitedVars
%    .initGuess
%    .limiting
%
%    .fe
%    .qe
%     * check fe/qe's size = size of ExplicitOutputNames
%    .fi
%    .qi
%     * check fi/qi's size = size of ImplicitEquationNames
%    .fqei
%     * a quick check that fqei returns same values as fe/qe/fi/qi


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin < 2
        verbose = 0;
    end

    %===========================================================
    % % ModelName, name, etc.
    %-----------------------------------------------------------
    % ModelName
    test.mnm = feval(MOD.ModelName, MOD);
    print_if_verbose(verbose, 1, 'ModelName: %s\n', test.mnm);
    %-----------------------------------------------------------
    % name
    test.nm = feval(MOD.name, MOD);
    print_if_verbose(verbose, 1, 'element name (id): ''%s''\n', test.nm);
    %===========================================================

    %===========================================================
    % % parameter access
    %-----------------------------------------------------------
    % parmnames
    test.parmnames = feval(MOD.parmnames, MOD);
    print_if_verbose(verbose, 1, 'parmnames: %s\n', cell2str(test.parmnames));
    %-----------------------------------------------------------
    % run parmdefaults
    % TODO: no proper printing routine for parmdefault values that supports ANY
    % type: matrix, string, scalar, function handle, etc.
    test.parmdefaults = feval(MOD.parmdefaults, MOD);
    % print_if_verbose(verbose, 1, 'parmdefaults: %s\n', cell2str(test.parmdefaults));
    %-----------------------------------------------------------
    % nparms
    test.nparms = feval(MOD.nparms, MOD);
    print_if_verbose(verbose, 1, 'nparms: %d\n', test.nparms);
    %-----------------------------------------------------------
    % check nparms matches sizes of parmnames, parmdefaults
    print_if_verbose(verbose, 1, '* nparms = length(parmnames) = length(parmdefaults)?  ');
    if length(test.parmnames) == test.nparms && ...
       length(test.parmnames) == test.nparms       
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('nparms doesn''t match parmnames or parmdefaults!');
    end 
    %===========================================================

    %===========================================================
    % % variable name and index functions:
    %-----------------------------------------------------------
    % IOnames
    test.ionames = feval(MOD.IOnames, MOD);
    print_if_verbose(verbose, 1, 'IOnames: %s\n', cell2str(test.ionames));
    %-----------------------------------------------------------
    % ExplicitOutputNames
    test.eons = feval(MOD.ExplicitOutputNames, MOD);
    print_if_verbose(verbose, 1, 'ExplicitOutputNames: %s\n', cell2str(test.eons));
    %-----------------------------------------------------------
    % OtherIONames
    test.oions = feval(MOD.OtherIONames, MOD);
    print_if_verbose(verbose, 1, 'OtherIONames: %s\n', cell2str(test.oions));
    %-----------------------------------------------------------
    % TODO: check IOnames is ExplicitOutputNames plus OtherIONames
    %-----------------------------------------------------------
    % InternalUnkNames
    test.iuns = feval(MOD.InternalUnkNames, MOD);
    print_if_verbose(verbose, 1, 'InternalUnkNames: %s\n', cell2str(test.iuns));
    %-----------------------------------------------------------
    % ImplicitEquationNames
    test.iens = feval(MOD.ImplicitEquationNames, MOD);
    print_if_verbose(verbose, 1, 'ImplicitEquationNames: %s\n', cell2str(test.iens));
    %-----------------------------------------------------------
    % uNames
    test.unames = feval(MOD.uNames, MOD);
    print_if_verbose(verbose, 1, 'uNames: %s\n', cell2str(test.unames));
    %-----------------------------------------------------------

    %===========================================================
    %
    %  % Core model functions
    %    .fe
    %    .qe
    %     * check fe/qe's size = size of ExplicitOutputNames
    %    .fi
    %    .qi
    %     * check fi/qi's size = size of ImplicitEquationNames
    %    .fqei
    %     * a quick check that fqei returns same values as fe/qe/fi/qi
    %
    %===========================================================

    rand('seed',  etime(clock, [1900, 1, 1, 0, 0, 0]));
    vecX = rand(length(test.oions),1);
    vecY = rand(length(test.iuns),1);
    vecU = rand(length(test.unames),1);

    %===========================================================
    % fe
    %-----------------------------------------------------------
    % fe(vecX, vecY, vecU)
    print_if_verbose(verbose, 1, 'running vecZf=fe(vecX,vecY,vecU)\n');
    test.vecZf = feval(MOD.fe, vecX, vecY, vecU, MOD);
    % test.vecZf
    %-----------------------------------------------------------
    % fe's size
    print_if_verbose(verbose, 1, '* Is fe''s size correct?  ');
    if size(test.vecZf, 1) == length(test.eons) && ...
       size(test.vecZf, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fe''s size is not correct!: it is %d, should be %d', size(test.vecZf, 1), length(test.eons));
    end 

    %-----------------------------------------------------------
    % dfe_dvecX(vecX, vecY, vecU) 
    print_if_verbose(verbose, 1, 'running dvecZf_dvecX=dfe_dvecX(vecX,vecY,vecU)\n');
    test.dvecZf_dvecX = feval(MOD.dfe_dvecX, vecX, vecY, vecU, MOD);
    % test.dvecZf_dvecX
    %-----------------------------------------------------------
    % dfe_dvecX's size
    print_if_verbose(verbose, 1, '* Is dfe_dvecX''s size correct?  ');
    if size(test.dvecZf_dvecX, 1) == length(test.eons) && ...
       size(test.dvecZf_dvecX, 2) == length(test.oions)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('dfe_dvecX''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % dfe_dvecY(vecX, vecY, vecU) 
    print_if_verbose(verbose, 1, 'running dvecZf_dvecY=dfe_dvecY(vecX,vecY,vecU)\n');
    test.dvecZf_dvecY = feval(MOD.dfe_dvecY, vecX, vecY, vecU, MOD);
    % test.dvecZf_dvecY
    %-----------------------------------------------------------
    % dfe_dvecY's size
    print_if_verbose(verbose, 1, '* Is dfe_dvecY''s size correct?  ');
    if size(test.dvecZf_dvecY, 1) == length(test.eons) && ...
       size(test.dvecZf_dvecY, 2) == length(test.iuns)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('dfe_dvecY''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % dfe_dvecU(vecX, vecY, vecU) 
    print_if_verbose(verbose, 1, 'running dvecZf_dvecU=dfe_dvecU(vecX,vecY,vecU)\n');
    test.dvecZf_dvecU = feval(MOD.dfe_dvecU, vecX, vecY, vecU, MOD);
    % test.dvecZf_dvecU
    %-----------------------------------------------------------
    % dfe_dvecU's size
    print_if_verbose(verbose, 1, '* Is dfe_dvecU''s size correct?  ');
    if size(test.dvecZf_dvecU, 1) == length(test.eons) && ...
       size(test.dvecZf_dvecU, 2) == length(test.unames)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('dfe_dvecU''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % qe(vecX, vecY)
    print_if_verbose(verbose, 1, 'running vecZq=qe(vecX,vecY)\n');
    test.vecZq = feval(MOD.qe, vecX, vecY, MOD);
    % test.vecZq
    %-----------------------------------------------------------
    % qe's size
    print_if_verbose(verbose, 1, '* Is qe''s size correct?  ');
    if size(test.vecZq, 1) == length(test.eons) && ...
       size(test.vecZq, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('qe''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % dqe_dvecX(vecX, vecY) 
    print_if_verbose(verbose, 1, 'running dvecZq_dvecX=dqe_dvecX(vecX,vecY)\n');
    test.dvecZq_dvecX = feval(MOD.dqe_dvecX, vecX, vecY, MOD);
    % test.dvecZq_dvecX
    %-----------------------------------------------------------
    % dqe_dvecX's size
    print_if_verbose(verbose, 1, '* Is dqe_dvecX''s size correct?  ');
    if size(test.dvecZq_dvecX, 1) == length(test.eons) && ...
       size(test.dvecZq_dvecX, 2) == length(test.oions)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('dqe_dvecX''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % dqe_dvecY(vecX, vecY) 
    print_if_verbose(verbose, 1, 'running dvecZq_dvecY=dqe_dvecY(vecX,vecY)\n');
    test.dvecZq_dvecY = feval(MOD.dqe_dvecY, vecX, vecY, MOD);
    % test.dvecZq_dvecY
    %-----------------------------------------------------------
    % dqe_dvecY's size
    print_if_verbose(verbose, 1, '* Is dqe_dvecY''s size correct?  ');
    if size(test.dvecZq_dvecY, 1) == length(test.eons) && ...
       size(test.dvecZq_dvecY, 2) == length(test.iuns)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('dqe_dvecY''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fi(vecX, vecY, vecU)
    print_if_verbose(verbose, 1, 'running vecWf=fi(vecX,vecY,vecU)\n');
    test.vecWf = feval(MOD.fi, vecX, vecY, vecU, MOD);
    % test.vecWf
    %-----------------------------------------------------------
    % fi's size
    print_if_verbose(verbose, 1, '* Is fi''s size correct?  ');
    if size(test.vecWf, 1) == length(test.iens) && ...
       size(test.vecWf, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fi''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % dfi_dvecX(vecX, vecY, vecU) 
    print_if_verbose(verbose, 1, 'running dvecWf_dvecX=dfi_dvecX(vecX,vecY,vecU)\n');
    test.dvecWf_dvecX = feval(MOD.dfi_dvecX, vecX, vecY, vecU, MOD);
    % test.dvecWf_dvecX
    %-----------------------------------------------------------
    % dfi_dvecX's size
    print_if_verbose(verbose, 1, '* Is dfi_dvecX''s size correct?  ');
    if size(test.dvecWf_dvecX, 1) == length(test.iens) && ...
       size(test.dvecWf_dvecX, 2) == length(test.oions)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('dfi_dvecX''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % dfi_dvecY(vecX, vecY, vecU) 
    print_if_verbose(verbose, 1, 'running dvecWf_dvecY=dfi_dvecY(vecX,vecY,vecU)\n');
    test.dvecWf_dvecY = feval(MOD.dfi_dvecY, vecX, vecY, vecU, MOD);
    % test.dvecWf_dvecY
    %-----------------------------------------------------------
    % dfi_dvecY's size
    print_if_verbose(verbose, 1, '* Is dfi_dvecY''s size correct?  ');
    if size(test.dvecWf_dvecY, 1) == length(test.iens) && ...
       size(test.dvecWf_dvecY, 2) == length(test.iuns)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('dfi_dvecY''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % dfi_dvecU(vecX, vecY, vecU) 
    print_if_verbose(verbose, 1, 'running dvecWf_dvecU=dfi_dvecU(vecX,vecY,vecU)\n');
    test.dvecWf_dvecU = feval(MOD.dfi_dvecU, vecX, vecY, vecU, MOD);
    % test.dvecWf_dvecU
    %-----------------------------------------------------------
    % dfi_dvecU's size
    print_if_verbose(verbose, 1, '* Is dfi_dvecU''s size correct?  ');
    if size(test.dvecWf_dvecU, 1) == length(test.iens) && ...
       size(test.dvecWf_dvecU, 2) == length(test.unames)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('dfi_dvecU''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % qi(vecX, vecY)
    print_if_verbose(verbose, 1, 'running vecWq=qi(vecX,vecY)\n');
    test.vecWq = feval(MOD.qi, vecX, vecY, MOD);
    % test.vecWq
    %-----------------------------------------------------------
    % qi's size
    print_if_verbose(verbose, 1, '* Is qi''s size correct?  ');
    if size(test.vecWq, 1) == length(test.iens) && ...
       size(test.vecWq, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('qi''s size is not correct!: it is %dx%d, should be %dx1', size(test.vecWq, 1), size(test.vecWq, 2), length(test.iens));
    end 

    %-----------------------------------------------------------
    % run dqi_dvecX(vecX, vecY) 
    print_if_verbose(verbose, 1, 'running dvecWq_dvecX=dqi_dvecX(vecX,vecY)\n');
    test.dvecWq_dvecX = feval(MOD.dqi_dvecX, vecX, vecY, MOD);
    % test.dvecWq_dvecX
    %-----------------------------------------------------------
    % dqi_dvecX's size
    print_if_verbose(verbose, 1, '* Is dqi_dvecX''s size correct?  ');
    if size(test.dvecWq_dvecX, 1) == length(test.iens) && ...
       size(test.dvecWq_dvecX, 2) == length(test.oions)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('dqi_dvecX''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % run dqi_dvecY(vecX, vecY) 
    print_if_verbose(verbose, 1, 'running dvecWq_dvecY=dqi_dvecY(vecX,vecY)\n');
    test.dvecWq_dvecY = feval(MOD.dqi_dvecY, vecX, vecY, MOD);
    % test.dvecWq_dvecY
    %-----------------------------------------------------------
    % dqi_dvecY's size
    print_if_verbose(verbose, 1, '* Is dqi_dvecY''s size correct?  ');
    if size(test.dvecWq_dvecY, 1) == length(test.iens) && ...
       size(test.dvecWq_dvecY, 2) == length(test.iuns)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('dqi_dvecY''s size is not correct!');
    end 

	%===========================================================
	% % Output related fields
	%-----------------------------------------------------------
	% OutputNames
	test.ons = feval(MOD.OutputNames, MOD);
	print_if_verbose(verbose, 1, 'OutputNames: %s\n', cell2str(test.ons));
	%-----------------------------------------------------------
	% OutputMatrix
	test.omat = feval(MOD.OutputMatrix, MOD);
	print_if_verbose(verbose, 1, 'OutputMatrix:');
	if verbose
		test.omat
    end
	%-----------------------------------------------------------
	% test whether OutputMatrix is of correct size
	print_if_verbose(verbose, 1, '* Is OutputMatrix ''s size correct?  ');
	if size(test.omat, 1) == length(test.ons) && ...
	   size(test.omat, 2) == length(test.eons) + length(test.iens)
		print_if_verbose(verbose, 1, 'Yes\n');
	else
		error('OutputMatrix ''s size is not correct!');
	end 
	%===========================================================


    if 1 == MOD.support_initlimiting
        %===========================================================
        % % init/limiting related data members
        %-----------------------------------------------------------
        % LimitedVarNames
        test.lvns = feval(MOD.LimitedVarNames, MOD);
        print_if_verbose(verbose, 1, 'LimitedVarNames: %s\n', cell2str(test.lvns));
        %-----------------------------------------------------------
        % vecXYtoLimitedVarsMatrix
        test.lvmat = feval(MOD.vecXYtoLimitedVarsMatrix, MOD);
        print_if_verbose(verbose, 1, 'vecXYtoLimitedVarsMatrix:');
        if verbose
			test.lvmat
        end
        %-----------------------------------------------------------
        % test whether vecXYtoLimitedVarsMatrix is of correct size
        print_if_verbose(verbose, 1, '* Is vecXYtoLimitedVarsMatrix''s size correct?  ');
        if size(test.lvmat, 1) == length(test.lvns) && ...
           size(test.lvmat, 2) == length(test.oions) + length(test.iuns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('vecXYtoLimitedVarsMatrix''s size is not correct!');
        end 
        %===========================================================

        %===========================================================
        % % init/limiting related function members
        %-----------------------------------------------------------
        % run vecXYtoLimitedVars(vecX, vecY) 
        print_if_verbose(verbose, 1, 'running vecLim=vecXYtoLimitedVars(vecX,vecY)\n');
        test.vecLim = feval(MOD.vecXYtoLimitedVars, vecX, vecY, MOD);
        %-----------------------------------------------------------
        % vecLim's size
        print_if_verbose(verbose, 1, '* Is vecXYtoLimitedVars''s size correct?  ');
        if size(test.vecLim, 1) == length(test.lvns) && ...
           size(test.vecLim, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('vecXYtoLimitedVars''s size is not correct!');
        end 
        %-----------------------------------------------------------
        % run initGuess(vecU) 
        print_if_verbose(verbose, 1, 'running vecLimInit=initGuess(vecU)\n');
        test.vecLimInit = feval(MOD.initGuess, vecU, MOD);
        %-----------------------------------------------------------
        % vecLimInit's size
        print_if_verbose(verbose, 1, '* Is initGuess''s size correct?  ');
        if size(test.vecLimInit, 1) == length(test.lvns) && ...
           size(test.vecLimInit, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('initGuess''s size is not correct!');
        end 
        %-----------------------------------------------------------
        vecLimOld = rand(length(test.lvns),1);
        %-----------------------------------------------------------
        % run limiting(vecX, vecY, vecLimOld, vecU) 
        print_if_verbose(verbose, 1, 'running vecLimNew=limiting(vecX,vecY,vecLimOld,vecU)\n');
        test.vecLimNew = feval(MOD.limiting, vecX, vecY, vecLimOld, vecU, MOD);
        %-----------------------------------------------------------
        % vecLimNew's size
        print_if_verbose(verbose, 1, '* Is limiting''s size correct?  ');
        if size(test.vecLimNew, 1) == length(test.lvns) && ...
           size(test.vecLimNew, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('limiting''s size is not correct!');
        end 
        %-----------------------------------------------------------
        % dlimiting_dvecX(vecX, vecY, vecLimOld, vecU) 
        print_if_verbose(verbose, 1, 'running  dlimiting_dvecX=dlimiting_dvecX(vecX,vecY,vecLimOld,vecU)\n');
        test.dlimiting_dvecX = feval(MOD.dlimiting_dvecX, vecX, vecY, vecLimOld, vecU, MOD);
        %-----------------------------------------------------------
        % dlimiting_dvecX's size
        print_if_verbose(verbose, 1, '* Is dlimiting_dvecX''s size correct?  ');
        if size(test.dlimiting_dvecX, 1) == length(test.lvns) && ...
           size(test.dlimiting_dvecX, 2) == length(test.oions)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dlimiting_dvecX''s size is not correct!');
        end 
        %-----------------------------------------------------------
        % dlimiting_dvecY(vecX, vecY, vecLimOld, vecU) 
        print_if_verbose(verbose, 1, 'running dlimiting_dvecY=dlimiting_dvecY(vecX,vecY,vecLimOld,vecU)\n');
        test.dlimiting_dvecY = feval(MOD.dlimiting_dvecY, vecX, vecY, vecLimOld, vecU, MOD);
        %-----------------------------------------------------------
        % dlimiting_dvecY's size
        print_if_verbose(verbose, 1, '* Is dlimiting_dvecY''s size correct?  ');
        if size(test.dlimiting_dvecY, 1) == length(test.lvns) && ...
           size(test.dlimiting_dvecY, 2) == length(test.iuns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dlimiting_dvecY''s size is not correct!');
        end 
        %===========================================================

        vecLim = rand(length(test.lvns),1);

        %===========================================================
        % fe
        %-----------------------------------------------------------
        % fe(vecX, vecY, vecLim, vecU)
        print_if_verbose(verbose, 1, 'running vecZf=fe(vecX,vecY,vecLim,vecU)\n');
        test.vecZf = feval(MOD.fe, vecX, vecY, vecLim, vecU, MOD);
        %TODO: test.vecZf is overwritten, seems fine...
        % test.vecZf
        %-----------------------------------------------------------
        % fe's size
        print_if_verbose(verbose, 1, '* Is fe''s size correct?  ');
        if size(test.vecZf, 1) == length(test.eons) && ...
           size(test.vecZf, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fe''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dfe_dvecX(vecX, vecY, vecLim, vecU) 
        print_if_verbose(verbose, 1, 'running dvecZf_dvecX=dfe_dvecX(vecX,vecY,vecLim,vecU)\n');
        test.dvecZf_dvecX = feval(MOD.dfe_dvecX, vecX, vecY, vecLim, vecU, MOD);
        % test.dvecZf_dvecX
        %-----------------------------------------------------------
        % dfe_dvecX's size
        print_if_verbose(verbose, 1, '* Is dfe_dvecX''s size correct?  ');
        if size(test.dvecZf_dvecX, 1) == length(test.eons) && ...
           size(test.dvecZf_dvecX, 2) == length(test.oions)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dfe_dvecX''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dfe_dvecY(vecX, vecY, vecLim, vecU) 
        print_if_verbose(verbose, 1, 'running dvecZf_dvecY=dfe_dvecY(vecX,vecY,vecLim,vecU)\n');
        test.dvecZf_dvecY = feval(MOD.dfe_dvecY, vecX, vecY, vecLim, vecU, MOD);
        % test.dvecZf_dvecY
        %-----------------------------------------------------------
        % dfe_dvecY's size
        print_if_verbose(verbose, 1, '* Is dfe_dvecY''s size correct?  ');
        if size(test.dvecZf_dvecY, 1) == length(test.eons) && ...
           size(test.dvecZf_dvecY, 2) == length(test.iuns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dfe_dvecY''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dfe_dvecU(vecX, vecY, vecLim, vecU) 
        print_if_verbose(verbose, 1, 'running dvecZf_dvecU=dfe_dvecU(vecX,vecY,vecLim,vecU)\n');
        test.dvecZf_dvecU = feval(MOD.dfe_dvecU, vecX, vecY, vecLim, vecU, MOD);
        % test.dvecZf_dvecU
        %-----------------------------------------------------------
        % dfe_dvecU's size
        print_if_verbose(verbose, 1, '* Is dfe_dvecU''s size correct?  ');
        if size(test.dvecZf_dvecU, 1) == length(test.eons) && ...
           size(test.dvecZf_dvecU, 2) == length(test.unames)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dfe_dvecU''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dfe_dvecLim(vecX, vecY, vecLim, vecU) 
        print_if_verbose(verbose, 1, 'running dvecZf_dvecLim=dfe_dvecU(vecX,vecY,vecLim,vecU)\n');
        test.dvecZf_dvecLim = feval(MOD.dfe_dvecLim, vecX, vecY, vecLim, vecU, MOD);
        % test.dvecZf_dvecLim
        %-----------------------------------------------------------
        % dfe_dvecLim's size
        print_if_verbose(verbose, 1, '* Is dfe_dvecLim''s size correct?  ');
        if size(test.dvecZf_dvecLim, 1) == length(test.eons) && ...
           size(test.dvecZf_dvecLim, 2) == length(test.lvns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dfe_dvecLim''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % qe(vecX, vecY, vecLim)
        print_if_verbose(verbose, 1, 'running vecZq=qe(vecX,vecY,vecLim)\n');
        test.vecZq = feval(MOD.qe, vecX, vecY, vecLim, MOD);
        % test.vecZq
        %-----------------------------------------------------------
        % qe's size
        print_if_verbose(verbose, 1, '* Is qe''s size correct?  ');
        if size(test.vecZq, 1) == length(test.eons) && ...
           size(test.vecZq, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('qe''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dqe_dvecX(vecX, vecY, vecLim) 
        print_if_verbose(verbose, 1, 'running dvecZq_dvecX=dqe_dvecX(vecX,vecY,vecLim)\n');
        test.dvecZq_dvecX = feval(MOD.dqe_dvecX, vecX, vecY, vecLim, MOD);
        % test.dvecZq_dvecX
        %-----------------------------------------------------------
        % dqe_dvecX's size
        print_if_verbose(verbose, 1, '* Is dqe_dvecX''s size correct?  ');
        if size(test.dvecZq_dvecX, 1) == length(test.eons) && ...
           size(test.dvecZq_dvecX, 2) == length(test.oions)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dqe_dvecX''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dqe_dvecY(vecX, vecY, vecLim) 
        print_if_verbose(verbose, 1, 'running dvecZq_dvecY=dqe_dvecY(vecX,vecY,vecLim)\n');
        test.dvecZq_dvecY = feval(MOD.dqe_dvecY, vecX, vecY, vecLim, MOD);
        % test.dvecZq_dvecY
        %-----------------------------------------------------------
        % dqe_dvecY's size
        print_if_verbose(verbose, 1, '* Is dqe_dvecY''s size correct?  ');
        if size(test.dvecZq_dvecY, 1) == length(test.eons) && ...
           size(test.dvecZq_dvecY, 2) == length(test.iuns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dqe_dvecY''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dqe_dvecLim(vecX, vecY, vecLim) 
        print_if_verbose(verbose, 1, 'running dvecZq_dvecLim=dqe_dvecLim(vecX,vecY,vecLim)\n');
        test.dvecZq_dvecLim = feval(MOD.dqe_dvecLim, vecX, vecY, vecLim, MOD);
        % test.dvecZq_dvecLim
        %-----------------------------------------------------------
        % dqe_dvecLim's size
        print_if_verbose(verbose, 1, '* Is dqe_dvecLim''s size correct?  ');
        if size(test.dvecZq_dvecLim, 1) == length(test.eons) && ...
           size(test.dvecZq_dvecLim, 2) == length(test.lvns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dqe_dvecLim''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fi(vecX, vecY, vecLim, vecU)
        print_if_verbose(verbose, 1, 'running vecWf=fi(vecX,vecY,vecLim,vecU)\n');
        test.vecWf = feval(MOD.fi, vecX, vecY, vecLim, vecU, MOD);
        % test.vecWf
        %-----------------------------------------------------------
        % fi's size
        print_if_verbose(verbose, 1, '* Is fi''s size correct?  ');
        if size(test.vecWf, 1) == length(test.iens) && ...
           size(test.vecWf, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fi''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dfi_dvecX(vecX, vecY, vecLim, vecU) 
        print_if_verbose(verbose, 1, 'running dvecWf_dvecX=dfi_dvecX(vecX,vecY,vecLim,vecU)\n');
        test.dvecWf_dvecX = feval(MOD.dfi_dvecX, vecX, vecY, vecLim, vecU, MOD);
        % test.dvecWf_dvecX
        %-----------------------------------------------------------
        % dfi_dvecX's size
        print_if_verbose(verbose, 1, '* Is dfi_dvecX''s size correct?  ');
        if size(test.dvecWf_dvecX, 1) == length(test.iens) && ...
           size(test.dvecWf_dvecX, 2) == length(test.oions)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dfi_dvecX''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dfi_dvecY(vecX, vecY, vecLim, vecU) 
        print_if_verbose(verbose, 1, 'running dvecWf_dvecY=dfi_dvecY(vecX,vecY,vecLim,vecU)\n');
        test.dvecWf_dvecY = feval(MOD.dfi_dvecY, vecX, vecY, vecLim, vecU, MOD);
        % test.dvecWf_dvecY
        %-----------------------------------------------------------
        % dfi_dvecY's size
        print_if_verbose(verbose, 1, '* Is dfi_dvecY''s size correct?  ');
        if size(test.dvecWf_dvecY, 1) == length(test.iens) && ...
           size(test.dvecWf_dvecY, 2) == length(test.iuns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dfi_dvecY''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dfi_dvecU(vecX, vecY, vecLim, vecU) 
        print_if_verbose(verbose, 1, 'running dvecWf_dvecU=dfi_dvecU(vecX,vecY,vecLim,vecU)\n');
        test.dvecWf_dvecU = feval(MOD.dfi_dvecU, vecX, vecY, vecLim, vecU, MOD);
        % test.dvecWf_dvecU
        %-----------------------------------------------------------
        % dfi_dvecU's size
        print_if_verbose(verbose, 1, '* Is dfi_dvecU''s size correct?  ');
        if size(test.dvecWf_dvecU, 1) == length(test.iens) && ...
           size(test.dvecWf_dvecU, 2) == length(test.unames)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dfi_dvecU''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % dfi_dvecLim(vecX, vecY, vecLim, vecU) 
        print_if_verbose(verbose, 1, 'running dvecWf_dvecLim=dfi_dvecLim(vecX,vecY,vecLim,vecU)\n');
        test.dvecWf_dvecLim = feval(MOD.dfi_dvecLim, vecX, vecY, vecLim, vecU, MOD);
        % test.dvecWf_dvecLim
        %-----------------------------------------------------------
        % dfi_dvecLim's size
        print_if_verbose(verbose, 1, '* Is dfi_dvecLim''s size correct?  ');
        if size(test.dvecWf_dvecLim, 1) == length(test.iens) && ...
           size(test.dvecWf_dvecLim, 2) == length(test.lvns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dfi_dvecLim''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % qi(vecX, vecY, vecLim)
        print_if_verbose(verbose, 1, 'running vecWq=qi(vecX,vecY,vecLim)\n');
        test.vecWq = feval(MOD.qi, vecX, vecY, vecLim, MOD);
        % test.vecWq
        %-----------------------------------------------------------
        % qi's size
        print_if_verbose(verbose, 1, '* Is qi''s size correct?  ');
        if size(test.vecWq, 1) == length(test.iens) && ...
           size(test.vecWq, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('qi''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % run dqi_dvecX(vecX, vecY, vecLim) 
        print_if_verbose(verbose, 1, 'running dvecWq_dvecX=dqi_dvecX(vecX,vecY,vecLim)\n');
        test.dvecWq_dvecX = feval(MOD.dqi_dvecX, vecX, vecY, vecLim, MOD);
        % test.dvecWq_dvecX
        %-----------------------------------------------------------
        % dqi_dvecX's size
        print_if_verbose(verbose, 1, '* Is dqi_dvecX''s size correct?  ');
        if size(test.dvecWq_dvecX, 1) == length(test.iens) && ...
           size(test.dvecWq_dvecX, 2) == length(test.oions)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dqi_dvecX''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % run dqi_dvecY(vecX, vecY, vecLim) 
        print_if_verbose(verbose, 1, 'running dvecWq_dvecY=dqi_dvecY(vecX,vecY,vecLim)\n');
        test.dvecWq_dvecY = feval(MOD.dqi_dvecY, vecX, vecY, vecLim, MOD);
        % test.dvecWq_dvecY
        %-----------------------------------------------------------
        % dqi_dvecY's size
        print_if_verbose(verbose, 1, '* Is dqi_dvecY''s size correct?  ');
        if size(test.dvecWq_dvecY, 1) == length(test.iens) && ...
           size(test.dvecWq_dvecY, 2) == length(test.iuns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dqi_dvecY''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % run dqi_dvecLim(vecX, vecY, vecLim) 
        print_if_verbose(verbose, 1, 'running dvecWq_dvecLim=dqi_dvecLim(vecX,vecY,vecLim)\n');
        test.dvecWq_dvecLim = feval(MOD.dqi_dvecLim, vecX, vecY, vecLim, MOD);
        % test.dvecWq_dvecLim
        %-----------------------------------------------------------
        % dqi_dvecLim's size
        print_if_verbose(verbose, 1, '* Is dqi_dvecLim''s size correct?  ');
        if size(test.dvecWq_dvecLim, 1) == length(test.iens) && ...
           size(test.dvecWq_dvecLim, 2) == length(test.lvns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('dqi_dvecLim''s size is not correct!');
        end 
    end % support_initlimiting flag

    %===========================================================
    %
    %  % redo all the checks on model functions with fqei and fqeiJ 
    %    .fqei with full flags
    %    .fqei with separate flag [TODO]
    %    .fqeiJ with full flags
    %    .fqeiJ with separate flag [TODO]
    %
    %    .fqei with full flags with vecLim
    %    .fqei with separate flag with vecLim [TODO]
    %    .fqeiJ with full flags with vecLim
    %    .fqeiJ with separate flag with vecLim [TODO]
    %===========================================================

    %-----------------------------------------------------------
    % run fqei(vecX, vecY, vecU, flag) 
    %-----------------------------------------------------------

    %===========================================================
    % fqei with full flag
    % fqei(vecX, vecY, vecU, flag)
    print_if_verbose(verbose, 1, 'running [fqei_fe,fqei_qe,fqei_fi,fqei_qi]=fqei(vecX,vecY,vecU)\n');
    flag.fe = 1; flag.qe = 1; flag.fi = 1; flag.qi = 1;
    [fqei_fe, fqei_qe, fqei_fi, fqei_qi] = feval(MOD.fqei, vecX, vecY, vecU, flag, MOD);
    %-----------------------------------------------------------
    % fqei_fe's size
    print_if_verbose(verbose, 1, '* Is fqei_fe''s size correct?  ');
    if size(fqei_fe, 1) == length(test.eons) && ...
       size(fqei_fe, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqei_fe''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqei_qe's size
    print_if_verbose(verbose, 1, '* Is fqei_qe''s size correct?  ');
    if size(fqei_qe, 1) == length(test.eons) && ...
       size(fqei_qe, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqei_qe''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqei_fi's size
    print_if_verbose(verbose, 1, '* Is fqei_fi''s size correct?  ');
    if size(fqei_fi, 1) == length(test.iens) && ...
       size(fqei_fi, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqei_fi''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqei_qi's size
    print_if_verbose(verbose, 1, '* Is fqei_qi''s size correct?  ');
    if size(fqei_qi, 1) == length(test.iens) && ...
       size(fqei_qi, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqei_qi''s size is not correct!');
    end 
    %===========================================================

    %-----------------------------------------------------------
    % run fqei_J(vecX, vecY, vecU, flag) 
    %-----------------------------------------------------------

    %===========================================================
    % fqeiJ with full flag
    % fqeiJ(vecX, vecY, vecU, flag)
    print_if_verbose(verbose, 1, 'running [fqeiJ_fqei,fqeiJ_J]=fqeiJ(vecX,vecY,vecU)\n');
    flag.fe = 1; flag.qe = 1; flag.fi = 1; flag.qi = 1; flag.J = 1;
    [fqeiJ_fqei, fqeiJ_J] = feval(MOD.fqeiJ, vecX, vecY, vecU, flag, MOD);
    %-----------------------------------------------------------
    % fqeiJ_fqei_fe's size
    fqeiJ_fqei_fe = fqeiJ_fqei.fe;
    print_if_verbose(verbose, 1, '* Is fqeiJ_fqei_fe''s size correct?  ');
    if size(fqeiJ_fqei_fe, 1) == length(test.eons) && ...
       size(fqeiJ_fqei_fe, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_fqei_fe''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_J_dfe_dvecX's size
    fqeiJ_J_dfe_dvecX = fqeiJ_J.Jfe.dfe_dvecX;
    print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfe_dvecX''s size correct?  ');
    if size(fqeiJ_J_dfe_dvecX, 1) == length(test.eons) && ...
       size(fqeiJ_J_dfe_dvecX, 2) == length(test.oions)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_J_dfe_dvecX''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_J_dfe_dvecY's size
    fqeiJ_J_dfe_dvecY = fqeiJ_J.Jfe.dfe_dvecY;
    print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfe_dvecY''s size correct?  ');
    if size(fqeiJ_J_dfe_dvecY, 1) == length(test.eons) && ...
       size(fqeiJ_J_dfe_dvecY, 2) == length(test.iuns)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_J_dfe_dvecY''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_J_dfe_dvecU's size
    fqeiJ_J_dfe_dvecU = fqeiJ_J.Jfe.dfe_dvecU;
    print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfe_dvecU''s size correct?  ');
    if size(fqeiJ_J_dfe_dvecU, 1) == length(test.eons) && ...
       size(fqeiJ_J_dfe_dvecU, 2) == length(test.unames)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_J_dfe_dvecU''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_fqei_qe's size
    fqeiJ_fqei_qe = fqeiJ_fqei.qe;
    print_if_verbose(verbose, 1, '* Is fqeiJ_fqei_qe''s size correct?  ');
    if size(fqeiJ_fqei_qe, 1) == length(test.eons) && ...
       size(fqeiJ_fqei_qe, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_fqei_qe''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_J_dqe_dvecX's size
    fqeiJ_J_dqe_dvecX = fqeiJ_J.Jqe.dqe_dvecX;
    print_if_verbose(verbose, 1, '* Is fqeiJ_J_dqe_dvecX''s size correct?  ');
    if size(fqeiJ_J_dqe_dvecX, 1) == length(test.eons) && ...
       size(fqeiJ_J_dqe_dvecX, 2) == length(test.oions)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_J_dqe_dvecX''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_J_dqe_dvecY's size
    fqeiJ_J_dqe_dvecY = fqeiJ_J.Jqe.dqe_dvecY;
    print_if_verbose(verbose, 1, '* Is fqeiJ_J_dqe_dvecY''s size correct?  ');
    if size(fqeiJ_J_dqe_dvecY, 1) == length(test.eons) && ...
       size(fqeiJ_J_dqe_dvecY, 2) == length(test.iuns)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_J_dqe_dvecY''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_fqei_fi's size
    fqeiJ_fqei_fi = fqeiJ_fqei.fi;
    print_if_verbose(verbose, 1, '* Is fqeiJ_fqei_fi''s size correct?  ');
    if size(fqeiJ_fqei_fi, 1) == length(test.iens) && ...
       size(fqeiJ_fqei_fi, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_fqei_fi''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_J_dfi_dvecX's size
    fqeiJ_J_dfi_dvecX = fqeiJ_J.Jfi.dfi_dvecX;
    print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfi_dvecX''s size correct?  ');
    if size(fqeiJ_J_dfi_dvecX, 1) == length(test.iens) && ...
       size(fqeiJ_J_dfi_dvecX, 2) == length(test.oions)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_J_dfi_dvecX''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_J_dfi_dvecY's size
    fqeiJ_J_dfi_dvecY = fqeiJ_J.Jfi.dfi_dvecY;
    print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfi_dvecY''s size correct?  ');
    if size(fqeiJ_J_dfi_dvecY, 1) == length(test.iens) && ...
       size(fqeiJ_J_dfi_dvecY, 2) == length(test.iuns)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_J_dfi_dvecY''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_J_dfi_dvecU's size
    fqeiJ_J_dfi_dvecU = fqeiJ_J.Jfi.dfi_dvecU;
    print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfi_dvecU''s size correct?  ');
    if size(fqeiJ_J_dfi_dvecU, 1) == length(test.iens) && ...
       size(fqeiJ_J_dfi_dvecU, 2) == length(test.unames)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_J_dfi_dvecU''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_fqei_qi's size
    fqeiJ_fqei_qi = fqeiJ_fqei.qi;
    print_if_verbose(verbose, 1, '* Is fqeiJ_fqei_qi''s size correct?  ');
    if size(fqeiJ_fqei_qi, 1) == length(test.iens) && ...
       size(fqeiJ_fqei_qi, 2) <= 1
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_fqei_qi''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_J_dqe_dvecX's size
    fqeiJ_J_dqi_dvecX = fqeiJ_J.Jqi.dqi_dvecX;
    print_if_verbose(verbose, 1, '* Is fqeiJ_J_dqi_dvecX''s size correct?  ');
    if size(fqeiJ_J_dqi_dvecX, 1) == length(test.iens) && ...
       size(fqeiJ_J_dqi_dvecX, 2) == length(test.oions)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_J_dqi_dvecX''s size is not correct!');
    end 

    %-----------------------------------------------------------
    % fqeiJ_J_dqi_dvecY's size
    fqeiJ_J_dqi_dvecY = fqeiJ_J.Jqi.dqi_dvecY;
    print_if_verbose(verbose, 1, '* Is fqeiJ_J_dqi_dvecY''s size correct?  ');
    if size(fqeiJ_J_dqi_dvecY, 1) == length(test.iens) && ...
       size(fqeiJ_J_dqi_dvecY, 2) == length(test.iuns)
        print_if_verbose(verbose, 1, 'Yes\n');
    else
        error('fqeiJ_J_dqi_dvecY''s size is not correct!');
    end 
    %===========================================================

    if 1 == MOD.support_initlimiting
        %-----------------------------------------------------------
        % run fqei(vecX, vecY, vecLim, vecU, flag) 
        %-----------------------------------------------------------

        %===========================================================
        % fqei with full flag
        % fqei(vecX, vecY, vecU, flag)
        print_if_verbose(verbose, 1, 'running [fqei_fe,fqei_qe,fqei_fi,fqei_qi]=fqei(vecX,vecY,vecLim,vecU)\n');
        flag.fe = 1; flag.qe = 1; flag.fi = 1; flag.qi = 1;
        [fqei_fe, fqei_qe, fqei_fi, fqei_qi] = feval(MOD.fqei, vecX, vecY, vecLim, vecU, flag, MOD);
        %-----------------------------------------------------------
        % fqei_fe's size
        print_if_verbose(verbose, 1, '* Is fqei_fe''s size correct?  ');
        if size(fqei_fe, 1) == length(test.eons) && ...
           size(fqei_fe, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqei_fe''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqei_qe's size
        print_if_verbose(verbose, 1, '* Is fqei_qe''s size correct?  ');
        if size(fqei_qe, 1) == length(test.eons) && ...
           size(fqei_qe, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqei_qe''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqei_fi's size
        print_if_verbose(verbose, 1, '* Is fqei_fi''s size correct?  ');
        if size(fqei_fi, 1) == length(test.iens) && ...
           size(fqei_fi, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqei_fi''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqei_qi's size
        print_if_verbose(verbose, 1, '* Is fqei_qi''s size correct?  ');
        if size(fqei_qi, 1) == length(test.iens) && ...
           size(fqei_qi, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqei_qi''s size is not correct!');
        end 
        %===========================================================

        %-----------------------------------------------------------
        % run fqei_J(vecX, vecY, vecLim, vecU, flag) 
        %-----------------------------------------------------------

        %===========================================================
        % fqeiJ with full flag
        % fqeiJ(vecX, vecY, vecLim, vecU, flag)
        print_if_verbose(verbose, 1, 'running [fqeiJ_fqei,fqeiJ_J]=fqeiJ(vecX,vecY,vecLim,vecU)\n');
        flag.fe = 1; flag.qe = 1; flag.fi = 1; flag.qi = 1; flag.J = 1;
        [fqeiJ_fqei, fqeiJ_J] = feval(MOD.fqeiJ, vecX, vecY, vecLim, vecU, flag, MOD);
        %-----------------------------------------------------------
        % fqeiJ_fqei_fe's size
        fqeiJ_fqei_fe = fqeiJ_fqei.fe;
        print_if_verbose(verbose, 1, '* Is fqeiJ_fqei_fe''s size correct?  ');
        if size(fqeiJ_fqei_fe, 1) == length(test.eons) && ...
           size(fqeiJ_fqei_fe, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_fqei_fe''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dfe_dvecX's size
        fqeiJ_J_dfe_dvecX = fqeiJ_J.Jfe.dfe_dvecX;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfe_dvecX''s size correct?  ');
        if size(fqeiJ_J_dfe_dvecX, 1) == length(test.eons) && ...
           size(fqeiJ_J_dfe_dvecX, 2) == length(test.oions)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dfe_dvecX''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dfe_dvecY's size
        fqeiJ_J_dfe_dvecY = fqeiJ_J.Jfe.dfe_dvecY;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfe_dvecY''s size correct?  ');
        if size(fqeiJ_J_dfe_dvecY, 1) == length(test.eons) && ...
           size(fqeiJ_J_dfe_dvecY, 2) == length(test.iuns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dfe_dvecY''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dfe_dvecLim's size
        fqeiJ_J_dfe_dvecLim = fqeiJ_J.Jfe.dfe_dvecLim;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfe_dvecLim''s size correct?  ');
        if size(fqeiJ_J_dfe_dvecLim, 1) == length(test.eons) && ...
           size(fqeiJ_J_dfe_dvecLim, 2) == length(test.lvns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dfe_dvecLim''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dfe_dvecU's size
        fqeiJ_J_dfe_dvecU = fqeiJ_J.Jfe.dfe_dvecU;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfe_dvecU''s size correct?  ');
        if size(fqeiJ_J_dfe_dvecU, 1) == length(test.eons) && ...
           size(fqeiJ_J_dfe_dvecU, 2) == length(test.unames)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dfe_dvecU''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_fqei_qe's size
        fqeiJ_fqei_qe = fqeiJ_fqei.qe;
        print_if_verbose(verbose, 1, '* Is fqeiJ_fqei_qe''s size correct?  ');
        if size(fqeiJ_fqei_qe, 1) == length(test.eons) && ...
           size(fqeiJ_fqei_qe, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_fqei_qe''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dqe_dvecX's size
        fqeiJ_J_dqe_dvecX = fqeiJ_J.Jqe.dqe_dvecX;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dqe_dvecX''s size correct?  ');
        if size(fqeiJ_J_dqe_dvecX, 1) == length(test.eons) && ...
           size(fqeiJ_J_dqe_dvecX, 2) == length(test.oions)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dqe_dvecX''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dqe_dvecY's size
        fqeiJ_J_dqe_dvecY = fqeiJ_J.Jqe.dqe_dvecY;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dqe_dvecY''s size correct?  ');
        if size(fqeiJ_J_dqe_dvecY, 1) == length(test.eons) && ...
           size(fqeiJ_J_dqe_dvecY, 2) == length(test.iuns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dqe_dvecY''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dqe_dvecLim's size
        fqeiJ_J_dqe_dvecLim = fqeiJ_J.Jqe.dqe_dvecLim;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dqe_dvecLim''s size correct?  ');
        if size(fqeiJ_J_dqe_dvecLim, 1) == length(test.eons) && ...
           size(fqeiJ_J_dqe_dvecLim, 2) == length(test.lvns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dqe_dvecLim''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_fqei_fi's size
        fqeiJ_fqei_fi = fqeiJ_fqei.fi;
        print_if_verbose(verbose, 1, '* Is fqeiJ_fqei_fi''s size correct?  ');
        if size(fqeiJ_fqei_fi, 1) == length(test.iens) && ...
           size(fqeiJ_fqei_fi, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_fqei_fi''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dfi_dvecX's size
        fqeiJ_J_dfi_dvecX = fqeiJ_J.Jfi.dfi_dvecX;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfi_dvecX''s size correct?  ');
        if size(fqeiJ_J_dfi_dvecX, 1) == length(test.iens) && ...
           size(fqeiJ_J_dfi_dvecX, 2) == length(test.oions)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dfi_dvecX''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dfi_dvecY's size
        fqeiJ_J_dfi_dvecY = fqeiJ_J.Jfi.dfi_dvecY;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfi_dvecY''s size correct?  ');
        if size(fqeiJ_J_dfi_dvecY, 1) == length(test.iens) && ...
           size(fqeiJ_J_dfi_dvecY, 2) == length(test.iuns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dfi_dvecY''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dfi_dvecLim's size
        fqeiJ_J_dfi_dvecLim = fqeiJ_J.Jfi.dfi_dvecLim;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfi_dvecLim''s size correct?  ');
        if size(fqeiJ_J_dfi_dvecLim, 1) == length(test.iens) && ...
           size(fqeiJ_J_dfi_dvecLim, 2) == length(test.lvns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dfi_dvecLim''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dfi_dvecU's size
        fqeiJ_J_dfi_dvecU = fqeiJ_J.Jfi.dfi_dvecU;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dfi_dvecU''s size correct?  ');
        if size(fqeiJ_J_dfi_dvecU, 1) == length(test.iens) && ...
           size(fqeiJ_J_dfi_dvecU, 2) == length(test.unames)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dfi_dvecU''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_fqei_qi's size
        fqeiJ_fqei_qi = fqeiJ_fqei.qi;
        print_if_verbose(verbose, 1, '* Is fqeiJ_fqei_qi''s size correct?  ');
        if size(fqeiJ_fqei_qi, 1) == length(test.iens) && ...
           size(fqeiJ_fqei_qi, 2) <= 1
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_fqei_qi''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dqe_dvecX's size
        fqeiJ_J_dqi_dvecX = fqeiJ_J.Jqi.dqi_dvecX;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dqi_dvecX''s size correct?  ');
        if size(fqeiJ_J_dqi_dvecX, 1) == length(test.iens) && ...
           size(fqeiJ_J_dqi_dvecX, 2) == length(test.oions)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dqi_dvecX''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dqi_dvecY's size
        fqeiJ_J_dqi_dvecY = fqeiJ_J.Jqi.dqi_dvecY;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dqi_dvecY''s size correct?  ');
        if size(fqeiJ_J_dqi_dvecY, 1) == length(test.iens) && ...
           size(fqeiJ_J_dqi_dvecY, 2) == length(test.iuns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dqi_dvecY''s size is not correct!');
        end 

        %-----------------------------------------------------------
        % fqeiJ_J_dqi_dvecLim's size
        fqeiJ_J_dqi_dvecLim = fqeiJ_J.Jqi.dqi_dvecLim;
        print_if_verbose(verbose, 1, '* Is fqeiJ_J_dqi_dvecLim''s size correct?  ');
        if size(fqeiJ_J_dqi_dvecLim, 1) == length(test.iens) && ...
           size(fqeiJ_J_dqi_dvecLim, 2) == length(test.lvns)
            print_if_verbose(verbose, 1, 'Yes\n');
        else
            error('fqeiJ_J_dqi_dvecLim''s size is not correct!');
        end 
        %===========================================================
    end % 1 == MOD.support_initlimiting

	print_if_verbose(verbose, 1, '\n');
    fprintf(1, 'check_ModSpec terminated successfully.\n');
end % check_ModSpec

function print_if_verbose(varargin)
    verbose = varargin{1};
    if verbose
        fprintf(varargin{2:end});
    end
end % print_if_verbose
