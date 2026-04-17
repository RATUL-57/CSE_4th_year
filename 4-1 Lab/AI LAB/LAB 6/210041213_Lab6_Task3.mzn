var 1..3: A;
var 1..3: S;
var 1..3: M;
var 1..3: R;

constraint A != S;
constraint (A != M) \/ (A = 2 /\ M = 2);
constraint (A = M) \/ (A = 3 \/ M = 3);
constraint R != A;
constraint R != S;
constraint R != M;
constraint R > M;

solve satisfy;

% ----------------------------
% OUTPUT
% ----------------------------


% A = 3;
% S = 1;
% M = 1;
% R = 2;