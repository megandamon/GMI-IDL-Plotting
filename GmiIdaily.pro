pro GmiOverpass2, file1, file2, exp1, exp2, month, year1, year2, postScript, diag

   if (diag eq 1) then print, "Start GmiOverpass2"

   do3DPlottingWithRecords, "overheadO3col_overpass", file1, file2, exp1, exp2, month, year1, year2, postScript, diag
   do3DPlottingWithRecords, "cloudOptDepth_overpass", file1, file2, exp1, exp2, month, year1, year2, postScript, diag

end
