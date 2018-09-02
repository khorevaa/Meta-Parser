
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
	Виды.Insert("String", Новый ОписаниеТипов("String"));
	Виды.Insert("Boolean", Новый ОписаниеТипов("Boolean"));
	Виды.Insert("Decimal", Новый ОписаниеТипов("Number"));
	Виды.Insert("UUID", "String");

	// simple
	Виды.Insert("MDObjectRef", "String");
	Виды.Insert("MDMethodRef", "String");
	Виды.Insert("FieldRef", "String");
	Виды.Insert("DataPath", "String");
	Виды.Insert("IncludeInCommandCategoriesType", "String");
	Виды.Insert("QName", "String");

	// common
	Виды.Insert("LocalStringType", LocalStringType());
	Виды.Insert("MDListType", MDListType());
	Виды.Insert("FieldList", FieldList());
	Виды.Insert("ChoiceParameterLinks", ChoiceParameterLinks());
	Виды.Insert("TypeLink", TypeLink());
	Виды.Insert("StandardAttributes", StandardAttributes());
	Виды.Insert("StandardTabularSections", StandardTabularSections());
	Виды.Insert("Characteristics", Characteristics());
	Виды.Insert("AccountingFlag", AccountingFlag());
	Виды.Insert("ExtDimensionAccountingFlag", ExtDimensionAccountingFlag());
	Виды.Insert("AddressingAttribute", AddressingAttribute());
	Виды.Insert("TypeDescription", TypeDescription());

	// metadata objects
	Виды.Insert("MetaDataObject", MetaDataObject());
	Виды.Insert("Attribute", Attribute());
	Виды.Insert("Dimension", Dimension());
	Виды.Insert("Resource", Resource());
	Виды.Insert("TabularSection", TabularSection());
	Виды.Insert("Command", Command());
	Виды.Insert("Configuration", Configuration());
	Виды.Insert("Language", Language());
	Виды.Insert("AccountingRegister", AccountingRegister());
	Виды.Insert("AccumulationRegister", AccumulationRegister());
	Виды.Insert("BusinessProcess", BusinessProcess());
	Виды.Insert("CalculationRegister", CalculationRegister());
	Виды.Insert("Catalog", Catalog());
	Виды.Insert("ChartOfAccounts", ChartOfAccounts());
	Виды.Insert("ChartOfCalculationTypes", ChartOfCalculationTypes());
	Виды.Insert("ChartOfCharacteristicTypes", ChartOfCharacteristicTypes());
	Виды.Insert("CommandGroup", CommandGroup());
	Виды.Insert("CommonAttribute", CommonAttribute());
	Виды.Insert("CommonCommand", CommonCommand());
	Виды.Insert("CommonForm", CommonForm());
	Виды.Insert("CommonModule", CommonModule());
	Виды.Insert("CommonPicture", CommonPicture());
	Виды.Insert("CommonTemplate", CommonTemplate());
	Виды.Insert("Constant", Constant());
	Виды.Insert("DataProcessor", DataProcessor());
	Виды.Insert("DocumentJournal", DocumentJournal());
	Виды.Insert("DocumentNumerator", DocumentNumerator());
	Виды.Insert("Document", Document());
	Виды.Insert("Enum", Enum());
	Виды.Insert("EventSubscription", EventSubscription());
	Виды.Insert("ExchangePlan", ExchangePlan());
	Виды.Insert("FilterCriterion", FilterCriterion());
	Виды.Insert("FunctionalOption", FunctionalOption());
	Виды.Insert("FunctionalOptionsParameter", FunctionalOptionsParameter());
	Виды.Insert("HTTPService", HTTPService());
	Виды.Insert("InformationRegister", InformationRegister());
	Виды.Insert("Report", Report());
	Виды.Insert("Role", Role());
	Виды.Insert("ScheduledJob", ScheduledJob());
	Виды.Insert("Sequence", Sequence());
	Виды.Insert("SessionParameter", SessionParameter());
	Виды.Insert("SettingsStorage", SettingsStorage());
	Виды.Insert("Subsystem", Subsystem());
	Виды.Insert("Task", Task());
	Виды.Insert("Template", Template());
	Виды.Insert("WebService", WebService());
	Виды.Insert("WSReference", WSReference());
	Виды.Insert("XDTOPackage", XDTOPackage());
	Виды.Insert("Form", Form());

	// logform
	Виды.Insert("LogForm", LogForm());
	Виды.Insert("FormChildItems", FormChildItems());

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
	Объект = Новый Структура("Элементы", Новый Map);
	Если База <> Неопределено Тогда
		Для Каждого Item Из База.Items Цикл
			Объект.Items.Add(Item);
		КонецЦикла;
	КонецЕсли;
	Возврат Объект;
КонецФункции // Объект()

#КонецОбласти // Kinds

#Область Common

Функция LocalStringType()
	This = Объект();
	Элементы = This.Элементы;
	Элементы["item"] = LocalStringTypeItem();
	Возврат This;
КонецФункции // LocalStringType()

Функция LocalStringTypeItem()
	This = Структура();
	This["lang"] = "String";
	This["content"] = "String";
	Возврат This;
КонецФункции // LocalStringTypeItem()

Функция MDListType()
	This = Объект();
	Элементы = This.Элементы;
	Элементы["Item"] = MDListTypeItem();
	Возврат This;
КонецФункции // MDListType()

Функция MDListTypeItem()
	This = Структура();
	This["type"] = "String";
	This["_"] = "String";
	Возврат This;
КонецФункции // MDListTypeItem()

Функция FieldList()
	This = Объект();
	Items = This.Элементы;
	Items["Field"] = FieldListItem();
	Возврат This;
КонецФункции // FieldList()

Функция FieldListItem()
	This = Структура();
	This["type"] = "String";
	This["_"] = "String";
	Возврат This;
КонецФункции // FieldListItem()

Функция ChoiceParameterLinks()
	This = Объект();
	Items = This.Элементы;
	Items["Link"] = ChoiceParameterLink();
	Возврат This;
КонецФункции // ChoiceParameterLinks()

Функция ChoiceParameterLink()
	This = Структура();
	This["Name"] = "String";
	This["DataPath"] = "String";
	This["ValueChange"] = "String"; // Enums.LinkedValueChangeMode;
	Возврат This;
КонецФункции // ChoiceParameterLink()

Функция TypeLink() // todo: check
	This = Структура();
	This["DataPath"] = "DataPath";
	This["LinkItem"] = "Decimal";
	This["ValueChange"] = "String"; // Enums.LinkedValueChangeMode;
	Возврат This;
КонецФункции // TypeLink()

Функция StandardAttributes()
	This = Объект();
	Items = This.Элементы;
	Items["StandardAttribute"] = StandardAttribute();
	Возврат This;
КонецФункции // StandardAttributes()

