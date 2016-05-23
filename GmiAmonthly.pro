pro plotFlashRates, file1, file2, exp1, exp2, month, year1, year2, postScript, diag
    if (diag eq 1) then print, "start plotFlashRates"
    largeValue = 99999999

    ; Get necessary variables for plotting
    flashrate1 = returnValues (file1,'flashrate_nc')
    flashrate2 = returnValues (file2,'flashrate_nc')

    lon = returnValues (file1,'longitude_dim')
    lat = returnValues (file1,'latitude_dim')

    ; Calculate data size and reform data to 1D array
    arraySize = n_elements(lon) * n_elements(lat)
    flashrate1 = reform(flashrate1,arraySize)
    flashrate2 = reform(flashrate2,arraySize)
    flashrateRatio = fltarr (arraySize)

    
    flashrateRatio = calculateRatios (flashrate1, flashrate2, flashrateRatio, largeValue, diag)    
    
    ; Reform data back to 2D lon x lat
    flashrate1 = reform(flashrate1, n_elements(lon), n_elements(lat))
    flashrate2 = reform(flashrate2, n_elements(lon), n_elements(lat))
    flashrateRatio = reform(flashrateRatio, n_elements(lon), n_elements(lat))

    levels = returnMaxLevels (flashrate1, flashrate2)
    
    createThreePanelXYPlot, "Flashrate", levels, flashrate1, flashrate2, $
      flashrateRatio, lon, lat, exp1, exp2, "Flashrate_nc_"+month, year1, year2, postScript

end

pro plotConst, file1, file2, exp1, exp2, date, postScript, diag
    if (diag eq 1) then print, "start plotConst for: ", date
    largeValue = 99999999

    ; Get necessary variables for plotting
    const1 = returnValues (file1, "const")
    const2 = returnValues (file2, "const")
    lon = returnValues (file1, 'longitude_dim')
    lat = returnValues (file1, 'latitude_dim')
    lev = returnValues (file1, 'eta_dim')
    species = returnValues (file1, 'species_dim')
    numberSpecies = n_elements(species)
    speciesLabels = string(returnValues (file1,"const_labels"))
    speciesLabels = strcompress(speciesLabels)

    arraySize = n_elements(lon) * n_elements(lat) * n_elements(lev)
    for i=0,numberSpecies-1 do begin

        ; Calculate data size and reform to 1D
        const1Specie = const1[*,*,*,i]
        const2Specie = const2[*,*,*,i]

        const1Specie = reform(const1Specie,arraySize)
        const2Specie = reform(const2Specie,arraySize)
        constRatio = fltarr (arraySize)
        constRatio = calculateRatios (const1Specie, const2Specie, constRatio, largeValue, diag)
        if (diag eq 1) then begin
            print, 'max ratio: ', max(constRatio)
            print, 'min ratio: ', min(constRatio)
        endif

        ; Reform data back to 3D
        const1Specie = reform(const1Specie, n_elements(lon), n_elements(lat), n_elements(lev))
        const2Specie = reform(const2Specie, n_elements(lon), n_elements(lat), n_elements(lev))
        constRatio = reform(constRatio, n_elements(lon), n_elements(lat), n_elements(lev))

        specieLabel = strmid(speciesLabels[i],0,strlen(speciesLabels[i])-1)
        print, "plotting specie: ", specieLabel
        if (specieLabel eq "Total density") then specieLabel = "TotalDensity"
        plot3DField, "const_"+specieLabel+"_", const1Specie, const2Specie, constRatio, lat, lon, lev, exp1, exp2, date, $
          postScript, diag
    endfor
end


