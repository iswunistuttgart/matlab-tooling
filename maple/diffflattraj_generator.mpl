
# Differentially Flat Trajectories
# Code Generation
# Initialization of Maple Sheet
with(StringTools):
with(CodeGeneration):
with(LanguageDefinition):
# Polynomial coefficients for systems of order 1..7
ai := [[3, -2], [10, -15, 6], [35, -84, 70, -20], [126, -420, 540, -315, 70], [462, -1980, 3465, -3080, 1386, -252], [1716, -9009, 20020, -24024, 16380, -6006, 924], [6435, -40040, 108108, -163800, 150150, -83160, 25740, -3432]]:
# Procedure to create the polynomial for a given system order n
poly := n -> [seq(ai[n][i-n]/(T^~i)*(t^i), i = (n+1)..(2*n+1))]:
# Loop over all possible system orders (1..7) and create k derivatives functions (k = 0..2n+1)
fname := cat(interface(worksheetdir),"/zzz.m"):
f_n := fopen(fname, WRITE, TEXT):
for n from 1 to 7 do
  zz := z0 + (z1 - z0)*add(poly(n)):
  for iD from 0 to (2*n + 1) do
    fprintf(f_n, "function D%dz = in_sys%d_diff%d(t, z0, z1, T)\n", iD, n, iD):
    fprintf(f_n, "%%%% IN_SYS%d_DIFF%d is the %d-degree derivative trajectory for an order-%d system\n", n, iD, iD, n):
    fprintf(f_n, "%%\n"):
    fprintf(f_n, "%%   D%dZ = IN_SYS%d_DIFF%d(T, Z0, Z1, T) returns the evaluated differentially flat\n", iD, n, iD):
    fprintf(f_n, "%%   trajectory over time T starting at point Z0 and ending at Z1 with a total\n"):
    fprintf(f_n, "%%   time of transition of T seconds.\n"):
    fprintf(f_n, "%%\n"):
    fprintf(f_n, "%%   Inputs:\n"):
    fprintf(f_n, "%%\n"):
    fprintf(f_n, "%%   T                   Nx1 vector of time values to evaluate trajectory for.\n"):
    fprintf(f_n, "%%\n"):
    fprintf(f_n, "%%   Z0                  1xM vector of start values.\n"):
    fprintf(f_n, "%%\n"):
    fprintf(f_n, "%%   Z1                  1xM vector of target values.\n"):
    fprintf(f_n, "%%\n"):
    fprintf(f_n, "%%   T                   Total time of transition.\n"):
    fprintf(f_n, "%%\n"):
    fprintf(f_n, "%%   Outputs:\n"):
    fprintf(f_n, "%%\n"):
    fprintf(f_n, "%%   D%dz                NxM vector of evaluated trajectory points\n", iD):
    fprintf(f_n, "\n\n\n"):
    fprintf(f_n, "%%%% Auto-generated and optimized code\n"):
    fprintf(f_n, "\n"):
    fclose(f_n):
    Matlab(zz, output=fname, optimize=tryhard, defaulttype=numeric, resultname=sprintf("D%dz", iD)):
    f_n := fopen(fname, APPEND, TEXT):
    fprintf(f_n, "\n"):
    fprintf(f_n, "end\n"):
    fprintf(f_n, "%% END function D%dz = in_sys%d_diff%d(t, z0, z1, T)\n", iD, n, iD):
    fprintf(f_n, "\n\n\n"):
    zz := simplify(diff(zz, t)):
  end do:
end do:
fclose(f_n):

