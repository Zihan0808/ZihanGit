# Catch failures in the sampling exercise and keep all trial outcomes.
doit <- function(x) {
    temp_x <- sample(x, replace = TRUE)
    if (length(unique(temp_x)) <= 30) {
        stop("Couldn't calculate mean: too few unique values!")
    }
    mean(temp_x)
}

set.seed(1345)
popn <- rnorm(50)
result <- lapply(seq_len(15), function(i) try(doit(popn), silent = TRUE))
failed <- vapply(result, inherits, logical(1), what = "try-error")
cat(sprintf("Completed %d trials: %d means, %d caught errors.\n",
            length(result), sum(!failed), sum(failed)))
