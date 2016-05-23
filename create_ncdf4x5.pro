pro create_ncdf4x5,out_name,cdfid,emissid,outprs,lev

cdfid = ncdf_create(out_name,/clobber)

lonid = ncdf_dimdef(cdfid,'longitude_dim',72)
latid = ncdf_dimdef(cdfid,'latitude_dim',46)
prsid = ncdf_dimdef(cdfid,'sigma_dim',lev)
spcid = ncdf_dimdef(cdfid,'species_dim',8)
spc2did = ncdf_dimdef(cdfid,'species2d_dim',23)
timid = ncdf_dimdef(cdfid,'time_dim',12)
wrdid=ncdf_dimdef(cdfid,'word',10)

emissid = ncdf_vardef(cdfid,'emiss',[lonid,latid,prsid,spcid,timid])
emiss2did = ncdf_vardef(cdfid,'emiss2d',[lonid,latid,spc2did,timid])

lonvarid = ncdf_vardef(cdfid,'longitude_dim',[lonid])
latvarid = ncdf_vardef(cdfid,'latitude_dim',[latid])
prsvarid = ncdf_vardef(cdfid,'sigma_dim',[prsid])
timvarid = ncdf_vardef(cdfid,'time_dim',[timid])

; THIS WILL ALLOW GTX TO DISPLAY MONTH NAMES

ncdf_attput,cdfid,timvarid,'long_name','month'
ncdf_attput,cdfid,timvarid,'coord_labels','month'
ncdf_attput,cdfid,timvarid,'selection_category','NULL'
tim_name_id = ncdf_vardef(cdfid,'month',[wrdid,timid],/char)
ncdf_attput,cdfid,tim_name_id,'selection_category','NULL'
ncdf_control,cdfid,/endef

; SAVE THE VALUES OF THE DIMENSIONS

ncdf_varput,cdfid,latvarid,(indgen(46)*4)-90
ncdf_varput,cdfid,lonvarid,indgen(72)*5
ncdf_varput,cdfid,prsvarid,outprs


; THIS WILL ALLOW GTX TO DISPLAY MONTH NAMES

month_name = [ 'January   ','February  ','March     ','April     ', $
'May       ','June      ','July      ','August    ', $
'September ','October   ','November  ','December  ']

month_name = reform(byte(month_name),10,12)

ncdf_varput,cdfid,timvarid,indgen(12)+1
ncdf_varput,cdfid,tim_name_id,month_name


end
