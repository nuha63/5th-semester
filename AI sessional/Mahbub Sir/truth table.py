def AND(p,q):return p and q
def IMPLIES(p,q): return (not p) or q
def OR(p,q):return p or q
#print truthtable
def truthtable(op,name):
    values=[True ,False]
    print(f"truthtable for {name}:")
    for p in values:
        for q in values:
            print(f"{p} {name} {q} = {op(p,q)}")
    print()
p=True
q=True
truthtable(AND,"AND")
truthtable(IMPLIES,"implication")
truthtable(OR,"OR")