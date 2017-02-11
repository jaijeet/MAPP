function out = der2mat(u)
%function out = der2mat(u) (also soft linked as jac)
%VECVALDER/DER2MAT (vv2 version) defines val2mat of a vv2 object. It just
%returns the derivative - ie, all columns of u.valder except the first.
%
%Note: the ugly name der2mat is retained for backward compatibility. Use jac()
%instead in your code.
%
%Author: JR, 2014/06/18
    if ~isempty(u.valder)
        out = u.valder(:,2:end);
    else
        out = [];
    end
end
