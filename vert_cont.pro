pro vert_cont,a,y,z,badval=badval,title=title,lev=lev,nocontr=nocontr $
 ,nocolor=nocolor,max=max,base_color=base_color,gray=gray,noerase=noerase $
 ,c_color=c_color,c_thick=c_thick,cps=cps,charthick=charthick,charsize=charsize $
 ,overlay=overlay,xtickv=xtickv,ytickv=ytickv,_extra=uextra,frame=frame $
 ,fixlev=fixlev,split_horiz=split_horiz,boxfill=boxfill,ptop=ptop,pbot=pbot,ytitle=ytitle
;+
;	This procedure creates a plot of a latitude height cross-section
;	 default is to be a color filled contour plot, but most things are 
;	 controllable.
;-

print, 'here'
if(n_params() eq 0) then begin
  print,'pro vert_cont,a,y,z,badval=badval,title=title,lev=lev,nocontr=nocontr $'
  print,' ,nocolor=nocolor,max=max,base_color=base_color,gray=gray,noerase=noerase $'
  print,' ,c_color=c_color,c_thick=c_thick,cps=cps,charthick=charthick,charsize=charsize $'
  print,' ,overlay=overlay,xtickv=xtickv,ytickv=ytickv,_extra=uextra,frame=frame'
  print,' ,fixlev=fixlev,split_horiz=split_horiz,boxfill=boxfill,ptop=ptop,pbot=pbot,ytitle=ytitle'
  return
 end

if(max(a) eq min(a)) then begin
  print,'The array to be contoured is constant - aborting plot'
  return
 end
temp = reform(a)
sz = size(temp)
if(sz(0) lt 2) then begin
  print,'Input array must be two-dimensional...'
  return
 end
if(n_elements(fixlev) eq 0) then fixlev = 0
if(n_elements(split_horiz) eq 0) then split_horiz = 0
if(n_elements(boxfill) eq 0) then boxfill = 0
if(n_elements(ytitle) eq 0) then begin 
    pressYTitle = "Pressure (hPa)"
endif else begin
    pressYTitle = ytitle
endelse


;... set default y and z and do some checking
if(n_elements(y) eq 0) then $
  y = findgen(sz(1))*(180./(sz(1)-1))-90

;... a couple of plev arrays if none specified
dims = size(a)
if(n_elements(z) eq 0) then $
  case dims(2) of
    18: z = [1000,850,700,500,400,300,250,200,150,100 $
      ,70,50,30,10,5,2,1.,0.4]
;    28: z = [921.954,771.362,648.074,547.723,447.214 $
;      ,346.410,273.861,223.607,187.083,162.019,139.642 $
;      ,118.000,100.000,88.0000,77.0000,68.1292,57.0000 $
;      ,46.4159,31.6228,21.5443,14.6780,10.0000,6.81292 $
;      ,4.64159,3.16228,2.15443,1.46780,0.681294]
    28: z = [918.316,772.170,649.033,543.019,441.362 $
      ,348.182,276.080,224.975,188.703,161.825,139.835 $
      ,118.835,100.947,87.8748,77.2146,67.1829,56.6158 $
      ,44.3917,31.6228,21.5444,14.6780,10.0000,6.81291 $
      ,4.64159,3.16228,2.15443,1.33353,0.656174]
    32: z = [918.316,772.170,649.033,543.019,441.362,348.182 $
      ,274.633,225.768,191.907,163.123,138.657,117.861 $
      ,100.184,85.1578,72.3131,61.2832,51.8318,43.7506 $
      ,36.8555,30.9696,25.9457,21.6716,18.0475,14.9844 $
      ,12.8567,10.0000,6.81292,4.64159,3.16228,2.15444 $
      ,1.33352,.656183]
    33: z = [918.316, 772.170, 649.033, 543.019, 441.362, 348.182 $
      , 276.080, 224.975, 188.703, 161.825, 139.835, 118.835 $
      , 100.947, 87.8748, 77.2146, 67.1829, 56.6158, 44.3917 $
      , 31.6228, 21.5444, 14.6780, 10.0000, 6.81292, 4.64159 $
      , 3.16228, 2.15444, 1.33352, 0.681292, 0.316227, 0.146780 $
      , 0.0681292, 0.0316227, 0.0146780]
    36: z = [1000.00,975.000,950.000,925.000,900.000,875.000 $
      ,850.000,825.000,800.000,750.000,700.000,650.000 $
      ,600.000,550.000,500.000,450.000,400.000,350.000 $
      ,300.000,250.000,200.000,150.000,100.000,70.0000 $
      ,50.0000,40.0000,30.0000,20.0000,10.0000,7.00000 $
      ,5.00000,3.00000,2.00000,1.00000,.400000,.200000]
