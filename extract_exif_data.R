
### Generate exif data for 
# install.packages("exiftoolr")
#exiftoolr::install_exiftool()
library(exiftoolr)
# install.packages("magick")
#library(magick)

# exif_data = exif_read(
#   path = "/Volumes/camera_trap_data/Richmond Park 2018 untagged/",
#   tags = c("SourceFile", "DateTimeOriginal", "CreateDate", "Directory", "ExposureTime", "NumberOfImages", "Subject"),
#   recursive = TRUE,
#   quiet = TRUE,
#   pipeline = "csv"
# )
# write.csv(exif_data, "RichmondPark2018_Exif.csv")
# 
# 
# folders = list.files("/Volumes/camera_trap_data/Palewell_Common/", pattern = "*DCIM", full.names = TRUE, include.dirs = TRUE)
# exif_data = exif_read(
#   path = folders,
#   tags = c("SourceFile", "DateTimeOriginal", "CreateDate", "Directory", "ExposureTime", "NumberOfImages", "Subject"),
#   recursive = TRUE,
#   quiet = TRUE,
#   pipeline = "csv"
# )
# write.csv(exif_data, "PalewellCommon_Exif.csv")
# saveRDS(exif_data, file = "palewell_commmon.rds")

# 
# folders = list.files("/Volumes/camera_trap_data/Barnes Area Survey (not tagged)/Bank of England/", pattern = "*DCIM", full.names = TRUE, include.dirs = TRUE)
# exif_data = exif_read(
#   path = folders,
#   tags = c("SourceFile", "DateTimeOriginal", "CreateDate", "Directory", "ExposureTime", "NumberOfImages", "Subject"),
#   recursive = TRUE,
#   quiet = TRUE,
#   pipeline = "csv"
# )
# saveRDS(exif_data, file = "Bank_of_England_Exif.rds")
# exif_data = readRDS("Bank_of_England_Exif.rds")
# write.csv(exif_data, "Bank_of_England_Exif.csv")
# 
# folders = list.files("/Volumes/camera_trap_data/Roehampton_Golf_Course/", pattern = "*DCIM", full.names = TRUE, include.dirs = TRUE)
# exif_data = exif_read(
#   path = folders,
#   tags = c("SourceFile", "DateTimeOriginal", "CreateDate", "Directory", "ExposureTime", "NumberOfImages", "Subject"),
#   recursive = TRUE,
#   quiet = TRUE,
#   pipeline = "csv"
# )
# saveRDS(exif_data, file = "Roehampton_Golf_Course_Exif.rds")
# 
# 
# exif_data = readRDS("Roehampton_Golf_Course_Exif.rds")
# exif_data$Subject = unlist(exif_data$Subject)
# write.csv(exif_data, "Roehampton_Golf_Course_Exif.csv")


folders = list.files("/Volumes/camera_trap_data/BrockwellPark/BrockwellPark_Hogwatch_2019/", full.names = TRUE, include.dirs = TRUE)
exif_data = exif_read(
  path = folders,
  tags = c("SourceFile", "DateTimeOriginal", "CreateDate", "Directory", "ExposureTime", "NumberOfImages", "Subject"),
  recursive = TRUE,
  quiet = TRUE,
  pipeline = "csv"
)
saveRDS(exif_data, file = "BrockwellPark_Hogwatch_2019.rds")



