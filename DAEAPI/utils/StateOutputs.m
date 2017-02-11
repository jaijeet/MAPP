function OutputObj = StateOutputs(DAE)
%function OutputObj = StateOutputs(DAE)
%This function creates a StateOutputs object (useful for print/plot functions
%in various analyses like QSS, LTISSS, etc.)
%INPUT args:
%   DAE                 - DAE object
%OUTPUT:
%   OutputObj           - StateOutput object
%
%functions supplied by this object:
%      indexlist = OutputIndices(output-obj)
%      	returns the unknown vector indices of the current outputs
%      outnames = OutputNames(output-obj)
%      	returns the names of the current outputs (as a cell array)
%      output-obj = Reset(output-obj)
%      	resets current output list to all variables in dae
%      output-obj = DeleteAll(output-obj)
%      	zeroes current output list to null
%      output-obj = Add(output-obj, cell-array-of-ckt-varnames)
%      	adds valid circuit variable names to the current
%      	output list
%      output-obj = Delete(output-obj, cell-array-of-ckt-varnames)
%      	delete valid circuit variable names from the current
%      	output list
%
%Examples
%--------
%      outs = StateOutputs(DAE) % instantiates outputs; initializes with 
%       	% all dae variables
%      outs = feval(outs.DeleteAll, outs); % clears all variables to print
%      outs = feval(outs.Reset, outs); % restores all outputs to dae outputs
%      outs = feval(outs.DeleteAll, outs);
%      outs = feval(outs.Add, {'1', 'vdd.i'}, outs);
%      feval(qss.print, outs, qss); % prints solution of a qss object
%
%See also
%--------
%
% QSS, LMS, LTISSS, DAE_concepts, DAEAPI
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







% Data
%
OutputObj.alloutputnames = feval(DAE.unknames,DAE); % cell list
%
OutputObj.outputnames = OutputObj.alloutputnames;
OutputObj.numoutputs = feval(DAE.nunks, DAE);
OutputObj.outputindices = 1:OutputObj.numoutputs;
OutputObj.DAE = DAE; % this should really be a pointer
%
% functions supplied
%
OutputObj.OutputIndices = @OutputIndices;
OutputObj.OutputNames = @OutputNames;
OutputObj.Reset = @Reset;
OutputObj.DeleteAll = @DeleteAll;
OutputObj.Delete = @Delete;
OutputObj.Add = @Add;

% end StateOutputs "constructor"

function out = OutputIndices(Oobj)
% return the indices
	out = Oobj.outputindices;
% end OutputIndices

function out = OutputNames(Oobj)
% return the names of the outputs
	out = Oobj.outputnames; % cell list
% end OutputNames

function Oobjout = Reset(Oobj)
% reset to all dae variables
	Oobj.outputnames = Oobj.alloutputnames;
	Oobj.numoutputs = feval(Oobj.DAE.nunks, Oobj.DAE);
	Oobj.outputindices = 1:Oobj.numoutputs;
	Oobjout = Oobj; % remember Oobj is a local copy in matlab
% end Reset

function Oobjout = DeleteAll(Oobj)
% zaps all output variables;
	Oobj.outputnames = {};
	%fprintf('debug: outputnames is %s\n', Oobj.outputnames);
	Oobj.numoutputs = 0;
	%fprintf('debug: numoutputs is %d\n', Oobj.numoutputs);
	Oobj.outputindices = [];
	%fprintf('debug: outputindices is %d\n', Oobj.outputindices);
	Oobjout = Oobj; % remember Oobj is a local copy in matlab
% end function DeleteAll of class StateOutputs


% useful: strmatch, strfind, FINDSTR, STRVCAT, STRCMP, STRNCMP, deblank, deblankall

function Oobjout = Add(strings, Oobj)
% Usage: Oobj = feval(Oobj.Add, Oobj, {'1', 'vdd.i'});
% 
	for i=1:length(strings)
		str = strings{i};
		idx = strmatch(str, Oobj.alloutputnames, 'exact');
		lenidx = length(idx);
		if (lenidx > 0) 
			for j=1:lenidx
				Oobj.numoutputs = Oobj.numoutputs + 1;
				Oobj.outputindices(Oobj.numoutputs) = ...
					idx(j);
				Oobj.outputnames{Oobj.numoutputs} = ...
					Oobj.alloutputnames{idx(j)};
			end
		else
			fprintf(2, 'no such variable %s - ignoring.\n', str);
		end
	end
	Oobjout = Oobj; % remember Oobj is a local copy in matlab
% end function Add of StateOutputs

function Oobjout = Delete(strings, Oobj)
% Usage: Oobj = feval(Oobj.Delete, Oobj, {'1', 'vdd.i'});
% FIXME someday: this is not very efficient.
% 
	for i=1:length(strings)
		str = strings{i};
		idx = strmatch(str, Oobj.outputnames, 'exact');
		lenidx = length(idx);
		if (lenidx > 0) 
			for j=1:lenidx
				Oobj.outputindices(idx(j)) = -1;
				%Oobj.outputnames{idx(j)} = '';
				%Oobj.numoutputs = Oobj.numoutputs - 1;
			end
		else
			fprintf(2, 'no such variable %s - ignoring.\n', str);
		end
	end
	% get rid of deleted entries
	noutputs = 0; tmpnames = {}; tmpindices = [];
	for i=1:length(Oobj.outputindices) % bad: O(length(outputindices))
		if (Oobj.outputindices(i) ~= -1)
			noutputs = noutputs+1;
			tmpindices(noutputs) = Oobj.outputindices(i);
			tmpnames{noutputs} = Oobj.outputnames{i};
		end
	end
	Oobj.outputindices = tmpindices;
	Oobj.outputnames = tmpnames;
	Oobj.numoutputs = noutputs;
	Oobjout = Oobj; % remember Oobj is a local copy in matlab
% end function Delete of StateOutputs
