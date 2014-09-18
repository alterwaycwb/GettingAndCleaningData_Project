Codebook
========================================================

This Codebook explains the variables created to trasform the raw dataset to a tidy 
dataset and the steps to create that as well.


 1. Table of Variables
------------------------------------
 Variable name      | Description 
 ---------------    | ------------
**subject**	        | ID the subject who performed the activity for each window sample. Its range is from 1 to 30.
**activity**        |	Activity name
**featDomain**      |	Feature: Time domain signal or frequency domain signal (Time or Freq)
**featInstrument**  |	Feature: Measuring instrument (Accelerometer or Gyroscope)
**featAcceleration**|	Feature: Acceleration signal (Body or Gravity)
**featVariable**    |	Feature: Variable (Mean or SD)
**featJerk**        |	Feature: Jerk signal
**featMagnitude**   |	Feature: Magnitude of the signals calculated using the Euclidean norm
**featAxis**        |	Feature: 3-axial signals in the X, Y and Z directions (X, Y, or Z)
**featCount**	      | Feature: Count of data points used to compute average
**featAverage**     |	Feature: Average of each variable for each activity and each subject


2. Steps to create the tidy dataset
-----------------------

1. Extrat data from the web.

```r
 if (!file.exists('adl.zip')) {
     download.file(paste0('https://d396qusza40orc.cloudfront.net/','getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'), method='curl', destfile='adl.zip')
     unzip('adl.zip')
  }

# Getting the path of the working directory
path <- getwd()

# List all files on "UCI HAR Dataset" directory
pathIn <- file.path(path, "UCI HAR Dataset")
list.files(pathIn, recursive=TRUE)
```

```
##  [1] "activity_labels.txt"                         
##  [2] "features.txt"                                
##  [3] "features_info.txt"                           
##  [4] "README.txt"                                  
##  [5] "test/Inertial Signals/body_acc_x_test.txt"   
##  [6] "test/Inertial Signals/body_acc_y_test.txt"   
##  [7] "test/Inertial Signals/body_acc_z_test.txt"   
##  [8] "test/Inertial Signals/body_gyro_x_test.txt"  
##  [9] "test/Inertial Signals/body_gyro_y_test.txt"  
## [10] "test/Inertial Signals/body_gyro_z_test.txt"  
## [11] "test/Inertial Signals/total_acc_x_test.txt"  
## [12] "test/Inertial Signals/total_acc_y_test.txt"  
## [13] "test/Inertial Signals/total_acc_z_test.txt"  
## [14] "test/subject_test.txt"                       
## [15] "test/X_test.txt"                             
## [16] "test/y_test.txt"                             
## [17] "train/Inertial Signals/body_acc_x_train.txt" 
## [18] "train/Inertial Signals/body_acc_y_train.txt" 
## [19] "train/Inertial Signals/body_acc_z_train.txt" 
## [20] "train/Inertial Signals/body_gyro_x_train.txt"
## [21] "train/Inertial Signals/body_gyro_y_train.txt"
## [22] "train/Inertial Signals/body_gyro_z_train.txt"
## [23] "train/Inertial Signals/total_acc_x_train.txt"
## [24] "train/Inertial Signals/total_acc_y_train.txt"
## [25] "train/Inertial Signals/total_acc_z_train.txt"
## [26] "train/subject_train.txt"                     
## [27] "train/X_train.txt"                           
## [28] "train/y_train.txt"
```

2. Trasform data


3. Load data to the target "HumanActivityRecognitionUsingSmartphones.txt" dataset


