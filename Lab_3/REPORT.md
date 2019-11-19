#№ Отчет по лабораторной работе №3
## по курсу "Логическое программирование"

## Решение задач методом поиска в пространстве состояний

### студент: Ваньков Д.А.


## Введение

Один из методов решения задач - поиск в пространстве состояний, суть которого заключается в построении графа и применении алгоритмов поиска на нем со следующими условиями:

1.Вершины графа отвечают за состояния задачи
2.Ребра графа являются переходами из одного состояния в другое
3.Есть начальные и конечные состояния
4.Решение задачи - это путь из начальной вершины в конечную

В данной лабораторной работе используется 3 алгоритма поиска: в глубину, в ширину, и с итеративным погружением

Prolog оказывается действительно удобным языком для решения таких задач с помощью поиска в глубину и поиска с итеративным углублением, так как эти методы обхода графа очень схожи с механизмом вывода в Prolog. Другой важной особенностью является то, что в данном языке можно легко описать множество состояний, причем в некоторых случаях можно генерировать новые состояния при необходимости, а не хранить их все.


## Задание

Расстановка мебели. Площадь разделена на шесть квадратов, пять из них заняты мебелью, шестой свободен. Переставить мебель так, чтобы шкаф и кресло поменялись местами,
при этом никакие два предмета не могут стоять на одном квадрате.


## Принцип решения

Вершины графа - список из двух списков, описывающих комнату.
Предикат move, описанный для каждого из состояний, генерирует переход из одного состояния в другое, только если это возможно. Предикат prolong, продлевает текущий путь, рекурсивно запуская предикат move.

```Prolog
move([U,D],[U1,D]) :-
	change(U,U1).

move([U,D],[U,D1]) :-
	change(D,D1).

move([U,D],[U1,D1]) :-
	change(U,D,U1,D1).

move([U,D],[U1,D1]) :-
	change(D,U,D1,U1).

change([empty,X,Y],[X,empty,Y]).
change([X,empty,Y],[empty,X,Y]).
change([X,empty,Y],[X,Y,empty]).
change([X,Y,empty],[X,empty,Y]).
change([Y,Z,empty],[U,W,X],[Y,Z,X],[U,W,empty]).
change([Y,empty,Z],[U,X,W],[Y,X,Z],[U,empty,W]).
change([empty,Y,Z],[X,U,W],[X,Y,Z],[empty,U,W]).

prolong([X|T], [Y,X|T]) :-
    move(X,Y),
\+(member(Y,[X|T])).
```

Предикат pathDFS ищет ответ на задачу, а точнее путь от начального состояния к конечному, с помощью обхода в глубину. В данном случае обход в глубину работает, пока возможно продление пути и не достигнута конечная вершина. Так как путь записан в обратном порядке, его необходимо реверсировать (Данное утверждение справедливо и для остальных алгоритмов). Найденный путь будет необязательно кратчайшим.
```Prolog
pathDFS(X,Y,P) :- 
    dfs([X], Y, P1), reverse(P1, P).    

dfs([X|T],X,[X|T]).
dfs(P,Y,R) :-
    prolong(P,P1), dfs(P1,Y,R).
```
pathBFS реализует решение с помощью поиска в ширину. Для него используется очередь из путей, которые можно продлить. Продленные пути добавляются в конец очереди, а путь, который мы продлевали удаляется. Если первый элемент очереди - это путь который ведет в конечную вершину, поиск можно завершить. Найденный путь гарантированно будет кратчайшим. 
```Prolog
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
```
Поиск с итеративным углублением использует идею метода поиска в глубину, однако глубина поиска ограничивается некоторым значением, поэтому мы ограничываем длину возможных решений, что позволяет найти кратчайший путь.
```Prolog
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
```


## Результаты

