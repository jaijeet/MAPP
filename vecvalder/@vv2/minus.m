function h = minus(u,v)
%function h = minus(u,v)
%VECVALDER/MINUS (vv2 version) overloads subtraction: 2 arguments
%Author: JR, 2014/06/16
  if ~isobject(u) %u is a scalar
     h = v; % avoid using constructor
     % h = vecvalder(u-val2mat(v), -der2mat(v));
     h.valder = [u-v.valder(:,1), -v.valder(:,2:end)];
  elseif ~isobject(v) %v is a scalar
     h = u; % avoid using constructor below
     h.valder = [u.valder(:,1)-v, u.valder(:,2:end)];
   else
     h = u; % avoid using constructor below
     if 1 == size(u.valder,1)
        h.valder = ones(size(v.valder,1),1)*u.valder-v.valder;
     elseif 1 == size(v.valder,1)
        h.valder = u.valder-ones(size(u.valder,1),1)*v.valder;
     else
        h.valder = u.valder-v.valder;
     end
   end
end
