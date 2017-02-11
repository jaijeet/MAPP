function DAE = readSPICE(filename)
%function DAE = readSPICE(filename)
%This function parses the SPICE netlist in filename using Parser-for-DAEAPI and
%sources the resulting .m file to produce the corresponding DAE.
%INPUT arg:
%   filename        - name of a SPICE netlist
%
%OUTPUT:
%   DAE             - DAE object representing the same circuit as the input
%                     SPICE netlist
%
%Call this function using MATLAB's command format (eg, "readSPICE simpleRLC.sp")
%or using the function format "readSPICE('simpleRLC.sp')".
%
%Example:
%	DAE = readSPICE spiceinputs/simpleRC.sp
%
	%BASH=sprintf('%s/bin/bash', CYGWINPREFIX);
	BASH=sprintf('/bin/bash');

	%display(sprintf('readSPICE: filename is "%s"\n',filename));
	%display(sprintf('readSPICE: CYGWINPREFIX is "%s"\n',CYGWINPREFIX));

	%if ( (filename(1) == '/') | (strfind(filename,CYGWINPREFIX) == 1) )
	if ( (filename(1) == '/') )
		absolutepath=filename;
		%cyglen = length(CYGWINPREFIX);
		%if (cyglen > 0)
		%	absolutepath(1:cyglen)=''; % take out CYGWINPREFIX
		%end
	else
		[status,retval] = unix('pwd');
		% get rid of trailing \n and other junk
		for i=length(retval):-1:1
			if ((retval(i) < 33) | (retval(i) > 126))
				%display(sprintf('retval(%d) seems to be ASCII %d=%s; setting to 0\n', i, retval(i),retval(i)));
				%%retval(length(retval)) = '';
				retval(i) = '';
			else
				break; % out of for loop
			end
		end
		%retval
		absolutepath=sprintf('%s/%s', retval, filename);
		%absolutepath
	end

	% FIXME/TODO: here we need to do this sed type processing more natively
	%subscmd = sprintf('echo %s | sed -e ''s#.*/##'' -e ''s/\..*//'' ', absolutepath);
	%[status, cktfuncdirname] = system(subscmd);
	%if (status ~= 0)
	%	fprintf(2, 'There was an error running sed (TODO: implement error handling)\n');
	%end

	%mkdircmd = sprintf('mkdir %s/cktmpdefunchandles;', SPPTMPDIR, );
	%[status, output] = system(mkdircmd);
	%if (status ~= 0)
	%	fprintf(2, 'There was an error in mkdir - may be benign.\n');
	%end

	global PARSER; % set up by setuppaths_DAEAPI; absolute pathname of parser script or executable
	PARSEROUTPUT = 'parser_output';

	rmcmd = sprintf('rm -f %s.m', PARSEROUTPUT);
	[status, output] = unix(sprintf('%s -c "%s"', BASH, rmcmd));

	runparsercmd = sprintf('%s %s %s.m', PARSER, absolutepath, PARSEROUTPUT);
	%runparsercmd
	[status, output] = unix(sprintf('%s -c "%s"', BASH, runparsercmd));

	if (length(output) > 0)
		fprintf(2, 'output from parser:\n');
		fprintf(2, '%s\n', output);
	end

	if (status ~= 0)
		fprintf(2, 'There was an error running %s.\nPlease look into it.\n\n', PARSER);
		out = 'ERROR running run-parser.sh';
		return;
	end

	fprintf(1, '\nFile %s\n\ttranslated to Matlab code in\n\t./%s.m.\n', filename, PARSEROUTPUT);

	DAE = eval(sprintf('%s;', PARSEROUTPUT)); 
end
