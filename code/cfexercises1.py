"""Return results from the six MQB functions and control flow examples."""


def foo_1(x):
    """Return the square root of nonnegative x."""
    return x ** 0.5


def foo_2(x, y):
    """Return the larger of two comparable values."""
    if x > y:
        return x
    return y


def foo_3(x, y, z):
    """Return three comparable values in ascending order."""
    if x > y:
        x, y = y, x
    if x > z:
        x, z = z, x
    if y > z:
        y, z = z, y
    return [x, y, z]


def _check_factorial_input(n):
    if type(n) is not int or n < 0:
        raise ValueError("Factorial requires a nonnegative integer")


def foo_4(n):
    """Return n factorial using a for loop."""
    _check_factorial_input(n)
    result = 1
    for i in range(1, n + 1):
        result *= i
    return result


def foo_5(n):
    """Return n factorial recursively for small nonnegative integers."""
    _check_factorial_input(n)
    if n <= 1:
        return 1
    return n * foo_5(n - 1)


def foo_6(n):
    """Return n factorial using a while loop."""
    _check_factorial_input(n)
    result = 1
    while n >= 1:
        result *= n
        n -= 1
    return result


if __name__ == "__main__":
    print("Square root of 9:", foo_1(9))
    print("Larger of 3 and 8:", foo_2(3, 8))
    print("Sort 7, 2 and 5:", foo_3(7, 2, 5))
    for n, expected in [(0, 1), (1, 1), (5, 120)]:
        results = (foo_4(n), foo_5(n), foo_6(n))
        assert results == (expected, expected, expected)
        print(f"{n}! by for loop, recursion and while loop: {results}")
