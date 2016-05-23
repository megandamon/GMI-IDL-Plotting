pro gendates,syear,eyear,yint,dint,fvdates,yyyy=yyyy
;
;	if yyyy=1 then return YYYY in dates

;	New option: dint gt 10 will calculate every day of the year.
;
;	New option: 10 days per month (dint=10)
;	To get 6 days per month (CGCM instantaneous data), choose dint=6
;	Data are saved on the 1st, 6th, 11th,16th, 21th, and 26th of each month.

;	Choose start year, end year, and intervals
;	between the years to be read in. syear and eyear are YYYY.
;	YINT means year interval (1= every year, 3=every 3rd year, etc_
;	DINT means #days per month read in (6=6 days (every 5th), 3=every 10th,
;	2=5th and 20th, 1=15th)
;
sy=fix(syear)
ey=fix(eyear)
ny=((ey-sy)/yint)+1
yy=indgen(ny)*yint+sy
ychar=strtrim(string(yy),2)
ychar=strmid(ychar,0,4)
mm=indgen(12)+1
mm=strtrim(string(mm),2)
mm(0:8)='0'+mm(0:8)

darr=strtrim(string(indgen(31)+1),2)
for i=0,8 do darr(i)='0'+darr(i)

dmx=[31,28,31,30,31,30,31,31,30,31,30,31]
if dint gt 10 then dd=darr
if dint eq 10 then dd=['01','04','07','10','13','16','19','22','25','28']
if dint eq 6 then dd=['01','06','11','16','21','26']
if dint eq 3 then dd=['01','10','20']
if dint eq 2 then dd=['05','20']
if dint eq 1 then dd=['15']

if dint le 10 then begin 
   fvdates=strarr(ny*12*dint)

   for y=0,ny-1 do for m=0,11 do begin 
     ind=y*12*dint +m*dint
     for d=0,dint-1 do fvdates(ind+d)=ychar(y)+mm(m)+dd(d)
   endfor
endif
 
if dint gt 10 then begin
   fvdates=strarr(ny*365)
   for y=0,ny-1 do for m=0,11 do begin
      ind=y*365+total(dmx(0:m))-dmx(m)
      for d=0,dmx(m)-1 do fvdates(ind+d)=ychar(y)+mm(m)+dd(d)
   endfor
endif

;	fvdates is YYYYMMDD by default. If keyword 'yyyy' is not set, then
;	return YYMMDD

if keyword_set(yyyy) eq 0 then fvdates=strmid(fvdates,2,6)

end
