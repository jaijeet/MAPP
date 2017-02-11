function [output_names, output_matrix] = DAE_outputs_from_circuitdata(DAE, MNAorSTA)
%function [output_names, output_matrix] = DAE_outputs_from_circuitdata(DAE, MNAorSTA)
%This is used by MNA_EqnEngine and STA_EqnEngine to set up DAE outputs from
%circuitdata.outputs. UTSL.
%

%Author: J. Roychowdhury, 2014/12/24

    if ~isfield(DAE.circuitdata,'outputs') || 0==length(DAE.circuitdata.outputs)
        % if no outputs selected, every unk is an output
        output_names = DAE.unk_names;
        output_matrix = speye(DAE.n_unks, DAE.n_unks);
    else
        j = 1; % row index of DAE.output_names and DAE.output_matrix
        for i=1:length(DAE.circuitdata.outputs)
            oname = DAE.circuitdata.outputs{i}{1};
            oscale = DAE.circuitdata.outputs{i}{2};
            unk1entry = DAE.circuitdata.outputs{i}{3};

            output_matrix_row = setup_output_matrix_row(oname, unk1entry, DAE, MNAorSTA);
            if isempty(output_matrix_row)
                continue; % empty means output should be ignored
            end

            if (length(DAE.circuitdata.outputs{i}) > 3)
                unk2entry = DAE.circuitdata.outputs{i}{4};
                output_matrix_row_2 = setup_output_matrix_row(oname, ...
                                                            unk2entry, DAE, MNAorSTA);
                if isempty(output_matrix_row_2)
                    continue; % empty means output should be ignored
                end
                output_matrix_row = output_matrix_row - output_matrix_row_2;
            end

            output_names{j} = oname;
            output_matrix(j,:) = oscale*output_matrix_row;
            j = j+1;
        end % for i=1:length(DAE.circuitdata.outputs)
    end % if 0==length(DAE.circuitdata.outputs)
end %function [output_names, output_matrix] = DAE_outputs_from_circuitdata(DAE, MNAorSTA)
% END set up DAE outputs from circuitdata.outputs

function output_matrix_row = setup_output_matrix_row(oname, unkentry, DAE, MNAorSTA)
%function output_matrix_row = setup_output_matrix_row(oname, unkentry, DAE, MNAorSTA)
%private function, called from above
%sets up a row of C corresponding to an output given by unkentry.
%returns [] if the output does not correspond to an MNA unknown.
%see the main function above to see how it is used.
    output_matrix_row(1,DAE.n_unks) = 0; % get the size right
    if 1==strcmp(unkentry{1}, 'e') % node voltage output
        nodename = unkentry{2};
        if ~strcmp(nodename, DAE.circuitdata.groundnodename)
            % no need to do anything if ground node
            node_unk = strcat('e_', nodename);
            idx = find(strcmp(node_unk, DAE.unk_names));
            if 1==length(idx) % found the unknown
                output_matrix_row(1,idx) = 1;
            else
                error(sprintf('%s_EqnEngine output setup for %s: node unknown %s not found exactly once in unk_names', MNAorSTA, oname, node_unk));
            end
        end
    elseif 1==strcmp(unkentry{1}, 'i') % branch current output
        elname = unkentry{2};
        prefix = sprintf('%s%s', elname, DAE.separatorString);
        idx = find( strcmp(elname, DAE.element_names) );
        if 1==length(idx) % found the element
            % check if it is a two-terminal element
            the_element = DAE.circuitdata.elements{idx};
            if length(the_element.nodes) ~= 2
                error(sprintf('%s_EqnEngine output setup for %s: element %s is not 2 terminal', MNAorSTA, oname, elname));
            end
            % then check if there is a current unknown, using the facts
            % that only current otherIOs become MNA unknowns, and that
            % all branch currents in IOnames become STA unknowns. Make sure
            % there is only ONE current unknown.

            i_count = 0;
            if strcmp(MNAorSTA, 'MNA')
                IO_unks = the_element.model.OtherIO_names;
            elseif strcmp(MNAorSTA, 'STA')
                IO_unks = the_element.model.IO_names;
            else
                error(sprintf('There is no %s_EqnEngine; only MNA_EqnEngine and STA_EqnEngine!', MNAorSTA));
            end
            for k=1:length(IO_unks)
                if regexp(IO_unks{k}, '^i')
                    i_idx = k;
                    i_count = i_count + 1;
                end
            end
            if 1 == i_count
                ibr_unk = sprintf('%s%s', prefix, IO_unks{i_idx}); 
                                % looks like L1:::ipn
                idx = find(strcmp(ibr_unk, DAE.unk_names));
                if 1==length(idx) % found the unknown
                    output_matrix_row(1,idx) = 1;
                else
                    error(sprintf('%s_EqnEngine output setup for %s: current unknown %s not found exactly once in unk_names', MNAorSTA, oname, ibr_unk));
                end
            else
                msg = sprintf('%s_EqnEngine output setup for %s: element %s does not have exactly one current unknown', MNAorSTA, oname, elname);
                if strcmp(MNAorSTA, 'MNA')
                    warning(sprintf('%s: ignoring this output.', msg));
                else % STA
                    error(sprintf('%s: not supported.', msg));
                end
                output_matrix_row = [];
            end
        else
            error(sprintf('%s_EqnEngine output setup for %s: element %s not found exactly once', MNAorSTA, oname, elname));
        end
    else % if 1==strcmp(unkentry{1}, 'e') elseif 1==strcmp(unkentry{1}, 'i') 
        error(sprintf('%s_EqnEngine output setup for %s: illegal output type %c', MNAorSTA, oname, unkentry{1}));
    end % if 1==strcmp(unkentry{1}, 'e') elseif 1==strcmp(unkentry{1}, 'i') 
end % setup_output_matrix_row
