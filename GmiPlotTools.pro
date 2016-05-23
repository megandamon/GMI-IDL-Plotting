pro plotIdailySpecies, file1, file2, exp1, exp2, variableName, speciesLabelsName, refMonth, month, year1, year2, $ 
                   postScript, diag, stratSpeciesFile=stratSpeciesFile, tropSpeciesFile=tropSpeciesFile, $
                   species2DFile=species2DFile

    if (diag eq 1) then print, "start plotIdailySpecies: ", variableName
    largeValue = 9999999

    ; Get variables for plotting
    array1 = returnValues (file1, variableName)
    array2 = returnValues (file2, variableName)

    lon = returnValues (file1, 'longitude_dim')
    lat = returnValues (file1, 'latitude_dim')
    eta_dim = returnValues (file1, 'eta_dim')
    arraySize = n_elements(lon) * n_elements(lat) * n_elements(eta_dim)
    variableShape1 = size(array1,/dimensions)
    variableShape2 = size(array2,/dimensions)
    print, "arraySize: ", arraySize

    ; Check that the number of species are the same
    numSpecies1 = variableShape1(3)
    numSpecies2 = variableShape2(3)
    print, "numSpecies1: ", numSpecies1
    print, "numSpecies2: ", numSpecies2

    if (numSpecies1 ne numSpecies2) then begin
        print, "Species for ", variableName, " are not the same!"
        print, "Num species in file 1: ", numSpecies1
        print, "Num species in file 2: ", numSpecies2
    endif
    speciesLabels1 = string(returnValues (file1,speciesLabelsName))
    speciesLabels1 = trimSpeciesNames(speciesLabels1)
    speciesLabels2 = string(returnValues (file2,speciesLabelsName))
    speciesLabels2 = trimSpeciesNames(speciesLabels2)

    ; loop through largest list of species
    if (numSpecies1 gt numSpecies2 or numSpecies1 eq numSpecies2) then begin
        print, "file 1 has more species or the same."
        numberSpecies = numSpecies1
        speciesLabels = speciesLabels1
        otherLabels = speciesLabels2
    endif else begin
        print, "file 2 has more species"
        numberSpecies = numSpecies2
        speciesLabels = speciesLabels2
        otherLabels = speciesLabels1
     endelse

    if (diag eq 1) then begin
        print, "Number of species: ", numberSpecies
        print, "Species labels: ", speciesLabels
        print, "other labels: ", otherLabels
    endif

    for i=0,numberSpecies-1 do begin
       print, ""
       print, ""
       print, "top of for loop: ", speciesLabels[i]
       otherLocation = returnLocationOfString (speciesLabels[i], otherLabels)
       print, "other location: ", otherLocation
       print, "i: ", i

       if (otherLocation ne -1) then begin
          print, "Species in both files!"
           ; Calculate data size and reform to 1D
           if (numberSpecies eq numSpecies1) then begin
               array1Specie = array1[*,*,*,i]
               array2Specie = array2[*,*,*,otherLocation]
           endif else begin
               array1Specie = array1[*,*,*,otherLocation]
               array2Specie = array2[*,*,*,i]
           endelse

           array1Specie = reform(array1Specie,arraySize)
           array2Specie = tereform(array2Specie,arraySize)
           arrayRatio = fltarr (arraySize)

           arrayRatio = calculateRatios (array1Specie, array2Specie, arrayRatio, largeValue, diag)
           if (diag eq 1) then begin
               print, 'max ratio: ', max(arrayRatio)
               print, 'min ratio: ', min(arrayRatio)
           endif


            ; Reform data back to 3D
           array1Specie = reform(array1Specie, n_elements(lon), n_elements(lat), n_elements(eta_dim))
           array2Specie = reform(array2Specie, n_elements(lon), n_elements(lat), n_elements(eta_dim))
           arrayRatio = reform(arrayRatio, n_elements(lon), n_elements(lat), n_elements(eta_dim))
           
           print, "speciesLabel: ", speciesLabels[i]

           plotIdailyField, variableName+"_"+speciesLabels[i]+"_", array1Specie, array2Specie, arrayRatio, lat, lon, eta_dim, exp1, exp2, refMonth, month, $
            year1, year2, postScript, diag, stratSpeciesFile=stratSpeciesFile, tropSpeciesFile=tropSpeciesFile, species2DFile=species2DFile
            print, "returned from plot3DField2"
           
       endif else begin
           print, speciesLabels[i], " not in both files - will not plot"
       endelse

       print, "bottom of for loop"
    endfor

 end


