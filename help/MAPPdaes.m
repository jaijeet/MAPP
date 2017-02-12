%Differential-Algebraic Equations in MAPP
%----------------------------------------
%
%In MAPP, differential-algebraic equations (DAEs) are written in the following
%general form:
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
%DAEAPI wrapper (help DAEAPI_wrapper) is a convenient high-level wrapper that
%MAPP provides (on top of its lower-level DAEAPI API) for describing such DAEs.
%
%To write a DAE using DAEAPI wrapper:
%
%1. Start with
%	    DAE = init_DAE();
%2. Then put in several
%	    DAE = add_to_DAE(DAE, 'field_name', field_value);
%   statements to augment the skeleton structure.
%3. Finally, end with
%	    DAE = end_DAE(DAE);
%
%help add_to_DAE for more information and examples.  Once the DAE is set up,
%you can run MAPP's analyses (help MAPPanalyses) on it.
%
%Examples
%--------
%
% help add_to_DAE contains examples you can cut and paste, and also lists
% several m-files defining DAEs that you can examine.
% 
%See also
%--------
%  init_DAE, add_to_DAE, finish_DAE, check_DAE, DAEAPI_wrapper, DAEAPI.
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2015/07                                            %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%%               reserved.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
