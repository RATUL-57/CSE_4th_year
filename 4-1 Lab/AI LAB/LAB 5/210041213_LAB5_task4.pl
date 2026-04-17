
edges([
    (a, b, 5),
    (b, c, 4),
    (b, d, 2),
    (c, e, 3),
    (d, e, 5),
    (b, e, 5)
]).

foods([
    (a, pizza),
    (b, burger),
    (c, pizza),
    (d, burger),
    (e, pizza)
]).

food_values([
    (pizza, 6),
    (burger, 10)
]).

% find_edge(Start, End, Cost)
find_edge(X, Y, Cost) :-
    edges(Edges),
    member((X, Y, Cost), Edges).

% find_food(Node, Food)
find_food(Node, Food) :-
    foods(Foods),
    member((Node, Food), Foods).

% find_food_value(Food, Value)
find_food_value(Food, Value) :-
    food_values(FVs),
    member((Food, Value), FVs).

% calculate_food_gain(Food, FoodCount, Gain)
% FoodCount = number of times food eaten previously
calculate_food_gain(Food, FoodCount, Gain) :-
    find_food_value(Food, Value),
    Gain is Value / FoodCount.

% ---------------- Main search ----------------

% happiest_path(Start, End, Path, Cost, Points)
happiest_path(Start, End, Path, Cost, Points) :-
    dfs(Start, End, [Start], 0, [], 0, Path, Cost, Points),
    Points > 0.  % Only return if Points > 0

% dfs(CurrentNode, End, Visited, CostSoFar, FoodList, HappinessSoFar, Path, TotalCost, Points)
dfs(End, End, Visited, CostSoFar, _, HappinessSoFar, Path, CostSoFar, Points) :-
    reverse(Visited, Path),
    Points is HappinessSoFar.  % At end node, food doesn't count, only subtract cost already done

dfs(Current, End, Visited, CostSoFar, FoodEaten, HappinessSoFar, Path, TotalCost, Points) :-
    find_edge(Current, Next, StepCost),
    \+ member(Next, Visited),
    
    % Calculate food gain if Next is not the end
    (Next \= End ->
        find_food(Next, Food),
        count_occurrences(Food, FoodEaten, Count),
        NewCount is Count + 1,
        calculate_food_gain(Food, NewCount, FoodGain),
        NewHappiness is HappinessSoFar + FoodGain
    ;
        % If next is End, food doesn't count
        NewHappiness is HappinessSoFar
    ),
    
    NewCost is CostSoFar + StepCost,
    
    % Continue DFS
    dfs(Next, End, [Next|Visited], NewCost, [Food|FoodEaten], NewHappiness, Path, TotalCost, Points).

% count_occurrences(Element, List, Count)
count_occurrences(_, [], 0).
count_occurrences(E, [E|T], Count) :-
    count_occurrences(E, T, C1),
    Count is C1 + 1.
count_occurrences(E, [H|T], Count) :-
    E \= H,
    count_occurrences(E, T, Count).


% ---------------- Example query ----------------
% ?- happiest_path(a, e, Path, Cost, Points).
% Expected: Path = [a,b,c,e], Cost = 12, Points = 4
