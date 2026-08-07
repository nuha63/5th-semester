n=[1,2,3,4,5,6,7,8]
even=[]
odd=[]
for item in n:
    if item%2==0:
        even.append(item)
    else:
        odd.append(item)

print("even numbers: ",even)
print("odd nmbers: ",odd)