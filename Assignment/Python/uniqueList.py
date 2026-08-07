num=[1,2,2,3,1,4]
unique=[]
for item in num:
    if item not in unique:
        unique.append(item)

print(unique)
