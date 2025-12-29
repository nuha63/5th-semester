from itertools import product

def truth_table(express):
    print(" P | Q | R \n __________")
    for P,Q in product([0,1], repeat=2):
        R=express(P,Q)
        print(f" {P} | {Q} | {R}")
express=lambda P,Q: (not P) or Q
truth_table(express)
