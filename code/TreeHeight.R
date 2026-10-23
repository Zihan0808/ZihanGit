
TreeHeight <- function(Distance.m, Angle.degrees) {
    height_m <- Distance.m * tan(Angle.degrees * pi / 180)
    return(height_m)
}

trees <- read.csv("data/trees.csv", check.names = FALSE)
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
write.csv(trees, "results/TreeHts.csv", row.names = FALSE)
