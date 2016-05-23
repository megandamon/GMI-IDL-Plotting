pro globe_cont_local,a,x,y,badval=badval,title=title,lev=lev,nocontr=nocontr $
 ,nocolor=nocolor,lon_rsn=lon_rsn,lat_rsn=lat_rsn,map_color=map_color $
 ,nomap=nomap,blon=blon,blat=blat,elon=elon,elat=elat,max=max $
 ,base_color=base_color,gray=gray,noerase=noerase,limlon=limlon,limlat=limlat $
 ,c_color=c_color,c_thick=c_thick,overlay=overlay,cps=cps,fixlev=fixlev $
 ,position=position,_extra=uextra,frame=frame,charsize=charsize,quad=quad $
 ,boxfill=boxfill,usa=usa
;+
;... routine to give color filled contour plot of lat/lon grid day
;
;... written by:
;...  Stephen D. Steenrod 
;...  while at NASA GSFC
;-

;... quad does 2x2 arrangement for 4 plots

if(n_params() eq 0) then begin
  print,'pro globe_cont_local,a,x,y,badval=badval,title=title,lev=lev,nocontr=nocontr $'
  print,' ,nocolor=nocolor,lon_rsn=lon_rsn,lat_rsn=lat_rsn,map_color=map_color $'
  print,' ,nomap=nomap,blon=blon,blat=blat,max=max,base_color=base_color $'
  print,' ,noerase=noerase,limlon=limlon,limlat=limlat,overlay=overlay $'
  print,' ,c_color=c_color,c_thick=c_thick,gray=gray,cps=cps,fixlev=fixlev $'
  print,' ,_extra=uextra,quad=quad,boxfill=boxfill'
  return
 end

if(max(a) eq min(a)) then begin
  print,'The array to be contoured is constant - aborting plot :) :)'
  return
 end

if(n_elements(title) eq 0) then title = ''
if(n_elements(nocolor) eq 0) then nocolor = 0
if(n_elements(map_color) eq 0) then map_color = 0
if(n_elements(nomap) eq 0) then nomap = 0
if(n_elements(c_color) eq 0) then c_color = 255
if(n_elements(c_thick) eq 0) then c_thick = 1
if(n_elements(charsize) eq 0) then charsize = 1
if(n_elements(base_color) eq 0) then base_color = 1
if(n_elements(gray) eq 0) then gray = 0
if(n_elements(cps) eq 0 and !d.name ne 'PS') then cps = 0
if(n_elements(cps) eq 0 and !d.name eq 'PS') then cps = 1
if(n_elements(fixlev) eq 0) then fixlev = 0
if(n_elements(frame) eq 0) then frame = [1,1]
if(n_elements(quad) eq 0) then quad = 1
if(n_elements(usa) eq 0) then usa = 0
if(n_elements(boxfill) eq 0) then boxfill = 0

if(n_elements(position) eq 0) then !p.position = [.14,.08,.88,.87] $
  else !p.position = position
left = !p.position(0)
rght = !p.position(2)
top = !p.position(3)
bot = !p.position(1)
del = .04			;half distance between plots
dtop = 1-top-del			;start down from top
dbot = bot-del  		;start up from bottom
tf = 1.-dtop-dbot		;total frame available top to bottom
tfs = 1.-rght-left		;total frame available left to right
case frame(1) of
 1: !p.position = [left,dbot+del,.88,1-dtop-del]
 2: if(frame(0) eq 1) then !p.position = [left,dbot+del,rght,tf/2.+dbot-del] $
      else !p.position = [left,tf/2.+dbot+del,rght,1-dtop-del]
 3: if(frame(0) eq 1) then !p.position = [left,dbot+del,rght,tf/3.+dbot-del] $
      else if(frame(0) eq 2) then !p.position = [left,tf/3.+dbot+del,rght,2*(tf/3.)+dbot-del] $
      else !p.position = [left,2*(tf/3.)+dbot+del,rght,1-dtop-del]
 4: if(quad) then begin
      if(frame(0) eq 1) then !p.position = [left,dbot+del,.5-del,tf/2.+dbot-del] $
      else if(frame(0) eq 2) then !p.position = [.5+2*del,dbot+del,rght,tf/2.+dbot-del] $
      else if(frame(0) eq 3) then !p.position = [left,tf/2.+dbot+del,0.5-del,1-dtop-del] $
      else !p.position = [.5+2*del,tf/2.+dbot+del,rght,1-dtop-del]
      end $
     else begin
       if(frame(0) eq 1) then !p.position = [left,dbot+del,rght,tf/4.+dbot-del] $
       else if(frame(0) eq 2) then !p.position = [left,tf/4.+dbot+del,rght,2*(tf/4.)+dbot-del] $
       else if(frame(0) eq 3) then !p.position = [left,2*(tf/4.)+dbot+del,rght,3*(tf/4.)+dbot-del] $
       else !p.position = [left,3*(tf/4.)+dbot+del,rght,1-dtop-del]
     end
 else: begin
   print,'frame parameter is to be used as:'
   print,'  two element array where first element is which plot to draw'
   print,'  and second is total number of plots in frame'
   print,'  all plots will take up full width and be stacked from bottom up'
   return
   end
 endcase

