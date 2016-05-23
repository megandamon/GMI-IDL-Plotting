pro gmiidl, otherArgs
	compile_opt strictarr

!path="/home/ssteenro/idl/:"+!path
.compile ncdf_info
.r globe_cont_local
.r GmiReaderTool
.r createContoursFromArray
.r GmiStringOperations.pro
.r GmiNetCdfTools.pro
.r GmiDataTools.pro
.r GmiPlotTools.pro
.r GmiColumn.pro
.r GmiAmonthly.pro
.r GmiOverpass2.pro
.r GmiStations.pro
.r GmiDoAllPlots.pro

	args = command_line_args(count=nargs)

	help, nargs
	if (nargs gt 0L) then print, args

	dir1 = args[0]
	dir2 = args[1]
	exp1 = args[2]
	exp2 = args[3]
	year1 = args[4]
	year2 = args[5]
	month = args[6]
	postScript = args[7]
	diag = args[8]

	print, dir1, " ", exp1, " ", year1, " ", month
	print, dir2, " ", exp2, " ", year2, " ", month
	print, "post script? ", postScript
	print, "diag?", diag

	; set font to device font
	!p.font=0

        fileString1 = dir1 + '/'+ year1 + '/gmic_' + exp1 + '_' + year1 + '_' + month
        fileString2 = dir2 + '/'+ year2 + '/gmic_' + exp2 + '_' + year2 + '_' + month


        ; restart file1
        file1 = fileString1 + '.rst.nc'
        file2 = fileString2 + '.rst.nc'
        checkFile, file1, diag
        checkFile, file2, diag


	print, "made it to the end"

end
