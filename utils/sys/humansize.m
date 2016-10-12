function Human = humansize(SizeNumber, Decimals, Step)

% Default decimals
if nargin < 2
    Decimals = 2;
end

% Default stepsize (let user choose whether they want 1000 or 1024 as base size
if nargin < 3
    Step = 1024;
end

dStep = Step;

% These are the valid sizes that are available. Anything larger than 1024 YB
% will be parsed still as YB
ceSizes = {'B', 'kB', 'MB' ,'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'};

% Assume everything in bytes
nSize = 1;

% Loop over the given size and devide it by the step 
while ( SizeNumber/dStep ) > 0.9 && nSize < numel(ceSizes)
    SizeNumber = SizeNumber./dStep;
    nSize = nSize + 1;
end

% Parse the human readable size
Human = sprintf(sprintf('%%.%df %%s', Decimals), round(SizeNumber, Decimals), ceSizes{nSize});

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
