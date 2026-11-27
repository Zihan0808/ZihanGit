# Adapted from the MQB Pound Hill data wrangling example.
# Run from the repository root with Rscript code/data_wrang.R.
raw_data <- as.matrix(read.csv("data/pound_hill_data.csv", header = FALSE,
                               colClasses = "character"))
metadata <- read.csv("data/pound_hill_meta_data.csv", sep = ";", header = TRUE)
print(utils::head(metadata))

# The first four source rows describe the design. Transposing makes them
# identifier columns and gives each sampled quadrat one row.
quadrats <- t(raw_data)
wide_data <- as.data.frame(quadrats[-1L, , drop = FALSE], stringsAsFactors = FALSE)
names(wide_data) <- quadrats[1L, ]
id_columns <- c("Cultivation", "Block", "Plot", "Quadrat")
species_columns <- setdiff(names(wide_data), id_columns)

# In these data, blanks in sampled quadrats represent observed absences.
# Recode species counts only and keep the sample identifiers untouched.
for (species in species_columns) {
    values <- wide_data[[species]]
    values[!is.na(values) & values == ""] <- "0"
    wide_data[[species]] <- as.integer(values)
}

# One row per sampled quadrat and species, using the course's reshape2 route.
long_data <- reshape2::melt(wide_data, id.vars = id_columns,
                            measure.vars = species_columns,
                            variable.name = "Species", value.name = "Count")
long_data[id_columns] <- lapply(long_data[id_columns], factor)
print(utils::head(long_data))
print(dim(long_data))

dir.create("results", showWarnings = FALSE)
write.csv(long_data, "results/pound_hill_long.csv", row.names = FALSE)
