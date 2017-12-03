## Load packages
library(dplyr)

## Main path creation
main_path <- "~/Personal/Coursera/Getting and Cleaning Data/UCI HAR Dataset/"

## Read in tests
subject_test <- tbl_df(read.table(paste(main_path, "test/", "subject_test.txt", sep = "")))
x_test <- tbl_df(read.table(paste(main_path, "test/", "X_test.txt", sep = "")))
y_test <- tbl_df(read.table(paste(main_path, "test/", "y_test.txt", sep = "")))

##Read in training sets
subject_train <- tbl_df(read.table(paste(main_path, "train/", "subject_train.txt", sep = "")))
x_train <- tbl_df(read.table(paste(main_path, "train/", "X_train.txt", sep = "")))
y_train <- tbl_df(read.table(paste(main_path, "train/", "y_train.txt", sep = "")))

##Combine sets
subjects_all <- bind_rows(subject_test, subject_train)
x_all <- bind_rows(x_test, x_train)
y_all <- bind_rows(y_test, y_train)

## Remove old ones
rm(subject_test, x_test, y_test, subject_train, y_train, x_train)

## Read in info
activity_labels <- tbl_df(read.table(paste(main_path, "activity_labels.txt", sep = ""), stringsAsFactors = FALSE))
features <- tbl_df(read.table(paste(main_path, "features.txt", sep = ""), stringsAsFactors = FALSE))

## Fix features names
features_vec <- features$V2
features_vec_1 <- paste(1:561, features_vec, sep = "")
features_vec_2 <- gsub("\\(+\\)","",as.character(features_vec_1))
features_vec_3 <- gsub("\\-", "", as.character(features_vec_2))

## Combine all and rename
all_data <- bind_cols(subjects_all, y_all, x_all)
colnames(all_data) <- c("subject_id", "activity_id", features_vec_3)

## Collect mean and standard deviation
mean_std <- select(all_data, subject_id, activity_id, contains("mean"), contains("std"))

## Put in activities
colnames(activity_labels) <- c("id", "activity")
mean_std_2 <- tbl_df(merge(activity_labels, mean_std, by.x = "id", by.y = "activity_id", all = TRUE))
mean_std <- select(mean_std_2, -id) %>% arrange(subject_id)

## Grouping
by_act_id <- group_by(mean_std, activity, subject_id) %>% summarise_all(mean)
