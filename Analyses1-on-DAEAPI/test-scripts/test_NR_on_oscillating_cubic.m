% from https://www.wolframalpha.com/input/?i=Use+Newton%27s+method+to+solve+-0.75+%2B+0.78+*+x+%2B+1.1+*+x%5E2+-+3.6+*+x%5E3+%3D+0+with+x0+%3D+0.6,
% sent by Mehrdad Niknami

% but this converges
ghandle = @(x, args) -0.75 + 0.78 * x + 1.1 * x.^2 - 3.6 * x.^3;
dghandle = @(x, args) 0.78 + 1.1*2*x - 3.6*3*x.^2;
%initguess = 0.6;
initguess = 0.57;
g_domain_pts = (0:100)/100*2 -1; % 101 pts over [-1, 1] 
g_args = [];
arrow_width = 0.1;




%ghandle = @(x, args) -0.74 + 0.78 * x + 1.1 * x^2 - 3.5637491 * x^3;

%Also, regarding Newton's method, when I try it on the equation
%       f(x) = -0.74 + 0.78 x + 1.1 x2 - 3.55 x3
%it oscillates between these 6 guesses (see plot attached): 0.54402448,
%0.066050058, 0.84514356, 0.55565326, 0.10767046, 0.8326408
ghandle = @(x, args) -0.74 + 0.78 * x + 1.1 * x.^2 - 3.55 * x.^3;
dghandle = @(x, args) 0.78 + 1.1*2*x - 3.55*3*x.^2;
initguess = 0.54402448;
g_domain_pts = (0:100)/100; % 101 pts over [0, 1] 
g_args = [];
arrow_width = 0.6;




NRparms = defaultNRparms(); NRparms.maxiter = 100; NRparms.dbglvl = 3;
[sol, iters, success, allpts] = NR(ghandle, dghandle, initguess, [], NRparms);

% turn this into plot_NR_track(ghandle, dghandle, g_args, g_domain_pts,
%                                                           allpts, arrow_width)

if size(allpts, 1) ~= 1
    error('plot_NR_track supports only scalar equations');
end

for i = 1:length(g_domain_pts)
    gee(i) = feval(ghandle, g_domain_pts(i), g_args);
end

figure();
plot(g_domain_pts, gee, 'b-');
hold on;

for i=1:size(allpts, 2)
    gs(i) = feval(ghandle, allpts(:,i), g_args); 
    if i>1
        arrow3([allpts(i-1), gs(i-1)], [allpts(i), gs(i)], 'x', arrow_width);
    end
end

grid on;
xlabel 'x'; ylabel 'g(x)'; title 'NR track';
drawnow;
