function h = dot(u,v)
  %VECVALDER/DOT overloads dot (with two inputs) with at least one vecvalder
  % object argument
  if ~isa(u,'vecvalder') %u is a vector of scalars
    h = vecvalder(dot(u, val2mat(v)), u' * der2mat(v));
  elseif ~isa(v,'vecvalder') %v is a vector of scalars
    h = vecvalder(dot(val2mat(u), v), v' * der2mat(u));
  else % u and v are both vecvalder objs
    h = vecvalder(dot(val2mat(u), val2mat(v)),...
		val2mat(u)'*der2mat(v) + val2mat(v)'*der2mat(u));
    % n = size(u(1).der,2);
	% hder = [];
	% uder = der2mat(u);
	% vder = der2mat(v);
	% for c = 1:n
	% 	hder = [hder, cross(uder(:,c),val2mat(v)) + cross(val2mat(u),vder(:,c))];
	% end
    % h = vecvalder(cross(val2mat(u), val2mat(v)), hder);
  end
end

