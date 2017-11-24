#!/bin/bash

for i in `seq 1 30`; do
	#Parsing Vectors
	cat parsed_$i | awk '{print $2}' | grep -v "-" | sort -n | uniq --count > vec_distr_$i

	#Parsing clock cycles
	cat parsed_$i | awk '{print $6}' | grep -v "-" | sort -n | uniq --count > clock_distr_$i
done;
