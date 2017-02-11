function h = end(u, K, N)
%function h = end(u, K, N)
%VECVALDER/END (vv2 version) overloads end(u, K, N) when the argument is of
%vecvalder type.
% 
% Author: Tianshi, 2014/08/10
    
    h = size(u.valder, 1);
end

