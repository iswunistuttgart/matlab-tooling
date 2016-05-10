function coeffs = polyTrajecCoeffs(SystemOrder)

coeffs = zeros(1, SystemOrder + 1);

switch SystemOrder
    case 1
        coeffs = horzcat(coeffs, [3, -2]);
    case 2
        coeffs = horzcat(coeffs, [10, -15, 6]);
    case 3
        coeffs = horzcat(coeffs, [35, -84, 70, -20]);
    case 4
        coeffs = horzcat(coeffs, [126, -420, 540, -315, 70]);
    case 5
        coeffs = horzcat(coeffs, [462, -1980, 3465, -3080, 1386, -252]);
    case 6
        coeffs = horzcat(coeffs, [1716, -9009, 20020, -24024, 16380, -6006, 924]);
    case 7
        coeffs = horzcat(coeffs, [6435, -40040, 108108, -163800, 150150, -83160, 25740, -3432]);
    otherwise
        error('Unsupported system order givne');
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
