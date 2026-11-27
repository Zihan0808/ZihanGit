"""Inspect and handle the zero denominator in the MQB debugger exercise."""


def buggyfunc(x):
    """Return the last valid quotient, or None if there was no valid one."""
    if type(x) is not int or x < 1:
        raise ValueError("x must be a positive integer")
    y = x
    last_quotient = None
    for i in range(x):
        y -= 1
        try:
            last_quotient = x / y
        except ZeroDivisionError:
            print(f"Skipped division by zero at i={i}, x={x}, y={y}")
    return last_quotient


if __name__ == "__main__":
    print(f"Last valid quotient: {buggyfunc(20)}")