На запрос  | ?- pathDFS([[x,y,z],[w,empty,u]],[[_,_,u],[_,_,z]],P). - программа выдает следующий ответ, который является путем из начального состояния в конечное, а также время работы алгоритма и количество шагов.
```Prolog
| ?- pathDFS([[x,y,z],[w,empty,u]],[[_,_,u],[_,_,z]],P).
P = [[[x,y,z],[w,empty,u]],[[x,y,z],[empty,w,u]],[[empty,y,z],[x,w,u]],[[y,empty,z],[x,w,u]],[[y,z,empty],[x,w,u]],[[y,z,u],[x,w,empty]],[[y,z,u],[x,empty,w]],[[y,z,u],[empty,x,w]],[[empty,z,u],[y,x,w]],[[z,empty,u],[y,x,w]],[[z,u,empty],[y,x,w]],[[z,u,w],[y,x,empty]],[[z,u,w],[y,empty,x]],[[z,u,w],[empty,y,x]],[[empty,u,w],[z,y,x]],[[u,empty,w],[z,y,x]],[[u,w,empty],[z,y,x]],[[u,w,x],[z,y,empty]],[[u,w,x],[z,empty,y]],[[u,w,x],[empty,z,y]],[[empty,w,x],[u,z,y]],[[w,empty,x],[u,z,y]],[[w,x,empty],[u,z,y]],[[w,x,y],[u,z,empty]],[[w,x,y],[u,empty,z]],[[w,x,y],[empty,u,z]],[[empty,x,y],[w,u,z]],[[x,empty,y],[w,u,z]],[[x,u,y],[w,empty,z]],[[x,u,y],[empty,w,z]],[[empty,u,y],[x,w,z]],[[u,empty,y],[x,w,z]],[[u,y,empty],[x,w,z]],[[u,y,z],[x,w,empty]],[[u,y,z],[x,empty,w]],[[u,y,z],[empty,x,w]],[[empty,y,z],[u,x,w]],[[y,empty,z],[u,x,w]],[[y,z,empty],[u,x,w]],[[y,z,w],[u,x,empty]],[[y,z,w],[u,empty,x]],[[y,z,w],[empty,u,x]],[[empty,z,w],[y,u,x]],[[z,empty,w],[y,u,x]],[[z,w,empty],[y,u,x]],[[z,w,x],[y,u,empty]],[[z,w,x],[y,empty,u]],[[z,w,x],[empty,y,u]],[[empty,w,x],[z,y,u]],[[w,empty,x],[z,y,u]],[[w,x,empty],[z,y,u]],[[w,x,u],[z,y,empty]],[[w,x,u],[z,empty,y]],[[w,x,u],[empty,z,y]],[[empty,x,u],[w,z,y]],[[x,empty,u],[w,z,y]],[[x,z,u],[w,empty,y]],[[x,z,u],[empty,w,y]],[[empty,z,u],[x,w,y]],[[z,empty,u],[x,w,y]],[[z,u,empty],[x,w,y]],[[z,u,y],[x,w,empty]],[[z,u,y],[x,empty,w]],[[z,u,y],[empty,x,w]],[[empty,u,y],[z,x,w]],[[u,empty,y],[z,x,w]],[[u,y,empty],[z,x,w]],[[u,y,w],[z,x,empty]],[[u,y,w],[z,empty,x]],[[u,y,w],[empty,z,x]],[[empty,y,w],[u,z,x]],[[y,empty,w],[u,z,x]],[[y,w,empty],[u,z,x]],[[y,w,x],[u,z,empty]],[[y,w,x],[u,empty,z]],[[y,w,x],[empty,u,z]],[[empty,w,x],[y,u,z]],[[w,empty,x],[y,u,z]],[[w,x,empty],[y,u,z]],[[w,x,z],[y,u,empty]],[[w,x,z],[y,empty,u]],[[w,empty,z],[y,x,u]],[[empty,w,z],[y,x,u]],[[y,w,z],[empty,x,u]],[[y,w,z],[x,empty,u]],[[y,w,z],[x,u,empty]],[[y,w,empty],[x,u,z]],[[y,empty,w],[x,u,z]],[[empty,y,w],[x,u,z]],[[x,y,w],[empty,u,z]],[[x,y,w],[u,empty,z]],[[x,y,w],[u,z,empty]],[[x,y,empty],[u,z,w]],[[x,empty,y],[u,z,w]],[[empty,x,y],[u,z,w]],[[u,x,y],[empty,z,w]],[[u,x,y],[z,empty,w]],[[u,x,y],[z,w,empty]],[[u,x,empty],[z,w,y]],[[u,empty,x],[z,w,y]],[[empty,u,x],[z,w,y]],[[z,u,x],[empty,w,y]],[[z,u,x],[w,empty,y]],[[z,u,x],[w,y,empty]],[[z,u,empty],[w,y,x]],[[z,empty,u],[w,y,x]],[[empty,z,u],[w,y,x]],[[w,z,u],[empty,y,x]],[[w,z,u],[y,empty,x]],[[w,empty,u],[y,z,x]],[[empty,w,u],[y,z,x]],[[y,w,u],[empty,z,x]],[[y,w,u],[z,empty,x]],[[y,w,u],[z,x,empty]],[[y,w,empty],[z,x,u]],[[y,empty,w],[z,x,u]],[[empty,y,w],[z,x,u]],[[z,y,w],[empty,x,u]],[[z,y,w],[x,empty,u]],[[z,y,w],[x,u,empty]],[[z,y,empty],[x,u,w]],[[z,empty,y],[x,u,w]],[[empty,z,y],[x,u,w]],[[x,z,y],[empty,u,w]],[[x,z,y],[u,empty,w]],[[x,z,y],[u,w,empty]],[[x,z,empty],[u,w,y]],[[x,empty,z],[u,w,y]],[[empty,x,z],[u,w,y]],[[u,x,z],[empty,w,y]],[[u,x,z],[w,empty,y]],[[u,x,z],[w,y,empty]],[[u,x,empty],[w,y,z]],[[u,empty,x],[w,y,z]],[[u,y,x],[w,empty,z]],[[u,y,x],[empty,w,z]],[[empty,y,x],[u,w,z]],[[y,empty,x],[u,w,z]],[[y,x,empty],[u,w,z]],[[y,x,z],[u,w,empty]],[[y,x,z],[u,empty,w]],[[y,x,z],[empty,u,w]],[[empty,x,z],[y,u,w]],[[x,empty,z],[y,u,w]],[[x,z,empty],[y,u,w]],[[x,z,w],[y,u,empty]],[[x,z,w],[y,empty,u]],[[x,z,w],[empty,y,u]],[[empty,z,w],[x,y,u]],[[z,empty,w],[x,y,u]],[[z,w,empty],[x,y,u]],[[z,w,u],[x,y,empty]],[[z,w,u],[x,empty,y]],[[z,w,u],[empty,x,y]],[[empty,w,u],[z,x,y]],[[w,empty,u],[z,x,y]],[[w,u,empty],[z,x,y]],[[w,u,y],[z,x,empty]],[[w,u,y],[z,empty,x]],[[w,u,y],[empty,z,x]],[[empty,u,y],[w,z,x]],[[u,empty,y],[w,z,x]],[[u,z,y],[w,empty,x]],[[u,z,y],[empty,w,x]],[[empty,z,y],[u,w,x]],[[z,empty,y],[u,w,x]],[[z,y,empty],[u,w,x]],[[z,y,x],[u,w,empty]],[[z,y,x],[u,empty,w]],[[z,y,x],[empty,u,w]],[[empty,y,x],[z,u,w]],[[y,empty,x],[z,u,w]],[[y,x,empty],[z,u,w]],[[y,x,w],[z,u,empty]],[[y,x,w],[z,empty,u]],[[y,x,w],[empty,z,u]],[[empty,x,w],[y,z,u]],[[x,empty,w],[y,z,u]],[[x,w,empty],[y,z,u]],[[x,w,u],[y,z,empty]],[[x,w,u],[y,empty,z]]] 
X = 181 ? 
(4 ms) yes


| ?- pathBFS([[x,y,z],[w,empty,u]],[[_,_,u],[_,_,z]],P).
P = [[[x,y,z],[w,empty,u]],[[x,y,z],[w,u,empty]],[[x,y,empty],[w,u,z]],[[x,empty,y],[w,u,z]],[[empty,x,y],[w,u,z]],[[w,x,y],[empty,u,z]],[[w,x,y],[u,empty,z]],[[w,empty,y],[u,x,z]],[[w,y,empty],[u,x,z]],[[w,y,z],[u,x,empty]],[[w,y,z],[u,empty,x]],[[w,y,z],[empty,u,x]],[[empty,y,z],[w,u,x]],[[y,empty,z],[w,u,x]],[[y,u,z],[w,empty,x]],[[y,u,z],[w,x,empty]],[[y,u,empty],[w,x,z]],[[y,empty,u],[w,x,z]]]
X = 18 ?
(12 ms) yes

| ?- pathIDDFS([[x,y,z],[w,empty,u]],[[_,_,u],[_,_,z]],P),length(P,X).
P = [[[x,y,z],[w,empty,u]],[[x,y,z],[w,u,empty]],[[x,y,empty],[w,u,z]],[[x,empty,y],[w,u,z]],[[empty,x,y],[w,u,z]],[[w,x,y],[empty,u,z]],[[w,x,y],[u,empty,z]],[[w,empty,y],[u,x,z]],[[w,y,empty],[u,x,z]],[[w,y,z],[u,x,empty]],[[w,y,z],[u,empty,x]],[[w,y,z],[empty,u,x]],[[empty,y,z],[w,u,x]],[[y,empty,z],[w,u,x]],[[y,u,z],[w,empty,x]],[[y,u,z],[w,x,empty]],[[y,u,empty],[w,x,z]],[[y,empty,u],[w,x,z]]]
X = 18 ? 
(12 ms) yes
```

| Алгоритм поиска |  Длина найденного первым пути  |  Время работы  |
|-------------------------------------------------------------------|
| В глубину       |             X = 181            |      4 ms      |
| В ширину        |             X = 18             |     12 ms      |
| ID              |             X = 18             |     12 ms      |

## Выводы

В ходе лабораторной работы была успешно выполнена поставленная цель изучен метод поиска в пространстве состояний для решения задачи. Были реализованы три алгоритма поиска в графах: в ширину, глубину и с итеративным углублением.

Из результата работы программы мы видим, что самым быстрым является DFS, однако он нашел не кратчайший путь, и этот путь намного длинее.
Я считаю, что поиск и итеративным углублением является наиболее подходящим для решения данной задачи, по следующим причинам:

1. В отличии от DFS, он находит кратчайший путь для решения, хоть и работает дольше.
2. BFS хоть и находит самый короткий путь, использование им оперативной памяти желает оставлять лучшего.
