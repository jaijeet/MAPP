%  This is the MAPP quickstart guide. This script takes users
%  through a step-by-step process to perform transient analysis on an RC
%  circuit in MAPP framework. 
fprintf('\n\nWelcome to MAPP Quickstart guide.\n')
fprintf('This script guides users through a step-by-step process to perform transient analysis on the\n');
fprintf('following RC circuit in MAPP framework.\n\n');

fprintf('        -------/\\/\\/\\/\\---------\n');
fprintf('        |e1       R          e2|\n');
fprintf('        |                      |\n');
fprintf('        |                      | C\n');
fprintf('     .--!--.                 --!--\n');
fprintf('     | ac  | v1=Vo sin(wt)   -----\n');
fprintf('     *-----*                   |\n');
fprintf('        |                      |\n');
fprintf('        |                      |\n');
fprintf('        |     v1:::ipn -->     |\n');
fprintf('        |----------------------| \n\n');

fprintf('First, a DAE object representing the circuit needs to be created (see Tutorial 1: <link>).');
fprintf('To create the DAE object for the given RC circuit, type the following at the prompt\n\n');
fprintf('       MNAEqnEngine_vsrcRC <ENTER>\n');
prompt='\n>>';
correct_input=false;
% Remove any whitespaces
str1=regexprep(input(prompt,'s'),'[^\w'']','');
while ~correct_input
        if strcmp(str1,'MNAEqnEngine_vsrcRC')
                correct_input=true;
        else
                fprintf('Wrong input! Type "MNAEqnEngine_vsrcRC" (without quotes) and then, press ENTER key.');
                % Remove any whitespaces
                str1=regexprep(input(prompt,'s'),'[^\w'']','');
        end
end
fprintf('\nCreating DAE object...\n\n');
eval(str1)
fprintf('A MATLAB DAE object representing the RC circuit was created. Now we can do various analysis on this object. ')
fprintf('Let us first do a transient analysis on this DAE object. ');
fprintf('To create an LMS object for the given RC circuit, type the following at the prompt\n\n');
fprintf('TransObjBE = LMS(DAE);\n');
prompt='\n>>';
correct_input=false;
% Remove any whitespaces
str1=regexprep(input(prompt,'s'),'[^\w\(\)=;'']','');
str1
while ~correct_input
        if strcmp(str1,'TransObjBE=LMS(DAE);') || strcmp(str1,'TransObjBE=LMS(DAE)')
                correct_input=true;
        else
                fprintf('Wrong input! Type the following at the prompt\n\n');
                fprintf('TransObjBE = LMS(DAE);\n');
                % Remove any whitespaces
                str1=regexprep(input(prompt,'s'),'[^\w=\(\);'']','');
        end
end
fprintf('\nCreating LMS object...\n\n');
eval([str1 ';'])
fprintf('Created LMS Object ...\n\n');
% run transient and plot
xinit = zeros(feval(DAE.nunks,DAE),1);
tstart = 0;
tstep = 10e-6;
tstop = 5e-3;

fprintf('Start time %d, Time step %d, and Stop time %d\n\n', tstart,tstep,tstop);
fprintf('Running transient simulation on the given RC circuit (using Backward Euler algorithm)\n');
pause(5)
TransObjBE = feval(TransObjBE.solve, TransObjBE, ...
        xinit, tstart, tstep, tstop);
[thefig, legends] = feval(TransObjBE.plot, TransObjBE);
