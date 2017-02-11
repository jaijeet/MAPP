function [success, summary] = run_ALL_vecvalder_tests_silent(updateOrCompare)
%function [success, summary] = run_ALL_vecvalder_tests_silent(updateOrCompare)
% calls run_ALL_vecvalder_tests but suppress the output
% 
%Inputs:
% - updateOrCompare: string, 'compare' or 'update', default if 'compare' .
%   if 'compare', it calls run_ALL_vecvalder_tests and returns the results.
%   if 'update', it doesn't do anything as update routine for vecvalder test is
%   not implemented or needed.
%
%Outputs:
% - success: 1 or 0.
% - summary: struct, like in MAPPtest_AC/DC/TRAN, it contains the following
%            fields.
%        
%     .msgSummary     - Brief summary of the test outcome
%                      "All vecvalder tests passed." or
%                      "One or more vecvalder tests failed, see comparisonInfo
%                      for details." or
%                      "Error: input is neither 'update' nor 'compare'."
%     .msgDetailed    - Detailed summary whenever applicable
%                      (empty as the info is contained in comparisonInfo)
%     .comparisonInfo - Detailed information about the comparison in 'compare'
%                       mode.
%                      (the printout of original run_ALL_vecvalder_tests)
%
    if 0 == nargin
        updateOrCompare = 'compare';
    end

    if strcmp(updateOrCompare, 'compare');
        global isOctave;
        if ~isOctave
            [T, success] = evalc('run_ALL_vecvalder_tests');
        else
            success = run_ALL_vecvalder_tests([], 1);
            T = 'Octave: output of run_ALL_vecvalder_tests not recorded';
        end 
		if 1 == success
			summary.msgSummary = 'All vecvalder tests passed.';
			summary.msgDetailed = '';
			summary.comparisonInfo = T;
		else % 0 == success
			summary.msgSummary = 'One or more vecvalder tests failed, see the comparisonInfo field of MAPPtest''s output for details.';
			summary.msgDetailed = '';
			summary.comparisonInfo = T;
		end
    elseif strcmp(updateOrCompare, 'update');
        success = 1;
        summary.msgSummary = 'update_ALL_vecvalder_test is not implemented, nor is it needed.';
        summary.msgDetailed = '';
        summary.comparisonInfo = '';
    else
        success = 0;
        summary.msgSummary = 'Error: input is neither ''update'' nor ''compare''.';
        summary.msgDetailed = '';
        summary.comparisonInfo = '';
    end

end
