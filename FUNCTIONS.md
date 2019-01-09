# List of functions

## dae/
  * `betsch`: implements BETSCH's ODE time-stepping scheme for mechanical systems
  * `Betsch_pend`: 
  * `Betsch_twoMass`: 
  * `daeget`: Get DAE OPTIONS parameters.
  * `daeproblem`: creates a DAE problem structure
  * `daeset`: Create/alter ODE OPTIONS structure.
  * `discrderiv`: calculates the discrete derivative of a scalar function F
  * `fourbarlinkage_dae_constraintsq`: FOURBARLINKAGE_DAE_CONSTRAINTSQ
  * `fourbarlinkage_dae_jconstraintsq`: FOURBARLINKAGE_DAE_JCONSTRAINTSQ
  * `fourbarlinkage_generator`: GENERATOR for the dynamics models of the four-bar linkage
  * `fourbarlinkage_geo_nodes`: FOURBARLINKAGE_GEO_NODES
  * `fourbarlinkage_ode_forces`: FOURBARLINKAGE_ODE_FORCES
  * `fourbarlinkage_ode_mass`: FOURBARLINKAGE_ODE_MASS
  * `fourbarlinkage_simulate`: SIMULATE the four-bar linkage with different DAE stabilization techniques


## data/
  * `allcomb`: - All combinations
  * `cycliccell`: repeats a cell as a cycle
  * `last`: gets the last element of the given argument
  * `limit`: the given value between minimum and maximum
  * `mat2tex`: converts a matrix to LaTeX compatible tabular syntax
  * `mergestructs`: merges multiple structs into one
  * `parallel_axis_inertia`: determines the inertia of another point O following the
  * `structtime2ts`: Turn a simulink sink "struct with time" to a timeseries data
  * `textable`: is a MATLAB table object that supports export to TeX files
  * `unmatchedcell`: turns the given structure of unmatched IP parameters to a cell


## experiments/
  * `em`: wrapper for exps.manager.instance()


## file/
  * `abspath`: returns an absolute file path for the given arguments
  * `alldirs`: Finds all files in directory DIR and returns them in a structure
  * `allfiles`: Finds all files in directory DIR and returns them in a structure
  * `datastorage`: returns the path to the data storage of this project
  * `emptydir`: empties a directory
  * `escapepath`: 
  * `exppath`: returns the path of the EXPERIMENTS project location
  * `file2cell`: Convert a text file to a cell array of lines.
  * `fullpath`: - Get absolute canonical path of a file or folder
  * `path2cell`: Convert search path to cell array.
  * `path2file`: Write the Matlabpath to a file, one directory on each line.


## func/
  * `_odeget`: ODEGET Get ODE OPTIONS parameters.
  * `_odeset`: ODESET Create/alter ODE OPTIONS structure.
  * `funcname`: returns the current function's name
  * `funcnew`: creates a new function file based on a template
  * `funcren`: renames the function to a new name
  * `isfunction`: - true for valid matlab functions
  * `packageroot`: Determine the root directory of the given package.
  * `parseswitcharg`: parses the toggle arg to a valid and unified char.
  * `runge`: Calculates Runge's function 1 / (1 + x^2) over X
  * `splitaxesargs`: calls axescheck for a list with an object inside


## mat/
  * `aall`: is a wrapper over recursive calls to all(all(all(....)))
  * `ascol`: returns elements of array as column vector
  * `asrow`: ensures the vector is a row vector
  * `asvec`: return elements of array X as a vector
  * `fnsdim`: First non-singleton dimension.
  * `isalnum`: True for alphanumerics (letters and digits).
  * `isalpha`: True for letters.
  * `isascii`: True for decimal digits.
  * `iscolvector`: True for column vector input.
  * `isdigit`: True for decimal digits.
  * `isdivisibleby`: checks if number is divisable by divisor
  * `iseven`: checks the given number(s) for being even
  * `isint`: checks the given value to be of natural numbers
  * `islower`: True for lowercase letters.
  * `ismeshgrid`: determines whether grid might come from meshgrid or not
  * `ismonotonic`: returns a boolean value indicating whether or not a vector is monotonic.  
  * `isnatural`: True for arrays of positive i.e., non-negative natural nmbers.
  * `isodd`: checks the given number(s) for being odd
  * `isposint`: True for positive integers.
  * `isprtchr`: True for printable characters.
  * `isrowvector`: True for row vector input.
  * `issize`: - Check whether the given matrix is of provided size/dimensions
  * `issquare`: - Check whether the given matrix is square
  * `isupper`: True for uppercase letters.
  * `isxdigit`: True for hexadecimal digits.
  * `ord`: returns the ordinal for the given number
  * `tspan`: creates a properly and evenly spaced vector
  * `wraprad`: Map angles measured in radians to the interval [-pi,pi).
  * `xkron`: Kronecker tensor product.


