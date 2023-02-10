﻿#Область ВспомогательныеФункций

//ПрочитатьCSVФайлВТаблицу () импортирует данные в ТЗ из текста в формате CSV
//Параметры:
//ИмяФайла 		- Файл, содержащий текст в формате csv
//Разделитель 	- Для формата CSV разделителем является ',', но т.к. 
//				  Excel берет разделитель из региональных стандартов, то
//				  используется ';'
//
&НаСервереБезКонтекста
Функция ПрочитатьCSVФайлВТаблицу(ИмяФайла, Разделитель=";", КоличествоПервыхСтрокПропустить = 0, КоличествоКолонок = Неопределено)
		
	ЧтениеТекста = Новый ЧтениеТекста(ИмяФайла);
	
	ТЗ = Новый ТаблицаЗначений;
	Колонки = ТЗ.Колонки;
	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка");
	
	Если КоличествоКолонок <> Неопределено Тогда
		Для НомерКолоки = 1 По КоличествоКолонок Цикл
			Колонки.Добавить("Колонка"+НомерКолоки, ОписаниеТиповСтрока);
		КонецЦикла;
	КонецЕсли;
	
	НомерСтроки = 1;
	Стр = ЧтениеТекста.ПрочитатьСтроку();
	Пока Стр <> Неопределено Цикл
		Если НомерСтроки < 1 + КоличествоПервыхСтрокПропустить Тогда
			Стр = ЧтениеТекста.ПрочитатьСтроку();
			НомерСтроки = НомерСтроки + 1;
			Продолжить;
		КонецЕсли; 
		СтрокаТЗ = ТЗ.Добавить();
		НомерПоля = 0;
		Пока Стр <> "" Цикл
			Токен = "";
			ПозицияРазделителя = Найти(стр, Разделитель);
			ПозицияОткрКавычек = Найти(стр, """");
			//"";""
			Если ПозицияОткрКавычек > 1 И Сред(стр, ПозицияОткрКавычек-1, 1) <> Разделитель Тогда
				ПозицияОткрКавычек = 0;
			КонецЕсли;
			Если (ПозицияРазделителя > ПозицияОткрКавычек ИЛИ ПозицияРазделителя = 0) И ПозицияОткрКавычек > 0 Тогда
				// начинающееся с кавычек читаем до тех пор
				Токен = Лев(Стр, ПозицияОткрКавычек);
				Стр = Сред(Стр, ПозицияОткрКавычек+1);
				ПозицияДляПоискаЗакрКавычек = 1;
				ПозицияЗакрКавычек = 0;
				Пока ПозицияЗакрКавычек = 0 Цикл
					Если СтрДлина(Стр) >= ПозицияДляПоискаЗакрКавычек Тогда
					ПозицияЗакрКавычек = СтрНайти(Стр, """",,ПозицияДляПоискаЗакрКавычек);
					КонецЕсли;
					
					Если ПозицияЗакрКавычек > 0 И Сред(Стр,ПозицияЗакрКавычек + 1, 1) = """" Тогда
						ПозицияДляПоискаЗакрКавычек = ПозицияЗакрКавычек + 2;
						ПозицияЗакрКавычек = 0;
						Продолжить; //это просто экранированная кавычка, а не кавычка закрывающее поле
					ИначеЕсли ПозицияЗакрКавычек > 0 Тогда
						Прервать;
					Иначе
						Токен = Токен + Стр + Символы.ПС;
						НомерСтроки = НомерСтроки + 1;
						Стр = ЧтениеТекста.ПрочитатьСтроку();
						Если Стр = Неопределено Тогда
							Стр = "";
							Прервать; // файл закончился, закрывающую кавычку не нашли
						КонецЕсли; 		
						ПозицияДляПоискаЗакрКавычек = 1; // ищем с начала новой, полученной строки
					КонецЕсли;
										
				КонецЦикла;
				
				Если СтрДлина(Стр) > ПозицияЗакрКавычек Тогда 
					ПозицияРазделителя=СтрНайти(Стр, Разделитель,,ПозицияЗакрКавычек + 1);
				Иначе
					ПозицияРазделителя = 0;
				КонецЕсли;
			КонецЕсли;
			
			Если ПозицияРазделителя>0 Тогда
				Токен = Токен + Лев(Стр, ПозицияРазделителя-1);
				Стр = Сред(Стр, ПозицияРазделителя+1);
			Иначе
				Токен = Токен + Стр; // разделитель не нашли, добавляем оставшуюся часть строки
				Стр = ""; // строка полностью обработана
			КонецЕсли;
			
			// Уберем экранирующие кавычки у поля, если они там были
			Если Лев(Токен, 1) = """" Тогда
				Токен = Сред(Токен, 2);
				Токен = ?(Прав(Токен, 1) = """", Лев(Токен, СтрДлина(Токен)-1), Токен);
			КонецЕсли;
						
			// убираем двойные кавычки 
			Токен = СтрЗаменить(Токен, """""", """");
			
			НомерПоля = НомерПоля + 1;
			Если КоличествоКолонок = Неопределено Тогда
				Если Колонки.Количество()<НомерПоля Тогда
					Колонки.Добавить("Колонка"+НомерПоля, ОписаниеТиповСтрока);
				КонецЕсли;
			ИначеЕсли НомерПоля > КоличествоКолонок Тогда
				Прервать;
			КонецЕсли;
			СтрокаТЗ[НомерПоля-1] = Токен;
			
		КонецЦикла;
		НомерСтроки = НомерСтроки + 1;
		Стр = ЧтениеТекста.ПрочитатьСтроку();
	КонецЦикла;
	
	ЧтениеТекста.Закрыть();
	
	Возврат ТЗ; 
КонецФункции

//ПреобразоватьТЗвТекстCSV () экспортирует данные ТЗ в текст в формате CSV
//Параметры:
//ТЗ 			- Таблица значений данные которые сохраняются в файл
//флЭкспортироватьИменаКолонок - Первой строкой выводить имена колонок
//Разделитель 	- Для формата CSV разделителем является ',', но т.к. 
//				  Excel берет разделитель из региональных стандартов, то
//				  используется ';'
//
&НаСервереБезКонтекста
Функция ПреобразоватьТЗвТекстCSV(ТЗ, Разделитель = ";", флЭкспортироватьИменаКолонок = Ложь) Экспорт
		
	ТекстCSV = "";
	
	Если флЭкспортироватьИменаКолонок Тогда
		//Если нужно выгружать наименование колонок Выгружаем
		ПодготовленнаяСтрока = "";
		Для Каждого Колонка Из ТЗ.Колонки Цикл
			ПодготовленнаяСтрока = ПодготовленнаяСтрока + Колонка.Имя + Разделитель;
		КонецЦикла;
		ПодготовленнаяСтрока = Лев (ПодготовленнаяСтрока,СтрДлина(ПодготовленнаяСтрока)-1);
		
		ТекстCSV = ТекстCSV + ПодготовленнаяСтрока + Символы.ПС;
	КонецЕсли;
	
	Для Каждого Строка Из ТЗ Цикл
        ПодготовленнаяСтрока = "";
        Для Каждого Колонка Из ТЗ.Колонки Цикл
            ПреобразованноеПоле = Строка[Колонка.Имя];
            //по правилам CSV если поле содержит перенос строки или запятую оно должно заключатся в двойные кавычки
            Если Найти(ПреобразованноеПоле,Разделитель) ИЛИ Найти(ПреобразованноеПоле,Символы.ПС) Тогда 
                //ИЛИ Найти(ПреобразованноеПоле,"""") Тогда
                ПреобразованноеПоле = """" + ПреобразованноеПоле + """";
            КонецЕсли;
            //по правилам CSV если поле содержит двойные кавычки они должны повторятся дважды
            Если Найти(ПреобразованноеПоле,"""") Тогда
                ПреобразованноеПоле = СтрЗаменить(ПреобразованноеПоле,"""","""""");
            КонецЕсли;
            
            ПодготовленнаяСтрока = ПодготовленнаяСтрока + """" + ПреобразованноеПоле + """"+ Разделитель;
        КонецЦикла;
        ПодготовленнаяСтрока = Лев (ПодготовленнаяСтрока,СтрДлина(ПодготовленнаяСтрока)-1);
        
        ТекстCSV = ТекстCSV + ПодготовленнаяСтрока + Символы.ПС;
    КонецЦикла;

	Возврат ТекстCSV;
КонецФункции

// Функция возвращает ТабличныйДокумент с данными файла.
//
&НаКлиенте
Функция ПрочитатьCSV_ADO(ИмяФайла, Разделитель=",")
	ТабДок = Новый ТабличныйДокумент;
	Файл = Новый Файл(ИмяФайла);
	
	Connection=Новый COMОбъект("ADODB.Connection");
	Connection.Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source="+Файл.Путь+";Extended Properties=""text;HDR=No;IMEX=1;FMT=Delimited""");

	RecordSet=Новый COMОбъект("ADODB.Recordset");
	RecordSet.ActiveConnection = Connection;
	
	RecordSet.Open("select * from "+Файл.Имя, Connection);
	
	сч=0;
	Пока НЕ RecordSet.EOF() Цикл
		сч=сч+1;
		
		Для й=0 по RecordSet.Fields.Count-1 Цикл
			ТабДок.Область(сч, й+1).Текст = RecordSet.Fields(й).Value;
		КонецЦикла;
		Если сч%1000=0 Тогда	// ~ 1000 в секунду
			Состояние(""+сч+" ...");
			ОбработкаПрерыванияПользователя();
		КонецЕсли;
		RecordSet.MoveNext();
	КонецЦикла;
	
	RecordSet.Close();
	Connection.Close();
	Возврат ТабДок;
КонецФункции

// Функция возвращает ТаблицуЗначений с данными файла.
//
// Источник: http://forum.script-coding.com/viewtopic.php?id=5664
//
&НаСервере
Функция ПрочитатьCSV_GWF(ИмяФайла)
	Файл = Новый Файл(ИмяФайла);

	// Schema.ini уже должен быть подготовлен
    objRec = Новый COMОбъект("ADODB.Recordset");
    strQuery = "SELECT * FROM [" + Файл.Имя + "]";
    strConn = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + Файл.Путь + ";Extended Properties=""text;HDR=No""";
    adOpenStatic = 3;
    adLockOptimistic = 3;
    adCmdText = 1;
    objRec.Open(strQuery, strConn, adOpenStatic, adLockOptimistic, adCmdText);
    
    Если ПодключитьВнешнююКомпоненту("GameWithFire.ADOUtils") Тогда
	    ADOUtils = Новый("AddIn.ADOUtils");
	    Возврат ADOUtils.ADORecordsetToValueTable(objRec);	// ~ 3000 в сек
	Иначе
		Сообщить("Не удалось подключить компоненту GameWithFire");
		Возврат Новый ТаблицаЗначений;
	КонецЕсли;
КонецФункции

&НаКлиенте
Процедура ПрочитатьФайл(ИмяФайла, ТекстФайла)
	ЧтениеТекста = Новый ЧтениеТекста(ИмяФайла);
	ТекстФайла = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьФайл(ИмяФайла, ТекстФайла)
	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.ANSI);
	ЗаписьТекста.Записать(ТекстФайла);
	ЗаписьТекста.Закрыть();
КонецПроцедуры

#КонецОбласти

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	// тесты
	Тесты = "";
	Тесты = Тесты + Символы.ПС + """ZF6A-11"";"""";""""";
	Тесты = Тесты + Символы.ПС + """Прокладка выпускного коллектора металлическая"";""190016010;3056046;31-024515-00;693.820;70-25112-00;71-24068-10;71-34208-00;JE138;JF206;0693820;078 253 039;103 632;103 632 015;103632685;103 633;103 633 016;1257319;256905;29-0078;302530115433;30694/1507;343412;433253115;433253115;433253115A;433253115A;460052;51157;70-24068-00;71-24068-00;AG7524;"";""AUDI-PEGASO-VOLKSWAGEN-VOLVO  #  1978->  #   DV,DW,CP,1S,1G,ACT,D24,D24T,D24TIC     1595/1781/2383 cc    DIESEL""";
	Тесты = Тесты + Символы.ПС + "ACDelco;OPEL Astra J/Insignia /для 17""диска;2357.00";
	//ДобавитьТест("a", Рез("a"));
	//ДобавитьТест("a,b;c", Рез("a,b","c"));
	//ДобавитьТест("a;b\nc", Рез("a","b"), Рез("c"));
	Тесты = Тесты + Символы.ПС + "a";
	Тесты = Тесты + Символы.ПС + "a,b;c";
	Тесты = Тесты + Символы.ПС + "a;b\nc";
	Тесты = Тесты + Символы.ПС + """a;b"";c";
	Тесты = Тесты + Символы.ПС + """a""""b"";c";
	Тесты = Тесты + Символы.ПС + """"""""";c";
	Тесты = Тесты + Символы.ПС + """;"";c";
	Тесты = Тесты + Символы.ПС + ";";
	Тесты = Тесты + Символы.ПС + "a;""b\nc"";d";
	Тесты = Тесты + Символы.ПС + "a;""b\nc;\n\nd;;\ne"";d";
	Тесты = Тесты + Символы.ПС + "a;""b""""\nc"""""";d";
	// неправильный формат
	Тесты = Тесты + Символы.ПС + "a;""b\n""с""";
	Тесты = Тесты + Символы.ПС + "a;""""b;"";""";
	// тест rise
	Тесты = Тесты + Символы.ПС + "aaa;"""";""ccc""";

	ТекстCSV = СтрЗаменить(СокрЛП(Тесты), "\n", Символы.ПС);
	
	// инициализируем таблицу на форме
	тз = Новый ТаблицаЗначений;
	тз.Колонки.Добавить("Колонка1");
	тз.Колонки.Добавить("Колонка2");
	тз.Колонки.Добавить("Колонка3");
	тз.Добавить();
	
	//ТабДок0 = ДанныеТаблицыЗначенийВТабличныйДокумент();
	//ВывестиТаблицуНаФорму(ЭтаФорма, "ТаблицаCSV", тз);
	
	Если ПустаяСтрока(ЭтаФорма.Разделитель) Тогда
		ЭтаФорма.Разделитель = ";";
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПутьФайла_ПриИзменении();
КонецПроцедуры

&НаКлиенте
Процедура ПутьФайлаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	Режим = РежимДиалогаВыбораФайла.Открытие;
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(Режим);
	ДиалогОткрытияФайла.ПолноеИмяФайла = "";
	Фильтр = "Текст CSV (*.csv)|*.csv";
	ДиалогОткрытияФайла.Фильтр = Фильтр;
	ДиалогОткрытияФайла.МножественныйВыбор = Ложь;
	ДиалогОткрытияФайла.Заголовок = "Выберите файл";
	Если ДиалогОткрытияФайла.Выбрать() Тогда
		ФайлДанных = Новый Файл(ДиалогОткрытияФайла.ПолноеИмяФайла);
		Если Найти(ФайлДанных.Имя, "-") ИЛИ
			Найти(ФайлДанных.Имя, " ") Тогда
			Предупреждение("В имени файла не дожно быть тире, пробелов и прочих недопустимых символов (как в имени переменной)!");
		Иначе
	    	ЭтаФорма.ПутьФайла = ДиалогОткрытияФайла.ПолноеИмяФайла;
			ПутьФайла_ПриИзменении();
		КонецЕсли;
	КонецЕсли; 

КонецПроцедуры

&НаКлиенте
Процедура Разделитель1ПриИзменении(Элемент)
	ПутьФайла_ПриИзменении();
КонецПроцедуры

&НаСервере
Процедура ПутьФайла_ПриИзменении()
	ФайлДанных = Новый Файл(ЭтаФорма.ПутьФайла);
	ФайлСхемы = Новый Файл(ФайлДанных.Путь+"Schema.ini");
	ЭтаФорма.Схема = "[" + ФайлДанных.Имя+ "]
    |ColNameHeader=False
    |Format=Delimited("+ЭтаФорма.Разделитель+")
    //|TextDelimiter=none
    |CharacterSet=ANSI
    |";
	
	Если Разделитель = "," Тогда
		ЭтаФорма.Схема = "[" + ФайлДанных.Имя+ "]";
	КонецЕсли;	
КонецПроцедуры

&НаСервере
Процедура КомандаПреобразоватьCSVвТЗНаСервере()
	ИмяВремФайла = ПолучитьИмяВременногоФайла(".csv");
	ТекстДокумент = Новый ТекстовыйДокумент;
	ТекстДокумент.УстановитьТекст(ТекстCSV);
	ТекстДокумент.Записать(ИмяВремФайла);
	
	Время1 = ТекущаяУниверсальнаяДатаВМиллисекундах();
	тз = ПрочитатьCSVФайлВТаблицу(ИмяВремФайла, Разделитель);
	Время2 = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	УдалитьФайлы(ИмяВремФайла);
	ТабДок0 = ДанныеТаблицыЗначенийВТабличныйДокумент(тз);
	
	Элементы.Декорация6.Заголовок = "Считано записей:" + тз.Количество() + " Время, мс: " + (Время2-Время1);
		СкоростьЧтения = Цел(тз.Количество() / (Время2-Время1) * 1000); // строк в секунду
		Элементы.Декорация7.Заголовок = СтрШаблон("~ %1 строк в секунду для %2 колонок",СкоростьЧтения,тз.Колонки.Количество());
КонецПроцедуры

&НаКлиенте
Процедура КомандаПреобразоватьCSVвТЗ(Команда)
	КомандаПреобразоватьCSVвТЗНаСервере();
КонецПроцедуры

&НаСервере
Процедура КомандаПреобразоватьТЗвCSVНаСервере()
	тз = РеквизитФормыВЗначение("ТаблицаCSV");
	ТекстCSV = ПреобразоватьТЗвТекстCSV(тз, Разделитель);
КонецПроцедуры

&НаКлиенте
Процедура КомандаПреобразоватьТЗвCSV(Команда)
	КомандаПреобразоватьТЗвCSVНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура КомандаПрочитатьADO(Команда)
	
	// подготовим Schema.ini
	ФайлДанных = Новый Файл(ЭтаФорма.ПутьФайла);
	ФайлСхемы = Новый Файл(ФайлДанных.Путь+"Schema.ini");
	ЗаписатьФайл(ФайлСхемы.ПолноеИмя, ЭтаФорма.Схема);
	
	ЭтаФорма.ТабДок = ПрочитатьCSV_ADO(ЭтаФорма.ПутьФайла);
		
		КомандаПрочитатьADOНаСервере(ЭтаФорма.ПутьФайла);
КонецПроцедуры

&НаСервере
Процедура КомандаПрочитатьADOНаСервере(ПутьФайла)
	Время1 = ТекущаяУниверсальнаяДатаВМиллисекундах();
	тз = ПрочитатьCSVвТЗ_ADO(ПутьФайла);
	Время2 = ТекущаяУниверсальнаяДатаВМиллисекундах();
	//Сообщить("ADODB "+(Время2-Время1)+" мс");
		
	Элементы.Декорация4.Заголовок = "Считано записей:" + тз.Количество() + " Время, мс: " + (Время2-Время1);
	
		// 5123 строк за 2345 мс
		// тогда 5123 / 2345 * 1000
		СкоростьЧтения = Цел(тз.Количество() / (Время2-Время1) * 1000); // строк в секунду
		Элементы.Декорация5.Заголовок = СтрШаблон("~ %1 строк в секунду для %2 колонок",СкоростьЧтения,тз.Колонки.Количество());
КонецПроцедуры

&НаСервере
Функция ПрочитатьCSVвТЗ_ADO(ИмяФайла, Разделитель=";", ЗаголовкиИзПервойСтроки = Ложь)
	ТаблицаРезультат = Новый ТаблицаЗначений;
	Файл = Новый Файл(ИмяФайла);
	
	Connection=Новый COMОбъект("ADODB.Connection");
	Connection.Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source="+Файл.Путь+";Extended Properties=""text;HDR=No;IMEX=1;FMT=Delimited""");
	//Connection.Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source="+Файл.Путь+";Extended Properties=""text;HDR=Yes;FMT=Delimited""");

	// Так как FMT=Delimited(;) не работает создадим schema.ini 
	//Схема = СтрШаблон("[%1]
	//	|ColNameHeader=%2
	//	|Format=Delimited(%3)", Файл.Имя, Формат(ЗаголовкиИзПервойСтроки, "БЛ=False; БИ=True"), Разделитель);
	//ФайлСхемы = Новый ТекстовыйДокумент;
	//ФайлСхемы.УстановитьТекст(Схема);
	//ФайлСхемы.Записать(Файл.Путь + "Schema.ini", "CESU-8"); // UTF-8 без BOM
	
	RecordSet=Новый COMОбъект("ADODB.Recordset");
	RecordSet.ActiveConnection = Connection;
	
	RecordSet.Open("select * from "+Файл.Имя, Connection);
	
	// определим имена колонок
	Для НомерКолонки = 0 по RecordSet.Fields.Count-1 Цикл
		ТаблицаРезультат.Колонки.Добавить(RecordSet.Fields(НомерКолонки).Name);
	КонецЦикла;
	
	Сч=0;
	Пока НЕ RecordSet.EOF() Цикл
		Сч=Сч+1;
		
		НоваяСтрока = ТаблицаРезультат.Добавить();
		Для й=0 по RecordSet.Fields.Count-1 Цикл
			НоваяСтрока[й] = RecordSet.Fields(й).Value;
		КонецЦикла;
		
		RecordSet.MoveNext();
	КонецЦикла;
	
	RecordSet.Close();
	Connection.Close();
	Возврат ТаблицаРезультат;
