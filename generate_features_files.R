####
## Generate csv files of 'features' for a directory of images.
## 
## This script will try and generate a csv of inception-v3 features (2048 values)
## for every directory of images in a given directory
##
###

# The source directory full of directories of images. 
# For example, this might be a survey directory and each subdirectory is a 
# camera/location
#SOURCE_DIR = "/Volumes/camera_trap_data/Palewell_Common/"
SOURCE_DIR = "cats_and_dogs_filtered/validation/"

# Settings for custom crop function to remove the top 30px and bottom 120px of every image
TOP_TRIM = 30
BOTTOM_TRIM = 120

# Size of files to filter ignore (in bytes) (have encountered some problematic empty images)
MIN_SIZE = 100000
MIN_SIZE = 1000

## Run this first to install tensorflow package
#install.packages("tensorflow")

# Then run these to install tensorflow on the system
#library(tensorflow)
#install_tensorflow()
#tensorflow::install_tensorflow(extra_packages=c('pillow', 'h5py'))

# Load tensorflow
library(tensorflow)
#tf$constant("Hello Tensorflow") # This will test if its working

# Install keras package for precompiled networks
# install.packages(keras)
library(keras)

library(data.table)

# Load custom crop function
reticulate::source_python('crop_generator.py')

# Load an inception model without fully connected top layer, with max pooling
# This is our 'feature generator'
inception_v3_feature_model = keras:::application_inception_v3(
  include_top = FALSE,
  weights = "imagenet",
  input_tensor = NULL,
  input_shape = NULL,
  pooling = "max"
)

# Given an image path, extract features for that image
# This function is for inception_v3
# Note the inception_v3_preprocess_input line and notes in help:
# "Do note that the input image format for this model is different than for the VGG16 and ResNet models (299x299 instead of 224x224)."
extract_features_inception_v3 <- function(img_path) {
  
  # Load image as colour and resize
  img = image_load(
    img_path,
    grayscale = FALSE,
    #target_size = c(299, 299),
    #interpolation = "nearest"
  )
  
  # Use our custom crop function to remove the top 30px and bottom 120px of every image
  img_crop = defined_crop(img, top_trim = TOP_TRIM, bottom_trim = BOTTOM_TRIM) # Trim infobar
    
  # Resize image to 299 x 299
  x = image_array_resize(img_crop, width=299, height=299)
  
  # Plot for visualisation
  #x %>% as.raster(max = 255L) %>% plot()
  
  # Reshape for preprocess function
  x <- array_reshape(x, c(1, dim(x)))
  vals = inception_v3_preprocess_input(x)
  
  # pass image into inception model and get output features
  # e.g. predicting to near the final layers and getting those values
  feats <- inception_v3_feature_model %>% predict(vals)
  return(feats)
}

# Directory of directories to generate features from
dirs = list.dirs(SOURCE_DIR, recursive = FALSE)

# For each directory
for (train_dir in dirs) {
  print(sprintf("Processing dir: %s", train_dir))
  
  # Get list of jpg/JPG images in directory (including subdirs)
  files = list.files(train_dir, pattern = "*.jpg|*.JPG", full.names = TRUE, recursive = TRUE, include.dirs=FALSE)
  
  # filter out files of <MIN_SIZE (have encountered some problematic empty images)
  files = files[sapply(files, file.size) > MIN_SIZE]

  # If there are images to process
  if (length(files) > 0) {
    pos_feature_list = list()
    
    # For each image
    for (i in 1:length(files)) {
      f = files[i]
      print(sprintf("[%d] Processing: %s\n", i, f))
      
      # Try and generate features
      tryCatch({
    	  pos_feature_list[[f]] = extract_features_inception_v3(f)
    	}, error=function(e) {
        # If something goes wrong, store NA instead
        pos_feature_list[[f]] = NA
        print(sprintf("Error processing $s", f))
      })
    }
  
    # Convert to large data table
    pos_feature_df = data.table(filename = names(pos_feature_list), matrix(unlist(pos_feature_list), nrow = length(pos_feature_list), byrow = TRUE))
   
    # Store result as a file for this directory in the current working directory
    fwrite(pos_feature_df, paste0(gsub("/", "-", train_dir), "_features_v3.csv"))
  } else {
    # If not files were found, store a file with 'EMPTY' in the name instead (can be useful when running unattended)
    file.create(paste0(gsub("/", "-", train_dir), "_features_v3_EMPTY.csv"))
  }
}


