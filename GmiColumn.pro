pro printMessage
    print, 'GmiColumn, dir1, dir2, exp1, exp2, year, postScript (0/1), diag(0/1)'
    return
end

pro GmiColumn, dir1, dir2, exp1, exp2, year, postScript, diag
   if (n_params() eq 0 or n_params() ne 7) then begin
       printMessage
   end

   ; set font to device font
   !p.font=0

    ; create file name for each month
    months = ['jan','feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
    i = 0
    while (i lt 12) do begin
        month = months[i]
        file1 = dir1 + 'gmic_' + exp1 + '_' + year + '_' + month + '.column.nc'
        file2 = dir2 + 'gmic_' + exp2 + '_' + year + '_' + month + '.column.nc'
        checkFile, file1, diag
        checkFile, file2, diag
        i = i + 1

        plot2DSpecies, file1, file2, exp1, exp2, "constColTrop_freq3", "freq3_labels", $
          month+year, postScript, diag

        plot2DSpecies, file1, file2, exp1, exp2, "constColCombo_freq3", "freq3_labels", $
          month+year, postScript, diag
    end

end
