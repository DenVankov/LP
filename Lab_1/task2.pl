% Task 2: Relational Data
% The line below imports the data
:- ['four.pl'].

:- dynamic grade/2.

%Находим среднее арифмитическое предмета
find_center(Subject,Grade) :- subject(Subject,L), add(L), count(Grade), delete(L).

%Получение локальной базы в формате: grade('Имя', mark)
add([]) :- !.
add([X|Subject]) :- add(Subject), assert(X).

%Получение списка оценок
count(X) :- findall(Mark,grade(Name,Mark),Result), accumulate(Result,Sum), answer(Result,Sum,X).

%Получение общей суммы оценок
accumulate(List,X) :- accumulate(List,0,X).
accumulate([Frst|Tail], N, Res) :- N1 is N + Frst, accumulate(Tail, N1, Res).
accumulate([], Res, Res).

%Получение среднего арифметического
answer(Marks,Sum,X) :- length(Marks,Y), X is Sum/Y.


% Предикат вызова несдавших в каждой группе
count_group_fail() :-
  setof(Y,X^group(Y,X),Group_list),
  group_fail(Group_list).

%Предикат вывода
group_fail([]) :- !.
group_fail([Group|T]) :-
  people_failed_exam(Group,Count),
  write('В группе '),
  write(Group),
  write(' не сдало: '),
  write(Count),
  nl,
  group_fail(T).

%Предикат производящий считывание и передачу данных в вывод
people_failed_exam(Group,Count) :-
  group(Group,Name_List),
  findall(List_of_list, subject(_,List_of_list),Grade_list),
  add_grade(Grade_list),
  count_losers(Name_List, Count),!,
  delete_grade(Grade_list).

%Удаление базы оценок
delete_grade([]).
delete_grade([Grade|T]) :- delete_grade(T), delete(Grade).

%Получение списка списков всех предикатов grade()
add_grade_list() :-
  findall(List_of_list, subject(_,List_of_list),Grade_list),
  add_grade(Grade_list).

%Разделение списка списков на один список
add_grade([]).
add_grade([Grade|T]) :- add_grade(T), add_for_two(Grade).

%Получение списка предикатов grade()
add_for_two([]) :- !.
add_for_two([Grade|T]) :- add_for_two(T), assertz(Grade).

%Подсчет несдавших по группам
count_losers([], 0) :- !.
count_losers([Name|T],Count) :- find_loser(Name), count_losers(T,Count1), Count is Count1 + 1.
count_losers([Name|T],Count) :- count_losers(T,Count).

%Проверка на несдавшего любого человека
find_loser(Name) :-
  findall(Mark,grade(Name,Mark),List_of_Marks), fall_two(List_of_Marks).

%Есть ли у человека двойка
fall_two(List_of_Marks) :- member(2,List_of_Marks).


%Вызов предиката вывода, а также получение списка всех предметов
count_subject_fail() :-
  setof(Y,X^subject(Y,X),Subject_list),
  subject_fail(Subject_list).

%Предикат вывода
subject_fail([]) :- !.
subject_fail([Subject|Tail]) :-
  people_failed_subject(Subject,Count),
  write('Предмет '),
  write(Subject),
  write(' не сдало: '),
  write(Count),
  nl,
  subject_fail(Tail).

%Предикат производящий считывание и передачу данных в вывод
people_failed_subject(Subject,Count):-
  subject(Subject,Grade_List),
  add(Grade_List),
  findall(Mark,grade(Name,Mark),List_of_Marks),
  count_losers_sub(List_of_Marks,Count),!,
  delete(Grade_List).

%Удаление текущей локальной базы
delete([]) :- !.
delete([X|Subject]) :- delete(Subject), retract(X).

%Сравнение
equal(X,Y) :- X=Y.

%Подсчет несдавших по предметам
count_losers_sub([],0) :- !.
count_losers_sub([Mark|T],Count) :- equal(Mark,2), count_losers_sub(T,Count1), Count is Count1 + 1.
count_losers_sub([Mark|T],Count) :- count_losers_sub(T,Count).
