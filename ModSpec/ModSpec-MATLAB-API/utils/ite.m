function out = ite (ifcond, ifval, elseval)
%function out = ite (ifcond, ifval, elseval)
%
%This function is meant to be a replacement for an if/else condition.
%
%The statement "w = ite(x, y, z);" is equivalent to the following:
%
%if x
%    w = y;
%else
%    w = z;
%end
%
%The reason for using ite instead of if/else is to enable analysis by vv4.
%
%Author: Aadithya V. Karthik <aadithya@berkeley.edu>, July 2014.
%

    if ifcond
        out = ifval;
    else
        out = elseval;
    end
end
