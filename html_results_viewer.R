###
# Script to take results file and visualise data as local HTML file
# Assumes files are locally available (e.g. local disk or usb drive)
###

library(stringi)
library(data.table)

# Source directory to look for results files in
SOURCE_DIR = "~/Dropbox/R/inception_v3/"

# Function to create html file from results and template file
html_generator <- function(data, new_html_file, view = FALSE) {
  # Load template file to add images to
  template_htmlfile = "template.html"
  lines <- readLines(template_htmlfile, warn=FALSE)
  
  # Convert data to an image with class given by classification
  #new_html = sprintf("<img class = '%s img-thumbnail' width='200' src='%s' />", data$class, data$filename)
  
  new_html = sprintf("<a href='%s' target='_blank'>
      <img src='%s' alt='%s' class='%s' loading='lazy' style='width:200px'>
    </a>", data$filename, data$filename, data$class, data$class)
  
  # Find the comment to replace in the image
  toSubcode <- paste0("<!--images_here-->")
  # Get its location
  location <- which(stri_detect_fixed(lines, toSubcode) )
  
  # Create new lines including new data
  newlines <- c(lines[1:(location-1)],
                new_html,
                lines[min(location+1, length(lines)):length(lines)])  # be careful when insertHTML being last line in .Rmd file
  # Write new file
  write(newlines, new_html_file)
  
  if (view == TRUE) {
    # View file
    rstudioapi::viewer(new_html_file)
  }
} #end html_generator

# Look for feature files in the SOURCE_DIR
files = list.files(SOURCE_DIR, pattern = "*_results_v3.csv", full.names = TRUE)

# For each results file
for (f in files) {
  print(sprintf("Processing file %s", f))
  
  # Read in results data
  results_data = fread(f)
  
  # Generate html file of images
  html_generator(results_data, gsub("_results_v3.csv", "_images.html", f))
}
