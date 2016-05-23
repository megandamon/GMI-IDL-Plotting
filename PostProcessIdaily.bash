#!/usr/local/bin/bash

flnames=( const_freq1 )
export dateString=2007


for flname in "${flnames[@]}"
do
   :
   for file in `ls $flname*.ps | sort`; do echo "$file"; cat $file >> $flname.$dateString.ps; done; ps2pdf $flname.$dateString.ps; rm $flname*.ps
done
