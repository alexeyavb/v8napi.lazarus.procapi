{%RunFlags BUILD-}
{%RunCommand }
unit vkobject;

{$MODE DELPHI}
{$codepage UTF8}

interface

uses
  v8napi,windows;

type
  TMyClass = class(TV8UserObject)
  private
    FPropertyInt: integer;
    FPropertyStr: WideString;
  public
    function HelloFunc(RetValue: PV8Variant; Params: PV8ParamArray;
      const ParamCount: integer): boolean;
    function HelloFunc2(RetValue: PV8Variant;Params: PV8ParamArray;
      const ParamCount: integer): boolean;
    function PropertyIntGetSet(propValue: PV8Variant; Get: boolean): boolean;
    function PropertyStrGetSet(propValue: PV8Variant; Get: boolean): boolean;
    constructor Create; override;
  end;

  TMyClass2 = class(TV8UserObject)
  public
    function Hello(RetValue: PV8Variant; Params: PV8ParamArray;
      const ParamCount: integer): boolean;
  end;


 implementation

{ TMyClass }

function TMyClass.HelloFunc(RetValue: PV8Variant; Params: PV8ParamArray;
  const ParamCount: integer): boolean;
 //берем значения из четырех параметров функции, изменяем их
 //и помещаем значения обратно.
 //В результат функции пишем True
var
  i: integer;
  d: double;
  dt: TDateTime;
  w: WideString;
begin

  i := V8AsInt(@Params[1]);
  i := I * 2; //умножаем на 2
  V8SetInt(@Params[1], i); //сохраняем обратно в переменную 1С


  d := V8AsDouble(@Params[2]);
  d := d * 2; //умножаем на 2
  V8SetDouble(@Params[2], d); //сохраняем обратно в переменную 1С


  dt := V8AsDate(@Params[3]);
  dt := dt + 1; //добавляем день к дате
  V8SetDate(@Params[3], dt); //сохраняем обратно в переменную 1С


  w := V8AsPWideChar(@Params[4]);
  w := w + ' здесь была наша ВК'; //добавляем к параметру свою строку
  V8SetWString(@Params[4], w); //сохраняем обратно в переменную 1С

  V8SetBool(RetValue, True); //Результат функции

  result := True;
end;

function TMyClass.HelloFunc2(RetValue: PV8Variant;Params: PV8ParamArray;
  const ParamCount: integer): boolean;
//соединяем два строковых параметра в одну строку
//процедура имеет параметр по умолчанию
var
  w: WideString;
begin
  w := V8AsPWideChar(@Params[1]);
  w := w + V8AsPWideChar(@Params[2]);
  V8SetWString(RetValue,w);
  result := True;
end;

function TMyClass.PropertyIntGetSet(propValue: PV8Variant;
  Get: boolean): boolean;
begin
  if Get then //если 1С хочет получить значение нашего свойства
  begin
    V8SetInt(propValue, FPropertyInt);
  end else
  begin
    FPropertyInt := V8AsInt(propValue);
  end;
  result := True;
end;

function TMyClass.PropertyStrGetSet(propValue: PV8Variant;
  Get: boolean): boolean;
begin
  if Get then //если 1С хочет получить значение нашего свойства
  begin
    V8SetWString(propValue, FPropertyStr);
  end else
  begin
    FPropertyStr := V8AsPWideChar(propValue);
  end;
  result := True;
end;

constructor TMyClass.Create;
begin
   FPropertyInt := -1;
   FPropertyStr := 'начальное значение свойства';
end;

{ TMyClass2 }

function TMyClass2.Hello(RetValue: PV8Variant; Params: PV8ParamArray;
  const ParamCount: integer): boolean;
begin
    V8SetWString(RetValue,'Это TMyClass2! Привет из Delphi');
    result := True;
end;


begin
  //Регистрация класса 1
  with ClassRegList.RegisterClass(TMyClass, 'ПервыйКласс', 'TMyClass') do
  begin
    AddFunc('HelloFunc', 'ФункцияПривет', @TMyClass.HelloFunc, 4);
    with
    AddFunc('HelloFunc2', 'ФункцияПривет2', @TMyClass.HelloFunc2, 2) do
    begin
        DefParams.AddWString('Первый Параметр',1);
        DefParams.AddWString('Второй Параметр',2);
    end;
    AddProp('PropertyInt','СвойствоЧисло',True,True,@TMyClass.PropertyIntGetSet);
    AddProp('PropertyStr','СвойствоСтрока',True,True,@TMyClass.PropertyStrGetSet);
  end;

   //Регистрация класса 2
  with ClassRegList.RegisterClass(TMyClass2, 'ВторойКласс', 'TMyClass2') do
  begin
    AddFunc('Hello', 'Привет', @TMyClass2.Hello);
  end;


end.

