% Proposed changes to circuit netlists for 1) more efficient model support
% (ie, keep ONE copy of the ModSpec model) and 2) model/element separation
% 2014/06/26, sitting w Tianshi.

	MVS_Model = MVS_1_0_1_ModSpec();

    % nmosElem
    subcktnetlist = add_model(subcktnetlist, 'standardCap', CapModSpec); % make this pre-defined and global (ie, top-level and subckts)
                                                                         % and accessible with names 'cap', 'CAP', 'C', 'c', etc.
                                                                         % Similarly for R, L, VSRC, ISRC, xCyS

    subcktnetlist = add_model(subcktnetlist, 'someMODname', MVS_Model, {{'Type', 1}, {'W', 1e-4}, {'Lgdr', 32e-7}, {'dLg', 9e-7}, ...
                                {'Cg', 2.57e-6}, {'Beta', 1.8}, {'Alpha', 3.5}, {'Tjun', 300}, {'Cif', 1.38e-12}, {'Cof', 1.47e-12},...
   	                            {'phib', 1.2}, {'Gamma', 0.1}, {'mc', 0.2}, {'CTM_select', 1}, {'Rs0', 100}, {'Rd0', 100}, ...
                                {'n0', 1.68}, {'nd', 0.1}, {'vxo', 1.2e7}, {'Mu', 200}, {'Vt0', 0.4}, {'delta', 0.15}}); 
                                % just a basic ModSpec model, like we have now

    % use Containers.map() to create a table internally of modelname vs the actual ModSpec structure
    % see http://stackoverflow.com/questions/3591942/hash-tables-in-matlab
    %
    % alternatively, recent versions of MATLAB do support pointers as part of the OO HANDLE superclass, though these are
    % not supported in Octave yet; one could use those. See
    % http://www.mathworks.com/matlabcentral/answers/46884-is-there-something-like-a-struct-pointer-in-matlab

    subcktnetlist = add_model(subcktnetlist, 'someMODname2', 'someMODname', {{'W', 0.1}, {'L', 2}}); % model vs element separation
    subcktnetlist = add_element(subcktnetlist, 'someMODname2', 'NMOS', {'out', 'in', 'gnd', 'gnd');