КонецФункции

&НаСервере
Процедура КомандаПрочитатьGWFНаСервере()
	#Если ТолстыйКлиентОбычноеПриложение ИЛИ ТолстыйКлиентУправляемоеПриложение Тогда
		Время1 = ТекущаяУниверсальнаяДатаВМиллисекундах();
		
		тз = ПрочитатьCSV_GWF(ЭтаФорма.ПутьФайла);
		
		Время2 = ТекущаяУниверсальнаяДатаВМиллисекундах();
		//Сообщить("GWF "+(Время2-Время1)+" мс");
		
		КС = Новый КвалификаторыСтроки(20);
		Массив = Новый Массив;
		Массив.Добавить(Тип("Строка"));
		ОписаниеТиповС = Новый ОписаниеТипов(Массив, , КС);

		Таблица = Новый ТаблицаЗначений;
		Для Каждого ТекКолонка Из тз.Колонки Цикл
			Таблица.Колонки.Добавить(ТекКолонка.Имя, ОписаниеТиповС);
		КонецЦикла;
		Для Каждого ТекСтрока Из тз Цикл
			НоваяСтрока = Таблица.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, ТекСтрока);
		КонецЦикла;

		ТабДок2 = ДанныеТаблицыЗначенийВТабличныйДокумент(Таблица);
		
		// 5123 строк за 2345 мс
		// тогда 5123 / 2345 * 1000
		СкоростьЧтения = Цел(Таблица.Количество() / (Время2-Время1) * 1000); // строк в секунду
		Элементы.Декорация1.Заголовок = "Считано записей:" + тз.Количество() + " Время, мс: " + (Время2-Время1);
		Элементы.Декорация3.Заголовок = СтрШаблон("~ %1 строк в секунду для %2 колонок",СкоростьЧтения,Таблица.Колонки.Количество());
	#Иначе
		Сообщить("Компонента GameWithFire работает только в толстом клиенте!");
	#КонецЕсли
