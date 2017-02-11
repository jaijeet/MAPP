function DAE = van_der_Pol_ish_DAEwrapper(spikiness)
%function DAE = van_der_Pol_ish_DAEwrapper(spikiness)
%DAE for a van der Pol like oscillator. From Mehrdad Niknami, 2015/07/07.
% The system is:
% > x' = y
% > y' = ((1 - x^2) * y - x) * spikiness
%
%If not specified, spikiness will be set to 10. Try 10^6 (from Mehrdad, who
%got it from the Intel ODE solver library documentation) - will need Gear2 and
%very good timestep control to simulate, with sharp peaks jumping to O(10^6)!
%
%Example:
%
%DAE = van_der_Pol_ish_DAEwrapper(); % spikiness = 10
% %run a transient with init cond
% %> x(0) = 2
% %> y(0) = 0
%tr = dot_transient(DAE, [2; 0], 0, 1e-2, 20);
%feval(tr.plot, tr)
%[tpts, vals] = feval(tr.getsolution, tr);
%figure;
% %phase plane plot
%plot(vals(1,:), vals(2,:), '.-');
%xlabel('x(t)'); ylabel('y(t)'); title('van der Pol-ish osc: phase plane plot');
%grid on; axis tight;
%

%Author: J. Roychowdhury, 2015/07/07
%
    if 0 == nargin
        spikiness = 10; % 
    end
	DAE = init_DAE();

	DAE = add_to_DAE(DAE, 'uniqIDstr','vanderPolish');
	DAE = add_to_DAE(DAE, 'nameStr', 'van der Pol-like oscillator');
	DAE = add_to_DAE(DAE, 'unkname(s)', {'x', 'y'});
	DAE = add_to_DAE(DAE, 'eqnname(s)', {'-xdotPlusf1(x,y)', '-ydotPlusf2(x,y)'});
	%DAE = add_to_DAE(DAE, 'inputname(s)', {});
	%DAE = add_to_DAE(DAE, 'outputname(s)', {'Vout=eCL-rCR'});

	DAE = add_to_DAE(DAE, 'parm(s)', {'spikiness', spikiness});
	DAE = add_to_DAE(DAE, 'f_takes_inputs', 1);

	DAE = add_to_DAE(DAE, 'f', @f);
	DAE = add_to_DAE(DAE, 'q', @q);

	DAE = add_to_DAE(DAE, 'C', @C);
	DAE = add_to_DAE(DAE, 'D', @D);

	DAE = finish_DAE(DAE);
end

function fout = f(S)
    % d/dt q(x) + f(x, inputs) = 0; this is f(x, inputs)
	v2struct(S);
    fout(1,1) = y;
    fout(2,1) = ((1-x^2)*y - x)*spikiness;
end %f(...)

function qout = q(S)
    % d/dt q(x) + f(x, inputs) = 0; this is q(x)
	v2struct(S);
	qout(1,1) = -x;
	qout(2,1) = -y;
% end q(...)
end

function out = C(DAE)
	out = eye(2); % x and y are both outputs
% end C(...)
end

function out = D(DAE)
	out = sparse(2,0); % no inputs
% end D(...)
end
