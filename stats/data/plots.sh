#!/bin/bash

for i in `seq 1 20`; do
	#Parsing Vectors
	cat parsed_$i | awk '{print $2}' | sort -n | uniq --count > vec_distr_$i

	#Parsing clock cycles
	cat parsed_$i | awk '{print $6}' | sort -n | uniq --count > clock_distr_$i
done;
