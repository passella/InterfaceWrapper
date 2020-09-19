unit untPrincipal;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
   Vcl.Controls, Vcl.Forms, Vcl.Dialogs, untTypes, untInterfaceWrapper,
  Vcl.StdCtrls;

type
   IMyInterface1 = interface;
   IMyInterface2 = interface;
   IMyInterface3 = interface;
   IMyInterface4 = interface;

   TfrmPrincipal = class(TForm)
    edtTeste: TEdit;
      procedure FormCreate(Sender: TObject);
   private
      { Private declarations }
      procedure DoMethod(const intF: IMyInterface1); overload;
      procedure DoMethod(const intF: IMyInterface2); overload;
      procedure DoMethod(const intF: IMyInterface3); overload;
      procedure DoMethod(const intF: IMyInterface4); overload;
   public
      { Public declarations }
   end;

   IMyInterface1 = interface(IInvokable)
      ['{0FA2A89D-58E3-4701-8862-4C3F349AD9B9}']
      [IndexedPropertyWrapperAttribute('Controls')]
      function GetControls(const Index: Integer): TControl;
      [PropertyWrapper('Caption')]
      function GetTitle: string;
      property Controls[const Index: Integer]: TControl read GetControls;
      property Title: string read GetTitle;
   end;

   IMyInterface2 = interface(IInvokable)
      ['{ADDEF9EB-AED7-455E-8C9B-439A9F53D8DA}']
      [FieldWrapper('FField')]
      function GetFField: Integer;
      [ClassMethodWrapperAttribute('class function GetMyClassIndexedProperty(const Index: Integer): Integer')]
      function GetMyClassIndexedProperty(const Index: Integer): Integer;
      [ClassMethodWrapperAttribute('class function GetMyClassProperty: Integer')]
      function GetMyClassProperty: Integer;
      [PropertyWrapper('MyProperty')]
      function GetMyProperty: Integer;
      [MethodWrapper('function MethodAnything: Integer')]
      function MethodEverythingEven: Integer;
      [FieldWrapper('FField')]
      procedure SetFField(const Value: Integer);
      [ClassMethodWrapperAttribute('class procedure SetMyClassIndexedProperty(const Index: Integer; const Value: Integer)')]
      procedure SetMyClassIndexedProperty(const Index: Integer; const Value: Integer);
      [ClassMethodWrapperAttribute('class procedure SetMyClassProperty(const Value: Integer)')]
      procedure SetMyClassProperty(const Value: Integer);
      [PropertyWrapper('MyProperty')]
      procedure SetMyProperty(const Value: Integer);
      function MyMethod(const par1: Integer; out par2: Integer): Integer;
      property FField: Integer read GetFField write SetFField;
      property MyClassIndexedProperty[const Index: Integer]: Integer read
          GetMyClassIndexedProperty write SetMyClassIndexedProperty;
      property MyClassProperty: Integer read GetMyClassProperty write SetMyClassProperty;
      property MyProperty: Integer read GetMyProperty write SetMyProperty;
   end;

   IMyInterface3 = interface(IInvokable)
      ['{7288311F-A609-4317-A917-BFB698F972A9}']
      function GetMyIndexedProperty(const Index: Integer): Integer;
      function GetMyProperty: Integer;
      [MethodWrapper('function MyMethod: Integer')]
      function MyMethodNew: Integer;
      procedure SetMyIndexedProperty(const Index: Integer; const Value: Integer);
      procedure SetMyProperty(const Value: Integer);
      property MyIndexedProperty[const Index: Integer]: Integer read
         GetMyIndexedProperty write SetMyIndexedProperty;
      property MyProperty: Integer read GetMyProperty write SetMyProperty;
   end;

   IMyInterface4 = interface(IInvokable)
      ['{A30DBEDD-383D-4BAA-9C92-867E216B4C20}']
      function GetMyIndexedProperty(const Index: Integer): Integer;
      function GetMyProperty: Integer;
      [FieldWrapper('FField')]
      function GetPrivateField: Integer;
      procedure SetMyIndexedProperty(const Index: Integer; const Value: Integer);
      procedure SetMyProperty(const Value: Integer);
      [FieldWrapper('FField')]
      procedure SetPrivateField(const Value: Integer);
      [MethodWrapper('function MyMethod: Integer')]
      function MyIntFMethod: Integer;
      [ClassMethodWrapper('class function MyClassMethod: Integer')]
      function MyClassMethod: Integer;

      property MyIndexedProperty[const Index: Integer]: Integer read
          GetMyIndexedProperty write SetMyIndexedProperty;
      property MyProperty: Integer read GetMyProperty write SetMyProperty;
      property PrivateField: Integer read GetPrivateField write SetPrivateField;
   end;