;EC-Oslo
    37: z = [ $
        994.464, 980.623, 966.346, 953.087, 937.160, 918.527 $
      , 897.209, 873.277, 846.855, 818.108, 787.234, 754.467 $
      , 720.069, 684.319, 647.512, 609.955, 571.957, 533.829 $
      , 495.869, 458.373, 421.613, 385.840, 351.276, 318.109 $
      , 286.491, 256.526, 228.271, 201.724, 176.823, 153.443 $
      , 131.385, 110.371, 90.0430, 70.0000, 50.0000 $
      , 25.0000, 11.0000 ]
;EC-Oslo
    40: z = [ $
        994.464, 980.623, 966.346, 953.087, 937.160, 918.527 $
      , 897.209, 873.277, 846.855, 818.108, 787.234, 754.467 $
      , 720.069, 684.319, 647.512, 609.955, 571.957, 533.829 $
      , 495.869, 458.373, 421.613, 385.840, 351.276, 318.109 $
      , 286.491, 256.526, 228.271, 201.724, 176.823, 153.443 $
      , 131.385, 110.371, 90.0430, 70.0000, 50.0000, 35.0000 $
      , 25.0000, 17.0000, 11.0000, 5.00000 ]

    42: z = [ $
       992.556,970.555,929.649,867.161,787.702,696.796 $
      ,600.524,510.455,433.895,368.818,313.501,266.481 $
      ,226.513,192.539,163.661,139.115,118.250,100.515 $
      ,85.4390,72.5578,61.4957,52.0159,43.9097,36.9927 $
      ,31.0889,26.0491,21.7610,18.1243,15.0502,12.4601 $
      ,9.76546,6.93872,4.72730,3.22067,2.19422,1.38914 $
      ,0.732080,0.339801,0.157722,0.0732080,0.0339800,0.0157720 ]
    46: z = [ $
       993.936,971.303,929.932,875.073,812.519,745.026,674.533,604.540,536.546 $
      ,471.553,410.059,352.565,301.570,258.051,220.351,187.125,157.965,132.894 $
      ,111.811,94.1256,79.3246,66.9658,56.6683,48.1072,41.0059,35.0235,29.8890 $
      ,25.4920,21.7603,18.5367,15.6694,13.1342,10.9064,8.96261,7.28028,5.83643 $
      ,4.60955,3.57915,2.72524,2.02781,1.46836,1.02891,0.692941,0.443966,0.266483 $
      ,0.146995 ]
    55: begin
       ak = [1.,2.,3.27,4.7585,6.6,  8.9345,  11.9703,  15.9495, $
        21.1349, 27.8526,36.5041,47.5806,61.6779,79.5134,101.9441, $
        130.0508,165.0792,208.4971,262.0212,327.6433,407.6567, $
        504.6805,  621.68,  761.9839,  929.2943,  1127.689,  1364.339, $
        1645.707,  1979.155,  2373.036,  2836.782,  3380.995,  4017.542,  $
        4764.393, 5638.794,  6660.338,  7851.23,  9236.566,  10866.34, $
        12783.7, 15039.3,  17693.,  20119.2,  21686.49,  22436.29,  22388.47, $
        21541.75, 19873.78,  17340.32,  13874.44,  10167.16,  6609.843, $
        3546.596,  1270.494, 0.E+0, 0.E+0]
       bk = [fltarr(42),6.96E-3,  2.801E-2,  6.372E-2,  0.11503,  0.1833, $
        0.27033,  0.37844,  0.51046,  0.64271,  0.76492,  0.86783,  0.94329, $
        0.98511,  1.]
       ptop = 0.01
       z1 = ak*ptop+bk*1000
       z = (z1(0:*)+z1(1:*))/2
       end
     72: begin
       z = [0.015000001, 0.026350009, 0.040142512, 0.056792521, 0.077672510 $
          ,  0.10452403,  0.13959901,  0.18542204,  0.24493753,  0.32178352 $
          ,  0.42042358,  0.54629269,  0.70595657,  0.90728729,   1.1599754 $
          ,   1.4756502,   1.8678806,   2.3525906,   2.9483206,   3.6765005 $
          ,   4.5616858,   5.6318005,   6.9183209,   8.4563898,   10.284922 $
          ,   12.460154,   15.050253,   18.124354,   21.761011,   26.049104 $
          ,   31.088906,   36.992705,   43.909658,   52.015913,   61.495649 $
          ,   72.557876,   85.439043,   100.51438,   118.25001,   139.11501 $
          ,   163.66154,   192.55764,   226.59694,   266.69782,   313.21444 $
          ,   356.89354,   394.60041,   432.31628,   470.04056,   507.77102 $
          ,   545.50591,   583.24526,   620.98781,   658.73237,   690.18853 $
          ,   715.35433,   740.52030,   765.68726,   790.85547,   813.50702 $
          ,   831.12499,   846.22649,   861.32819,   876.42994,   891.53179 $
          ,   906.63371,   921.73599,   936.83859,   951.94094,   967.04335 $
          ,   982.14619,   997.23357]
        z = reverse(z)
