def modus_ponens(p,q):
    implication=(not p) or q
    if implication and p:
        return True
    else:
        return False
    
def modus_tollense(p,q):
    implication=(not p) or q
    if implication and (not q):
        return True
    else:
        return False 
def disjunctive_sylloligm(p,q):
    implication=(not p)or q
    disjunctive=(p or q)and (not p)
    if  implication and disjunctive:
        return True
    else:
        return False
p_input=input("enter input in true/false: ").strip().lower()
q_input=input("samne as p:true/false ").strip().lower()

p=(p_input=="true")
q=(q_input=="true")

print("\n Result: ")
print("premises if p then q and p is ",p,"q is ",q)
print("conclusion for MP:",modus_ponens(p,q))
print("conclusion for MT",modus_tollense(p,q))
print("conclusion for disjunctive: ",disjunctive_sylloligm(p,q))

