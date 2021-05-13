# camptrap_classifier

The scrips implement the inception_v3 based classifier developed in Li et al (in prep). The scripts present three different processes:

## Create a classifier

1) Create training feature sets for positive and negative example images of a class (e.g. fox/non-fox) [including possibly trimming off any 'info bars']
2) Create and save a simple MLP classifier to a named file

Implemented in 'shiya_model_trim.R'

This script will look in two directories (TRAINING_POS_DIRECTORY and TRAINING_NEG_DIRECTORY) for example images of a positive class (e.g. humans, cats, etc.) and a negative class (e.g. non-human, dogs, etc.). It currently expects those files to be JPEG files with the extension .jpg or .JPG.
It will extract features from those images (and it now trims them 30px top, 120px bottom if they're large enough) then build a classifier from the features (2048 inputs into 784 hidden units into prediction). It will train that classifier and save it to the MODEL_NAME directory

## Create features

Create files of features (2048-length vectors) for a directory of directories of images (corresponding to a survey containing multiple locations/cameras)

1) Generate inception_v3 features for camera trap images (trimming off any 'info bars') in each subdirectory and save those features as <foldername>_features_v3.csv

Implemented in 'generate_features_files.R'

this is a script to look through a directory of directories (e.g. a survey folder with lots of camera locations inside). For each directory, it will load all the images and try to generate inception_v3 features (2048 value vectors). Each image has 30px trimmed from the top and 120px trimmed from the bottom (as per Shiya's tests). The features are then stored as CSVs for each subdirectory (these can be quite large - 50Mb to 500Mb in my experience depending on the number of images).

## Predict image classes

Using a previously trained classifer and feature files, create a 'results' file (<foldername>_results_v3.csv) where each image is classified according to the give classifier.

Implemented in 'apply_model.R'

This script will look for feature files generate by the above script (I've made those files end in '_features_v3.csv' to identify them automatically), and run predictions on them from a given loaded model. For each feature file it will create a results file (ending '​_results_v3.csv'), which will contain 3 columns, the original filename, the probability it is in the positive class being predicted by the model, and a 'classification' (positive or negative) based on the threshold set in the script.

## View results

Implemented in 'html_results_viewer.R'

I was struggling to see the results from the above in a useful way, so this script will take the results files and try to create an HTML file for each which shows you the image with a border (red or green) corresponding to the classification (negative or positive respectively). This only works if the original image files are available locally (on your local drive or a usb drive for example),

## Extra files

'crop_generator.py' - Small python script to quickly trim off a given portion of an image file
'template.html' - HTML template used by 'html_results_viewer.R

## Example

There's also small folder of dog/cat images that the scripts use as an example (subsampled from the dog/cat image database), 

# Installation.. 

install.packages("tensorflow") # Should install tensorflow

## Then you need to run this to install tensorflow on the system

tensorflow::install_tensorflow(extra_packages=c('pillow', 'h5py')).  # Previously didn't include pillow or h5py which caused a few problems

## Load tensorflow
library(tensorflow)
tf$constant("Hello Tensorflow") # This will test if its working

## Then install keras package for precompiled networks
install.packages(keras)

Have a play and let me know if these work!

Rob