## math/
  * `adjugate`: Calculate the adjugate matrix of A
  * `angle2rotm`: Create Tait-Bryan rotation matrices from rotation angles
  * `bbox`: Calculates the 2D bounding box for the given points
  * `bbox3`: Calculates the 3D bounding box for the given points
  * `binomcoef`: Binomial coefficient.
  * `cart2quadrant`: returns the quadrant of the given Cartesian coordinates
  * `closest`: finds the row and column of the matrix element closest to a given
  * `crossing`: find the crossings of a given level of a signal
  * `evec`: 
  * `evec3`: 
  * `evecn`: Make sure we do not create vectors larger than the specified dimension by
  * `f2w`: turns ordinary frequency into angular frequency
  * `factorial2`: Factorial function.
  * `fibonacci`: Fibonacci numbers.
  * `gausslegendre`: Determine Gauss-Legendre Quadrature abscissae and weights
  * `gcd2`: Greatest common divisor of all elements.
  * `haversin`: creates the haversinersine function of argument z
  * `iseven`: checks the given number(s) for being even
  * `isprime2`: True for prime numbers.
  * `lcm2`: LCMALL Least common multiple of all elements.
  * `loglim`: returns logarithmic limits
  * `mcols`: Count number of columns of matrix A
  * `mmax`: behaves similar to MAX except that it automatically shrinks down to
  * `mmin`: behaves similar to MIN except that it automatically shrinks down to
  * `mnormcol`: Normalize a matrix per column
  * `mnormrow`: Normalize a matrix per row
  * `nrows`: Count number of rows of matrix A
  * `quat2acc`: Get angular acceleration from quaternion velocity, and acceleration
  * `quat2ratem`: Gives the quaternion rate matrices
  * `quat2rotm`: converts quaternions to rotation matrices
  * `quat2rotzyx`: Convert quaternion to Tait-Bryan angle rotation matrix
  * `quat2vel`: Converts quaternion velocity vector to angular velocity vector
  * `reldiff`: Calculate relative difference of X and Y
  * `rot2`: creates the 2D rotation matrix of angles A
  * `rot2d`: ROT2d creates the 2D rotation matrix of angles A given in degree
  * `rotm2row`: converts a 3d rotation matrix to a row
  * `rotmdiff`: determine the difference between two rotation matrices
  * `rotrow2m`: converts a 1d rotation matrix row vector to its matrix representation
  * `rotxsym`: Symbolic rotation matrix about the x-axis
  * `rotysym`: Symbolic rotation matrix about the y-axis
  * `rotzsym`: Symbolic rotation matrix about the z-axis
  * `sigdigits`: Return significant digits in a numeric non-uint64 number
  * `skew2vec`: Convert skew-symmetric matrix into skew-symmetric vector representation
  * `sym_eul2rotm`: Convert symbolic Euler angles to rotation matrix
  * `vec2skew`: Turn the input into its skew-symmetrix matrix form
  * `vec2tens`: converts a vector to its 2d tensor matrix representation.
  * `versin`: calculates the versine of the argument
  * `w2f`: turns angular frequency into ordinary frequency


## ode/
  * `amm`: implements a linear multistep method to solve ODEs with Adamas-Moulton method
  * `bdf`: implements a linear multistep method to solve ODEs with BDF approximation
  * `leapfrog`: implements Leapfrog integration of ODEs
  * `ode1`: Solve differential equations with a non-adaptive method of order 1.
  * `ode2`: Solve differential equations with a non-adaptive method of order 2.
  * `ode3`: Solve differential equations with a non-adaptive method of order 3.
  * `ode4`: Solve differential equations with a non-adaptive method of order 4.
  * `ode5`: Solve differential equations with a non-adaptive method of order 5.
  * `odeprogress`: creates a progress bar window for use as simulation progress info


## optim/
  * `newtonraphson`: Solve set of non-linear equations using Newton-Raphson method.


## plot/
  * `anim2d`: animates 2-dimensional data over time.
  * `anim3d`: animates 3-dimensional data over time.
  * `autosetlims`: automatically sets limits of the curent axis
  * `center_cos`: centers the coordinate system at [0, 0] i.e., moves the axes
  * `circle`: draws a circle of specified radius
  * `circle3`: draws a circle in 3D
  * `cmyk2rgb`: convert CMYK colors to RGB colors
  * `colororder_pre2014b`: returns the color order of plot lines pre R2014b
  * `distinguishableColors`: pick colors that are maximally perceptually distinct
  * `figplot`: opens a figure and plots inside this figure.
  * `gpf`: Get the given handles parent figure
  * `isallaxes`: Checks whether the given handle is purely axes or not
  * `isfig`: checks whether the given handle is a figure handle or not
  * `isplot2d`: Check the given axes against being a 2D plot i.e., created by plot()
  * `isplot3d`: Check the given axes against being a 3D plot i.e., created by plot3()
  * `lame`: plots the LAMÉ superellipses
  * `max_fig`: maximizes the current or given figure
  * `maxplotvalue`: Determine the maximum plotted value along all axes
  * `minplotvalue`: Determine the minimum plotted value along all axes
  * `plot_addPointPlaneIntersection`: Adds intersection indicator for a point on the
  * `plot_colbox`: plots a colored box (patch) for the given color
  * `plot_coordaxes`: Add a frame of reference to the current plot
  * `plot_cyclelinestyles`: adds different line styles to each plot in an axis
  * `plot_houghlines`: plot lines from houghlines
  * `plot_markers`: Plot some markers on the lines given in Axes
  * `plot_zoom`: plots a zoom region into the given axes
  * `plotrange`: Determine the range of plotted data from min to max
  * `point`: Define the input parser
  * `rgb2cmyk`: convert RGB colors to CMYK colors
  * `rgb_darker`: 
  * `rgb_lighter`: 
  * `ruler`: plots a vertical or horizontal ruler at the given position
  * `semilogxy`: plots a 3D plot with logarithmic X- and Y-axis
  * `setfigureratio`: sets the ratio of the current or given figure
  * `shadow3`: plots a 3D shadow3 plot of all data into the given axes onto the given
  * `usdistcolors`: creates distinguishable colors complying with University of
  * `uslayout`: applies the corresponding figure to University of Stuttgarts
  * `uslinestyles`: creates a list of N unique lineseries plot styles
  * `zoomax`: in or out into an axes depending on the scaling factor