;... keyword to draw thick unfilled contours over existing plot
if(n_elements(overlay) ne 0) then begin
  noerase = 1
  nocolor = 1
  nocontr = 0
  c_thick = 3
  c_color = 0 
 end
;... make sure title is scalar
title = title(0)

if(gray) then base_color = 16
contr = 1
if(n_elements(nocontr) eq 0) then nocontr = 0
if(nocontr ne 0) then contr = 0

sz = size(a)
if(sz(0) lt 2) then begin
  print,'Input array must be two-dimensional...'
  return
 end

if(n_elements(x) eq 0) then begin
  if(n_elements(blon) eq 0) then blon = 0.
  if(n_elements(elon) eq 0) then elon = blon+360.
  lon_rsn = float((elon-blon))/sz(1)
  x = findgen(sz(1))*lon_rsn+blon
 end
if(n_elements(y) eq 0) then  begin
  if(n_elements(blat) eq 0) then blat = -90
  if(n_elements(elat) eq 0) then elat = 90
  lat_rsn = float((elat-blat))/(sz(2)-1)
  y = findgen(sz(2))*lat_rsn+blat
 end
if(n_elements(lon_rsn) eq 0) then lon_rsn = x(1)-x(0)
if(n_elements(lat_rsn) eq 0) then lat_rsn = y(1)-y(0)

;... set up temp array and copy 1st lon to make wrap around globe
blon = min(x)
elon = max(x)
if(elon+lon_rsn-360 eq blon) then begin
  temp = fltarr(sz(1)+1,sz(2))
  tempx = [x,x(0)+360]
  for n=0,sz(2)-1 do temp(*,n) = [a(*,n),a(0,n)]
  end $
 else begin
   temp = a
   tempx = x
 end
tempy = y

;... trap constant array and abort
if(sz[sz[0]+1] eq 5) then begin
  stra = string(max(temp),f='(e17.10)')
  strb = string(min(temp),f='(e17.10)')
  end $
else begin
  stra = string(max(temp),f='(e12.5)')
  strb = string(min(temp),f='(e12.5)')
end
if(stra eq strb) then begin
  print,'The array to be contoured is effectively constant - aborting plot :) :)'
  return
 end
;... if desired limit range of plot in x and/or y
if(n_elements(limlon) ne 0 or n_elements(limlat) ne 0) then begin
  if(n_elements(limlon) eq 0) then limlon = [min(tempx),max(tempx)]
  if(n_elements(limlat) eq 0) then limlat = [min(tempy),max(tempy)]
  indx = where(tempx ge limlon(0) and tempx le limlon(1),cntx)
  indy = where(tempy ge limlat(0) and tempy le limlat(1),cnty)
  if(cntx gt 0 and cnty gt 0) then begin
    tempx = tempx(indx)
    tempy = tempy(indy)
    temp1 = fltarr(cntx,cnty)
    for j=0,cnty-1 do temp1(*,j) = temp(indx,indy(j))
   end
  temp = temp1
 end

badplt = 1e20
if(n_elements(max) ne 0) then begin
  ind = where(temp ge max,cnt)
  if(cnt gt 0) then temp(ind) = badplt
 end

if(n_elements(badval) ne 0) then begin
  ind = where(temp eq badval,badcnt)
  if(badcnt gt 0) then temp(ind) = badplt
 end

ind = where(temp ne badplt,cnt)
if(cnt lt 3) then begin 
  print,'Almost all values marked as bad... will not contour'
  return
 end
max0 = max(temp(ind))
min0 = min(temp(ind))
if(n_elements(lev) eq 0) then begin
;... contour level increment
  dum3 = nice((max0-min0)/15)
;... caused problems when max0 and min0 differed by less than most sig digit
  dum = magnitude(dum3)
  dum = -dum(0)
  dum4 = long(min0*10.^dum)
  dum4 = float(dum4)*10.^(-dum)

  while (14*dum3+dum4 lt max0) do dum3 = nice(2*dum3)
  lev = findgen(15)*dum3+dum4
  ind2 = where(lev lt max(temp(ind)))
  lev = lev(ind2)
 end
