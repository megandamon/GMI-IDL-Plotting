pro GmiAerosolPlots, dir1, dir2, exp1, exp2, year1, year2, postScript, diag
    compile_opt strictarr

    if (n_params() eq 0 or n_params() ne 8) then begin
    	print, 'GmiAerosolPlots, dir1, dir2, exp1, exp2, year1, year2, postScript (0/1), diag(0/1)'
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
      
        ; aerosol dust file
        file1 = fileString1 + '.aerdust.nc'
        file2 = fileString2 + '.aerdust.nc'
        checkFile, file1, diag
        checkFile, file2, diag

        plot2DSpecies, file1, file2, exp1, exp2, "ColumnMass_AerDust", "CMAerDust_labels", $
          month, year1, year2, postScript, diag

        plot3DSpecies, file1, file2, exp1, exp2, "OptDepth", "AerDust_labels", $
          month, year1, year2, postScript, diag

        
    end

end
