function [success, summary] = run_ALL_DAEAPI_tests_silent(updateOrCompare)
%function [success, summary] = run_ALL_DAEAPI_tests_silent(updateOrCompare)
% calls run_ALL_DAEAPI_tests or update_ALL_DAEAPI_tests but suppresses the
% outputs
% 
%Inputs:
% - updateOrCompare: string, 'compare' or 'update', default if 'compare' .
%   if 'compare', it calls run_ALL_DAEAPI_tests and returns the results.
%   if 'update', it calls update_ALL_DAEAPI_tests and returns the results.
%
%Outputs:
% - success: 1 or 0.
% - summary: struct, like in MAPPtest_AC/DC/TRAN, it contains the following
%            fields.
%        
%     .msgSummary     - Brief summary of the test outcome
%                      "All DAEAPI tests passed." or
%                      "One or more DAEAPI tests failed, see comparisonInfo for
%                      details." or
%                      "Error: input is neither 'update' nor 'compare'."
%     .msgDetailed    - Detailed summary whenever applicable
%                      (empty as the info is contained in comparisonInfo)
%     .comparisonInfo - Detailed information about the comparison in 'compare'
%                       mode.
%                      (the printout of original run/update_ALL_DAEAPI_tests)
    if 0 == nargin
        updateOrCompare = 'compare';
    end

    global isOctave;
    if strcmp(updateOrCompare, 'compare');
        if ~isOctave
            [T, success] = evalc('run_ALL_DAEAPI_tests');
        else
            success = run_ALL_DAEAPI_tests;
            T = 'Octave: output of run_ALL_DAEAPI_tests not recorded';
        end
		if 1 == success
			summary.msgSummary = 'All DAEAPI tests passed.';
			summary.msgDetailed = '';
			summary.comparisonInfo = T;
		else % 0 == success
			summary.msgSummary = 'One or more DAEAPI tests failed, see the comparisonInfo field of MAPPtest''s output for details.';
			summary.msgDetailed = '';
			summary.comparisonInfo = T;
		end
    elseif strcmp(updateOrCompare, 'update');
        if ~isOctave
            T = evalc('update_ALL_DAEAPI_tests');
        else
            update_ALL_DAEAPI_tests;
            T = 'Octave: output of update_ALL_DAEAPI_tests not recorded';
        end 
        success = 1;
		summary.msgSummary = ['All DAEAPI tests updated, see comparisonInfo for details.', ...
	        'Remember to move the generated .mat files from the current directory to test-data/ under DAEAPI''s installation folder'];
        summary.msgDetailed = '';
        summary.comparisonInfo = T;
    else
        success = 0;
        summary.msgSummary = 'Error: input is neither ''update'' nor ''compare''.';
        summary.msgDetailed = '';
        summary.comparisonInfo = '';
    end

end
