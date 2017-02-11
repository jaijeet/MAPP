%Using fft() to compute Fourier coefficients
%-------------------------------------------
%
%Derivation
%----------
%
%Given a truncated Fourier series
%
%    x(t) = \sum_{i=-M}^M X_i e^{j i 2 pi f0 t},                         --- (1)
%
%let N = 2M+1, T = 1/f0 and j=sqrt(-1). If we sample x(t) uniformly at
%intervals of T/N, then we get, for n= 0, ..., N-1, 
%
%    x_n = x(nT/N) = \sum_{i=-M}^M X_i e^{j i 2 pi f0 n T/N}
%                  = \sum_{i=-M}^M X_i e^{j i 2 pi n/N}
%                  = \sum_{i=-M}^{-1} X_i e^{j i 2 pi n/N} + 
%                                        \sum_{i=0}^M X_i e^{j i 2 pi n/N}
%                  = \sum_{l=M+1}^{N-1} X_{l-N} e^{j i 2 pi n/N} + 
%                                        \sum_{i=0}^M X_i e^{j i 2 pi n/N},
%                                            (defining l = i - N).       --- (2)
%
%Now, for i > M, define X_l = X_{l-N}. Then (2) becomes
%
%    x_n = \sum_{i=0}^{N-1} X_i e^{j i 2 pi n/N}.                        --- (3)
%
%So, the order of the Fourier coefficients for i=0, ..., N-1 is
%
%    X_0, X_1, ..., X_M, X_{-M}, X{-M+1}, ..., X{-1}.                    --- (4)
%
%We will refer to this as the "FFT ordering".
%
%MATLAB's help fft says:
%> FFT(X) is the discrete Fourier transform (DFT) of vector X.
%> For length N input vector x, the DFT is a length N vector X,
%> with elements
%>                  N
%>    X(k) =       sum  x(n)*exp(-j*2*pi*(k-1)*(n-1)/N), 1 <= k <= N.    --- (5)
%>                 n=1
%> The inverse DFT (computed by IFFT) is given by
%>                  N
%>    x(n) = (1/N) sum  X(k)*exp( j*2*pi*(k-1)*(n-1)/N), 1 <= n <= N.    --- (6)
%>                 k=1
%
%Comparing (3) with (6), we see that
%
%  -------------------------
%  | {x_n} = N*ifft({X_i}) |.                                            --- (7)
%  -------------------------
%
%And using (5), we have
%
%  ---------------------------
%  | {X_i} = 1/N * fft{x_n}) |.                                          --- (8)
%  ---------------------------
%
%
%Examples
%--------
%
%M = 8; % for example
%N= 2*M+1;
%T=1; % example; signal should be periodic with this T
%tpts = (0:(N-1))/N*T;
%A1=1; phi1=0; A3=3; phi3=0;
%samples = A1*cos(2*pi/T*tpts+phi1) + A3*sin(3*2*pi/T*tpts+phi3); % for example
%tmp = fft(samples)/N;
%% tmp contains the F. coeffs. in FFT order: tmp(1) isX_0; tmp(2:M+1) are X_1
%% to X_M; tmp(N:-1:M+2) are X_{-1} to X{-M}.
%
%% reorder tmp into -M, ..., M order
%Xarray(1:M)=tmp(M+2:N); Xarray((M+2):N)=tmp(2:(M+1)); Xarray(M+1)=tmp(1);
%% now Xarray(1:M) are X_{-M} to X{-1}; Xarray(M+1:N) are X(0) to X(N)
%
%figure(); h=subplot(2,1,1); stem(-M:M,abs(Xarray));
%oof=sprintf('Fourier Coefficient index (multiples of f0=%g)', 1/T);
%xlabel(oof); ylabel('magnitude'); grid on; axis tight;
%title(sprintf(...
%     'F. coeff. magnitudes of %g*cos(2*pi*f0*t+%g)+%g*sin(3*2*pi*f0*t+%g)', ...
%     A1, phi1, A3, phi3));
%h=subplot(2,1,2); stem(-M:M,phase(Xarray)/pi);
%xlabel(oof); ylabel('phase (fraction of pi)'); grid on; axis tight;
%title(sprintf(...
%      'F. coeff. phases of %g*cos(2*pi*f0*t+%g)+%g*sin(3*2*pi*f0*t+%g)', ...
%      A1, phi1, A3, phi3));
%
%% Now run an ifft and compare with the original data
%tmp2 = N*ifft(tmp);
%figure(); plot(tpts, samples, 'b.-', tpts, tmp2, 'c.-');
%legend({'original samples', 'samples after ifft(fft())'});
%xlabel('time'); ylabel('values'); grid on; axis tight;
%title(sprintf(...
%      'time-domain plot of %g*cos(2*pi*f0*t+%g)+%g*sin(3*2*pi*f0*t+%g)', ...
%      A1, phi1, A3, phi3));
%err = max(abs(tmp2-samples));
%fprintf(2, 'error between original and reconstructed samples: %g\n', err);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Author: J. Roychowdhury, 2015/07/19                                         %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%%               reserved.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
