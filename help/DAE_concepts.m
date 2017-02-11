%The DAE system with state x(t), inputs u(t) and outputs y(t), parameters p,
%and noise inputs n(t) is given by: 
%
% if the flag DAE.f_takes_inputs == 0:
%
%    qdot(x, p) + f(x, p) + B*u(t) + m(x, n(t), p) = 0
%    y = C*x + D*u(t)
%
% if the flag DAE.f_takes_inputs == 1:
%
%    qdot(x, p) + f(x, u(t), p) + m(x, n(t), p) = 0
%    y = C*x + D*u(t)
%
% - for descriptions on DAE's API implemented in MAPP:
%   >> help DAEAPI;
%
