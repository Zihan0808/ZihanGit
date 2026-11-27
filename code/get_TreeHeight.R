# Run from the project root with one readable CSV of tree measurements.
main <- function(args = commandArgs(trailingOnly = TRUE)) {
    if (length(args) != 1L) {
        stop("Expected exactly one CSV file path. Usage: Rscript code/get_TreeHeight.R data/trees.csv")
    }
    input_file <- args[[1L]]

    tree_height <- new.env()
    sys.source("code/TreeHeight.R", envir = tree_height)
    trees <- tree_height$read_tree_measurements(input_file)
    trees$height_m <- tree_height$TreeHeight(trees$Angle.degrees, trees$Distance.m)

    stem <- sub("[.]csv$", "", basename(input_file), ignore.case = TRUE)
    output_file <- file.path("results", paste0(stem, "_treeheights.csv"))
    tree_height$write_tree_heights(trees, input_file, output_file)
}

main()
