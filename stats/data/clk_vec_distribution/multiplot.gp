set print "clock_avg_var.txt"

do for [i=1:20] {
	set term svg size 1300,600
	set output 'clock_vs_vector'.i.'.svg'

	set multiplot layout 1,2 rowsfirst

	RATE = i*400
	set title "RATE: ".RATE." Mbps"

	unset key                               
	#set key outside

	stats 'clock_distr_'.i;


	set xlabel "Clock cycles"              
	set ylabel "P(X)>x"
	set xrange [0.1:1000000]

	set label 1 sprintf("MEAN = %6.4f",STATS_mean_y) left at graph 0.2, graph 0.5
	set label 2 sprintf("STDDEV = %7.4f",STATS_stddev_y) left at graph 0.2, graph 0.4

	set logscale x
	set format x "10^%T"

	plot 'clock_distr_'.i using 2:($1/STATS_sum_x) smooth cumulative with lines title "CLOCK"

	a = sprintf("CLCK: %.2f AVG: %.2f STD: %.2f\n",RATE, STATS_mean_y, STATS_stddev_y)
	print a



	unset label 1
	unset label 2
	unset logscale
	set xlabel "Vector sizes"
	unset xrange
	unset format x             

	stats 'vec_distr_'.i;
	set label 1 sprintf("MEAN = %6.4f",STATS_mean_y) left at graph 0.2, graph 0.5
	set label 2 sprintf("STDDEV = %7.4f",STATS_stddev_y) left at graph 0.2, graph 0.4

	plot 'vec_distr_'.i using 2:($1/STATS_sum_x) smooth cumulative with lines title "VECTORS"

	unset multiplot
}
