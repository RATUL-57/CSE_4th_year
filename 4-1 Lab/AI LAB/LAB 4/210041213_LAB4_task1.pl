sumto(0, 0).

sumto(N, S) :-
    N > 0,
    N mod 2 =:= 1,
    N1 is N - 1,
    sumto(N1, S1),
    S is S1 + N.

sumto(N, S) :-
    N > 0,
    N mod 2 =:= 0,
    N1 is N - 2,
    sumto(N1, S).


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%   QUERY   %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  sumto(9, SUM)     ----> SUM = 25
%  sumto(5, N)       ----> N = 9