if(fixlev eq 0) then begin
  ind = where(lev le max0 and lev ge min0)
  lev = lev(ind)
  if(lev(0) gt min0) then lev = [lev(0)-(lev(1)-lev(0)),lev]
  dum1 = n_elements(lev)-1
  if(lev(dum1) lt max0) then  $
    lev = [lev,lev(dum1)+(lev(dum1)-lev(dum1-1))]
 end
if(!d.name eq 'PS' and cps eq 0) then $
  color_index = [0,50,100,70,110,170,140,190,210,200,220,240,230,245,253,250,254] $
 else color_index = findgen(n_elements(lev))+base_color
 
if(fixlev eq 0) then lev = [lev,lev(dum1)+2*(lev(dum1)-lev(dum1-1))]

if(cps ne 0) then begin
  tvlct,r,g,b,/get
  tvlct,255,255,255,16
  tvlct,0,0,0,255
 end

color_index = [color_index,0]

if(n_elements(noerase) eq 0) then noer = 0  else  noer = noerase

;????
;stop
case max(tempx)-min(tempx) of
 360: xtickv = -180+findgen(15)*60
 else: xtickv = findgen(100)*fix(max(tempx)-min(tempx))/5+fix(min(tempx))
 endcase
xtickv = xtickv(where(xtickv ge min(tempx) and xtickv le max(tempx)))
xticks = n_elements(xtickv)-1
case max(tempy)-min(tempy) of
 180: ytickv = findgen(7)*30-90
 else: ytickv = findgen(100)*fix(nice(max(tempy)-min(tempy))/4)+fix(min(tempy))
 endcase
; ytickv = findgen(7)*30-90
;ytickv = findgen(100)*fix(nice(max(tempy)-min(tempy))/5)+fix(min(tempy))
ytickv = ytickv(where(ytickv ge min(tempy) and ytickv le max(tempy)))
yticks = n_elements(ytickv)-1

;... print longitude title only for bottom plot
if(frame(0) eq 1) then xtitle = 'Longitude'  else xtitle = ''
if(frame(0) eq 2 and frame(1) eq 4) then xtitle = 'Longitude'

ytitle='Latitude'
if(frame(1) eq 4 and (frame(0) eq 2 or frame(0) eq 4)) then ytitle = ''
;... do grid box filled plot
if(boxfill) then begin 
   xint = ([tempx[0],(tempx[0:sz[1]-1]+tempx[1:sz[1]])/2,tempx[sz[1]]])
   yint = [tempy[0],(tempy[0:sz[2]-2]+tempy[1:sz[2]-1])/2,tempy[sz[2]-1]]
   contour,temp,tempx,tempy,xr=[min(tempx),max(tempx)],yr=[min(tempy),max(tempy)] $
      ,xs=1,ys=1,xticks=xticks,xmin=3,yticks=yticks,ymin=3,title=title $
      ,xtitle=xtitle,ytitle=ytitle,xtickv=xtickv,ytickv=ytickv,yticklen=-.02,xticklen=-.02 $
      ,charsize=charsize,/nodata,noerase=noer
   for j=0,sz[2]-1 do for i=0,sz[1] do begin
     xbox = [xint[i],xint[i],xint[i+1],xint[i+1]]
     ybox = [yint[j+1],yint[j],yint[j],yint[j+1]]
     c = where(lev ge temp[i,j])
     polyfill,xbox,ybox,color=max([0,min([16,c[0]])])
   end
   end $
;... do regular contour filled plot
  else if(not nocolor) then begin
    contour,temp,tempx,tempy,xr=[min(tempx),max(tempx)],yr=[min(tempy),max(tempy)] $
      ,xs=1,ys=1,xticks=xticks,xmin=3,yticks=yticks,ymin=3,title=title,/cell $
      ,c_colors=color_index,lev=lev,/foll,xtitle=xtitle,ytitle=ytitle $
      ,noerase=noer,xtickv=xtickv,ytickv=ytickv,yticklen=-.02,xticklen=-.02 $
      ,charsize=charsize,_extra=uextra
    noer = 1
    if(contr) then $
      contour,temp,tempx,tempy,xr=[min(tempx),max(tempx)],yr=[min(tempy),max(tempy)] $
       ,/fol,max=badplt,lev=lev,xs=5,ys=5,noer=noer,_extra=uextra $
       ,charsize=charsize,color=c_color,c_thick=c_thick
    end $
   else begin
     if(overlay) then $
       contour,temp,tempx,tempy,xr=[min(tempx),max(tempx)],yr=[min(tempy),max(tempy)] $
        ,max=badplt,lev=lev,xs=5,ys=5,noer=noer,_extra=uextra $
        ,charsize=charsize,color=c_color,c_thick=c_thick $
      else $
        contour,temp,tempx,tempy,xr=[min(tempx),max(tempx)],yr=[min(tempy),max(tempy)] $
         ,xticks=xticks,xmin=3,yticks=yticks,ymin=3,/fol,max=badplt,lev=lev,xs=1,ys=1 $
         ,title=title,noer=noer,xtickv=xtickv,ytickv=ytickv,_extra=uextra $
         ,xtitle=xtitle,ytitle=ytitle,color=c_color,c_thick=c_thick $
         ,charsize=charsize,yticklen=-.02,xticklen=-.02
      noer = 1
   end

