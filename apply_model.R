####
## Generate csv files of 'features' for a directory of images.
## 
## This script will try and generate a csv of inception-v3 features (2048 values)
## for every directory of images in a given directory
##
###

# Source directory to look for feature files in
SOURCE_DIR = "~/Dropbox/R/inception_v3/"

MODEL_NAME = "dog_cat_model"
#MODEL_NAME = "hp_model"

# Classification threshold for predictions
THRESHOLD = 0.5

#positive_class_label = "human"
#negative_class_label = "non-human"
positive_class_label = "cat"
negative_class_label = "dog"

library(tensorflow)
library(keras)
library(data.table)

# Load a previously saved model
classify_model = load_model_tf(MODEL_NAME)

# Look for feature files in the SOURCE_DIR
files = list.files(SOURCE_DIR, pattern = "*_features_v3.csv", full.names = TRUE)
for (f in files) {
  print(sprintf("Processing file %s", f))
  
  # Read in feature data
  feature_data = fread(f)
  
  filenames = feature_data$filename
  # Get rid of filesname (just leaving feature data)
  input_data = feature_data[, filename:=NULL]
  
  # Apply model to feature data
  result = tf$constant(as.matrix(input_data)) %>% classify_model
  
  result_table = data.table(filename = filenames, p = as.numeric(result))
  result_table$class = ifelse(result_table$p > THRESHOLD, positive_class_label, negative_class_label)
  
  fwrite(result_table, file = gsub("_features_v3.csv", "_results_v3.csv", f))
  
}


