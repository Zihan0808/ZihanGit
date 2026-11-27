# MQB R conditionals. Each function accepts a single whole number in
# [-.Machine$integer.max, .Machine$integer.max].
check_integer <- function(n) {
    if (length(n) != 1L || !is.numeric(n) || is.complex(n) ||
        !is.finite(n) || n != trunc(n) || abs(n) > .Machine$integer.max) {
        stop("Expected a single whole number in the signed 32-bit R integer range.",
             call. = FALSE)
    }
}

is.even <- function(n) {
    check_integer(n)
    if (n %% 2 == 0) {
        paste(n, "is even!")
    } else {
        paste(n, "is odd!")
    }
}

is.power2 <- function(n) {
    check_integer(n)
    candidate <- n
    # Repeated exact division avoids testing equality on logarithms.
    while (candidate > 1 && candidate %% 2 == 0) {
        candidate <- candidate / 2
    }
    if (candidate == 1) {
        paste(n, "is a power of 2!")
    } else {
        paste(n, "is not a power of 2!")
    }
}

is.prime <- function(n) {
    check_integer(n)
    if (n < 0) {
        return(paste(n, "is not prime!"))
    }
    if (n == 0) {
        return(paste(n, "is a zero!"))
    }
    if (n == 1) {
        return(paste(n, "is just a unit!"))
    }
    # Handle the smallest primes before forming a sequence of divisors.
    if (n <= 3 || all(n %% seq.int(2, floor(sqrt(n))) != 0)) {
        paste(n, "is a prime!")
    } else {
        paste(n, "is a composite!")
    }
}

print(is.even(6))
print(is.power2(4))
print(is.prime(3))