; end
;if(not nomap) then mymap,color=map_color
if(not nomap) then $
  map_set,0,(max(tempx)+min(tempx))/2,/noeras,color=map_color,/cont,/cyl $
	,lim=[min(tempy),min(tempx),max(tempy),max(tempx)],/noborder,usa=usa

;... draw scale boxes
if(not nocolor) then begin
  xax0 = (!p.position(2)+.010+.055/frame(1))*!d.x_size
  xax1 = (!p.position(2)+.015+.082/frame(1))*!d.x_size
  yax0 = !p.position(1)*!d.y_size
  yax1 = !p.position(3)*!d.y_size
  temp = magnitude(max(lev))
  temp = temp(0)
  atemp = abs(temp)
  dum = (atemp/3)+(min([1,(atemp mod 3)]))
  if(temp gt 0) then dum = dum-1
  if(atemp eq 0) then temp = 0   else temp = 3*dum*temp/atemp
  csize = charsize
  clvls = lev
  if(temp gt 2 or temp lt -2) then begin
    clvls = lev/(10.^temp)
    xyouts,xax1,yax1+6,/dev, $
	'x10!U'+strtrim(temp,2),charsize=csize*0.62,ali=1,_extra=uextra
    miny = min0/(10.^temp)
    maxy = max0/(10.^temp)
   end
;... draw scale box and labels
  xpf = [xax0+1,xax1,xax1,xax0+1,xax0+1]
  range = n_elements(lev)
  yinc = (yax1-yax0)/(range-1)
  for c=0,range-2 do begin
    ypf = [yax0+c*yinc,yax0+c*yinc,yax0+(c+1)*yinc,yax0+(c+1)*yinc,yax0+c*yinc]
    polyfill,xpf,ypf,/dev,color=color_index(c)
    plot,xpf,ypf,/dev,/noerase,xstyle=5,ystyle=5,xticks=1,xminor=0 $
	,xrange=[xax0,xax1],yrange=[yax0,yax1],pos=[xax0,yax0,xax1,yax1] $
	,yticks=1,yminor=0
;stop
    dum1 = magnitude(clvls(c+1)-clvls(c))
    case dum1(0) of 
      -4: strtmp = string(clvls(c),f='(f8.4)')
      -3: strtmp = string(clvls(c),f='(f7.3)')
      -2: strtmp = string(clvls(c),f='(f6.2)')
      -1: strtmp = string(clvls(c),f='(f5.1)')
      else: strtmp = strtrim(round(clvls(c)),2)
     endcase
;    if(dum1(0) eq -2) then strtmp = string(clvls(c),f='(f6.2)') $
;     else if(dum1(0) lt 0) then strtmp = string(clvls(c),f='(f6.2)') $
;     else strtmp = strtrim(round(clvls(c)),2)
    xyouts,xax0,yax0+c*yinc-5,strtmp,charsize=csize*0.6,ali=1,/dev,_extra=uextra
   end
  c = range-1
  dum1 = magnitude(clvls(c)-clvls(c-1))
  case dum1(0) of 
    -4: strtmp = string(clvls(c),f='(f8.4)')
    -3: strtmp = string(clvls(c),f='(f7.3)')
    -2: strtmp = string(clvls(c),f='(f6.2)')
    -1: strtmp = string(clvls(c),f='(f5.1)')
    else: strtmp = strtrim(round(clvls(c)),2)
   endcase
;  if(dum1(0) lt 0) then strtmp = string(clvls(c),f='(f6.2)') $
;   else strtmp = strtrim(round(clvls(c)),2)
  xyouts,xax0-3,yax0+c*yinc-5,strtmp,charsize=csize*0.6,ali=1,/dev,_extra=uextra
 end

if(cps ne 0) then tvlct,r,g,b

end
