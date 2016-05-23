pro GmiPlotEmissions, fileName, fileName2, month, vLevelDimName, exp, exp2, postScript, diag, maxPressValue

   if (n_params() eq 0 or n_params() ne 9) then begin
       print, "Usage: GmiPlotEmissions emiss_fileName, fileName2, month, vertical level name, exp, exp2, postScript (1/0), diag(1/0), max pressure value to plot"
       print, "month should be in format: January, February, etc."
       stop
   end

   ; set font to device font
   !p.font=0

   checkFile, fileName, diag
   checkFile, fileName2, diag

   ; read in emiss array
   emissArray = returnValues(fileName,"emiss_2d")
   emissSize = size(emissArray,/dimensions)
   print, size(emissArray,/dimensions)

   ; read in emiss array2
   emissArray2 = returnValues(fileName2,"emiss_2d")
   emissSize2 = size(emissArray2,/dimensions)
   print, size(emissArray2,/dimensions)

   ; read in month names
   months = string(returnValues(fileName,"month"))
   months = trimSpeciesNames(months)

   ; get species labels
   speciesLabels = string(returnValues(fileName,"species"))
   speciesLabels = trimSpeciesNames(speciesLabels)
   numberSpecies = n_elements(speciesLabels)

   ; read in lat, lon, and vertical levels
   lat = returnValues(fileName,"latitude_dim")
   lon = returnValues(fileName,"longitude_dim")
   vLevels = returnValues(fileName, vLevelDimName)

   monthRecord = -1
   for i=0,emissSize[3] do begin
       print, months[i], "**"
       if (months[i] eq month) then begin
           monthRecord = i
           break
       endif
   endfor

   if (monthRecord eq -1) then begin
       print, "Aborting in error - month not found"
       return
   endif

   for i=0,numberSpecies-1 do begin
      
      emissArrayMonth = emissArray[*,*,i,monthRecord]
      emissArrayMonth2 = emissArray2[*,*,i,monthRecord]
      
      print, speciesLabels[i]

      print, "size of emissArrayMonth: ", size(emissArrayMonth,/dimensions)
      print, "size of emissArrayMonth2: ", size(emissArrayMonth2,/dimensions)

      arraySize =  size(emissArrayMonth,/N_ELEMENTS)
      arraySize2 =  size(emissArrayMonth2,/N_ELEMENTS)

      print, "arraySize: ", arraySize
      print, "arraySize2: ", arraySize2

      tempArray = emissArrayMonth[*,*]
      tempArray2 = emissArrayMonth2[*,*]
      tempArray = reform(tempArray,arraySize)
      tempArray2 = reform(tempArray2,arraySize2)
      arrayRatio = fltarr (arraySize)
      arrayRatio = calculateRatios (tempArray, tempArray2, arrayRatio, 99999999, diag)
      
      arrayDims = size(emissArrayMonth,/DIMENSIONS)
      print, arrayDims[0]
      print, arrayDims[1]

      tempArray= reform(tempArray, arrayDims[0], arrayDims[1])
      tempArray2= reform(tempArray2, arrayDims[0], arrayDims[1])
      arrayRatio = reform(arrayRatio, arrayDims[0], arrayDims[1])
      levels = returnMaxLevels (tempArray, tempArray2)


      title = months[monthRecord]+ "_" + speciesLabels[i]
      ; one file for each specie
      if (postScript eq 1) then plopen,'ps',color=39,fn=title,/portrait

      ; plot surface
      surfaceContours = createContoursFromArray(emissArrayMonth[*,*])
      call2DXYPlottingRoutines, surfaceContours, emissArrayMonth[*,*], lon, lat, title+'_surface', exp, [3,3]

;      call2DXYPlottingRoutines, levels, emissArrayMonth[*,*], lon, lat, title+'_surface', exp, [3,3]

      surfaceContours = createContoursFromArray(emissArrayMonth2[*,*])
      call2DXYPlottingRoutines, surfaceContours, emissArrayMonth2[*,*], lon, lat, title+'_surface', exp2, [2,3], /noerase

;      call2DXYPlottingRoutines, levels, emissArrayMonth2[*,*], lon, lat, title+'_surface', exp2, [2,3], /noerase

      ratioLevels = [0.60,0.80,0.90,0.95,0.98,1.0,1.02,1.05,1.10,1.20,1.40,2.0,10.,1000]
      ratioLevelsNew = [[0],ratioLevels]

      globe_cont_local,arrayRatio,lon,lat,nocontr=1,map_color=0,fixLev=1,lev=ratioLevelsNew, ti=title,frame=[1,3],/noerase

;      if (array_equal(emissArrayMonth,emissArrayMonth2)) then begin
;         print, "Arrays are the same.  Will not plot ratios XY"
;      endif else begin
;        globe_cont_local,arrayRatios,lon,lat,nocontr=1,map_color=0,fixLev=1,lev=ratioLevelsNew, ti=title,frame=[1,3],/noerase
;    endelse


       
      if (postScript eq 1) then plclose
   endfor
   

   stop

   if (diag eq 1) then begin 
       emissMonth = emissArray[*,*,*,*,monthRecord]
       print, "Budget for: ", monthRecord, ", ", months[monthRecord], " is ", total(emissMonth,/double)
       sumArray= dblarr (emissSize[0], emissSize[1], emissSize[2])
       print, "size of sum array: ", size(sumArray,/dimensions)

       ; report budgets for each species
       print, months[monthRecord], " budget for all species"
       for i=0,numberSpecies-1 do begin
           title = speciesLabels[i]
           emissArraySpecie = emissArray[*,*,*,i,monthRecord]
           sumArray = sumArray[*,*,*] + emissArraySpecie
           print, title, total(emissArraySpecie[*,*,*], /double)
       endfor
   
       print, "Budget as calculated: ", total(sumArray)
       print, "Budget as calculated: ", total(sumArray, /double)
   endif
   

end

