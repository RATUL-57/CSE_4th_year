edge(a, b).
edge(b, c).
edge(c, d).
edge(d, e).
edge(c, e).


find_path(Start, Goal, [Start, Goal]) :-
    edge(Start, Goal), !.

find_path(Start, Goal, [Start | Path]) :-
    edge(Start, Next),
    find_path(Next, Goal, Path).


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%   QUERY   %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%


% find_path(a, e, Path)               ------> Path = [a, b, c, e]
% find_path(b, d, P)                  ------> P = [b, c, d]
% find_path(e, b, X)                  ------> false
% find_path(b, a, N)                  ------> false


