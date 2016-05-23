pro Test
   
   directory = "/discover/nobackup/mrdamon/Devel/GMI_IDL/"
   fileName = "amonthly.const.strat.txt"

   species = readFileLines (directory+fileName, 1)
   print, "Species: ", species

   print, testArrayForString ('BB', species)

end
