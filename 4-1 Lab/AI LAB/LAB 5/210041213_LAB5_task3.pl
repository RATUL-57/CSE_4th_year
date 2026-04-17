student(alice, 100, 70, 90).
student(bob, 80, 80, 80).
student(charlie, 100, 50, 100).
student(diana, 70, 70, 70).

subject_grade(Marks, 'A') :- Marks >= 90, !.
subject_grade(Marks, 'B') :- Marks >= 80, !.
subject_grade(Marks, 'C') :- Marks >= 70, !.
subject_grade(Marks, 'D') :- Marks >= 60, !.
subject_grade(_, 'F').

grade_value('A',5).
grade_value('B',4).
grade_value('C',3).
grade_value('D',2).
grade_value('F',1).

lowest_grade(G1,G2,G3,Lowest) :-
    grade_value(G1,V1),
    grade_value(G2,V2),
    grade_value(G3,V3),
    Minimum is min(V1, min(V2,V3)),
    grade_value(Lowest, Minimum).

total(M1,M2,M3,T) :- T is M1+M2+M3.

student_entry(Name, [Lowest, Total, Name], SortKey) :-
    student(Name,M1,M2,M3),
    subject_grade(M1,G1),
    subject_grade(M2,G2),
    subject_grade(M3,G3),
    lowest_grade(G1,G2,G3,Lowest),
    total(M1,M2,M3,Total),
    grade_value(Lowest, GV),
    SortKey = -GV-Total.

rank_students(RankedList) :-
    findall(
        Key-Entry,
        student_entry(_, Entry, Key),
        KeyPairLists
    ),
    keysort(KeyPairLists, SortedAscending),
    reverse(SortedAscending, SortedDescending),
    extract(SortedDescending, RankedList).

extract([], []).
extract([_-E|T], [E|R]) :-
    extract(T,R).

