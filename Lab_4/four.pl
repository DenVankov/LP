/* Программа получает список, состоящий из операторов
и операндов. представим его в виде:
G = <VT,  NT, S0, P>, где VT-терминальные элементы
NT-нетерминальные, S0-начальное сотояние, P-правило
перехода
VT = {+,-,*,/,0,1,...,9}
NT = {Expr, Term, Number}
    (+,-)   (*,/)  (0,1)
*/
% Главный предикат принимающий список из операторов и операндов
calculate(List, Res):-
  reverse(List, List1), a_expr(List1, Res),!.

% Вычисление для плюса
a_expr(Expr, Res):-
   append(Term, ['+'|Expr1], Expr),
   a_term(Term, Res1), a_expr(Expr1,Res2),
   Res is Res1 + Res2.

% Вычисление для минуса
a_expr(Expr,Res):-
  append(Term,['-'|Expr1], Expr),
  a_term(Term, Res1), a_expr(Expr1, Res2),
  Res is Res2 - Res1.

% Опишем правила перехода для Expr
a_expr(Expr, Res):- a_term(Expr,Res).

% Если терм это число то получаем его
a_term(Term, Res):-
  a_power(Term, Res).

% Вычисление для умножения
a_term(Term, Res):-
  append(Power,['*'|Term1], Term),
  a_power(Power, Res1), a_term(Term1,Res2),
  Res is Res1 * Res2.

% Вычисление для деления
a_term(Term, Res):-
  append(Power,['/'|Term1], Term),
  a_power(Power, Res1), a_term(Term1, Res2),
  Res is Res2 / Res1.

% Отдельный предикат для возведения в степень для приоретета
a_power(Term, Res):-
  append(Number,['^'|Term1], Term),
  a_number(Number, Res1), a_power(Term1, Res2),
  Res is Res2 ** Res1.

% Получение числа
a_number([Number],Number):- number(Number).

% Получения числа для предиката степени
a_power([Number],Number):- number(Number).
