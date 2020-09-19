**

## Interface Wrapper

**

Classes responsible for encapsulating any Class / Interface or Record in a new interface, even if this object or interface does not implement the desired interface, even allowing a record to implement a desired interface

## **Example of use**

**Types**

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
          function MyMethod: Integer;
          procedure SetMyIndexedProperty(const Index: Integer; const Value: Integer);
          procedure SetMyProperty(const Value: Integer);
       end;

**Interfaces**

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
    
          property MyIndexedProperty[const Index: Integer]: Integer read
              GetMyIndexedProperty write SetMyIndexedProperty;
          property MyProperty: Integer read GetMyProperty write SetMyProperty;
          property PrivateField: Integer read GetPrivateField write SetPrivateField;
       end;


**Use**

       var rec: TMyRecord;
       DoMethod(TInterfaceRecordWrapper<TMyRecord>.Wrap<IMyInterface4>(@rec));
       DoMethod(TInterfaceRecordWrapper<TMyRecord>.Wrap<IMyInterface4>());
       DoMethod(TInterfaceRecordWrapper<TMyRecord>.WrapCopy<IMyInterface4>(rec));
       DoMethod(TInterfaceWrapper.WrapInterface<IMyInterface, IMyInterface3>(TMyInterfaceImp.Create as IMyInterface));
       DoMethod(TInterfaceWrapper.WrapObject<TMyClass, IMyInterface2>(TMyClass.Create, True));
       DoMethod(TInterfaceWrapper.WrapObject<TfrmPrincipal, IMyInterface1>(Self));
