# MQB examples for if/else, for and while. Run from the project root.

a <- TRUE
if (a) {
    print("a is TRUE")
} else {
    print("a is FALSE")
}

z <- runif(1)
if (z <= 0.5) {
    print("Less than a half")
}

for (i in 1:10) {
    print(paste(i, "squared is", i^2))
}

for (species in c("Heliodoxa rubinoides", "Boissonneaua jardini", "Sula nebouxii")) {
    print(paste("The species is", species))
}

v1 <- c("a", "bc", "def")
for (value in v1) {
    print(value)
}

i <- 0
while (i < 10) {
    i <- i + 1
    print(i^2)
}
