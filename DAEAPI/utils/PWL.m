function v = PWL(ts, vs, t)
%function v = PWL(ts,vs,t)
%This function returns the output of a piece-wise linear signal at a
%specified time instance or vector.
%INPUT:
%    ts 	- time at which value of output is set by vs
%		  A row vector whose entries are strictly ascending
%    vs		- value of output at corresponding ts
% 		  A row vector of the same size as ts
%    t 		- time
%		  A scalar or vector
%
%OUTPUT:
%    v 		- value of the PWL source at time t
%		  A scalar or vector of the same size as t
%
%EXAMPLE:
%    ts = [1 2 3 4 5];
%    vs = [2 1 4 0 2];
%    t = 0.1:0.1:6;
%    v = PWL(ts,vs,t);
%    plot(t,v);
% 

%Author: Bichen Wu <bichen@berkeley.edu> circa 2013
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: B. Wu.
% Copyright (C) 2013 Bichen Wu <bichen@berkeley.edu>. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

    [m n] = size(t);
    v=ones(m,n);

    for i=1:length(t) 
        % find the interval which t fall into
        if t(i) <= ts(1,1)
            v(i) = vs(1,1);
        elseif t(i) >= ts(1, end);
            v(i) = vs(1, end);
        else
            interval = find (ts > t(i), 1) - 1;
    
        % find v at time t, knowing the interval
        
            t1 = ts(1, interval);
            v1 = vs(1, interval);
            t2 = ts(1, interval+1);
            v2 = vs(1, interval+1);
    
            slope = (v2 - v1) / (t2 - t1);
            v(i) = v1 + (t(i) - t1)*slope;
        end
    end

end
