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

1.1 Packages required


```r
packages <- c("data.table", "reshape2","knitr","markdown")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
```

```
## data.table   reshape2      knitr   markdown 
##       TRUE       TRUE       TRUE       TRUE
```


1.2 Download the Dataset

```r
if (!file.exists('adl.zip')) {
     download.file(paste0('https://d396qusza40orc.cloudfront.net/','getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'), method='curl', destfile='adl.zip')
     unzip('adl.zip')
  }

# Getting the path of the working directory
path <- getwd()

# List all files on "UCI HAR Dataset" directory
pathDataset <- file.path(path, "UCI HAR Dataset")
list.files(pathDataset, recursive=TRUE)
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


2.  Trasform data

2.1  Helper functions created

```r
#Method used to load files 
loadFile <- function(path,folder,fileName){
  dt <- fread(file.path(path,folder,fileName))
}

# Load Data Tables
loadFileToDataTable <- function (path,folder,fileName) {
  dt <- data.table(read.table(file.path(path, folder, fileName)))
}

# Find features by regurar expressions
grepFeature <- function (regex) {
  grepl(regex, dt$feature)
}
```
2.2 Steps to transform the Dataset

2.2.1 Loading Files

```r
#Loading the Datasets
dtSubjectTrain <- loadFile(pathDataset,"train","subject_train.txt")
dtSubjectTest  <- loadFile(pathDataset,"test","subject_test.txt")

dtActivityTrain <- loadFile(pathDataset,"train","Y_train.txt") 
dtActivityTest  <- loadFile(pathDataset,"test","Y_test.txt") 

dtTrain <- loadFileToDataTable(pathDataset, "train", "X_train.txt")
dtTest  <- loadFileToDataTable(pathDataset, "test" , "X_test.txt" )


##Binding the test and train sets and changing  the name from V1 to subject
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")


#Binding the Activity test and train sets and changing the name from V1 to activityNum
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")

#Binding the train and test DataSet Loaded
dt <- rbind(dtTrain, dtTest)

#Binding the subjetc and activity with the data set
dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt)

setkey(dt, subject, activityNum)

#Loading and setting the head of features table
dtFeatures <- fread(file.path(pathDataset, "features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))

# Getting the features with mean and standard deviation
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]

# Adding a colum the the feature code
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]

#Getting the data from feature codes filtered 
select <- c(key(dt), dtFeatures$featureCode)
dt <- dt[, select, with=FALSE]


# Loading and mergin the Activities
dtActivityNames <- fread(file.path(pathDataset, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))
dt <- merge(dt, dtActivityNames, by="activityNum", all.x=TRUE)
setkey(dt, subject, activityNum, activityName)

# Melting data
dt <- data.table(melt(dt, key(dt), variable.name="featureCode"))

# Mergin by feature code 
dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by="featureCode", all.x=TRUE)

# Adding factors
dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)


## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(grepFeature("^t"), grepFeature("^f")), ncol=nrow(y))
dt$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))

x <- matrix(c(grepFeature("Acc"), grepFeature("Gyro")), ncol=nrow(y))
dt$featInstrument <- factor(x %*% y, labels=c("Accelerometer", "Gyroscope"))

x <- matrix(c(grepFeature("BodyAcc"), grepFeature("GravityAcc")), ncol=nrow(y))
dt$featAcceleration <- factor(x %*% y, labels=c(NA, "Body", "Gravity"))

x <- matrix(c(grepFeature("mean()"), grepFeature("std()")), ncol=nrow(y))
dt$featVariable <- factor(x %*% y, labels=c("Mean", "SD"))


## Features with 1 category
dt$featJerk <- factor(grepFeature("Jerk"), labels=c(NA, "Jerk"))
dt$featMagnitude <- factor(grepFeature("Mag"), labels=c(NA, "Magnitude"))

## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(grepFeature("-X"), grepFeature("-Y"), grepFeature("-Z")), ncol=nrow(y))
dt$featAxis <- factor(x %*% y, labels=c(NA, "X", "Y", "Z"))
```


3. Load data to the target "HumanActivityRecognitionUsingSmartphones.txt" dataset

```r
#Filterig the data that we need
setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt[, list(count = .N, average = mean(value)), by=key(dt)]


# Writing to a txt Data File cal
f <- file.path(path, "HumanActivityRecognitionUsingSmartphones.txt")
write.table(dtTidy, f, quote = FALSE, sep = "\t", row.names = FALSE)
```

