function out = createOrderedMatrix(A,B)
% Created an ordered tuple from matrix A and B
% Call it recursively to more than two matrices

% Create a reverse ordered matrix B
flippedB = flipud(B);
noOfRowsA = size(A,1);
noOfRowsB = size(B,1);
% Keep track of ordering in B
keepTrack = 1;
out1 = [];
for count1 = 1:1:noOfRowsA
    if keepTrack > 0.5
        whichB = B;
    else
        whichB = flippedB;
    end
    out2 = [];
    for count2 = 1:1:noOfRowsB
        out2 = [ out2; A(count1,:),whichB(count2,:)];
    end
    out1 = [ out1 ; out2];
    keepTrack = ~keepTrack;
end
out = out1;


