"""Demonstrate six combinations of loops and conditions from MQB."""

########################
def hello_1(x):
    for j in range(x):
        if j % 3 == 0:
            print('hello')
    print(' ')

hello_1(12)

########################
def hello_2(x):
    for j in range(x):
        if j % 5 == 3:
            print('hello')
        elif j % 4 == 3:
            print('hello')
    print(' ')

hello_2(12)

########################
def hello_3(x, y):
    for i in range(x, y):
        print('hello')
    print(' ')

hello_3(3, 17)

########################
def hello_4(x):
    # Adding three reaches 15 only from this set of integer starting values.
    if not isinstance(x, int) or x > 15 or x % 3 != 0:
        raise ValueError("x must be an integer multiple of 3 at most 15")
    while x != 15:
        print('hello')
        x = x + 3
    print(' ')

hello_4(0)

########################
def hello_5(x):
    while x < 100:
        if x == 31:
            for k in range(7):
                print('hello')
        elif x == 18:
            print('hello')
        x = x + 1
    print(' ')

hello_5(12)

# WHILE loop with BREAK
def hello_6(x, y):
    while x and y < 6:
        print("hello! " + str(y))
        y += 1 # increment y by 1
        if y == 6:
            break
    print(' ')

hello_6(True, 0)
