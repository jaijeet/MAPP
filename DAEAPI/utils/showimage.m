function showimage(filename)
%function showimage(filename)
	%exist --> 2
	if 2 == exist(filename)
		x = imread(filename);
		% image(x);
		figure; 
		imshow(x);
		colormap('gray');
	else
		fprintf('showimage: %s not found.\n', filename);
	end
end
