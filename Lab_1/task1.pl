% Предикат принадлежности
member(X, [X|_]).
member(X, [_|T]) :- member(X, T).

% Конкатенация списков
append([], L, L).
append([X|R1]), L2, [X|R3] :- append(R1, L2, R3).
%Удалить 1 элемент по значению, если их несколько перебор всех вариантов
remove(X, [X|T], T).
remove(X, [M|T], [M|T1]) :- remove(X, T, T1).

% Удаление элемента из конца списка
removelast([_|[]], []).
removelast([H|T], [H|Result]) :- removelast(T, Result).

% Подсписок списка (первый второго)
sublist([],_).
sublist([X|Tail1], [X|Tail2]) :- sublist(Tail1, Tail2).
sublist([X|Tail1], [Y|Tail2]) :- sublist(X|Tail1, Tail2).

% Перестановка списка
takeout(X, [X|T], T).
takeout(X, [F|T1], [F|T2]) :- takeout(X, T1, T2).

permute([X|T1], K) :- permute(T1,M), takeout(X, K, M).
permute([],[]).

% Длина списка
length([],0).
length([X|T],N) :- length(T,N1), N is N1 + 1.

% Удаление по значению
delete([], _Elem, []) :- !.
delete([Elem|Tail], Elem, ResultTail) :- delete(Tail, Elem, ResultTail), !.
delete([Head|Tail], Elem, [Head|ResultTail]) :- delete(Tail, Elem, ResultTail).

% Предикат удаления 3 первых элементов
delThree([_,_,_|T], T) :- !.
delThree(_, []).

equal(X,Y) :- X=Y.

%Предикат вычисление числа вхождения 1-го элемента
count([X|T],N):-count(X,T,N),!.
count(_,[],1).
count(X,[Y|T],N):-equal(X,Y),count(X,T,N1),N is N1 + 1.
count(X,[Y|T],N):-count(X,T,N).
count([],0).
