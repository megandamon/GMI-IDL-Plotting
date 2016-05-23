pro checkFile, fileName, diag

    result = FILE_TEST(fileName)
    if (result ne 1) then begin
        print, fileName + ' does not exist: ', result
        stop
    end

    if (diag eq 1) then begin
        print, fileName + ' exists: ', result
    end
end

function returnValues, fileName, valueName
    ncdf_info,iNum,fileName
    ncdf_varget,iNum,ncdf_varid(iNum,valueName),values
    ncdf_close,iNum
    return, values
end
