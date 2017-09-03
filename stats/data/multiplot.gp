
do for [i=1:20] {
	set term png
	set output 'clock_vs_vector'.i.'.png'

	set multiplot layout 1,2 rowsfirst

	RATE = i*400
	set title "RATE: ".RATE." Mbps"

	unset key                               

	stats 'clock_distr_'.i


	set xlabel "Clock cycles"              
	set ylabel "P(X)>x"
	set xrange [0.1:100000]

	set logscale x
	set format x "10^%T"
	plot 'clock_distr_'.i using 2:($1/STATS_sum_x) smooth cumulative with lines title "CLOCK"


	unset logscale
	set xlabel "Vector sizes"
	unset xrange
	unset format x             
	plot 'vec_distr_'.i using 2:($1/STATS_sum_x) smooth cumulative with lines title "VECTORS"

	unset multiplot
}

