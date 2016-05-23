function zonalavg,datain,badval,badval=badval1,minnumpct=minnumpct
;+
; NAME:
;	zonalavg
; PURPOSE:
;	calculate the zonal average of a 2-d or 3-d field
; CATEGORY:
;	General Utility
; CALLING SEQUENCE:
;	za = zonalavg(arr,bad=bad)
; INPUT PARAMETERS:
;	arr	= 
; OPTIONAL INPUT PARAMETERS:
;	badval	= bad value flag
; KEYWORD PARAMETERS:
;	badval1	= bad value flag - takes precedence over badval
;	minnumpct= minimum percentage of values in zonal that will be 
;		   used in zonal average - bad value filled otherwise
; OUTPUT PARAMETERS:
;	za	= zonal average of arr
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
;	should pass 2 or more dim array, the first of which is longitude
; PROCEDURE:
; REQUIRED ROUTINES:
; MODIFICATION HISTORY:
;	Stephen D. Steenrod - Jun 95 - documented
;-

if(n_elements(badval1) ne 0) then badval = badval1
if(n_elements(minnumpct) eq 0) then minnumpct = 50

sz = size(datain)
case sz(0) of
  0: return,datain
  1: return,avg(datain)
  2: d3 = 1
  else: d3 = sz[3]
 end
;if(sz(0) eq 2) then d3 = 1 else d3 = sz(3)

case sz(sz(0)+1) of
 2: temp = intarr(sz[2],d3)
 3: temp = lonarr(sz[2],d3)
 4: temp = fltarr(sz[2],d3)
 5: temp = dblarr(sz[2],d3)
 6: temp = complexarr(sz[2],d3)
 else: return,-999
 endcase

for n=0,d3-1 do for j=0,sz[2]-1 do $
  if(n_elements(badval) eq 0) then begin 
     temp[j,n] = avg(datain[*,j,n]) 
   endif else begin
     dum1 = datain[*,j,n]
     ind = where(dum1 ne badval[0],cnt)
     if(cnt gt sz[1]*minnumpct/100) then temp[j,n] = avg(dum1[ind]) $
      else temp[j,n] = badval[0]
   endelse

return,temp
end
