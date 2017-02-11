% This script tries to visualise equations that govern the growth of the
% filament in the dielectric in an RRAM.
%
% 1) An RRAM is a two-terminal device with two I/Os: ipn and vpn. For a regular
% two-terminal device, we should be able to write the model equation:
%
%     ipn = f(vpn).             (1)
%
% But for RRAM, there is another variable that affects ipn: the length of the
% filament in the dielectric (l), or the tunneling gap (gap), which is the
% distance between the tip of the filament and the opposite electrode.
% Since l+gap = tox, the thickness of the dielectric, here we only consider gap
% as the variable to model.
%
% Then the ipn equation becomes:
%
%     ipn = f1(vpn, gap).            (2)
%
% And gap should satisfy a differential equation:
%
%     d/dt gap = f2(vpn, gap).       (3)
%
% If we figure out what (2) and (3) should be, the model is complete.
%
% 2) Let's look at (2) first.
%
% In the Stanford model:
%
%     f1(vpn, gap) = I0 * exp(-gap/g0) * sinh(vpn/V0),
%
% where I0=10, g0=0.25e-9, V0=0.25 are fitting parameters.
%
% In the UMich model:
% TODO: much more complicated...
%
% 3) Let's look at (3).
% The problem with both Standford and UMich models is that f2() in (3) is not
% continuous, and apart from (3), gap should also satisfy:
%
%     gap_min <= gap <= gap_max.    (4)
%
% Both models define f2() only within the range in (4). This is often a
% deal-breaker in simulation.
%
% This scripts aims to plot f2_Stanford, f2_UMich with different vpn and gap
% values, then tries to come up with a modified version of f2 that is
% continuous, "accurate" within (4), and has definition beyond (4).
%

% Stanford:

vpns = -3:0.1:3;
gaps = 1e-10*(0:1:17);

kb = 1.3806226e-23; % Boltzmann's Constant (joules/kelvin)
q = 1.6021918e-19; % Electron Charge (C)

T_ini = 273+25;
T_cur = T_ini;

gamma0 = 16;
gamma_ini = gamma0;

Beta = 0.8;
tox = 12e-9;
F_min = 1.4e9;
Vel0 = 10;
Ea = 0.6;
a0 = 0.25e-9;

for c = 1:length(vpns)
	for d = 1:length(gaps)
		vpn = vpns(c);
		gap = gaps(d);

		gamma = gamma_ini - Beta * (gap/1e-9)^3;
		if ((gamma * abs(vpn)/ tox) < F_min)
			gamma = 0;
		end
		f2_Stanford(c, d) = - Vel0 * exp(- q * Ea / kb / T_cur) * sinh(gamma * a0 / tox * q * vpn / kb / T_cur);
	end % d
end % c

figure; 
surf(gaps, vpns, f2_Stanford);
xlabel('gap (m)');
ylabel('vpn (V)');
title('f2() in the Stanford RRAM model');

% UMich:

vpns = -5:0.1:5;
% gaps = 1e-10*(0:1:17);
gaps = 1e-9*(-1:0.1:6);

k = 1.3806226e-23; % Boltzmann's Constant (joules/kelvin)
q = 1.6021918e-19; % Electron Charge (C)

Beta = 10.56;
Ua = 0.87;
Kappa = 1903.84;
T = 300;
h = 5e-9;

Vt = k*T/q;

do_smooth = 1;
smoothing = 1e-5;
for c = 1:length(vpns)
	for d = 1:length(gaps)
		vpn = vpns(c);
		gap = gaps(d);
		l = h - gap;

		ion_flow = Beta * exp(-Ua/Vt) * sinh(vpn * Kappa/T);

        if 0 == do_smooth
			prev_underflow = double((sign(l) + sign(ion_flow) + 1) > 0);
			ddt_l = prev_underflow * ion_flow;
        else % 1 == do_smooth
			% % smooth version
			clipfactor = 1 - smoothstep(-ion_flow, smoothing)*smoothstep(-1e9*l, smoothing);
			ddt_l = clipfactor * ion_flow;
        end
		f2_UMich(c, d) = - ddt_l;
	end % d
end % c

figure; 
surf(gaps, vpns, f2_UMich);
xlabel('gap (m)');
ylabel('vpn (V)');
title('f2() in the UMich RRAM model');

