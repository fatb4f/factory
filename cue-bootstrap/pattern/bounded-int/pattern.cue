package boundedint

// #BoundedInt is the pilot semantic pattern. It intentionally exercises only
// integer kind intersection and inclusive lower/upper bounds.
#BoundedInt: int & >=0 & <=10

#NonNegativeInt: int & >=0
#AtMostTenInt:  int & <=10

// The pattern is explicitly decomposable by unification.
#RecomposedBoundedInt: #NonNegativeInt & #AtMostTenInt
