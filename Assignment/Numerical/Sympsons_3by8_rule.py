def f(x):
    return 1 / (1 + x ** 2)


def simpson38(x0, xn, n):
    h = (xn - x0) / n

    integration = f(x0) + f(xn)

    for i in range(1, n):
        k = x0 + i * h

        if i % 3 == 0:
            integration = integration + 2 * f(k)
        else:
            integration = integration + 3 * f(k)

    integration = integration * 3 * h / 8

    return integration


lower_limit = float(input("Enter lower limit of integration: "))
upper_limit = float(input("Enter upper limit of integration: "))
sub_interval = int(input("Enter number of sub intervals: "))

result = simpson38(lower_limit, upper_limit, sub_interval)
print("Integration result by Simpson's 3/8 method is: %0.6f" % (result))