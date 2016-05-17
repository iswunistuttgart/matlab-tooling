function test_rotm2row()

% How many random matrices to create?
nMatrices = round(rand(1)*1000);

% Placeholder
aRotations_Matrix = zeros(3, 3, nMatrices);
aRotations_RowEx = zeros(nMatrices, 9);

% Build a variable size matrix
for iMatrix = 1:nMatrices
    % Matrix entries are the regular 11, 12, 13, 21, 22, 23, 31, 32, 33 ...
    aRotations_Matrix(:,:,iMatrix) = [11, 12, 13; ...
        21, 22, 23; ...
        31, 32, 33];
    % ... but shifted by the current row number times 100
    aRotations_Matrix(:,:,iMatrix) = aRotations_Matrix(:,:,iMatrix) + iMatrix*100;
    
    % Also bild the expected matrix row
    aRotations_RowEx(iMatrix,:) = [aRotations_Matrix(1,1,iMatrix), aRotations_Matrix(1,2,iMatrix), aRotations_Matrix(1,3,iMatrix), ...
                                    aRotations_Matrix(2,1,iMatrix), aRotations_Matrix(2,2,iMatrix), aRotations_Matrix(2,3,iMatrix), ...
                                    aRotations_Matrix(3,1,iMatrix), aRotations_Matrix(3,2,iMatrix), aRotations_Matrix(3,3,iMatrix)];
end

% Do the transformation
aRotations_RowIs = rotm2row(aRotations_Matrix);

% And assert that all entries in the 'is'-matrix are the same as in the
% 'ex'-matrix
try
    assert(all(all(aRotations_RowIs == aRotations_RowEx)));
    
    cprintf('green', 'Test passed successfully\n');
catch me
    cprintf('err', [me.message , '\n']);
end

end