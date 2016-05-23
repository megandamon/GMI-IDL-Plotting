function xdim, data
; return x dimension (# columns) of a 2D array
  sumc = data(*,0)
  sumc = sumc ge -1.0e20
  ncol = total(sumc)
return, ncol
end

