
#Область Парсер

Функция Разобрать(ЧтениеXML, Виды, Вид, ЧитатьВСоответствие = Ложь) Экспорт
	//Пока ТипЗнч(Вид) = Тип("Строка") Цикл
	//	Вид = Виды[Вид];
	//КонецЦикла;
	Данные = Неопределено;
	Если ТипЗнч(Вид) = Тип("Map") Тогда
		Данные = РазобратьСтруктуру(ЧтениеXML, Виды, Вид, ЧитатьВСоответствие);
	ИначеЕсли ТипЗнч(Вид) = Тип("Структура") Тогда
		Данные = РазобратьОбъект(ЧтениеXML, Виды, Вид, ЧитатьВСоответствие);
	Иначе
		ЧтениеXML.Прочитать(); // node val | node end
		Если ЧтениеXML.ТипУзла <> XMLNodeType.КонецЭлемента Тогда
			Если ТипЗнч(Вид) = Тип("ОписаниеТипов") Тогда  // basic
				Данные = Вид.ПривестиЗначение(ЧтениеXML.Значение);
			Иначе  // enum
				Данные = Вид[ЧтениеXML.Значение];
			КонецЕсли;
			ЧтениеXML.Прочитать();		 // node end
		КонецЕсли;
	КонецЕсли;
	Возврат Данные;
КонецФункции // Разобрать()

Функция РазобратьСтруктуру(ЧтениеXML, Виды, Вид, ЧитатьВСоответствие)
	Объект = ?(ЧитатьВСоответствие, Новый Соответствие, Новый Структура);
	Пока ЧтениеXML.ReadAttribute() Цикл
		ИмяАтрибута = ЧтениеXML.LocalName;
		ВидАтрибута = Вид[ИмяАтрибута];
		Если ВидАтрибута <> Неопределено Тогда
			Объект.Вставить(ИмяАтрибута, ВидАтрибута.ПривестиЗначение(ЧтениеXML.Value));
		КонецЕсли;
	КонецЦикла;
	Пока ЧтениеXML.Прочитать() // node beg | parent end | none
		And ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Цикл
		ИмяСвойства = ЧтениеXML.LocalName;
		ВидСвойства = Вид[ИмяСвойства];
		Если ВидСвойства = Неопределено Тогда
			ЧтениеXML.Пропустить();
		Иначе
			Объект.Вставить(ИмяСвойства, Разобрать(ЧтениеXML, Виды, ВидСвойства, ЧитатьВСоответствие));
		КонецЕсли;
	КонецЦикла;
	Если ЧтениеXML.ТипУзла = ТипУзлаXML.Текст Тогда
		ИмяСвойства = "_"; // noname
		ВидСвойства = Вид[ИмяСвойства];
		Если ВидСвойства <> Неопределено Тогда
			Объект.Вставить(ИмяСвойства, ВидСвойства.AdjustValue(ЧтениеXML.Value));
		КонецЕсли;
		ЧтениеXML.Прочитать();	 // node end
	КонецЕсли;
	Возврат Объект;
КонецФункции // ParseRecord()

Функция РазобратьОбъект(ЧтениеXML, Виды, Вид, ЧитатьВСоответствие)
	Элементы = Вид.Элементы;
	Данные = ?(ЧитатьВСоответствие, Новый Соответствие, Новый Структура);
	Для Каждого Элемент Из Элементы Цикл
		Данные.Вставить(Элемент.Ключ, Новый Массив);
	КонецЦикла;
	Пока ЧтениеXML.Прочитать() // node beg | parent end | none
		И ЧтениеXML.NodeType = ТипУзлаXML.НачалоЭлемента Цикл
		ИмяЭлемента = ЧтениеXML.LocalName;
		ВидЭлемента = Элементы[ИмяЭлемента];
		Если ВидЭлемента = Неопределено Тогда
			ЧтениеXML.Skip();		 // node end
		Иначе
			Данные[ИмяЭлемента].Add(Разобрать(ЧтениеXML, Виды, ВидЭлемента, ЧитатьВСоответствие));
		КонецЕсли;
	КонецЦикла;
	Возврат Данные;
КонецФункции // РазобратьОбъект()

#КонецОбласти // Парсер

#Область Виды

Функция Виды() Экспорт

	Виды = Новый Структура;

	// basic
	Виды.Вставить("String", Новый ОписаниеТипов("String"));
	Виды.Вставить("Boolean", Новый ОписаниеТипов("Boolean"));
	Виды.Вставить("Decimal", Новый ОписаниеТипов("Number"));
	Виды.Вставить("UUID", "String");

	// simple
	Виды.Вставить("MDObjectRef", "String");
	Виды.Вставить("MDMethodRef", "String");
	Виды.Вставить("FieldRef", "String");
	Виды.Вставить("DataPath", "String");
	Виды.Вставить("IncludeInCommandCategoriesType", "String");
	Виды.Вставить("QName", "String");

	// common
	Виды.Вставить("LocalStringType", LocalStringType());
	Виды.Вставить("MDListType", MDListType());
	Виды.Вставить("FieldList", FieldList());
	Виды.Вставить("ChoiceParameterLinks", ChoiceParameterLinks());
	Виды.Вставить("TypeLink", TypeLink());
	Виды.Вставить("StandardAttributes", StandardAttributes());
	Виды.Вставить("StandardTabularSections", StandardTabularSections());
	Виды.Вставить("Characteristics", Characteristics());
	Виды.Вставить("AccountingFlag", AccountingFlag());
	Виды.Вставить("ExtDimensionAccountingFlag", ExtDimensionAccountingFlag());
	Виды.Вставить("AddressingAttribute", AddressingAttribute());
	Виды.Вставить("TypeDescription", TypeDescription());

	// metadata objects
	Виды.Вставить("MetaDataObject", MetaDataObject());
	Виды.Вставить("Attribute", Attribute());
	Виды.Вставить("Dimension", Dimension());
	Виды.Вставить("Resource", Resource());
	Виды.Вставить("TabularSection", TabularSection());
	Виды.Вставить("Command", Command());
	Виды.Вставить("Configuration", Configuration());
	Виды.Вставить("Language", Language());
	Виды.Вставить("AccountingRegister", AccountingRegister());
	Виды.Вставить("AccumulationRegister", AccumulationRegister());
	Виды.Вставить("BusinessProcess", BusinessProcess());
	Виды.Вставить("CalculationRegister", CalculationRegister());
	Виды.Вставить("Catalog", Catalog());
	Виды.Вставить("ChartOfAccounts", ChartOfAccounts());
	Виды.Вставить("ChartOfCalculationTypes", ChartOfCalculationTypes());
	Виды.Вставить("ChartOfCharacteristicTypes", ChartOfCharacteristicTypes());
	Виды.Вставить("CommandGroup", CommandGroup());
	Виды.Вставить("CommonAttribute", CommonAttribute());
	Виды.Вставить("CommonCommand", CommonCommand());
	Виды.Вставить("CommonForm", CommonForm());
	Виды.Вставить("CommonModule", CommonModule());
	Виды.Вставить("CommonPicture", CommonPicture());
	Виды.Вставить("CommonTemplate", CommonTemplate());
	Виды.Вставить("Constant", Constant());
	Виды.Вставить("DataProcessor", DataProcessor());
	Виды.Вставить("DocumentJournal", DocumentJournal());
	Виды.Вставить("DocumentNumerator", DocumentNumerator());
	Виды.Вставить("Document", Document());
	Виды.Вставить("Enum", Enum());
	Виды.Вставить("EventSubscription", EventSubscription());
	Виды.Вставить("ExchangePlan", ExchangePlan());
	Виды.Вставить("FilterCriterion", FilterCriterion());
	Виды.Вставить("FunctionalOption", FunctionalOption());
	Виды.Вставить("FunctionalOptionsParameter", FunctionalOptionsParameter());
	Виды.Вставить("HTTPService", HTTPService());
	Виды.Вставить("InformationRegister", InformationRegister());
	Виды.Вставить("Report", Report());
	Виды.Вставить("Role", Role());
	Виды.Вставить("ScheduledJob", ScheduledJob());
	Виды.Вставить("Sequence", Sequence());
	Виды.Вставить("SessionParameter", SessionParameter());
	Виды.Вставить("SettingsStorage", SettingsStorage());
	Виды.Вставить("Subsystem", Subsystem());
	Виды.Вставить("Task", Task());
	Виды.Вставить("Template", Template());
	Виды.Вставить("WebService", WebService());
	Виды.Вставить("WSReference", WSReference());
	Виды.Вставить("XDTOPackage", XDTOPackage());
	Виды.Вставить("Form", Form());

	// logform
	Виды.Вставить("LogForm", LogForm());
	Виды.Вставить("FormChildItems", FormChildItems());

	ЗаменитьСсылкиНаТипы(Виды, Виды);

	Возврат Виды;

КонецФункции // Виды()

Процедура ЗаменитьСсылкиНаТипы(Kinds, Object)
	Для Каждого Item Из Object Цикл
		Если ТипЗнч(Item.Value) = Тип("String") Тогда
			Object[Item.Key] = Kinds[Item.Value];
		ИначеЕсли ТипЗнч(Item.Value) = Тип("Map")
			Or ТипЗнч(Item.Value) = Тип("Structure") Тогда
			ЗаменитьСсылкиНаТипы(Kinds, Item.Value);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры // ЗаменитьСсылкиНаТипы()

Функция Структура(База = Неопределено)
	Структура = Новый Map;
	Если База <> Неопределено Тогда
		Для Каждого Элемент Из База Цикл
			Структура[Элемент.Ключ] = Элемент.Значение;
		КонецЦикла;
	КонецЕсли;
	Возврат Структура;
КонецФункции // Структура()

Функция Объект(База = Неопределено)
	Объект = Новый Структура("Элементы", Новый Соответствие);
	Если База <> Неопределено Тогда
		Для Каждого Элемент Из База.Элементы Цикл
			Объект.Элементы.Add(Элемент);
		КонецЦикла;
	КонецЕсли;
	Возврат Объект;
