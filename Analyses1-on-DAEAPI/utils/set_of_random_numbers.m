function out = set_of_random_numbers(n, seed)
%out = set_of_random_numbers(n, seed)
%
%This provides a row vector of n independent, Gaussianly-distributed random 
%number samples (each of variance 1), obtained using randn().
%
%Arguments
%---------
%   n:      (integer) the number of samples in the output
%   seed:   (integer) if specified, seeds the stream of random numbers.
%           Defaults to 5489. To get the same set of samples, use the same
%           seed.
%
%Note
%----
%   Uses randstream() for seeding. help randstream for details.
%
%
%Examples
%--------
%   rands1 = set_of_random_numbers(50, 1);
%   rands2 = set_of_random_numbers(50, 2);
%   rands3 = set_of_random_numbers(100, 1);
%       % note: because of the same seed, rands3(1:50) == rands1.
%   plot(1:50, rands1, 1:50, rands2, 1:50, rands3(1:50));
%
%See also
%--------
%   rand, randn, randstream
%


% Author: Jaijeet Roychowdhury <jr@berkeley.edu>
%
% Changelog:
% 
% 2014/03/10: initial version (jr).

    if nargin < 1 
        n = 1;
    end
    if nargin < 2 
        seed = 5489;
    end

    s = RandStream.create('mt19937ar','seed',seed);
    RandStream.setDefaultStream(s);       
    out = randn(1,n);
end % set_of_random_numbers
