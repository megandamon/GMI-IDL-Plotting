pro get_hdf_var,full_path_fn,field,data,bad_val=bad_val,begin_date=begin_date, $
                begin_time=begin_time,delta_time=delta_time,getbad=getbad, $
                time_units=time_units

; procedure to read files with hdf_sd format
;
; field variable names can be found from "/ford1/local/bin/ncdump -h <file>"  
;             
; the reversing capability of earlier versions has been discontinued.

if(n_elements(getbad) eq 0) then getbad = 0 else getbad = 1

my_file_id = hdf_sd_start( full_path_fn )

valid=0
attempt=0

while (valid eq 0) do begin
 on_ioerror, tryagain

 my_field_id = hdf_sd_select(my_file_id, hdf_sd_nametoindex(my_file_id,field))
 hdf_sd_getdata,my_field_id,data

 valid = 1

 tryagain: attempt = attempt + 1
 if ((attempt gt 1) and (valid eq 0)) then begin
  print,' '
  stop,'GET_HDF_VAR: Cannot retrieve variable "'+field+'"'
 endif
endwhile

if(getbad eq 1) then begin
 gindex = hdf_sd_attrfind(my_field_id,'missing_value')
 hdf_sd_attrinfo,my_field_id,gindex,data=bad_val,NAME=name,TYPE=type,COUNT=count
 bad_val=bad_val[0]
endif

if( field eq 'time' ) then begin
 gindex = hdf_sd_attrfind(my_field_id,'begin_date')
 hdf_sd_attrinfo,my_field_id,gindex,data=begin_date,NAME=name,TYPE=type,COUNT=count
 begin_date=begin_date[0]
 gindex = hdf_sd_attrfind(my_field_id,'begin_time')
 hdf_sd_attrinfo,my_field_id,gindex,data=begin_time,NAME=name,TYPE=type,COUNT=count
 begin_time=begin_time[0]
 gindex = hdf_sd_attrfind(my_field_id,'time_increment')
 hdf_sd_attrinfo,my_field_id,gindex,data=delta_time,NAME=name,TYPE=type,COUNT=count
 delta_time=delta_time[0]
 gindex = hdf_sd_attrfind(my_field_id,'units')
 hdf_sd_attrinfo,my_field_id,gindex,data=time_units,NAME=name,TYPE=type,COUNT=count
 r=strpos(time_units,' ',0)
 time_units=strmid(time_units,0,r)
endif

hdf_sd_end,my_file_id

end