КонецФункции // Объект()

#КонецОбласти // Kinds

#Область Common

Функция LocalStringType()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["item"] = LocalStringTypeItem();
	Возврат Этот;
КонецФункции // LocalStringType()

Функция LocalStringTypeItem()
	Этот = Структура();
	Этот["lang"] = "String";
	Этот["content"] = "String";
	Возврат Этот;
КонецФункции // LocalStringTypeItem()

Функция MDListType()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Item"] = MDListTypeItem();
	Возврат Этот;
КонецФункции // MDListType()

Функция MDListTypeItem()
	Этот = Структура();
	Этот["type"] = "String";
	Этот["_"] = "String";
	Возврат Этот;
КонецФункции // MDListTypeItem()

Функция FieldList()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Field"] = FieldListItem();
	Возврат Этот;
КонецФункции // FieldList()

Функция FieldListItem()
	Этот = Структура();
	Этот["type"] = "String";
	Этот["_"] = "String";
	Возврат Этот;
КонецФункции // FieldListItem()

Функция ChoiceParameterLinks()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Link"] = ChoiceParameterLink();
	Возврат Этот;
КонецФункции // ChoiceParameterLinks()

Функция ChoiceParameterLink()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["DataPath"] = "String";
	Этот["ValueChange"] = "String"; // Enums.LinkedValueChangeMode;
	Возврат Этот;
КонецФункции // ChoiceParameterLink()

Функция TypeLink() // todo: check
	Этот = Структура();
	Этот["DataPath"] = "DataPath";
	Этот["LinkItem"] = "Decimal";
	Этот["ValueChange"] = "String"; // Enums.LinkedValueChangeMode;
	Возврат Этот;
КонецФункции // TypeLink()

Функция StandardAttributes()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["StandardAttribute"] = StandardAttribute();
	Возврат Этот;
КонецФункции // StandardAttributes()

