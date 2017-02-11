function h = cross(u,v)
  %VECVALDER/CROSS overloads cross with at least one vecvalder object argument
  % u and v are of size 3-by-1
  if ~isa(u,'vecvalder') %u is a vector of scalars
    n = size(v(1).der,2);
	hder = [];
	vder = der2mat(v);
	for c = 1:n
		hder = [hder, cross(u,vder(:,c))];
	end
    h = vecvalder(cross(u,val2mat(v)), hder);
  elseif ~isa(v,'vecvalder') %v is a vector of scalars
    n = size(u(1).der,2);
	hder = [];
	uder = der2mat(u);
	for c = 1:n
		hder = [hder, cross(uder(:,c),v)];
	end
    h = vecvalder(cross(val2mat(u), v), hder);
  else % u and v are both vecvalder objs
    n = size(u(1).der,2);
	hder = [];
	uder = der2mat(u);
	vder = der2mat(v);
	for c = 1:n
		hder = [hder, cross(uder(:,c),val2mat(v)) + cross(val2mat(u),vder(:,c))];
	end
    h = vecvalder(cross(val2mat(u), val2mat(v)), hder);
  end
end

