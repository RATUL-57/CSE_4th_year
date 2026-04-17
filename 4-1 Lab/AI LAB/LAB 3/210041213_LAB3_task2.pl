
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

sibling(X, Y) :- parent(Z, X), parent(Z, Y), X \= Y.

child(X, Y) :- parent(Y, X).

man(X) :- gender(X, male).

woman(X) :- gender(X, female).

grandparent(X, Z) :- parent(X, Y) , parent(Y, Z).

grandson(X, Z) :- parent(Z, Y) , parent(Y, X), gender(X, male).

granddaughter(X, Z) :- parent(Z, Y) , parent(Y, X), gender(X, female).




% ====================
% ======QUERY=========
% ====================


% grandparent(X, charlie)

% grandparent(alice, eric)

% grandson(X, alice)







