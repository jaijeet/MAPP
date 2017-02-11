function out = val2mat(u)
%function out = val2mat(u) (also soft linked as val)
%VECVALDER/VAL2MAT (vv2 version) defines val2mat of a vv2 object. It just
%returns the value - ie, the first column of u.valder.
%
%Note: the ugly name val2mat is retained for backward compatibility. Use val()
%instead in your code.
%
%Author: JR, 2014/06/18
    if ~isempty(u.valder)
        out = u.valder(:,1);
    else
        out = [];
    end
end
