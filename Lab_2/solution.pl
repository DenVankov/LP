/*
Как-то раз случай свел в купе известного астронома, поэта, прозаика и драматурга.
 Это были Алексеев, Борисов, Константинов и Дмитриев.
 Оказалось, что каждый из них взял с собой книгу, написанную одним из пассажиров этого купе.
 Алексеев и Борисов углубились в чтение, предварительно обменявшись купленными книгами.
 Поэт читал пьесу. Прозаик, очень молодой человек, выпустивший свою первую книгу, говорил, что он никогда ничего не читает по астрономии.
 Борисов купил в дорогу одно из произведений Дмитриева.
 Никто из пассажиров не покупал и не читал книги, написанные им самим.
 Что читал каждый из них? Кто кем был?
*/
man(alekseev).
man(borisov).
man(konstantinov).
man(dmitriev).

book(astronomy).
book(poetry).
book(prose).
book(piece).

no_repetitions([]):-!.
no_repetitions([Head|Tail]):-
   member(Head, Tail), !, fail;
   no_repetitions(Tail).

solve(Solve):-
  Solve = [passenger(X, XRead, XBuy, XWrite), passenger(Y, YRead, YBuy, YWrite),
          passenger(Z, ZRead, ZBuy, ZWrite), passenger(W, WRead, WBuy, WWrite)],

  % 4 разных пасажира
  man(X), man(Y), man(Z), man(W), no_repetitions([X, Y, Z, W]),

  % каждый написал книгу
  book(XWrite), book(YWrite),
  book(ZWrite), book(WWrite),
  no_repetitions([XWrite, YWrite, ZWrite, WWrite]),

  % каждый купил книгу
  book(XBuy), book(YBuy),
  book(ZBuy), book(WBuy),
  no_repetitions([XBuy, YBuy, ZBuy, WBuy]),

  % каждый читает книгу
  book(XRead), book(YRead),
  book(ZRead), book(WRead),
  no_repetitions([XRead, YRead, ZRead, WRead]),

  % Никто не читал и не покупал свою книгу
  check(Solve),

  % Поэт читает пьесу
  member(passenger(_, piece, _, poetry), Solve),

  % Прозаик читает не астрономию
  not(member(passenger(_, astronomy, _, prose), Solve)),

  % прозаик не покупал астрономию
  not(member(passenger(_, _, astronomy, prose), Solve)),

  % Алексеев и Борисов обменялись книгами
  member(passenger(alekseev, AlekseevRead, AlekseevBuy, _), Solve),
  member(passenger(borisov, AlekseevBuy, AlekseevRead, _), Solve),

  % Борисов купил произведение Дмитриева
  member(passenger(dmitriev, _, _, DmitrievWrite), Solve),
  member(passenger(borisov, DmitrievWrite, _, _), Solve).

check([]):-!.
check([passenger(_, XRead, XBuy, XWrite)|T]):-
  check(T),!,not(XRead = XWrite), not(XBuy = XWrite).
