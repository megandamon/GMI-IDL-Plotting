function readFileLines, fileName, diag

   if (diag eq 1) then print, "Reading lines from: ", fileName

   ; make sure the file exits
   result = FILE_TEST(fileName)
    if (result ne 1) then begin
        print, fileName + ' does not exist: ', result
        stop
    end
    

    OPENR,fileUnit,fileName,/GET_LUN
    rows = FILE_LINES(fileName)

    data = strarr(rows)
    while not EOF(fileUnit) do begin
        READf,fileUnit,data
    endwhile
    close,fileUnit
    free_lun,fileUnit

    return, data

end

function returnLocationOfString, string, array
   for i = 0, n_elements(array)-1 do begin
       if (array[i] eq string) then return, i
   endfor

   return, -1
end

function testArrayForString, string, array
  
   ; not sure we need this
   stringLength = strlen(string)
   print, "stringLength: ", stringLength

   strings = STRSPLIT (string, '_', /extract)

   print, "strings: ", strings

   ; different types of strings will be passed to this routine
   ; start with "const" species
   if (strings[0] eq "const") then begin

       if (n_elements(strings) eq 2) then begin
           specie = strings[1]

       endif else if (n_elements(strings) eq 3 and strings[1] eq "Total") then begin
           specie = "Total density"

       
       endif else if (n_elements(strings) eq 3 and strings[1] eq "freq1") then begin
          specie = strings[2]
          print, "freq1 species found!! ", specie

       endif else begin
           print, "PROBLEM: ", string
           print, strings
           stop

       endelse


   endif else if (strings[0] eq "qj") then begin
      print, "qj found!!", string
      print, "num elements: ", n_elements(strings)
      specie = ""
      for i = 1, n_elements(strings)-1 do begin
         specie = specie + strings[i] 
         if (i ne n_elements(strings)-1) then specie = specie + " "
      endfor
      print, "specie: ", specie

   endif else begin
       print, "PROBLEM with non-const string: ", string
       print, strings
       stop
   endelse

   for i = 0, n_elements(array)-1 do begin
       if (array[i] eq specie) then return, 1
   endfor

  return, 0
end
