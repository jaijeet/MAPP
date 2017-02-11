function NR_results = NR(fhandle, dfhandle, initguess, DAE, NRparms)
%function [solution, iters, success] =
%NR(fhandle,dfhandle,initguess,DAE,NRparms)
%
%Run a Newton-Raphson to solve feval(fhandle,x,feval(DAE.uQSS,DAE),DAE) = 0. Convergence
%must be checked using BOTH a reltol-abstol criterion on norm(deltax) AND
%an absolute tolerance residualtol on norm(f(x)).
%
%Input arguments:
%	fhandle: feval(fhandle,x,feval(DAE.uQSS,DAE),DAE) evaluates f(x) 
%       dfhandle: feval(dfhandle,x,feval(DAE.uQSS,DAE), DAE) returns df/dx, the Jacobian matrix.
%	initguess: initial guess for Newton-Raphson. 
%       DAE: passed to fhandle and dfhandle when they are called, as described above.
%
%	The fifth input argument, NRparms,  should be a struct with the following fields:
%
%       NRparms.maxiter;
%       NRparms.reltol;
%       NRparms.abstol;
%       NRparms.residualtol;
%
%Return values:
%	solution: the NR solution if converged; NaN if not converged. iters:
%	the number of iterations taken. success: 1 if converged, 0 if not
%	converged.
%
    maxiter=NRparms.maxiter;
    reltol=NRparms.reltol;
    abstol=NRparms.abstol;
    residualtol=NRparms.residualtol;


disp('Entering Newton Raphson...');

%Check if initguess is a vector

disp(sprintf('The initial guess is a %d X %d matrix',size(initguess,1),size(initguess,2)));
if (size(initguess,2)~=1)
    disp(sprintf('The initial guess should be a vector, not a %d X %d matrix',...
        size(initguess,1),size(initguess,2)));
    disp('Existing Newton-Raphson...');
    return;
end

%Check if g(x0) is a vector
f0=feval(fhandle,initguess,feval(DAE.uQSS,DAE),DAE);
disp(sprintf('The value of f(x) evaluated at initial guess is a %d X %d matrix',...
    size(f0,1),size(f0,2)));
if (size(f0,2)~=1)
    disp(sprintf('f(0) should be a vector, not a %d X %d matrix',...
        size(f0,1),size(f0,2)));
    disp('Existing Newton-Raphson...');
    return;
end

%Check if Jf(x0) is a square matrix
Jf0=feval(dfhandle,initguess,feval(DAE.uQSS,DAE),DAE);
disp(sprintf('The value of Jf(x0) is a %d X %d array',...
    size(Jf0,1),size(Jf0,2)));
if (size(Jf0,1)~=size(Jf0,2))
    disp(sprintf('Jf(0) should be a square matrix, not a %d X %d matrix',...
        size(Jf0,1),size(Jf0,2)));
    disp('Exiting Newton-Raphson...');
    return;
end


% If the norm of g(x)<residualtol initially, there is no need for search
if norm(f0)<residualtol
    disp(sprintf('The norm of f(0) is %d,\nwhich is less than residualtol (%d)',...
        norm(f0),residualtol));
    disp('Newton-Raphson will not search for solution and return the intial guess as solution');
end

iters=0; %Initial iter value
x=initguess; % Initial solution is same as initial guess
%Initial delta_x is set to 10 times of convergence criterion
delta_x=ones(size(initguess))*10*(reltol*norm(initguess)+abstol);
% Convergence criterion 1
conv_criterion_1=(norm(delta_x)>(reltol*norm(initguess)+abstol));
% Convergence criterion2 
conv_criterion_2=(norm(feval(fhandle,x,feval(DAE.uQSS,DAE), DAE))>(residualtol));

% Newton Raphson starts...

while (conv_criterion_1 ||conv_criterion_2) && (iters<maxiter)
        f=feval(fhandle,x,feval(DAE.uQSS,DAE),DAE);
        Jf=feval(dfhandle,x,feval(DAE.uQSS,DAE),DAE);
        delta_x=-Jf\f; % solving the NR eqn : Jf(x)*delta_x=-g(x)
        x=x+delta_x; %update the solution
        % Update the convergence criterions
        conv_criterion_1=(norm(delta_x)>(reltol*norm(x)+abstol));
        conv_criterion_2=(norm(feval(fhandle,x,feval(DAE.uQSS,DAE),DAE))>(residualtol));
        iters=iters+1 % one iteration more !

        if iters==maxiter &&conv_criterion_1 && conv_criterion_2
                error('Max iterations completed. NR failed to converge');
        end
        disp(sprintf('Iteration #%d',iters));
        disp(sprintf('Norm of x = %d',norm(x)));
        disp(sprintf('Norm of delta_x = %d',norm(delta_x)));
        disp(sprintf('Norm of Jx = %d',norm(Jf)));
        disp(sprintf('Norm of f(x) = %d',norm(f)));
end

% end of Newton Raphson ...

% Check if solution has converged:
if conv_criterion_1 && conv_criterion_2
    solution=NaN;
    success=0;
else    
    solution=x;
    success=1;
end

% Make the output structure
NR_results.solution=solution;
NR_results.success= success;
NR_results.iters=iters;
