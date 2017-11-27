set term svg size 2000,500
set output 'nodes.svg'

set samples 10000

#set ylabel "Virtual queue sizes (Vqs)" 
#set xlabel 'Events'

set title "Packets per vector in some nodes"

set yrange [0:300]
 
plot "DATA/nodes.dat" u 2:xtic(1) w boxes 

set term pngcairo
set output 'nodes.png'

replot
