; This routine written by Megan Damon, but based heavily on code
; written by Steve Steenrod

function createContoursFromArray, dataArray,maxValue=maxValue, badValue=badValue,fixLevel=fixLevel, diag=diag

   if n_elements(diag) eq 0 then diag = 0

   if (diag eq 1) then print, "start createContoursFromArray"

   badValue = 1e20
   if(n_elements(fixLevel) eq 0) then fixLevel = 0

   if(n_elements(maxValue) ne 0) then begin
       index = where(dataArray ge maxValue,count)
       if(count gt 0) then dataArray(index) = badValue
   end

   if(n_elements(badValue) ne 0) then begin
       index = where(dataArray eq badValue,badCount)
       if(badCount gt 0) then dataArray(index) = badValue
   end

   index = where(dataArray ne badValue,count)
   if(count lt 3) then begin 
       print,'Almost all values marked as bad.  Check your data'
       return, -1
   end

   maxValue = max(dataArray(index))
   minValue = min(dataArray(index))

   ; contour level increment
   contourInterval = nice((maxValue-minValue)/15)
   if (contourInterval eq 0) then begin
       print, "Contour Interval is 0! "
       return, [minValue,maxValue]
   endif


   ; caused problems when maxValue and minValue differed by less than most sig digit
   intervalMagnitude = magnitude(contourInterval)
   intervalMagnitude = -intervalMagnitude(0)
   minContourValue = long(minValue*10.^intervalMagnitude)
   minContourValue = float(minContourValue)*10.^(-intervalMagnitude)

   while (14*contourInterval+minContourValue lt maxValue) do contourInterval = nice(2*contourInterval)
   levels = findgen(15)*contourInterval+minContourValue
   index2 = where(levels lt max(dataArray(index)))
   levels = levels(index2)

   if(fixLevel eq 0) then begin
       index = where(levels le maxValue and levels ge minValue)
       levels = levels(index)
       if(levels(0) gt minValue) then levels = [levels(0)-(levels(1)-levels(0)),levels]
       lastLevelIndex = n_elements(levels)-1
       if(levels(lastLevelIndex) lt maxValue) then  $
         levels = [levels,levels(lastLevelIndex)+(levels(lastLevelIndex)-levels(lastLevelIndex-1))]
   end
   if(fixLevel eq 0) then levels = [levels,levels(lastLevelIndex)+2*(levels(lastLevelIndex)-levels(lastLevelIndex-1))]

   return, levels

end