Функция StandardAttribute()
	This = Структура();
	This["name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["ToolTip"] = "LocalStringType";
	This["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	This["FillChecking"] = "String"; // Enums.FillChecking;
	//This["FillValue"]             = ;
	This["FillFromFillingValue"] = "String"; // Enums.Boolean;
	This["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//This["ChoiceParameters"]      = ;
	This["LinkByType"] = "TypeLink";
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["PasswordMode"] = "String"; // Enums.Boolean;
	This["DataHistory"] = "String"; // Enums.DataHistoryUse;
	This["Format"] = "LocalStringType";
	This["EditFormat"] = "LocalStringType";
	This["Mask"] = "String";
	This["MultiLine"] = "String"; // Enums.Boolean;
	This["ExtendedEdit"] = "String"; // Enums.Boolean;
	//This["MinValue"]              = ;
	//This["MaxValue"]              = ;
	This["MarkNegatives"] = "String"; // Enums.Boolean;
	This["ChoiceForm"] = "MDObjectRef";
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Возврат This;
КонецФункции // StandardAttribute()

Функция StandardTabularSections()
	This = Объект();
	Items = This.Элементы;
	Items["StandardTabularSection"] = StandardTabularSection();
	Возврат This;
КонецФункции // StandardTabularSections()

Функция StandardTabularSection()
	This = Структура();
	This["name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["ToolTip"] = "LocalStringType";
	This["FillChecking"] = "String"; // Enums.FillChecking;
	This["StandardAttributes"] = "StandardAttributes";
	Возврат This;
КонецФункции // StandardTabularSection()

Функция Characteristics()
	This = Объект();
	Items = This.Элементы;
	Items["Characteristic"] = Characteristic();
	Возврат This;
КонецФункции // Characteristics()

Функция Characteristic()
	This = Структура();
	This["CharacteristicTypes"] = CharacteristicTypes();
	This["CharacteristicValues"] = CharacteristicValues();
	Возврат This;
КонецФункции // Characteristic()

Функция CharacteristicTypes()
	This = Структура();
	This["from"] = "MDObjectRef";
	This["KeyField"] = "FieldRef";
	This["TypesFilterField"] = "FieldRef";
	//This["TypesFilterValue"] = ;
	Возврат This;
КонецФункции // CharacteristicTypes()

Функция CharacteristicValues()
	This = Структура();
	This["from"] = "MDObjectRef";
	This["ObjectField"] = "FieldRef";
	This["TypeField"] = "FieldRef";
	//This["ValueField"] = ;
	Возврат This;
КонецФункции // CharacteristicValues()

Функция TypeDescription()
	This = Объект();
	Items = This.Элементы;
	Items["Type"] = "QName";
	Items["TypeSet"] = "QName";
	Items["TypeId"] = "UUID";
	Items["NumberQualifiers"] = NumberQualifiers();
	Items["StringQualifiers"] = StringQualifiers();
	Items["DateQualifiers"] = DateQualifiers();
	Items["BinaryDataQualifiers"] = BinaryDataQualifiers();
	Возврат This;
КонецФункции // TypeDescription()

Функция NumberQualifiers()
	This = Структура();
	This["Digits"] = "Decimal";
	This["FractionDigits"] = "Decimal";
	This["AllowedSign"] = "String"; // Enums.AllowedSign;
	Возврат This;
КонецФункции // NumberQualifiers()

Функция StringQualifiers()
	This = Структура();
	This["Length"] = "Decimal";
	This["AllowedLength"] = "String"; // Enums.AllowedLength;
	Возврат This;
КонецФункции // StringQualifiers()

Функция DateQualifiers()
	This = Структура();
	This["DateFractions"] = "String"; // Enums.DateFractions;
	Возврат This;
КонецФункции // DateQualifiers()

Функция BinaryDataQualifiers()
	This = Структура();
	This["Length"] = "Decimal";
	This["AllowedLength"] = "String"; // Enums.AllowedLength;
	Возврат This;
КонецФункции // BinaryDataQualifiers()

#КонецОбласти // Common

#Область MetaDataObject

Функция MetaDataObject()
	This = Структура();
	This["version"] = "Decimal";
	This["Configuration"] = Configuration();
	This["Language"] = Language();
	This["AccountingRegister"] = AccountingRegister();
	This["AccumulationRegister"] = AccumulationRegister();
	This["BusinessProcess"] = BusinessProcess();
	This["CalculationRegister"] = CalculationRegister();
	This["Catalog"] = Catalog();
	This["ChartOfAccounts"] = ChartOfAccounts();
	This["ChartOfCalculationTypes"] = ChartOfCalculationTypes();
	This["ChartOfCharacteristicTypes"] = ChartOfCharacteristicTypes();
	This["CommandGroup"] = CommandGroup();
	This["CommonAttribute"] = CommonAttribute();
	This["CommonCommand"] = CommonCommand();
	This["CommonForm"] = CommonForm();
	This["CommonModule"] = CommonModule();
	This["CommonPicture"] = CommonPicture();
	This["CommonTemplate"] = CommonTemplate();
	This["Constant"] = Constant();
	This["DataProcessor"] = DataProcessor();
	This["DocumentJournal"] = DocumentJournal();
	This["DocumentNumerator"] = DocumentNumerator();
	This["Document"] = Document();
	This["Enum"] = Enum();
	This["EventSubscription"] = EventSubscription();
	This["ExchangePlan"] = ExchangePlan();
	This["FilterCriterion"] = FilterCriterion();
	This["FunctionalOption"] = FunctionalOption();
	This["FunctionalOptionsParameter"] = FunctionalOptionsParameter();
	This["HTTPService"] = HTTPService();
	This["InformationRegister"] = InformationRegister();
	This["Report"] = Report();
	This["Role"] = Role();
	This["ScheduledJob"] = ScheduledJob();
	This["Sequence"] = Sequence();
	This["SessionParameter"] = SessionParameter();
	This["SettingsStorage"] = SettingsStorage();
	This["Subsystem"] = Subsystem();
	This["Task"] = Task();
	This["Template"] = Template();
	This["WebService"] = WebService();
	This["WSReference"] = WSReference();
	This["XDTOPackage"] = XDTOPackage();
	This["Form"] = Form();
	Возврат This;
КонецФункции // MetaDataObject()

Функция MDObjectBase()
	This = Структура();
	This["uuid"] = "UUID";
	//This["InternalInfo"] = InternalInfo();
	Возврат This;
КонецФункции // MDObjectBase()

#Область ChildObjects

#Область Attribute

Функция Attribute()
	This = Структура(MDObjectBase());
	This["Properties"] = AttributeProperties();
	Возврат This;
КонецФункции // Attribute()

Функция AttributeProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Type"] = "TypeDescription";
	This["PasswordMode"] = "String"; // Enums.Boolean;
	This["Format"] = "LocalStringType";
	This["EditFormat"] = "LocalStringType";
	This["ToolTip"] = "LocalStringType";
	This["MarkNegatives"] = "String"; // Enums.Boolean;
	This["Mask"] = "String";
	This["MultiLine"] = "String"; // Enums.Boolean;
	This["ExtendedEdit"] = "String"; // Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//This["FillValue"]              = ;
	This["FillChecking"] = "String"; // Enums.FillChecking;
	This["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceForm"] = "MDObjectRef";
	This["LinkByType"] = "TypeLink";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["Indexing"] = "String"; // Enums.Indexing;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["Use"] = "String"; // Enums.AttributeUse;
	This["ScheduleLink"] = "MDObjectRef";
	This["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат This;
КонецФункции // AttributeProperties()

#КонецОбласти // Attribute

#Область Dimension

Функция Dimension()
	This = Структура(MDObjectBase());
	This["Properties"] = DimensionProperties();
	Возврат This;
КонецФункции // Dimension()

Функция DimensionProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Type"] = "TypeDescription";
	This["PasswordMode"] = "String"; // Enums.Boolean;
	This["Format"] = "LocalStringType";
	This["EditFormat"] = "LocalStringType";
	This["ToolTip"] = "LocalStringType";
	This["MarkNegatives"] = "String"; // Enums.Boolean;
	This["Mask"] = "String";
	This["MultiLine"] = "String"; // Enums.Boolean;
	This["ExtendedEdit"] = "String"; // Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillChecking"] = "String"; // Enums.FillChecking;
	This["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceForm"] = "MDObjectRef";
	This["LinkByType"] = "TypeLink";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["Balance"] = "String"; // Enums.Boolean;
	This["AccountingFlag"] = "MDObjectRef";
	This["DenyIncompleteValues"] = "String"; // Enums.Boolean;
	This["Indexing"] = "String"; // Enums.Indexing;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["UseInTotals"] = "String"; // Enums.Boolean;
	This["RegisterDimension"] = "MDObjectRef";
	This["LeadingRegisterData"] = "MDListType";
	This["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//This["FillValue"]              = ;
	This["Master"] = "String"; // Enums.Boolean;
	This["MainFilter"] = "String"; // Enums.Boolean;
	This["BaseDimension"] = "String"; // Enums.Boolean;
	This["ScheduleLink"] = "MDObjectRef";
	This["DocumentMap"] = "MDListType";
	This["RegisterRecordsMap"] = "MDListType";
	This["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат This;
КонецФункции // DimensionProperties()

#КонецОбласти // Dimension

#Область Resource

Функция Resource()
	This = Структура(MDObjectBase());
	This["Properties"] = ResourceProperties();
	Возврат This;
КонецФункции // Resource()

Функция ResourceProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Type"] = "TypeDescription";
	This["PasswordMode"] = "String"; // Enums.Boolean;
	This["Format"] = "LocalStringType";
	This["EditFormat"] = "LocalStringType";
	This["ToolTip"] = "LocalStringType";
	This["MarkNegatives"] = "String"; // Enums.Boolean;
	This["Mask"] = "String";
	This["MultiLine"] = "String"; // Enums.Boolean;
	This["ExtendedEdit"] = "String"; // Enums.Boolean;
	//This["MinValue"]                    = ;
	//This["MaxValue"]                    = ;
	This["FillChecking"] = "String"; // Enums.FillChecking;
	This["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//This["ChoiceParameters"]            = ;
	This["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceForm"] = "MDObjectRef";
	This["LinkByType"] = "TypeLink";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["Balance"] = "String"; // Enums.Boolean;
	This["AccountingFlag"] = "MDObjectRef";
	This["ExtDimensionAccountingFlag"] = "MDObjectRef";
	This["NameInDataSource"] = "String";
	This["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//This["FillValue"]                   = ;
	This["Indexing"] = "String"; // Enums.Indexing;
	This["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат This;
КонецФункции // ResourceProperties()

#КонецОбласти // Resource

#Область AccountingFlag

Функция AccountingFlag()
	This = Структура(MDObjectBase());
	This["Properties"] = AccountingFlagProperties();
	Возврат This;
КонецФункции // AccountingFlag()

Функция AccountingFlagProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Type"] = "TypeDescription";
	This["PasswordMode"] = "String"; // Enums.Boolean;
	This["Format"] = "LocalStringType";
	This["EditFormat"] = "LocalStringType";
	This["ToolTip"] = "LocalStringType";
	This["MarkNegatives"] = "String"; // Enums.Boolean;
	This["Mask"] = "String";
	This["MultiLine"] = "String"; // Enums.Boolean;
	This["ExtendedEdit"] = "String"; // Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//This["FillValue"]              = ;
	This["FillChecking"] = "String"; // Enums.FillChecking;
	This["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceForm"] = "MDObjectRef";
	This["LinkByType"] = "TypeLink";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Возврат This;
КонецФункции // AccountingFlagProperties()

#КонецОбласти // AccountingFlag

#Область ExtDimensionAccountingFlag

Функция ExtDimensionAccountingFlag()
	This = Структура(MDObjectBase());
	This["Properties"] = ExtDimensionAccountingFlagProperties();
	Возврат This;
КонецФункции // ExtDimensionAccountingFlag()

Функция ExtDimensionAccountingFlagProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Type"] = "TypeDescription";
	This["PasswordMode"] = "String"; // Enums.Boolean;
	This["Format"] = "LocalStringType";
	This["EditFormat"] = "LocalStringType";
	This["ToolTip"] = "LocalStringType";
	This["MarkNegatives"] = "String"; // Enums.Boolean;
	This["Mask"] = "String";
	This["MultiLine"] = "String"; // Enums.Boolean;
	This["ExtendedEdit"] = "String"; // Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//This["FillValue"]              = ;
	This["FillChecking"] = "String"; // Enums.FillChecking;
	This["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceForm"] = "MDObjectRef";
	This["LinkByType"] = "TypeLink";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Возврат This;
КонецФункции // ExtDimensionAccountingFlagProperties()

#КонецОбласти // ExtDimensionAccountingFlag

#Область Column

Функция Column()
	This = Структура(MDObjectBase());
	This["Properties"] = ColumnProperties();
	Возврат This;
КонецФункции // Column()

Функция ColumnProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Indexing"] = "String"; // Enums.Indexing;
	This["References"] = "MDListType";
	Возврат This;
КонецФункции // ColumnProperties()

#КонецОбласти // Column

#Область EnumValue

Функция EnumValue()
	This = Структура(MDObjectBase());
	This["Properties"] = EnumValueProperties();
	Возврат This;
КонецФункции // EnumValue()

Функция EnumValueProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	Возврат This;
КонецФункции // EnumValueProperties()

#КонецОбласти // EnumValue

#Область Form

Функция Form()
	This = Структура(MDObjectBase());
	This["Properties"] = FormProperties();
	Возврат This;
КонецФункции // Form()

Функция FormProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["FormType"] = "String"; // Enums.FormType;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	//This["UsePurposes"]            = "FixedArray";
	This["ExtendedPresentation"] = "LocalStringType";
	Возврат This;
КонецФункции // FormProperties()

#КонецОбласти // Form

#Область Template

Функция Template()
	This = Структура(MDObjectBase());
	This["Properties"] = TemplateProperties();
	Возврат This;
КонецФункции // Template()

Функция TemplateProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["TemplateType"] = "String"; // Enums.TemplateType;
	Возврат This;
КонецФункции // TemplateProperties()

#КонецОбласти // Template

#Область AddressingAttribute

Функция AddressingAttribute()
	This = Структура(MDObjectBase());
	This["Properties"] = AddressingAttributeProperties();
	Возврат This;
КонецФункции // AddressingAttribute()

Функция AddressingAttributeProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Type"] = "TypeDescription";
	This["PasswordMode"] = "String"; // Enums.Boolean;
	This["Format"] = "LocalStringType";
	This["EditFormat"] = "LocalStringType";
	This["ToolTip"] = "LocalStringType";
	This["MarkNegatives"] = "String"; // Enums.Boolean;
	This["Mask"] = "String";
	This["MultiLine"] = "String"; // Enums.Boolean;
	This["ExtendedEdit"] = "String"; // Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//This["FillValue"]              = ;
	This["FillChecking"] = "String"; // Enums.FillChecking;
	This["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceForm"] = "MDObjectRef";
	This["LinkByType"] = "TypeLink";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["Indexing"] = "String"; // Enums.Indexing;
	This["AddressingDimension"] = "MDObjectRef";
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	Возврат This;
КонецФункции // AddressingAttributeProperties()

#КонецОбласти // AddressingAttribute

#Область TabularSection

Функция TabularSection()
	This = Структура(MDObjectBase());
	This["Properties"] = TabularSectionProperties();
	This["ChildObjects"] = TabularSectionChildObjects();
	Возврат This;
КонецФункции // TabularSection()

Функция TabularSectionProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["ToolTip"] = "LocalStringType";
	This["FillChecking"] = "String"; // Enums.FillChecking;
	This["StandardAttributes"] = "StandardAttributes";
	This["Use"] = "String"; // Enums.AttributeUse;
	Возврат This;
КонецФункции // TabularSectionProperties()

Функция TabularSectionChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Возврат This;
КонецФункции // TabularSectionChildObjects()

#КонецОбласти // TabularSection

#Область Command

Функция Command()
	This = Структура(MDObjectBase());
	This["Properties"] = CommandProperties();
	Возврат This;
КонецФункции // Command()

Функция CommandProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Group"] = "IncludeInCommandCategoriesType";
	This["CommandParameterType"] = "TypeDescription";
	This["ParameterUseMode"] = "String"; // Enums.CommandParameterUseMode;
	This["ModifiesData"] = "String"; // Enums.Boolean;
	This["Representation"] = "String"; // Enums.ButtonRepresentation;
	This["ToolTip"] = "LocalStringType";
	//This["Picture"]               = ;
	//This["Shortcut"]              = ;
	Возврат This;
КонецФункции // CommandProperties()

#КонецОбласти // Command

#КонецОбласти // ChildObjects

#Область Configuration

Функция Configuration()
	This = Структура(MDObjectBase());
	This["Properties"] = ConfigurationProperties();
	This["ChildObjects"] = ConfigurationChildObjects();
	Возврат This;
КонецФункции // Configuration()

Функция ConfigurationProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["NamePrefix"] = "String";
	This["ConfigurationExtensionCompatibilityMode"] = "String"; // Enums.CompatibilityMode;
	This["DefaultRunMode"] = "String"; // Enums.ClientRunMode;
	//This["UsePurposes"]                                      = "FixedArray";
	This["ScriptVariant"] = "String"; // Enums.ScriptVariant;
	This["DefaultRoles"] = "MDListType";
	This["Vendor"] = "String";
	This["Version"] = "String";
	This["UpdateCatalogAddress"] = "String";
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["UseManagedFormInOrdinaryApplication"] = "String"; // Enums.Boolean;
	This["UseOrdinaryFormInManagedApplication"] = "String"; // Enums.Boolean;
	This["AdditionalFullTextSearchDictionaries"] = "MDListType";
	This["CommonSettingsStorage"] = "MDObjectRef";
	This["ReportsUserSettingsStorage"] = "MDObjectRef";
	This["ReportsVariantsStorage"] = "MDObjectRef";
	This["FormDataSettingsStorage"] = "MDObjectRef";
	This["DynamicListsUserSettingsStorage"] = "MDObjectRef";
	This["Content"] = "MDListType";
	This["DefaultReportForm"] = "MDObjectRef";
	This["DefaultReportVariantForm"] = "MDObjectRef";
	This["DefaultReportSettingsForm"] = "MDObjectRef";
	This["DefaultDynamicListSettingsForm"] = "MDObjectRef";
	This["DefaultSearchForm"] = "MDObjectRef";
	//This["RequiredMobileApplicationPermissions"]             = "FixedMap";
	This["MainClientApplicationWindowMode"] = "String"; // Enums.MainClientApplicationWindowMode;
	This["DefaultInterface"] = "MDObjectRef";
	This["DefaultStyle"] = "MDObjectRef";
	This["DefaultLanguage"] = "MDObjectRef";
	This["BriefInformation"] = "LocalStringType";
	This["DetailedInformation"] = "LocalStringType";
	This["Copyright"] = "LocalStringType";
	This["VendorInformationAddress"] = "LocalStringType";
	This["ConfigurationInformationAddress"] = "LocalStringType";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["ObjectAutonumerationMode"] = "String"; // Enums.ObjectAutonumerationMode;
	This["ModalityUseMode"] = "String"; // Enums.ModalityUseMode;
	This["SynchronousPlatformExtensionAndAddInCallUseMode"] = "String"; // Enums.SynchronousPlatformExtensionAndAddInCallUseMode;
	This["InterfaceCompatibilityMode"] = "String"; // Enums.InterfaceCompatibilityMode;
	This["CompatibilityMode"] = "String"; // Enums.CompatibilityMode;
	This["DefaultConstantsForm"] = "MDObjectRef";
	Возврат This;
КонецФункции // ConfigurationProperties()

Функция ConfigurationChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Language"] = "String";
	Items["Subsystem"] = "String";
	Items["StyleItem"] = "String";
	Items["Style"] = "String";
	Items["CommonPicture"] = "String";
	Items["Interface"] = "String";
	Items["SessionParameter"] = "String";
	Items["Role"] = "String";
	Items["CommonTemplate"] = "String";
	Items["FilterCriterion"] = "String";
	Items["CommonModule"] = "String";
	Items["CommonAttribute"] = "String";
	Items["ExchangePlan"] = "String";
	Items["XDTOPackage"] = "String";
	Items["WebService"] = "String";
	Items["HTTPService"] = "String";
	Items["WSReference"] = "String";
	Items["EventSubscription"] = "String";
	Items["ScheduledJob"] = "String";
	Items["SettingsStorage"] = "String";
	Items["FunctionalOption"] = "String";
	Items["FunctionalOptionsParameter"] = "String";
	Items["DefinedType"] = "String";
	Items["CommonCommand"] = "String";
	Items["CommandGroup"] = "String";
	Items["Constant"] = "String";
	Items["CommonForm"] = "String";
	Items["Catalog"] = "String";
	Items["Document"] = "String";
	Items["DocumentNumerator"] = "String";
	Items["Sequence"] = "String";
	Items["DocumentJournal"] = "String";
	Items["Enum"] = "String";
	Items["Report"] = "String";
	Items["DataProcessor"] = "String";
	Items["InformationRegister"] = "String";
	Items["AccumulationRegister"] = "String";
	Items["ChartOfCharacteristicTypes"] = "String";
	Items["ChartOfAccounts"] = "String";
	Items["AccountingRegister"] = "String";
	Items["ChartOfCalculationTypes"] = "String";
	Items["CalculationRegister"] = "String";
	Items["BusinessProcess"] = "String";
	Items["Task"] = "String";
	Items["ExternalDataSource"] = "String";
	Возврат This;
КонецФункции // ConfigurationChildObjects()

#КонецОбласти // Configuration

#Область Language

Функция Language()
	This = Структура(MDObjectBase());
	This["Properties"] = LanguageProperties();
	Возврат This;
КонецФункции // Foo()

Функция LanguageProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["LanguageCode"] = "String";
	Возврат This;
КонецФункции // LanguageProperties()

#КонецОбласти // Language

#Область AccountingRegister

Функция AccountingRegister()
	This = Структура(MDObjectBase());
	This["Properties"] = AccountingRegisterProperties();
	This["ChildObjects"] = AccountingRegisterChildObjects();
	Возврат This;
КонецФункции // AccountingRegister()

Функция AccountingRegisterProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["ChartOfAccounts"] = "MDObjectRef";
	This["Correspondence"] = "String"; // Enums.Boolean;
	This["PeriodAdjustmentLength"] = "Decimal";
	This["DefaultListForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["StandardAttributes"] = "StandardAttributes";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["EnableTotalsSplitting"] = "String"; // Enums.Boolean;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // AccountingRegisterProperties()

Функция AccountingRegisterChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Dimension"] = "Dimension";
	Items["Resource"] = "Resource";
	Items["Attribute"] = "Attribute";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // AccountingRegisterChildObjects()

#КонецОбласти // AccountingRegister

#Область AccumulationRegister

Функция AccumulationRegister()
	This = Структура(MDObjectBase());
	This["Properties"] = AccumulationRegisterProperties();
	This["ChildObjects"] = AccumulationRegisterChildObjects();
	Возврат This;
КонецФункции // AccumulationRegister()

Функция AccumulationRegisterProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["DefaultListForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["RegisterType"] = "String"; // Enums.AccumulationRegisterType;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["StandardAttributes"] = "StandardAttributes";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["EnableTotalsSplitting"] = "String"; // Enums.Boolean;
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // AccumulationRegisterProperties()

Функция AccumulationRegisterChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Resource"] = "Resource";
	Items["Attribute"] = "Attribute";
	Items["Dimension"] = "Dimension";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // AccumulationRegisterChildObjects()

#КонецОбласти // AccumulationRegister

#Область BusinessProcess

Функция BusinessProcess()
	This = Структура(MDObjectBase());
	This["Properties"] = BusinessProcessProperties();
	This["ChildObjects"] = BusinessProcessChildObjects();
	Возврат This;
КонецФункции // BusinessProcess()

Функция BusinessProcessProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["EditType"] = "String"; // Enums.EditType;
	This["InputByString"] = "FieldList";
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	This["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	This["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	This["DefaultObjectForm"] = "MDObjectRef";
	This["DefaultListForm"] = "MDObjectRef";
	This["DefaultChoiceForm"] = "MDObjectRef";
	This["AuxiliaryObjectForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["AuxiliaryChoiceForm"] = "MDObjectRef";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["NumberType"] = "String"; // Enums.BusinessProcessNumberType;
	This["NumberLength"] = "Decimal";
	This["NumberAllowedLength"] = "String"; // Enums.AllowedLength;
	This["CheckUnique"] = "String"; // Enums.Boolean;
	This["StandardAttributes"] = "StandardAttributes";
	This["Characteristics"] = "Characteristics";
	This["Autonumbering"] = "String"; // Enums.Boolean;
	This["BasedOn"] = "MDListType";
	This["NumberPeriodicity"] = "String"; // Enums.BusinessProcessNumberPeriodicity;
	This["Task"] = "MDObjectRef";
	This["CreateTaskInPrivilegedMode"] = "String"; // Enums.Boolean;
	This["DataLockFields"] = "FieldList";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["ObjectPresentation"] = "LocalStringType";
	This["ExtendedObjectPresentation"] = "LocalStringType";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // BusinessProcessProperties()

Функция BusinessProcessChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Items["TabularSection"] = "TabularSection";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // BusinessProcessChildObjects()

#КонецОбласти // BusinessProcess

#Область CalculationRegister

Функция CalculationRegister()
	This = Структура(MDObjectBase());
	This["Properties"] = CalculationRegisterProperties();
	This["ChildObjects"] = CalculationRegisterChildObjects();
	Возврат This;
КонецФункции // CalculationRegister()

Функция CalculationRegisterProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["DefaultListForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["Periodicity"] = "String"; // Enums.CalculationRegisterPeriodicity;
	This["ActionPeriod"] = "String"; // Enums.Boolean;
	This["BasePeriod"] = "String"; // Enums.Boolean;
	This["Schedule"] = "MDObjectRef";
	This["ScheduleValue"] = "MDObjectRef";
	This["ScheduleDate"] = "MDObjectRef";
	This["ChartOfCalculationTypes"] = "MDObjectRef";
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["StandardAttributes"] = "StandardAttributes";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // CalculationRegisterProperties()

Функция CalculationRegisterChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Resource"] = "Resource";
	Items["Attribute"] = "Attribute";
	Items["Dimension"] = "Dimension";
	Items["Recalculation"] = "String";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // CalculationRegisterChildObjects()

#КонецОбласти // CalculationRegister

#Область Catalog

Функция Catalog()
	This = Структура(MDObjectBase());
	This["Properties"] = CatalogProperties();
	This["ChildObjects"] = CatalogChildObjects();
	Возврат This;
КонецФункции // Catalog()

Функция CatalogProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Hierarchical"] = "String"; // Enums.Boolean;
	This["HierarchyType"] = "String"; // Enums.HierarchyType;
	This["LimitLevelCount"] = "String"; // Enums.Boolean;
	This["LevelCount"] = "Decimal";
	This["FoldersOnTop"] = "String"; // Enums.Boolean;
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["Owners"] = "MDListType";
	This["SubordinationUse"] = "String"; // Enums.SubordinationUse;
	This["CodeLength"] = "Decimal";
	This["DescriptionLength"] = "Decimal";
	This["CodeType"] = "String"; // Enums.CatalogCodeType;
	This["CodeAllowedLength"] = "String"; // Enums.AllowedLength;
	This["CodeSeries"] = "String"; // Enums.CatalogCodesSeries;
	This["CheckUnique"] = "String"; // Enums.Boolean;
	This["Autonumbering"] = "String"; // Enums.Boolean;
	This["DefaultPresentation"] = "String"; // Enums.CatalogMainPresentation;
	This["StandardAttributes"] = "StandardAttributes";
	This["Characteristics"] = "Characteristics";
	This["PredefinedDataUpdate"] = "String"; // Enums.PredefinedDataUpdate;
	This["EditType"] = "String"; // Enums.EditType;
	This["QuickChoice"] = "String"; // Enums.Boolean;
	This["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	This["InputByString"] = "FieldList";
	This["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	This["DefaultObjectForm"] = "MDObjectRef";
	This["DefaultFolderForm"] = "MDObjectRef";
	This["DefaultListForm"] = "MDObjectRef";
	This["DefaultChoiceForm"] = "MDObjectRef";
	This["DefaultFolderChoiceForm"] = "MDObjectRef";
	This["AuxiliaryObjectForm"] = "MDObjectRef";
	This["AuxiliaryFolderForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["AuxiliaryChoiceForm"] = "MDObjectRef";
	This["AuxiliaryFolderChoiceForm"] = "MDObjectRef";
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["BasedOn"] = "MDListType";
	This["DataLockFields"] = "FieldList";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["ObjectPresentation"] = "LocalStringType";
	This["ExtendedObjectPresentation"] = "LocalStringType";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат This;
КонецФункции // CatalogProperties()

Функция CatalogChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Items["TabularSection"] = "TabularSection";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // CatalogChildObjects()

#КонецОбласти // Catalog

#Область ChartOfAccounts

Функция ChartOfAccounts()
	This = Структура(MDObjectBase());
	This["Properties"] = ChartOfAccountsProperties();
	This["ChildObjects"] = ChartOfAccountsChildObjects();
	Возврат This;
КонецФункции // ChartOfAccounts()

Функция ChartOfAccountsProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["BasedOn"] = "MDListType";
	This["ExtDimensionTypes"] = "MDObjectRef";
	This["MaxExtDimensionCount"] = "Decimal";
	This["CodeMask"] = "String";
	This["CodeLength"] = "Decimal";
	This["DescriptionLength"] = "Decimal";
	This["CodeSeries"] = "String"; // Enums.CharOfAccountCodeSeries;
	This["CheckUnique"] = "String"; // Enums.Boolean;
	This["DefaultPresentation"] = "String"; // Enums.AccountMainPresentation;
	This["StandardAttributes"] = "StandardAttributes";
	This["Characteristics"] = "Characteristics";
	This["StandardTabularSections"] = "StandardTabularSections";
	This["PredefinedDataUpdate"] = "String"; // Enums.PredefinedDataUpdate;
	This["EditType"] = "String"; // Enums.EditType;
	This["QuickChoice"] = "String"; // Enums.Boolean;
	This["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	This["InputByString"] = "FieldList";
	This["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["DefaultObjectForm"] = "MDObjectRef";
	This["DefaultListForm"] = "MDObjectRef";
	This["DefaultChoiceForm"] = "MDObjectRef";
	This["AuxiliaryObjectForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["AuxiliaryChoiceForm"] = "MDObjectRef";
	This["AutoOrderByCode"] = "String"; // Enums.Boolean;
	This["OrderLength"] = "Decimal";
	This["DataLockFields"] = "FieldList";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["ObjectPresentation"] = "LocalStringType";
	This["ExtendedObjectPresentation"] = "LocalStringType";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // ChartOfAccountsProperties()

Функция ChartOfAccountsChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Items["TabularSection"] = "TabularSection";
	Items["AccountingFlag"] = "AccountingFlag";
	Items["ExtDimensionAccountingFlag"] = "ExtDimensionAccountingFlag";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // ChartOfAccountsChildObjects()

#КонецОбласти // ChartOfAccounts

#Область ChartOfCalculationTypes

Функция ChartOfCalculationTypes()
	This = Структура(MDObjectBase());
	This["Properties"] = ChartOfCalculationTypesProperties();
	This["ChildObjects"] = ChartOfCalculationTypesChildObjects();
	Возврат This;
КонецФункции // ChartOfCalculationTypes()

Функция ChartOfCalculationTypesProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["CodeLength"] = "Decimal";
	This["DescriptionLength"] = "Decimal";
	This["CodeType"] = "String"; // Enums.ChartOfCalculationTypesCodeType;
	This["CodeAllowedLength"] = "String"; // Enums.AllowedLength;
	This["DefaultPresentation"] = "String"; // Enums.CalculationTypeMainPresentation;
	This["EditType"] = "String"; // Enums.EditType;
	This["QuickChoice"] = "String"; // Enums.Boolean;
	This["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	This["InputByString"] = "FieldList";
	This["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["DefaultObjectForm"] = "MDObjectRef";
	This["DefaultListForm"] = "MDObjectRef";
	This["DefaultChoiceForm"] = "MDObjectRef";
	This["AuxiliaryObjectForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["AuxiliaryChoiceForm"] = "MDObjectRef";
	This["BasedOn"] = "MDListType";
	This["DependenceOnCalculationTypes"] = "String"; // Enums.ChartOfCalculationTypesBaseUse;
	This["BaseCalculationTypes"] = "MDListType";
	This["ActionPeriodUse"] = "String"; // Enums.Boolean;
	This["StandardAttributes"] = "StandardAttributes";
	This["Characteristics"] = "Characteristics";
	This["StandardTabularSections"] = "StandardTabularSections";
	This["PredefinedDataUpdate"] = "String"; // Enums.PredefinedDataUpdate;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["DataLockFields"] = "FieldList";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["ObjectPresentation"] = "LocalStringType";
	This["ExtendedObjectPresentation"] = "LocalStringType";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // ChartOfCalculationTypesProperties()

Функция ChartOfCalculationTypesChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Items["TabularSection"] = "TabularSection";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // ChartOfCalculationTypesChildObjects()

#КонецОбласти // ChartOfCalculationTypes

#Область ChartOfCharacteristicTypes

Функция ChartOfCharacteristicTypes()
	This = Структура(MDObjectBase());
	This["Properties"] = ChartOfCharacteristicTypesProperties();
	This["ChildObjects"] = ChartOfCharacteristicTypesChildObjects();
	Возврат This;
КонецФункции // ChartOfCharacteristicTypes()

Функция ChartOfCharacteristicTypesProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["CharacteristicExtValues"] = "MDObjectRef";
	This["Type"] = "TypeDescription";
	This["Hierarchical"] = "String"; // Enums.Boolean;
	This["FoldersOnTop"] = "String"; // Enums.Boolean;
	This["CodeLength"] = "Decimal";
	This["CodeAllowedLength"] = "String"; // Enums.AllowedLength;
	This["DescriptionLength"] = "Decimal";
	This["CodeSeries"] = "String"; // Enums.CharacteristicKindCodesSeries;
	This["CheckUnique"] = "String"; // Enums.Boolean;
	This["Autonumbering"] = "String"; // Enums.Boolean;
	This["DefaultPresentation"] = "String"; // Enums.CharacteristicTypeMainPresentation;
	This["StandardAttributes"] = "StandardAttributes";
	This["Characteristics"] = "Characteristics";
	This["PredefinedDataUpdate"] = "String"; // Enums.PredefinedDataUpdate;
	This["EditType"] = "String"; // Enums.EditType;
	This["QuickChoice"] = "String"; // Enums.Boolean;
	This["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	This["InputByString"] = "FieldList";
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	This["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	This["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["DefaultObjectForm"] = "MDObjectRef";
	This["DefaultFolderForm"] = "MDObjectRef";
	This["DefaultListForm"] = "MDObjectRef";
	This["DefaultChoiceForm"] = "MDObjectRef";
	This["DefaultFolderChoiceForm"] = "MDObjectRef";
	This["AuxiliaryObjectForm"] = "MDObjectRef";
	This["AuxiliaryFolderForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["AuxiliaryChoiceForm"] = "MDObjectRef";
	This["AuxiliaryFolderChoiceForm"] = "MDObjectRef";
	This["BasedOn"] = "MDListType";
	This["DataLockFields"] = "FieldList";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["ObjectPresentation"] = "LocalStringType";
	This["ExtendedObjectPresentation"] = "LocalStringType";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // ChartOfCharacteristicTypesProperties()

Функция ChartOfCharacteristicTypesChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Items["TabularSection"] = "TabularSection";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // ChartOfCharacteristicTypesChildObjects()

#КонецОбласти // ChartOfCharacteristicTypes

#Область CommandGroup

Функция CommandGroup()
	This = Структура(MDObjectBase());
	This["Properties"] = CommandGroupProperties();
	This["ChildObjects"] = CommandGroupChildObjects();
	Возврат This;
КонецФункции // CommandGroup()

Функция CommandGroupProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Representation"] = "String"; // Enums.ButtonRepresentation;
	This["ToolTip"] = "LocalStringType";
	//This["Picture"]         = ;
	This["Category"] = "String"; // Enums.CommandGroupCategory;
	Возврат This;
КонецФункции // CommandGroupProperties()

Функция CommandGroupChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // CommandGroupChildObjects()

#КонецОбласти // CommandGroup

#Область CommonAttribute

Функция CommonAttribute()
	This = Структура(MDObjectBase());
	This["Properties"] = CommonAttributeProperties();
	This["ChildObjects"] = CommonAttributeChildObjects();
	Возврат This;
КонецФункции // CommonAttribute()

Функция CommonAttributeProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Type"] = "TypeDescription";
	This["PasswordMode"] = "String"; // Enums.Boolean;
	This["Format"] = "LocalStringType";
	This["EditFormat"] = "LocalStringType";
	This["ToolTip"] = "LocalStringType";
	This["MarkNegatives"] = "String"; // Enums.Boolean;
	This["Mask"] = "String";
	This["MultiLine"] = "String"; // Enums.Boolean;
	This["ExtendedEdit"] = "String"; // Enums.Boolean;
	//This["MinValue"]                           = ;
	//This["MaxValue"]                           = ;
	This["FillFromFillingValue"] = "String"; // Enums.Boolean;
	//This["FillValue"]                          = ;
	This["FillChecking"] = "String"; // Enums.FillChecking;
	This["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//This["ChoiceParameters"]                   = ;
	This["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceForm"] = "MDObjectRef";
	This["LinkByType"] = "TypeLink";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	//This["Content"]                            = CommonAttributeContent();
	This["AutoUse"] = "String"; // Enums.CommonAttributeAutoUse;
	This["DataSeparation"] = "String"; // Enums.CommonAttributeDataSeparation;
	This["SeparatedDataUse"] = "String"; // Enums.CommonAttributeSeparatedDataUse;
	This["DataSeparationValue"] = "MDObjectRef";
	This["DataSeparationUse"] = "MDObjectRef";
	This["ConditionalSeparation"] = "MDObjectRef";
	This["UsersSeparation"] = "String"; // Enums.CommonAttributeUsersSeparation;
	This["AuthenticationSeparation"] = "String"; // Enums.CommonAttributeAuthenticationSeparation;
	This["ConfigurationExtensionsSeparation"] = "String"; // Enums.CommonAttributeConfigurationExtensionsSeparation;
	This["Indexing"] = "String"; // Enums.Indexing;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат This;
КонецФункции // CommonAttributeProperties()

Функция CommonAttributeChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // CommonAttributeChildObjects()

#КонецОбласти // CommonAttribute

#Область CommonCommand

Функция CommonCommand()
	This = Структура(MDObjectBase());
	This["Properties"] = CommonCommandProperties();
	This["ChildObjects"] = CommonCommandChildObjects();
	Возврат This;
КонецФункции // CommonCommand()

Функция CommonCommandProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	//This["Group"]                  = IncludeInCommandCategoriesType;
	This["Representation"] = "String"; // Enums.ButtonRepresentation;
	This["ToolTip"] = "LocalStringType";
	//This["Picture"]                = ;
	//This["Shortcut"]               = ;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["CommandParameterType"] = "TypeDescription";
	This["ParameterUseMode"] = "String"; // Enums.CommandParameterUseMode;
	This["ModifiesData"] = "String"; // Enums.Boolean;
	Возврат This;
КонецФункции // CommonCommandProperties()

Функция CommonCommandChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // CommonCommandChildObjects()

#КонецОбласти // CommonCommand

#Область CommonForm

Функция CommonForm()
	This = Структура(MDObjectBase());
	This["Properties"] = CommonFormProperties();
	This["ChildObjects"] = CommonFormChildObjects();
	Возврат This;
КонецФункции // CommonForm()

Функция CommonFormProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["FormType"] = "String"; // Enums.FormType;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	//This["UsePurposes"]            = "FixedArray";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["ExtendedPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // CommonFormProperties()

Функция CommonFormChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // CommonFormChildObjects()

#КонецОбласти // CommonForm

#Область CommonModule

Функция CommonModule()
	This = Структура(MDObjectBase());
	This["Properties"] = CommonModuleProperties();
	This["ChildObjects"] = CommonModuleChildObjects();
	Возврат This;
КонецФункции // CommonModule()

Функция CommonModuleProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Global"] = "String"; // Enums.Boolean;
	This["ClientManagedApplication"] = "String"; // Enums.Boolean;
	This["Server"] = "String"; // Enums.Boolean;
	This["ExternalConnection"] = "String"; // Enums.Boolean;
	This["ClientOrdinaryApplication"] = "String"; // Enums.Boolean;
	This["Client"] = "String"; // Enums.Boolean;
	This["ServerCall"] = "String"; // Enums.Boolean;
	This["Privileged"] = "String"; // Enums.Boolean;
	This["ReturnValuesReuse"] = "String"; // Enums.ReturnValuesReuse;
	Возврат This;
КонецФункции // CommonModuleProperties()

Функция CommonModuleChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // CommonModuleChildObjects()

#КонецОбласти // CommonModule

#Область CommonPicture

Функция CommonPicture()
	This = Структура(MDObjectBase());
	This["Properties"] = CommonPictureProperties();
	This["ChildObjects"] = CommonPictureChildObjects();
	Возврат This;
КонецФункции // CommonPicture()

Функция CommonPictureProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	Возврат This;
КонецФункции // CommonPictureProperties()

Функция CommonPictureChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // CommonPictureChildObjects()

#КонецОбласти // CommonPicture

#Область CommonTemplate

Функция CommonTemplate()
	This = Структура(MDObjectBase());
	This["Properties"] = CommonTemplateProperties();
	This["ChildObjects"] = CommonTemplateChildObjects();
	Возврат This;
КонецФункции // CommonTemplate()

Функция CommonTemplateProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["TemplateType"] = "String"; // Enums.TemplateType;
	Возврат This;
КонецФункции // CommonTemplateProperties()

Функция CommonTemplateChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // CommonTemplateChildObjects()

#КонецОбласти // CommonTemplate

#Область Constant

Функция Constant()
	This = Структура(MDObjectBase());
	This["Properties"] = ConstantProperties();
	This["ChildObjects"] = ConstantChildObjects();
	Возврат This;
КонецФункции // Constant()

Функция ConstantProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Type"] = "TypeDescription";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["DefaultForm"] = "MDObjectRef";
	This["ExtendedPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	This["PasswordMode"] = "String"; // Enums.Boolean;
	This["Format"] = "LocalStringType";
	This["EditFormat"] = "LocalStringType";
	This["ToolTip"] = "LocalStringType";
	This["MarkNegatives"] = "String"; // Enums.Boolean;
	This["Mask"] = "String";
	This["MultiLine"] = "String"; // Enums.Boolean;
	This["ExtendedEdit"] = "String"; // Enums.Boolean;
	//This["MinValue"]               = ;
	//This["MaxValue"]               = ;
	This["FillChecking"] = "String"; // Enums.FillChecking;
	This["ChoiceFoldersAndItems"] = "String"; // Enums.FoldersAndItemsUse;
	This["ChoiceParameterLinks"] = "ChoiceParameterLinks";
	//This["ChoiceParameters"]       = ;
	This["QuickChoice"] = "String"; // Enums.UseQuickChoice;
	This["ChoiceForm"] = "MDObjectRef";
	This["LinkByType"] = "TypeLink";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Возврат This;
КонецФункции // ConstantProperties()

Функция ConstantChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // ConstantChildObjects()

#КонецОбласти // Constant

#Область DataProcessor

Функция DataProcessor()
	This = Структура(MDObjectBase());
	This["Properties"] = DataProcessorProperties();
	This["ChildObjects"] = DataProcessorChildObjects();
	Возврат This;
КонецФункции // DataProcessor()

Функция DataProcessorProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["DefaultForm"] = "MDObjectRef";
	This["AuxiliaryForm"] = "MDObjectRef";
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["ExtendedPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // DataProcessorProperties()

Функция DataProcessorChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Items["TabularSection"] = "TabularSection";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // DataProcessorChildObjects()

#КонецОбласти // DataProcessor

#Область DocumentJournal

Функция DocumentJournal()
	This = Структура(MDObjectBase());
	This["Properties"] = DocumentJournalProperties();
	This["ChildObjects"] = DocumentJournalChildObjects();
	Возврат This;
КонецФункции // DocumentJournal()

Функция DocumentJournalProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["DefaultForm"] = "MDObjectRef";
	This["AuxiliaryForm"] = "MDObjectRef";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["RegisteredDocuments"] = "MDListType";
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["StandardAttributes"] = "StandardAttributes";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // DocumentJournalProperties()

Функция DocumentJournalChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Column"] = Column();
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // DocumentJournalChildObjects()

#КонецОбласти // DocumentJournal

#Область DocumentNumerator

Функция DocumentNumerator()
	This = Структура(MDObjectBase());
	This["Properties"] = DocumentNumeratorProperties();
	This["ChildObjects"] = DocumentNumeratorChildObjects();
	Возврат This;
КонецФункции // DocumentNumerator()

Функция DocumentNumeratorProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["NumberType"] = "String"; // Enums.DocumentNumberType;
	This["NumberLength"] = "Decimal";
	This["NumberAllowedLength"] = "String"; // Enums.AllowedLength;
	This["NumberPeriodicity"] = "String"; // Enums.DocumentNumberPeriodicity;
	This["CheckUnique"] = "String"; // Enums.Boolean;
	Возврат This;
КонецФункции // DocumentNumeratorProperties()

Функция DocumentNumeratorChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // DocumentNumeratorChildObjects()

#КонецОбласти // DocumentNumerator

#Область Document

Функция Document()
	This = Структура(MDObjectBase());
	This["Properties"] = DocumentProperties();
	This["ChildObjects"] = DocumentChildObjects();
	Возврат This;
КонецФункции // Document()

Функция DocumentProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["Numerator"] = "MDObjectRef";
	This["NumberType"] = "String"; // Enums.DocumentNumberType;
	This["NumberLength"] = "Decimal";
	This["NumberAllowedLength"] = "String"; // Enums.AllowedLength;
	This["NumberPeriodicity"] = "String"; // Enums.DocumentNumberPeriodicity;
	This["CheckUnique"] = "String"; // Enums.Boolean;
	This["Autonumbering"] = "String"; // Enums.Boolean;
	This["StandardAttributes"] = "StandardAttributes";
	This["Characteristics"] = "Characteristics";
	This["BasedOn"] = "MDListType";
	This["InputByString"] = "FieldList";
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	This["DefaultObjectForm"] = "MDObjectRef";
	This["DefaultListForm"] = "MDObjectRef";
	This["DefaultChoiceForm"] = "MDObjectRef";
	This["AuxiliaryObjectForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["AuxiliaryChoiceForm"] = "MDObjectRef";
	This["Posting"] = "String"; // Enums.Posting;
	This["RealTimePosting"] = "String"; // Enums.RealTimePosting;
	This["RegisterRecordsDeletion"] = "String"; // Enums.RegisterRecordsDeletion;
	This["RegisterRecordsWritingOnPost"] = "String"; // Enums.RegisterRecordsWritingOnPost;
	This["SequenceFilling"] = "String"; // Enums.SequenceFilling;
	This["RegisterRecords"] = "MDListType";
	This["PostInPrivilegedMode"] = "String"; // Enums.Boolean;
	This["UnpostInPrivilegedMode"] = "String"; // Enums.Boolean;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["DataLockFields"] = "FieldList";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["ObjectPresentation"] = "LocalStringType";
	This["ExtendedObjectPresentation"] = "LocalStringType";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат This;
КонецФункции // DocumentProperties()

Функция DocumentChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Items["Form"] = "String";
	Items["TabularSection"] = "TabularSection";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // DocumentChildObjects()

#КонецОбласти // Document

#Область Enum

Функция Enum()
	This = Структура(MDObjectBase());
	This["Properties"] = EnumProperties();
	This["ChildObjects"] = EnumChildObjects();
	Возврат This;
КонецФункции // Enum()

Функция EnumProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["StandardAttributes"] = "StandardAttributes";
	This["Characteristics"] = "Characteristics";
	This["QuickChoice"] = "String"; // Enums.Boolean;
	This["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	This["DefaultListForm"] = "MDObjectRef";
	This["DefaultChoiceForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["AuxiliaryChoiceForm"] = "MDObjectRef";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	Возврат This;
КонецФункции // EnumProperties()

Функция EnumChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["EnumValue"] = EnumValue();
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // EnumChildObjects()

#КонецОбласти // Enum

#Область EventSubscription

Функция EventSubscription()
	This = Структура(MDObjectBase());
	This["Properties"] = EventSubscriptionProperties();
	This["ChildObjects"] = EventSubscriptionChildObjects();
	Возврат This;
КонецФункции // EventSubscription()

Функция EventSubscriptionProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Source"] = "TypeDescription";
	//This["Event"]    = "AliasedStringType";
	This["Handler"] = "MDMethodRef";
	Возврат This;
КонецФункции // EventSubscriptionProperties()

Функция EventSubscriptionChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // EventSubscriptionChildObjects()

#КонецОбласти // EventSubscription

#Область ExchangePlan

Функция ExchangePlan()
	This = Структура(MDObjectBase());
	This["Properties"] = ExchangePlanProperties();
	This["ChildObjects"] = ExchangePlanChildObjects();
	Возврат This;
КонецФункции // ExchangePlan()

Функция ExchangePlanProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["CodeLength"] = "Decimal";
	This["CodeAllowedLength"] = "String"; // Enums.AllowedLength;
	This["DescriptionLength"] = "Decimal";
	This["DefaultPresentation"] = "String"; // Enums.DataExchangeMainPresentation;
	This["EditType"] = "String"; // Enums.EditType;
	This["QuickChoice"] = "String"; // Enums.Boolean;
	This["ChoiceMode"] = "String"; // Enums.ChoiceMode;
	This["InputByString"] = "FieldList";
	This["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	This["DefaultObjectForm"] = "MDObjectRef";
	This["DefaultListForm"] = "MDObjectRef";
	This["DefaultChoiceForm"] = "MDObjectRef";
	This["AuxiliaryObjectForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["AuxiliaryChoiceForm"] = "MDObjectRef";
	This["StandardAttributes"] = "StandardAttributes";
	This["Characteristics"] = "Characteristics";
	This["BasedOn"] = "MDListType";
	This["DistributedInfoBase"] = "String"; // Enums.Boolean;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["DataLockFields"] = "FieldList";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["ObjectPresentation"] = "LocalStringType";
	This["ExtendedObjectPresentation"] = "LocalStringType";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // ExchangePlanProperties()

Функция ExchangePlanChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Items["TabularSection"] = "TabularSection";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // ExchangePlanChildObjects()

#КонецОбласти // ExchangePlan

#Область FilterCriterion

Функция FilterCriterion()
	This = Структура(MDObjectBase());
	This["Properties"] = FilterCriterionProperties();
	This["ChildObjects"] = FilterCriterionChildObjects();
	Возврат This;
КонецФункции // FilterCriterion()

Функция FilterCriterionProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Type"] = "TypeDescription";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["Content"] = "MDListType";
	This["DefaultForm"] = "MDObjectRef";
	This["AuxiliaryForm"] = "MDObjectRef";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // FilterCriterionProperties()

Функция FilterCriterionChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Form"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // FilterCriterionChildObjects()

#КонецОбласти // FilterCriterion

#Область FunctionalOption

Функция FunctionalOption()
	This = Структура(MDObjectBase());
	This["Properties"] = FunctionalOptionProperties();
	This["ChildObjects"] = FunctionalOptionChildObjects();
	Возврат This;
КонецФункции // FunctionalOption()

Функция FunctionalOptionProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Location"] = "MDObjectRef";
	This["PrivilegedGetMode"] = "String"; // Enums.Boolean;
	//This["Content"]            = FuncOptionContentType();
	Возврат This;
КонецФункции // FunctionalOptionProperties()

Функция FunctionalOptionChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // FunctionalOptionChildObjects()

#КонецОбласти // FunctionalOption

#Область FunctionalOptionsParameter

Функция FunctionalOptionsParameter()
	This = Структура(MDObjectBase());
	This["Properties"] = FunctionalOptionsParameterProperties();
	This["ChildObjects"] = FunctionalOptionsParameterChildObjects();
	Возврат This;
КонецФункции // FunctionalOptionsParameter()

Функция FunctionalOptionsParameterProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Use"] = "MDListType";
	Возврат This;
КонецФункции // FunctionalOptionsParameterProperties()

Функция FunctionalOptionsParameterChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // FunctionalOptionsParameterChildObjects()

#КонецОбласти // FunctionalOptionsParameter

#Область HTTPService

Функция HTTPService()
	This = Структура(MDObjectBase());
	This["Properties"] = HTTPServiceProperties();
	This["ChildObjects"] = HTTPServiceChildObjects();
	Возврат This;
КонецФункции // HTTPService()

Функция HTTPServiceProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["RootURL"] = "String";
	This["ReuseSessions"] = "String"; // Enums.SessionReuseMode;
	This["SessionMaxAge"] = "Decimal";
	Возврат This;
КонецФункции // HTTPServiceProperties()

Функция HTTPServiceChildObjects()
	This = Объект();
	Items = This.Элементы;
	//Items["URLTemplate"] = ;
	Возврат This;
КонецФункции // HTTPServiceChildObjects()

#КонецОбласти // HTTPService

#Область InformationRegister

Функция InformationRegister()
	This = Структура(MDObjectBase());
	This["Properties"] = InformationRegisterProperties();
	This["ChildObjects"] = InformationRegisterChildObjects();
	Возврат This;
КонецФункции // InformationRegister()

Функция InformationRegisterProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["EditType"] = "String"; // Enums.EditType;
	This["DefaultRecordForm"] = "MDObjectRef";
	This["DefaultListForm"] = "MDObjectRef";
	This["AuxiliaryRecordForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["StandardAttributes"] = "StandardAttributes";
	This["InformationRegisterPeriodicity"] = "String"; // Enums.InformationRegisterPeriodicity;
	This["WriteMode"] = "String"; // Enums.RegisterWriteMode;
	This["MainFilterOnPeriod"] = "String"; // Enums.Boolean;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["EnableTotalsSliceFirst"] = "String"; // Enums.Boolean;
	This["EnableTotalsSliceLast"] = "String"; // Enums.Boolean;
	This["RecordPresentation"] = "LocalStringType";
	This["ExtendedRecordPresentation"] = "LocalStringType";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	This["DataHistory"] = "String"; // Enums.DataHistoryUse;
	Возврат This;
КонецФункции // InformationRegisterProperties()

Функция InformationRegisterChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Resource"] = "Resource";
	Items["Attribute"] = "Attribute";
	Items["Dimension"] = "Dimension";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // InformationRegisterChildObjects()

#КонецОбласти // InformationRegister

#Область Report

Функция Report()
	This = Структура(MDObjectBase());
	This["Properties"] = ReportProperties();
	This["ChildObjects"] = ReportChildObjects();
	Возврат This;
КонецФункции // Report()

Функция ReportProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["DefaultForm"] = "MDObjectRef";
	This["AuxiliaryForm"] = "MDObjectRef";
	This["MainDataCompositionSchema"] = "MDObjectRef";
	This["DefaultSettingsForm"] = "MDObjectRef";
	This["AuxiliarySettingsForm"] = "MDObjectRef";
	This["DefaultVariantForm"] = "MDObjectRef";
	This["VariantsStorage"] = "MDObjectRef";
	This["SettingsStorage"] = "MDObjectRef";
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["ExtendedPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // ReportProperties()

Функция ReportChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Items["TabularSection"] = "TabularSection";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // ReportChildObjects()

#КонецОбласти // Report

#Область Role

Функция Role()
	This = Структура(MDObjectBase());
	This["Properties"] = RoleProperties();
	This["ChildObjects"] = RoleChildObjects();
	Возврат This;
КонецФункции // Role()

Функция RoleProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	Возврат This;
КонецФункции // RoleProperties()

Функция RoleChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // RoleChildObjects()

#КонецОбласти // Role

#Область ScheduledJob

Функция ScheduledJob()
	This = Структура(MDObjectBase());
	This["Properties"] = ScheduledJobProperties();
	This["ChildObjects"] = ScheduledJobChildObjects();
	Возврат This;
КонецФункции // ScheduledJob()

Функция ScheduledJobProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["MethodName"] = "MDMethodRef";
	This["Description"] = "String";
	This["Key"] = "String";
	This["Use"] = "String"; // Enums.Boolean;
	This["Predefined"] = "String"; // Enums.Boolean;
	This["RestartCountOnFailure"] = "Decimal";
	This["RestartIntervalOnFailure"] = "Decimal";
	Возврат This;
КонецФункции // ScheduledJobProperties()

Функция ScheduledJobChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // ScheduledJobChildObjects()

#КонецОбласти // ScheduledJob

#Область Sequence

Функция Sequence()
	This = Структура(MDObjectBase());
	This["Properties"] = SequenceProperties();
	This["ChildObjects"] = SequenceChildObjects();
	Возврат This;
КонецФункции // Sequence()

Функция SequenceProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["MoveBoundaryOnPosting"] = "String"; // Enums.MoveBoundaryOnPosting;
	This["Documents"] = "MDListType";
	This["RegisterRecords"] = "MDListType";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	Возврат This;
КонецФункции // SequenceProperties()

Функция SequenceChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Dimension"] = "Dimension";
	Возврат This;
КонецФункции // SequenceChildObjects()

#КонецОбласти // Sequence

#Область SessionParameter

Функция SessionParameter()
	This = Структура(MDObjectBase());
	This["Properties"] = SessionParameterProperties();
	This["ChildObjects"] = SessionParameterChildObjects();
	Возврат This;
КонецФункции // SessionParameter()

Функция SessionParameterProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Type"] = "TypeDescription";
	Возврат This;
КонецФункции // SessionParameterProperties()

Функция SessionParameterChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // SessionParameterChildObjects()

#КонецОбласти // SessionParameter

#Область SettingsStorage

Функция SettingsStorage()
	This = Структура(MDObjectBase());
	This["Properties"] = SettingsStorageProperties();
	This["ChildObjects"] = SettingsStorageChildObjects();
	Возврат This;
КонецФункции // SettingsStorage()

Функция SettingsStorageProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["DefaultSaveForm"] = "MDObjectRef";
	This["DefaultLoadForm"] = "MDObjectRef";
	This["AuxiliarySaveForm"] = "MDObjectRef";
	This["AuxiliaryLoadForm"] = "MDObjectRef";
	Возврат This;
КонецФункции // SettingsStorageProperties()

Функция SettingsStorageChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Form"] = "String";
	Items["Template"] = "String";
	Возврат This;
КонецФункции // SettingsStorageChildObjects()

#КонецОбласти // SettingsStorage

#Область Subsystem

Функция Subsystem()
	This = Структура(MDObjectBase());
	This["Properties"] = SubsystemProperties();
	This["ChildObjects"] = SubsystemChildObjects();
	Возврат This;
КонецФункции // Subsystem()

Функция SubsystemProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["IncludeInCommandInterface"] = "String"; // Enums.Boolean;
	This["Explanation"] = "LocalStringType";
	//This["Picture"]                    = ;
	This["Content"] = "MDListType";
	Возврат This;
КонецФункции // SubsystemProperties()

Функция SubsystemChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Subsystem"] = "String";
	Возврат This;
КонецФункции // SubsystemChildObjects()

#КонецОбласти // Subsystem

#Область Task

Функция Task()
	This = Структура(MDObjectBase());
	This["Properties"] = TaskProperties();
	This["ChildObjects"] = TaskChildObjects();
	Возврат This;
КонецФункции // Task()

Функция TaskProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["UseStandardCommands"] = "String"; // Enums.Boolean;
	This["NumberType"] = "String"; // Enums.TaskNumberType;
	This["NumberLength"] = "Decimal";
	This["NumberAllowedLength"] = "String"; // Enums.AllowedLength;
	This["CheckUnique"] = "String"; // Enums.Boolean;
	This["Autonumbering"] = "String"; // Enums.Boolean;
	This["TaskNumberAutoPrefix"] = "String"; // Enums.TaskNumberAutoPrefix;
	This["DescriptionLength"] = "Decimal";
	This["Addressing"] = "MDObjectRef";
	This["MainAddressingAttribute"] = "MDObjectRef";
	This["CurrentPerformer"] = "MDObjectRef";
	This["BasedOn"] = "MDListType";
	This["StandardAttributes"] = "StandardAttributes";
	This["Characteristics"] = "Characteristics";
	This["DefaultPresentation"] = "String"; // Enums.TaskMainPresentation;
	This["EditType"] = "String"; // Enums.EditType;
	This["InputByString"] = "FieldList";
	This["SearchStringModeOnInputByString"] = "String"; // Enums.SearchStringModeOnInputByString;
	This["FullTextSearchOnInputByString"] = "String"; // Enums.FullTextSearchOnInputByString;
	This["ChoiceDataGetModeOnInputByString"] = "String"; // Enums.ChoiceDataGetModeOnInputByString;
	This["CreateOnInput"] = "String"; // Enums.CreateOnInput;
	This["DefaultObjectForm"] = "MDObjectRef";
	This["DefaultListForm"] = "MDObjectRef";
	This["DefaultChoiceForm"] = "MDObjectRef";
	This["AuxiliaryObjectForm"] = "MDObjectRef";
	This["AuxiliaryListForm"] = "MDObjectRef";
	This["AuxiliaryChoiceForm"] = "MDObjectRef";
	This["ChoiceHistoryOnInput"] = "String"; // Enums.ChoiceHistoryOnInput;
	This["IncludeHelpInContents"] = "String"; // Enums.Boolean;
	This["DataLockFields"] = "FieldList";
	This["DataLockControlMode"] = "String"; // Enums.DefaultDataLockControlMode;
	This["FullTextSearch"] = "String"; // Enums.FullTextSearchUsing;
	This["ObjectPresentation"] = "LocalStringType";
	This["ExtendedObjectPresentation"] = "LocalStringType";
	This["ListPresentation"] = "LocalStringType";
	This["ExtendedListPresentation"] = "LocalStringType";
	This["Explanation"] = "LocalStringType";
	Возврат This;
КонецФункции // TaskProperties()

Функция TaskChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = "Attribute";
	Items["TabularSection"] = "TabularSection";
	Items["Form"] = "String";
	Items["Template"] = "String";
	Items["AddressingAttribute"] = "AddressingAttribute";
	Items["Command"] = "Command";
	Возврат This;
КонецФункции // TaskChildObjects()

#КонецОбласти // Task

#Область WebService

Функция WebService()
	This = Структура(MDObjectBase());
	This["Properties"] = WebServiceProperties();
	This["ChildObjects"] = WebServiceChildObjects();
	Возврат This;
КонецФункции // WebService()

Функция WebServiceProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Namespace"] = "String";
	//This["XDTOPackages"]        = "ValueList";
	This["DescriptorFileName"] = "String";
	This["ReuseSessions"] = "String"; // Enums.SessionReuseMode;
	This["SessionMaxAge"] = "Decimal";
	Возврат This;
КонецФункции // WebServiceProperties()

Функция WebServiceChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Operation"] = Operation();
	Возврат This;
КонецФункции // WebServiceChildObjects()

Функция Operation()
	This = Структура(MDObjectBase());
	This["Properties"] = OperationProperties();
	This["ChildObjects"] = OperationChildObjects();
	Возврат This;
КонецФункции // Operation()

Функция OperationProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["XDTOReturningValueType"] = "QName";
	This["Nillable"] = "String"; // Enums.Boolean;
	This["Transactioned"] = "String"; // Enums.Boolean;
	This["ProcedureName"] = "String";
	Возврат This;
КонецФункции // OperationProperties()

Функция OperationChildObjects()
	This = Объект();
	Items = This.Элементы;
	Items["Parameter"] = Parameter();
	Возврат This;
КонецФункции // OperationChildObjects()

Функция Parameter()
	This = Структура(MDObjectBase());
	This["Properties"] = ParameterProperties();
	Возврат This;
КонецФункции // Parameter()

Функция ParameterProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["XDTOValueType"] = "QName";
	This["Nillable"] = "String"; // Enums.Boolean;
	This["TransferDirection"] = "String"; // Enums.TransferDirection;
	Возврат This;
КонецФункции // ParameterProperties()

#КонецОбласти // WebService

#Область WSReference

Функция WSReference()
	This = Структура(MDObjectBase());
	This["Properties"] = WSReferenceProperties();
	This["ChildObjects"] = WSReferenceChildObjects();
	Возврат This;
КонецФункции // WSReference()

Функция WSReferenceProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["LocationURL"] = "String";
	Возврат This;
КонецФункции // WSReferenceProperties()

Функция WSReferenceChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // WSReferenceChildObjects()

#КонецОбласти // WSReference

#Область XDTOPackage

Функция XDTOPackage()
	This = Структура(MDObjectBase());
	This["Properties"] = XDTOPackageProperties();
	This["ChildObjects"] = XDTOPackageChildObjects();
	Возврат This;
КонецФункции // XDTOPackage()

Функция XDTOPackageProperties()
	This = Структура();
	This["Name"] = "String";
	This["Synonym"] = "LocalStringType";
	This["Comment"] = "String";
	This["Namespace"] = "String";
	Возврат This;
КонецФункции // XDTOPackageProperties()

Функция XDTOPackageChildObjects()
	This = Объект();
	Items = This.Элементы;

	Возврат This;
КонецФункции // XDTOPackageChildObjects()

#КонецОбласти // XDTOPackage

#КонецОбласти // MetaDataObject

#Область LogForm

Функция LogForm()
	This = Структура();
	This["Title"] = "LocalStringType";
	This["Width"] = "Decimal";
	This["Height"] = "Decimal";
	This["VerticalScroll"] = "String"; // Enums.VerticalFormScroll;
	This["WindowOpeningMode"] = "String"; // Enums.FormWindowOpeningMode;
	This["Attributes"] = FormAttributes();
	This["Events"] = FormEvents();
	This["ChildItems"] = "FormChildItems";
	Возврат This;
КонецФункции // LogForm()

Функция FormItemBase()
	This = Структура();
	This["id"] = "Decimal";
	This["name"] = "String";
	Возврат This;
КонецФункции // FormItemBase()

Функция FormChildItems()
	This = Объект();
	Items = This.Элементы;
	Items["UsualGroup"] = FormUsualGroup();
	Возврат This;
КонецФункции // FormChildItems()

Функция FormUsualGroup()
	This = Структура(FormItemBase());
	This["HorizontalAlign"] = "String"; // Enums.ItemHorizontalLocation;
	This["United"] = "Boolean";
	This["ShowTitle"] = "Boolean";
	This["ChildItems"] = "FormChildItems";
	Возврат This;
КонецФункции // FormUsualGroup()

#Область Events

Функция FormEvents()
	This = Объект();
	Items = This.Элементы;
	Items["Event"] = FormEvent();
	Возврат This;
КонецФункции // FormEvents()

Функция FormEvent()
	This = Структура();
	This["name"] = "String";
	This["_"] = "String";
	Возврат This;
КонецФункции // FormEvent()

#КонецОбласти // Events

#Область Attributes

Функция FormAttributes()
	This = Объект();
	Items = This.Элементы;
	Items["Attribute"] = FormAttribute();
	Возврат This;
КонецФункции // FormAttributes()

Функция FormAttribute()
	This = Структура();
	This["name"] = "String";
	This["Title"] = "LocalStringType";
	This["SavedData"] = "Boolean";
	This["Columns"] = FormAttributeColumns();
	Возврат This;
КонецФункции // FormAttribute()

#Область Columns

Функция FormAttributeColumns()
	This = Объект();
	Items = This.Элементы;
	Items["Column"] = FormAttributeColumn();
	Возврат This;
КонецФункции // FormAttributeColumns()

Функция FormAttributeColumn()
	This = Структура();
	This["name"] = "String";
	This["Title"] = "LocalStringType";
	Возврат This;
КонецФункции // FormAttributeColumn()

#КонецОбласти // Columns

#КонецОбласти // Attributes

#КонецОбласти