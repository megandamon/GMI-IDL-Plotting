pro ncdf_info, cdfid, filename, dim_name=dim_name, dim_size=dim_size $
  ,var_name=var_name, var_dims=var_dims, var_atts=var_atts, cdfid1=cdfid1

;+ 
;   Procedure to open and give info about a netcdf file. Prints a table
;    of dimensions and variable names and sizes (and number of attributes 
;    on each variable). Also gives form of command to get a variable
;
;-
if(n_params() eq 0) then begin
  print,'ncdf_info, cdfid, filename, dim_name=dim_name, dim_size=dim_size $'
  print,',var_name=var_name, var_dims=var_dims, var_atts=var_atts, cdfid1=cdfid1'
  return
  end
if (n_params() eq 1) then begin
  filename = cdfid
 end


catch, ierror
if(ierror ne 0) then begin
  print,'Failed to open file: ',filename
  return
 end
cdfid = ncdf_open(filename)
catch,/cancel


cdfid1 = cdfid
res = ncdf_inquire(cdfid)

;.... get and print dimension info about file
print,''
print,'Dimension names and sizes:'
print,'   No.  Size                Name'
dim_size = lonarr(res.ndims)
dim_name = strarr(res.ndims)
for n=0,res.ndims-1 do begin
  ncdf_diminq,cdfid,n,name,size
  dim_name(n) = name
  dim_size(n) = size
  print,n,dim_size(n),dim_name(n),form='(2i6,a20)'
  end

;.... get and print variable info about file
print,''
print,'Variable names and sizes:'
print,'   No.  Atts  Dims                  Name    Dimensions'
var_name = strarr(res.nvars)
var_dims = lonarr(res.nvars)
var_atts = lonarr(res.nvars)
for n=0,res.nvars-1 do begin
  vres = ncdf_varinq(cdfid,n)
  var_name(n) = vres.name
  var_dims(n) = vres.ndims
  var_atts(n) = vres.natts
  print,n,var_atts(n),var_dims(n),'  ',vres.name,'  ',dim_size(vres.dim) $
    ,form='(3i6,a2,a20,a2,12i6)'
  end

print,''
print,'Use: ncdf_varget, cdfid, VarNo., variable (,count=[cnt1,cnt2,...]) (,offset=[0,0...])'
print,'  to get the data'
print,''
return
end