;       ak = [0.015000001, 0.026350009, 0.040142512, 0.056792521, 0.077672510 $
;          ,  0.10452403,  0.13959901,  0.18542204,  0.24493753,  0.32178352 $
;          ,  0.42042358,  0.54629269,  0.70595657,  0.90728729,   1.1599754 $
;          ,   1.4756502,   1.8678806,   2.3525906,   2.9483206,   3.6765005 $
;          ,   4.5616858,   5.6318005,   6.9183209,   8.4563898,   10.284922 $
;          ,   12.460154,   15.050253,   18.124354,   21.761011,   26.049104 $
;          ,   31.088906,   36.992705,   43.909658,   52.015913,   61.495649 $
;          ,   72.557876,   85.439043,   100.51438,   118.25001,   139.11501 $
;          ,   163.66154,   192.55764,   226.59694,   266.69782,   313.21444 $
;          ,   356.89354,   394.60041,   432.31628,   470.04056,   507.77102 $
;          ,   545.50591,   583.24526,   620.98781,   658.73237,   690.18853 $
;          ,   715.35433,   740.52030,   765.68726,   790.85547,   813.50702 $
;          ,   831.12499,   846.22649,   861.32819,   876.42994,   891.53179 $
;          ,   906.63371,   921.73599,   936.83859,   951.94094,   967.04335 $
;          ,   982.14619,   997.23357]
;       bk = fltarr(72)
;       ptop = 1
;       z1 = ak*ptop+bk*1000
;       z = (z1(0:*)+z1(1:*))/2.
       end
     73: begin
       z = [0.015000001, 0.026350009, 0.040142512, 0.056792521, 0.077672510 $
          ,  0.10452403,  0.13959901,  0.18542204,  0.24493753,  0.32178352 $
          ,  0.42042358,  0.54629269,  0.70595657,  0.90728729,   1.1599754 $
          ,   1.4756502,   1.8678806,   2.3525906,   2.9483206,   3.6765005 $
          ,   4.5616858,   5.6318005,   6.9183209,   8.4563898,   10.284922 $
          ,   12.460154,   15.050253,   18.124354,   21.761011,   26.049104 $
          ,   31.088906,   36.992705,   43.909658,   52.015913,   61.495649 $
          ,   72.557876,   85.439043,   100.51438,   118.25001,   139.11501 $
          ,   163.66154,   192.55764,   226.59694,   266.69782,   313.21444 $
          ,   356.89354,   394.60041,   432.31628,   470.04056,   507.77102 $
          ,   545.50591,   583.24526,   620.98781,   658.73237,   690.18853 $
          ,   715.35433,   740.52030,   765.68726,   790.85547,   813.50702 $
          ,   831.12499,   846.22649,   861.32819,   876.42994,   891.53179 $
          ,   906.63371,   921.73599,   936.83859,   951.94094,   967.04335 $
          ,   982.14619,   997.23357]
       z = [0.01,(z+z[1:*])/2,1000]
      end

    else: begin
      print,'*********** Need plev to be input: *************'
      print,'pro vert_cont,a,y,z,badval=badval,title=title,lev=lev,nocontr=nocontr $'
      print,' ,nocolor=nocolor,max=max,base_color=base_color,gray=gray,noerase=noerase $'
      print,' ,c_color=c_color,c_thick=c_thick,cps=cps,charthick=charthick,charsize=charsize $'
      print,' ,overlay=overlay,xtickv=xtickv,ytickv=ytickv,_extra=uextra,frame=frame'
      return
      end
   endcase
