;   $Header: /science/nmc/met_fields/programs/epv_eqlat.pro,v 1.18 2006/07/11 13:48:03 nash Exp $

function  map_area,data,lon,lat,level,hem,direct=direct,zarr=zarr,zout=zout

; NAME:
;   map_area
; PURPOSE:
;   Calculates the area contained inside contours. This is an internal
;   routine for epv_eqlat.
; CATEGORY:
;   interpolation
; CALLING SEQUENCE:
;   pvl = map_area(data, lon, lat, level, bad, hem, direct)
; FUNCTION RETURN VALUE:
;   float:array
;   Returns the area enclosed by the level contours
; INPUT PARAMETERS:
;   data     = defined the same as qarr in the main call
;   lon      = defined the same as in the main call
;   lat      = defined the same as in the main call
;   level    = (float array) levels in data for which to calculate the areas
;   hem      = (number) hemisphere:  -1 = sh;  0 = globe;  1 = nh
;   direct   = defined the same as in the main call
; INPUT KEYWORDS:
;   zarr     = defined the same as in the main call
; OUTPUT KEYWORDS:
;   zout     = defined the same as zeq in the main call
; REQUIRED ROUTINES:
;   area_wts
; RESTRICTIONS:
;   Internal use only in epv_eqlat.

; *****number of levels
  n = n_elements(level)
  nm1 = n-1L
  usez = (n_elements(zarr) gt 0L)

; *****areas set to missing
  area = fltarr(n)
  lhem = 0.

; *****area for a hemisphere
  if  (keyword_set(hem))  then  begin

;   *****lats must be in the hemisphere specified
    lhem = hem/abs(hem)
    l = where(lhem*lat ge 0.)
    if  (l[0] eq -1)  then  return,fltarr(n)

  endif  else  l = make_array(n_elements(lat),/index,/long)

; *****representative weights for each lat/lon section
  areaa = area_wts(lat[l],lon)*2.

; *****min and max latitudes
  mnlat = min(lat[l],max=mxlat)

; *****set up weights for calculating z
  if  (usez)  then  begin
    z = zarr[*,l]*areaa
    r = area
    zout = area
  endif

; *****make sure we use only data in the hemisphere, if specified
  d = data[*,temporary(l)]

; *****sort data from smallest to largest areas
  l = sort(areaa)
  areaa = areaa[l]
  if  (usez)  then  z = z[l]
  d = d[temporary(l)]

; *****default direction of the data
  if  (keyword_set(direct))  then  ddirect = direct $
  else  ddirect = 2*((lhem ne -1) eq (total(data(*,where(lat eq mnlat))) lt $
    total(data(*,where(lat eq mxlat)))))-1

; *****increasing toward north pole, decreasing toward south pole
  if  (ddirect gt 0)  then  begin
    for  i = 0L,nm1  do  area[i] = total(areaa*(d ge level[i]))
    if  (usez)  then  for  i = 0L,nm1  do  r[i] = total(z*(d ge level[i]))

; *****opposite direction
  endif  else  begin
    for  i = 0L,nm1  do  area[i] = total(areaa*(d le level[i]))
    if  (usez)  then  for i = 0L,nm1  do  r[i] = total(z*(d le level[i]))
  endelse
  dmin = min(temporary(d),max=dmax)

; *****calculate z along q
  if  (usez)  then  begin
    z = 0
    auniq = area(uniq(area,sort(area)))

;   *****all points are unique, just calculate
    if  (n_elements(auniq) eq n)  then  begin
      zout = (shift(r,-1)-shift(r,1))/(((shift(area,-1)-shift(area,1)))+1.E-20)

;   *****take care of endpoints
      zout[0L] = (r[1L]-r[0L])/(area[1L]-area[0L]+1.e-20)
      zout[nm1] = (r[nm1]-r[nm1-1L])/(area[nm1]-area[nm1-1L]+1.E-20)

;   *****some areas are not unique
    endif  else  begin

;     *****calculate for unique points
      luniq = in(auniq,area)
      nu1 = n_elements(luniq)-1L
      zout[luniq] = (shift(r[luniq],-1)-shift(r[luniq],1))/ $
        (((shift(area[luniq],-1)-shift(area[luniq],1)))+1.e-20)

