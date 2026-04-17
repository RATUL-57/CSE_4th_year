% Use this editor as a MiniZinc scratch book
% ----------------------------------------
% Sulawesi Map Coloring CSP
% Colors: 1 = Red, 2 = Yellow, 3 = Blue
% ----------------------------------------

% Decision variables (one per province)
var 1..3: NS;   % North Sulawesi
var 1..3: G;    % Gorontalo
var 1..3: CS;   % Central Sulawesi
var 1..3: WS;   % West Sulawesi
var 1..3: SS;   % South Sulawesi
var 1..3: SES;  % Southeast Sulawesi

% ----------------------------------------
% Neighbor constraints (no two neighbors
% can have the same color)
% ----------------------------------------

constraint NS != G;

constraint G != NS;
constraint G != CS;

constraint CS != G;
constraint CS != WS;
constraint CS != SS;
constraint CS != SES;

constraint WS != CS;
constraint WS != SS;

constraint SS != WS;
constraint SS != CS;
constraint SS != SES;

constraint SES != SS;
constraint SES != CS;

% ----------------------------------------
% Solve (CSP – just find solutions)
% ----------------------------------------

solve satisfy;

% ----------------------------------------
% Output for single solution
% ----------------------------------------

% NS = 1
% G  = 2
% CS = 1
% WS = 3
% SS = 2
% SES= 3


% ----------------------------------------
% Output for all solution
% ----------------------------------------

% NS = 1
% G  = 2
% CS = 1
% WS = 3
% SS = 2
% SES= 3
% ----------
% NS = 3
% G  = 2
% CS = 1
% WS = 3
% SS = 2
% SES= 3
% ----------
% NS = 1
% G  = 3
% CS = 1
% WS = 3
% SS = 2
% SES= 3
% ----------
% NS = 2
% G  = 3
% CS = 1
% WS = 3
% SS = 2
% SES= 3
% ----------
% NS = 1
% G  = 2
% CS = 1
% WS = 2
% SS = 3
% SES= 2
% ----------
% NS = 3
% G  = 2
% CS = 1
% WS = 2
% SS = 3
% SES= 2
% ----------
% NS = 1
% G  = 3
% CS = 1
% WS = 2
% SS = 3
% SES= 2
% ----------
% NS = 2
% G  = 3
% CS = 1
% WS = 2
% SS = 3
% SES= 2
% ----------
% NS = 2
% G  = 1
% CS = 2
% WS = 3
% SS = 1
% SES= 3
% ----------
% NS = 3
% G  = 1
% CS = 2
% WS = 3
% SS = 1
% SES= 3
% ----------
% NS = 1
% G  = 3
% CS = 2
% WS = 3
% SS = 1
% SES= 3
% ----------
% NS = 2
% G  = 3
% CS = 2
% WS = 3
% SS = 1
% SES= 3
% ----------
% NS = 2
% G  = 1
% CS = 2
% WS = 1
% SS = 3
% SES= 1
% ----------
% NS = 3
% G  = 1
% CS = 2
% WS = 1
% SS = 3
% SES= 1
% ----------
% NS = 1
% G  = 3
% CS = 2
% WS = 1
% SS = 3
% SES= 1
% ----------
% NS = 2
% G  = 3
% CS = 2
% WS = 1
% SS = 3
% SES= 1
% ----------
% NS = 2
% G  = 1
% CS = 3
% WS = 2
% SS = 1
% SES= 2
% ----------
% NS = 3
% G  = 1
% CS = 3
% WS = 2
% SS = 1
% SES= 2
% ----------
% NS = 1
% G  = 2
% CS = 3
% WS = 2
% SS = 1
% SES= 2
% ----------
% NS = 3
% G  = 2
% CS = 3
% WS = 2
% SS = 1
% SES= 2
% ----------
% NS = 2
% G  = 1
% CS = 3
% WS = 1
% SS = 2
% SES= 1
% ----------
% NS = 3
% G  = 1
% CS = 3
% WS = 1
% SS = 2
% SES= 1
% ----------
% NS = 1
% G  = 2
% CS = 3
% WS = 1
% SS = 2
% SES= 1
% ----------
% NS = 3
% G  = 2
% CS = 3
% WS = 1
% SS = 2
% SES= 1
% ----------