pro plotIdailyField, variableName, data1, data2, dataRatio, lat, lon, lev, exp1, exp2, refMonth, month, year1, year2, $
                 postScript, diag, stratSpeciesFile=stratSpeciesFile, tropSpeciesFile=tropSpeciesFile, $
                 species2DFile=species2DFile

    if (diag eq 1) then print, "start plotIdailyField"

    ; issues with species happen around these level
    plotLevels=[65,70]
    for i=0,n_elements(plotLevels)-1 do begin

        doSpecie = 0
        if (n_elements(species2DFile) ne 0) then begin
            species2D = readFileLines(species2DFile, diag)
            doSpecie = testArrayForString (variableName, species2D)
        endif else begin doSpecie = 1
        endelse


        if (doSpecie eq 1) then begin
            levelIndex = plotLevels[i]
            contourLevels = returnMaxLevels (data1[*,*,levelIndex], data2[*,*,levelIndex])
            titleString = createTitleUsingLevelIndex(variableName, lev, levelIndex, diag) +"_"
            
            createThreePanelXYPlotIDaily, titleString, contourLevels, data1[*,*,levelIndex], $
              data2[*,*,levelIndex], dataRatio[*,*,levelIndex], lon, lat, exp1, exp2, titleString, $
                                          refMonth, month, year1, year2, postScript
        endif

    end


end
 

pro createThreePanelXYPlotIDaily, fileName, levels, array1, array2, arrayRatios, lon, lat, exp1, exp2, title, $
                                  refMonth, month, year1, year2, postScript

  if (postScript eq 1) then plopen,'ps',color=39,fn=fileName,/portrait ; print to postscript

  call2DXYPlottingRoutines, levels, array1, lon, lat, title + refMonth + year1, exp1, [3,3]
  call2DXYPlottingRoutines, levels, array2, lon, lat, title + month + year2, exp2, [2,3],/noerase


  ;ratioLevels = findgen(15)*0.05+0.65
  ;ratioLevelsNew = [[0],ratioLevels]
  ratioLevels = [0.60,0.80,0.90,0.95,0.98,1.0,1.02,1.05,1.10,1.20,1.40,2.0,10.,1000]
  ratioLevelsNew = [[0],ratioLevels]

  if (exp1 eq exp2 and year1 ne year2) then title = title + year1 + "/" + year2
  if (exp1 ne exp2 and year1 eq year2) then title = title + exp1 + "/" + exp2
  if (exp1 ne exp2 and year1 ne year2) then title = title + exp1 + year1 + "/" + exp2 + year2
  globe_cont_local,arrayRatios,lon,lat,nocontr=1,map_color=0,fixLev=1,lev=ratioLevelsNew, ti=title,frame=[1,3],/noerase
  if (postScript eq 1) then plclose ; close postscript


end


pro plot3DSpecies, file1, file2, exp1, exp2, variableName, speciesLabelsName, month, year1, year2, $ 
                   postScript, diag, stratSpeciesFile=stratSpeciesFile, tropSpeciesFile=tropSpeciesFile, $
                   species2DFile=species2DFile

    if (diag eq 1) then print, "start plot3DSpecies: ", variableName
    largeValue = 9999999

    ; Get variables for plotting
    array1 = returnValues (file1, variableName)
    array2 = returnValues (file2, variableName)
    lon = returnValues (file1, 'longitude_dim')
    lat = returnValues (file1, 'latitude_dim')
    eta_dim = returnValues (file1, 'eta_dim')
    arraySize = n_elements(lon) * n_elements(lat) * n_elements(eta_dim)
    variableShape1 = size(array1,/dimensions)
    variableShape2 = size(array2,/dimensions)
    print, "arraySize: ", arraySize

    ; Check that the number of species are the same
    numSpecies1 = variableShape1(3)
    numSpecies2 = variableShape2(3)
    print, "numSpecies1: ", numSpecies1
    print, "numSpecies2: ", numSpecies2

    if (numSpecies1 ne numSpecies2) then begin
        print, "Species for ", variableName, " are not the same!"
        print, "Num species in file 1: ", numSpecies1
        print, "Num species in file 2: ", numSpecies2
    endif
    speciesLabels1 = string(returnValues (file1,speciesLabelsName))
    speciesLabels1 = trimSpeciesNames(speciesLabels1)
    speciesLabels2 = string(returnValues (file2,speciesLabelsName))
    speciesLabels2 = trimSpeciesNames(speciesLabels2)

    ; loop through largest list of species
    if (numSpecies1 gt numSpecies2 or numSpecies1 eq numSpecies2) then begin
        print, "file 1 has more species or the same."
        numberSpecies = numSpecies1
        speciesLabels = speciesLabels1
        otherLabels = speciesLabels2
    endif else begin
        print, "file 2 has more species"
        numberSpecies = numSpecies2
        speciesLabels = speciesLabels2
        otherLabels = speciesLabels1
     endelse

    if (diag eq 1) then begin
        print, "Number of species: ", numberSpecies
        print, "Species labels: ", speciesLabels
        print, "other labels: ", otherLabels
    endif

    for i=0,numberSpecies-1 do begin
       print, ""
       print, ""
       print, "top of for loop: ", speciesLabels[i]
       otherLocation = returnLocationOfString (speciesLabels[i], otherLabels)
       print, "other location: ", otherLocation
       print, "i: ", i