КонецПроцедуры

&НаКлиенте
Процедура КомандаПрочитатьGWF(Команда)
	
	// подготовим Schema.ini
	ФайлДанных = Новый Файл(ЭтаФорма.ПутьФайла);
	ФайлСхемы = Новый Файл(ФайлДанных.Путь+"Schema.ini");
	ЗаписатьФайл(ФайлСхемы.ПолноеИмя, ЭтаФорма.Схема);
	
	КомандаПрочитатьGWFНаСервере();
КонецПроцедуры

&НаСервере
Процедура КомандаПрочитать1СНаСервере()
	Время1 = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	тз = ПрочитатьCSVФайлВТаблицу(ПутьФайла, Разделитель);
	
	Время2 = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	//Сообщить("Native "+(Время2-Время1)+" мс");
	
	ТабДок0 = ДанныеТаблицыЗначенийВТабличныйДокумент(тз);
	
	Элементы.Декорация6.Заголовок = "Считано записей:" + тз.Количество() + " Время, мс: " + (Время2-Время1);
		СкоростьЧтения = Цел(тз.Количество() / (Время2-Время1) * 1000); // строк в секунду
		Элементы.Декорация7.Заголовок = СтрШаблон("~ %1 строк в секунду для %2 колонок",СкоростьЧтения,тз.Колонки.Количество());
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПрочитать1С(Команда)
	КомандаПрочитать1СНаСервере();
КонецПроцедуры


// Возвращает табличный документ на основании таблицы значений
//
// Параметры:
//  ДанныеВТабличныйДокумент - ТаблицаЗначений
//
&НаСервереБезКонтекста
Функция ДанныеТаблицыЗначенийВТабличныйДокумент(ДанныеВТабличныйДокумент)
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	Построитель = Новый ПостроительОтчета;
	Построитель.ИсточникДанных = Новый ОписаниеИсточникаДанных(ДанныеВТабличныйДокумент);       
	Построитель.Вывести(ТабличныйДокумент);
		
	Возврат ТабличныйДокумент;

КонецФункции // ДанныеТаблицыЗначенийВТабличныйДокумент()