#!/usr/local/bin/bash

export dateString=mar

#flnames=( overheadO3col cloudOptDepth OptDepth ColumnMass const surf_emiss dry_depos wet_depos )
flnames=( const surf_emiss )
#flnames=( overheadO3col cloudOptDepth qj OptDepth ColumnMass const lightning_nc surf_emiss dry_depos wet_depos )
#flnames=( const dry_depos surf_emiss wet_depos lightning_nc )
#flnames=( qj )
#flnames=( overheadO3col cloudOptDepth ColumnMass const lightning_nc surf_emiss dry_depos wet_depos )
#flnames=( overheadO3col )
#flnames=( OptDepth )
#flnames=( ColumnMass OptDepth )
#flnames=( cloudOptDepth )
#flnames=( qj OptDepth ColumnMass const lightning_nc surf_emiss dry_depos wet_depos )
#flnames=( const lightning_nc surf_emiss dry_depos wet_depos )
for flname in "${flnames[@]}"
do
   :
   for file in `ls $flname*.ps | sort`; do echo "$file"; cat $file >> $flname.$dateString.ps; done; ps2pdf $flname.$dateString.ps; rm $flname*.ps
done
ps2pdf Flashrate.ps 
rm Flashrate.ps
mv Flashrate.pdf Flashrate_$dateString.pdf 

