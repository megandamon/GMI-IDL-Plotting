#!/usr/local/bin/bash

export dateString=dec

flnames=( constColTrop constColCombo )

for flname in "${flnames[@]}"
do
   :
   for file in `ls $flname*.ps | sort`; do echo "$file"; cat $file >> $flname.$dateString.ps; done; ps2pdf $flname.$dateString.ps; rm $flname*.ps
done

