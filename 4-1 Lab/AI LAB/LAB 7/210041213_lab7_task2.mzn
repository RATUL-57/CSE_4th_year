% Faculty: 1 = X, 2 = Y
% Time slots: 1..4

% Tasks:
% 0 = Free
% 1 = G (Gather DBMS content)
% 2 = Q (Check quiz - 2 hrs)
% 3 = C (AI class)
% 4 = D (DBMS Lab)
% 5 = L (AI Lab - 2 hrs)

array[1..2, 1..4] of var 0..5: schedule;

constraint forall(f in 1..2)(
    exists(t1 in 1..4, t2 in 1..4)(
        schedule[f,t1]=3 /\
        schedule[f,t2]=5 /\
        t1 < t2
    )
);




constraint exists(t1 in 1..4, t2 in 1..4)(
    schedule[1,t1] = 1 /\
    (schedule[1,t2] = 4 \/ schedule[2,t2] = 4) /\
    t1 < t2
);


constraint forall(f in 1..2, t in 3..4)(
    schedule[f,t] != 4
);

constraint exists(t in 1..4)( schedule[1,t] = 1 );


constraint forall(t in 1..4)(
    (schedule[1,t]=4 -> schedule[2,t] != 0) /\
    (schedule[2,t]=4 -> schedule[1,t] != 0)
);


constraint forall(f in 1..2)(
    (exists(t in 1..4)(schedule[f,t]=4)) ->
    (forall(t in 1..4)(schedule[f,t] != 5))
);

constraint forall(f in 1..2)(
    (exists(t in 1..4)(schedule[f,t]=5)) ->
    (exists(t in 1..4)(schedule[f,t]=3))
);

constraint forall(f in 1..2)(
    (exists(t in 1..3)(
        schedule[f,t]=2 /\ schedule[f,t+1]=2
    ))
);

constraint forall(f in 1..2)(
    (exists(t in 1..3)(
        schedule[f,t]=5 /\ schedule[f,t+1]=5
    ))
);




solve satisfy;

% output [
% "Schedule (faculty x time):\n",
% show(schedule)
% ];