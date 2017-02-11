function out = get(u, propname)
%function out = get(u, propname)
%VECVALDER/GET (vv2 version) overloads get() for a vv2 object. Valid
%property names (propname argument) are:
%'val': returns the value - ie, u.valder(:,1)
%'jac' or 'der': returns the derivative - ie, u.valder(:,2:end)
%'valder': returns u.valder, ie, both value and derivative.
%
%if propname is not specified, returns a structure with the fields:
%   - out.val
%   - out.der
%   - out.jac
%
%Author: JR, 2014/06/18
  if 1 == nargin
    out.val = u.valder(:,1);
    out.der = u.valder(:,2:end);
    out.jac = u.valder(:,2:end);
  elseif 2 == nargin
    if ischar(propname)
      switch (propname)
        case 'val'
          out = u.valder(:,1);
        case {'der', 'jac'}
    	  out = u.valder(:,2:end);
        case 'valder'
    	  out = u.valder;
        otherwise
          error('vecvalder (vv2) get: invalid property %s', propname);
      end
    else
      error('vecvalder (vv2) get: propname is not a string');
    end
  end
end
