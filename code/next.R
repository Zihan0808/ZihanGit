# Skip even values and print the odd numbers.
for (i in 1:10) {
    if (i %% 2 == 0) {
        next
    }
    print(i)
}