if(sz(1) ne n_elements(y)) then begin
  print,'Horizontal dimensions are incompatable - aborting'
  return
 end

zxcx = z
if(boxfill) then if(n_elements(z) ne dims(2)+1) then begin;z[sz[2]-1] = ptop
   zxcx = [abs(z[0]-z[1])/2+z[0],(z[0:sz[2]-2]+z[1:sz[2]-1])/2 $
     ,exp(alog(z[sz[2]-1])+(alog(z[sz[2]-1])-alog(z[sz[2]-2]))/2)]
   if(n_elements(pbot) ne 0) then zxcx[0] = pbot
   if(n_elements(ptop) ne 0) then zxcx[sz[2]] = ptop
 end

if(sz(2) ne n_elements(z) and (boxfill and sz(2)+1 ne n_elements(z))) then begin
  print,'Vertical dimensions are incompatable - aborting'
  return
 end

if(n_elements(title) eq 0) then title = ''
if(n_elements(nocolor) eq 0) then nocolor = 0
if(n_elements(base_color) eq 0) then base_color = 1
if(n_elements(c_color) eq 0) then c_color = 255
if(n_elements(c_thick) eq 0) then c_thick = 1
if(n_elements(charthick) eq 0) then charthick = 1
if(n_elements(charsize) eq 0) then charsize = 1.5
if(n_elements(gray) eq 0) then gray = 0
if(n_elements(cps) eq 0 and !d.name ne 'PS') then cps = 0
if(n_elements(cps) eq 0 and !d.name eq 'PS') then cps = 1

;... keyword to draw thick unfilled contours over existing plot
if(n_elements(overlay) ne 0) then begin
  noerase = 1
  nocolor = 1
  if(!d.name eq 'PS') then c_thick = 6 else c_thick = 3
  c_color = 0 
 end

if(gray) then base_color = 16
contr = 1
if(n_elements(nocontr) eq 0) then nocontr = 0
if(nocontr ne 0) then contr = 0

if(n_elements(frame) le 1) then frame = [1,1]
npicts = frame(1)
case frame(1) of
  1: begin
    numx = 1
    numy = 1
;    position = [.20,.09,.75,.85]
    position = [0.0,0.0,1.0,1.0]
    end
  2: begin
    if(split_horiz eq 1) then begin
      numx = 2
      numy = 1
      case frame(0) of
        1: position = [0.5,0.0,1.0,1.0]
        else: position = [0.0,0.0,0.5,1.0]
       endcase
      end $
    else begin
      numx = 1
      numy = 2
      case frame(0) of
        1: position = [0.0,0.5,1.0,1.0]
        else: position = [0.0,0.0,1.0,0.5]
       endcase
    end
    end
  3: begin
    numx = 1
    numy = 3
    case frame(0) of
      1: position = [0.0,0.67,1.0,1.0]
      2: position = [0.0,0.33,1.0,.67]
      else: position = [0.0,0.0,1.0,0.33]
     endcase
    end
  4: begin
    numx = 2
    numy = 2
    case frame(0) of
      1: position = [0.0,0.5,0.5,1.0]
      2: position = [0.5,0.5,1.0,1.0]
      3: position = [0.0,0.0,0.5,0.5]
      else: position = [0.5,0.0,1.0,0.5]
     endcase
    end
  6: begin
    numx = 2
    numy = 3
    case frame(0) of
      1: position = [0.0,0.67,0.5,1.0]
      2: position = [0.5,0.67,1.0,1.0]
      3: position = [0.0,0.33,0.5,0.67]
      4: position = [0.5,0.33,1.0,0.67]
      5: position = [0.0,0.00,0.5,0.33]
      else: position = [0.5,0.0,1.0,0.33]
     endcase
    end
  else: begin
    print,'This case of frame not allowed in vert_cont at present: ',frame
    return
   end
 endcase
charfact = 1./(sqrt(npicts))
!p.position = [position(0)+.17*charfact,position(1)+.09*charfact $
  ,position(2)-.21/numx,position(3)-.1*charfact]
charsize = float(charsize)*charfact
;!p.position = [.20,.09,.75,.85]

badplt = 1e20
if(n_elements(max) ne 0) then begin
  ind = where(temp ge max,cnt)
  if(cnt gt 0) then temp(ind) = badplt
 end

if(n_elements(badval) ne 0) then begin
  ind = where(temp eq badval,badcnt)
  if(badcnt gt 0) then temp(ind) = badplt
 end
