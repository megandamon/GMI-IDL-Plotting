pro test, otherArgs
	compile_opt strictarr

	args = command_line_args(count=nargs)

	help, nargs
	if (nargs gt 0L) then print, args

	help, otherArgs
	if (n_elements(otherArgs) gt 0L) then print, otherArgs
	
	print, "made it to the end"

end
