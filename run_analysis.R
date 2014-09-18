# The purpose of this project is to demonstrate your ability to collect,
#work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. 
#You will be graded by your peers on a series of yes/no questions related to the project. 
#You will be required to submit: 

# 1) a tidy data set as described below, 
# 2) a link to a Github repository with your script for performing the analysis, and 
# 3) a code book that describes the variables, the data, and any transformations or work that you performed 
#  to clean up the data called CodeBook.md. You should also include  a  README.md in the repo with your scripts.
#   This repo explains how all of the scripts work and how they are connected.


## One of the most exciting areas in all of data science right now is wearable computing - see for example this article . 
## Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users.
## The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 
## A full description is available at the site where the data was obtained: 
  
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

#Here are the data for the project: 
  
  ##https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# You should create one R script called run_analysis.R that does the following. 
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names. 
# From the data set in step 4, creates a second, independent tidy data set with the average 
#        of each variable for each activity and each subject.


packages <- c("data.table", "reshape2","knitr","markdown")
sapply(packages, require, character.only=TRUE, quietly=TRUE)

# If the raw data has not been saved, download and unzip it.

  if (!file.exists('adl.zip')) {
     download.file(paste0('https://d396qusza40orc.cloudfront.net/','getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'), method='curl', destfile='adl.zip')
     unzip('adl.zip')
  }

# Getting the path of the working directory
path <- getwd()

# List all files on "UCI HAR Dataset" directory
pathDataset <- file.path(path, "UCI HAR Dataset")
list.files(pathDataset, recursive=TRUE)

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

#Filterig the data that we need
setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt[, list(count = .N, average = mean(value)), by=key(dt)]

# Writing to a txt Data File cal
f <- file.path(path, "HumanActivityRecognitionUsingSmartphones.txt")
write.table(dtTidy, f, quote = FALSE, sep = "\t", row.names = FALSE)



