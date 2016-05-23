pro calc_model_pdf,n2o,lat,lon,nbins,incr,minbin,latrange,pdfn2o,xbins,meann2o,most,$
	htrange=htrange,badval=badval
;
;	Written by Susan Strahan (strahan@code916.gsfc.nasa.gov). I am not a
;	professional programmer, but the code does work for me.

;	INPUT FIELDS:
;	'n2o' - This array is a 3D or 4D field for which pdfs will be calculated, 
;	either (lon,lat,lev) or (lon,lat,lev,time).
;	'lat' and 'lon' -  1D arrays containing the appropriate latitudes and longitudes
;	for the 'n2o' array.
;	nbins - the number of bins
;	incr - the size of the bin (e.g., 30 ppb)
;	minbin - the lowest bin (usually 0)
;	latrange - a 2-element array containing the min and max latitude over which
;	the pdfs will be calculated.
 
;	Optional keyword 'htrange' can be used if you don't want to calculate pdfs
;	for all of the vertical levels in 'n2o'. 'htrange' is the array of elements
;	for which to calculate the pdfs. For example, if 'n2o' has 10 vertical levels,
;	but you only want pdfs for the 1st 5, then htrange=[0,1,2,3,4]. (In IDL-speak,
;	htrange=indgen(5) )
;
;	Optional keyword 'badval' used to define any values within the 'n2o' array that
;	are defined as bad (e.g. 9999).
;
;	OUTPUT FIELDS:
;	pdfn2o - array(nbins,lev,time). pdfs of 'n2o'
;	xbins - the x-axis array of mixing ratios for plotting 'pdfn2o'
;	meann2o - area-weighted mean mixing ratio for each pdf.
;	most - most probable value of each pdf.
;
;	-----------------------------------------------------------------------
;
s=size(n2o)
;	s(0) tells whether 3D or 4D array. Third dimension should always be levels.
nk=s(3)
if keyword_set(htrange) then nk=n_elements(htrange) else htrange=indgen(nk)
  
if s(0) eq 4 then nd=s(4)
if s(0) eq 3 then nd=1
;
pdfn2o=fltarr(nbins,nk,nd)
meann2o=fltarr(nk,nd) & most=meann2o
xbins=findgen(nbins)*incr+minbin
;
;
if keyword_set(badval) then begin
  c=where(n2o eq badval)
  if c(0) ge 0 then n2o(c)=-1
endif
;
for t=0,nd-1 do for k=0,nk-1 do begin  
  if s(0) eq 4 then temp=n2o(*,*,htrange(k),t) else temp=n2o(*,*,htrange(k))
;	check for bad values within latrange
  d=where(lat ge latrange(0) and lat le latrange(1) )
  temp2=temp(*,d)
  b=where(temp2 ne -1)
;
;	Don't proceed if 1/4 of the points within latrange are bad.
  if n_elements(b) lt 0.75*n_elements(temp2) then goto, nextk

; if b(0) lt 0 then goto, nextk
  pdf_field,temp,lon,lat,delta=incr,lat1=latrange(0),lat2=latrange(1),x=x,pdf=pdf 
  n=n_elements(x) 
  a=where(x eq minbin-(incr/2.0))
  z=where(xbins ge x(a)) 
  e=n-a(0)-1
  pdfn2o(z(0):z(0)+e,k,t)=pdf(a(0):n-1) 
  meann2o(k,t)=total(pdfn2o(*,k,t)*xbins)
  z=where(pdfn2o(*,k,t) eq max(pdfn2o(*,k,t)))
  most(k,t)=avg(xbins(z))
nextk:
endfor
;
end
