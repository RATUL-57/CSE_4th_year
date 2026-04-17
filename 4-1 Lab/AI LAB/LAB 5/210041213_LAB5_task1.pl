% ----- Available coins -----
coins([1,2,5,10,50]).

% ----- GCD (Euclid) -----
gcd(A, 0, A) :- A > 0.
gcd(A, B, G) :-
    B > 0,
    R is A mod B,
    gcd(B, R, G).

% ----- Check GCD = 1 between consecutive coins -----
valid_gcd([_]).
valid_gcd([A,B|T]) :-
    gcd(A,B,1),
    valid_gcd([B|T]).

% ----- Sum of list -----
sum_list([],0).
sum_list([H|T],S) :-
    sum_list(T,S1),
    S is H+S1.

% ----- Count unique coins -----
unique_count(List, Count) :-
    sort(List, Unique),
    length(Unique, Count).

% ----- Generate coin sequences that sum to Amount -----
coin_seq(0, _, []).
coin_seq(Amount, Coins, [C|T]) :-
    Amount > 0,
    member(C, Coins),
    Amount1 is Amount - C,
    Amount1 >= 0,
    coin_seq(Amount1, Coins, T).

% ----- Find the sequence with maximum unique coins -----
change(Amount, BestCoins, BestUnique) :-
    coins(CoinList),
    findall(
        (Coins, U),
        (
            coin_seq(Amount, CoinList, Coins),
            Coins \= [],
            valid_gcd(Coins),
            unique_count(Coins, U)
        ),
        AllSolutions
    ),
    max_unique(AllSolutions, (BestCoins, BestUnique)).

% ----- Select best solution (maximum unique coins) -----
max_unique([X], X).
max_unique([(C1,U1),(C2,U2)|T], Best) :-
    ( U1 >= U2 ->
        max_unique([(C1,U1)|T], Best)
    ;
        max_unique([(C2,U2)|T], Best)
    ).
