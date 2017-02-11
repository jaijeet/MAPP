function out = vertcat(varargin)
  %VECVALDER/vertcat overloads [a; b; c] for vv objects
  %Use: z = [x; y]

  % how many args: nargin seems to work, at least in octave
  for i=1:nargin
      if isa(varargin{i}, 'vecvalder')
  	ders = der2mat(varargin{i});
	nvars = size(ders, 2);
	break;
      end
  end
  %
  vals = [];
  ders = [];
  for i=1:nargin
      if isa(varargin{i}, 'vecvalder')
  	vals = [vals; val2mat(varargin{i})];
  	ders = [ders; der2mat(varargin{i})];
      else
  	vals = [vals; varargin{i}];
  	ders = [ders; zeros(size(varargin{i}, 1), nvars)];
      end
  end
  out = vecvalder(vals, ders);
end
