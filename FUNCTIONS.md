# List of functions

## /
  * <kbd>finish</kbd>: shuts down the project
  * <kbd>projpath</kbd>: returns the path definiton for this project
  * <kbd>startup</kbd>: starts this project


## data/
  * <kbd>cycliccell</kbd>: repeats a cell as a cycle
  * <kbd>last</kbd>: gets the last element of the given argument
  * <kbd>limit</kbd>: the given value between minimum and maximum
  * <kbd>mat2tex</kbd>: converts a matrix to LaTeX compatible tabular syntax
  * <kbd>mergestructs</kbd>: merges multiple structs into one
  * <kbd>parallel_axis_inertia</kbd>: determines the inertia of another point O following the
  * <kbd>structtime2ts</kbd>: Turn a simulink sink "struct with time" to a timeseries data
  * <kbd>test_textable</kbd>: 
  * <kbd>textable</kbd>: is a MATLAB table object that supports export to TeX files
  * <kbd>unmatchedcell</kbd>: turns the given structure of unmatched IP parameters to a cell


## experiments/
  * <kbd>em</kbd>: wrapper for exps.manager.instance()


## file/
  * <kbd>abspath</kbd>: returns an absolute file path for the given arguments
  * <kbd>alldirs</kbd>: Finds all files in directory DIR and returns them in a structure
  * <kbd>allfiles</kbd>: Finds all files in directory DIR and returns them in a structure
  * <kbd>datastorage</kbd>: returns the path to the data storage of this project
  * <kbd>emptydir</kbd>: empties a directory
  * <kbd>escapepath</kbd>: 
  * <kbd>exppath</kbd>: returns the path of the EXPERIMENTS project location
  * <kbd>file2cell</kbd>: Convert a text file to a cell array of lines.
  * <kbd>fullpath</kbd>: - Get absolute canonical path of a file or folder
  * <kbd>path2cell</kbd>: Convert search path to cell array.
  * <kbd>path2file</kbd>: Write the Matlabpath to a file, one directory on each line.


## function/
  * <kbd>funcname</kbd>: returns the current function's name
  * <kbd>funcnew</kbd>: creates a new function file based on a template
  * <kbd>funcren</kbd>: renames the function to a new name
  * <kbd>isfunction</kbd>: - true for valid matlab functions
  * <kbd>parseswitcharg</kbd>: parses the toggle arg to a valid and unified char.
  * <kbd>splitaxesargs</kbd>: calls axescheck for a list with an object inside


## mat/
  * <kbd>aall</kbd>: is a wrapper over recursive calls to all(all(all(....)))
  * <kbd>ascol</kbd>: returns elements of array as column vector
  * <kbd>asrow</kbd>: ensures the vector is a row vector
  * <kbd>asvec</kbd>: return elements of array X as a vector
  * <kbd>fnsdim</kbd>: First non-singleton dimension.
  * <kbd>isalnum</kbd>: True for alphanumerics (letters and digits).
  * <kbd>isalpha</kbd>: True for letters.
  * <kbd>isascii</kbd>: True for decimal digits.
  * <kbd>iscolvector</kbd>: True for column vector input.
  * <kbd>isdigit</kbd>: True for decimal digits.
  * <kbd>isdivisibleby</kbd>: checks if number is divisable by divisor
  * <kbd>iseven</kbd>: checks the given number(s) for being even
  * <kbd>isint</kbd>: checks the given value to be of natural numbers
  * <kbd>islower</kbd>: True for lowercase letters.
  * <kbd>ismeshgrid</kbd>: determines whether grid might come from meshgrid or not
  * <kbd>ismonotonic</kbd>: returns a boolean value indicating whether or not a vector is monotonic.  
  * <kbd>isnatural</kbd>: True for arrays of positive i.e., non-negative natural nmbers.
  * <kbd>isodd</kbd>: checks the given number(s) for being odd
  * <kbd>isposint</kbd>: True for positive integers.
  * <kbd>isprtchr</kbd>: True for printable characters.
  * <kbd>isrowvector</kbd>: True for row vector input.
  * <kbd>issize</kbd>: - Check whether the given matrix is of provided size/dimensions
  * <kbd>issquare</kbd>: - Check whether the given matrix is square
  * <kbd>isupper</kbd>: True for uppercase letters.
  * <kbd>isxdigit</kbd>: True for hexadecimal digits.
  * <kbd>ord</kbd>: returns the ordinal for the given number
  * <kbd>wraprad</kbd>: Map angles measured in radians to the interval [-pi,pi).
  * <kbd>xkron</kbd>: Kronecker tensor product.


