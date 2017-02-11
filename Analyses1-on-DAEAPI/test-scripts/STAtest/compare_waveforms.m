function [passOrFail, comparisonInfo] =  ...
        compare_waveforms(waveform1,waveform2,parms)
%Compares two waveforms using abstol and reltol;
%  
%Input arguments:
%  waveform1           - The first waveform (2D matrix)
%                        The first row contains the numerical values for the
%                        independent variable of the waveform (e.g., time,
%                        frequency) and the second row contains the numerical
%                        values for the amplitude of the waveform. The values
%                        for the independent variable in the first row is
%                        assumed to be unique in the sense that no values are
%                        repeated twice or more.
%
%  waveform2           - The second waveform (2D matrix)
%                        The first row contains the numerical values for the
%                        independent variable of the waveform (e.g., time,
%                        frequency) and the second row contains the numerical
%                        values for the amplitude of the waveform. The values
%                        for the independent variable in the first row is
%                        assumed to be unique in the sense that no values are
%                        repeated twice or more.
%
%  parms (optional)   - A variable containing the following fields related to
%                       the interpolation/extrapolation-based comparison
%                       between waveform1 and waveform2. (All the following
%                       fields are optional.)
%
%      .interpMethod      = Type of interpolation/extrapolation. 
%                           Currently supported interpolation/extrapolation
%                           methods are:
%                           'linear'   - Linear interpolation (DEFAULT)
%                           'nearest'  - Nearest neighborhood interpolation
%                           'spline'   - Cubic spline interpolation
%                           'cubic'    - Piecewise cubic Hermite interpolation
%
%      .resampleAt        = An array containing the values for the independent
%                           variable at which waveform1 and waveform2 are
%                           resampled after interpolation/extrapolation. By
%                           DEFAULT, this is the union of the independent
%                           variables of waveform1 and waveform2, i.e.,
%                           waveform1(1,:) U waveform2(1,:). 
%
%      .beginResampleAt   = A scalar value at which the resampling of waveform1
%                           and waveform2 starts. By DEFAULT, this is the
%                           smallest element of resampleAt, i.e.,
%                           beginResampleAt = min(resampleAt). If
%                           beginResampleAt is specified and more than
%                           min(resampleAt), then the resampling of both the
%                           waveforms are done at
%                           resampleAt(resampleAt>=beginResampleAt), and if it
%                           is less than min(resampleAt), then the resampling
%                           of both the waveforms are done at [beginResampleAt
%                           resampleAt].
%
%      .endResampleAt     = A scalar value at which resampling of waveform1 and
%                           waveform2 ends. By DEFAULT, this is the
%                           largest element of resampleAt, i.e.,
%                           endResampleAt = max(resampleAt). If
%                           endResampleAt is specified and less than
%                           max(resampleAt), then the resampling of both the
%                           waveforms are done at
%                           resampleAt(resampleAt<=endResampleAt), and if it
%                           is more than max(resampleAt), then the resampling
%                           of both the waveforms are done at [resampleAt,
%                           endResampleAt].
%
%      .abstol            = The absolute tolerance for waveform comparison
%                           DEFAULT value: 1e-9 
%
%      .reltol            = The relative tolerance for waveform comparison
%                           DEFAULT value: 1e-3 
%
%NOTE: If both beginResampleAt and endResampleAt have been specified, then
%the resampling of both the waveforms are done at 
%[beginResampleAt,
%resampleAT(resampleAt >= beginResampleAt & resampleAt<= endResampleAt)
%endResampleAt]
%              
%Returns:
%  passOrFail  -    1, if both the waveforms match (for a given pair of
%                        abstol and reltol).
%
%                     0, if both the waveforms do not match (for a given pair
%                        of abstol and reltol).
%
%                  (-1), otherwise (some error occured and the comparison
%                        between both the waveforms was not complete).
%
% comparisonInfo - Various information regrading the waveform comparison test.
%                  It contains the following fields:
%
% .msg             - If passOrFail == 1, then this is an empty string. If
%                    pass_of_fail == 0, then it contains the error message
%                    saying the the comparison test failed. If pass_of_fail ==
%                    (-1), then it contains the error message detailing where
%                    the error occured.
%                  
% .diffs           - If passOrFail == 1 or 0, then diffs =
%                    abs(resampledAmps1 - resampledAmps2), where
%                    resampledAmps1 and resampledAmps2 are resampled
%                    waveform1 and waveform2, respectively. If passOrFail ==
%                    (-1), then this is an empty matrix.
%                  
% .thresholds      - If passOrFail == 1 or 0, then thresholds = abstol + 0.5
%                    * (abs(resampledAmps1) + abs(resampledAmps2))*reltol.
%                    If passOrFail == (-1), then this is an empty matrix.
%                  
% .mismatchIndices - If passOrFail == 1 or (-1), then mismatchIndices is an
%                    empty matrix. If passOrFail == 0, then mismatchIndices is
%                    an array of indices corresponding to resampled waveforms
%                    at which the reltol/abstol test has failed, i.e.,
%                    mismatchIndices = find(diffs > thresholds);
%
% .mismatchPoints  - If passOrFail == 1 or (-1), then mismatchPoints is an
%                    empty matrix. If passOrFail == 0, then mismatchPoints is
%                    an array of points from resampledAt at which the
%                    reltol/abstol test has failed, i.e., mismatchPoints =
%                    resampleAt(find(diffs > thresholds));
%                  
% .reltol          - If passOrFail == 1 or 0, then reltol is the reltol that
%                    was used in the abstol/reltol test for the waveform
%                    comparison. If passOrFail == (-1), then this is an empty
%                    matrix.
%                  
% .abstol          - If passOrFail == 1 or 0, then abstol is the abstol that
%                    was used in the abstol/abstol test for the waveform
%                    comparison. If passOrFail == (-1), then this is an empty
%                    matrix.
%                  
% .interpMethod    - If passOrFail == 1 or 0, then interpMethod is the
%                    interpolation algorithm that was used in the
%                    abstol/abstol test for the waveform comparison. If
%                    passOrFail == (-1), then this is an empty matrix.
%                  
% .beginResampleAt - If passOrFail == 1 or 0, then beginResampleAt is the
%                    starting value of independent variable of the resampled
%                    waveforms.  If passOrFail == (-1), then this is an empty
%                    matrix.
%                  
% .endResampleAt   - If passOrFail == 1 or 0, then endResampleAt is the
%                    final value of independent variable of the resampled
%                    waveforms.  If passOrFail == (-1), then this is an empty
%                    matrix.
%
% .resampledAmps1 - If passOrFail == 1 or 0, then resampledAmps1 is the
%                    resampled waveform1. If passOrFail == (-1), then this is
%                    an empty matrix.
%
% .resampledAmps2 - If passOrFail == 1 or 0, then resampledAmps2 is the
%                    resampled waveform2. If passOrFail == (-1), then this is
%                    an empty matrix.
%
% .resampleAt      - <TODO> Rewrite this.
%                    If passOrFail == 1 or (-1), then mismatchPoints is an
%                    empty matrix. If passOrFail == 0, then mismatchPoints is
%                    an array of points from resampledAt at which the
%                    reltol/abstol test has failed, i.e., mismatchPoints =
%                    resampleAt(find(diffs > thresholds));

    % Set DEFAULT output in case any error occurs 
    passOrFail = (-1);
    comparisonInfo.msg = ''; % Empty string
    comparisonInfo.diffs=[];
    comparisonInfo.thresholds = [];
    comparisonInfo.mismatchIndices = []; 
    comparisonInfo.mismatchPoints = []; 
    comparisonInfo.reltol = [];
    comparisonInfo.abstol = [];
    comparisonInfo.interpMethod = '';
    comparisonInfo.beginResampleAt = [];
    comparisonInfo.endResampleAt = [];
    comparisonInfo.resampledAmps1 = [];
    comparisonInfo.resampledAmps2 = [];
    comparisonInfo.resampledAt = [];
    comparisonInfo.x1 = waveform1(1,:);
    comparisonInfo.y1 = waveform1(2,:);
    comparisonInfo.x2 = waveform2(1,:);
    comparisonInfo.y2 = waveform2(2,:);

    % Check for proper arguments
    if nargin < 2 || nargin > 3 
        % No. of arguments should be >=2 but <3
        comparisonInfo.msg = [sprintf('ERROR: Wrong number of arguments. The function \n') ...
                              sprintf('can only accept two or three arguments.\n\n')];
        % Also let us display this error message as well : TODO --> Should we?
        disp([ comparisonInfo.msg help('compare_waveforms')]);
        return; % Abort

    else %if nargin == 2 or 3

        % Do a waveform sanity check 
        [waveform_ok_1, sanity_chk.msg_1] = waveform_sanity_chk(waveform1,1);
        if waveform_ok_1 == 0  
            % Check if the waveform is okay
            comparisonInfo.msg = [ comparisonInfo.msg sanity_chk.msg_1];
            %disp([sanity_chk.msg_1 help('compare_waveforms')]);
            return;
        end

        [waveform_ok_2, sanity_chk.msg_2] = waveform_sanity_chk(waveform2,2);
        if waveform_ok_2 == 0  
            % Check if the waveform is okay
            comparisonInfo.msg = [ comparisonInfo.msg sanity_chk.msg_2];
            %disp([sanity_chk.msg_2 help('compare_waveforms')]);
            return;
        end

        % If nargin == 2 
        if nargin == 2
            % DEFAULT values for 'parms'
            interpMethod = 'linear'; % parms.interpMethod
            resampleAt = unique([waveform1(1,:) waveform2(1,:)]); % parms.resampleAt
            abstol = 1e-9; % parms.abstol
            reltol = 1e-3; % parms.reltol
            beginResampleAt = min(resampleAt);
            endResampleAt = max(resampleAt);

        else %if nargin == 3
            % parms is provided
            if isfield(parms,'interpMethod') 

                if strcmp(parms.interpMethod,'linear') || ...
                        strcmp(parms.interpMethod,'nearest')|| ...
                        strcmp(parms.interpMethod,'cubic') || ...
                        strcmp(parms.interpMethod,'spline')

                    interpMethod = parms.interpMethod;

                else

                    comparisonInfo.msg = sprintf('ERROR: The argument parms.interpMethod is %s.\n', ...
                        parms.interpMethod);
                    comparisonInfo.msg = [ comparisonInfo.msg ...
                        'Allowable values for parms.interpMethod are : ''linear'','...
                        '''nearest'',''spline'', ''cubic'''];
                    % Display the message on the MATLAB command line
                    %disp([ comparisonInfo.msg help('compare_waveforms')]);
                    return; % Abort
                end

            else
                interpMethod = 'linear';
            end

            % Check if the field parms.abstol is present, else use the
            % DEFAULT value
            if isfield(parms,'abstol') 
                % Check if it is a numeric
                if isnumeric(parms.abstol) 
                    % Check if it is a scalar
                    if isscalar(parms.abstol)
                        abstol = parms.abstol;
                    else
                        comparisonInfo.msg = sprintf('ERROR: The argument parms.abstol is.\n');
                        comparisonInfo.msg = [ comparisonInfo.msg sprintf('%s',evalc('disp(parms.abstol)'))];; 
                        % Note:  evalc(disp(a)) returns a char array, disp(a) does
                        % not for some reason.
                        comparisonInfo.msg = [ comparisonInfo.msg ...
                            sprintf('parms.abstol can only be a scalar integer or float (single or double).\n')];
                        % Display the message on the MATLAB command line
                        %disp([ comparisonInfo.msg help('compare_waveforms')]);
                        return; % Abort
                    end
                else
                    comparisonInfo.msg = sprintf('ERROR: The argument parms.abstol is %s.\n', ...
                        num2str(parms.abstol)); 
                    % Note:  if x is a string, x = num2str(x)
                    comparisonInfo.msg = [ comparisonInfo.msg ...
                        sprintf('parms.abstol can only be an integer or a float (single or double).\n')];
                    %disp([ comparisonInfo.msg help('compare_waveforms')]);
                    return; % Abort
                end
            else
                abstol = 1e-9;
            end

            % Check if the field parms.reltol is present, else use the
            % DEFAULT value
            if isfield(parms,'reltol') 
                % Check if it is a numeric
                if isnumeric(parms.reltol) 
                    % Check if it is a scalar
                    if isscalar(parms.reltol)
                        reltol = parms.reltol;
                    else
                        comparisonInfo.msg = sprintf('ERROR: The argument parms.reltol is.\n');
                        comparisonInfo.msg = [ comparisonInfo.msg sprintf('%s\n',evalc('disp(parms.reltol)'))];; 
                        % Note:  evalc(disp(a)) returns a char array, disp(a) does
                        % not for some reason.
                        comparisonInfo.msg = [ comparisonInfo.msg ...
                            sprintf('parms.reltol can only be a scalar integer or float (single or double).\n')];
                        % Display the message on the MATLAB command line
                        %disp([ comparisonInfo.msg help('compare_waveforms')]);
                        return; % Abort
                    end
                else
                    comparisonInfo.msg = sprintf('ERROR: The argument parms.reltol is %s.\n', ...
                        num2str(parms.reltol)); 
                    % Note:  if x is a string, x = num2str(x)
                    comparisonInfo.msg = [ comparisonInfo.msg ...
                        sprintf('parms.reltol can only be an integer or a float (single or double).\n')];
                    %disp([ comparisonInfo.msg help('compare_waveforms')]);
                    return; % Abort
                end
            else
                reltol = 1e-3;
            end
            %Set resampleAt

            if isfield(parms,'resampleAt')
                % Check if resampleAt is numeric
                if isnumeric(parms.resampleAt)
                    % Check if it is 1D
                    if isrow(parms.resampleAt)|| iscolumn(parms.resampleAt)
                        resampleAt = parms.resampleAt;
                    else
                        comparisonInfo.msg = sprintf('ERROR: The argument parms.resampleAt is %s.\n', ...
                            num2str(parms.resampleAt)); 
                        comparisonInfo.msg = [ comparisonInfo.msg ...
                            sprintf('parms.resampleAt can only be an 1D numerical array.\n')];
                        %disp([ comparisonInfo.msg help('compare_waveforms')]);
                        return; % Abort
                    end
                else
                    comparisonInfo.msg = sprintf('ERROR: The argument parms.resampleAt is %s.\n', ...
                        num2str(parms.resampleAt)); 
                    comparisonInfo.msg = [ comparisonInfo.msg ...
                        sprintf('parms.resampleAt can only be an 1D numerical array.\n')];
                    %disp([ comparisonInfo.msg help('compare_waveforms')]);
                    return; % Abort
                end
            else
                % DEFAULT is union of both the independent variables
                resampleAt = unique([waveform1(1,:) waveform2(1,:)]); % parms.resampleAt
            end
            % Check if the field parms.beginResampleAt is present, 
            % else use the DEFAULT value
            if isfield(parms,'beginResampleAt') 
                % Check if it is a numeric
                if isnumeric(parms.beginResampleAt) 
                    % Check if it is a scalar
                    if isscalar(parms.beginResampleAt)
                        beginResampleAt = parms.beginResampleAt;
                    else
                        comparisonInfo.msg = sprintf('ERROR: The argument parms.beginResampleAt is.\n');
                        comparisonInfo.msg = [ comparisonInfo.msg sprintf('%s\n',evalc('disp(parms.beginResampleAt)'))];; 
                        % Note:  evalc(disp(a)) returns a char array, disp(a) does
                        % not for some reason.
                        comparisonInfo.msg = [ comparisonInfo.msg ...
                            sprintf('parms.beginResampleAt can only be a scalar integer or float (single or double).\n')];
                        % Display the message on the MATLAB command line
                        %disp([ comparisonInfo.msg help('compare_waveforms')]);
                        return; % Abort
                    end
                else
                    comparisonInfo.msg = sprintf('ERROR: The argument parms.beginResampleAt is %s.\n', ...
                        num2str(parms.beginResampleAt)); 
                    % Note:  if x is a string, x = num2str(x)
                    comparisonInfo.msg = [ comparisonInfo.msg ...
                        sprintf('parms.beginResampleAt can only be an integer or a float (single or double).\n')];
                    %disp([ comparisonInfo.msg help('compare_waveforms')]);
                    return; % Abort
                end
            else
                beginResampleAt = min(resampleAt);
            end

            % Check if the field parms.endResampleAt is present, 
            % else use the DEFAULT value
            if isfield(parms,'endResampleAt') 
                % Check if it is a numeric
                if isnumeric(parms.endResampleAt) 
                    % Check if it is a scalar
                    if isscalar(parms.endResampleAt)
                        endResampleAt = parms.endResampleAt;
                    else
                        comparisonInfo.msg = sprintf('ERROR: The argument parms.endResampleAt is.\n');
                        comparisonInfo.msg = [ comparisonInfo.msg sprintf('%s\n',evalc('disp(parms.endResampleAt)'))];; 
                        % Note:  evalc(disp(a)) returns a char array, disp(a) does
                        % not for some reason.
                        comparisonInfo.msg = [ comparisonInfo.msg ...
                            sprintf('parms.endResampleAt can only be a scalar integer or float (single or double).\n')];
                        % Display the message on the MATLAB command line
                        %disp([ comparisonInfo.msg help('compare_waveforms')]);
                        return; % Abort
                    end
                else
                    comparisonInfo.msg = sprintf('ERROR: The argument parms.endResampleAt is %s.\n', ...
                        num2str(parms.endResampleAt)); 
                    % Note:  if x is a string, x = num2str(x)
                    comparisonInfo.msg = [ comparisonInfo.msg ...
                        sprintf('parms.endResampleAt can only be an integer or a float (single or double).\n')];
                    %disp([ comparisonInfo.msg help('compare_waveforms')]);
                    return; % Abort
                end
            else
                endResampleAt = max(resampleAt);
            end

            % Check if begin_resamp_start < end_resamp_end 
            if beginResampleAt > endResampleAt
                comparisonInfo.msg = sprintf('ERROR: The argument parms.beginResampleAt (%d) cannot be >= parms.endResampleAt (%d).\n', ...
                    num2str(parms.beginResampleAt),num2str(parms.endResampleAt)); 
                %disp([ comparisonInfo.msg help('compare_waveforms')]);
                return; % Abort
            end
        end
    end 




    % Redefine sampleAt based on t_start and t_end
    resampleAt = [beginResampleAt, resampleAt(resampleAt >beginResampleAt & resampleAt < endResampleAt),...
                      endResampleAt];

    % Resample waveform1
    resampledAmps1 = interp1(waveform1(1,:),waveform1(2,:), resampleAt, interpMethod,'extrap');

    % Resample waveform2
    resampledAmps2 = interp1(waveform2(1,:),waveform2(2,:), resampleAt, interpMethod,'extrap');

    diffs = abs(resampledAmps1 - resampledAmps2);
    thresholds = abstol + 0.5 * (abs(resampledAmps1) + abs(resampledAmps2))*reltol;
    passOrFail = min(diffs < thresholds) > 0.5;
    % Always return these irrespective of pass or fail
    % These feilds would be empty if any error occured before doing the
    % comparison test
    comparisonInfo.diffs = diffs;
    comparisonInfo.thresholds = thresholds;
    % Find where mismatch has occured
    comparisonInfo.mismatchIndices = find((diffs <thresholds)<0.5);
    % Find the exact mismatch points
    comparisonInfo.mismatchPoints = resampleAt(find((diffs <thresholds)<0.5));
    comparisonInfo.reltol = reltol;
    comparisonInfo.abstol = abstol;
    comparisonInfo.interpMethod = interpMethod;
    comparisonInfo.beginResampleAt = beginResampleAt;
    comparisonInfo.endResampleAt = endResampleAt;
    comparisonInfo.resampledAmps1 = resampledAmps1;
    comparisonInfo.resampledAmps2 = resampledAmps2;
    comparisonInfo.resampledAt = resampleAt;

    if (passOrFail == 0)
        comparisonInfo.msg = sprintf('Comparison FAILED.\n');
        %comparisonInfo.msg = [ comparisonInfo.msg  sprintf('\tSee comparisonInfo for details.\n')];
        %disp([ comparisonInfo.msg help('compare_waveforms')]);
    end
