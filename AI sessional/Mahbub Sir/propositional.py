#PROPOSITIONAL LOGIC
def NOT(p):return not p
def AND(p,q):return p and q
def OR(p,q):return p or q
def IMPLIES(p,q):return (not p) or q
def BIDIRECTIONAL(p,q):return p == q

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


#print truthtable
def truthtable(op,name):
    values=[True ,False]
    print(f"truthtable for {name}:")
    for p in values:
        for q in values:
            print(f"{p} {name} {q} = {op(p,q)}")
def truthtable2(op,name):
    values=[True,False]
    print(f"/n{name }")
    for p in values:
        for q in values:
            for r in values:
                print(f"{p} {name} {q}={op(p,q,r)}")
    print()


p=True
q=True
r=True

truthtable(AND,"AND")
truthtable(IMPLIES,"implication")
truthtable (modus_ponens,"modus Ponens")
print("Not P:   ",NOT(p))
print("p ^ q:   ",AND(p,q))
print("p v q:   ",OR(p,q))
print("p->q:    ",IMPLIES(p,q))
print("P <=> q: ",BIDIRECTIONAL(p,q))
print("modus_ponens:",modus_ponens(p,q))
print("modus_tollens:",modus_tollens(p,q))
print("hypothetical_syllogism:",hypothetical_syllogism(p,q,r))
print("disjunctive_syllogism:",disjunctive_syllogism(p,q))