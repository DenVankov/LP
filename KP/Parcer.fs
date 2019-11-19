open System.IO

// GEDCOM -> parent(par, child), sex(humn, m/f)

type Person = {
    mutable Name    : string
    mutable Surname : string
    mutable ID      : string
    }

type Family = {
    mutable IDfather    : string
    mutable IDmother    : string
    mutable IDchildren  : string[]
    }

    // "<-" - так тут выполняется присваивание

[<EntryPoint>]
let main argv =

    let readLines filePath = System.IO.File.ReadAllLines(filePath) /// Функция, считывающая все строки в массив строк
    let rL = readLines @"/home/hvidsmen/Загрузки/550728731_1_DF_w35e8z28wbbf005j.ged" // Собственно запускаем эту функцию
    
    let findPerson(lines : string[]) = /// Функция, ищущая ОДНОГО человека в массиве строк
        let person = { Name = ""; Surname = ""; ID = "" } // Создаём изначально пустого человека
        let mutable i = 0 // Итератор
        let mutable notFound = true // Флаг, нашли мы или нет
        while i < lines.Length - 1 && notFound do // Проходимся по всему массиву
            if lines.[i].Contains("2 GIVN") then // Если начинается с "2 GIVN"
                person.Name <- lines.[i].[7 ..] // То мы нашли имя
                notFound <- false // Меняем флаг, чтобы выйти из цикла 
            i <- i + 1
        i <- 0 // Возвращаем счетчик на начало, чтобы найти фамилию
        notFound <- true // Флаг тоже
        while i < lines.Length - 1 && notFound do // Проходимся по всему массиву
            if lines.[i].Contains("2 SURN") then // Если начинается с "2 SURN"
                person.Surname <- lines.[i].[7 ..] // То мы нашли фамилию
                notFound <- false
            i <- i + 1
        i <- 0 // Опять возвращаеем счетчик и флаг
        notFound <- true
        while i < lines.Length - 1 && notFound do // Теперь ищём айдишник
            if lines.[i].Contains("0 @I") then // Если начинается на "0 @I", то это айди человека
                let mutable j = 3
                while not (lines.[i].[j] = '@') do // Ищем, где в строке находится ешё один символ @, (конец айди)
                    j <- j + 1
                person.ID <- lines.[i].[3 .. j-1] // Нашли айди
                notFound <- false
            i <- i + 1
        person // Возвращаем нашу структуру

    let findPeople (lines:string[]) = /// Функция, которая ищет ВСЕХ людей в массиве строк
        [| // Говорим, что создаем массив
            let mutable start = 0 // Разделяем массив на части при помощи start и finish
            let mutable finsih = 0
            let mutable first = true
            for i in 0 .. lines.Length - 1 do
                if lines.[i].Contains("0 @I") && not first then
                    finsih <- i
                    let person = findPerson lines.[start .. finsih] // Запускаем предыущую функцию, только на части массива
                    start <- finsih
                    yield person // Того человека, которого мы сделали, оставляем в массиве
                if lines.[i].Contains("0 @I") && first then // Первый раз мы пропускаем
                    first <- false
            finsih <- lines.Length - 1 // Нужно ещё найти последнего человека
            let person = findPerson lines.[start .. finsih]
            yield person
            |] // Так как больше в функции ничего нет, то она возвращает массив, который мы сделали

    let findFamily (lines:string[]) =  /// Функция, которая ищет ОДНУ семью в массиве строк
        let family = { IDfather = ""; IDmother = ""; IDchildren = [||] } // Создаем пустую семью
        let mutable i = 0
        let mutable notFound = true
        while i < lines.Length - 1 && notFound do // Логика работы та же, что и при поиске одного человека
            if lines.[i].Contains("1 HUSB") then
                let mutable j = 8
                while not (lines.[i].[j] = '@') do // Находим айди мужа
                    j <- j + 1
                family.IDfather <- lines.[i].[8 .. j-1]
                notFound <- false
            i <- i + 1
        if lines.[i].Contains("1 WIFE") then
            let mutable j = 8
            while not (lines.[i].[j] = '@') do // Ищем айди жены
                j <- j + 1
            family.IDmother <- lines.[i].[8 .. j-1]
        i <- i + 1
        let mutable fin = false
        while not fin && i < lines.Length - 1 do  // До конца ищем айди детей
            if lines.[i].Contains("1 CHIL") then
                let mutable j = 8
                while not (lines.[i].[j] = '@') do
                    j <- j + 1
                family.IDchildren <- Array.append family.IDchildren [|lines.[i].[8 .. j-1]|] // Добавляем к массиву детей ребенка, которого мы сейчас нашли
            else 
                fin <- true
            i <- i + 1
        family // Возвращаем семью

    let findFamilies (lines:string[]) = /// Функция поиска ВСЕХ семей, логика работы та же, что и при поиске всех Людей
        [|
            let mutable start = 0
            let mutable finish = 0
            let mutable first = true
            for i in 0 .. lines.Length - 1 do
                if lines.[i].Contains("0 @F") && not first then
                    finish <- i
                    let family = findFamily lines.[start .. finish]
                    start <- finish
                    yield family
                if lines.[i].Contains("0 @F") && first then // Так же пропускаем первое нахождение
                    first <- false
            finish <- lines.Length - 1
            let family = findFamily lines.[start .. finish] // Так же ищем последнее вхождение
            yield family
            |]

    let people = findPeople rL // Ищем всех людей
    for person in people do
        printfn "%s %s %s" person.Name person.Surname person.ID // Вывод людей
    let families = findFamilies rL // Ищем все семьи
    for family in families do 
        printfn "%s %s %A" family.IDfather family.IDmother family.IDchildren // Вывод семей
    use streamWriter = new StreamWriter(@"/home/hvidsmen/Загрузки/Data.pl", false) // В файл выведем наши предикаты
    for family in families do // Для каждой семьи
        let mutable fatherName = ""
        let mutable fatherSurn = ""
        for person in people do
                if person.ID = family.IDfather then // Ищем отца
                    fatherName <- person.Name
                    fatherSurn <- person.Surname
        
        let mutable motherName = ""
        let mutable motherSurn = ""
        for person in people do
            if person.ID = family.IDmother then // Ищем мать
                motherName <- person.Name
                motherSurn <- person.Surname
         
        for child in family.IDchildren do // Для каждого ребенка находим отца и мать
            for person in people do
                if person.ID = child then
                    let mutable fatherString = "parent(" + fatherSurn + fatherName + ", " + person.Surname + person.Name + ")."
                    let mutable maleString = "sex(" + fatherSurn + fatherName + ", m)."

                    let mutable motherString = "parent(" + motherSurn + motherName + ", " + person.Surname + person.Name + ")."
                    let mutable femaleString = "sex(" + motherSurn + motherName + ", f)."

                    printfn "%s" fatherString // Выводим предикат
                    printfn "%s" maleString
                    printfn "%s" motherString
                    printfn "%s" femaleString
                    streamWriter.WriteLine(fatherString) // Записываем в файл
                    streamWriter.WriteLine(maleString)
                    streamWriter.WriteLine(motherString)
                    streamWriter.WriteLine(femaleString)

    0 // возвращение целочисленного кода выхода