## math/
  * <kbd>angle2rotm</kbd>: Create Tait-Bryan rotation matrices from rotation angles
  * <kbd>bbox</kbd>: Calculates the 2D bounding box for the given points
  * <kbd>bbox3</kbd>: Calculates the 3D bounding box for the given points
  * <kbd>binomcoef</kbd>: Binomial coefficient.
  * <kbd>closest</kbd>: finds the row and column of the matrix element closest to a given
  * <kbd>crossing</kbd>: find the crossings of a given level of a signal
  * <kbd>evec</kbd>: 
  * <kbd>evec3</kbd>: 
  * <kbd>evecn</kbd>: Make sure we do not create vectors larger than the specified dimension by
  * <kbd>f2w</kbd>: turns ordinary frequency into angular frequency
  * <kbd>factorial2</kbd>: Factorial function.
  * <kbd>fibonacci</kbd>: Fibonacci numbers.
  * <kbd>gcd2</kbd>: Greatest common divisor of all elements.
  * <kbd>haversin</kbd>: creates the haversinersine function of argument z
  * <kbd>iseven</kbd>: checks the given number(s) for being even
  * <kbd>isprime2</kbd>: True for prime numbers.
  * <kbd>lcm2</kbd>: LCMALL Least common multiple of all elements.
  * <kbd>mcols</kbd>: Count number of columns of matrix A
  * <kbd>mmax</kbd>: behaves similar to MAX except that it automatically shrinks down to
  * <kbd>mmin</kbd>: behaves similar to MIN except that it automatically shrinks down to
  * <kbd>mnormcol</kbd>: Normalize a matrix per column
  * <kbd>mnormrow</kbd>: Normalize a matrix per row
  * <kbd>nrows</kbd>: Count number of rows of matrix A
  * <kbd>quat2acc</kbd>: Get angular acceleration from quaternion velocity, and acceleration
  * <kbd>quat2ratem</kbd>: Gives the quaternion rate matrices
  * <kbd>quat2rotm</kbd>: converts quaternions to rotation matrices
  * <kbd>quat2rotzyx</kbd>: Convert quaternion to Tait-Bryan angle rotation matrix
  * <kbd>quat2vel</kbd>: Converts quaternion velocity vector to angular velocity vector
  * <kbd>rot2</kbd>: creates the 2D rotation matrix of angles A
  * <kbd>rot2d</kbd>: ROT2d creates the 2D rotation matrix of angles A given in degree
  * <kbd>rotm2row</kbd>: converts a 3d rotation matrix to a row
  * <kbd>rotmdiff</kbd>: determine the difference between two rotation matrices
  * <kbd>rotrow2m</kbd>: converts a 1d rotation matrix row vector to its matrix representation
  * <kbd>rotxsym</kbd>: Symbolic rotation matrix about the x-axis
  * <kbd>rotysym</kbd>: Symbolic rotation matrix about the y-axis
  * <kbd>rotzsym</kbd>: Symbolic rotation matrix about the z-axis
  * <kbd>sym_eul2rotm</kbd>: Convert symbolic Euler angles to rotation matrix
  * <kbd>vec2skew</kbd>: Turn the input into its skew-symmetrix matrix form
  * <kbd>vec2tens</kbd>: converts a vector to its 2d tensor matrix representation.
  * <kbd>versin</kbd>: calculates the versine of the argument
  * <kbd>w2f</kbd>: turns angular frequency into ordinary frequency


