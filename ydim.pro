function ydim, data
; return y dimension (# rows) of a 2D array
  sumr = data(0,*)
  sumr = sumr ge -1.0e20
  nrow = total(sumr)
return, nrow
end

