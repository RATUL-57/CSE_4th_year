
parent(alice, bob).
parent(bob, charlie).
parent(alice, diana).
parent(diana, eric).

gender(alice, female).
gender(bob, male).
gender(charlie, male).
gender(diana, female).
gender(eric, male).

age(alice, 55).
age(bob, 30).
age(charlie, 10).
age(diana, 28).
age(eric, 5).

sibling(X, Y) :-
    parent(Z, X),
    parent(Z, Y),
    X \= Y.

child(X, Y) :-
    parent(Y, X).

man(X) :-
    gender(X, male).

woman(X) :-
    gender(X, female).



% ====================
% ======QUERY=========
% ====================


% parent(alice, X)

% parent(X, bob)

% age(X, 30)

% gender(X, male)






