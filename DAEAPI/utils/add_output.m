function cktdata = add_output(cktdata, unk1, varargin)
%function cktdata = add_output(cktdata, unk1, scale, unk2, oname)
%   or
%function cktdata = add_output(cktdata, unk1, unk2, scale, oname)
%   or
%function cktdata = add_output(cktdata, unk1, unk2, oname, scale)
%
%This function adds or replaces an output in cktdata -- ie, it sets up
%the output by adding it to or updating cktdata.outputs. (cktdata.outputs
%is used by the circuit equation engines ({MNA,STA}_EqnEngine) to set up the
%DAE's C() API function, which is used by the printing and plotting routines
%of various analyses.)
%
%add_output should be called after all add_element calls for setting
%up the netlist have been made.
%
%Arguments:
%
% - cktdata: the circuit netlist structure to be updated.
%
% - unk1:    a node voltage or branch current  (string):
%
%            - '<nodename>', 'e(<nodename>)', or 'v(<nodename>)' refers to
%              a node voltage output. <nodename> should have been declared
%              in cktdata.nodenames (see cktnetlist_lowlevel or
%              MAPPcktnetlists), otherwise an error will be issued.
%
%            - 'i(<elementname>)' refers to the current through the
%              circuit element <elementname>. <elementname> must already
%              exist in cktnetlist (ie, it must have been added using 
%              add_element()), otherwise an error will be issued.
%
%              - whether the current output is actually added to the
%                DAE, or just ignored with a warning, depends on the
%                equation engine on cktdata:
%
%                - for MNA_EqnEngine, only 2-terminal current-controlled
%                  elements are valid <elementname>s. Eg, voltage sources
%                  and inductors.
%
%                - for STA_EqnEngine, any 2-terminal element is valid.
%            - TODO: support adding device internal unknowns (like M1:::iddi)
%              - this will need cktnetlist = finish_cktnetlist(cktnetlist)
%                support, with checks, add_to_cktnelist(), etc..
%
% - scale:   (optional) if specified, multiplies unk1 (or unk1-unk2,
%            if unk2 is specified) to define the output. defaults to 1
%            if not specified or set to []. Should be a real number.
%
% - unk2:    (optional) if specified (same format as unk1), the output will be
%            scale*(unk1-unk2). Useful for, eg, differential outputs. Set this
%            to [] if there is no unk2 but you want to specify oname (below).
%
% - oname:   (optional) a name for the output (a string). This name will be
%            reported by the ckt DAE's outputnames() API function. If not
%            specified, or set to [], unk1 or unk1-unk2, multiplied by scale, 
%            will be used for the output name.
%
%
%Return values:
%
% - cktdata: updated circuit netlist structure with the output added.
%
%Implementation notes:
% - searching for element names and existing outputs is inefficient because
%   the data structure is cell arrays of structures or cell arrays,
%   requiring walking through the array.
%
%Examples
%--------
%  clear ntlst;
%
%  ntlst.nodenames = {'alpha', 'beta', '3', '1'}; % non-ground nodes
%  ntlst.groundnodename = '0';
%
%  % say there is code here that sets up the netlist with add_element
%  % calls, including a voltage source with name v1 and a resistor
%  % with name r1
%
%  ntlst = add_output(ntlst, 'e(1)'); % output name = 'e(1)'
%  ntlst = add_output(ntlst, 'e(1)', -1); % output name = '-1*e(1)'
%  ntlst = add_output(ntlst, 'beta', 'v(alpha)');
%                                     % output name: beta-v(alpha)'
%  ntlst = add_output(ntlst, 'beta', 'v(alpha)', 2);
%                                     % output name: '2*(beta-v(alpha))'
%  ntlst = add_output(ntlst, '3', '1', 'differential output', -1)
%                                     % output name: 'differential output'
%                                     % = e_3 - e_1
%  ntlst = add_output(ntlst, '3', '1', 'differential output', -1)
%                                     % output name: 'differential output'
%                                     % = -(e_3 - e_1)
%  ntlst = add_output(ntlst, 'a', [], -1, 'the output')
%                                     % output name: 'the output'
%                                     % = -e_a)
%
%  ntlst.outputs = {}; % clear all declared outputs
%  ntlst = add_output(ntlst, 'i(v1)', [], '1k*(current through v1)', 1e3); 
%                      % name: '1k*(current through v1)'
%  ntlst = add_output(ntlst, 'i(r1)', i(v1), 1e3); % will work  with
%                      % STA_EqnEngine [TODO: WHEN SUPPORTED]; MNA_EqnEngine
%                      % will throw a warning and ignore this output because
%                      % i(r1) is not an unknown in the MNA formulation.
%                      % name: '1000*(i(r1)-i(v1))'
%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  % a complete example of a ckt netlist with outputs set up
%
%  ntlst = SHringosc3_ckt; % type SHringosc3.m for details
%  ntlst.outputs = {}; % clear any already-declared outputs
%  ntlst = add_output(ntlst, 'inv1', 'inv2', 'v1-v2');
%  ntlst = add_output(ntlst, 'i(Vdd)', 1e3);
%  ntlst = add_output(ntlst, 'i(C1)', 1e3);
%  
%  DAE = MNA_EqnEngine(ntlst);  % MNA will drop i(C1) with a warning
%  %DAE = STA_EqnEngine(ntlst); % all outputs above valid for STA
%
%  DC = op(DAE);       
%  feval(DC.print, DC);
%
%  xinit = mod(1:feval(DAE.nunks,DAE),2)-0.5; % alternating 0.5 and -0.5
%  tstart = 0; tstep = 1e-5; tstop = 2.5e-3;
%  TR = transient(DAE, xinit, tstart, tstep, tstop);
%  feval(TR.plot, TR);
% 
%TODOS:
%   - write a convenience driver add_outputs that can take multiple outputs
%     - add_outputs(cktdata, 'v(1)', {'v(2)'}, {'3', [], myv3}, ...)
%   - doc:
%     - search through all files with add_element in the see also
%       section and add add_output(s) to them.
%   - ideally, we would like to declare multiple sets of outputs
%     (such as one set of voltages and another of currents), which
%     would be plotted on separate plots 
%     - this would require, essentially, multiple C() output
%       functions in DAEAPI. Or some additional data grouping the outputs
%       in C() into plots - just groups of indices into the rows of C().
%
%See also
%--------
% MAPPcktnetlists, cktnetlist_lowlevel, MAPPanalyses, MNA_EqnEngine[TODO], 
% STA_EqnEngine[TODO], DAE[TODO], DAEAPI[TODO]
% 
%Author: J. Roychowdhury, 2014/12/22-24

