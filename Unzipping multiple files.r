library(plyr)



###Price data
# get all the zip files
zipF <- list.files(path = "E:/INTL-34812-TotalReturnIndex", pattern = "*.zip", full.names = TRUE)

outDir<-"E:/tri"
#unzip(zipF,exdir=outDir)

# unzip all your files
ldply(.data = zipF, .fun = unzip, exdir = outDir)
