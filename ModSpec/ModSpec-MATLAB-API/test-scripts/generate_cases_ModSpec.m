function [dtests, rtests] = generate_cases_ModSpec...
		(n_dtests, n_rtests, MOD)
% <TODO> Need some comments here place holder </TODO>
%========================================================
% function [dtests, rtests] = generate_cases_ModSpec...
% 		(n_dtests, n_rtests, MOD)
% Author: Tianshi Wang, 2012-11-17
%
% Usage: [dtests, rtests] = generate_cases_ModSpec...
% 		(n_dtests, n_rtests, MOD)
% 	Generates dynamic test cases and 
%		  random test cases for 
%	run_ModSpec_functions
%
% Inputs:  n_dtests --> number of dynamic test cases 
%          n_rtests --> number of random  test cases 
%	   MOD 	    --> model to test

% Outputs: dtests   --> dynamic test cases
%			(cellarray sized n_dtests)
% 	   rtests   --> random  test cases
%			(cellarray of size 2:
%			rtest{1} is n_rtests
%			rtest{2} is a rtests template)
%========================================================
%
oions = feval(MOD.OtherIONames, MOD);
iuns = feval(MOD.InternalUnkNames, MOD);
unames = feval(MOD.uNames, MOD);
lvars = feval(MOD.LimitedVarNames, MOD);
%
% dynamic test cases
dtests = {}; % in case n_dtests == 0
%
for c = 1:n_dtests
	dtests{c}.vecX = rand(length(oions),1); 
	dtests{c}.vecY = rand(length(iuns),1); 
	dtests{c}.vecU = rand(length(unames),1); 
	dtests{c}.vecLim = rand(length(lvars),1); 
	dtests{c}.vecLimOld = rand(length(lvars),1); 
end
%
% random test cases
rtests{1} = n_rtests;
%
rtests{2}.vecX = rand(length(oions),1); 
rtests{2}.vecY = rand(length(iuns),1); 
rtests{2}.vecU = rand(length(unames),1); 
rtests{2}.vecLim = rand(length(lvars),1); 
rtests{2}.vecLimOld = rand(length(lvars),1); 
