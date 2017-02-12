%Differential-Algebraic Equations in MAPP
%----------------------------------------
%
%Differential-algebraic equations (DAEs) are a central concept around which
%MAPP is based. MAPP's DAEs have the following general form:
%
%       d/dt [q(x(t))] + f(x(t), u(t)) = 0,
%       y(t) = C*x(t) + D*u(t).
%
%Here, x(t) is a column vector of the system's n unknowns, u(t) is a column
%vector of its n_u inputs, f(.,.) and q(.) are (in general nonlinear)
%functions that return column vectors of size n. y(t) is a vector of n_o
%outputs, while C and D are matrices of size n_o x n and n_o x n_u,
%respectively.
%
%MAPP's DAEAPI wrapper (help DAEAPI_wrapper) is a convenient high-level wrapper
%that MAPP provides for describing such DAEs. It is also possible to define
%DAEs directly using its low-level API (help DAEAPI).  Once a DAE has been
%defined, you can test its functions (described in help DAEAPI) and run
%MAPP's analyses (help MAPPanalyses) on it.
%
%Examples
%--------
%
% help add_to_DAE contains examples you can cut and paste, and also lists
% several m-files defining DAEs that you can examine.
% 
%See also
%--------
%
% init_DAE, add_to_DAE, finish_DAE, check_DAE, DAEAPI_wrapper, DAEAPI.
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2015/07                                            %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%%               reserved.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
