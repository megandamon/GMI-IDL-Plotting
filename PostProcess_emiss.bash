#!/usr/local/bin/bash

flnames=( October ) 
for flname in "${flnames[@]}"
do
   :
   for file in `ls $flname*.ps | sort`; do echo "$file"; cat $file >> $flname.ps; done; ps2pdf $flname.ps; rm $flname*.ps
done

