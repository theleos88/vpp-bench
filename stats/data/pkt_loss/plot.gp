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


plot 'interface-data.1.dat' u 3:9 w lp lw 3 lc rgb "#FF1122"  t 'Packet lost, exp 1, traffic gen',\
'interface-data.2.dat' u 3:9 w lp lw 3 lc rgb "#11FF22"  t 'Packet lost, exp 2, traffic gen',\
'miss.vpp.dat' u 1:2 w lp lw 3 lc rgb "#1144FF"  t 'Packet lost, exp 1, VPP'

pause -1
