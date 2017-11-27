set term svg size 2000,500
set output 'perflow.svg'

set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xtic scale 0


set samples 10000

set yrange [0:*]
set ytics nomirror
set y2range [0:2000]
set y2tics

set ylabel "Throughput in pps" 
set xlabel 'Flows'

set title "Throughput per flow"
unset xlabel

set xtics border in scale 0,0 nomirror rotate by 90

plot "DATA/perflow.dat" u 2:xtic(1) w histogram axes x1y1, "DATA/flows.dat" u 2:xtic(1) w histogram title "Cost" axes x1y2
#plot "DATA/perflow.dat" u 2:stringcolumn($1) w histogram axes x1y1, "DATA/flows.dat" u 2:stringcolumn($1) w histogram title "Cost" axes x1y2

set term pngcairo size 2000,500
set output 'perflow.png'

replot
