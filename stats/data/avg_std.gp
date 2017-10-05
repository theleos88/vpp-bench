	set term svg size 1300,600
	set output 'avg_std.svg'

	set multiplot layout 1,2 rowsfirst

	set key top left

	set xlabel "Rate (Mbps)"              
	set ylabel "Average clock cycles"

	set format y "%.0t*10^{%S}"

	plot 'clock_avg_var.txt' using 2:4 with linespoints lw 3 lc 1 title "Average clock cycles"


	plot 'clock_avg_var.txt' using 2:6 with lp lw 3 lc 3 title "Std deviation"

