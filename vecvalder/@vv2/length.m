function h = length(u)
%function h = length(u)
%VECVALDER/LENGTH (vv2 version) overloads length(u) when the argument is of
%vecvalder type.
% 
% Author: Tianshi, 2014/08/06
    
    h = size(u.valder, 1);
end