;       if (otherLocation ne -1 and otherLocation eq i) then begin
       if (otherLocation ne -1) then begin

          print, "Species in both files!!"
          
           ; Calculate data size and reform to 1D
           if (numberSpecies eq numSpecies1) then begin
               array1Specie = array1[*,*,*,i]
               array2Specie = array2[*,*,*,otherLocation]
           endif else begin
               array1Specie = array1[*,*,*,otherLocation]
               array2Specie = array2[*,*,*,i]
           endelse

           array1Specie = reform(array1Specie,arraySize)
           array2Specie = reform(array2Specie,arraySize)
           arrayRatio = fltarr (arraySize)

           arrayRatio = calculateRatios (array1Specie, array2Specie, arrayRatio, largeValue, diag)
           if (diag eq 1) then begin
               print, 'max ratio: ', max(arrayRatio)
               print, 'min ratio: ', min(arrayRatio)
           endif
           

            ; Reform data back to 3D
           array1Specie = reform(array1Specie, n_elements(lon), n_elements(lat), n_elements(eta_dim))
           array2Specie = reform(array2Specie, n_elements(lon), n_elements(lat), n_elements(eta_dim))
           arrayRatio = reform(arrayRatio, n_elements(lon), n_elements(lat), n_elements(eta_dim))
           
           print, "speciesLabel: ", speciesLabels[i]

           plot3DField, variableName+"_"+speciesLabels[i]+"_", array1Specie, array2Specie, arrayRatio, lat, lon, eta_dim, exp1, exp2, month, $
            year1, year2, postScript, diag, stratSpeciesFile=stratSpeciesFile, tropSpeciesFile=tropSpeciesFile, species2DFile=species2DFile
            print, "returned from plot3DField2"
           
       endif else begin
           print, speciesLabels[i], " not in both files - will not plot"
       endelse

       print, "bottom of for loop"
    endfor

end

pro plot2DSpecies, file1, file2, exp1, exp2, variableName, speciesLabelsName, month, year1, year2, postScript, diag

    if (diag eq 1) then print, "start plot2DSpecies: ", variableName
    largeValue = 99999999
   

    ; Get variables for plotting
    array1 = returnValues (file1,variableName)
    array2 = returnValues (file2,variableName)
    speciesLabels = string(returnValues (file1,speciesLabelsName))
    
    ; Check that arrays are the same size
    variableShape1 = size(array1,/dimensions)
    variableShape2 = size(array2,/dimensions)
    if (where(variableShape1 ne variableShape2) ne -1) then begin
        print, "Dimensions for ", variableName, " are not the same!"
        return
    endif

    speciesLabels = strcompress(speciesLabels)
    print, speciesLabels

    
    numberSpecies = variableShape1[2]
    if (diag eq 1) then print, "Number of species: ", numberSpecies

    lon = returnValues (file1, 'longitude_dim')
    lat = returnValues (file1, 'latitude_dim')
    arraySize = n_elements(lon) * n_elements(lat)

    arrayRatio = fltarr (arraySize)
    for i=0,numberSpecies-1 do begin
        tempArray1 = array1[*,*,i]
        tempArray2 = array2[*,*,i]
        tempArray1 = reform(tempArray1,arraySize)
        tempArray2 = reform(tempArray2,arraySize)
        arrayRatio = calculateRatios (tempArray1, tempArray2, arrayRatio, largeValue, diag)

        if (diag eq 1) then begin
            print, 'max ratio: ', max(arrayRatio)
            print, 'min ratio: ', min(arrayRatio)
        endif

        ; Reform data back to 2D lonxlat
        tempArray1 = reform(tempArray1, n_elements(lon), n_elements(lat))
        tempArray2 = reform(tempArray2, n_elements(lon), n_elements(lat))
        arrayRatio = reform(arrayRatio, n_elements(lon), n_elements(lat))
        levels = returnMaxLevels (tempArray1, tempArray2)

        specieLabel = strmid(speciesLabels[i],0,strlen(speciesLabels[i])-1)
        if (variableName eq "ColumnMass_AerDust") then begin
            specieLabel = strjoin(strsplit(specieLabel, /extract), '_') 
            specieLabel = strsplit(specieLabel,"(",/extract)
            specieLabel = specieLabel[0]
            specieLabel = strmid(specieLabel,0,strlen(specieLabel)-1)
        endif
        print, "specieLabel: ", specieLabel

        createThreePanelXYPlot, variableName + "_" + specieLabel + "_" + month, levels, tempArray1, tempArray2, $
          arrayRatio, lon, lat, exp1, exp2, variableName + "_" + specieLabel + "_" , year1, year2, postScript

    endfor

