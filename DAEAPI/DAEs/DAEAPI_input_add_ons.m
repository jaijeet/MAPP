function outDAE = DAEAPI_input_add_ons(DAE)
%function outDAE = DAEAPI_input_add_ons()
%This augments the virtual base class DAEAPI_skeleton_core with various data members 
%that are used for setting and evaluating inputs. It also some name and other functions to use
%these data members.
%author: J. Roychowdhury, 2011/06/09
%
%
%Typically, this will be used as follows:
%DAE = DAEAPI_skeleton_core;
%DAE = DAEAPI_input_add_ons(DAE);
%followed by further setting up the DAE's data members
%and functions.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%

% version, help string: 
	DAE.Usage = help('DAEAPI_input_add_ons');
	
% inputs
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% initialize DAE.uQSSvec_updates
	DAE.uQSSvec_default = @(DAEarg) zeros(feval(DAEarg.ninputs,DAEarg),1); % default = all zeros
	DAE.uQSSvec_updates.indices = [];
	DAE.uQSSvec_updates.values = [];

	% initialize DAE.utfunc_updates
	%DAE.utfunc_default = @(t, DAEarg) zeros(feval(DAEarg.ninputs,DAEarg), length(t));
	DAE.utfunc_default = @(t, DAEarg) feval(DAEarg.uQSS,DAEarg)*ones(1,length(t)); % default = DC input; vectorized wrt t
	DAE.utfunc_updates.vector_utfunc = [];
	DAE.utfunc_updates.vector_utfunc_args = [];
	DAE.utfunc_updates.indices = [];
	DAE.utfunc_updates.utfunclist = {}; 
	DAE.utfunc_updates.utargslist = {};

	% initialize DAE.uMtfunc_updates
	%DAE.uMtfunc_default = @(ts, DAEarg) zeros(feval(DAEarg.ninputs,DAEarg), length(t));
	DAE.uMtfunc_default = @(ts, DAEarg) feval(DAEarg.uQSS,DAEarg)*ones(1,size(ts,1)); % default = DC input; vectorized wrt #of rows if ts is a matrix
	DAE.uMtfunc_updates.vector_uMtfunc = [];
	DAE.uMtfunc_updates.vector_uMtfunc_args = [];
	DAE.uMtfunc_updates.indices = [];
	DAE.uMtfunc_updates.uMtfunclist = {}; 
	DAE.uMtfunc_updates.uMtargslist = {};

	% initialize DAE.Uffunc_updates
	DAE.Uffunc_default = @(f, DAEarg) zeros(feval(DAEarg.ninputs,DAEarg), length(f));
	DAE.Uffunc_updates.vector_Uffunc = [];
	DAE.Uffunc_updates.vector_Uffunc_args = [];
	DAE.Uffunc_updates.indices = [];
	DAE.Uffunc_updates.Uffunclist = {}; 
	DAE.Uffunc_updates.Ufargslist = {};

	% initialize DAE.uHBfunc_updates
	DAE.uHBfunc_default = @(f, DAEarg) zeros(feval(DAEarg.ninputs,DAEarg), 1);
	DAE.uHBfunc_updates.vector_uHBfunc = [];
	DAE.uHBfunc_updates.vector_uHBfunc_args = [];
	DAE.uHBfunc_updates.indices = [];
	DAE.uHBfunc_updates.uHBfunclist = {}; 
	DAE.uHBfunc_updates.uHBargslist = {};
	% end inputs
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	DAE.uQSS = @uQSS;
    DAE.uDC = @(varargin) feval(DAE.uQSS, varargin{:});
	DAE.set_uQSS = @set_uQSS;
	DAE.set_uDC = @(varargin) feval(DAE.set_uQSS, varargin{:});
	DAE.utransient = @utransient; % must be vectorized wrt t
	DAE.set_utransient = @set_utransient; 
	DAE.uMultitime = @uMultitime; 
	DAE.set_uMultitime = @set_uMultitime; 
	DAE.uLTISSS = @uLTISSS; % must be vectorized wrt f
	DAE.uAC = @(varargin) feval(DAE.uLTISSS, varargin{:});
	DAE.set_uLTISSS = @set_uLTISSS; 
	DAE.set_uAC = @(varargin) feval(DAE.set_uLTISSS, varargin{:});
	DAE.uHB = @uHB; 
	DAE.set_uHB = @set_uHB; 

	DAE.B = @(arg) []; % return empty, consistent with default being f_takes_inputs == 1

% outputs
	DAE.C = @(DAEarg) speye(feval(DAEarg.noutputs, DAEarg), feval(DAEarg.nunks, DAEarg)); % default: all unknowns x
	DAE.D = @(DAEarg) sparse(feval(DAEarg.noutputs, DAEarg), feval(DAEarg.ninputs, DAEarg)); % default: zeros 

	outDAE = DAE;
end
% end DAEAPI_input_add_ons "constructor"
