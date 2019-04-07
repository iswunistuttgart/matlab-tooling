# Typesetting of MATLAB data in LaTeX documents

This only applies to documents written in LaTeX. Your mileage may vary in Word or other document writing apps.

Imagine we have some array of size `NxM` in our MATLAB workspace that we want to have output in a LaTeX document.
The easiest, and most automated way to have this array (and later changes) in our LaTeX document is by writing it to a file and `input`ing this later in our LaTeX document.
That makes sense, right?
Here's the problem: do we have to write all of LaTeX' `table` markup when we export the array to a file?
That's quite cumbersome, that's why there's a fancy, less typing, and more straight-forward automated way.

We shall make use of MATLAB's `writetable` (or `writematrix`) functions and LaTeX' `pgfplotstable` package.
MATLAB will simply write the array to a file (I prefer to use file extension `.dat` denoting a `dat`a file), and in LaTex, we need a little bit of markup to output the file.

To write your MATLAB array to a file, simply call
```matlab
% Our data array be called A
A = rand(10, 3);
% Write array as delimited string to a file
writematrix(A, 'A.dat', 'Delimiter', ',', 'Encoding', 'UTF-8')
```
The last line writes the array to a file called `file.dat` in your current working directory.
Each entry will be separated by `'Delimiter'`, which we set to be `','` i.e., we actually obtain a CSV file.
To be fully compatible will all OS', we set the file's `'Encoding'` to be `'UTF-8'`, but you may choose any of the available encodings.

Our directory should now contain a file called `A.dat` next to which we create a LaTeX file `A.tex`.
This file contains, at the bare minimum

```latex
\documentclass{article}

\usepackage{pgfplotstable}

\begin{document}

\pgfplotstabletypeset[%
    col sep=comma,%
  ]{A.dat}

\end{document}
```
Option `col sep=comma` is required since we used `'Delimiter', ','` in our MATLAB export.
Had we used MATLAB's default delimiter `'\t'` (tabs), then we would not have required to pass this option to `\pgfplotstabletypeset`.
Now run `latexmk A` or whichever way you prefer to compile your LaTeX documents, and you have the table typeset right away.

If you want column headers, these must of course exist in file `A.dat`; but how to get them there since array `A` does not have column names?
I prefer to convert my MATLAB `array` into a MATLAB `table` with the appropriate column names, and then export this table as `.dat` file.
To obtain a table from your array and write it to a file, follow these lines
```matlab
% Our data array be called A
A = rand(10, 3);
% Convert to table
T = array2table(A, 'VariableNames', {'col1', 'col2', 'col3', 'col4'});
% Write array as delimited string to a file
writematrix(T, 'A.dat', 'Delimiter', ',', 'Encoding', 'UTF-8')
```
where the cell array of `'VariableNames'` contains one entry per column of `A`.
Now you can simply run `latexmk A` again (since typesetting of the table has not changed, only its data), and you should now see the table with column headers in your document.

For more customization of table typesetting, refer to [pgfplotstable's CTAN page](https://ctan.org/pkg/pgfplotstable).
You can even combine `pgfplotstable` with `siunitx`, pretty cool.