end

pro adjustPlotPlacement, frame

   if (n_elements(frame) eq 0) then frame = [1,1]
   !p.position = [.14,.08,.88,.87] 

   left = !p.position(0)
   rght = !p.position(2)
   top = !p.position(3)
   bot = !p.position(1)
   del = .04			;half distance between plots
   dtop = 1-top-del             ;start down from top
   dbot = bot-del  		;start up from bottom
   tf = 1.-dtop-dbot		;total frame available top to bottom
   tfs = 1.-rght-left		;total frame available left to right
   case frame(1) of
       1: !p.position = [left,dbot+del,.88,1-dtop-del]
       2: if(frame(0) eq 1) then !p.position = [left,dbot+del,rght,tf/2.+dbot-del] $
          else !p.position = [left,tf/2.+dbot+del,rght,1-dtop-del]
       3: if(frame(0) eq 1) then !p.position = [left,dbot+del,rght,tf/3.+dbot-del] $
          else if(frame(0) eq 2) then !p.position = [left,tf/3.+dbot+del,rght,2*(tf/3.)+dbot-del] $
          else !p.position = [left,2*(tf/3.)+dbot+del,rght,1-dtop-del]
       4: if(quad) then begin
           if(frame(0) eq 1) then !p.position = [left,dbot+del,.5-del,tf/2.+dbot-del] $
           else if(frame(0) eq 2) then !p.position = [.5+2*del,dbot+del,rght,tf/2.+dbot-del] $
           else if(frame(0) eq 3) then !p.position = [left,tf/2.+dbot+del,0.5-del,1-dtop-del] $
           else !p.position = [.5+2*del,tf/2.+dbot+del,rght,1-dtop-del]
           end $
       else begin
           if(frame(0) eq 1) then !p.position = [left,dbot+del,rght,tf/4.+dbot-del] $
           else if(frame(0) eq 2) then !p.position = [left,tf/4.+dbot+del,rght,2*(tf/4.)+dbot-del] $
           else if(frame(0) eq 3) then !p.position = [left,2*(tf/4.)+dbot+del,rght,3*(tf/4.)+dbot-del] $
           else !p.position = [left,3*(tf/4.)+dbot+del,rght,1-dtop-del]
       end
   else: begin
       print,'frame parameter is to be used as:'
       print,'  two element array where first element is which plot to draw'
       print,'  and second is total number of plots in frame'
       print,'  all plots will take up full width and be stacked from bottom up'
       return
      end
   endcase
end