end % compare_waveforms ---- END ---------------------------------


% waveform_sanity_chk ---- BEGIN ---------------------------------
function [waveform_ok, msg] = ...
                    waveform_sanity_chk(waveform,waveform_no)
%Perfoms the sanity check on the argument for desired waveform confirmity

    waveform_ok = 0; % Not OKAY is DEFAULT
    msg = ''; % Empty string
    
    % CHECK 1: Is it numeric?
    if isnumeric(waveform)
        % CHECK 2: Is is two dimensional
        if size(waveform,1) == 2
            % CHECK 3: Is the first row unique (i.e., there is no repeated
            % numerical value)?
            if length(unique(waveform(1,:))) == length(waveform(1,:))
                % Here the waveform looks OKAY
                waveform_ok = 1;
            else % Repeated values are present in the independent row of the waveform
                msg = sprintf('ERROR in WAVEFORM%d SANITY CHECK\n',waveform_no);
                msg = [ msg ...
                    sprintf('There are repeated values in the first row of  argument ''waveform%d''.\n',waveform_no)];
            end
        else % Dimension is not 2
            msg = sprintf('ERROR in WAVEFORM%d SANITY CHECK\n',waveform_no);
            msg = [ msg ...
                sprintf('The argument ''waveform%d'' is not a 2D numerical array.\n',waveform_no)];
            msg = [ msg ...
                sprintf('The size of ''waveform%d'' is [ %s ].\n',waveform_no,num2str(size(waveform)))];
        end
    else % It is not numeric
        msg = sprintf('ERROR in WAVEFORM%d SANITY CHECK\n',waveform_no);
        msg = [ msg ...
            sprintf('The argument ''waveform%d'' is not a numerical array.\n',waveform_no)];
    end
end % waveform_sanity_chk ---- END ---------------------------------
