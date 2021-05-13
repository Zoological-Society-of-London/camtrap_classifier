####
## Generate classifier from files of positive and negative class
##
## This script will extract inception-v3 features (2048 values)
## for image from two directories (on the 'positive' class, the other
## the 'negative' class (e.g. cat vs dog)). It will then build
## a classifier to discriminate those classes and save that 
## as MODEL_NAME
##
###

# Input directory of class 1
TRAINING_POS_DIRECTORY = "cats_and_dogs_filtered/train/cats/"
#TRAINING_POS_DIRECTORY = "~/Documents/data/shiya_images/human"

# Input directory of class 2
TRAINING_NEG_DIRECTORY = "cats_and_dogs_filtered/train/dogs"
#TRAINING_NEG_DIRECTORY = "~/Documents/data/shiya_images/non_human/"

MODEL_NAME = "dog_cat_model"
#MODEL_NAME = "human_non_human_model"

# Settings for custom crop function to remove the top 30px and bottom 120px of every image
TOP_TRIM = 30
BOTTOM_TRIM = 120

## You will need to have run this first to install tensorflow package
#install.packages("tensorflow")

# Then run these to install tensorflow on the system
#library(tensorflow)
#install_tensorflow() 


# Load tensorflow
library(tensorflow)
#tf$constant("Hello Tensorflow") # This will test if its working

# Install keras package for precompiled networks
# install.packages(keras)
library(keras)

# Load custom crop function
library(reticulate)
source_python('crop_generator.py') # Seems to throw a subscript

# Inception model without fully connected top layer, with max pooling
# This is our 'feature generator'
# NB: I've occasionally had problems with loading this inception-v3 model
#  possibly due to conflicting h5py version in python. Re-installing from above
#  seems to fix it for the moment
inception_v3_feature_model = application_inception_v3(
  include_top = FALSE,
  weights = "imagenet",
  input_tensor = NULL,
  input_shape = NULL,
  pooling = "max"
)

# Given an image path, extract features for that image
# This function is for inception_v3
# Not the inception_v3_preprocess_input line and notes in help:
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
  img_crop = defined_crop(img, top_trim = TOP_TRIM, bottom_trim = BOTTOM_TRIM, min_width = 50, min_height = 50) # Trim infobar
  
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

classify_image_features <- function(feat) {
  pred <- classify_model %>% predict(feat)
  return(pred)
}


###
# Get data...
###

#ptm <- proc.time()
# Load training images and get features
pos_files = list.files(TRAINING_POS_DIRECTORY, pattern = "*.JPG|*.jpg", full.names = TRUE)
pos_feature_list = list()
for (i in 1:length(pos_files)) {
  f = pos_files[i]
  print(sprintf("[%d] Processing: %s\n", i, f))
  pos_feature_list[[f]] = extract_features_inception_v3(f)
}
#proc.time() - ptm

# Load training images and get features
neg_files = list.files(TRAINING_NEG_DIRECTORY, pattern = "*.JPG|*.jpg", full.names = TRUE)
neg_feature_list = list()
for (i in 1:length(neg_files)) {
  f = neg_files[i]
  print(sprintf("[%d] Processing: %s\n", i, f))
  neg_feature_list[[f]] = extract_features_inception_v3(f)
}

# Convert inputs into dataframe
inputs_pos <- data.frame(matrix(unlist(pos_feature_list), nrow=length(pos_feature_list), byrow=TRUE))
inputs_neg <- data.frame(matrix(unlist(neg_feature_list), nrow=length(neg_feature_list), byrow=TRUE))

library(data.table) # Or change the below to write.csv if you'd rather use data frames
fwrite(inputs_pos, "inputs_pos.csv")
fwrite(inputs_neg, "inputs_neg.csv")

# Get outputs matched to inputs
output_pos = rep(1, nrow(inputs_pos))
output_neg = rep(0, nrow(inputs_neg))

# Make single variables for both
inputs = rbind(inputs_pos, inputs_neg)
outputs = c(output_pos, output_neg)

# Set seed for reproducability
set.seed(101) 

# Get indices to split outputs into training (75%) and test (25%)
sample = caTools::sample.split(outputs, SplitRatio = .75)

# Use these to partition inputs
train_x = as.matrix(subset(inputs, sample == TRUE))
test_x =  as.matrix(subset(inputs, sample == FALSE))

# And outputs
train_y =  as.matrix(outputs[sample == TRUE])
test_y =  as.matrix(outputs[sample == FALSE])

## Train model...

# Very simple classification MLP
#classify_model <- keras_model_sequential()

# 2048 inputs into 100 hidden units
#classify_model %>% 
#  layer_dense(units = 100, activation = 'relu', input_shape = c(2048)) %>%
#  layer_dense(units = 1, activation = 'sigmoid')

# Alternative simple classification MLP with dropout
classify_model <- keras_model_sequential()
# 2048 inputs into 784 hidden units (with dropout to help generalisation)
classify_model %>%
  layer_dense(units = 784, input_shape = c(2048)) %>% # Size of layer
  layer_dropout(rate=0.2) %>%                 # Apply dropout to nodes in layer
  layer_activation(activation = 'relu') %>% # Activation of nodes in layer
  layer_dense(units = 1, activation = 'sigmoid') # final layer is is single softmax output

#compiling the defined model with metric = accuracy and optimiser as adam.
classify_model %>% compile(
  optimizer = 'rmsprop',
  loss = 'binary_crossentropy',
  metrics = c('accuracy')
)

# Fit model
classify_model %>% fit(train_x, train_y, epochs = 200, batch_size = 256)

# Evaluate model
loss_and_metrics <- classify_model %>% evaluate(test_x, test_y, batch_size = 128)
(loss_and_metrics)

##prediction 
prob_y <- classify_model %>% predict(test_x, batch_size = 128)
pred_y = round(prob_y)

# Confusion matrix
conf_mat = table(pred_y, test_y)
(conf_mat) # Count
(prop.table(conf_mat)) # Proportion

# Save the model to file
classify_model %>% save_model_tf(MODEL_NAME)



