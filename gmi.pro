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
xlct

print, 'Starting GmiDoAllPlots'
GmiDoAllPlots, "/archive/anon/pub/gmidata2/users/mrdamon/HindcastFFIgac2/", "/archive/anon/pub/gmidata2/users/mrdamon/HindcastFF/","HindcastFFIgac2", "HindcastFF", '2000','2000', 'dec', 1,1
print, 'Batch job complete'
