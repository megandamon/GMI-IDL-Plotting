pro GmiPlotIdailySpecies, dir1, dir2, exp1, exp2, year1, year2, refMonth, postScript, diag
    compile_opt strictarr

    if (n_params() eq 0 or n_params() ne 9) then begin
    	print, 'GmiPlotIdailySpecies, dir1, dir2, exp1, exp2, year1, year2, ref month, postScript (0/1), diag(0/1)'
   	stop
    end

    ; set font to device font
   !p.font=0

    ; create file name for each month
    months = ['jan']
    i = 0
    while (i lt n_elements(months)) do begin
        month = months[i]
        i = i + 1

        fileString1 = dir1 + '/'+ year1 + '/gmic_' + exp1 + '_' + year1 + '_' + refMonth 
        fileString2 = dir2 + '/'+ year2 + '/gmic_' + exp2 + '_' + year2 + '_' + month 

        file1 = fileString1 + '.idaily.nc'
        file2 = fileString2 + '.idaily.nc'
        checkFile, file1, diag
        checkFile, file2, diag

        plotIdailySpecies, file1, file2, exp1, exp2, "const_freq1", "freq1_labels", refMonth, month, year1, year2, $
                           postScript, diag, stratSpeciesFile="idaily.const.txt", tropSpeciesFile='idaily.const.txt', $
                       species2DFile='idaily.const.txt'
        
    end

end
