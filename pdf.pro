pro pdf,events,delta=delta,pvals=pvals,xvals=xvals,plot=plot,title=title,$
xtitle=xtitle,ytitle=ytitle,charsize=charsize,thick=thick,$
yrange=yrange,ystyle=ystyle,xrange=xrange,xstyle=xstyle,$
colshade=colshade,shade=shade,width=width

ntotal=n_elements(events)
values=reform(events,ntotal)


;returns xvals(j) and pvals(j)/total(pvals)=histogram
;  delta is the bin size

if n_elements(delta) eq 0 then delta = 1.
if n_elements(colshade) eq 0 then colshade=200
vals=values/float(delta)
minval=min(vals)
maxval=max(vals)
;imin=fix(minval)
imin=0
imax=fix(maxval)

xavg=avg(values)
xvar=avg( (values-xavg)^2 )

if not keyword_set(xrange) then xrange=[fix(min(values))-1,1+fix(max(values))]
if not keyword_set(xstyle) then xstyle=1
if not keyword_set(ystyle) then ystyle=1

xvals=(imin-.5 + findgen(imax+3.-imin + 2.))*delta - delta
pvals=histogram(vals,min=imin-2.,max=imax+2.)/float(ntotal)        ;normalized 

		if keyword_set(plot) then begin
if not keyword_set(yrange) then yrange=[0,max(pvals)*1.05]
if not keyword_set(xtitle) then xtitle='x'
if not keyword_set(ytitle) then ytitle='P('+xtitle+')'
if not keyword_set(charsize) then charsize=1
if not keyword_set(thick) then thick=1
if not keyword_set(title) then $
title='sigma= '+str(sqrt(xvar))+'!cmean= '+str(xavg)

if (keyword_set(width)) then pvals=smooth(pvals,width)

plot,xvals,pvals,psym=10,title=title,xtitle=xtitle,ytitle=ytitle,$
yrange=yrange,ystyle=ystyle,xrange=xrange,xstyle=xstyle,/nodata,$
charsize=charsize,yminor=2

	if keyword_set(shade) then begin

	for j=0,n_elements(pvals)-1 do begin
	xless=xvals(j)-delta/2. & xmore=xvals(j)+delta/2.
polyfill,[xless,xmore,xmore,xless],[0,0,pvals(j),pvals(j)],$
	color=colshade
	endfor
	endif else begin
	oplot,xvals,pvals,psym=10,thick=thick
	endelse

		endif

return
end