## ode/
  * <kbd>odeprogress</kbd>: creates a progress bar window for use as simulation progress info


## plot/
  * <kbd>anim2d</kbd>: animates 2-dimensional data over time.
  * <kbd>anim3d</kbd>: animates 3-dimensional data over time.
  * <kbd>autosetlims</kbd>: automatically sets limits of the curent axis
  * <kbd>center_cos</kbd>: centers the coordinate system at [0, 0] i.e., moves the axes
  * <kbd>circle</kbd>: draws a circle of specified radius
  * <kbd>circle3</kbd>: draws a circle in 3D
  * <kbd>distinguishableColors</kbd>: pick colors that are maximally perceptually distinct
  * <kbd>figplot</kbd>: opens a figure and plots inside this figure.
  * <kbd>gpf</kbd>: Get the given handles parent figure
  * <kbd>isallaxes</kbd>: Checks whether the given handle is purely axes or not
  * <kbd>isfig</kbd>: checks whether the given handle is a figure handle or not
  * <kbd>isplot2d</kbd>: Check the given axes against being a 2D plot i.e., created by plot()
  * <kbd>isplot3d</kbd>: Check the given axes against being a 3D plot i.e., created by plot3()
  * <kbd>max_fig</kbd>: maximizes the current or given figure
  * <kbd>maxplotvalue</kbd>: Determine the maximum plotted value along all axes
  * <kbd>minplotvalue</kbd>: Determine the minimum plotted value along all axes
  * <kbd>plot_addPointPlaneIntersection</kbd>: Adds intersection indicator for a point on the
  * <kbd>plot_colbox</kbd>: plots a colored box (patch) for the given color
  * <kbd>plot_coordaxes</kbd>: Add a frame of reference to the current plot
  * <kbd>plot_cyclelinestyles</kbd>: adds different line styles to each plot in an axis
  * <kbd>plot_houghlines</kbd>: plot lines from houghlines
  * <kbd>plot_markers</kbd>: Plot some markers on the lines given in Axes
  * <kbd>plot_zoom</kbd>: plots a zoom region into the given axes
  * <kbd>plotrange</kbd>: Determine the range of plotted data from min to max
  * <kbd>point</kbd>: Define the input parser
  * <kbd>rgb_darker</kbd>: 
  * <kbd>rgb_lighter</kbd>: 
  * <kbd>ruler</kbd>: plots a vertical or horizontal ruler at the given position
  * <kbd>semilogxy</kbd>: plots a 3D plot with logarithmic X- and Y-axis
  * <kbd>setfigureratio</kbd>: sets the ratio of the current or given figure
  * <kbd>shadow3</kbd>: plots a 3D shadow3 plot of all data into the given axes onto the given
  * <kbd>usdistcolors</kbd>: creates distinguishable colors complying with University of
  * <kbd>uslayout</kbd>: applies the corresponding figure to University of Stuttgarts


## plot/exportfig/
  * <kbd>append_pdfs</kbd>: Appends/concatenates multiple PDF files
  * <kbd>copyfig</kbd>: Create a copy of a figure, without changing the figure
  * <kbd>crop_borders</kbd>: Crop the borders of an image or stack of images
  * <kbd>eps2pdf</kbd>: Convert an eps file to pdf format using ghostscript
  * <kbd>export_fig</kbd>: Exports figures in a publication-quality format
  * <kbd>fix_lines</kbd>: Improves the line style of eps files generated by print
  * <kbd>ghostscript</kbd>: Calls a local GhostScript executable with the input command
  * <kbd>im2gif</kbd>: Convert a multiframe image to an animated GIF file
  * <kbd>isolate_axes</kbd>: Isolate the specified axes in a figure on their own
  * <kbd>pdf2eps</kbd>: Convert a pdf file to eps format using pdftops
  * <kbd>pdftops</kbd>: Calls a local pdftops executable with the input command
  * <kbd>print2array</kbd>: Exports a figure to an image array
  * <kbd>print2eps</kbd>: Prints figures to eps with improved line styles
  * <kbd>read_write_entire_textfile</kbd>: Read or write a whole text file to/from memory
  * <kbd>user_string</kbd>: Get/set a user specific string
  * <kbd>using_hg2</kbd>: Determine if the HG2 graphics engine is used


