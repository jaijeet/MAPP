function InObj = Inputs(DAE)
%function InObj = Inputs(DAE)
% This function creates a "class" that allows you to work with subsets of all
% the inputs in the DAE. It relies only on DAE.{ninputs(),inputnames()} and
% the order of the inputs in inputnames. Useful for sensitivity and perhaps
% other kinds of analyses.
%
% functions supplied by this object:
%	inidxlist = InputIndices(inobj)
%		returns the unknown vector indices of the inputs in inobj
%	innames = InputNames(inobj)
%		returns the names of the inputs in inobj (as a cell array)
%	inobjout = Reset(inobj)
%		resets inobj to _all_ DAE inputs
%	inobjout = DeleteAll(inobj)
%		zeroes current list of inputs
%	inobjout = Add(inobj, cell-array-of-valid-inputnames)
%		adds valid circuit inputs names to inobj
%	inobjout = Delete(inobj, cell-array-of-valid-inputnames)
%		delete valid circuit input names from inobj
%	inobjout = InputVals(inobj, DAEobj)
%		return values of the inputs in inobj from arg DAEobj
%
% Example of use:
%	ins = Inputs(DAE) % instantiates inputs; initializes with 
%        	% all dae inputs
%	ins = feval(ins.Delete, {'some_inputs'}, ins); % 
%	ins = feval(ins.Defaults, ins; % restores all DAE inputs to inobj
%	ins = feval(ins.DeleteAll, ins);
%	ins = feval(ins.Add, {'Vin:::E'}, ins);

% Author: Tianshi Wang, 2016/01/28. Copied from Parameters and modified.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
	% Data
	%
	InObj.allinputnames = feval(DAE.inputnames,DAE); % cell list
	%
	InObj.inputnames = InObj.allinputnames;
	InObj.numinputs = feval(DAE.ninputs, DAE);
	InObj.inputindices = 1:InObj.numinputs;
	InObj.DAE = DAE; % this should really be a pointer
	%
	% functions supplied
	%
	InObj.InputIndices = @InputIndices;
	InObj.InputNames = @InputNames;
	InObj.Reset = @Reset;
	InObj.DeleteAll = @DeleteAll;
	InObj.Delete = @Delete;
	InObj.Add = @Add;
	InObj.InputVals = @InputVals;
% end Inputs "constructor"

function out = InputIndices(InObj)
% return the indices
	out = InObj.inputindices;
% end InputIndices

function out = InputNames(InObj)
% return the names of the inputs
	out = InObj.inputnames; % cell list
% end InputNames

function InObjout = Reset(InObj)
% reset to all dae inputs
	InObj.inputnames = InObj.allinputnames;
	InObj.numinputs = feval(InObj.DAE.ninputs, InObj.DAE);
	InObj.inputindices = 1:InObj.numinputs;
	InObjout = InObj; % remember InObj is a local copy in matlab
% end Reset

function InObjout = DeleteAll(InObj)
% zaps all inputs;
	InObj.inputnames = {};
	InObj.numinputs = 0;
	InObj.inputindices = [];
	InObjout = InObj; % remember InObj is a local copy in matlab
% end function DeleteAll of class Inputs

% useful: strmatch, strfind, FINDSTR, STRVCAT, STRCMP, STRNCMP, deblank, deblankall

function InObjout = Add(strings, InObj)
% Usage: InObj = feval(InObj.Add, InObj, {'Is', 'Vt'});
% 
	for i=1:length(strings)
		str = strings{i};
		idx = strmatch(str, InObj.allinputnames, 'exact');
		lenidx = length(idx);
		if (lenidx > 0) 
			for j=1:lenidx
				InObj.numinputs = InObj.numinputs + 1;
				InObj.inputindices(InObj.numinputs) = ...
					idx(j);
				InObj.inputnames{InObj.numinputs} = ...
					InObj.allinputnames{idx(j)};
			end
		else
			fprintf(2, 'no such input %s - ignoring.\n', str);
		end
	end
	InObjout = InObj; % remember InObj is a local copy in matlab
% end function Add of Inputs

function InObjout = Delete(strings, InObj)
% Usage: InObj = feval(InObj.Delete, InObj, {'1', 'vdd.i'});
% FIXME someday: this is not very efficient.
% 
	for i=1:length(strings)
		str = strings{i};
		idx = strmatch(str, InObj.inputnames, 'exact');
		lenidx = length(idx);
		if (lenidx > 0) 
			for j=1:lenidx
				InObj.inputindices(idx(j)) = -1;
				%InObj.inputnames{idx(j)} = '';
				%InObj.numinputs = InObj.numinputs - 1;
			end
		else
			fprintf(2, 'no such input %s - ignoring.\n', str);
		end
	end
	% get rid of deleted entries
	ninputs = 0; tmpnames = {}; tmpindices = [];
	for i=1:length(InObj.inputindices) % bad: O(length(inputindices))
		if (InObj.inputindices(i) ~= -1)
			ninputs = ninputs+1;
			tmpindices(ninputs) = InObj.inputindices(i);
			tmpnames{ninputs} = InObj.inputnames{i};
		end
	end
	InObj.inputindices = tmpindices;
	InObj.inputnames = tmpnames;
	InObj.numinputs = ninputs;
	InObjout = InObj; % remember InObj is a local copy in matlab
% end function Delete of Inputs

function inputvals = InputVals(InObj, DAEobj)
% return values of InObj inputs, take them from DAEobj (not from InObj.DAE)
	% first check that DAEobj and InObj.DAE have the same inputs, in
	% the same order. Note that checking is inefficient.
	dinputnames = feval(DAEobj.inputnames, DAEobj);
	if length(dinputnames) ~= length(InObj.allinputnames)
		fprintf(2,'InputVals: error: lengths of DAEobj and InObj.DAE input lists differ.\n');
		inputvals = 'Error.';
	end
	for i=1:length(InObj.allinputnames)
		if InObj.allinputnames{i} ~= dinputnames{i}
			fprintf(2,'InputVals: error: entry %d of DAEobj and InObj.DAE input lists differ: %s vs %s.\n', i, dinputnames{i}, InObj.allinputnames{i});
			inputvals = 'Error.';
		end
	end
	QSSvec = feval(DAEobj.uQSS, DAEobj);
	inputVec = QSSvec(InObj.inputindices);
	inputvals = num2cell(inputVec);
% end function InputVals
