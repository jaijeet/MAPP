function obj = vecvalder(a, b)
%function obj = vecvalder(a, b)
%VECVALDER (vv2 version) constructor.
%
% This is vv2, an alternative implementation of vv1.  On running some
% basic speed tests, we found that most of the time taken during a transient
% run, for example, was in the execution of vv1's val2mat and der2mat
% functions. So, with vv2, we are looking for a new implementation of vecvalder
% that does not use cell arrays, val2mat, der2mat, etc. The key difference
% between vv2 and vecvalder is that vv2 uses a much simpler structure for
% storing (value, derivative) pairs (described below). 
%
% Let x be a vector of independent variables, of size 3. Let y be a vector of 
% size 5, that is a function of x. Then, in vv2, the object y will have one data
% member called valder, with the following properties:
%
% size(y.valder) = [5, 4],
% the "val" part of y = y.valder[:, 1], and
% the "der" part of y = y.valder[:, 2:end]
%
%Author: Karthik Aadithya, 2014/06/14
%Updates: JR, 2014/06/16-18
%
    if 0 == nargin
        obj.valder = [];
        obj = class (obj, 'vecvalder');
    elseif 1 == nargin
        if (size(a, 2) > 1)
            disp('ERROR: the argument can only be a column vector!');
            return;
        end
        obj.valder = [sparse(a), speye(size(a, 1))];
        %obj.valder = [a, eye(size(a, 1))]; % dense; may be faster? No.
        obj = class (obj, 'vecvalder');
    elseif 2 == nargin 
        if ischar(b)
            % I'm assuming that strcmp(b, 'indep')
            b = speye(size(a,1));
        end
        if (size(a,1) ~= size(b,1))
            disp('ERROR: the two arguments must have the same number of rows!');
            return;
        end
        if (size(a, 2) > 1)
            disp('ERROR: the first argument can only be a vertical vector!');
            return;
        end

        obj.valder = sparse([a, b]);
        %obj.valder = [a, b];
        obj = class (obj, 'vecvalder');
    else
        disp('ERROR: vecvalder(vv2): unexpected number of arguments');
    end
end
