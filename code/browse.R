# Source from an interactive R console to inspect exponential growth.
Exponential <- function(N0 = 1, r = 1, generations = 10) {
    N <- rep(NA_real_, generations)
    N[1] <- N0
    for (t in seq_len(generations)[-1L]) {
        N[t] <- N[t - 1L] * exp(r)
        if (interactive()) {
            browser()
        }
    }
    N
}

if (interactive()) {
    plot(Exponential(), type = "l", main = "Exponential growth")
}
