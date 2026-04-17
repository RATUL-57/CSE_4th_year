flatten_list([], []).

flatten_list([H|T], Flat) :-
    is_list(H),
    flatten_list(H, FH),
    flatten_list(T, FT),
    append(FH, FT, Flat).

flatten_list([H|T], [H|FT]) :-
    \+ is_list(H),
    flatten_list(T, FT).



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%   QUERY   %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  flatten_list([[a,b,d],[c],[e,c]], P)    ----> P = [a, b, d, c, e, c]
%  flatten_list([], LIST)                  ----> LIST = []
%  flatten_list([[a,b],[c],[b,d,e]], X)    ----> X = [a, b, c, b, d, e]