pro plotConstantArray, levels, array, lon, lat, title, frame, noerase=noerase
   print, "Plot constant array: ", title  
   if(n_elements(noerase) eq 0) then noer = 0  else  noer = noerase
   adjustPlotPlacement, frame

   if (!d.name ne 'PS' ) then cps = 0
   if (!d.name eq 'PS' ) then cps = 1

   badplt = 1e20

   ; create lon and lat deltas
   lon_rsn = lon(1)-lon(0)
   lat_rsn = lat(1)-lat(0)

   ;... set up temp array and copy 1st lon to make wrap around globe
   sz = size(array)
   blon = min(lon)
   elon = max(lon)
   if(elon+lon_rsn-360 eq blon) then begin
       temp = fltarr(sz(1)+1,sz(2))
       tempx = [lon,lon(0)+360]
       for n=0,sz(2)-1 do temp(*,n) = [array(*,n),array(0,n)]
   end $
   else begin
       temp = array
       tempx = lon
   end
   tempy = lat

   ind = where(temp ne badplt,cnt)
   if(cnt lt 3) then begin 
       print,'Almost all values marked as bad... will not contour'
       return
   end
   max0 = max(temp(ind))
   min0 = min(temp(ind))


   case max(tempx)-min(tempx) of
       360: xtickv = -180+findgen(15)*60
       else: xtickv = findgen(100)*fix(max(tempx)-min(tempx))/5+fix(min(tempx))
   endcase
   xtickv = xtickv(where(xtickv ge min(tempx) and xtickv le max(tempx)))
   xticks = n_elements(xtickv)-1
   case max(tempy)-min(tempy) of
       180: ytickv = findgen(7)*30-90
       else: ytickv = findgen(100)*fix(nice(max(tempy)-min(tempy))/4)+fix(min(tempy))
   endcase
   ytickv = ytickv(where(ytickv ge min(tempy) and ytickv le max(tempy)))
   yticks = n_elements(ytickv)-1

   ;... print longitude title only for bottom plot
   if(frame(0) eq 1) then xtitle = 'Longitude'  else xtitle = ''
   if(frame(0) eq 2 and frame(1) eq 4) then xtitle = 'Longitude'
   ytitle='Latitude'
   if(frame(1) eq 4 and (frame(0) eq 2 or frame(0) eq 4)) then ytitle = ''

  levelsTemp = [0,levels[1]]
  print, levelsTemp
  color_index = [0,50,100,70,110,170,140,190,210,200,220,240,230,245,253,250,254,0]
  contour,temp,tempx,tempy,xr=[min(tempx),max(tempx)],yr=[min(tempy),max(tempy)] $
    ,xs=1,ys=1,xticks=xticks,xmin=3,yticks=yticks,ymin=3,title=title,/cell $
    ,c_colors=color_index,lev=levelTemp,/foll,xtitle=xtitle,ytitle=ytitle $
    ,noerase=noer,xtickv=xtickv,ytickv=ytickv,yticklen=-.02,xticklen=-.02 

  map_color = 0
  usa = 0
  map_set,0,(max(tempx)+min(tempx))/2,/noeras,color=map_color,/cont,/cyl $
    ,lim=[min(tempy),min(tempx),max(tempy),max(tempx)],/noborder,usa=usa

  ;... draw scale boxes
  charsize = 1
  xax0 = (!p.position(2)+.010+.055/frame(1))*!d.x_size
  xax1 = (!p.position(2)+.015+.082/frame(1))*!d.x_size
  yax0 = !p.position(1)*!d.y_size
  yax1 = !p.position(3)*!d.y_size
  temp = magnitude(max(levels))
  temp = temp(0)
  atemp = abs(temp)
  dum = (atemp/3)+(min([1,(atemp mod 3)]))
  if(temp gt 0) then dum = dum-1
  if(atemp eq 0) then temp = 0   else temp = 3*dum*temp/atemp
  csize = charsize
  clvls = levels
  if(temp gt 2 or temp lt -2) then begin
    clvls = levels/(10.^temp)
    xyouts,xax1,yax1+6,/dev, $
	'x10!U'+strtrim(temp,2),charsize=csize*0.62,ali=1,_extra=uextra
    miny = min0/(10.^temp)
    maxy = max0/(10.^temp)
   end
;... draw scale box and labels
  xpf = [xax0+1,xax1,xax1,xax0+1,xax0+1]
  range = n_elements(levels)
  yinc = (yax1-yax0)/(range-1)
  for c=0,range-2 do begin
    ypf = [yax0+c*yinc,yax0+c*yinc,yax0+(c+1)*yinc,yax0+(c+1)*yinc,yax0+c*yinc]
    polyfill,xpf,ypf,/dev,color=color_index(c)
    plot,xpf,ypf,/dev,/noerase,xstyle=5,ystyle=5,xticks=1,xminor=0 $
	,xrange=[xax0,xax1],yrange=[yax0,yax1],pos=[xax0,yax0,xax1,yax1] $
	,yticks=1,yminor=0

    dum1 = magnitude(clvls(c+1)-clvls(c))
    case dum1(0) of 
      -4: strtmp = string(clvls(c),f='(f8.4)')
      -3: strtmp = string(clvls(c),f='(f7.3)')
      -2: strtmp = string(clvls(c),f='(f6.2)')
      -1: strtmp = string(clvls(c),f='(f5.1)')
      else: strtmp = strtrim(round(clvls(c)),2)
     endcase