;... figure out contour intervals
ind = where(temp ne badplt,cnt)
if(cnt lt 3) then begin 
  print,'Almost all values marked as bad... will not contour'
  return
 end
max0 = max(temp(ind))
min0 = min(temp(ind))

print, "n_elements(lev)", n_elements(lev)

if(n_elements(lev) eq 0) then begin
  dum3 = nice((max0-min0)/15)
  dum4 = nice(min0+dum3)
  while (14*dum3+dum4 lt max0) do begin
    dum3 = nice(2*dum3)
   end
  lev = findgen(15)*dum3+dum4
  ind2 = where(lev le max(temp(ind)) and lev ge min(temp(ind)),cnt)
  if(cnt gt 1) then lev = lev(ind2) $
   else begin
     max1 = nice(max0)+nice(max0-nice(max0))
     min1 = nice(min0)+nice(min0-nice(min0))
    dum3 = nice((max1-min1)/15)
    dum4 = nice(min1+dum3)
    while (14*dum3+min1 lt max1) do dum3 = nice(2*dum3)
    lev = findgen(15)*dum3+min1
    ind2 = where(lev le max(temp(ind)) and lev ge min(temp(ind)),cnt)
    if(cnt gt 1) then lev = lev(ind2) $
     else begin
       print,'really having trouble figuring out contour interval...'
       print,'The array to be contoured is too close to constant - aborting plot'
       
       print,max0,min0
       lev = [min0,(2.*min0+max0)/3.,(min0+2.*max0)/3.,max0]
       print,lev
;       return
;       print,'Enter the array you would like for contours:
;       read,inlev
;       print,inlev
;       lev=inlev
     end
   end 
end

;... make sure fixlev covers enough range
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
if(n_elements(lev) gt 16) then lev = lev(0:15)
if(cps ne 0) then color_index = [color_index,255] $
 else color_index = [color_index,0]

if(n_elements(noerase) eq 0) then noer = 0  else  noer = noerase

if(n_elements(ytickv) eq 0) then begin
  ytickv = 10^findgen(10)
  ind = where(ytickv ge min(zxcx) and ytickv le max(zxcx),cnt)
  if(cnt eq 0) then begin
    tmp = magnitude(min(zxcx))
    ytickv = 10^(tmp(0))*findgen(10)
   endif
  ytickv = ytickv(where(ytickv ge min(zxcx) and ytickv le max(zxcx)))
 end
yticks = n_elements(ytickv)-1

if(cps ne 0) then begin
  tvlct,r,g,b,/get
  tvlct,255,255,255,16
  tvlct,0,0,0,255
end

;... do grid box filled plot
if(boxfill) then begin 
   xint = round([y[0],(y[0:sz[1]-2]+y[1:sz[1]-1])/2,y[sz[1]-1]])
   yint = zxcx
   contour,temp,y,zxcx[0:sz[2]-1],xr=[min(y),max(y)],yr=[max(zxcx),min(zxcx)],xs=5,ys=5,/nodata,/ytype
   for l=0,sz[2]-1 do for i=0,sz[1]-1 do begin
     xbox = [xint[i],xint[i],xint[i+1],xint[i+1]]
     ybox = [yint[l+1],yint[l],yint[l],yint[l+1]]
     c = where(lev ge temp[i,l])
     polyfill,xbox,ybox,color=max([0,min([16,c[0]])])
   end
;stop
   end $
;... do regular contour filled plot
  else if(not nocolor) then begin
      print, "regular: ", lev
    contour,temp,y,zxcx,xr=[min(y),max(y)],yr=[max(zxcx),min(zxcx)],xs=5,ys=5 $
      ,/fill,c_colors=color_index,lev=lev,/ytype,noer=noer
    noer = 1
  end

if(not boxfill and contr) then begin
  contour,temp,y,zxcx,xr=[min(y),max(y)],yr=[max(zxcx),min(zxcx)],lev=lev $
    ,/fol,max=badplt,xs=5,ys=5,noer=noer,/ytype,color=c_color $
    ,c_thick=c_thick,_extra=uextra
  noer = 1
 end

