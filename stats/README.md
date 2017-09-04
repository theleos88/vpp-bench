# Stats

This directory contains the raw data of the VPP experiments.

## Components

The directory ```data``` contains the raw data on current experiments.

### Clock cycles and Vector size

This experiments consists on gathering data on the average vector size and the average clock cycles required to perform a full graph traversal.

Data is taken directly from the internal VPP logger, and is parsed to the raw file ```parsed_$i```, for ``` i = [1:20]```.

Each ```$i``` consists in a traffic rate multiple of 400 Mbps. We start at i=1 -> TX_in = 400Mbps. We end in i=20 -> TX_in = 8 Gbps. We already saturate our line rate at this point. (In fact, Vector size is already 256 for all calls).


**Most important files**

- ```multiplot.gp```; it plots our data on clock and vector sizes side-by-side
- ```parsed_$i```; raw data from logger
- ```clock_distr_$i```; cumulative distribution of clock cycles required for each vector processing
- ```vec_distr_$i```; vector size distribution for each graph traversal.