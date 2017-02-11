function fighandle = freqDomainMagPhasePlot(freqs, allHs, onames, analysistitle, daename, plotallinone, nophaseplots)
%function fighandle = freqDomainMagPhasePlot(freqs, allHs, onames, analysistitle, daename, plotallinone, nophaseplots)
% OLD: See freqDomainMagPhasePlot.m for the latest version of this file.

%Plots complex data as a function of frequency in magnitude/phase plots
%(old)
%magnitudes are plotted in log-log fashion; phases in linear-log fashion.
%
%inputs:
%	freqs: array (row) of frequency values.
%	allHs: 2D matrix of complex numbers
%		- each column contains all the outputs for a single freq. pt.
%		- each row contains all frequency points for a single output
%	onames: cell array containing the names of the outputs. 
%		length(onames) should equal size(allHs,1);
%	analysistitle: a string used for labelling the plots. Example: 'AC analysis'
%	daename: a string used for labelling plots. Example: 'diffpair with Vin=0.1'
%`	plotallinone: if 1, do all the plots in one figure, using subplots.
%		FIXME: if 0, not clear if this does anything useful.
%`	nophaseplots: optional; if 1, don't do the phase plots. Useful for PSDs.
%

	if nargin < 7
		nophaseplots = 0;
	end

	plotallinone = 1;
	if 1 == plotallinone
		fighandle = figure;
	else
		fighandle = [];
	end

	noutputs = size(allHs,1);
	for k=1:noutputs
		Hs = allHs(k,:); % row vector
		mags = abs(Hs);
		if 0 == nophaseplots
			% phases = phase(Hs); % use angle() instead - supported in Octave
			phases = angle(Hs); % use angle() instead - supported in Octave
		end
		if 0==plotallinone
			figure;
		end
		thiscol = getcolorfromindex(gca,k);
		if 0 == nophaseplots
			subplot(2,1,1); 
		end
		loglog(freqs, mags, '.-', 'color', thiscol);
		if 0==plotallinone
			xlabel('Frequency');
			ylabel('Magnitude');
			ttl = sprintf('%s: Magnitude of %s', ...
				analysistitle, onames{k});
			title(ttl);
			grid on; axis tight;
		end
		hold on;

		if 0 == nophaseplots
			subplot(2,1,2); 
			semilogx(freqs, phases/pi*180, '.-', ...
				'color', thiscol);
			if 0==plotallinone
				xlabel('Frequency');
				ylabel('Phase (degrees)');
				ttl = sprintf('Phase of %s', onames{k});
				title(ttl);
				grid on; axis tight;
			end
		end
		hold on;
		drawnow;
	end
	% set up legends if all in one plot
	if 1 == plotallinone
		if 0 == nophaseplots
			subplot(2,1,1); 
		end
		xlabel('Frequency');
		ylabel('Magnitude');
		ttl = sprintf( '%s (magnitude): %s', analysistitle, ...
					daename);
		title(ttl);
		grid on; axis tight;
		legend(onames, 'Location', 'SouthWest');

		if 0 == nophaseplots
			subplot(2,1,2); 
			xlabel('Frequency');
			ylabel('Phase (degrees)');
			ttl = sprintf( '%s (phase): %s', analysistitle, ...
						daename);
			title(ttl);
			grid on; axis tight;
			legend(onames, 'Location', 'SouthWest');
		end
	end
% end of freqDomainMagPhasePlot

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





