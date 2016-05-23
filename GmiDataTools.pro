function replaceArrayValues, elements, arrayValues, newValues, diag

    if (diag eq 1) then begin
        if (elements[0] ne -1) then print, "Number of elements to replace", n_elements(elements)
        print, "Size of array: ", n_elements(arrayValues)
    endif
    if (elements[0] ne -1) then begin
        if (diag eq 1 ) then print, "Assigning new array values"
        arrayValues(elements) = newValues
    endif
    return, arrayValues
end

function getClosestLevelIndex, levels, pressure, diag

    if (diag eq 1) then print, "start getClosestLevelIndex [", pressure, "]"

    maxDelta = 999999
    index = -1
    for i=0,n_elements(levels)-1 do begin
        delta = abs(levels[i]-pressure)
        if (delta lt maxDelta) then begin
            maxDelta = delta
            index = i
        endif
    endfor

    return, index
end


function calculateRatios, array1, array2, arrayRatio, largeValue, diag

    if (diag eq 1) then print, "Calculating ratios using ratios"

 ;   arrayRatio = array1 - array2
 ;   return, arrayRatio

 ;end

;function calculateRatiosAppendMe, array1, array2, arrayRatio, largeValue, diag

    ; Assign ratios where non-zeros array elements are found
    nonZeroElements = where(array1 ne 0 and array2 ne 0)
    sizeOfNonZeroArray = size(nonZeroElements)
    if (sizeOfNonZeroArray[0] ne 0) then begin
        arrayRatio = replaceArrayValues (nonZeroElements,  $
                                         arrayRatio, $
                                         array1(nonZeroElements)/array2(nonZeroElements), $
                                         diag )
    endif

    ; Assign arbitraily large number where the denominator is zero
    undefinedElements = where(array2 eq 0 and array1 ne 0)
    sizeOfUndefinedElements = size(undefinedElements)
    if (sizeOfUndefinedElements[0] ne 0) then begin 
    	arrayRatio = replaceArrayValues (undefinedElements, $
       	                              arrayRatio, $
       	                             largeValue, diag )
    endif

    ; Assign 0 if array1 is 0 and array 2 is not
    zeroElements = where(array1 eq 0 and array2 ne 0)
    sizeOfZeroElements = size(zeroElements)
    if (sizeOfZeroElements[0] ne 0) then begin
    	arrayRatio = replaceArrayValues(zeroElements, $
       	                             arrayRatio, $
       	                             0, diag )
    endif

    ; Assign 1 to others
    oneElements = where(array2 eq 0 and array1 eq 0)
    sizeOfOneElements = size(oneElements)
    if (sizeofOneElements[0] ne 0) then begin
	arrayRatio = replaceArrayValues (oneElements, $
       	                              arrayRatio, $
       	                              1, diag )
   endif

    if (diag eq 1) then begin
        print, 'max ratio: ', max(arrayRatio)
        print, 'min ratio: ', min(arrayRatio)
    endif


    return, arrayRatio
end 

                                
; Calculate levels and use the scale
; with the maximum value of the two sets
function returnMaxLevels, array1, array2
    print, "max array1: ", max(array1)
    print, "max array2: ", max(array2)
    if (max(array1) gt max(array2)) then begin
        levels = createContoursFromArray (array1)
    endif else begin
        levels = createContoursFromArray (array2)
    endelse

    print, "levels in returnMax: ", levels
    return, levels
end

function createRatioContourLevels, array1, array2, arrayRatios, maxLevel


   levels = fltarr(16)
   levels(0) = min(arrayRatios)
   maxValue = max(arrayRatios)

   ; is maxValue less than maxLevel?
   if (maxValue lt maxLevel) then begin
       delta = (maxValue - levels(0)) / (n_elements(levels)-1)
       for i=1, n_elements(levels)-1 do begin
           levels(i) = levels(i-1) + delta
       endfor

   endif else begin
       
       ; first half levels are between min val and maxLevel
       topLevel = 7
       delta = (maxLevel - levels(0)) / (topLevel)
       for i=1,7 do begin
           levels(i) = levels(i-1) + delta
           if (levels(i) ge maxLevel) then begin
               topLevel = i
           endif
       endfor

       topRange = maxValue - levels(topLevel)
       numTopLevels = n_elements(levels) - (topLevel+1)
       delta = topRange / numTopLevels
       for i=topLevel+1,n_elements(levels)-1 do begin
           levels(i)  = levels(i-1) + delta
       endfor

       
   endelse

   print, levels
   return, levels
end