% begin argument/default processing
    if nargin < 2
        error('add_output requires at least two arguments: cktdata and unk1');
    end

    scale = 1;
    otherargs = {};
    scale_found = 0;
    j = 0; % counter for otherargs
    for i=1:length(varargin)
        if ~isempty(varargin{i}) && isnumeric(varargin{i}) && ~scale_found
            scale = varargin{i};
            scale_found = 1;
        elseif ~isempty(varargin{i}) && isnumeric(varargin{i}) && scale_found
            error('add_output: you seem to have specified more than 1 scale argument; not supported');
        else
            j = j+1;
            otherargs{j} = varargin{i};
        end
    end

    if length(otherargs) < 1 
        unk2 = [];   
    else
        unk2 = otherargs{1};   
    end
    
    if length(otherargs) < 2
        if isempty(unk2)   
            oname = unk1;
            if scale ~= 1
                oname = sprintf('%g*%s', scale, oname);
            end
        else
            oname = sprintf('%s-%s', unk1, unk2);
            if scale ~= 1
                oname = sprintf('%g*(%s)', scale, oname);
            end
        end
    else
        oname = otherargs{2};
    end
% end argument/default processing

    % initialize cktdata.outputs if it doesn't exist
    if ~isfield(cktdata, 'outputs')
        cktdata.outputs = {};
    end

    % process unk1 string
    unk1 = strtrim(unk1); % remove insignificant spaces
    if ~isempty(regexpi(unk1, 'i\(.*\)'))
        iscurrent1 = 1;
        elementname1 = regexprep(unk1, 'i\((.*)\)', '$1', 'ignorecase');
    elseif ~isempty(regexpi(unk1, '[ve]\(.*\)'))
        iscurrent1 = 0;
        nodename1 = regexprep(unk1, '[ve]\((.*)\)', '$1', 'ignorecase');
    else
        iscurrent1 = 0;
        nodename1 = unk1;
    end

    % process unk2 string
    if ~isempty(unk2)
        unk2 = strtrim(unk2); % remove insignificant spaces
        if ~isempty(regexpi(unk2, 'i\(.*\)'))
            iscurrent2 = 1;
            elementname2 = regexprep(unk2, 'i\((.*)\)', '$1', 'ignorecase');
        elseif ~isempty(regexpi(unk2, '[ve]\(.*\)'))
            iscurrent2 = 0;
            nodename2 = regexprep(unk2, '[ve]\((.*)\)', '$1', 'ignorecase');
        else
            iscurrent2 = 0;
            nodename2 = unk2;
        end
    end

    % set up a table of element names if unk1/2 is a current
    if 1 == iscurrent1 || (~isempty(unk2) && 1 == iscurrent2)
        for i = 1:length(cktdata.elements)
            elnames{i} = cktdata.elements{i}.name;
        end
    end

    allnodenames = cktdata.nodenames;
    allnodenames{end+1} = cktdata.groundnodename;

    % check if unk1 already exists in cktdata, issue error if not
    if 1 == iscurrent1
        elidx1 = find(strcmp(elnames, elementname1));
        if length(elidx1) ~= 1
            error(sprintf('add_output: element %s not found exactly once in cktdata.elements', elementname1));
        end
    else
        nodeidx1 = find(strcmp(allnodenames, nodename1));
        if length(nodeidx1) ~= 1
            error(sprintf('add_output: node %s not found exactly once in cktdata.{nodenames union groundnodename})', nodename1));
        end
    end

    % check if unk2 already exists in cktdata, issue warning if not
    if ~isempty(unk2)
        if 1 == iscurrent2
            elidx2 = find(strcmp(elnames, elementname2));
            if length(elidx2) ~= 1
                error(sprintf('add_output: element %s not found exactly once in cktdata.elements', elementname2));
            end
        else
            nodeidx2 = find(strcmp(allnodenames, nodename2));
            if length(nodeidx2) ~= 1
                error(sprintf('add_output: node %s not found exactly once in cktdata.{nodenames union groundnodename}', nodename2));
            end
        end
    end

    % NOTE: we don't check the type of element, how many nodes, etc. - that's
    % the equation engine's job

    % set up the output entry
    if 1 == iscurrent1
        unk1entry{1} = 'i';
        unk1entry{2} = elnames{elidx1};
    else
        unk1entry{1} = 'e';
        unk1entry{2} = allnodenames{nodeidx1};
    end
    outputentry = {oname, scale, unk1entry};

    if ~isempty(unk2)
        if 1 == iscurrent2
            unk2entry{1} = 'i';
            unk2entry{2} = elnames{elidx2};
        else
            unk2entry{1} = 'e';
            unk2entry{2} = allnodenames{nodeidx2};
        end
        outputentry{4} = unk2entry;
    end

    % search through existing output names, replace if output exists
    for i=1:length(cktdata.outputs)
        if 1==strcmp(cktdata.outputs{i}{1}, oname)
            warning(sprintf('add_output: replacing existing output %s', oname));
            cktdata.outputs{i} = outputentry;
            return;
        end
    end

    % otherwise, append a new output
    cktdata.outputs{end+1} = outputentry;
end
%Author: J. Roychowdhury, 2014/12/22-24
