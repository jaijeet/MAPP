%Differential-Algebraic Equations (DAEs)
%---------------------------------------
%
%Differential-Algebraic Equations (DAEs) are a central concept in MAPP.
%Every circuit or system is first represented as a DAE. Once the DAE has been
%set up, various numerical simulation algorithms ("analyses"), such as DC, AC
%and transient, can be run on it. Every device or compact model is also
%represented in DAE form.
%
%To understand MAPP's DAE representation, consider the simple scalar
%differential equation
%   d/dt[z(t)] = k*z(t) + sin(t).
%z(t) is the unknown to be solved for (a scalar function of time); sin(t) is
%an input waveform; and k is a constant parameter.
%
%Rewrite the above equation as
%   d/dt[z(t)] - k*z(t) - sin(t) = 0.
%
%Now, if we define: 
%   - x(t) = z(t), 
%   - q(x) = x,
%   - f(x, y) = -k*x - y, and
%   - u(t) = sin(t),
%then the above equation can be written as
%   d/dt[q(x(t))] + f(x(t), u(t)) = 0                          (the DAE).
%
%This is the form MAPP uses for DAEs. By defining the unknown(s) x(t), the
%input(s) u(t), and the functions q(.) and f(.,.) appropriately, virtually any
%continuous system in any physical domain can be modelled as a DAE. The
%following examples illustrate this for a few simple electrical and mechanical
%systems:
%
%1. vsrc-R-C circuit as a DAE
%   - run:
%     >> vsrcRC_as_DAE_demo
%
%2. damped pendulum as a DAE
%   - run:
%     >> damped_pendulum_as_DAE_demo
%
%Note that DAEAPI describes DAEs with as many equations as unknowns, whereas
%ModSpec (MAPP's way of specifying devices) usually describes device model
%DAEs with fewer equations than unknowns. Therefore, in ModSpec, for the device
%models to be connected to the rest of the system, the unknowns x are separated
%into IOs and internal (non-IO) states, while the equations f and q are
%separated into fe, qe, fi and qi. This is explained further in the
%help topic ModSpec_concepts (see also MAPPquickstart_ModSpec).
%
%Further reading on DAEs
%-----------------------
%
%J. Roychowdhury. (Chapter 3 of) Numerical Simulation and Modelling of
%                 Electronic and Biochemical Systems, Foundations and Trends®
%                 in Electronic Design Automation, Vol 3, Issue 2–3, December
%                 2009, NOW Publishers.
%                 http://http://www.nowpublishers.com/articles/foundations-and-trends-in-electronic-design-automation/EDA-009
%
%See also
%--------
%vsrcRC_as_DAE, damped_pendulum_as_DAE, MAPPquickstart

help MAPPquickstart_DAEs;