## signal/
  * <kbd>gauss</kbd>: calculates the 1D gaussian function along X
  * <kbd>h2r</kbd>: converts Hertz to radian per second
  * <kbd>r2h</kbd>: converts radian per second to Hertz
  * <kbd>siggen_difflattraj</kbd>: creates a differentially flat trajectory.
  * <kbd>siggen_rectangular</kbd>: generates a rectangular signal
  * <kbd>siggen_sawtooth</kbd>: 
  * <kbd>siggen_trapezoid</kbd>: 


## str/
  * <kbd>strdist</kbd>: computes distances between strings
  * <kbd>strlcfirst</kbd>: lower cases the frist character of the string(s)
  * <kbd>strnatsort</kbd>: Alphanumeric / Natural-Order sort the strings in a cell array of strings.
  * <kbd>strnatsortfiles</kbd>: Alphanumeric / Natural-Order sort of a cell array of filenames/filepaths.
  * <kbd>strucfirst</kbd>: upper cases the frist character of the string(s)
  * <kbd>strucwords</kbd>: uppercases each word of the given strings


## symbolic/
  * <kbd>deriv</kbd>: derives a symbolic expression with respect to another symbolic


## sys/
  * <kbd>bytes2str</kbd>: turns the number of bytes into a human readable string
  * <kbd>computername</kbd>: returns the name of the computer in the local network
  * <kbd>cprintf</kbd>: displays styled formatted text in the Command Window
  * <kbd>create_contents</kbd>: creates the CONTENTS.M files for this project
  * <kbd>create_docs</kbd>: creates the docs for project MATLAB-Tooling from each functions'
  * <kbd>datestr8601</kbd>: Convert a Date Vector or Serial Date Number to an ISO 8601
  * <kbd>dispstat</kbd>: Prints overwritable message to the command line. If you dont want to keep
  * <kbd>focus_cmdwin</kbd>: gives focus to the command window
  * <kbd>focus_editor</kbd>: gives programmatic focus to the editor
  * <kbd>humansize</kbd>: Default decimals
  * <kbd>iif</kbd>: Allows conditionals in inline and anonymous functions
  * <kbd>install_styles</kbd>: installes all styles stored in `styles` into the user's
  * <kbd>isinpath</kbd>: Checks whether the given path is part of MATLAB's environment path
  * <kbd>matlab_logo</kbd>: 
  * <kbd>pack_files_and_dependencies</kbd>: packs dependent files into one folder
  * <kbd>progressbar</kbd>: creates a nicer progress bar window for progress information
  * <kbd>restart</kbd>: executes a few functions to reset MATLAB workspace
  * <kbd>rmpaths</kbd>: Remove directory from search path recursively
  * <kbd>save_figure</kbd>: Saves the figure under the specified filename with variable types
  * <kbd>save_ws</kbd>: saves the whole workspace to a unique filename 
  * <kbd>setrng</kbd>: sets the random number generator to a set or pre-defined options
  * <kbd>stopalltimers</kbd>: stops all timers whether they are visible or not
  * <kbd>tsave</kbd>: 
  * <kbd>username</kbd>: returns the current user's username
  * <kbd>varsize</kbd>: determines the size of each variable given


## twincat/
  * <kbd>csv2tcscope</kbd>: converts a TwinCat CSV scope file to a TCSCOPE object


