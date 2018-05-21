# MATLAB Tooling

A collection of useful functions and scripts that make working with MATLAB a breeze and even more efficient.

Care to know what this package is providing? Check out the [list of functions](FUNCTIONS.md) giving you a quick overview of all the functions available.

### On notation of matrices (aka. **row/column issue**)

I like to think of MATLAB dealing with the row/column issue as saying that columns contain different variables, and rows contain different observations of those variables. Thus, the rows might be different observations in time of three different temperatures, which are represented in columns A, B, and C. This is consistent with MATLAB's behaviour for sum, mean, etc., which produce "the sum of all my observations for each variable".

### On `numel` vs `length`

IMHO from a code readability viewpoint, `length` should be used on one-dimensional arrays. It is about "intentional programming", you see the code and understand what programmer had in mind when conceiving his work. So when I see `numel` I know it is used on a matrix.
@see https://stackoverflow.com/questions/3119739/difference-between-matlabs-numel-and-length-functions
