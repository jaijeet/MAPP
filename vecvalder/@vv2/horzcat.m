function out = horzcat(varargin)
%function out = horzcat(varargin)
%VECVALDER/HORZCAT overloads vecvalder (vv2) [a, b, c] for vv objects
%
%This operation is not supported and will emit an error.
%
%Author: JR, 2014/06/18
  num_vecvalders = 0;
  out = vecvalder();
  for i=1:nargin % how many args: nargin seems to work, at least in octave
    if isobject(varargin{i})
		if ~isempty(varargin{i}.valder)
			if num_vecvalders > 0
				error('vecvalder (vv2) horzcat [a, b, c] is NOT supported - you cannot, eg, make matrices of vecvalders');
			end
			out = varargin{i}; % just return the first real vecvalder
			num_vecvalders = num_vecvalders+1;
		end
	else % it should be numeric
		if ~isempty(varargin{i})
				error('vecvalder (vv2) horzcat [a, b, c] is NOT supported - you cannot, eg, make matrices of vecvalders');
		end
    end
  end
end
