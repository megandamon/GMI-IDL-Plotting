pro plotStations, dir1, dir2, exp1, exp2, speciesLabelsName, year1, year2, $
                      month, postScript, diag, stationFile=stationFile


  if (diag eq 1) then print, "Start Stations"

  ; Get stations 
  if (n_elements(stationFile) ne 0) then begin
     stations = readFileLines (stationFile, diag)
     shape1 = size(stations,/dimensions)
     numStations = shape1(0)
  end

  if (diag eq 1) then begin
     print, "Do ", numStations, " stations: ", stations
  endif

  for i=0,numStations-1 do begin
     station = stations[i]
     file1 = dir1 + year1 + '/stations/gmic_' $
                   + exp1 + '_' + year1 + '_' + month $
                   + '_' + station + '.profile.nc'
     file2 = dir2 + year2 + '/stations/gmic_' $
                   + exp2 + '_' + year2 + '_' + month $
                   + '_' + station + '.profile.nc'
     if (diag eq 1) then print, "Plotting station: ", station


    ; Get variables for plotting
    array1 = returnValues (file1,"const_surf")
    array2 = returnValues (file2,"const_surf")
    speciesLabels = string(returnValues (file1,speciesLabelsName))

    ; Check that arrays are the same sze
    variableShape1 = size(array1,/dimensions)
    variableShape2 = size(array2,/dimensions)
    if (where(variableShape1 ne variableShape2) ne -1) then begin
        print, "Dimensions for ", variableName, " are not the same!"
        return
    endif

    ; Check that arrays are the same sze
    variableShape1 = size(array1,/dimensions)
    variableShape2 = size(array2,/dimensions)
    if (where(variableShape1 ne variableShape2) ne -1) then begin
        print, "Dimensions for ", variableName, " are not the same!"
        return
    endif

    numberRecords = variableShape1[1]
    speciesLabels = strcompress(speciesLabels)
    numberSpecies = variableShape1[0]
    arraySize = numberRecords * numberSpecies

    if (diag eq 1) then begin
       print, "Number of records: ", numberRecords
       print, numberSpecies, " Species labels: ", speciesLabels
       print, "Const_surf size: ", arraySize
    endif

    tempArray1 = array1[*,*]
    tempArray2 = array2[*,*]
    tempArray1 = reform(tempArray1,arraySize)
    tempArray2 = reform(tempArray2,arraySize)
    arrayRatio = fltarr (arraySize)
    arrayRatio = calculateRatios (tempArray1, tempArray2, arrayRatio, largeValue, diag)
    
    if (diag eq 1) then begin
       print, 'max ratio: ', max(arrayRatio)
       print, 'min ratio: ', min(arrayRatio)
    endif
    
    ; Reform data back to 2D lonxlat
    tempArray1 = reform(tempArray1, numberRecords, numberSpecies)
    tempArray2 = reform(tempArray2, numberRecords, numberSpecies)
    arrayRatio = reform(arrayRatio, numberRecords, numberSpecies)
    levels = returnMaxLevels (tempArray1, tempArray2)


    plot, tempArray1, $
          title="const_surf_" + station + "_" + month
;    plot, tempArray2
;    plot, arrayRatio

     ; surface values
;     createThreePanelXYPlot, "const_surf_" + station + "_" + month, $
;                             levels, tempArray1, tempArray2, $
;                             arrayRatio, lon, lat, exp1, exp2, $
;                             "const_surf_" + station + "_", year1, year2, $
;                             postScript

  endfor
end
