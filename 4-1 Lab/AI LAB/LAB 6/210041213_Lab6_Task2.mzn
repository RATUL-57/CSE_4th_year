% ----------------------------------------
% Restaurant Ordering CSP
% Foods:
% 1 = Special Rice
% 2 = Biriyani Rice
% 3 = Kashmiri Naan
% 4 = Paratha
% ----------------------------------------

% Decision variables
var 1..4: Z;
var 1..4: I;
var 1..4: F;
var 1..4: N;

% ----------------------------------------
% Constraints
% ----------------------------------------

% Z does not like Paratha
constraint Z != 4;

% I and F want different dishes
constraint I != F;

% F likes rice items only
constraint (F = 1) \/ (F = 2);

% Z copies I, but their dish must be different from others
constraint Z = I;
constraint Z != F;
constraint Z != N;

% N does not want Kashmiri Naan
constraint N != 3;


solve satisfy;

% ----------------------------------------
% Output for one solution
% ----------------------------------------

% Z = 2;
% I = 2;
% F = 1;
% N = 1;

% ----------------------------------------
% Output for all solution
% ----------------------------------------

% Z = 2;
% I = 2;
% F = 1;
% N = 1;
% ----------
% Z = 2;
% I = 2;
% F = 1;
% N = 4;
% ----------
% Z = 3;
% I = 3;
% F = 1;
% N = 1;
% ----------
% Z = 3;
% I = 3;
% F = 1;
% N = 2;
% ----------
% Z = 3;
% I = 3;
% F = 1;
% N = 4;
% ----------
% Z = 1;
% I = 1;
% F = 2;
% N = 2;
% ----------
% Z = 1;
% I = 1;
% F = 2;
% N = 4;
% ----------
% Z = 3;
% I = 3;
% F = 2;
% N = 1;
% ----------
% Z = 3;
% I = 3;
% F = 2;
% N = 2;
% ----------
% Z = 3;
% I = 3;
% F = 2;
% N = 4;
% ----------