;... draw axes
if(min(y) lt -90 or max(y) gt 90) then begin
  if(n_elements(xtickv) eq 0) then begin
    xtickv = findgen(7)*60+min(y)
    xtickv = xtickv(where(xtickv ge min(y) and xtickv le max(y)))
   end
  xticks = n_elements(xtickv)-1
  plot_io,[min(y)],[max(zxcx)],/noeras,/nodata,xstyle=1,ystyle=5,xmin=6,ymin=9 $
   ,xtickv=xtickv,xr=[min(y),max(y)],yr=[max(zxcx),min(zxcx)],xtitle='Longitude' $
   ,title=title,xticks=xticks,ytitle=pressYTitle,charthick=charthick $
   ,charsize=charsize,ticklen=-.02
  end $
 else begin
   if(n_elements(xtickv) eq 0) then begin
     xtickv = findgen(7)*30-90
     xtickv = xtickv(where(xtickv ge min(y) and xtickv le max(y)))
    end
   xticks = n_elements(xtickv)-1
   plot_io,[min(y)],[max(zxcx)],/noeras,/nodata,xstyle=1,ystyle=5,xmin=3,ymin=9 $
    ,xtickv=xtickv,xr=[min(y),max(y)],yr=[max(zxcx),min(zxcx)],xtitle='Latitude' $
    ,title=title,xticks=xticks,ytitle=pressYTitle,charthick=charthick $
    ,charsize=charsize,ticklen=-.02
end

axis,yaxis=0,/ytype,ytitle=pressYTitle,yr=[max(zxcx),min(zxcx)],ymin=9,ys=1 $
  ,charthick=charthick,charsize=charsize,ticklen=-.02
dum1 = [-7*alog(max(zxcx)/1000.),-7*alog(min(zxcx)/1000.)]
plot,[min(y)],[max(zxcx)],/noeras,/nodata,xstyle=5,ystyle=5,xr=[min(y),max(y)] $
  ,yr=dum1
axis,yaxis=1,ytitle='Height (km)',yr=dum1,ys=1,charthick=charthick $
  ,charsize=charsize,ticklen=-.02

;... draw scale boxes
if(not nocolor) then begin
  xax0 = (!p.position(2)+.165/numx)*!d.x_size
  xax1 = (!p.position(2)+.197/numx)*!d.x_size
  yax0 = !p.position(1)*!d.y_size
  yax1 = !p.position(3)*!d.y_size
  temp = magnitude(max(lev))
  temp = temp(0)
  atemp = abs(temp)
  dum = (atemp/3)+(min([1,(atemp mod 3)]))
  if(temp gt 0) then dum = dum-1
  temp = 3*dum*temp/atemp
  clvls = lev
  if(temp gt 2 or temp lt -2) then begin
    clvls = lev/(10.^temp)
    xyouts,xax1,yax1+6,/dev,'x10!U'+strtrim(temp,2) $
	,charsize=charsize*0.72,ali=1,charthick=charthick
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
	,yticks=1,yminor=0,charthick=charthick
;... labels
;stop
;    dum1 = magnitude(clvls(c))
    dum2 = magnitude(clvls(c+1)-clvls(c))
    case dum2(0) of 
      -4: strtmp = string(clvls(c),f='(f8.4)')
      -3: strtmp = string(clvls(c),f='(f7.3)')
      -2: strtmp = string(clvls(c),f='(f6.2)')
      -1: strtmp = string(clvls(c),f='(f5.1)')
      else: strtmp = strtrim(round(clvls(c)),2)
     endcase
;    if(dum1(0) eq 0) then strtmp = string(clvls(c),f='(f5.2)') $
;     else strtmp = strtrim(round(clvls(c)),2)
    xyouts,xax0,yax0+c*yinc-5,strtmp,charsize=charsize*0.7,ali=1,/dev $
      ,charthick=charthick
   end
  c = range-1
;  dum1 = magnitude(clvls(c))
  dum2 = magnitude(clvls(c)-clvls(c-1))
  case dum2(0) of 
    -4: strtmp = string(clvls(c),f='(f8.4)')
    -3: strtmp = string(clvls(c),f='(f7.3)')
    -2: strtmp = string(clvls(c),f='(f6.2)')
    -1: strtmp = string(clvls(c),f='(f5.1)')
    else: strtmp = strtrim(round(clvls(c)),2)
   endcase
;  if(dum1(0) eq 0) then strtmp = string(clvls(c),f='(f5.2)') $
;   else strtmp = strtrim(round(clvls(c)),2)
  xyouts,xax0-3,yax0+c*yinc-5,strtmp,charsize=charsize*0.7,ali=1,/dev $
    ,charthick=charthick
 end

if(cps ne 0) then tvlct,r,g,b
end
