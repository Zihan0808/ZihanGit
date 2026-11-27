# MQB file I/O exercise. Run from the repository root.
MyData <- read.csv("data/trees.csv", header = TRUE)
dir.create("results", showWarnings = FALSE)
output <- "results/MyData.csv"

# Write the complete table, then append one record without a second header.
write.csv(MyData, output, row.names = FALSE)
write.table(MyData[1, , drop = FALSE], output, append = TRUE,
            sep = ",", row.names = FALSE, col.names = FALSE)

# Overwrite the appended table and demonstrate adding row names.
write.csv(MyData, output, row.names = TRUE)

# Overwrite again, keeping the comma separator and omitting the column names.
write.table(MyData, output, sep = ",", row.names = TRUE, col.names = FALSE)
