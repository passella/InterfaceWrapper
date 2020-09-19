unit untTypes;

interface

uses
  System.Classes;

type
   {$M+}
   IMyInterface = interface
      ['{DCD13765-6F2E-4F50-B8E8-404D5B2CF5CD}']
      function GetMyIndexedProperty(const Index: Integer): Integer;
      function GetMyProperty: Integer;
      function MyMethod: Integer;
      procedure SetMyIndexedProperty(const Index: Integer; const Value: Integer);
      procedure SetMyProperty(const Value: Integer);
      property MyIndexedProperty[const Index: Integer]: Integer read
         GetMyIndexedProperty write SetMyIndexedProperty;
      property MyProperty: Integer read GetMyProperty write SetMyProperty;
   end;
   {$M-}

   TMyClass = class
   private
      FField: Integer;
      function GetMyIndexedProperty(const Index: Integer): Integer;
      function GetMyProperty: Integer;
      procedure SetMyIndexedProperty(const Index: Integer; const Value: Integer);
      procedure SetMyProperty(const Value: Integer);
      property MyIndexedProperty[const Index: Integer]: Integer read GetMyIndexedProperty write SetMyIndexedProperty;
   public
      constructor Create;
      destructor Destroy; override;
      function MyMethod(const par1: Integer; out par2: Integer): Integer;
      function MethodAnything: Integer;
      class function GetMyClassIndexedProperty(const Index: Integer): Integer; static;
      class function GetMyClassProperty: Integer; static;
      class procedure SetMyClassIndexedProperty(const Index: Integer; const Value: Integer); static;
      class procedure SetMyClassProperty(const Value: Integer); static;
      class property MyClassIndexedProperty[const Index: Integer]: Integer read
          GetMyClassIndexedProperty write SetMyClassIndexedProperty;
      class property MyClassProperty: Integer read GetMyClassProperty write
          SetMyClassProperty;
      property MyProperty: Integer read GetMyProperty write SetMyProperty;
   end;

   TMyInterfaceImp = class(TInterfacedObject, IMyInterface)
   strict private
      function GetMyIndexedProperty(const Index: Integer): Integer;
      function GetMyProperty: Integer;
      function MyMethod: Integer;
      procedure SetMyIndexedProperty(const Index: Integer; const Value: Integer);
      procedure SetMyProperty(const Value: Integer);
   public
      constructor Create();
      destructor Destroy; override;
   end;

   TMyRecord = packed record
   private
      FField: Integer;
   public
      function GetMyIndexedProperty(const Index: Integer): Integer;
      function GetMyProperty: Integer;
      class function MyClassMethod: Integer; static;
      function MyMethod: Integer;
      procedure SetMyIndexedProperty(const Index: Integer; const Value: Integer);
      procedure SetMyProperty(const Value: Integer);
   end;

implementation

uses
   Vcl.Dialogs;

constructor TMyClass.Create;
begin
   inherited Create();
   Randomize;
   FField := Random(100);
end;

destructor TMyClass.Destroy;
begin
   inherited Destroy;
end;

class function TMyClass.GetMyClassIndexedProperty(const Index: Integer):
    Integer;
begin
   Randomize;
   Result := Random(100);
end;

class function TMyClass.GetMyClassProperty: Integer;
begin
   Randomize;
   Result := Random(100);
end;

function TMyClass.GetMyIndexedProperty(const Index: Integer): Integer;
begin
   Result := Index;
end;

function TMyClass.GetMyProperty: Integer;
begin
   Randomize;
   Result := Random(100);
end;

function TMyClass.MethodAnything: Integer;
begin
   Randomize;
   Result := Random(100);
end;

function TMyClass.MyMethod(const par1: Integer; out par2: Integer): Integer;
begin
   Result := 2 * par1;
   par2 := 3 * par1;
end;

class procedure TMyClass.SetMyClassIndexedProperty(const Index: Integer; const
    Value: Integer);
begin
   ShowMessageFmt('%d %d', [Index, Value]);
end;

class procedure TMyClass.SetMyClassProperty(const Value: Integer);
begin
   ShowMessageFmt('%d', [Value]);
end;

procedure TMyClass.SetMyIndexedProperty(const Index: Integer; const Value:
   Integer);
begin
   ShowMessageFmt('%d %d', [Index, Value]);
end;

procedure TMyClass.SetMyProperty(const Value: Integer);
begin
   ShowMessageFmt('%d', [Value]);
end;

function TMyRecord.GetMyIndexedProperty(const Index: Integer): Integer;
begin
   Result := Index;
end;

function TMyRecord.GetMyProperty: Integer;
begin
   Randomize;
   Result := Random(100);
end;

class function TMyRecord.MyClassMethod: Integer;
begin
   Randomize;
   Result := Random(100);
end;

function TMyRecord.MyMethod: Integer;
begin
   Randomize;
   Result := Random(100);
end;

procedure TMyRecord.SetMyIndexedProperty(const Index: Integer; const Value:
   Integer);
begin
   ShowMessageFmt('%d %d', [Index, Value]);
end;

procedure TMyRecord.SetMyProperty(const Value: Integer);
begin
   ShowMessageFmt('%d', [Value]);
end;

constructor TMyInterfaceImp.Create;
begin
   inherited Create;
end;

destructor TMyInterfaceImp.Destroy;
begin
   inherited Destroy;
end;

function TMyInterfaceImp.GetMyIndexedProperty(const Index: Integer): Integer;
begin
   Result := Index;
end;

function TMyInterfaceImp.GetMyProperty: Integer;
begin
   Randomize;
   Result := Random(100);
end;

function TMyInterfaceImp.MyMethod: Integer;
begin
   Randomize;
   Result := Random(100);
end;

procedure TMyInterfaceImp.SetMyIndexedProperty(const Index: Integer; const
   Value: Integer);
begin
   ShowMessageFmt('%d %d', [Index, Value]);
end;

procedure TMyInterfaceImp.SetMyProperty(const Value: Integer);
begin
   ShowMessageFmt('%d', [Value]);
end;

end.
