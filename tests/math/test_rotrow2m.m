function test_rotrow2m()

% How many random matrices to create?
nRows = round(rand(1)*1000);

% Placeholder
aRotations_Row = zeros(nRows, 9);
aRotations_MatEx = zeros(3, 3, nRows);

% Build a variable size matrix
for iRow = 1:nRows
    % Matrix entries are the regular 11, 12, 13, 21, 22, 23, 31, 32, 33 ...
    aRotations_Row(iRow,:) = [11, 12, 13, ...
        21, 22, 23, ...
        31, 32, 33];
    % ... but shifted by the current row number times 100
    aRotations_Row(iRow,:) = aRotations_Row(iRow,:) + iRow*100;
    
    % Also bild the expected matrix row
    aRotations_MatEx(:,:,iRow) = [aRotations_Row(iRow,1), aRotations_Row(iRow,2), aRotations_Row(iRow,3); ...
                                    aRotations_Row(iRow,4), aRotations_Row(iRow,5), aRotations_Row(iRow,6); ...
                                    aRotations_Row(iRow,7), aRotations_Row(iRow,8), aRotations_Row(iRow,9)];
end

% Do the transformation
aRotations_MatIs = rotrow2m(aRotations_Row);

% And assert that all entries in the 'is'-matrix are the same as in the
% 'ex'-matrix
try
    assert(all(all(all(aRotations_MatIs == aRotations_MatEx))));
    
    cprintf('green', 'Test passed successfully\n');
catch me
    cprintf('err', [me.message , '\n']);
end


end