pro plotCOEmissions, file1, file2, exp1, exp2, month, year1, year2, postScript, diag

    largeValue = 99999999

   ; A = total CO emissions
   ; A(file1)/A(file2)
   ; Completed using plot2DSpecies of "surf_emiss"
   ; See surf_emiss_CO_*.ps

   ; B = total biogenic emissions (skip propene)
   ; B(file1)/B(file2)
   ; surf_emiss_biogenic_*.ps

   ; Get the species' locations for CO_methanol and CO_monoterpene
    speciesLabelsAll = string(returnValues (file1,"emiss_spc_labels2"))
    sizeSpecies = size(speciesLabelsAll)
    numSpecies = sizeSpecies[1]
    biogenicEmissLocations = intarr(2) ; holds indexes of biogenic CO sources

    count = 0
    for i=0,numSpecies-1 do begin
        specieLabel = strmid(speciesLabelsAll[i],0,strlen(speciesLabelsAll[i])-1)
        specieLabel = strsplit(specieLabel," ",/extract)
        if (specieLabel eq "CO_methanol" or specieLabel eq "CO_monoterpene") then begin
            biogenicEmissLocations[count] = i
            count = count + 1
        endif 
    endfor
    
    ; should only be 2 (hard-coded above)
    numBiogenics = size(biogenicEmissLocations,/dimensions)

    ; Read in array and add the biogenics together
    array1 = returnValues (file1,"surf_emiss2")
    array2 = returnValues (file2,"surf_emiss2")
    
    arraySize = size(array1,/dimensions)
    biogenicsArray1 = fltarr(arraySize[0], arraySize[1])
    biogenicsArray2 = fltarr(arraySize[0], arraySize[1])
    
    ; sum the biogenic sources of CO
    for i=0,numBiogenics[0]-1 do begin
        biogenicsArray1[*,*] = biogenicsArray1[*,*] + array1[*,*,biogenicEmissLocations[i]]
        biogenicsArray2[*,*] = biogenicsArray1[*,*] + array2[*,*,biogenicEmissLocations[i]]
    endfor

    ; now get the ratios
    tempArray1 = biogenicsArray1[*,*]
    tempArray2 = biogenicsArray2[*,*]
    arraySizeFlat = arraySize[0] * arraySize[1]
    tempArray1 = reform(tempArray1,arraySizeFlat)
    tempArray2 = reform(tempArray2,arraySizeFlat)
    arrayRatio = fltarr (arraySizeFlat)
    arrayRatio = calculateRatios (tempArray1, tempArray2, arrayRatio, largeValue, diag)

    ; reform the areas back to lonxlat
    tempArray1 = reform(tempArray1, arraySize[0], arraySize[1])
    tempArray2 = reform(tempArray2, arraySize[0], arraySize[1])
    arrayRatio = reform(arrayRatio, arraySize[0], arraySize[1])
    levels = returnMaxLevels (tempArray1, tempArray2)

    createThreePanelXYPlot, "surf_emiss_CO_biogenic_" + month, levels, tempArray1, tempArray2, $
      arrayRatio, lon, lat, exp1, exp2, "surf_emiss_CO_biogenic_", year1, year2, postScript

    ; (A - B) (of file1) / (A - B) of file2 OR...
    ; (total CO emissions - biogenic emissions) (of file1) /  (total CO emissions - biogenic emissions) (of file2) 
    speciesLabelsAll = string(returnValues (file1,"emiss_spc_labels"))
    sizeSpecies = size(speciesLabelsAll)
    numSpecies = sizeSpecies[1]
    coLocation = -1 ; index location of CO
    
    ; first, find out where CO is in emiss_spc_labels
    count = 0
    for i=0,numSpecies-1 do begin
        specieLabel = strmid(speciesLabelsAll[i],0,strlen(speciesLabelsAll[i])-1)
        specieLabel = strsplit(specieLabel," ",/extract)
        if (specieLabel eq "CO") then begin
            coLocation = i
            count = count + 1
            break
        endif 
    endfor

    print, "CO indexlocation: ", coLocation

    ; Read in CO from array
    array1 = returnValues (file1,"surf_emiss")
    array2 = returnValues (file2,"surf_emiss")
    
    arraySize = size(array1,/dimensions)
    coArray1 = fltarr(arraySize[0], arraySize[1])
    coArray2 = fltarr(arraySize[0], arraySize[1])
    
    ; extract only CO
    coArray1[*,*] = array1[*,*,coLocation]
    coArray2[*,*] = array2[*,*,coLocation]

    ; now we have total CO emissions for both cases: coArray1, coArray2
    ; and total biogenic emissions for both cases: tempArray1, tempArray2
    ; subtract them
    diffArray1 = coArray1 - tempArray1
    diffArray2 = coArray2 - tempArray2

    ; now get the ratios
    tempDiffArray1 = diffArray1[*,*]
    tempDiffArray2 = diffArray2[*,*]
    arraySizeFlat = arraySize[0] * arraySize[1]

    tempDiffArray1 = reform(tempDiffArray1,arraySizeFlat)
    tempDiffArray2 = reform(tempDiffArray2,arraySizeFlat)
    arrayRatio = fltarr (arraySizeFlat)
    arrayRatio = calculateRatios (tempDiffArray1, tempDiffArray2, arrayRatio, largeValue, diag)

    ; reform the areas back to lonxlat
    tempDiffArray1 = reform(tempDiffArray1, arraySize[0], arraySize[1])
    tempDiffArray2 = reform(tempDiffArray2, arraySize[0], arraySize[1])
    arrayRatio = reform(arrayRatio, arraySize[0], arraySize[1])
    levels = returnMaxLevels (tempDiffArray1, tempDiffArray2)

    createThreePanelXYPlot, "surf_emiss_totalCO-biogenicCO_" + month, levels, tempDiffArray1, tempDiffArray2, $
      arrayRatio, lon, lat, exp1, exp2, "surf_emiss_totalCO-biogenicCO_", year1, year2, postScript

end



pro GmiAmonthly, file1, file2, exp1, exp2, month, year1, year2, postScript, diag

   if (diag eq 1) then print, "Start GmiAmonthly"

   ; plot 2D fields
;   plotFlashRates, file1, file2, exp1, exp2, month, year1, year2, postScript, diag
;   plot2DSpecies, file1, file2, exp1, exp2, "dry_depos", "drydep_spc_labels", month, year1, year2, postScript, diag
;   plot2DSpecies, file1, file2, exp1, exp2, "wet_depos", "wetdep_spc_labels", month, year1, year2, postScript, diag
   plot2DSpecies, file1, file2, exp1, exp2, "surf_emiss", "emiss_spc_labels", month, year1, year2, postScript, diag
   plot2DSpecies, file1, file2, exp1, exp2, "surf_emiss2", "emiss_spc_labels2", month, year1,year2,  postScript, diag
   ;plotCOEmissions, file1, file2, exp1, exp2, month, year1, year2, postScript, diag

                             
;   do3DPlotting, "lightning_nc", file1, file2, exp1, exp2, month, year1, year2, postScript, diag
       
   stratSpeciesFile = 'amonthly.const.strat.txt'
   tropSpeciesFile = 'amonthly.const.trop.txt'
   species2DFile = 'amonthly.const.2d.txt'
   plot3DSpecies, file1, file2, exp1, exp2, "const", "const_labels", month, year1, year2, $ 
     postScript, diag, stratSpeciesFile=stratSpeciesFile, tropSpeciesFile=tropSpeciesFile, $
     species2DFile=species2DFile



return
end





