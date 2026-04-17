% Use this editor as a MiniZinc scratch book
% Houses are 1..5 (1 = leftmost)

array[1..5] of var 1..5: color;
array[1..5] of var 1..5: nation;
array[1..5] of var 1..5: candy;
array[1..5] of var 1..5: drink;
array[1..5] of var 1..5: pet;

% ----------------------------
% All-different constraints 
% ----------------------------

% Colors --------------------
% 1 = Red , 2 = Green , 3 = Ivory , 4 = Yellow , 5 = Blue
% ---------------------------

constraint color[1]!=color[2] /\ color[1]!=color[3] /\ color[1]!=color[4] /\ color[1]!=color[5] /\
          color[2]!=color[3] /\ color[2]!=color[4] /\ color[2]!=color[5] /\
          color[3]!=color[4] /\ color[3]!=color[5] /\
          color[4]!=color[5];


% Nationality ---------------
% 1 = English , 2 = Spaniard , 3 = Norwegian , 4 = Ukranian , 5 = Japanese
% ---------------------------

constraint nation[1]!=nation[2] /\ nation[1]!=nation[3] /\ nation[1]!=nation[4] /\ nation[1]!=nation[5] /\
          nation[2]!=nation[3] /\ nation[2]!=nation[4] /\ nation[2]!=nation[5] /\
          nation[3]!=nation[4] /\ nation[3]!=nation[5] /\
          nation[4]!=nation[5];

% Candy ---------------------
% 1 = Hershey , 2 = KitKat , 3 = Smarties , 4 = Snickers , 5 = Milkyway
% ---------------------------

constraint candy[1]!=candy[2] /\ candy[1]!=candy[3] /\ candy[1]!=candy[4] /\ candy[1]!=candy[5] /\
          candy[2]!=candy[3] /\ candy[2]!=candy[4] /\ candy[2]!=candy[5] /\
          candy[3]!=candy[4] /\ candy[3]!=candy[5] /\
          candy[4]!=candy[5];

% Drink ---------------------
% 1 = Coffee , 2 = Tea , 3 = Milk , 4 = OrangeJuice , 5 = Water
% ---------------------------

constraint drink[1]!=drink[2] /\ drink[1]!=drink[3] /\ drink[1]!=drink[4] /\ drink[1]!=drink[5] /\
          drink[2]!=drink[3] /\ drink[2]!=drink[4] /\ drink[2]!=drink[5] /\
          drink[3]!=drink[4] /\ drink[3]!=drink[5] /\
          drink[4]!=drink[5];

% Pets ----------------------
% 1 = Dog , 2 = Fox , 3 = Snails , 4 = Horse , 5 = Cat
% ---------------------------

constraint pet[1]!=pet[2] /\ pet[1]!=pet[3] /\ pet[1]!=pet[4] /\ pet[1]!=pet[5] /\
          pet[2]!=pet[3] /\ pet[2]!=pet[4] /\ pet[2]!=pet[5] /\
          pet[3]!=pet[4] /\ pet[3]!=pet[5] /\
          pet[4]!=pet[5];

% -------------------------------------------------
% Given facts
% -------------------------------------------------

constraint forall(i in 1..5)(
    (nation[i]=1) -> (color[i]=1)
);

constraint forall(i in 1..5)(
    (nation[i]=2) -> (pet[i]=1)
);

constraint nation[1]=3;

constraint exists(i in 1..4)(
    color[i]=3 /\ color[i+1]=2
);

constraint forall(i in 1..5)(
    (candy[i]=1) ->
    ((i>1 /\ pet[i-1]=2) \/ (i<5 /\ pet[i+1]=2))
);

constraint forall(i in 1..5)(
    (candy[i]=2) -> (color[i]=4)
);

constraint (color[2]=5);

constraint forall(i in 1..5)(
    (candy[i]=3) -> (pet[i]=3)
);

constraint forall(i in 1..5)(
    (candy[i]=4) -> (drink[i]=4)
);

constraint forall(i in 1..5)(
    (nation[i]=4) -> (drink[i]=2)
);

constraint forall(i in 1..5)(
    (nation[i]=5) -> (candy[i]=5)
);

constraint forall(i in 1..5)(
    (candy[i]=2) ->
    ((i>1 /\ pet[i-1]=4) \/ (i<5 /\ pet[i+1]=4))
);

constraint forall(i in 1..5)(
    (color[i]=2) -> (drink[i]=1)
);

constraint drink[3]=3;

solve satisfy;
