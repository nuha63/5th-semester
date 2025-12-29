def AND(p,q): return p and q
def IMPLIES(p,q):return (not p) or q
def OR(p,q):return p or q
def bidirection(p,q):return p==q

def truthtable(op,name):
    values=[True,False]
    print(f"truthtable for {name}")
    for p in values:
        for q in values:
            print(f"{p} {"||"} {q} = {op(p,q)}")
    print()
p=True
q=True
    #bidirection
print("a) It is raining outside if and only if it is a cloudy day")
truthtable(bidirection,"R<->C") 
print("b)If you get 100 on the exam then you earn an A (E → A) ")  
truthtable(IMPLIES,"E->A")
print("Take either Advil or Tylenol (A or T)")
truthtable(OR,"A or T")
print("She studied hard or she is bright (S ∨ B)")
truthtable(OR,"S or B")
print("I am a rock and I am an island (R ∧ I)")
truthtable(AND,"R ^ I")
