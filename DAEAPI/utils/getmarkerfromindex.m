function marker = getmarkerfromindex(i)
%function marker = getmarkerfromindex(i)
%cycles through the following markers
% .     point              
% o     circle             
% x     x-mark              
% +     plus                 
% *     star           
% s     square
% d     diamond
% v     triangle (down)
% ^     triangle (up)
% <     triangle (left)
% >     triangle (right)
% p     pentagram
% h     hexagram
%
%Examples
%--------
% marker = getmarkerfromindex(5);
% plot(1:10, 10:1, 'Marker', marker);
%
%See also
%--------
%
% getcolorfromindex
%
%
%Author: Jaijeet Roychowdhury <jr@berkeley.edu>

	markers = {'.', 'o', 'x', '+', '*', 's', 'd', 'v', ...
			'^', '<', '>', 'p', 'h'};
	i = mod(i, length(markers)) + 1;
	marker = markers{i};
end
