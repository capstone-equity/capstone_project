setwd("File path")
load("journal_folder_df1_webofscience.RData")
write.csv(data.frame, file = "journal_folder.csv", row.names = FALSE)
