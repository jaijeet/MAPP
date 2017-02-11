function PObj = Parameters(DAE)
%function PObj = Parameters(DAE)
% This function creates a "class" that allows you to work with subsets of all
% the parameters in the DAE. It relies only on DAE.{nparms(),parmnames()} and
% the order of the parameters in parms. Useful for sensitivity and perhaps
% other kinds of analyses.
% NOTE  - this object just keeps track of parameter indices. The values are
%         kept in the DAE (and should be changed via DAE.setparms)
%
% functions supplied by this object:
%	pidxlist = ParmIndices(pobj)
%		returns the unknown vector indices of the parameters in pobj
%	pnames = ParmNames(pobj)
%		returns the names of the parameters in pobj (as a cell array)
%	pobjout = Reset(pobj)
%		resets pobj to _all_ DAE parameters
%	pobjout = DeleteAll(pobj)
%		zeroes current list of parameters
%	pobjout = Add(pobj, cell-array-of-valid-parmnames)
%		adds valid circuit parameters names to pobj
%	pobjout = Delete(pobj, cell-array-of-valid-parmames)
%		delete valid circuit parameter names from pobj
%	pobjout = ParmVals(pobj, DAEobj)
%		return values of the parameters in pobj from arg DAEobj
%
% Example of use:
%	ps = Parameters(DAE) % instantiates parameters; initializes with 
%        	% all dae parameters
%	ps = feval(ps.Delete, {'some_non_numerical_parm'}, ps); % 
%	ps = feval(ps.Defaults, ps; % restores all DAE parameters to pobj
%	ps = feval(ps.DeleteAll, ps);
%	ps = feval(ps.Add, {'R', 'C'}, ps);

% Author: Jaijeet Roychowdhury, 2009/11/16. Copied from Outputs and modified.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%
	% Data
	%
	PObj.allparmnames = feval(DAE.parmnames,DAE); % cell list
	%
	PObj.parmnames = PObj.allparmnames;
	PObj.numparms = feval(DAE.nparms, DAE);
	PObj.parmindices = 1:PObj.numparms;
	PObj.DAE = DAE; % this should really be a pointer
	%
	% functions supplied
	%
	PObj.ParmIndices = @ParmIndices;
	PObj.ParmNames = @ParmNames;
	PObj.Reset = @Reset;
	PObj.DeleteAll = @DeleteAll;
	PObj.Delete = @Delete;
	PObj.Add = @Add;
	PObj.ParmVals = @ParmVals;
% end Parameters "constructor"

function out = ParmIndices(Pobj)
% return the indices
	out = Pobj.parmindices;
% end ParmIndices

function out = ParmNames(Pobj)
% return the names of the parameters
	out = Pobj.parmnames; % cell list
% end ParmNames

function Pobjout = Reset(Pobj)
% reset to all dae parms
	Pobj.parmnames = Pobj.allparmnames;
	Pobj.numparms = feval(Pobj.DAE.nparms, Pobj.DAE);
	Pobj.parmindices = 1:Pobj.numparms;
	Pobjout = Pobj; % remember Pobj is a local copy in matlab
% end Reset

function Pobjout = DeleteAll(Pobj)
% zaps all parameters;
	Pobj.parmnames = {};
	Pobj.numparms = 0;
	Pobj.parmindices = [];
	Pobjout = Pobj; % remember Pobj is a local copy in matlab
% end function DeleteAll of class Parameters


% useful: strmatch, strfind, FINDSTR, STRVCAT, STRCMP, STRNCMP, deblank, deblankall

function Pobjout = Add(strings, Pobj)
% Usage: Pobj = feval(Pobj.Add, Pobj, {'Is', 'Vt'});
% 
	for i=1:length(strings)
		str = strings{i};
		idx = strmatch(str, Pobj.allparmnames, 'exact');
		lenidx = length(idx);
		if (lenidx > 0) 
			for j=1:lenidx
				Pobj.numparms = Pobj.numparms + 1;
				Pobj.parmindices(Pobj.numparms) = ...
					idx(j);
				Pobj.parmnames{Pobj.numparms} = ...
					Pobj.allparmnames{idx(j)};
			end
		else
			fprintf(2, 'no such parameter %s - ignoring.\n', str);
		end
	end
	Pobjout = Pobj; % remember Pobj is a local copy in matlab
% end function Add of Parameters

function Pobjout = Delete(strings, Pobj)
% Usage: Pobj = feval(Pobj.Delete, Pobj, {'1', 'vdd.i'});
% FIXME someday: this is not very efficient.
% 
	for i=1:length(strings)
		str = strings{i};
		idx = strmatch(str, Pobj.parmnames, 'exact');
		lenidx = length(idx);
		if (lenidx > 0) 
			for j=1:lenidx
				Pobj.parmindices(idx(j)) = -1;
				%Pobj.parmnames{idx(j)} = '';
				%Pobj.numparms = Pobj.numparms - 1;
			end
		else
			fprintf(2, 'no such parameter %s - ignoring.\n', str);
		end
	end
	% get rid of deleted entries
	nparms = 0; tmpnames = {}; tmpindices = [];
	for i=1:length(Pobj.parmindices) % bad: O(length(parmindices))
		if (Pobj.parmindices(i) ~= -1)
			nparms = nparms+1;
			tmpindices(nparms) = Pobj.parmindices(i);
			tmpnames{nparms} = Pobj.parmnames{i};
		end
	end
	Pobj.parmindices = tmpindices;
	Pobj.parmnames = tmpnames;
	Pobj.numparms = nparms;
	Pobjout = Pobj; % remember Pobj is a local copy in matlab
% end function Delete of Parameters

function parmvals = ParmVals(Pobj, DAEobj)
% return values of Pobj parameters, take them from DAEobj (not from Pobj.DAE)
	% first check that DAEobj and Pobj.DAE have the same parameters, in
	% the same order. Note that checking is inefficient.
	dpnames = feval(DAEobj.parmnames, DAEobj);
	if length(dpnames) ~= length(Pobj.allparmnames)
		fprintf(2,'ParmVals: error: lengths of DAEobj and Pobj.DAE parameter lists differ.\n');
		parmvals = 'Error.';
	end
	for i=1:length(Pobj.allparmnames)
		if Pobj.allparmnames{i} ~= dpnames{i}
			fprintf(2,'ParmVals: error: entry %d of DAEobj and Pobj.DAE parameter lists differ: %s vs %s.\n', i, dpnames{i}, Pobj.allparmnames{i});
			parmvals = 'Error.';
		end
	end
	dparmvals = feval(DAEobj.getparms, DAEobj);
	parmvals = dparmvals(Pobj.parmindices);
% end function ParmVals
