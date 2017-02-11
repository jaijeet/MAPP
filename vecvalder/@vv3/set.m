function s = set (obj, varargin)
  s = obj;
  ll = length(varargin);
  if (ll < 2 || rem(ll, 2) ~= 0)
    error('set: expecting property/value pairs');
  end
  while (length (varargin) > 1)
    prop = varargin{1};
    val = varargin{2};
    varargin(1:2) = [];
    if (ischar (prop) && strcmp (prop, 'val'))
      if (isvector (val) && isreal (val))
        s.val = val;
      else
        error ('set: expecting the value to be a real ');
      end
    elseif (ischar (prop) && strcmp (prop, 'der'))
      if (isvector (val) && isreal (val))
        s.der = val;
      else
        error ('set: expecting the value to be a real ');
      end
    else
      error ('set: invalid property of valder class');
    end
 end
end
