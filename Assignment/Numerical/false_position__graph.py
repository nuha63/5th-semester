# Importing modules for plotting and Array
from pylab import *

# Defining function using Lambda
f = lambda x: x ** 3 - 9 * x - 5

# Creating array of x using linspace
x = linspace(-4, 4, 50)

# Drawing function for better understanding of convergence
figure(1, figsize=(7.20,3.50))
plot(x, f(x))
ylim(-19, 10)
plot([-4, 4], [0, 0], 'k--')

# Selecting false position interval x1 and x2
x1 = -3
x2 = -1

# Evaluating the values at x1 and x2 viz. y1 and y2
y1 = f(x1)
y2 = f(x2)

# Initial check for gussed interval
if y1 * y2 > 0:
   print("on the same side of x axis, Correct the Range")
   exit
else:
   # Plotting line joining (x1,y1) and (x2,y2)
   plot([x1, x2], [y1, y2])

   # Iteration counter
   count = 1

   # Iterations
   while True:
      xn = x1 - y1 * (x2 - x1) / (y2 - y1)
      plot([xn], [0], 'o', label=f'{xn}')
      yn = f(xn)
      if abs(y1) < 1.E-5:
         print("Root= ", x1)
         break
      elif y1 * yn < 0:
         x2 = xn
         y2 = yn
         plot([x1, x2], [y1, y2])
      else:
         x1 = xn
         y1 = yn
         plot([x1, x2], [y1, y2])

      # printing few xn
      if count < 6:
         legend()
      # Incrementing counter
      count += 1
   show()