;   *****take care of endpoints
      zout[luniq[0]] = (r[luniq[1]]-r[luniq[0]])/ $
        (area[luniq[1]]-area[luniq[0]]+1.E-20)
      zout[luniq[nu1]] = (r[luniq[nu1]]-r[luniq[nu1-1]])/ $
        (area[luniq[nu1]]-area[luniq[nu1-1]]+1.E-20)

;     *****now interpolate the non-unique points
      lnot = where(in(lindgen(n),luniq) eq -1L)
      zout[lnot] = interpol(zout(luniq),temporary(luniq),lnot)

;     *****do not want to extend the endpoints, so just set them to the first
;     *****unique value
      nn1 = nm1-nu1-1L
      l = (where(make_array(n,/index,/long) eq lnot))[0]
      if  (l ne -1L)  then  zout[0L] = zout[l+1L]
      l = (reverse(where(reverse(lindgen(n)) eq reverse(temporary(lnot)))))[0]
      if  (l ne -1L)  then  zout[nm1-l] = zout[nm1-l-1L]
    endelse
  endif

; *****fix up area roundoff
  amin = min(area,max=amax)
  area = (temporary(area)-amin)/(amax-amin)*((lhem eq 0)+1.)

; *****set minimum level to have either max or min of area (handles roundoff)
;  l = where(level eq dmin)
;  if  (l(0) ne -1)  then  area(l) = (ddirect*((lhem eq 0)+1)) > 0
    
; *****set maximum level to have either max or min of area (handles roundoff)
;  l = where(level eq dmax)
;  if  (l(0) ne -1)  then  area(l) = (-ddirect*((lhem eq 0)+1)) > 0

  return,area
end


function  epv_eqlat,qarr,lat,lon,bad=bad,deleq=deleq,direct=direct,fill=fill, $
          npvq=npvq,pvq=pvq,zarr=zarr,area=area,eqlat=eqlat,pvi=pvi,zeq=zeq