Функция StandardAttribute()
	Этот = Структура();
	Этот["name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["ToolTip"] = "LocalStringType";
	Этот["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	//Этот["FillValue"]             = ;
	Этот["FillFromFillingValue"] = "String"; // Enums.Boolean;
	Этот["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//Этот["ChoiceParameters"]      = ;
	Этот["LinkByType"] = "TypeLink";
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["PasswordMode"] = "String"; // Enums.Boolean;
	Этот["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Этот["Format"] = "LocalStringType";
	Этот["EditFormat"] = "LocalStringType";
	Этот["Mask"] = "String";
	Этот["MultiLine"] = "String"; // Enums.Boolean;
	Этот["ExtendedEdit"] = "String"; // Enums.Boolean;
	//Этот["MinValue"]              = ;
	//Этот["MaxValue"]              = ;
	Этот["MarkNegatives"] = "String"; // Enums.Boolean;
	Этот["ChoiceForm"] = "MDObjectRef";
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Возврат Этот;
КонецФункции // StandardAttribute()

Функция StandardTabularSections()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["StandardTabularSection"] = StandardTabularSection();
	Возврат Этот;
КонецФункции // StandardTabularSections()

Функция StandardTabularSection()
	Этот = Структура();
	Этот["name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["ToolTip"] = "LocalStringType";
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	Этот["StandardAttributes"] = "StandardAttributes";
	Возврат Этот;
КонецФункции // StandardTabularSection()

Функция Characteristics()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Characteristic"] = Characteristic();
	Возврат Этот;
КонецФункции // Characteristics()

Функция Characteristic()
	Этот = Структура();
	Этот["CharacteristicTypes"] = CharacteristicTypes();
	Этот["CharacteristicValues"] = CharacteristicValues();
	Возврат Этот;
КонецФункции // Characteristic()

Функция CharacteristicTypes()
	Этот = Структура();
	Этот["from"] = "MDObjectRef";
	Этот["KeyField"] = "FieldRef";
	Этот["TypesFilterField"] = "FieldRef";
	//Этот["TypesFilterValue"] = ;
	Возврат Этот;
КонецФункции // CharacteristicTypes()

Функция CharacteristicValues()
	Этот = Структура();
	Этот["from"] = "MDObjectRef";
	Этот["ObjectField"] = "FieldRef";
	Этот["TypeField"] = "FieldRef";
	//Этот["ValueField"] = ;
	Возврат Этот;
КонецФункции // CharacteristicValues()

Функция TypeDescription()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Type"] = "QName";
	Элементы["TypeSet"] = "QName";
	Элементы["TypeId"] = "UUID";
	Элементы["NumberQualifiers"] = NumberQualifiers();
	Элементы["StringQualifiers"] = StringQualifiers();
	Элементы["DateQualifiers"] = DateQualifiers();
	Элементы["BinaryDataQualifiers"] = BinaryDataQualifiers();
	Возврат Этот;
КонецФункции // TypeDescription()

Функция NumberQualifiers()
	Этот = Структура();
	Этот["Digits"] = "Decimal";
	Этот["FractionDigits"] = "Decimal";
	Этот["AllowedSign"] = "String"; // Enums.AllowedSign;
	Возврат Этот;
КонецФункции // NumberQualifiers()

Функция StringQualifiers()
	Этот = Структура();
	Этот["Length"] = "Decimal";
	Этот["AllowedLength"] = "String"; // Enums.AllowedLength;
	Возврат Этот;
КонецФункции // StringQualifiers()

Функция DateQualifiers()
	Этот = Структура();
	Этот["DateFractions"] = "String"; // Enums.DateFractions;
	Возврат Этот;
КонецФункции // DateQualifiers()

Функция BinaryDataQualifiers()
	Этот = Структура();
	Этот["Length"] = "Decimal";
	Этот["AllowedLength"] = "String"; // Enums.AllowedLength;
	Возврат Этот;
КонецФункции // BinaryDataQualifiers()

#КонецОбласти // Common

#Область MetaDataObject

Функция MetaDataObject()
	Этот = Структура();
	Этот["version"] = "Decimal";
	Этот["Configuration"] = Configuration();
	Этот["Language"] = Language();
	Этот["AccountingRegister"] = AccountingRegister();
	Этот["AccumulationRegister"] = AccumulationRegister();
	Этот["BusinessProcess"] = BusinessProcess();
	Этот["CalculationRegister"] = CalculationRegister();
	Этот["Catalog"] = Catalog();
	Этот["ChartOfAccounts"] = ChartOfAccounts();
	Этот["ChartOfCalculationTypes"] = ChartOfCalculationTypes();
	Этот["ChartOfCharacteristicTypes"] = ChartOfCharacteristicTypes();
	Этот["CommandGroup"] = CommandGroup();
	Этот["CommonAttribute"] = CommonAttribute();
	Этот["CommonCommand"] = CommonCommand();
	Этот["CommonForm"] = CommonForm();
	Этот["CommonModule"] = CommonModule();
	Этот["CommonPicture"] = CommonPicture();
	Этот["CommonTemplate"] = CommonTemplate();
	Этот["Constant"] = Constant();
	Этот["DataProcessor"] = DataProcessor();
	Этот["DocumentJournal"] = DocumentJournal();
	Этот["DocumentNumerator"] = DocumentNumerator();
	Этот["Document"] = Document();
	Этот["Enum"] = Enum();
	Этот["EventSubscription"] = EventSubscription();
	Этот["ExchangePlan"] = ExchangePlan();
	Этот["FilterCriterion"] = FilterCriterion();
	Этот["FunctionalOption"] = FunctionalOption();
	Этот["FunctionalOptionsParameter"] = FunctionalOptionsParameter();
	Этот["HTTPService"] = HTTPService();
	Этот["InformationRegister"] = InformationRegister();
	Этот["Report"] = Report();
	Этот["Role"] = Role();
	Этот["ScheduledJob"] = ScheduledJob();
	Этот["Sequence"] = Sequence();
	Этот["SessionParameter"] = SessionParameter();
	Этот["SettingsStorage"] = SettingsStorage();
	Этот["Subsystem"] = Subsystem();
	Этот["Task"] = Task();
	Этот["Template"] = Template();
	Этот["WebService"] = WebService();
	Этот["WSReference"] = WSReference();
	Этот["XDTOPackage"] = XDTOPackage();
	Этот["Form"] = Form();
	Возврат Этот;
КонецФункции // MetaDataObject()

Функция MDObjectBase()
	Этот = Структура();
	Этот["uuid"] = "UUID";
	//Этот["InternalInfo"] = InternalInfo();
	Возврат Этот;
КонецФункции // MDObjectBase()

#Область ChildObjects

#Область Attribute

Функция Attribute()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = AttributeProperties();
	Возврат Этот;
КонецФункции // Attribute()

Функция AttributeProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Type"] = "TypeDescription";
	Этот["PasswordMode"] = "String"; // Enums.Boolean;
	Этот["Format"] = "LocalStringType";
	Этот["EditFormat"] = "LocalStringType";
	Этот["ToolTip"] = "LocalStringType";
	Этот["MarkNegatives"] = "String"; // Enums.Boolean;
	Этот["Mask"] = "String";
	Этот["MultiLine"] = "String"; // Enums.Boolean;
	Этот["ExtendedEdit"] = "String"; // Enums.Boolean;
	//Этот["MinValue"]               = ;
	//Этот["MaxValue"]               = ;
	Этот["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//Этот["FillValue"]              = ;
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	Этот["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	Этот["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//Этот["ChoiceParameters"]       = ;
	Этот["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceForm"] = "MDObjectRef";
	Этот["LinkByType"] = "TypeLink";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["Indexing"] = "String"; // Enums.Indexing;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["Use"] = "String"; // Enums.AttributeUse;
	Этот["ScheduleLink"] = "MDObjectRef";
	Этот["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат Этот;
КонецФункции // AttributeProperties()

#КонецОбласти // Attribute

#Область Dimension

Функция Dimension()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = DimensionProperties();
	Возврат Этот;
КонецФункции // Dimension()

Функция DimensionProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Type"] = "TypeDescription";
	Этот["PasswordMode"] = "String"; // Enums.Boolean;
	Этот["Format"] = "LocalStringType";
	Этот["EditFormat"] = "LocalStringType";
	Этот["ToolTip"] = "LocalStringType";
	Этот["MarkNegatives"] = "String"; // Enums.Boolean;
	Этот["Mask"] = "String";
	Этот["MultiLine"] = "String"; // Enums.Boolean;
	Этот["ExtendedEdit"] = "String"; // Enums.Boolean;
	//Этот["MinValue"]               = ;
	//Этот["MaxValue"]               = ;
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	Этот["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	Этот["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//Этот["ChoiceParameters"]       = ;
	Этот["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceForm"] = "MDObjectRef";
	Этот["LinkByType"] = "TypeLink";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["Balance"] = "String"; // Enums.Boolean;
	Этот["AccountingFlag"] = "MDObjectRef";
	Этот["DenyIncompleteValues"] = "String"; // Enums.Boolean;
	Этот["Indexing"] = "String"; // Enums.Indexing;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["UseInTotals"] = "String"; // Enums.Boolean;
	Этот["RegisterDimension"] = "MDObjectRef";
	Этот["LeadingRegisterData"] = "MDListType";
	Этот["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//Этот["FillValue"]              = ;
	Этот["Master"] = "String"; // Enums.Boolean;
	Этот["MainFilter"] = "String"; // Enums.Boolean;
	Этот["BaseDimension"] = "String"; // Enums.Boolean;
	Этот["ScheduleLink"] = "MDObjectRef";
	Этот["DocumentMap"] = "MDListType";
	Этот["RegisterRecordsMap"] = "MDListType";
	Этот["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат Этот;
КонецФункции // DimensionProperties()

#КонецОбласти // Dimension

#Область Resource

Функция Resource()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ResourceProperties();
	Возврат Этот;
КонецФункции // Resource()

Функция ResourceProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Type"] = "TypeDescription";
	Этот["PasswordMode"] = "String"; // Enums.Boolean;
	Этот["Format"] = "LocalStringType";
	Этот["EditFormat"] = "LocalStringType";
	Этот["ToolTip"] = "LocalStringType";
	Этот["MarkNegatives"] = "String"; // Enums.Boolean;
	Этот["Mask"] = "String";
	Этот["MultiLine"] = "String"; // Enums.Boolean;
	Этот["ExtendedEdit"] = "String"; // Enums.Boolean;
	//Этот["MinValue"]                    = ;
	//Этот["MaxValue"]                    = ;
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	Этот["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	Этот["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//Этот["ChoiceParameters"]            = ;
	Этот["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceForm"] = "MDObjectRef";
	Этот["LinkByType"] = "TypeLink";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["Balance"] = "String"; // Enums.Boolean;
	Этот["AccountingFlag"] = "MDObjectRef";
	Этот["ExtDimensionAccountingFlag"] = "MDObjectRef";
	Этот["NameInDataSource"] = "String";
	Этот["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//Этот["FillValue"]                   = ;
	Этот["Indexing"] = "String"; // Enums.Indexing;
	Этот["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат Этот;
КонецФункции // ResourceProperties()

#КонецОбласти // Resource

#Область AccountingFlag

Функция AccountingFlag()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = AccountingFlagProperties();
	Возврат Этот;
КонецФункции // AccountingFlag()

Функция AccountingFlagProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Type"] = "TypeDescription";
	Этот["PasswordMode"] = "String"; // Enums.Boolean;
	Этот["Format"] = "LocalStringType";
	Этот["EditFormat"] = "LocalStringType";
	Этот["ToolTip"] = "LocalStringType";
	Этот["MarkNegatives"] = "String"; // Enums.Boolean;
	Этот["Mask"] = "String";
	Этот["MultiLine"] = "String"; // Enums.Boolean;
	Этот["ExtendedEdit"] = "String"; // Enums.Boolean;
	//Этот["MinValue"]               = ;
	//Этот["MaxValue"]               = ;
	Этот["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//Этот["FillValue"]              = ;
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	Этот["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	Этот["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//Этот["ChoiceParameters"]       = ;
	Этот["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceForm"] = "MDObjectRef";
	Этот["LinkByType"] = "TypeLink";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Возврат Этот;
КонецФункции // AccountingFlagProperties()

#КонецОбласти // AccountingFlag

#Область ExtDimensionAccountingFlag

Функция ExtDimensionAccountingFlag()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ExtDimensionAccountingFlagProperties();
	Возврат Этот;
КонецФункции // ExtDimensionAccountingFlag()

Функция ExtDimensionAccountingFlagProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Type"] = "TypeDescription";
	Этот["PasswordMode"] = "String"; // Enums.Boolean;
	Этот["Format"] = "LocalStringType";
	Этот["EditFormat"] = "LocalStringType";
	Этот["ToolTip"] = "LocalStringType";
	Этот["MarkNegatives"] = "String"; // Enums.Boolean;
	Этот["Mask"] = "String";
	Этот["MultiLine"] = "String"; // Enums.Boolean;
	Этот["ExtendedEdit"] = "String"; // Enums.Boolean;
	//Этот["MinValue"]               = ;
	//Этот["MaxValue"]               = ;
	Этот["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//Этот["FillValue"]              = ;
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	Этот["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	Этот["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//Этот["ChoiceParameters"]       = ;
	Этот["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceForm"] = "MDObjectRef";
	Этот["LinkByType"] = "TypeLink";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Возврат Этот;
КонецФункции // ExtDimensionAccountingFlagProperties()

#КонецОбласти // ExtDimensionAccountingFlag

#Область Column

Функция Column()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ColumnProperties();
	Возврат Этот;
КонецФункции // Column()

Функция ColumnProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Indexing"] = "String"; // Enums.Indexing;
	Этот["References"] = "MDListType";
	Возврат Этот;
КонецФункции // ColumnProperties()

#КонецОбласти // Column

#Область EnumValue

Функция EnumValue()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = EnumValueProperties();
	Возврат Этот;
КонецФункции // EnumValue()

Функция EnumValueProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Возврат Этот;
КонецФункции // EnumValueProperties()

#КонецОбласти // EnumValue

#Область Form

Функция Form()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = FormProperties();
	Возврат Этот;
КонецФункции // Form()

Функция FormProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["FormType"] = "String"; // Enums.FormType;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	//Этот["UsePurposes"]            = "FixedArray";
	Этот["ExtendedPresentation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // FormProperties()

#КонецОбласти // Form

#Область Template

Функция Template()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = TemplateProperties();
	Возврат Этот;
КонецФункции // Template()

Функция TemplateProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["TemplateType"] = "String"; // Enums.TemplateType;
	Возврат Этот;
КонецФункции // TemplateProperties()

#КонецОбласти // Template

#Область AddressingAttribute

Функция AddressingAttribute()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = AddressingAttributeProperties();
	Возврат Этот;
КонецФункции // AddressingAttribute()

Функция AddressingAttributeProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Type"] = "TypeDescription";
	Этот["PasswordMode"] = "String"; // Enums.Boolean;
	Этот["Format"] = "LocalStringType";
	Этот["EditFormat"] = "LocalStringType";
	Этот["ToolTip"] = "LocalStringType";
	Этот["MarkNegatives"] = "String"; // Enums.Boolean;
	Этот["Mask"] = "String";
	Этот["MultiLine"] = "String"; // Enums.Boolean;
	Этот["ExtendedEdit"] = "String"; // Enums.Boolean;
	//Этот["MinValue"]               = ;
	//Этот["MaxValue"]               = ;
	Этот["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//Этот["FillValue"]              = ;
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	Этот["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	Этот["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//Этот["ChoiceParameters"]       = ;
	Этот["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceForm"] = "MDObjectRef";
	Этот["LinkByType"] = "TypeLink";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["Indexing"] = "String"; // Enums.Indexing;
	Этот["AddressingDimension"] = "MDObjectRef";
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Возврат Этот;
КонецФункции // AddressingAttributeProperties()

#КонецОбласти // AddressingAttribute

#Область TabularSection

Функция TabularSection()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = TabularSectionProperties();
	Этот["ChildObjects"] = TabularSectionChildObjects();
	Возврат Этот;
КонецФункции // TabularSection()

Функция TabularSectionProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["ToolTip"] = "LocalStringType";
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["Use"] = "String"; // Enums.AttributeUse;
	Возврат Этот;
КонецФункции // TabularSectionProperties()

Функция TabularSectionChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Возврат Этот;
КонецФункции // TabularSectionChildObjects()

#КонецОбласти // TabularSection

#Область Command

Функция Command()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = CommandProperties();
	Возврат Этот;
КонецФункции // Command()

Функция CommandProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Group"] = "IncludeInCommandCategoriesType";
	Этот["CommandParameterType"] = "TypeDescription";
	Этот["ParameterUseMode"] = "String"; // Enums.CommandParameterUseMode;
	Этот["ModifiesData"] = "String"; // Enums.Boolean;
	Этот["Representation"] = "String"; // Enums.ButtonRepresentation;
	Этот["ToolTip"] = "LocalStringType";
	//Этот["Picture"]               = ;
	//Этот["Shortcut"]              = ;
	Возврат Этот;
КонецФункции // CommandProperties()

#КонецОбласти // Command

#КонецОбласти // ChildObjects

#Область Configuration

Функция Configuration()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ConfigurationProperties();
	Этот["ChildObjects"] = ConfigurationChildObjects();
	Возврат Этот;
КонецФункции // Configuration()

Функция ConfigurationProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["NamePrefix"] = "String";
	Этот["ConfigurationExtensionCompatibilityMode"] = "String"; // Enums.CompatibilityMode;
	Этот["DefaultRunMode"] = "String"; // Enums.ClientRunMode;
	//Этот["UsePurposes"]                                      = "FixedArray";
	Этот["ScriptVariant"] = "String"; // Enums.ScriptVariant;
	Этот["DefaultRoles"] = "MDListType";
	Этот["Vendor"] = "String";
	Этот["Version"] = "String";
	Этот["UpdateCatalogAddress"] = "String";
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["UseManagedFormInOrdinaryApplication"] = "String"; // Enums.Boolean;
	Этот["UseOrdinaryFormInManagedApplication"] = "String"; // Enums.Boolean;
	Этот["AdditionalFullTextSearchDictionaries"] = "MDListType";
	Этот["CommonSettingsStorage"] = "MDObjectRef";
	Этот["ReportsUserSettingsStorage"] = "MDObjectRef";
	Этот["ReportsVariantsStorage"] = "MDObjectRef";
	Этот["FormDataSettingsStorage"] = "MDObjectRef";
	Этот["DynamicListsUserSettingsStorage"] = "MDObjectRef";
	Этот["Content"] = "MDListType";
	Этот["DefaultReportForm"] = "MDObjectRef";
	Этот["DefaultReportVariantForm"] = "MDObjectRef";
	Этот["DefaultReportSettingsForm"] = "MDObjectRef";
	Этот["DefaultDynamicListSettingsForm"] = "MDObjectRef";
	Этот["DefaultSearchForm"] = "MDObjectRef";
	//Этот["RequiredMobileApplicationPermissions"]             = "FixedMap";
	Этот["MainClientApplicationWindowMode"] = "String"; // Enums.MainClientApplicationWindowMode;
	Этот["DefaultInterface"] = "MDObjectRef";
	Этот["DefaultStyle"] = "MDObjectRef";
	Этот["DefaultLanguage"] = "MDObjectRef";
	Этот["BriefInformation"] = "LocalStringType";
	Этот["DetailedInformation"] = "LocalStringType";
	Этот["Copyright"] = "LocalStringType";
	Этот["VendorInformationAddress"] = "LocalStringType";
	Этот["ConfigurationInformationAddress"] = "LocalStringType";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["ObjectAutonumerationMode"] = "String"; // Enums.ObjectAutonumerationMode;
	Этот["ModalityUseMode"] = "String"; // Enums.ModalityUseMode;
	Этот["SynchronousPlatformExtensionAndAddInCallUseMode"] = "String"; // Enums.SynchronousPlatformExtensionAndAddInCallUseMode;
	Этот["InterfaceCompatibilityMode"] = "String"; // Enums.InterfaceCompatibilityMode;
	Этот["CompatibilityMode"] = "String"; // Enums.CompatibilityMode;
	Этот["DefaultConstantsForm"] = "MDObjectRef";
	Возврат Этот;
КонецФункции // ConfigurationProperties()

Функция ConfigurationChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Language"] = "String";
	Элементы["Subsystem"] = "String";
	Элементы["StyleItem"] = "String";
	Элементы["Style"] = "String";
	Элементы["CommonPicture"] = "String";
	Элементы["Interface"] = "String";
	Элементы["SessionParameter"] = "String";
	Элементы["Role"] = "String";
	Элементы["CommonTemplate"] = "String";
	Элементы["FilterCriterion"] = "String";
	Элементы["CommonModule"] = "String";
	Элементы["CommonAttribute"] = "String";
	Элементы["ExchangePlan"] = "String";
	Элементы["XDTOPackage"] = "String";
	Элементы["WebService"] = "String";
	Элементы["HTTPService"] = "String";
	Элементы["WSReference"] = "String";
	Элементы["EventSubscription"] = "String";
	Элементы["ScheduledJob"] = "String";
	Элементы["SettingsStorage"] = "String";
	Элементы["FunctionalOption"] = "String";
	Элементы["FunctionalOptionsParameter"] = "String";
	Элементы["DefinedType"] = "String";
	Элементы["CommonCommand"] = "String";
	Элементы["CommandGroup"] = "String";
	Элементы["Constant"] = "String";
	Элементы["CommonForm"] = "String";
	Элементы["Catalog"] = "String";
	Элементы["Document"] = "String";
	Элементы["DocumentNumerator"] = "String";
	Элементы["Sequence"] = "String";
	Элементы["DocumentJournal"] = "String";
	Элементы["Enum"] = "String";
	Элементы["Report"] = "String";
	Элементы["DataProcessor"] = "String";
	Элементы["InformationRegister"] = "String";
	Элементы["AccumulationRegister"] = "String";
	Элементы["ChartOfCharacteristicTypes"] = "String";
	Элементы["ChartOfAccounts"] = "String";
	Элементы["AccountingRegister"] = "String";
	Элементы["ChartOfCalculationTypes"] = "String";
	Элементы["CalculationRegister"] = "String";
	Элементы["BusinessProcess"] = "String";
	Элементы["Task"] = "String";
	Элементы["ExternalDataSource"] = "String";
	Возврат Этот;
КонецФункции // ConfigurationChildObjects()

#КонецОбласти // Configuration

#Область Language

Функция Language()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = LanguageProperties();
	Возврат Этот;
КонецФункции // Foo()

Функция LanguageProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["LanguageCode"] = "String";
	Возврат Этот;
КонецФункции // LanguageProperties()

#КонецОбласти // Language

#Область AccountingRegister

Функция AccountingRegister()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = AccountingRegisterProperties();
	Этот["ChildObjects"] = AccountingRegisterChildObjects();
	Возврат Этот;
КонецФункции // AccountingRegister()

Функция AccountingRegisterProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["ChartOfAccounts"] = "MDObjectRef";
	Этот["Correspondence"] = "String"; // Enums.Boolean;
	Этот["PeriodAdjustmentLength"] = "Decimal";
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["EnableTotalsSplitting"] = "String"; // Enums.Boolean;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // AccountingRegisterProperties()

Функция AccountingRegisterChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Dimension"] = "Dimension";
	Элементы["Resource"] = "Resource";
	Элементы["Attribute"] = "Attribute";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // AccountingRegisterChildObjects()

#КонецОбласти // AccountingRegister

#Область AccumulationRegister

Функция AccumulationRegister()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = AccumulationRegisterProperties();
	Этот["ChildObjects"] = AccumulationRegisterChildObjects();
	Возврат Этот;
КонецФункции // AccumulationRegister()

Функция AccumulationRegisterProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["RegisterType"] = "String"; // Enums.AccumulationRegisterType;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["EnableTotalsSplitting"] = "String"; // Enums.Boolean;
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // AccumulationRegisterProperties()

Функция AccumulationRegisterChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Resource"] = "Resource";
	Элементы["Attribute"] = "Attribute";
	Элементы["Dimension"] = "Dimension";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // AccumulationRegisterChildObjects()

#КонецОбласти // AccumulationRegister

#Область BusinessProcess

Функция BusinessProcess()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = BusinessProcessProperties();
	Этот["ChildObjects"] = BusinessProcessChildObjects();
	Возврат Этот;
КонецФункции // BusinessProcess()

Функция BusinessProcessProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["EditType"] = "String"; // Enums.EditType;
	Этот["InputByString"] = "FieldList";
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	Этот["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	Этот["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	Этот["DefaultObjectForm"] = "MDObjectRef";
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["DefaultChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryObjectForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["AuxiliaryChoiceForm"] = "MDObjectRef";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["NumberType"] = "String"; // Enums.BusinessProcessNumberType;
	Этот["NumberLength"] = "Decimal";
	Этот["NumberAllowedLength"] = "String"; // Enums.AllowedLength;
	Этот["CheckUnique"] = "String"; // Enums.Boolean;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["Characteristics"] = "Characteristics";
	Этот["Autonumbering"] = "String"; // Enums.Boolean;
	Этот["BasedOn"] = "MDListType";
	Этот["NumberPeriodicity"] = "String"; // Enums.BusinessProcessNumberPeriodicity;
	Этот["Task"] = "MDObjectRef";
	Этот["CreateTaskInPrivilegedMode"] = "String"; // Enums.Boolean;
	Этот["DataLockFields"] = "FieldList";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["ObjectPresentation"] = "LocalStringType";
	Этот["ExtendedObjectPresentation"] = "LocalStringType";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // BusinessProcessProperties()

Функция BusinessProcessChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Элементы["TabularSection"] = "TabularSection";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // BusinessProcessChildObjects()

#КонецОбласти // BusinessProcess

#Область CalculationRegister

Функция CalculationRegister()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = CalculationRegisterProperties();
	Этот["ChildObjects"] = CalculationRegisterChildObjects();
	Возврат Этот;
КонецФункции // CalculationRegister()

Функция CalculationRegisterProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["Periodicity"] = "String"; // Enums.CalculationRegisterPeriodicity;
	Этот["ActionPeriod"] = "String"; // Enums.Boolean;
	Этот["BasePeriod"] = "String"; // Enums.Boolean;
	Этот["Schedule"] = "MDObjectRef";
	Этот["ScheduleValue"] = "MDObjectRef";
	Этот["ScheduleDate"] = "MDObjectRef";
	Этот["ChartOfCalculationTypes"] = "MDObjectRef";
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // CalculationRegisterProperties()

Функция CalculationRegisterChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Resource"] = "Resource";
	Элементы["Attribute"] = "Attribute";
	Элементы["Dimension"] = "Dimension";
	Элементы["Recalculation"] = "String";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // CalculationRegisterChildObjects()

#КонецОбласти // CalculationRegister

#Область Catalog

Функция Catalog()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = CatalogProperties();
	Этот["ChildObjects"] = CatalogChildObjects();
	Возврат Этот;
КонецФункции // Catalog()

Функция CatalogProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Hierarchical"] = "String"; // Enums.Boolean;
	Этот["HierarchyType"] = "String"; // Enums.HierarchyType;
	Этот["LimitLevelCount"] = "String"; // Enums.Boolean;
	Этот["LevelCount"] = "Decimal";
	Этот["FoldersOnTop"] = "String"; // Enums.Boolean;
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["Owners"] = "MDListType";
	Этот["SubordinationUse"] = "String"; // Enums.SubordinationUse;
	Этот["CodeLength"] = "Decimal";
	Этот["DescriptionLength"] = "Decimal";
	Этот["CodeType"] = "String"; // Enums.CatalogCodeType;
	Этот["CodeAllowedLength"] = "String"; // Enums.AllowedLength;
	Этот["CodeSeries"] = "String"; // Enums.CatalogCodesSeries;
	Этот["CheckUnique"] = "String"; // Enums.Boolean;
	Этот["Autonumbering"] = "String"; // Enums.Boolean;
	Этот["DefaultPresentation"] = "String"; // Enums.CatalogMainPresentation;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["Characteristics"] = "Characteristics";
	Этот["PredefinedDataUpdate"] = "String"; // Enums.PredefinedDataUpdate;
	Этот["EditType"] = "String"; // Enums.EditType;
	Этот["QuickChoice"] = "String"; // Enums.Boolean;
	Этот["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	Этот["InputByString"] = "FieldList";
	Этот["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	Этот["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	Этот["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	Этот["DefaultObjectForm"] = "MDObjectRef";
	Этот["DefaultFolderForm"] = "MDObjectRef";
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["DefaultChoiceForm"] = "MDObjectRef";
	Этот["DefaultFolderChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryObjectForm"] = "MDObjectRef";
	Этот["AuxiliaryFolderForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["AuxiliaryChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryFolderChoiceForm"] = "MDObjectRef";
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["BasedOn"] = "MDListType";
	Этот["DataLockFields"] = "FieldList";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["ObjectPresentation"] = "LocalStringType";
	Этот["ExtendedObjectPresentation"] = "LocalStringType";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат Этот;
КонецФункции // CatalogProperties()

Функция CatalogChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Элементы["TabularSection"] = "TabularSection";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // CatalogChildObjects()

#КонецОбласти // Catalog

#Область ChartOfAccounts

Функция ChartOfAccounts()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ChartOfAccountsProperties();
	Этот["ChildObjects"] = ChartOfAccountsChildObjects();
	Возврат Этот;
КонецФункции // ChartOfAccounts()

Функция ChartOfAccountsProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["BasedOn"] = "MDListType";
	Этот["ExtDimensionTypes"] = "MDObjectRef";
	Этот["MaxExtDimensionCount"] = "Decimal";
	Этот["CodeMask"] = "String";
	Этот["CodeLength"] = "Decimal";
	Этот["DescriptionLength"] = "Decimal";
	Этот["CodeSeries"] = "String"; // Enums.CharOfAccountCodeSeries;
	Этот["CheckUnique"] = "String"; // Enums.Boolean;
	Этот["DefaultPresentation"] = "String"; // Enums.AccountMainPresentation;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["Characteristics"] = "Characteristics";
	Этот["StandardTabularSections"] = "StandardTabularSections";
	Этот["PredefinedDataUpdate"] = "String"; // Enums.PredefinedDataUpdate;
	Этот["EditType"] = "String"; // Enums.EditType;
	Этот["QuickChoice"] = "String"; // Enums.Boolean;
	Этот["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	Этот["InputByString"] = "FieldList";
	Этот["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	Этот["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	Этот["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["DefaultObjectForm"] = "MDObjectRef";
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["DefaultChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryObjectForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["AuxiliaryChoiceForm"] = "MDObjectRef";
	Этот["AutoOrderByCode"] = "String"; // Enums.Boolean;
	Этот["OrderLength"] = "Decimal";
	Этот["DataLockFields"] = "FieldList";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["ObjectPresentation"] = "LocalStringType";
	Этот["ExtendedObjectPresentation"] = "LocalStringType";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // ChartOfAccountsProperties()

Функция ChartOfAccountsChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Элементы["TabularSection"] = "TabularSection";
	Элементы["AccountingFlag"] = "AccountingFlag";
	Элементы["ExtDimensionAccountingFlag"] = "ExtDimensionAccountingFlag";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // ChartOfAccountsChildObjects()

#КонецОбласти // ChartOfAccounts

#Область ChartOfCalculationTypes

Функция ChartOfCalculationTypes()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ChartOfCalculationTypesProperties();
	Этот["ChildObjects"] = ChartOfCalculationTypesChildObjects();
	Возврат Этот;
КонецФункции // ChartOfCalculationTypes()

Функция ChartOfCalculationTypesProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["CodeLength"] = "Decimal";
	Этот["DescriptionLength"] = "Decimal";
	Этот["CodeType"] = "String"; // Enums.ChartOfCalculationTypesCodeType;
	Этот["CodeAllowedLength"] = "String"; // Enums.AllowedLength;
	Этот["DefaultPresentation"] = "String"; // Enums.CalculationTypeMainPresentation;
	Этот["EditType"] = "String"; // Enums.EditType;
	Этот["QuickChoice"] = "String"; // Enums.Boolean;
	Этот["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	Этот["InputByString"] = "FieldList";
	Этот["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	Этот["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	Этот["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["DefaultObjectForm"] = "MDObjectRef";
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["DefaultChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryObjectForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["AuxiliaryChoiceForm"] = "MDObjectRef";
	Этот["BasedOn"] = "MDListType";
	Этот["DependenceOnCalculationTypes"] = "String"; // Enums.ChartOfCalculationTypesBaseUse;
	Этот["BaseCalculationTypes"] = "MDListType";
	Этот["ActionPeriodUse"] = "String"; // Enums.Boolean;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["Characteristics"] = "Characteristics";
	Этот["StandardTabularSections"] = "StandardTabularSections";
	Этот["PredefinedDataUpdate"] = "String"; // Enums.PredefinedDataUpdate;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["DataLockFields"] = "FieldList";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["ObjectPresentation"] = "LocalStringType";
	Этот["ExtendedObjectPresentation"] = "LocalStringType";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // ChartOfCalculationTypesProperties()

Функция ChartOfCalculationTypesChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Элементы["TabularSection"] = "TabularSection";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // ChartOfCalculationTypesChildObjects()

#КонецОбласти // ChartOfCalculationTypes

#Область ChartOfCharacteristicTypes

Функция ChartOfCharacteristicTypes()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ChartOfCharacteristicTypesProperties();
	Этот["ChildObjects"] = ChartOfCharacteristicTypesChildObjects();
	Возврат Этот;
КонецФункции // ChartOfCharacteristicTypes()

Функция ChartOfCharacteristicTypesProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["CharacteristicExtValues"] = "MDObjectRef";
	Этот["Type"] = "TypeDescription";
	Этот["Hierarchical"] = "String"; // Enums.Boolean;
	Этот["FoldersOnTop"] = "String"; // Enums.Boolean;
	Этот["CodeLength"] = "Decimal";
	Этот["CodeAllowedLength"] = "String"; // Enums.AllowedLength;
	Этот["DescriptionLength"] = "Decimal";
	Этот["CodeSeries"] = "String"; // Enums.CharacteristicKindCodesSeries;
	Этот["CheckUnique"] = "String"; // Enums.Boolean;
	Этот["Autonumbering"] = "String"; // Enums.Boolean;
	Этот["DefaultPresentation"] = "String"; // Enums.CharacteristicTypeMainPresentation;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["Characteristics"] = "Characteristics";
	Этот["PredefinedDataUpdate"] = "String"; // Enums.PredefinedDataUpdate;
	Этот["EditType"] = "String"; // Enums.EditType;
	Этот["QuickChoice"] = "String"; // Enums.Boolean;
	Этот["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	Этот["InputByString"] = "FieldList";
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	Этот["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	Этот["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["DefaultObjectForm"] = "MDObjectRef";
	Этот["DefaultFolderForm"] = "MDObjectRef";
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["DefaultChoiceForm"] = "MDObjectRef";
	Этот["DefaultFolderChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryObjectForm"] = "MDObjectRef";
	Этот["AuxiliaryFolderForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["AuxiliaryChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryFolderChoiceForm"] = "MDObjectRef";
	Этот["BasedOn"] = "MDListType";
	Этот["DataLockFields"] = "FieldList";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["ObjectPresentation"] = "LocalStringType";
	Этот["ExtendedObjectPresentation"] = "LocalStringType";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // ChartOfCharacteristicTypesProperties()

Функция ChartOfCharacteristicTypesChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Элементы["TabularSection"] = "TabularSection";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // ChartOfCharacteristicTypesChildObjects()

#КонецОбласти // ChartOfCharacteristicTypes

#Область CommandGroup

Функция CommandGroup()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = CommandGroupProperties();
	Этот["ChildObjects"] = CommandGroupChildObjects();
	Возврат Этот;
КонецФункции // CommandGroup()

Функция CommandGroupProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Representation"] = "String"; // Enums.ButtonRepresentation;
	Этот["ToolTip"] = "LocalStringType";
	//Этот["Picture"]         = ;
	Этот["Category"] = "String"; // Enums.CommandGroupCategory;
	Возврат Этот;
КонецФункции // CommandGroupProperties()

Функция CommandGroupChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // CommandGroupChildObjects()

#КонецОбласти // CommandGroup

#Область CommonAttribute

Функция CommonAttribute()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = CommonAttributeProperties();
	Этот["ChildObjects"] = CommonAttributeChildObjects();
	Возврат Этот;
КонецФункции // CommonAttribute()

Функция CommonAttributeProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Type"] = "TypeDescription";
	Этот["PasswordMode"] = "String"; // Enums.Boolean;
	Этот["Format"] = "LocalStringType";
	Этот["EditFormat"] = "LocalStringType";
	Этот["ToolTip"] = "LocalStringType";
	Этот["MarkNegatives"] = "String"; // Enums.Boolean;
	Этот["Mask"] = "String";
	Этот["MultiLine"] = "String"; // Enums.Boolean;
	Этот["ExtendedEdit"] = "String"; // Enums.Boolean;
	//Этот["MinValue"]                           = ;
	//Этот["MaxValue"]                           = ;
	Этот["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//Этот["FillValue"]                          = ;
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	Этот["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	Этот["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//Этот["ChoiceParameters"]                   = ;
	Этот["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceForm"] = "MDObjectRef";
	Этот["LinkByType"] = "TypeLink";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	//Этот["Content"]                            = CommonAttributeContent();
	Этот["AutoUse"] = "String"; // Enums.CommonAttributeAutoUse;
	Этот["DataSeparation"] = "String"; // Enums.CommonAttributeDataSeparation;
	Этот["SeparatedDataUse"] = "String"; // Enums.CommonAttributeSeparatedDataUse;
	Этот["DataSeparationValue"] = "MDObjectRef";
	Этот["DataSeparationUse"] = "MDObjectRef";
	Этот["ConditionalSeparation"] = "MDObjectRef";
	Этот["UsersSeparation"] = "String"; // Enums.CommonAttributeUsersSeparation;
	Этот["AuthenticationSeparation"] = "String"; // Enums.CommonAttributeAuthenticationSeparation;
	Этот["ConfigurationExtensionsSeparation"] = "String"; // Enums.CommonAttributeConfigurationExtensionsSeparation;
	Этот["Indexing"] = "String"; // Enums.Indexing;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат Этот;
КонецФункции // CommonAttributeProperties()

Функция CommonAttributeChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // CommonAttributeChildObjects()

#КонецОбласти // CommonAttribute

#Область CommonCommand

Функция CommonCommand()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = CommonCommandProperties();
	Этот["ChildObjects"] = CommonCommandChildObjects();
	Возврат Этот;
КонецФункции // CommonCommand()

Функция CommonCommandProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	//Этот["Group"]                  = IncludeInCommandCategoriesType;
	Этот["Representation"] = "String"; // Enums.ButtonRepresentation;
	Этот["ToolTip"] = "LocalStringType";
	//Этот["Picture"]                = ;
	//Этот["Shortcut"]               = ;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["CommandParameterType"] = "TypeDescription";
	Этот["ParameterUseMode"] = "String"; // Enums.CommandParameterUseMode;
	Этот["ModifiesData"] = "String"; // Enums.Boolean;
	Возврат Этот;
КонецФункции // CommonCommandProperties()

Функция CommonCommandChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // CommonCommandChildObjects()

#КонецОбласти // CommonCommand

#Область CommonForm

Функция CommonForm()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = CommonFormProperties();
	Этот["ChildObjects"] = CommonFormChildObjects();
	Возврат Этот;
КонецФункции // CommonForm()

Функция CommonFormProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["FormType"] = "String"; // Enums.FormType;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	//Этот["UsePurposes"]            = "FixedArray";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["ExtendedPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // CommonFormProperties()

Функция CommonFormChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // CommonFormChildObjects()

#КонецОбласти // CommonForm

#Область CommonModule

Функция CommonModule()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = CommonModuleProperties();
	Этот["ChildObjects"] = CommonModuleChildObjects();
	Возврат Этот;
КонецФункции // CommonModule()

Функция CommonModuleProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Global"] = "String"; // Enums.Boolean;
	Этот["ClientManagedApplication"] = "String"; // Enums.Boolean;
	Этот["Server"] = "String"; // Enums.Boolean;
	Этот["ExternalConnection"] = "String"; // Enums.Boolean;
	Этот["ClientOrdinaryApplication"] = "String"; // Enums.Boolean;
	Этот["Client"] = "String"; // Enums.Boolean;
	Этот["ServerCall"] = "String"; // Enums.Boolean;
	Этот["Privileged"] = "String"; // Enums.Boolean;
	Этот["ReturnValuesReuse"] = "String"; // Enums.ReturnValuesReuse;
	Возврат Этот;
КонецФункции // CommonModuleProperties()

Функция CommonModuleChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // CommonModuleChildObjects()

#КонецОбласти // CommonModule

#Область CommonPicture

Функция CommonPicture()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = CommonPictureProperties();
	Этот["ChildObjects"] = CommonPictureChildObjects();
	Возврат Этот;
КонецФункции // CommonPicture()

Функция CommonPictureProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Возврат Этот;
КонецФункции // CommonPictureProperties()

Функция CommonPictureChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // CommonPictureChildObjects()

#КонецОбласти // CommonPicture

#Область CommonTemplate

Функция CommonTemplate()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = CommonTemplateProperties();
	Этот["ChildObjects"] = CommonTemplateChildObjects();
	Возврат Этот;
КонецФункции // CommonTemplate()

Функция CommonTemplateProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["TemplateType"] = "String"; // Enums.TemplateType;
	Возврат Этот;
КонецФункции // CommonTemplateProperties()

Функция CommonTemplateChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // CommonTemplateChildObjects()

#КонецОбласти // CommonTemplate

#Область Constant

Функция Constant()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ConstantProperties();
	Этот["ChildObjects"] = ConstantChildObjects();
	Возврат Этот;
КонецФункции // Constant()

Функция ConstantProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Type"] = "TypeDescription";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["DefaultForm"] = "MDObjectRef";
	Этот["ExtendedPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Этот["PasswordMode"] = "String"; // Enums.Boolean;
	Этот["Format"] = "LocalStringType";
	Этот["EditFormat"] = "LocalStringType";
	Этот["ToolTip"] = "LocalStringType";
	Этот["MarkNegatives"] = "String"; // Enums.Boolean;
	Этот["Mask"] = "String";
	Этот["MultiLine"] = "String"; // Enums.Boolean;
	Этот["ExtendedEdit"] = "String"; // Enums.Boolean;
	//Этот["MinValue"]               = ;
	//Этот["MaxValue"]               = ;
	Этот["FillChecking"] = "String"; // Enums.FillChecking;
	Этот["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	Этот["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//Этот["ChoiceParameters"]       = ;
	Этот["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	Этот["ChoiceForm"] = "MDObjectRef";
	Этот["LinkByType"] = "TypeLink";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Возврат Этот;
КонецФункции // ConstantProperties()

Функция ConstantChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // ConstantChildObjects()

#КонецОбласти // Constant

#Область DataProcessor

Функция DataProcessor()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = DataProcessorProperties();
	Этот["ChildObjects"] = DataProcessorChildObjects();
	Возврат Этот;
КонецФункции // DataProcessor()

Функция DataProcessorProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["DefaultForm"] = "MDObjectRef";
	Этот["AuxiliaryForm"] = "MDObjectRef";
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["ExtendedPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // DataProcessorProperties()

Функция DataProcessorChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Элементы["TabularSection"] = "TabularSection";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // DataProcessorChildObjects()

#КонецОбласти // DataProcessor

#Область DocumentJournal

Функция DocumentJournal()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = DocumentJournalProperties();
	Этот["ChildObjects"] = DocumentJournalChildObjects();
	Возврат Этот;
КонецФункции // DocumentJournal()

Функция DocumentJournalProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["DefaultForm"] = "MDObjectRef";
	Этот["AuxiliaryForm"] = "MDObjectRef";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["RegisteredDocuments"] = "MDListType";
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // DocumentJournalProperties()

Функция DocumentJournalChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Column"] = Column();
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // DocumentJournalChildObjects()

#КонецОбласти // DocumentJournal

#Область DocumentNumerator

Функция DocumentNumerator()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = DocumentNumeratorProperties();
	Этот["ChildObjects"] = DocumentNumeratorChildObjects();
	Возврат Этот;
КонецФункции // DocumentNumerator()

Функция DocumentNumeratorProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["NumberType"] = "String"; // Enums.DocumentNumberType;
	Этот["NumberLength"] = "Decimal";
	Этот["NumberAllowedLength"] = "String"; // Enums.AllowedLength;
	Этот["NumberPeriodicity"] = "String"; // Enums.DocumentNumberPeriodicity;
	Этот["CheckUnique"] = "String"; // Enums.Boolean;
	Возврат Этот;
КонецФункции // DocumentNumeratorProperties()

Функция DocumentNumeratorChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // DocumentNumeratorChildObjects()

#КонецОбласти // DocumentNumerator

#Область Document

Функция Document()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = DocumentProperties();
	Этот["ChildObjects"] = DocumentChildObjects();
	Возврат Этот;
КонецФункции // Document()

Функция DocumentProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["Numerator"] = "MDObjectRef";
	Этот["NumberType"] = "String"; // Enums.DocumentNumberType;
	Этот["NumberLength"] = "Decimal";
	Этот["NumberAllowedLength"] = "String"; // Enums.AllowedLength;
	Этот["NumberPeriodicity"] = "String"; // Enums.DocumentNumberPeriodicity;
	Этот["CheckUnique"] = "String"; // Enums.Boolean;
	Этот["Autonumbering"] = "String"; // Enums.Boolean;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["Characteristics"] = "Characteristics";
	Этот["BasedOn"] = "MDListType";
	Этот["InputByString"] = "FieldList";
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	Этот["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	Этот["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	Этот["DefaultObjectForm"] = "MDObjectRef";
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["DefaultChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryObjectForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["AuxiliaryChoiceForm"] = "MDObjectRef";
	Этот["Posting"] = "String"; // Enums.Posting;
	Этот["RealTimePosting"] = "String"; // Enums.RealTimePosting;
	Этот["RegisterRecordsDeletion"] = "String"; // Enums.RegisterRecordsDeletion;
	Этот["RegisterRecordsWritingOnPost"] = "String"; // Enums.RegisterRecordsWritingOnPost;
	Этот["SequenceFilling"] = "String"; // Enums.SequenceFilling;
	Этот["RegisterRecords"] = "MDListType";
	Этот["PostInPrivilegedMode"] = "String"; // Enums.Boolean;
	Этот["UnpostInPrivilegedMode"] = "String"; // Enums.Boolean;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["DataLockFields"] = "FieldList";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["ObjectPresentation"] = "LocalStringType";
	Этот["ExtendedObjectPresentation"] = "LocalStringType";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат Этот;
КонецФункции // DocumentProperties()

Функция DocumentChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Элементы["Form"] = "String";
	Элементы["TabularSection"] = "TabularSection";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // DocumentChildObjects()

#КонецОбласти // Document

#Область Enum

Функция Enum()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = EnumProperties();
	Этот["ChildObjects"] = EnumChildObjects();
	Возврат Этот;
КонецФункции // Enum()

Функция EnumProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["Characteristics"] = "Characteristics";
	Этот["QuickChoice"] = "String"; // Enums.Boolean;
	Этот["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["DefaultChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["AuxiliaryChoiceForm"] = "MDObjectRef";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Возврат Этот;
КонецФункции // EnumProperties()

Функция EnumChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["EnumValue"] = EnumValue();
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // EnumChildObjects()

#КонецОбласти // Enum

#Область EventSubscription

Функция EventSubscription()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = EventSubscriptionProperties();
	Этот["ChildObjects"] = EventSubscriptionChildObjects();
	Возврат Этот;
КонецФункции // EventSubscription()

Функция EventSubscriptionProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Source"] = "TypeDescription";
	//Этот["Event"]    = "AliasedStringType";
	Этот["Handler"] = "MDMethodRef";
	Возврат Этот;
КонецФункции // EventSubscriptionProperties()

Функция EventSubscriptionChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // EventSubscriptionChildObjects()

#КонецОбласти // EventSubscription

#Область ExchangePlan

Функция ExchangePlan()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ExchangePlanProperties();
	Этот["ChildObjects"] = ExchangePlanChildObjects();
	Возврат Этот;
КонецФункции // ExchangePlan()

Функция ExchangePlanProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["CodeLength"] = "Decimal";
	Этот["CodeAllowedLength"] = "String"; // Enums.AllowedLength;
	Этот["DescriptionLength"] = "Decimal";
	Этот["DefaultPresentation"] = "String"; // Enums.DataExchangeMainPresentation;
	Этот["EditType"] = "String"; // Enums.EditType;
	Этот["QuickChoice"] = "String"; // Enums.Boolean;
	Этот["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	Этот["InputByString"] = "FieldList";
	Этот["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	Этот["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	Этот["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	Этот["DefaultObjectForm"] = "MDObjectRef";
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["DefaultChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryObjectForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["AuxiliaryChoiceForm"] = "MDObjectRef";
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["Characteristics"] = "Characteristics";
	Этот["BasedOn"] = "MDListType";
	Этот["DistributedInfoBase"] = "String"; // Enums.Boolean;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["DataLockFields"] = "FieldList";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["ObjectPresentation"] = "LocalStringType";
	Этот["ExtendedObjectPresentation"] = "LocalStringType";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // ExchangePlanProperties()

Функция ExchangePlanChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Элементы["TabularSection"] = "TabularSection";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // ExchangePlanChildObjects()

#КонецОбласти // ExchangePlan

#Область FilterCriterion

Функция FilterCriterion()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = FilterCriterionProperties();
	Этот["ChildObjects"] = FilterCriterionChildObjects();
	Возврат Этот;
КонецФункции // FilterCriterion()

Функция FilterCriterionProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Type"] = "TypeDescription";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["Content"] = "MDListType";
	Этот["DefaultForm"] = "MDObjectRef";
	Этот["AuxiliaryForm"] = "MDObjectRef";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // FilterCriterionProperties()

Функция FilterCriterionChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Form"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // FilterCriterionChildObjects()

#КонецОбласти // FilterCriterion

#Область FunctionalOption

Функция FunctionalOption()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = FunctionalOptionProperties();
	Этот["ChildObjects"] = FunctionalOptionChildObjects();
	Возврат Этот;
КонецФункции // FunctionalOption()

Функция FunctionalOptionProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Location"] = "MDObjectRef";
	Этот["PrivilegedGetMode"] = "String"; // Enums.Boolean;
	//Этот["Content"]            = FuncOptionContentType();
	Возврат Этот;
КонецФункции // FunctionalOptionProperties()

Функция FunctionalOptionChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // FunctionalOptionChildObjects()

#КонецОбласти // FunctionalOption

#Область FunctionalOptionsParameter

Функция FunctionalOptionsParameter()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = FunctionalOptionsParameterProperties();
	Этот["ChildObjects"] = FunctionalOptionsParameterChildObjects();
	Возврат Этот;
КонецФункции // FunctionalOptionsParameter()

Функция FunctionalOptionsParameterProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Use"] = "MDListType";
	Возврат Этот;
КонецФункции // FunctionalOptionsParameterProperties()

Функция FunctionalOptionsParameterChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // FunctionalOptionsParameterChildObjects()

#КонецОбласти // FunctionalOptionsParameter

#Область HTTPService

Функция HTTPService()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = HTTPServiceProperties();
	Этот["ChildObjects"] = HTTPServiceChildObjects();
	Возврат Этот;
КонецФункции // HTTPService()

Функция HTTPServiceProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["RootURL"] = "String";
	Этот["ReuseSessions"] = "String"; // Enums.SessionReuseMode;
	Этот["SessionMaxAge"] = "Decimal";
	Возврат Этот;
КонецФункции // HTTPServiceProperties()

Функция HTTPServiceChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	//Элементы["URLTemplate"] = ;
	Возврат Этот;
КонецФункции // HTTPServiceChildObjects()

#КонецОбласти // HTTPService

#Область InformationRegister

Функция InformationRegister()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = InformationRegisterProperties();
	Этот["ChildObjects"] = InformationRegisterChildObjects();
	Возврат Этот;
КонецФункции // InformationRegister()

Функция InformationRegisterProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["EditType"] = "String"; // Enums.EditType;
	Этот["DefaultRecordForm"] = "MDObjectRef";
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["AuxiliaryRecordForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["InformationRegisterPeriodicity"] = "String"; // Enums.InformationRegisterPeriodicity;
	Этот["WriteMode"] = "String"; // Enums.RegisterWriteMode;
	Этот["MainFilterOnPeriod"] = "String"; // Enums.Boolean;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["EnableTotalsSliceFirst"] = "String"; // Enums.Boolean;
	Этот["EnableTotalsSliceLast"] = "String"; // Enums.Boolean;
	Этот["RecordPresentation"] = "LocalStringType";
	Этот["ExtendedRecordPresentation"] = "LocalStringType";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Этот["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат Этот;
КонецФункции // InformationRegisterProperties()

Функция InformationRegisterChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Resource"] = "Resource";
	Элементы["Attribute"] = "Attribute";
	Элементы["Dimension"] = "Dimension";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // InformationRegisterChildObjects()

#КонецОбласти // InformationRegister

#Область Report

Функция Report()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ReportProperties();
	Этот["ChildObjects"] = ReportChildObjects();
	Возврат Этот;
КонецФункции // Report()

Функция ReportProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["DefaultForm"] = "MDObjectRef";
	Этот["AuxiliaryForm"] = "MDObjectRef";
	Этот["MainDataCompositionSchema"] = "MDObjectRef";
	Этот["DefaultSettingsForm"] = "MDObjectRef";
	Этот["AuxiliarySettingsForm"] = "MDObjectRef";
	Этот["DefaultVariantForm"] = "MDObjectRef";
	Этот["VariantsStorage"] = "MDObjectRef";
	Этот["SettingsStorage"] = "MDObjectRef";
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["ExtendedPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // ReportProperties()

Функция ReportChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Элементы["TabularSection"] = "TabularSection";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // ReportChildObjects()

#КонецОбласти // Report

#Область Role

Функция Role()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = RoleProperties();
	Этот["ChildObjects"] = RoleChildObjects();
	Возврат Этот;
КонецФункции // Role()

Функция RoleProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Возврат Этот;
КонецФункции // RoleProperties()

Функция RoleChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // RoleChildObjects()

#КонецОбласти // Role

#Область ScheduledJob

Функция ScheduledJob()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ScheduledJobProperties();
	Этот["ChildObjects"] = ScheduledJobChildObjects();
	Возврат Этот;
КонецФункции // ScheduledJob()

Функция ScheduledJobProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["MethodName"] = "MDMethodRef";
	Этот["Description"] = "String";
	Этот["Key"] = "String";
	Этот["Use"] = "String"; // Enums.Boolean;
	Этот["Predefined"] = "String"; // Enums.Boolean;
	Этот["RestartCountOnFailure"] = "Decimal";
	Этот["RestartIntervalOnFailure"] = "Decimal";
	Возврат Этот;
КонецФункции // ScheduledJobProperties()

Функция ScheduledJobChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // ScheduledJobChildObjects()

#КонецОбласти // ScheduledJob

#Область Sequence

Функция Sequence()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = SequenceProperties();
	Этот["ChildObjects"] = SequenceChildObjects();
	Возврат Этот;
КонецФункции // Sequence()

Функция SequenceProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["MoveBoundaryOnPosting"] = "String"; // Enums.MoveBoundaryOnPosting;
	Этот["Documents"] = "MDListType";
	Этот["RegisterRecords"] = "MDListType";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Возврат Этот;
КонецФункции // SequenceProperties()

Функция SequenceChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Dimension"] = "Dimension";
	Возврат Этот;
КонецФункции // SequenceChildObjects()

#КонецОбласти // Sequence

#Область SessionParameter

Функция SessionParameter()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = SessionParameterProperties();
	Этот["ChildObjects"] = SessionParameterChildObjects();
	Возврат Этот;
КонецФункции // SessionParameter()

Функция SessionParameterProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Type"] = "TypeDescription";
	Возврат Этот;
КонецФункции // SessionParameterProperties()

Функция SessionParameterChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // SessionParameterChildObjects()

#КонецОбласти // SessionParameter

#Область SettingsStorage

Функция SettingsStorage()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = SettingsStorageProperties();
	Этот["ChildObjects"] = SettingsStorageChildObjects();
	Возврат Этот;
КонецФункции // SettingsStorage()

Функция SettingsStorageProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["DefaultSaveForm"] = "MDObjectRef";
	Этот["DefaultLoadForm"] = "MDObjectRef";
	Этот["AuxiliarySaveForm"] = "MDObjectRef";
	Этот["AuxiliaryLoadForm"] = "MDObjectRef";
	Возврат Этот;
КонецФункции // SettingsStorageProperties()

Функция SettingsStorageChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Возврат Этот;
КонецФункции // SettingsStorageChildObjects()

#КонецОбласти // SettingsStorage

#Область Subsystem

Функция Subsystem()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = SubsystemProperties();
	Этот["ChildObjects"] = SubsystemChildObjects();
	Возврат Этот;
КонецФункции // Subsystem()

Функция SubsystemProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["IncludeInCommandInterface"] = "String"; // Enums.Boolean;
	Этот["Explanation"] = "LocalStringType";
	//Этот["Picture"]                    = ;
	Этот["Content"] = "MDListType";
	Возврат Этот;
КонецФункции // SubsystemProperties()

Функция SubsystemChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Subsystem"] = "String";
	Возврат Этот;
КонецФункции // SubsystemChildObjects()

#КонецОбласти // Subsystem

#Область Task

Функция Task()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = TaskProperties();
	Этот["ChildObjects"] = TaskChildObjects();
	Возврат Этот;
КонецФункции // Task()

Функция TaskProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["UseStandardCommands"] = "String"; // Enums.Boolean;
	Этот["NumberType"] = "String"; // Enums.TaskNumberType;
	Этот["NumberLength"] = "Decimal";
	Этот["NumberAllowedLength"] = "String"; // Enums.AllowedLength;
	Этот["CheckUnique"] = "String"; // Enums.Boolean;
	Этот["Autonumbering"] = "String"; // Enums.Boolean;
	Этот["TaskNumberAutoPrefix"] = "String"; // Enums.TaskNumberAutoPrefix;
	Этот["DescriptionLength"] = "Decimal";
	Этот["Addressing"] = "MDObjectRef";
	Этот["MainAddressingAttribute"] = "MDObjectRef";
	Этот["CurrentPerformer"] = "MDObjectRef";
	Этот["BasedOn"] = "MDListType";
	Этот["StandardAttributes"] = "StandardAttributes";
	Этот["Characteristics"] = "Characteristics";
	Этот["DefaultPresentation"] = "String"; // Enums.TaskMainPresentation;
	Этот["EditType"] = "String"; // Enums.EditType;
	Этот["InputByString"] = "FieldList";
	Этот["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	Этот["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	Этот["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	Этот["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	Этот["DefaultObjectForm"] = "MDObjectRef";
	Этот["DefaultListForm"] = "MDObjectRef";
	Этот["DefaultChoiceForm"] = "MDObjectRef";
	Этот["AuxiliaryObjectForm"] = "MDObjectRef";
	Этот["AuxiliaryListForm"] = "MDObjectRef";
	Этот["AuxiliaryChoiceForm"] = "MDObjectRef";
	Этот["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Этот["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	Этот["DataLockFields"] = "FieldList";
	Этот["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Этот["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Этот["ObjectPresentation"] = "LocalStringType";
	Этот["ExtendedObjectPresentation"] = "LocalStringType";
	Этот["ListPresentation"] = "LocalStringType";
	Этот["ExtendedListPresentation"] = "LocalStringType";
	Этот["Explanation"] = "LocalStringType";
	Возврат Этот;
КонецФункции // TaskProperties()

Функция TaskChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = "Attribute";
	Элементы["TabularSection"] = "TabularSection";
	Элементы["Form"] = "String";
	Элементы["Template"] = "String";
	Элементы["AddressingAttribute"] = "AddressingAttribute";
	Элементы["Command"] = "Command";
	Возврат Этот;
КонецФункции // TaskChildObjects()

#КонецОбласти // Task

#Область WebService

Функция WebService()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = WebServiceProperties();
	Этот["ChildObjects"] = WebServiceChildObjects();
	Возврат Этот;
КонецФункции // WebService()

Функция WebServiceProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Namespace"] = "String";
	//Этот["XDTOPackages"]        = "ValueList";
	Этот["DescriptorFileName"] = "String";
	Этот["ReuseSessions"] = "String"; // Enums.SessionReuseMode;
	Этот["SessionMaxAge"] = "Decimal";
	Возврат Этот;
КонецФункции // WebServiceProperties()

Функция WebServiceChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Operation"] = Operation();
	Возврат Этот;
КонецФункции // WebServiceChildObjects()

Функция Operation()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = OperationProperties();
	Этот["ChildObjects"] = OperationChildObjects();
	Возврат Этот;
КонецФункции // Operation()

Функция OperationProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["XDTOReturningValueType"] = "QName";
	Этот["Nillable"] = "String"; // Enums.Boolean;
	Этот["Transactioned"] = "String"; // Enums.Boolean;
	Этот["ProcedureName"] = "String";
	Возврат Этот;
КонецФункции // OperationProperties()

Функция OperationChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Parameter"] = Parameter();
	Возврат Этот;
КонецФункции // OperationChildObjects()

Функция Parameter()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = ParameterProperties();
	Возврат Этот;
КонецФункции // Parameter()

Функция ParameterProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["XDTOValueType"] = "QName";
	Этот["Nillable"] = "String"; // Enums.Boolean;
	Этот["TransferDirection"] = "String"; // Enums.TransferDirection;
	Возврат Этот;
КонецФункции // ParameterProperties()

#КонецОбласти // WebService

#Область WSReference

Функция WSReference()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = WSReferenceProperties();
	Этот["ChildObjects"] = WSReferenceChildObjects();
	Возврат Этот;
КонецФункции // WSReference()

Функция WSReferenceProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["LocationURL"] = "String";
	Возврат Этот;
КонецФункции // WSReferenceProperties()

Функция WSReferenceChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // WSReferenceChildObjects()

#КонецОбласти // WSReference

#Область XDTOPackage

Функция XDTOPackage()
	Этот = Структура(MDObjectBase());
	Этот["Properties"] = XDTOPackageProperties();
	Этот["ChildObjects"] = XDTOPackageChildObjects();
	Возврат Этот;
КонецФункции // XDTOPackage()

Функция XDTOPackageProperties()
	Этот = Структура();
	Этот["Name"] = "String";
	Этот["Synonym"] = "LocalStringType";
	Этот["Comment"] = "String";
	Этот["Namespace"] = "String";
	Возврат Этот;
КонецФункции // XDTOPackageProperties()

Функция XDTOPackageChildObjects()
	Этот = Объект();
	Элементы = Этот.Элементы;

	Возврат Этот;
КонецФункции // XDTOPackageChildObjects()

#КонецОбласти // XDTOPackage

#КонецОбласти // MetaDataObject

#Область LogForm

Функция LogForm()
	Этот = Структура();
	Этот["Title"] = "LocalStringType";
	Этот["Width"] = "Decimal";
	Этот["Height"] = "Decimal";
	Этот["VerticalScroll"] = "String"; // Enums.VerticalFormScroll;
	Этот["WindowOpeningMode"] = "String"; // Enums.FormWindowOpeningMode;
	Этот["Attributes"] = FormAttributes();
	Этот["Events"] = FormEvents();
	Этот["ChildItems"] = "FormChildItems";
	Возврат Этот;
КонецФункции // LogForm()

Функция FormItemBase()
	Этот = Структура();
	Этот["id"] = "Decimal";
	Этот["name"] = "String";
	Возврат Этот;
КонецФункции // FormItemBase()

Функция FormChildItems()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["UsualGroup"] = FormUsualGroup();
	Возврат Этот;
КонецФункции // FormChildItems()

Функция FormUsualGroup()
	Этот = Структура(FormItemBase());
	Этот["HorizontalAlign"] = "String"; // Enums.ItemHorizontalLocation;
	Этот["United"] = "Boolean";
	Этот["ShowTitle"] = "Boolean";
	Этот["ChildItems"] = "FormChildItems";
	Возврат Этот;
КонецФункции // FormUsualGroup()

#Область Events

Функция FormEvents()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Event"] = FormEvent();
	Возврат Этот;
КонецФункции // FormEvents()

Функция FormEvent()
	Этот = Структура();
	Этот["name"] = "String";
	Этот["_"] = "String";
	Возврат Этот;
КонецФункции // FormEvent()

#КонецОбласти // Events

#Область Attributes

Функция FormAttributes()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Attribute"] = FormAttribute();
	Возврат Этот;
КонецФункции // FormAttributes()

Функция FormAttribute()
	Этот = Структура();
	Этот["name"] = "String";
	Этот["Title"] = "LocalStringType";
	Этот["SavedData"] = "Boolean";
	Этот["Columns"] = FormAttributeColumns();
	Возврат Этот;
КонецФункции // FormAttribute()

#Область Columns

Функция FormAttributeColumns()
	Этот = Объект();
	Элементы = Этот.Элементы;
	Элементы["Column"] = FormAttributeColumn();
	Возврат Этот;
КонецФункции // FormAttributeColumns()

Функция FormAttributeColumn()
	Этот = Структура();
	Этот["name"] = "String";
	Этот["Title"] = "LocalStringType";
	Возврат Этот;
КонецФункции // FormAttributeColumn()

#КонецОбласти // Columns

#КонецОбласти // Attributes

#КонецОбласти