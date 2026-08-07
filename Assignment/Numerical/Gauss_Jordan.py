import numpy

def gaussJordan():
    n=int(input("Enter the number of variables: "))
    A= numpy.zeros((n,n+1))
    X=numpy.zeros(n)

    print("enter the coefficients of augumented matrix: ")
    for i in range(n):
        for j in range(n+1):
            A[i][j]=float(input('A['+str(i)+']['+str(j)+']='))
    print(A)
    for i in range(n):
        if A[i][j]==0.0:
            print('devide by 0 detected!!')
            break
        for j in range(n):
            if i!=j:
                r= A[j][i]/A[i][i]
                for k in range (n+1):
                    A[j][k]=A[j][k]-r*A[i][k]
    print("The diagonal matrix is: ")
    print(A)
    print("The values of variables are: ")
    for i in range(n):
        X[i]=A[i][n]/A[i][i]
    for i in range(n):
        print('x%d=%0.2f' %(i, X[i]), end='\n')


gaussJordan()