;+
; NAME:
;   epv_eqlat
; PURPOSE:
;   Calculates Epv on equivalent latitudes. Uses the method of having the grid
;   point represent the area surrounding it and summing over each of these
;   contributions to the total area. Optionally, another quantity can be
;   averaged along the contours. 
; CATEGORY:
;   interpolation
; CALLING SEQUENCE:
;   pvl = epv_eqlat(qarr, lat)
;   pvl = epv_eqlat(qarr, lat, lon)
; FUNCTION RETURN VALUE:
;   float:array
;   Returns an array of Epv values on the equivalent latitudes, corresponding 
;     to the values in eqlat.
; INPUT PARAMETERS:
;   qarr     = ([nlon,nlat] float array) potential vorticity on a theta surface
;   lat      = ([nlat] float array) latitudes corresponding to the qarr array.
;              Note that the routine needs to have a complete hemisphere
;              or global coverage to work. lat must be in one of the
;              following ranges:  -90 to 90, 0 to 90, -90 to 0
; OPTIONAL INPUT PARAMETERS:
;   lon      = ([nlon] float array) longitudes corresponding to the qarr array
; INPUT/OUTPUT PARAMETERS:
; OPTIONAL INPUT/OUTPUT PARAMETERS:
; OUTPUT PARAMETERS:
; OPTIONAL OUTPUT PARAMETERS:
; INPUT KEYWORDS:
;   bad      = (float) bad-data value.
;   deleq    = (float) equivalent latitude delta -- spacing of the equivalent
;              latitudes. Defaults to the difference in the first two elements
;              of lat
;   direct   = (number) if positive then areas will be computed greater than
;              the values of pvq. If negative then areas will computed less
;              than the values of pvq. If set to 0 or not specified, then the 
;              default behavior will be assumeds. In each hemisphere, the 
;              smallest areas are at the pole. In both hemispheres, if the 
;              values of qarr are increasing/deceasing towards the respective 
;              pole, the default value would be +1/-1, calculating areas which 
;              are greater/less than the reference values and the smallest areas
;              would be found at the highest values of qarr. Globally, if the 
;              values of qarr are increasing/decreasing from south to north, 
;              the default value would be +1/-1, calculating areas which are 
;              greater/less than the reference values and the smallest areas
;              would be found at the highest values of qarr.
;   fill     = (flag) If set, npvq = 0, and pvq is specified, then the values
;              of area and pvi will be filled to the maximum range, otherwise 
;              pvq will be used as-is. The default is to fill, so this must be
;              explicitly set to zero to turn off
;   npvq     = (number) determines which values of potential vorticity will have
;              areas calculated before interpolating to equivalent latitudes:
;              if < 0: the default pvq array will consist of all the values
;                      in the entire qarr array
;              if = 0: (default) if pvq is specified, use the pvq values, 
;                      otherwise the default pvq will be an array of values
;                      consisting of dividing the range of qarr by the number 
;                      of latitudes. This is the same as setting the value to be
;                      nlat
;              if > 0: the default pvq will be the an array of values
;                      consisting of dividing the range of qarr by this value
;   pvq      = (float array) if npvq is set to zero, then these values will be
;              used to calculate the areas. Note that this array should not be 
;              interpreted as values to interpolated to. The finer this grid, 
;              the "noisier" will be the areas. The number of latitudes (the 
;              default for npvq = 0) is just about the optimum spacing. This 
;              array is not used if npvq is not zero, and the default will be
;              as described in npvq. Specify this only if you need to 
;              experiment or you really know how to interpret the results. 
;              If you need the area calculated at specific values, first 
;              calculate the results and then interpolate using the area and 
;              pvi arrays or the function result and eqlat arrays. Values 
;              outside of the range of qarr will be dropped. To calculate the
;              areas properly, pvq will be sorted in increasing order with
;              duplicates removed and the range will stretch to the min and
;              max of qarr
;   zarr     = (float array) values that will be averaged around the contours
;              specified in pvq. (For example, winds along the contours)
;              Should be same size as qarr
; INPUT/OUTPUT KEYWORDS:
; OUTPUT KEYWORDS:
;   area     = (float array) area (in equivalent latitude units) of each point 
;              in pvi. The number of values will be determined from npvq
;   eqlat    = (float array) equivalent latitudes based on the value of deleq.
;              The function results are specified at these equivalent latitudes
;   pvi      = (float array) potential vorticity on equivalent latitudes. Will 
;              be the uniq values of pvq if specified. If /fill is specified, 
;              the range of pvi will extend over the full range of qarr. If 
;              fill=0, the range of pvi will be as specified in pvq. If pvq is 
;              not used, this will be determined from npvq
;   zeq      = (float array) the average zarr value around each contour on 
;              equivalent latitudes. The corresponding equivalent latitudes 
;              are in eqlat
; COMMON BLOCKS:
; REQUIRED ROUTINES:
;   area_wts, interpol
; @ FILES:
; RESTRICTIONS:
;   The routine needs to have a complete hemisphere or global coverage to
;   work.
; SIDE EFFECTS:
; DIAGNOSTIC INFORMATION:
; PROCEDURE:
;   Calculates areas under contours and scales to equivalent latitude
; EXAMPLES:
; REFERENCE:
; FURTHER INFORMATION:
; RELATED FUNCTIONS AND PROCEDURES:
;   calc_vedge
; MODIFICATION HISTORY:
;   $Log: epv_eqlat.pro,v $
;   Revision 1.18  2006/07/11 13:48:03  nash
;   fix so that duplicate areas are not included in final interpolation
;
;   Revision 1.17  2006/07/10 18:44:28  nash
;   fixed end points in area
;
;   1993-09-23:nash:written
;   1995-03-04:nash:added zarr; added different ways to calculate area
;   1995-03-16:nash:fixed problem in map_area with hemisphere direction
;   1995-07-07:nash:added fill, return missing values if all areas are bad
;   1995-10-16:nash:changed default npvq to be zero
;   1996-01-03:nash:totals in map_area now start from smallest values
;   1996-01-04:nash:fixed endpoints - only the last points are now filled
;   1996-02-01:nash:fixed reference to z(l) in map_area - now use usez
;   1996-09-03:nash:fixed documentation to correctly reflect what is returned
;   1996-11-18:nash:limited the areas to fit properly
;   1998-06-10:nash:fixed end points in the area set to zero. Now it uses
;                   points further in to calculate the zeq
;   1999-11-01:nash:fixed number of points in filling the area
;   2000-02-24:nash:major rewrite of logic. direction now determines if gt
;                   or lt is used for testing
;                   /fill has a slightly different meaning
;   2000-05-17:nash:finally fixed the problem of non-unique areas
;   2000-06-27:nash:missing () in final calculation of area
;-

; *****defaults
  if  (n_elements(bad) eq 0)  then  bad = -999.
  if  ((n_elements(qarr) eq 0) or (n_elements(lat) eq 0))  then  return,bad
  if  (n_elements(deleq) eq 0)  then  deleq = abs(lat[1L]-lat[0L])
  if  (n_elements(npvq) eq 0)  then  npvq = 0

