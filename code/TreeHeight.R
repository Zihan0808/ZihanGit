# Calculate height from an elevation angle in degrees and horizontal distance.
TreeHeight <- function(degrees, distance) {
    radians <- degrees * pi / 180
    distance * tan(radians)
}

read_tree_measurements <- function(input_file) {
    if (!isTRUE(file_test("-f", input_file)) || file.access(input_file, 4) != 0) {
        stop("Input file is missing or unreadable: ", input_file)
    }
    trees <- tryCatch(
        read.csv(input_file, check.names = FALSE, row.names = NULL, fill = FALSE),
        error = function(e) stop("Cannot read CSV: ", conditionMessage(e))
    )
    required_columns <- c("Species", "Distance.m", "Angle.degrees")
    if (ncol(trees) != 3L || !all(required_columns %in% names(trees))) {
        stop("CSV must contain exactly these columns: Species, Distance.m, Angle.degrees.")
    }
    if (nrow(trees) == 0L) {
        stop("CSV must contain at least one tree record.")
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
    trees
}

write_tree_heights <- function(trees, input_file, output_file) {
    output_dir <- dirname(output_file)
    if (!dir.exists(output_dir) && !dir.create(output_dir, showWarnings = FALSE)) {
        stop("Cannot create results directory: ", output_dir)
    }
    if (isTRUE(nzchar(Sys.readlink(output_file), keepNA = TRUE)) ||
        normalizePath(input_file) == normalizePath(output_file, mustWork = FALSE)) {
        stop("Refusing to replace the input or an output symbolic link: ", output_file)
    }
    if (file.exists(output_file) && !isTRUE(file_test("-f", output_file))) {
        stop("Output path is not a regular file: ", output_file)
    }
    # Write beside the destination, so a write failure preserves the previous CSV.
    pending <- tempfile("tree-heights-", tmpdir = output_dir)
    on.exit(unlink(pending), add = TRUE)
    write.csv(trees, pending, row.names = FALSE)
    if (!file.rename(pending, output_file)) {
        stop("Cannot replace output CSV: ", output_file)
    }
}

# Running the file directly or using source() at the R prompt runs the practical.
# The general script sources these helpers into its own environment.
if (identical(environment(), globalenv())) {
    input_file <- "data/trees.csv"
    trees <- read_tree_measurements(input_file)
    trees$height_m <- TreeHeight(trees$Angle.degrees, trees$Distance.m)
    write_tree_heights(trees, input_file, "results/TreeHts.csv")
}
