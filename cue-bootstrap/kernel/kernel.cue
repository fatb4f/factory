package kernel

// This is the minimum kernel vocabulary required by the bounded-int pilot.
// It is deliberately not a general CUE lattice model.
#Integer: int
#InclusiveLowerBound: >=0
#InclusiveUpperBound: <=10

#BoundedInt: #Integer & #InclusiveLowerBound & #InclusiveUpperBound
