function [figh, colindex] = freqDomainMagPhasePlot(freqs, allHs, ...
      onames, analysistitle, daename, nophaseplots, fighin, linetype, ...
      colindex, magplottype)
%function [figh, clrindex] = freqDomainMagPhasePlot(freqs, allHs, ...
%    onames, analysistitle, name, nophaseplots, fighin, linetype, ...
%    clrindex, magplottype)
%
%Plots complex data as a function of frequency in magnitude/phase plots.
%Magnitudes are plotted with loglog; phases using semilogx.
%freqDomainMagPhasePlot can be called multiple times to update an existing
%figure with additional waveforms in a sensible way. It is the workhorse
%behind LTISSS.plot.
%
%Arguments:
%	freqs:         array (row) of frequency values.
%	allHs:         2D matrix of complex numbers
%		       - each column contains all the outputs for a single 
%                        freq. pt.
%		       - each row contains all frequency points for a single 
%                        output
%	onames:        cell array containing the names of the outputs. 
%		       length(onames) should equal size(allHs,1);
%	analysistitle: a string used for labelling the plots. Example: 
%                      'AC analysis'
%	name:          an additional string used for labelling.
%                      Example: 'diffpair with Vin=0.1'
%	nophaseplots:  (optional) if 1, don't do the phase plots. Useful 
%                      for plotting PSDs.
%	fighin:        (optional) if specified, adds plots to the provided
%                      figure handle. If not specified (or []), creates a new
%                      figure.
%	linetype:      (optional) specifies line type in plots. If not
%                      specified (or []): '.-'
%	clrindex:      (optional) specifies index of colour to start plots from.
%	               Uses getcolorfromindex to select the colour.
%   magplottype:   (optional) a case-insensitive string that determines how 
%                  the magnitude will be plotted:
%                  - 'log10': plot log10(magnitude). This is the default.
%                  - 'linear' or 'lin': plot just the magnitude.
%                  - '10log10' or 'pwrdB' or 'pdB': plot 10*log10(magnitude)
%                    - 'dB' implies '10log10' (will issue a warning)
%                  - '20log10' or 'magdB' or 'vdB': plot 20*log10(magnitude)
%
%Outputs:
%	figh:          figure handle of the plot. Useful for passing into
%                      a subsequent call (as fighin).
%	clrindex:      updated clrindex after the plots. Useful for passing into
%                      a subsequent call.
%
%Examples
%--------
%
% freqs = 1:1000; Hs = crand(2,1000); names = {'Hs1(1)', 'Hs1(2)'};
% analysistitle = 'test plot';
% name = 'random data';
%
% [figh, colindex] = freqDomainMagPhasePlot(freqs, Hs, names, ... 
%                    analysistitle, name, 0);
%
%
%See also
%--------
% LTISSS::LTISSSplot, getcolorfromindex
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2020 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	if nargin < 6
		nophaseplots = 0;
	end

	if nargin < 7  || 0 == sum(size(fighin))
		figh = figure;
	else
		figh = figure(fighin);
		hold on;
	end

	if nargin < 8  || 0 == sum(size(linetype))
		linetype = '.-';
	end

	if nargin < 9  || 0 == sum(size(colindex))
		colindex = 0;
	end

	if nargin < 10  || isempty(magplottype)
		magplottype = 'log10';
	end

	noutputs = size(allHs,1);
	for k=1:noutputs
		Hs = allHs(k,:); % row vector

		mags = abs(Hs);
		colindex = colindex + 1;
		thiscol = getcolorfromindex(gca,colindex);
		if 0 == nophaseplots
			subplot(2,1,1); 
		end

        if strcmpi('db', magplottype)
            warning('magplottype=%s is ambiguous; assuming 10log10', ...
                    magplottype);
            magplottype='10log10';
        end

        if strcmpi('log10', magplottype)
		    loglog(freqs, mags, linetype, 'color', thiscol);
            magstr = 'Magnitude';
        elseif strcmp('linear', magplottype) || strcmpi('lin', magplottype)
		    semilogx(freqs, mags, linetype, 'color', thiscol);
            magstr = 'Magnitude';
        elseif strcmpi('10log10', magplottype) ...
                                || strcmpi('pwrdb', magplottype) ...
                                || strcmpi('pdb', magplottype)
		    semilogx(freqs, 10*log10(mags+1e-18), linetype, 'color', thiscol);
            magstr = '10*log10(Magnitude)';
        elseif strcmpi('20log10', magplottype) ...
                                || strcmpi('magdb', magplottype) ...
                                || strcmpi('vdb', magplottype)
		    semilogx(freqs, 20*log10(mags+1e-18), linetype, 'color', thiscol);
            magstr = '20*log10(Magnitude)';
        else
            error('Unrecognized magplottype %s', magplottype);
        end
		hold on;

		if 0 == nophaseplots
			% phases = phase(Hs); % use angle() instead, supported in Octave
			phases = angle(Hs); % use angle() instead, supported in Octave
			subplot(2,1,2); 
			semilogx(freqs, phases/pi*180, linetype, 'color', thiscol);
			hold on;
		end
		drawnow;
	end

	% labels and legends for the magnitude plots
	if 0 == nophaseplots
		subplot(2,1,1); 
		ttlmagstr=' (magnitude)';
	else
		ttlmagstr='';
	end
	xlabel('Frequency');
	ylabel(magstr);
	ttl = sprintf( '%s%s: %s', analysistitle, ttlmagstr, daename);
    %ttl = strrep(ttl, '_', '\_');
    ttl = escape_special_characters(ttl);
	title(ttl);
	grid on; axis tight;
    % onames = strrep(onames, '_', '\_');
    for i=1:length(onames)
        onames{i} = escape_special_characters(onames{i});
    end
	legend(onames, 'Location', 'SouthWest');

	% labels and legends for the phase plots
	if 0 == nophaseplots
		subplot(2,1,2); 
		xlabel('Frequency');
		ylabel('Phase (degrees)');
		ttl = sprintf( '%s (phase): %s', analysistitle, daename);
        %ttl = strrep(ttl, '_', '\_');
        ttl = escape_special_characters(ttl);
		title(ttl);
		grid on; axis tight;
		legend(onames, 'Location', 'SouthWest');
	end
end % of freqDomainMagPhasePlot
