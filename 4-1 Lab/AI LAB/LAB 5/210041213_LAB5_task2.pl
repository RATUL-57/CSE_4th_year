% -------- Available coins and stock --------
coins([1,2,5,10]).
stock([(1,5),(2,3),(5,2),(10,2)]).

% -------- Main Predicate --------
change_limited(Amount, LowLimit, HighLimit, Coins, Sum) :-
    coins(CoinList),
    stock(StockList),
    solve(CoinList, StockList, Amount, LowLimit, HighLimit, Coins, Sum),
    write('Coins = '), write(Coins), nl,
    write('Sum = '), write(Sum), nl,
    fail.
change_limited(_,_,_,_,_) :- true.

% -------- Recursive solver --------
solve([], [], 0, Low, High, [], 0) :-
    Low =< 0,
    High >= 0.

solve([C|CT], [(C,Max)|ST], Amount, Low, High, [(C,Q)|T], Sum) :-
    between(0, Max, Q),           % choose quantity within stock
    Amount1 is Amount - C*Q,
    Amount1 >= 0,
    Low1 is Low - Q,
    High1 is High - Q,
    High1 >= 0,
    solve(CT, ST, Amount1, Low1, High1, T, Sum1),
    Sum is Q + Sum1.