;    if(dum1(0) eq -2) then strtmp = string(clvls(c),f='(f6.2)') $
;     else if(dum1(0) lt 0) then strtmp = string(clvls(c),f='(f6.2)') $
;     else strtmp = strtrim(round(clvls(c)),2)
    xyouts,xax0,yax0+c*yinc-5,strtmp,charsize=csize*0.6,ali=1,/dev,_extra=uextra
   end
  c = range-1
  dum1 = magnitude(clvls(c)-clvls(c-1))
  case dum1(0) of 
    -4: strtmp = string(clvls(c),f='(f8.4)')
    -3: strtmp = string(clvls(c),f='(f7.3)')
    -2: strtmp = string(clvls(c),f='(f6.2)')
    -1: strtmp = string(clvls(c),f='(f5.1)')
    else: strtmp = strtrim(round(clvls(c)),2)
   endcase


  xyouts,xax0-3,yax0+c*yinc-5,strtmp,charsize=csize*0.6,ali=1,/dev,_extra=uextra



end

pro call2DXYPlottingRoutines, levels, array, lon, lat, title, exp, frame, noerase=noerase

    if (min(array) eq max(array)) then begin
        plotConstantArray, levels, array, lon, lat, title + " " + exp, frame,noerase=noerase
    endif else begin
        globe_cont_local,array,lon,lat,nocontr=1,map_color=33,fixlev=1,lev=levels,ti=title + " " + exp,frame=frame,noerase=noerase
    endelse

end

pro createThreePanelXYPlot, fileName, levels, array1, array2, arrayRatios, lon, lat, exp1, exp2, title, year1, year2, postScript

  if (postScript eq 1) then plopen,'ps',color=39,fn=fileName,/portrait ; print to postscript

  call2DXYPlottingRoutines, levels, array1, lon, lat, title + year1, exp1, [3,3]
  call2DXYPlottingRoutines, levels, array2, lon, lat, title + year2, exp2, [2,3],/noerase

  
    ;ratioLevels = createRatioContourLevels(array1, array2, arrayRatios, 1.35)
    ;ratioLevelsNew = [[0],ratioLevels]
    ;ratioLevels = [0.65,0.70,0.75,0.80,0.85,0.90,0.95,0.98,1.0,1.02,1.05,1.10,1.15,1.20,1.25,1.30,1.35]
    ;ratioLevelsNew = [[0],ratioLevels]
    ;ratioLevels = findgen(15)*0.05+0.65

  ratioLevels = [0.60,0.80,0.90,0.95,0.98,1.0,1.02,1.05,1.10,1.20,1.40,2.0,10.,1000]
  ratioLevelsNew = [[0],ratioLevels]


    if (array_equal(array1,array2)) then begin
        print, "Arrays are the same.  Will not plot ratios XY"
    endif else begin
        if (exp1 eq exp2 and year1 ne year2) then title = title + year1 + "/" + year2
        if (exp1 ne exp2 and year1 eq year2) then title = title + exp1 + "/" + exp2
        if (exp1 ne exp2 and year1 ne year2) then title = title + exp1 + year1 + "/" + exp2 + year2
        globe_cont_local,arrayRatios,lon,lat,nocontr=1,map_color=0,fixLev=1,lev=ratioLevelsNew, ti=title,frame=[1,3],/noerase
    endelse
    if (postScript eq 1) then plclose                     ; close postscript


end

