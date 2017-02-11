function obj = vv3 (a, b)

% TODO: change the comments here to reflect true nature of vv3
% This is vv3, an alternative implementation of vecvalder. On running some
% basic speed tests, we found that most of the time taken during a transient
% run, for example, was in the execution of vecvalder's val2mat and der2mat
% functions. So, with vv3, we are looking for a new implementation of vecvalder
% that does not use cell arrays, val2mat, der2mat, etc. The key difference
% between vv3 and vecvalder is that vv3 uses a much simpler structure for
% storing (value, derivative) pairs (described below). 
%
% Let x be a vector of independent variables, of size 3. Let y be a vector of 
% size 5, that is a function of x. Then, in vv3, the object y will have one data 
% member called valder, with the following properties:
%
% size(y.valder) = [5, 4],
% the "val" part of y = y.valder[:, 1], and
% the "der" part of y = y.valder[:, 2:end]
%

    if (nargin == 0)
        obj.valder = [];
        obj = class (obj, 'vv3');
    elseif (nargin == 1)
        if siz
            disp('ERROR: the argument can only be a column vector!');
            return;
        end
        obj.valder = [a, speye(size(a, 1))];
        obj = class (obj, 'vv3');
    elseif (nargin == 2)
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
        obj = class (obj, 'vv3');
    else
        disp('ERROR: vv3: unexpected number of arguments');
    end

end

