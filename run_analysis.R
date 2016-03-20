## Get UCI HAR Analysis Data into working directory

if(!file.exists("./Data")){dir.create("./Data")}
zipURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- download.file(zipURL, destfile = "./Data/UCIData.zip")
unzip("./Data/UCIData.zip")

## Read in all the data as separate tables to stage for combining and merging

testXData <- read.table("./UCI HAR Dataset/test/X_test.txt", stringsAsFactors = FALSE)
testyData <- read.table("./UCI HAR Dataset/test/y_test.txt")
testSubjectData <- read.table("./UCI HAR Dataset/test/subject_test.txt")
trainXData <- read.table("./UCI HAR Dataset/train/X_train.txt", stringsAsFactors = FALSE)
trainyData <- read.table("./UCI HAR Dataset/train/y_train.txt")
trainSubjectData <- read.table("./UCI HAR Dataset/train/subject_train.txt")
featureData <- read.table("./UCI HAR Dataset/features.txt")

## Combine table data and assign column names
dataStats <- rbind(testXData,trainXData)
colnames(dataStats) <- featureData$V2
subjectId <- rbind(testSubjectData,trainSubjectData)
colnames(subjectId) <- c("Subject")
activityId <- rbind(testyData,trainyData)
colnames(activityId) <- c("Activity")

## 1st Requirement - Put it all together in one data frame
combinedHarData <- cbind(subjectId, activityId, dataStats)

## 2nd Requirement - Extract only columns with mean or standard deviation values
## identify variable with "std" or "mean" and store in character vector
meanSDHarCols <- grep("std|mean", names(combinedHarData), value = TRUE)

## Subset full data set to include Subject, Activity, and extracted variable names
refinedHarData <- combinedHarData[,c("Subject", "Activity", meanSDHarCols)]

## 3rd Requirement - Use activity labels
## Add activity labels to working data set and replace values in Activity column
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
refinedHarData$Activity <- factor(refinedHarData$Activity, levels = 1:6, labels = activityLabels$V2)

## 4th Requirement - Appropriately labels the data set with descriptive variable names.
## These follow lecture guidelines of all lower case variable names though it makes it
## more difficult to read with more descriptive names.
names(refinedHarData) <- tolower(names(refinedHarData))
names(refinedHarData) <- sub("^t", "time", names(refinedHarData))
names(refinedHarData) <- sub("^f", "freq", names(refinedHarData))
names(refinedHarData) <- sub("acc", "acceleration", names(refinedHarData))
names(refinedHarData) <- sub("gyro", "gyroscopic", names(refinedHarData))
names(refinedHarData) <- sub("mag", "magnitude", names(refinedHarData))

## 5th Requirement - Create a tidy data set with the average of each variable for each activity 
## and each subject.
tidyHarData <- aggregate(. ~subject + activity, refinedHarData, mean)

##write tidy data set to output file
write.csv(tidyHarData, file = "Summary_HAR_Statistics.csv", row.names = FALSE)

##End of R Script







