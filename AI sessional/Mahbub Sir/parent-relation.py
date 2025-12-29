class People:
    def __init__(self,name,parent=None,children=None):
        self.name=name
        self.parent=parent
        self.children=[children]

class Relation:
    def __init__(self):
        self.map={}

    def add(self,person):
        self.map[person.name]=person
    def parent(self,parent,child):
        self.map[child].parent=parent
        if self.map[parent].children==[]:
            self.map[parent].children=[child]
        else:
            self.map[parent].children.append(child)

    def find_grandparent(self,name):
        parent=self.map[name].parent
        if parent==None:
            return None
        grandparent=self.map[parent].parent
        return grandparent

relation=Relation()
john=People("John")
mary=People("mary")
joe=People("Joe")

relation.add(john)
relation.add(mary)
relation.add(joe)

relation.parent("John","mary")
relation.parent("mary","Joe")
print("joe's is grand parent is ",relation.find_grandparent("Joe"))