## plot/exportfig/
  * `append_pdfs`: Appends/concatenates multiple PDF files
  * `copyfig`: Create a copy of a figure, without changing the figure
  * `crop_borders`: Crop the borders of an image or stack of images
  * `eps2pdf`: Convert an eps file to pdf format using ghostscript
  * `export_fig`: Exports figures in a publication-quality format
  * `fix_lines`: Improves the line style of eps files generated by print
  * `ghostscript`: Calls a local GhostScript executable with the input command
  * `im2gif`: Convert a multiframe image to an animated GIF file
  * `isolate_axes`: Isolate the specified axes in a figure on their own
  * `pdf2eps`: Convert a pdf file to eps format using pdftops
  * `pdftops`: Calls a local pdftops executable with the input command
  * `print2array`: Exports a figure to an image array
  * `print2eps`: Prints figures to eps with improved line styles
  * `read_write_entire_textfile`: Read or write a whole text file to/from memory
  * `user_string`: Get/set a user specific string
  * `using_hg2`: Determine if the HG2 graphics engine is used


## signal/
  * `bump`: Bump function
  * `gauss`: calculates the 1D gaussian function along X
  * `h2r`: converts Hertz to radian per second
  * `heaviside`: Analytic heaviside function at X = 0
  * `r2h`: converts radian per second to Hertz
  * `richard`: Generalized logistics curve or Richards' curve
  * `siggen_difflattraj`: creates a differentially flat trajectory.
  * `siggen_rectangular`: generates a rectangular signal
  * `siggen_sawtooth`: 
  * `siggen_trapezoid`: 
  * `smoothtrans`: Evaluate a smooth transition function at value X


## str/
  * `num2prefix`: converts numbers to their SI unit prefix.
  * `strdist`: computes distances between strings
  * `strlcfirst`: lower cases the frist character of the string(s)
  * `strnatsort`: Alphanumeric / Natural-Order sort the strings in a cell array of strings.
  * `strnatsortfiles`: Alphanumeric / Natural-Order sort of a cell array of filenames/filepaths.
  * `strucfirst`: upper cases the frist character of the string(s)
  * `strucwords`: uppercases each word of the given strings


## symbolic/
  * `deriv`: derives a symbolic expression with respect to another symbolic


## sys/
  * `argstring`: truns a list of arguments into a human-readable string
  * `bytes2str`: turns the number of bytes into a human readable string
  * `computername`: returns the name of the computer in the local network
  * `cprintf`: displays styled formatted text in the Command Window
  * `create_contents`: creates the CONTENTS.M files for this project
  * `create_docs`: creates the docs for project MATLAB-Tooling from each functions'
  * `datestr8601`: Convert a Date Vector or Serial Date Number to an ISO 8601
  * `dispstat`: Prints overwritable message to the command line. If you dont want to keep
  * `focus_cmdwin`: gives focus to the command window
  * `focus_editor`: gives programmatic focus to the editor
  * `humansize`: Default decimals
  * `iif`: Allows conditionals in inline and anonymous functions
  * `isinpath`: Checks whether the given path is part of MATLAB's environment path
  * `matlab_logo`: 
  * `objectcheck`: checks for an object of a calling class in the list of arguments
  * `pack_files_and_dependencies`: packs dependent files into one folder
  * `progressbar`: creates a nicer progress bar window for progress information
  * `restart`: executes a few functions to reset MATLAB workspace
  * `rgb`: converts a conventional RGB representation into MATLAB RGB format
  * `rmpaths`: Remove directory from search path recursively
  * `save_figure`: Saves the figure under the specified filename with variable types
  * `save_ws`: saves the whole workspace to a unique filename 
  * `secs2hms`: Convert seconds to a human readable time format
  * `setrng`: sets the random number generator to a set or pre-defined options
  * `stopalltimers`: stops all timers whether they are visible or not
  * `tsave`: 
  * `username`: returns the current user's username
  * `varsize`: determines the size of each variable given


## twincat/
  * `csv2tcscope`: converts a TwinCat CSV scope file to a TCSCOPE object


