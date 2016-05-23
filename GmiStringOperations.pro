function trimSpeciesNames, speciesNamesArray
   numSpecies = n_elements(speciesNamesArray)
   speciesNamesArray = strcompress(speciesNamesArray)

   for i=0,numSpecies-1 do begin
       specieLabel = strmid(speciesNamesArray[i],0,strlen(speciesNamesArray[i])-1)
       specieLabel = strjoin(strsplit(specieLabel, /extract), '_') 
       specieLabel = strjoin(strsplit(specieLabel, ')', /extract), '') 
       specieLabel = strjoin(strsplit(specieLabel, '(', /extract), '') 
       speciesNamesArray[i]=specieLabel       
   end

   return, speciesNamesArray
end


function createTitleUsingLevel, title, levels, levelIndex, diag

    if (diag eq 1) then print, "start createTitleUsingLevel"
    levelString = string(strcompress(fix(levels[levelIndex])))
    levelString = strmid(levelString[0],1,strlen(levelString[0]))
    return, title+string(levelString)

end

function createTitleUsingLevelIndex, title, levels, levelIndex, diag

    if (diag eq 1) then print, "start createTitleUsingLevelIndex"
    levelString = string(strcompress(levelIndex))
    levelString = strmid(levelString[0],1,strlen(levelString[0]))
    return, title+"_lev_"+string(levelString)

end

function createTitleUsingTwoLevels, title, levels, pressure1, pressure2, diag
    
    if (diag eq 1) then print, "start createTitleUsingTwoLevels"
    
    index1 = getClosestLevelIndex (levels, pressure1, diag)
    index2 = getClosestLevelIndex (levels, pressure2, diag)

    titleString = createTitleUsingLevel (title, levels, index1, diag)
    titleString = createTitleUsingLevel (titleString + "_", levels, index2, diag)

    return, titleString

end
