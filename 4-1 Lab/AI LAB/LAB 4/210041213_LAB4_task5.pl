edge(a, b).
edge(b, c).
edge(c, d).
edge(d, b).
edge(c, e).


path(Start, End, Path) :-
    path(Start, End, [Start], Path), !.
	
path(End, End, _, [End]).

path(Current, End, Visited, [Current|Path]) :-
    edge(Current, Next),
    \+ member(Next, Visited),       
    path(Next, End, [Next|Visited], Path).




%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%   QUERY   %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% path(a,e,P)            -----> P = [a, b, c, e]
% path(d,e,Path)         -----> Path = [d, b, c, e]
% path(c,b,X)           -----> X = [c, d, b]
% path(e,b,N)           -----> false