pro do3DPlottingWithRecords, variableName, file1, file2, exp1, exp2, month, year1, year2, postScript, diag
   if (diag eq 1) then print, "start do3DPlottingWithRecords"
   largeValue = 999999999

   lon = returnValues (file1, 'longitude_dim')
   lat = returnValues (file1, 'latitude_dim')
   lev = returnValues (file1, 'eta_dim')
   array1Records = returnValues (file1, variableName)
   array2Records = returnValues (file2, variableName)

   arrayDims = size(array1Records,/dimensions)
   numberOfRecords = arrayDims[3]

   if (variableName eq "overheadO3col_overpass") then begin
      numberOfRecords = 1
   endif

   print, numberOfRecords, " records for the variable: ", variableName

   arraySize = n_elements(lon) * n_elements(lat) * n_elements(lev)
   arrayRatio = fltarr (arraySize)
   for i=0,numberOfRecords-1 do begin
       array1 = array1Records[*,*,*,i]
       array2 = array2Records[*,*,*,i]
       array1 = reform(array1,arraySize)
       array2 = reform(array2,arraySize)
       arrayRatio = calculateRatios (array1, array2, arrayRatio, largeValue, diag)

       ; Reform data back to 3D lon x lat x lev
       array1 = reform(array1, n_elements(lon), n_elements(lat), n_elements(lev))
       array2 = reform(array2, n_elements(lon), n_elements(lat), n_elements(lev))
       arrayRatio = reform(arrayRatio, n_elements(lon), n_elements(lat), n_elements(lev))
       dayString = strmid(strcompress(string(i+1)),1,strlen(string(i)-1))
       if (i lt 9) then begin
           dayString = '0' + dayString
       endif
       dayString = "day" + dayString + "_"

       plot3DField, variableName+dayString,array1, array2, arrayRatio, lat, lon, lev, exp1, exp2, month, year1, year2, postScript, diag
       print, "returned from plot3DField3"
   end

end

pro do3DPlotting, variableName, file1, file2, exp1, exp2, month, year1, year2, postScript, diag
   if (diag eq 1) then print, "start do3DPlotting"
   largeValue = 999999999

   ; Get necessary variables for plotting
   array1 = returnValues (file1, variableName)
   array2 = returnValues (file2, variableName)
   lon = returnValues (file1, 'longitude_dim')
   lat = returnValues (file1, 'latitude_dim')
   lev = returnValues (file1, 'eta_dim')

    ; Calculate data size and reform to 1D
    arraySize = n_elements(lon) * n_elements(lat) * n_elements(lev)
    array1 = reform(array1,arraySize)
    array2 = reform(array2,arraySize)
    arrayRatio = fltarr (arraySize)

    arrayRatio = calculateRatios (array1, array2, arrayRatio, largeValue, diag)

    ; Reform data back to 3D lon x lat x lev
    array1 = reform(array1, n_elements(lon), n_elements(lat), n_elements(lev))
    array2 = reform(array2, n_elements(lon), n_elements(lat), n_elements(lev))
    arrayRatio = reform(arrayRatio, n_elements(lon), n_elements(lat), n_elements(lev))

    plot3DField, variableName +"_",array1, array2, arrayRatio, lat, lon, lev, exp1, exp2, month, year1, year2, postScript, diag
    print, "returned from plot3DField1"

end

pro plot3DField, variableName, data1, data2, dataRatio, lat, lon, lev, exp1, exp2, month, year1, year2, $
                 postScript, diag, stratSpeciesFile=stratSpeciesFile, tropSpeciesFile=tropSpeciesFile, $
                 species2DFile=species2DFile

    if (diag eq 1) then print, "start plot3DField"

    ; plot surface, 500 mb, and 200 mb
    plotLevels=[1000,500,200]
    plotLevels=[720,505,226]
    for i=0,n_elements(plotLevels)-1 do begin

        doSpecie = 0
        if (n_elements(species2DFile) ne 0) then begin
            species2D = readFileLines(species2DFile, diag)
            doSpecie = testArrayForString (variableName, species2D)
        endif else begin doSpecie = 1
        endelse

        ;print, "doSpecie1 = ", doSpecie

        
        if (doSpecie eq 1) then begin
            levelIndex = getClosestLevelIndex (lev, plotLevels[i], diag)
            ;print, "levelIndex: ", levelIndex

            contourLevels = returnMaxLevels (data1[*,*,levelIndex], data2[*,*,levelIndex])

            titleString = createTitleUsingLevel(variableName+month, lev, levelIndex, diag) +"mb_"
            ;print, titleString

            createThreePanelXYPlot, titleString, contourLevels, data1[*,*,levelIndex], $
              data2[*,*,levelIndex], dataRatio[*,*,levelIndex], lon, lat, exp1, exp2, titleString, year1, year2, postScript

        endif

     end

    ; Latitude-height (log pressure), 1000-100 hPa
    levelIndex1 = getClosestLevelIndex (lev, 1000, diag)
    levelIndex2 = getClosestLevelIndex (lev, 100, diag)

    doSpecie = 0
    if (n_elements(tropSpeciesFile) ne 0) then begin
        tropSpecies = readFileLines(tropSpeciesFile, diag)
        doSpecie = testArrayForString (variableName, tropSpecies)
    endif else begin doSpecie = 1
    endelse
    print, "doSpecie2 = ", doSpecie

    if (doSpecie eq 1) then begin
        title1 = variableName+month+"_"
        createThreePanelZonalMeanPlot, title1+"trop", data1[*,*,levelIndex1:levelIndex2], data2[*,*,levelIndex1:levelIndex2], $
          dataRatio[*,*,levelIndex1:levelIndex2], lat, lev[levelIndex1:levelIndex2], exp1, exp2, title1, year1, year2, "Pressure (1000-100hPa)",postScript

    endif
                            
    ; Latitude-height (log pressure), 100-1 hPa
    levelIndex3 = getClosestLevelIndex (lev, 1, diag)

    doSpecie = 0
    if (n_elements(stratSpeciesFile) ne 0) then begin
        stratSpecies = readFileLines(stratSpeciesFile, 1)
        doSpecie = testArrayForString (variableName, stratSpecies)
    endif else begin doSpecie = 1
    endelse
    print, "doSpecie3 = ", doSpecie
    if (doSpecie eq 1) then begin
        title1 = variableName+month+"_"
        createThreePanelZonalMeanPlot, title1+"strat", data1[*,*,levelIndex2:levelIndex3], data2[*,*,levelIndex2:levelIndex3], $
          dataRatio[*,*,levelIndex2:levelIndex3], lat, lev[levelIndex2:levelIndex3], exp1, exp2, title1, year1, year2, "Pressure (100-1hPa)",postScript
    endif

