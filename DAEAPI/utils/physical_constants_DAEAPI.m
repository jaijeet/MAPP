function [k, q] = physical_constants_DAEAPI()
%function [k, q] = physical_constants_DAEAPI()
%This function returns k (Boltzmann's constant, in m^2 kg s^{-2})) and q
%(unit electronic charge, in Coulombs).
%INPUT arg: (none)
%
%OUTPUTS
%   k       - Boltzmann's constant (m^2 kg s^{-2})
%   q       - unit electronic charge (Coulombs)

	k = 1.380648813e-13; % Boltzmann's constant, from Wikipedia. Units: m^2 kg s^{-2}
	% k = 1.3806503e-13; % Boltzmann's constant according to google calculator.
	q = 1.60217656535e-19; % electronic charge from Wikipedia: Units: Coulomb (1 electron = this many Coulombs)
	% q = 1.60217646e-19; % according to google calculator.
% end physical_constants;
