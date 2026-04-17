
color(red).
color(green).
color(blue).

different_colors(X, Y) :- color(X), color(Y), X \= Y.



% ====================
% ======QUERY=========
% ====================



% different_colors(red, green)
% returns true


% different_colors(red, red)
% returns false [as same color]


% different_colors(blue, green)
% returns true


% different_colors(blue, yellow)
% returns false [as yellow is not defined in color]



