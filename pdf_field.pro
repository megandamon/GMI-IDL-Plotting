pro pdf_field,field,lonf,latf,lat1=lat1,lat2=lat2,hemis=hemis,dlat=dlat,$
delta=delta,x=x,pdf=pdf,plot=plot,funif=funif,latu=latu,lonu=lonu,$
width=width

; inputs a 2D gridded field (called "field") defined on a grid (lonf,latf),
; interpolates it to a set of points distributed uniformly over the globe,
; within the region bounded by lat1 and lat2 (default -90 to 90), 
; and gets the pdf.

;	Added by SES: pdf_field will recognize that any 'field' values that are
;	less than or equal to 0 are not real, but are bad values. To make these
;	points easily identifiable (even after latloninterp), this program will
;	automatically changes those zeroes to large negative numbers.
;
; this routine calls ~sparling/pdf.pro
; this routine calls ~sparling/gridinit.pro

if (n_elements(delta) eq 0) then delta=1.
if (n_elements(hemis) eq 0) then hemis=0
if (not keyword_set(lat1) ) then lat1=-90
if (not keyword_set(lat2) ) then lat2=90
if (not keyword_set(dlat) ) then dlat=2
if (not keyword_set(width) ) then width=2

;get latu and lonu - these are the lats and lons of a set of points
;uniformly distributed in area

gridinit,[lat2,lat1],dlat,latu,lonu
if (hemis eq -1) then latu=-latu

;get funif(i),the  field at the points (lonu(i), latu(i))

c=where(field le 0)
if c(0) ge 0 then field(c)=-999999

funif=latlonintrp(field,lonf,latf,lonu,latu,/wrap,$
reglat=reglat,reglon=reglon)

;get the pdf of the elements of the 1D vector funif:
; all the bad values have gotten interpolated. Bad values should have been originally
;	set to a large negative number. Set them all back to the large number.
c=where(funif le 0)
if c(0) ge 0 then funif(c)=-99999

if (keyword_set(plot)) then pdf,funif,delta=delta,xvals=x,pvals=pdf,/plot,$
title=' ',width=width  else pdf,funif,delta=delta,xvals=x,pvals=pdf

return
end

