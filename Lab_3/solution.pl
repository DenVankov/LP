
% Предикат движения, или перехода из одного состояния в другое
move([U,D],[U1,D]) :-
	change(U,U1).

move([U,D],[U,D1]) :-
	change(D,D1).

move([U,D],[U1,D1]) :-
	change(U,D,U1,D1).

move([U,D],[U1,D1]) :-
	change(D,U,D1,U1).

% Возвможность перестановки элементов
change([empty,X,Y],[X,empty,Y]).
change([X,empty,Y],[empty,X,Y]).
change([X,empty,Y],[X,Y,empty]).
change([X,Y,empty],[X,empty,Y]).
change([Y,Z,empty],[U,W,X],[Y,Z,X],[U,W,empty]).
change([Y,empty,Z],[U,X,W],[Y,X,Z],[U,empty,W]).
change([empty,Y,Z],[X,U,W],[X,Y,Z],[empty,U,W]).

% Предикат продлевающий путь
prolong([X|T], [Y,X|T]) :-
    move(X,Y),
\+(member(Y,[X|T])).

% Поиск в глубину
pathDFS(X,Y,P) :- 
    dfs([X], Y, P1), reverse(P1, P).    

dfs([X|T],X,[X|T]).
dfs(P,Y,R) :-
prolong(P,P1), dfs(P1,Y,R).

% Поиск в ширину
pathBFS(X,Y,P) :- 
    bfs([[X]],Y,P1),
    reverse(P1,P).

bfs([[X|T]|_], X, [X|T]).

bfs([P|QI], X, R) :-
    findall(Z, prolong(P,Z), T),
    append(QI,T,QO),!,
    bfs(QO, X, R).

bfs([_|T], Y, L) :-
bfs(T,Y,L).

fact(1, 1):- !.
fact(X, N) :-
    X1 is X - 1,
    fact(X1,N1),
    N is X * N1, !.

% Поиск в глубину с итерационным заглублением
pathIDDFS(X,Y,P) :-
    MaxLevel = 20,
    generate(Level),
    (
        Level > MaxLevel, !;
        pathIDDFS(X,Y,P1,Level), reverse(P1, P)
    ).

generate(1).
generate(M) :-
    generate(N),
	M is N + 1.

pathIDDFS(X,Y,P,DepthLimit) :-
    iddfs([X], Y, P, DepthLimit).

iddfs([X|T],X,[X|T],0).

iddfs(P,Y,R,N) :-
    N > 0,
    prolong(P, P1),
    N1 is N - 1,
iddfs(P1,Y,R,N1). 