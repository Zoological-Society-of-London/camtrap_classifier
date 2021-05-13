###
# Script to take results file and insert resulst into original images
#   Adds the following to each file (will append to whatever metadat exists):
#   xmp tags:
#     Publisher=ctc_v0.1
#     HierarchicalSubject=ctc_species|<classname> # Where <classname> is the labelled 'class' in the results file
#     HierarchicalSubject=ctc_probability|<classname>|<prob> # Where <classname> is the labelled 'class' in the results file, and <prob> is the probability
#   iptc:
#     keywords=ctc_species|<classname> # Where <classname> is the labelled 'class' in the results file
#     keywords=ctc_probability|<classname>|<prob> # Where <classname> is the labelled 'class' in the results file, and <prob> is the probability
#
# Assumes files are locally available (e.g. local disk or usb drive)
###

library(exiftoolr)
#install_exiftool() # Run this to get exiftoolr to install exiftool on your system

# Source directory to look for feature files in
SOURCE_DIR = "~/Dropbox/R/inception_v3/"

exif_insertion <- function(data, overwrite_original = FALSE) {
  
  for (i in 1:nrow(data)) {
    filename = data$filename[i]
    probability = data$p[i]
    class = data$class[i]
      
    # Construct tags to be added to each file
    tag0 = sprintf("-xmp-dc:Publisher+='ctc_v0.1'")
    tag1 = sprintf("-xmp-lr:HierarchicalSubject+=ctc_species|%s", class)
    tag2 = sprintf("-xmp-lr:HierarchicalSubject+=ctc_probability|%s|%f", class, probability)
    tag3 = sprintf("-keywords+=ctc_species|%s", class)
    tag4 = sprintf("-keywords+=ctc_probability|%s|%f", class, probability)
    
    # Set the overwrite flag accordingly
    overwrite = ifelse(overwrite_original, "-overwrite_original", "")
    
    # Call exiftool to update exifdata
    exif_call(args = c(tag0, tag1, tag2, tag3, tag4, overwrite), path = filename)
  }
}

# Look for results files in the SOURCE_DIR
files = list.files(SOURCE_DIR, pattern = "*_results_v3.csv", full.names = TRUE)

# For each results file
for (f in files) {
  print(sprintf("Processing file %s", f))
  
  # Read in results data
  results_data = fread(f)
  
  # Add results to exif data of images...
  exif_insertion(results_data, overwrite_original = TRUE)
}
