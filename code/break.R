# End the loop before printing 10.
i <- 0
while (i < Inf) {
    if (i == 10) {
        break
    }
    cat("i equals", i, "\n")
    i <- i + 1
}
