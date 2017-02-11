function [dtests, rtests] = generate_cases_DAEAPI...
		(n_dtests, n_rtests, DAE)
%========================================================
% function [dtests, rtests] = generate_cases_DAEAPI...
% 		(n_dtests, n_rtests, DAE)
% Author: Tianshi Wang, 2012-11-20
%
% Usage: [dtests, rtests] = generate_cases_DAEAPI...
% 		(n_dtests, n_rtests, DAE)
% 	Generates dynamic test cases and 
%		  random test cases for 
%	run_DAEAPI_functions
%
% Inputs:  n_dtests --> number of dynamic test cases 
%          n_rtests --> number of random  test cases 
%	   DAE 	    --> DAE to test

% Outputs: dtests   --> dynamic test cases
%			(cellarray sized n_dtests)
% 	   rtests   --> random  test cases
%			(cellarray of size 2:
%			rtest{1} is n_rtests
%			rtest{2} is a rtests template)
%========================================================
%
nunks = feval(DAE.nunks, DAE);
neqns = feval(DAE.neqns, DAE);
ninputs = feval(DAE.ninputs, DAE);
nlimitedvars = feval(DAE.nlimitedvars, DAE);
%
% dynamic test cases
dtests = {}; % in case n_dtests == 0
%
for c = 1:n_dtests
	dtests{c}.x = rand(nunks,1); 
	dtests{c}.xlim = rand(nlimitedvars,1); 
	dtests{c}.xlimOld = rand(nlimitedvars,1); 
	dtests{c}.u = rand(ninputs,1); 
end
%
% random test cases
rtests{1} = n_rtests;
%
rtests{2}.x = rand(nunks,1); 
rtests{2}.xlim = rand(nlimitedvars,1); 
rtests{2}.xlimOld = rand(nlimitedvars,1); 
rtests{2}.u = rand(ninputs,1); 
