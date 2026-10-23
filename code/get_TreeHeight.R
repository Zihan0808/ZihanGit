args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
    stop("Expected exactly one CSV file path. Usage: Rscript code/get_TreeHeight.R data/trees.csv")
}
input_file <- args[1]
if (!file.exists(input_file) || dir.exists(input_file) ||
    file.access(input_file, 4) != 0) {
    stop("Input file is missing or unreadable: ", input_file)
}

TreeHeight <- function(Distance.m, Angle.degrees) {
    height_m <- Distance.m * tan(Angle.degrees * pi / 180)
    return(height_m)
}

trees <- tryCatch(
    read.csv(input_file, check.names = FALSE),
    error = function(e) stop("Cannot read CSV: ", conditionMessage(e))
)
required_columns <- c("Species", "Distance.m", "Angle.degrees")
if (ncol(trees) != 3 || !all(required_columns %in% names(trees))) {
    stop("CSV must contain exactly these columns: Species, Distance.m, Angle.degrees.")
}

if (!is.numeric(trees$Distance.m) || !is.numeric(trees$Angle.degrees) ||
    any(!is.finite(trees$Distance.m)) || any(!is.finite(trees$Angle.degrees))) {
    stop("Distance.m and Angle.degrees must contain finite numeric values with no missing values.")
}
if (any(trees$Distance.m <= 0 | trees$Distance.m > 100)) {
    stop("Distance.m must satisfy 0 < Distance.m <= 100.")
}
if (any(trees$Angle.degrees <= 0 | trees$Angle.degrees >= 90)) {
    stop("Angle.degrees must satisfy 0 < Angle.degrees < 90.")
}


trees$height_m <- TreeHeight(trees$Distance.m, trees$Angle.degrees)
dir.create("results", showWarnings = FALSE)
output_file <- file.path("results", paste0(tools::file_path_sans_ext(basename(input_file)),
                                         "_treeheights.csv"))
# Protect the input if an output path points back to it.
if (normalizePath(input_file) == normalizePath(output_file, mustWork = FALSE)) {
    stop("Output would overwrite the input file: ", input_file)
}
write.csv(trees, output_file, row.names = FALSE)
