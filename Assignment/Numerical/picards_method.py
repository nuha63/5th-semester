import math
def Y1(x):
    return (1 + (x) + pow(x, 2) / 2)


def Y2(x):
    return (1 + (x) + pow(x, 2) / 2 + pow(x, 3) / 3 + pow(x, 4) / 8)


def Y3(x):
    return (1 + (x) + pow(x, 2) / 2 + pow(x, 3) / 3 + pow(x, 4) / 8 + pow(x, 5) / 15 + pow(x, 6) / 48)


start_value = 0
end_value = 3
allowed_error = 0.4
y1 = [0 for _ in range(30)]
y2 = [0 for _ in range(30)]
y3 = [0 for _ in range(30)]

temp = start_value
count = 0
while temp <= end_value:
    y1[count] = Y1(temp);
    y2[count] = Y2(temp);
    y3[count] = Y3(temp);

    temp = temp + allowed_error
    count += 1

print("\nX");
temp = start_value
while temp <= end_value:
    # considering all values
    # upto 4 decimal places.
    print(round(temp, 4), end=" ")
    temp = temp + allowed_error

print("\n\nY(1)");
temp = start_value
count = 0
while temp <= end_value:
    print(round(y1[count], 4), end=" ")

    temp = temp + allowed_error
    count += 1

print("\n\nY(2)");
temp = start_value
count = 0
while temp <= end_value:
    print(round(y2[count], 4), end=" ")

    temp = temp + allowed_error
    count += 1

print("\n\nY(3)");
temp = start_value
count = 0
while temp <= end_value:
    print(round(y3[count], 4), end=" ")

    temp = temp + allowed_error
    count += 1
