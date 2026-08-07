def f(x):
    return x ** 2 - 3

def bisection(x0, x1, e):
    iteration = 1
    print('\n Solving Equation through Bisection \n')
    condition = True
    while condition:
        x2 = (x0 + x1) / 2
        print('Iteration-%d, x2 = %0.6f and f(x2) = %0.6f' % (iteration, x2, f(x2)))

        if f(x0) * f(x2) < 0:
            x1 = x2
        else:
            x0 = x2

        iteration = iteration + 1
        condition = abs(f(x2)) > e

    print('\n Required Root is : %0.8f' %x2)



x0 = input('First Guess: ')
x1 = input('Second Guess: ')
e = input('Tolerable Error: ')


x0 = float(x0)
x1 = float(x1)
e = float(e)


if f(x0) * f(x1) > 0.0:
    print('Given guess values do not bracket the root.')
    print('Try Again with different guess values.')


else:
    bisection(x0, x1, e)
