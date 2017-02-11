function out = vertcat(varargin)
%function out = vertcat(varargin)
%VECVALDER/vertcat overloads vecvalder (vv2) [a; b; c] for vv objects
%
%NO SIZE CHECKS (for efficiency): using numeric vertcat to catch size problems
%
%Note: this uses for loops; inefficient, should be used sparingly.
%
%TODO: make a global empty vv2 object to avoid calling the constructor
%
%Use: z = [x; y]
%Author: JR, 2014/06/18
  % find the number of derivs for the vecvalder args (assuming they are the
  % same for all vecvalder arguments)
  for i=1:nargin % how many args: nargin seems to work, at least in octave
    if isobject(varargin{i})
        nderivs = size(varargin{i}.valder,2)-1;
        out = varargin{i}; % for efficiency - don't call constructor
        out.valder = [];
	    break;
    end
  end
  
  % do the vertcat
  for i=1:nargin
    if isobject(varargin{i})
  	    out.valder = [out.valder; varargin{i}.valder];
    else % numeric vector
        the_len = length(varargin{i});
  	    out.valder = [out.valder; [varargin{i}, zeros(the_len, nderivs)]];
    end
  end
end
