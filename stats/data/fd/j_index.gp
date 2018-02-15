set terminal svg size 1500,500
set output "j_index.svg"


set multiplot layout 1,2 rowsfirst

# Files cpufd_cycles_j.dat  cpufd_throughput_j.dat  j_index.gp  nofd_cycles_j.dat  nofd_throughput_j.dat

set title "J index fairness for 20 flows of 2 classes [2(costly), 18(normal)]"

set logscale y
set key bottom left

set xlabel "Ratio between cost of classes (MAX/MIN)"
set ylabel "J index"

set xrange [1:]

plot "cpufd_cycles_j.dat" u ($2/350):6 w lp lw 2 pt 2 lc 1 title "CPU-FD: J-Cycles",\
"cpufd_throughput_j.dat" u ($2/350):5 w lp lw 2 pt 3 lc 1 title "CPU-FD: J-Throughput"


plot "nofd_cycles_j.dat" u ($2/350):6 w lp lw 2 pt 2 lc 2  title "TD: J-Cycles",\
"nofd_throughput_j.dat" u ($2/350):5 w lp lw 2 pt 3 lc 2 title "TD: J-Throughput"


unset multiplot


