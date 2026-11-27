# Tidyverse version of the MQB Pound Hill exercise. Run from the project root.
raw_data <- as.matrix(read.csv("data/pound_hill_data.csv", header = FALSE,
                               colClasses = "character"))
metadata <- read.csv("data/pound_hill_meta_data.csv", sep = ";", header = TRUE)
print(utils::head(metadata))

# Transpose the sampling design into identifier columns, one row per quadrat.
quadrats <- t(raw_data)
wide_data <- as.data.frame(quadrats[-1L, , drop = FALSE], stringsAsFactors = FALSE)
names(wide_data) <- quadrats[1L, ]
id_columns <- c("Cultivation", "Block", "Plot", "Quadrat")
species_columns <- setdiff(names(wide_data), id_columns)

# In this survey, blank species counts are observed absences. Preserve IDs.
wide_data <- dplyr::mutate(
    wide_data,
    dplyr::across(dplyr::all_of(species_columns), function(values) {
        as.integer(replace(values, !is.na(values) & values == "", "0"))
    }),
    dplyr::across(dplyr::all_of(id_columns), factor)
)

# Keep melt()'s species-major order and factor levels for a direct comparison.
long_data <- tidyr::pivot_longer(
    wide_data, cols = dplyr::all_of(species_columns), cols_vary = "slowest",
    names_to = "Species", values_to = "Count"
)
long_data <- as.data.frame(dplyr::mutate(
    long_data, Species = factor(Species, levels = species_columns)
))
print(utils::head(long_data))
print(dim(long_data))

dir.create("results", showWarnings = FALSE)
write.csv(long_data, "results/pound_hill_long_tidy.csv", row.names = FALSE)