; *****size the q_array
  ss = size(qarr)
  nlon = ss[1L]
  nlat = ss[2L]
  ss = 0

; *****check lats
  lmax = max(lat,min=lmin)
  if  (lmin eq -90)  then  begin
    if  (lmax eq 0)  then  hem = -1 $
    else  if  (lmax eq 90)  then hem = 0 $
    else  begin
      message,/cont,'Latitudes must be global or hemispheres'
      return,bad
    endelse
  endif  else  if  ((lmin eq 0) and (lmax eq 90))  then  hem = 1 $
    else  begin
      message,/cont,'Latitudes must be global or hemispheres'
      return,bad
    endelse
  if  (n_elements(lon) eq 0L)  then $
    lon = make_array(nlon,/float,/index)*(360./nlon)
  neqlat = long((lmax-lmin)/deleq)+1L
  eqlat = make_array(neqlat,/float,/index)*deleq+lmin

; *****calculate the area represented by each point on the grid
  qmax = max(qarr,min=qmin)
  nl1 = nlat-1L
  fill_lo = 0L

; *****all qarr values sorted in order
  if  (npvq lt 0L)  then  begin
    pvi = qarr[sort(qarr)]
    fill_hi = n_elements(pvi)-1L

; *****a range of npvq values between qmin and qmax
  endif  else  if  (npvq gt 1L)  then  begin
    pvi = make_array(npvq,/float,/index)*(qmax-qmin)/(npvq-1.)+qmin
    fill_hi = npvq-1L
    pvi(fill_hi) = qmax

; *****an explicit array of pvq specified
  endif  else  if  ((npvq eq 0L) and (n_elements(pvq) gt 0L)) then  begin
    pvi = pvq[uniq(pvq,sort(pvq))]

;   *****make sure that values are within the data range
    l = where((pvi ge qmin) and (pvi le qmax))
    if  (l[0] lt 0L)  then  begin
      message,/cont,'pvq values must be within the range of qarr'
      return,bad
    endif
    pvi = pvi[temporary(l)]
    plo = (pvi[0] ne qmin)
    phi = (pvi(n_elements(pvi)-1L) ne qmax)
    if  (plo and phi)  then  pvi = [qmin,temporary(pvi),qmax] $
    else  if  (plo)  then  pvi = [qmin,temporary(pvi)] $
    else  if  (phi)  then  pvi = [temporary(pvi),qmax]
    if  (keyword_set(fill))  then  fill_hi = n_elements(pvi)-1L $
    else  begin
      fill_lo = plo
      fill_hi = n_elements(pvi)-1L-phi
    endelse

; *****a range of neqlat values between qmin and qmax
  endif  else  begin
    pvi = make_array(neqlat,/float,/index)*(qmax-qmin)/(neqlat-1.)+qmin   
    fill_hi = neqlat-1L
    pvi(fill_hi) = qmax
  endelse
  npvi = n_elements(pvi)
  area = map_area(qarr,lon,lat,pvi,hem,direct=direct,zarr=zarr,zout=zeq)

; *****calculate area in terms of equivalent latitude
  if  (hem eq 0)  then  area = asin(-1. > (1.-temporary(area)) < 1.)*!radeg $
  else if  (hem eq 1)  then  area = asin(0. > (1.-temporary(area)) < 1.)*!radeg $
  else  area = -asin(0. > (1.-temporary(area)) < 1.)*!radeg

; *****determine which areas are duplicates. The logic works as follows:
; *****leave out duplicates in the top half of the array that have a lower
; *****index and in the bottom half of the array that have a higher index.
  ll = make_array(/index,npvi,/long)
  l = where(((area-shift(area,-1) ne 0.) or (ll le npvi/2L)) $
    and ((shift(area,+1)-area ne 0.) or (temporary(ll) ge npvi/2L)))

; *****interpolate and use the filling factors if needed
  if  (n_elements(zeq) gt 0L)  then $
    zeq = interpol((temporary(zeq))[l],area[l],eqlat)
  qeq = interpol(pvi[l],area[temporary(l)],eqlat)
  pvi = pvi[fill_lo:fill_hi]
  area = area[temporary(fill_lo):temporary(fill_hi)]
  return,qeq
end