var
   frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}


procedure TfrmPrincipal.DoMethod(const intF: IMyInterface2);
begin
   intF.MyClassProperty := 100;
   ShowMessageFmt('intF.ClassProperty: %d', [intF.MyClassProperty]);

   intF.MyClassIndexedProperty[0] := 200;
   ShowMessageFmt('intF.MyClassIndexedProperty[0]: %d', [intF.MyClassIndexedProperty[0]]);

   intF.MyProperty := 300;
   ShowMessageFmt('intF.MyProperty: %d', [intF.MyProperty]);

   intF.FField := 10;
   ShowMessageFmt('intF.FField: %d', [intF.FField]);

   ShowMessageFmt('intF.MethodEverythingEven: %d', [intF.MethodEverythingEven]);

   var intPar: Integer;
   var ret := intF.MyMethod(50, intPar);
   ShowMessageFmt('intPar: %d, ret: %d', [intPar, ret]);
end;

procedure TfrmPrincipal.DoMethod(const intF: IMyInterface3);
begin
   ShowMessageFmt('intF.MyMethodNew: %d', [intF.MyMethodNew]);
   intF.MyIndexedProperty[0] := 5;
   ShowMessageFmt('intF.MyIndexedProperty[0]: %d', [intF.MyIndexedProperty[0]]);
   intF.MyProperty := 10;
   ShowMessageFmt('intF.MyProperty: %d', [intF.MyProperty]);
end;

procedure TfrmPrincipal.DoMethod(const intF: IMyInterface4);
begin
   intF.MyIndexedProperty[0] := 10;
   ShowMessageFmt('intF.MyIndexedProperty[0]: %d', [intF.MyIndexedProperty[0]]);
   intF.MyProperty := 50;
   ShowMessageFmt('intF.MyProperty: %d', [intF.MyProperty]);
   intF.PrivateField := 100;
   ShowMessageFmt('intF.PrivateField: %d', [intF.PrivateField]);
   ShowMessageFmt('intF.MyIntFMethod: %d', [intF.MyIntFMethod]);
   ShowMessageFmt('intF.MyClassMethod: %d', [intF.MyClassMethod]);
end;



procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
   var rec: TMyRecord;
   DoMethod(TInterfaceRecordWrapper<TMyRecord>.Wrap<IMyInterface4>(@rec));
   DoMethod(TInterfaceRecordWrapper<TMyRecord>.Wrap<IMyInterface4>());
   DoMethod(TInterfaceRecordWrapper<TMyRecord>.WrapCopy<IMyInterface4>(rec));
   DoMethod(TInterfaceWrapper.WrapInterface<IMyInterface, IMyInterface3>(TMyInterfaceImp.Create as IMyInterface));
   DoMethod(TInterfaceWrapper.WrapObject<TMyClass, IMyInterface2>(TMyClass.Create, True));
   DoMethod(TInterfaceWrapper.WrapObject<TfrmPrincipal, IMyInterface1>(Self));
end;

{ TfrmPrincipal }

procedure TfrmPrincipal.DoMethod(const intF: IMyInterface1);
begin
   ShowMessage(intF.Title);
   var ctr := intF.Controls[0];
   if Assigned(ctr) then
   begin
      ShowMessage(ctr.ClassName);
      if ctr is TEdit then
         ShowMessage((ctr as TEdit).Text);
   end;



end;

end.
