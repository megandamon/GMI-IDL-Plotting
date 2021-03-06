pro GmiDoAllPlots, dir1, dir2, exp1, exp2, year1, year2, postScript, diag
    compile_opt strictarr

    if (n_params() eq 0 or n_params() ne 8) then begin
    	print, 'GmiDoAllPlots, dir1, dir2, exp1, exp2, year1, year2, postScript (0/1), diag(0/1)'
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
        ;fileString2 = dir2 + '/'+ year2 + '/' + exp2 + '_' + year2 + '_' + 'oct' 

        ; restart file1
        file1 = fileString1 + '.rst.nc'
        file2 = fileString2 + '.rst.nc'
        checkFile, file1, diag
        checkFile, file2, diag
        plot3DSpecies, file1, file2, exp1, exp2, "const", "const_labels", month, year1, year2, $
                      postScript, diag, stratSpeciesFile='amonthly.const.strat.txt', tropSpeciesFile='amonthly.const.trop.txt', $
                      species2DFile='amonthly.const.2d.txt'
	stop
	

	; amonthly / adaily file
        file1 = fileString1 + '.adaily.nc'
        file2 = fileString2 + '.adaily.nc'
        file1 = fileString1 + '.amonthly.nc'
        file2 = fileString2 + '.amonthly.nc'
        checkFile, file1, diag
        checkFile, file2, diag
        GmiAmonthly, file1, file2, exp1, exp2, month, year1, year2, postScript, diag
	
	stop

        ; column file
        file1 = fileString1 + '.column.nc'
        file2 = fileString2 + '.column.nc'
        checkFile, file1, diag
        file1 = fileString1 + '.amonthly.nc'
        file2 = fileString2 + '.amonthly.nc'
        ;checkFile, file1, diag
        ;checkFile, file2, diag
        ;GmiAmonthly, file1, file2, exp1, exp2, month, year1, year2, postScript, diag
	
	;stop

        ; column file
        file1 = fileString1 + '.column.nc'
        file2 = fileString2 + '.column.nc'
        ;checkFile, file1, diag
        ;checkFile, file2, diag
        ;plot2DSpecies, file1, file2, exp1, exp2, "constColTrop_freq3", "freq3_labels", $
        ;  month, year1, year2, postScript, diag
        ;plot2DSpecies, file1, file2, exp1, exp2, "constColCombo_freq3", "freq3_labels", $
        ;  month, year1, year2, postScript, diag


        ;stop

        ; overpass2 file
        file1 = fileString1 + '.overpass2.nc'
        file2 = fileString2 + '.overpass2.nc'
        ;checkFile, file1, diag
        ;checkFile, file2, diag
        ;GmiOverpass2, file1, file2, exp1, exp2, month, year1, year2, postScript, diag
      

        ; aerosol dust file
        file1 = fileString1 + '.aerdust.nc'
        file2 = fileString2 + '.aerdust.nc'
        checkFile, file1, diag
        checkFile, file2, diag

        plot2DSpecies, file1, file2, exp1, exp2, "ColumnMass_AerDust", "CMAerDust_labels", $
          month, year1, year2, postScript, diag

        plot3DSpecies, file1, file2, exp1, exp2, "OptDepth", "AerDust_labels", $
          month, year1, year2, postScript, diag

        stop

        ; station files
        ; plotStations, dir1, dir2, exp1, exp2, "const_labels", $
        ;               year1, year2, month, postScript, diag, stationFile="stations.txt"


        ; QJ file
        fileString1 = dir1 + '/'+ year1 + '/diagnostics/gmic_' + exp1 + '_' + year1 + '_' + month 
        fileString2 = dir2 + '/'+ year2 + '/diagnostics/gmic_' + exp2 + '_' + year2 + '_' + month 
        file1 = fileString1 + '.qj.nc'
        file2 = fileString2 + '.qj.nc'
        checkFile, file1, diag
        checkFile, file2, diag
        ;plot3DSpecies, file1, file2, exp1, exp2, "qj", "qj_labels", month, year1, year2, $
        ;  postScript, diag, stratSpeciesFile='qj.strat.txt', tropSpeciesFile='qj.trop.txt', $
        ;  species2DFile='qj.2d.txt'
        ;print, "In DoAllPlots"

        
    end

end
