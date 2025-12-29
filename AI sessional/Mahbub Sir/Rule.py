# -------- Logical Operators --------
def AND(p, q): return p and q
def OR(p, q): return p or q
def NOT(p): return not p
def IMPLIES(p, q): return (not p) or q

#RULES OF INFERENCE
def modus_ponens(p,q):
    if p and IMPLIES(p,q):
        return q
    return None
def modus_tollens(p, q):
    """If p→q is True and q is False, then ¬p"""
    if (not q) and IMPLIES(p, q):
        return NOT(p)
    return None
def hypothetical_syllogism(p,q,r):
    if IMPLIES(p,q) and IMPLIES(q,r):
        return IMPLIES(p,r)
    return None
def disjunctive_syllogism(p,q):
    if not(p) and (p or q): 
        return q
    return None

def addition(p,q):
    return OR(p,q)
def simplification(p,q):
    return AND(p,q) and p
def resolution(p,q,r):
    return OR(q,r)
def truthtable(op,name):
    values=[True,False]
    for p in values:
        for q in values:
            print(f"{p} || {q}={op(p,q)}")
def truthtable2(op,name):
    values=[True,False]
    for p in values:
        for q in values:
            for r in values:
                print(f"{p} || {q} || {r} = {op(p,q,r)}")
    print()

p=True
q=True
r=True
print("-----Modus Ponens----")
truthtable(modus_ponens,"Modus_Ponens")
print()
print("---Modus tollense----")
truthtable(modus_tollens,"Modus tollens")
print()
print("---Hypothetical syllogism--")
truthtable2(hypothetical_syllogism,"Hypothetical")
print()
print("---Resolution---")
truthtable2(resolution,"Resolution")
print()
print("---Disjunctive---")
truthtable(disjunctive_syllogism,"Disjunctive")
print()
print("---Additive---")
truthtable(addition,"Add")
print()
print("---simplification---")
truthtable(simplification,"simplification")


