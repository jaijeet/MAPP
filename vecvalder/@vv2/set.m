function out = set(u, varargin)
%function out = set(u, propname1, value1, propname2, value2, ...)
%VECVALDER/SET (vv2 version) overloads set() for a vv2 object, setting
%the appropriate parts of u and returning the updated version. This provides
%low-level access to a vecvalder object - USE WITH CAUTION. Also, it contains
%a while loop and is inefficient.
%
%Valid (propname, value) pairs are:
%
%- ('val', numeric_vector): set the value - ie, u.valder(:,1) to numeric_vector.
%                           Does not touch the derivative, or create it if
%                           u.valder is empty - USE WITH CAUTION. It is an
%                           error if the number of rows of numeric_vector does
%                           not equal that of an already existing derivative.
%       
%- ('der'/'jac', numeric_matrix): set the derivative - ie, u.valder(:,2:end) 
%                           to numeric_matrix.  Does not touch the value, or
%                           create it if u.valder is empty - USE WITH CAUTION.
%                           It is an error if the number of rows of
%                           numeric_matrix does not equal that of an already
%                           existing value.
%       
%- ('valder', numeric_matrix): sets u.valder to numeric_matrix.
%
%NO SIZE CHECKS.
%
%Author: JR, 2014/06/18
  ll = length(varargin);
  if (ll < 2 || mod(ll, 2) ~= 0)
    error('vecvalder (vv2) set: expecting property/value _pairs_.');
  end

  i=1; 
  out = u;
  while i < ll
    propname = varargin{i};
    the_value = varargin{i+1};
    if ischar(propname) 
        switch (propname)
            case 'val'
                out.valder(:,1) = the_value;
            case {'der', 'jac'}
                out.valder(:,2:end) = the_value;
            case 'valder'
                out.valder = the_value;
            otherwise
                error('vecvalder (vv2) set: invalid property %s', propname);
        end
    end
    i = i+2;
  end
end
