pro GmiColumnPlots, dir1, dir2, exp1, exp2, year1, year2, postScript, diag
    compile_opt strictarr

    if (n_params() eq 0 or n_params() ne 8) then begin
    	print, 'GmiColumnPlots, dir1, dir2, exp1, exp2, year1, year2, postScript (0/1), diag(0/1)'
   	stop
    end

    ; set font to device font
   !p.font=0

    ; create file name for each month
    ;months = ['jan','', 'jul', 'oct']
    months = ['dec']
    i = 0
    while (i lt n_elements(months)) do begin
        month = months[i]
        i = i + 1

        print, "month: ", month

        ;fileString1 = dir1 + '/'+ year1 + '/gmic_' + exp1 + '_' + year1 + '_' + month
        ;fileString2 = dir2 + '/'+ year2 + '/gmic_' + exp2 + '_' + year2 + '_' + month
        fileString1 = dir1 + '/'+ year1 + '/' + exp1 + '_' + year1 + '_' + month
        fileString2 = dir2 + '/'+ year2 + '/' + exp2 + '_' + year2 + '_' + month

        ; column file
        file1 = fileString1 + '.column.nc'
        file2 = fileString2 + '.column.nc'
        checkFile, file1, diag
        checkFile, file2, diag
        plot2DSpecies, file1, file2, exp1, exp2, "constColTrop_freq3", "freq3_labels", $
          month, year1, year2, postScript, diag
        plot2DSpecies, file1, file2, exp1, exp2, "constColCombo_freq3", "freq3_labels", $
          month, year1, year2, postScript, diag


        
    end

end
