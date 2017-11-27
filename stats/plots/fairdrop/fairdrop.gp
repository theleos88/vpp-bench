#set term epscairo enhanced color size 20in,10in 
set term svg size 2000,500
set output 'fairdrop.svg'

set samples 10000

set ylabel "Virtual queue sizes (Vqs)" 
set xlabel 'Events'

set logscale y
set title "Evolution of Virtual queues for flows"

THRESHOLD=4800
LINEMIN=5000
LINEMAX=6000

#create a function that accepts linenumber as first arg
#an returns second arg if linenumber in the given range.
InRange(x,y)=((x>=LINEMIN) ? ((x<=LINEMAX) ? y:1/0) : 1/0)


list = system('ls DATA/f_*')

set xrange [LINEMIN:LINEMAX]
plot for [file in list] file u (InRange($1,$1)):7 w lp lw 2 notitle, THRESHOLD w l lw 3

set term pngcairo
set output 'fairdrop.png'

replot
