#set term epscairo enhanced color size 20in,10in 
set term svg size 2000,500
set output 'thput.svg'

set key bottom left

set samples 10000

set xlabel 'Time'
set ylabel "Throuhgput in Mpps" 

set title "Evolution of overall Throughput vs time"

LINERATE=14.87
XC = 12.04
IP = 8.01
INPUT = 4.43

plot "DATA/total_thput.dat" u 3 w lp lw 2 t "Total throughput", INPUT w l lw 1 title "Processed packets", IP w l t "IP", XC w l t "XC" 

set term pngcairo
set output 'thput.png'

replot
