reset
set terminal svg
#################################################

# Modify output file here
set output "packet-loss.svg"

# Title of the plot
set title "Number of lost packets"

# Format of axis
set format y "10^%T"

# Grid
set grid y
set grid x

# Labels

set logscale y

set key top left

set xlabel 'Rate (Mbps)
set ylabel 'Number of Packets'


plot 'results-delay.dat' u 3:9 w lp lw 3 lc rgb "#FF1122"  t 'Packet lost, exp 3, traffic gen, no turbo boost',\
'miss.vpp.data' u 1:2 w lp lw 3 lc rgb "#1144FF"  t 'Packet lost, exp 2, VPP, no turbo boost'

pause -1