end


pro call2DZonalPlottingRoutines, array, lat, lev, maxLevels, title, exp, frame, ytitle, noerase=noerase

    if (min(array) eq max(array)) then begin
        plotConstantArray, maxLevels, array, lat, lev, title + " " + exp, frame,noerase=noerase
    endif else begin
        vert_cont,array,lat,lev,fixlev=1,lev=maxLevels,nocontr=1,title=title + " " + exp,frame=frame,ytitle=ytitle,noerase=noerase
    endelse

end


pro createThreePanelZonalMeanPlot, fileName, array1, array2, arrayRatios, lat, lev, exp1, exp2, title, year1, year2, ytitle, postScript
 
   largeValue = 9999999
   print, "file name: ", fileName
   if (postScript eq 1) then plopen,'ps',color=39,fn=fileName,/portrait ; print to postscript

   zonalArray1 = zonalavg(array1)
   zonalArray2 = zonalavg(array2)
   zonalRatios = zonalArray1/zonalArray2
 
   maxLevels = returnMaxLevels (zonalArray1, zonalArray2)
  
   call2DZonalPlottingRoutines, zonalArray1, lat, lev, maxLevels, title + year1, exp1, [1,3], ytitle
   call2DZonalPlottingRoutines, zonalArray2, lat, lev, maxLevels, title + year2, exp2, [2,3], ytitle, /noerase 
 

   ;ratioLevels = findgen(15)*0.05+0.65
   ;ratioLevelsNew = [[0],ratioLevels]
   ;ratioLevels = createRatioContourLevels(array1, array2, arrayRatios, 1.35)
   ;ratioLevels = [0.65,0.70,0.75,0.80,0.85,0.90,0.95,0.98,1.0,1.02,1.05,1.10,1.15,1.20,1.25,1.30,1.35]
   
   ratioLevels = [0.60,0.80,0.90,0.95,0.98,1.0,1.02,1.05,1.10,1.20,1.40,2.0,10.,1000]
   ratioLevelsNew = [[0],ratioLevels]

   if (array_equal(zonalArray1,zonalArray2)) then begin
       print, "Arrays are the same.  Will not plot ratios of zonal means"
   endif else begin
        if (exp1 eq exp2 and year1 ne year2) then title = title + year1 + "/" + year2
        if (exp1 ne exp2 and year1 eq year2) then title = title + exp1 + "/" + exp2
        if (exp1 ne exp2 and year1 ne year2) then title = title + exp1 + year1 + "/" + exp2 + year2
       vert_cont,zonalRatios,lat,lev,fixlev=1,lev=ratioLevelsNew,nocontr=1,title=title,frame=[3,3],ytitle=ytitle,/noerase
   endelse
   

    if (postScript eq 1) then plclose                     ; close postscript
   
end

