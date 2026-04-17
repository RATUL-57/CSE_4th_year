% Variables: positions of each friend
var 1..6: R;
var 1..6: A;
var 1..6: F;
var 1..6: I;
var 1..6: T;
var 1..6: S;

% All positions are unique
constraint
    R != A /\ R != F /\ R != I /\ R != T /\ R != S /\
    A != F /\ A != I /\ A != T /\ A != S /\
    F != I /\ F != T /\ F != S /\
    I != T /\ I != S /\
    T != S;

% Constraint 1: F is between A and I
constraint (F > A /\ F < I) \/ (F < A /\ F > I);

% Constraint 2: S and R are next to each other
constraint abs(S - R) = 1;

% Constraint 3: T at front or back
constraint T = 1 \/ T = 6;

% Constraint 4: S has exactly one person behind
constraint S = 5;

% Solve
solve satisfy;

% -------------------------
% OUTPUT
% -------------------------

% R = 4;
% A = 3;
% F = 2;
% I = 1;
% T = 6;
% S = 5;



