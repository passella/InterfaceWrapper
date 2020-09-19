{

MIT License

Copyright (c) 2020 Paulo Henrique de Freitas Passella (passella@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
}
unit untInterfaceWrapper;

interface

uses
   System.Rtti, System.Generics.Collections, System.SysUtils, System.TypInfo;

type
   TInterfaceWrapper = class
   public
      class function WrapInterface<S: IInterface; D: IInvokable>(const source: S): D; overload;
      class function WrapObject<S: class; D: IInvokable>(const source: S; const blnFree: Boolean = False): D; overload;
   end;

   TIntfFlagEx = (ifHasGuid, ifDispInterface, ifDispatch, ifMethodInfo);
   TIntfFlagsEx = set of TIntfFlagEx;

   IInterfaceWrapper = interface
      ['{2138C7E7-F911-4992-9E96-F3F1CE7C70C3}']
      procedure OnInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
   end;

   TRttiPropertyInterfaceWrapper = class(TInterfacedObject, IInterfaceWrapper)
   private
      instance: Pointer;
      sourceProperty: TRttiProperty;
   public
      constructor Create(const sourceProperty: TRttiProperty; const instance: Pointer);
      procedure OnInvoke(Method: TRttiMethod; const Args: System.TArray<System.Rtti.TValue>; out Result: TValue);
   end;

   TRttiIndexedPropertyInterfaceWrapper = class(TInterfacedObject, IInterfaceWrapper)
   private
      instance: Pointer;
      sourceProperty: TRttiIndexedProperty;
   public
      constructor Create(const sourceProperty: TRttiIndexedProperty; const instance: Pointer);
      procedure OnInvoke(Method: TRttiMethod; const Args: System.TArray<System.Rtti.TValue>; out Result: TValue);
   end;

   TRttiFieldInterfaceWrapper = class(TInterfacedObject, IInterfaceWrapper)
   private
      instance: Pointer;
      sourceField: TRttiField;
   public
      constructor Create(const sourceField: TRttiField; const instance: Pointer);
      procedure OnInvoke(Method: TRttiMethod; const Args: System.TArray<System.Rtti.TValue>; out Result: TValue);
   end;

   TRttiMethodInterfaceWrapper = class(TInterfacedObject, IInterfaceWrapper)
   private
      instance: TValue;
      mth: TRttiMethod;
   public
      constructor Create(const mth: TRttiMethod; const instance: TValue);
      procedure OnInvoke(Method: TRttiMethod; const Args: System.TArray<System.Rtti.TValue>; out Result: TValue);
   end;

   TInterfaceRecordWrapper<T: Record> = class
   public
      type PT = ^T;
   public
      class function Wrap<D: IInvokable>(const source: PT): D; overload;
      class function Wrap<D: IInvokable>(): D; overload;
      class function WrapCopy<D: IInvokable>(const source: T): D;
   end;

   TInterfaceObjectWrapper<S: class; D: IInvokable> = class(TVirtualInterface)
   private
      blnFree: Boolean;
      dicMethods: TDictionary<TRttiMethod, IInterfaceWrapper>;
      source: S;
      procedure Map;
   public
      constructor Create(const source: S; const blnFree: Boolean = False);
      destructor Destroy; override;
   end;

   TInterfaceRecordWrapper<S: record; D: IInvokable> = class(TVirtualInterface)
   private
      type PS = ^S;
   private
      blnFree: Boolean;
      dicMethods: TDictionary<TRttiMethod, IInterfaceWrapper>;
      source: PS;
      procedure Map;
      procedure SetOnInvoke;
   public
      constructor Create(const source: PS); overload;
      constructor Create(const source: S); overload;
      constructor Create(); overload;
      destructor Destroy; override;
   end;

   TInterfaceInterfaceWrapper<S: IInterface; D: IInvokable> = class(TVirtualInterface)
   private
      dicMethods: TDictionary<TRttiMethod, IInterfaceWrapper>;
      source: S;
      procedure Map;
   public
      constructor Create(const source: S);
      destructor Destroy; override;
   end;

   PropertyWrapperAttribute = class(TCustomAttribute)
   private
      strPropertyName: string;
   public
      constructor Create(const strPropertyName: string);
      property PropertyName: string read strPropertyName;
   end;

   IndexedPropertyWrapperAttribute = class(TCustomAttribute)
   private
      strPropertyName: string;
   public
      constructor Create(const strPropertyName: string);
      property PropertyName: string read strPropertyName;
   end;

   ClassMethodWrapperAttribute = class(TCustomAttribute)
   private
      strMethodSignature: string;
   public
      constructor Create(const strMethodSignature: string);
      property MethodSignature: string read strMethodSignature;
   end;

   FieldWrapperAttribute = class(TCustomAttribute)
   private
      strFieldName: string;
   public
      constructor Create(const strFieldName: string);
      property FieldName: string read strFieldName;
   end;

   MethodWrapperAttribute = class(TCustomAttribute)
   private
      strMethodSignature: string;
   public
      constructor Create(const strMethodSignature: string);
      property MethodSignature: string read strMethodSignature;
   end;

   TRttiObjectHelper = class helper for TRttiObject
   public
      function GetAttribute<T: TCustomAttribute>(): T;
   end;

   EPropertyNotFound = class(Exception);
   EIndextedPropertyNotFound = class(Exception);
   EClassMethodNotFound = class(Exception);
   EMethodNotFound = class(Exception);
   EFieldNotFound = class(Exception);
   EInterfaceWrapperNotMethodInfo = class(Exception);
   EInterfaceWrapperNotSupports = class(Exception);

implementation


{ TInterfaceWrapper }

class function TInterfaceWrapper.WrapInterface<S, D>(const source: S): D;
begin
   var flags := TIntfFlagsEx(GetTypeData(TypeInfo(S))^.IntfFlags);
   if not (ifMethodInfo in flags) then
      raise EInterfaceWrapperNotMethodInfo.CreateFmt('The type %s has no Method Info', [PTypeInfo(TypeInfo(S))^.Name]);

   var intF := TInterfaceInterfaceWrapper<S,D>.Create(source);
   if not Supports(intF, GetTypeData(TypeInfo(D))^.GUID, Result) then
      raise EInterfaceWrapperNotSupports.CreateFmt('the type %s not supports %s', [PTypeInfo(TypeInfo(S))^.Name, PTypeInfo(TypeInfo(D))^.Name]);
end;

class function TInterfaceWrapper.WrapObject<S, D>(const source: S; const blnFree: Boolean): D;
begin
   var intF := TInterfaceObjectWrapper<S,D>.Create(source, blnFree);
   Supports(intF, GetTypeData(TypeInfo(D))^.GUID, Result);
end;

{ TInterfaceRecordWrapper<T> }

class function TInterfaceRecordWrapper<T>.Wrap<D>(const source: PT): D;
begin
   var intF := TInterfaceRecordWrapper<T,D>.Create(source);
   Supports(intF, GetTypeData(TypeInfo(D))^.GUID, Result);
end;

constructor PropertyWrapperAttribute.Create(const strPropertyName: string);
begin
   inherited Create();
   Self.strPropertyName := strPropertyName;
end;

class function TInterfaceRecordWrapper<T>.Wrap<D>: D;
begin
   var intF := TInterfaceRecordWrapper<T,D>.Create();
   Supports(intF, GetTypeData(TypeInfo(D))^.GUID, Result);
end;

class function TInterfaceRecordWrapper<T>.WrapCopy<D>(const source: T): D;
begin
   var intF := TInterfaceRecordWrapper<T,D>.Create(source);
   Supports(intF, GetTypeData(TypeInfo(D))^.GUID, Result);
end;

{ TInterfaceObjectWrapper<S, D> }

constructor TInterfaceObjectWrapper<S, D>.Create(const source: S; const blnFree: Boolean);
begin
   inherited Create(TypeInfo(D));
   Self.source := source;
   Self.blnFree := blnFree;
   dicMethods := TDictionary<TRttiMethod, IInterfaceWrapper>.Create;
   Map;

   Self.OnInvoke := procedure(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue)
      begin
         var sourceMethod: IInterfaceWrapper := nil;

         if dicMethods.TryGetValue(Method, sourceMethod) then
         begin
            sourceMethod.OnInvoke(Method, Args, Result);
         end;
      end;
end;

destructor TInterfaceObjectWrapper<S, D>.Destroy;
begin
   if Assigned(dicMethods) then FreeAndNil(dicMethods);

   if blnFree then
   begin
      TObject(source).Free;
   end;

   inherited Destroy;
end;

procedure TInterfaceObjectWrapper<S, D>.Map;
begin
   var ctx: TRttiContext := TRttiContext.Create;
   try
      var destinyCtxType: TRttiType := ctx.GetType(TypeInfo(D));
      var destinyMethods: TArray<TRttiMethod> := destinyCtxType.GetMethods;

      var sourceCtxType: TRttiType := ctx.GetType(TypeInfo(S));
      var sourceMethods: TArray<TRttiMethod> := sourceCtxType.GetMethods;

      for var i := Low(destinyMethods) to High(destinyMethods) do
      begin
         var destinyMethod: TRttiMethod := destinyMethods[i];
         var sourceMethod: TRttiMethod := nil;

         var propAttr: PropertyWrapperAttribute := destinyMethod.GetAttribute<PropertyWrapperAttribute>();
         if Assigned(propAttr) then
         begin
            var prop: TRttiProperty := sourceCtxType.GetProperty(propAttr.PropertyName);
            if Assigned(prop) then
            begin
               dicMethods.AddOrSetValue(destinyMethod, TRttiPropertyInterfaceWrapper.Create(prop, TObject(source)));
               continue;
            end;

            raise EPropertyNotFound.CreateFmt('The property [%s] defined in interface [%s] in method [%s] was not found in type [%s]',
               [propAttr.PropertyName, destinyCtxType.Name, destinyMethod.ToString, sourceCtxType.Name]);
         end;

         var idxPropertyWrapperAttribute: IndexedPropertyWrapperAttribute := destinyMethod.GetAttribute<IndexedPropertyWrapperAttribute>();
         if Assigned(idxPropertyWrapperAttribute) then
         begin
            var idxProperty: TRttiIndexedProperty := sourceCtxType.GetIndexedProperty(idxPropertyWrapperAttribute.PropertyName);
            if Assigned(idxProperty) then
            begin
               dicMethods.AddOrSetValue(destinyMethod, TRttiIndexedPropertyInterfaceWrapper.Create(idxProperty, TObject(source)));
               continue;
            end;

            raise EIndextedPropertyNotFound.CreateFmt('The indexed property [%s] defined in interface [%s] in method [%s] was not found in type [%s]',
               [idxPropertyWrapperAttribute.PropertyName, destinyCtxType.Name, destinyMethod.ToString, sourceCtxType.Name]);
         end;

         var fltWrapperAttribute: FieldWrapperAttribute := destinyMethod.GetAttribute<FieldWrapperAttribute>();
         if Assigned(fltWrapperAttribute) then
         begin
            var flt: TRttiField := sourceCtxType.GetField(fltWrapperAttribute.FieldName);
            if Assigned(flt) then
            begin
               dicMethods.AddOrSetValue(destinyMethod, TRttiFieldInterfaceWrapper.Create(flt, TObject(source)));
               continue;
            end;

            raise EFieldNotFound.CreateFmt('The field [%s] defined in interface [%s] in method [%s] was not found in type [%s]',
               [fltWrapperAttribute.FieldName, destinyCtxType.Name, destinyMethod.ToString, sourceCtxType.Name]);
         end;

         var clsMethodWrapperAttribute: ClassMethodWrapperAttribute := destinyMethod.GetAttribute<ClassMethodWrapperAttribute>();
         if Assigned(clsMethodWrapperAttribute) then
         begin
            var arrMethods: TArray<TRttiMethod> := sourceCtxType.GetMethods;
            for var im := Low(arrMethods) to High(arrMethods) do
            begin
               if arrMethods[im].IsClassMethod then
               begin
                  if arrMethods[im].ToString.ToUpper().Replace(' ', '').Trim = clsMethodWrapperAttribute.MethodSignature.ToUpper().Replace(' ', '').Trim then
                  begin
                     sourceMethod := arrMethods[im];
                     break;
                  end;
               end;
            end;

            if not Assigned(sourceMethod) then
               raise EClassMethodNotFound.CreateFmt('The class method [%s] defined in interface [%s] in method [%s] was not found in type [%s]',
                  [clsMethodWrapperAttribute.MethodSignature, destinyCtxType.Name, destinyMethod.ToString, sourceCtxType.Name]);
         end;

         if not Assigned(sourceMethod) then
         begin
            var mthWrapperAttribute: MethodWrapperAttribute := destinyMethod.GetAttribute<MethodWrapperAttribute>();
            if Assigned(mthWrapperAttribute) then
            begin
               var arrMethods: TArray<TRttiMethod> := sourceCtxType.GetMethods;
               for var im := Low(arrMethods) to High(arrMethods) do
               begin
                  if not arrMethods[im].IsClassMethod then
                  begin
                     if arrMethods[im].ToString.ToUpper().Replace(' ', '').Trim = mthWrapperAttribute.MethodSignature.ToUpper().Replace(' ', '').Trim then
                     begin
                        sourceMethod := arrMethods[im];
                        break;
                     end;
                  end;
               end;

               if not Assigned(sourceMethod) then
                  raise EMethodNotFound.CreateFmt('The method [%s] defined in interface [%s] in method [%s] was not found in type [%s]',
                     [mthWrapperAttribute.MethodSignature, destinyCtxType.Name, destinyMethod.ToString, sourceCtxType.Name]);
            end;
         end;

         if not Assigned(sourceMethod) then
         begin
            for var m := Low(sourceMethods) to High(sourceMethods) do
            begin
               if sourceMethods[m].ToString.ToUpper().Replace(' ', '').Trim = destinyMethod.ToString.ToUpper().Replace(' ', '').Trim then
               begin
                  sourceMethod := sourceMethods[m];
                  break;
               end;
            end;
         end;

         if Assigned(sourceMethod) then
         begin
            dicMethods.AddOrSetValue(destinyMethod, TRttiMethodInterfaceWrapper.Create(sourceMethod, TValue.From(TObject(source))));
            continue;
         end;

         if not Assigned(sourceMethod) then
            raise EMethodNotFound.CreateFmt('The method [%s] was not found in type [%s]', [destinyMethod.ToString, sourceCtxType.Name]);
      end;
   finally
      ctx.Free;
   end;
end;

{ TRttiObjectHelper }

function TRttiObjectHelper.GetAttribute<T>: T;
begin
   Result := nil;
   var attributes: TArray<TCustomAttribute> := GetAttributes();
   var clsAttribute: TClass := GetTypeData(TypeInfo(T))^.ClassType;

   for var i := Low(attributes) to High(attributes) do
   begin
      if clsAttribute = attributes[i].ClassType then
         Exit(TValue.From(attributes[i]).AsType<T>());
   end;
end;

{ ClassMethodWrapperAttribute }

constructor ClassMethodWrapperAttribute.Create(
  const strMethodSignature: string);
begin
   inherited Create;
   Self.strMethodSignature := strMethodSignature;
end;

{ IndexedPropertyWrapperAttribute }

constructor IndexedPropertyWrapperAttribute.Create(
  const strPropertyName: string);
begin
   inherited Create();
   Self.strPropertyName := strPropertyName;
end;

{ FieldWrapperAttribute }

constructor FieldWrapperAttribute.Create(const strFieldName: string);
begin
   inherited Create();
   Self.strFieldName := strFieldName;
end;

{ MethodWrapperAttribute }

constructor MethodWrapperAttribute.Create(
  const strMethodSignature: string);
begin
   inherited Create();
   Self.strMethodSignature := strMethodSignature;
end;

{ TRttiPropertyInterfaceWrapper }

constructor TRttiPropertyInterfaceWrapper.Create(
  const sourceProperty: TRttiProperty; const instance: Pointer);
begin
   inherited Create();
   Self.sourceProperty := sourceProperty;
   Self.instance := instance;
end;

procedure TRttiPropertyInterfaceWrapper.OnInvoke(Method: TRttiMethod;
  const Args: System.TArray<System.Rtti.TValue>; out Result: TValue);
begin
   case Method.MethodKind of
      mkProcedure: sourceProperty.SetValue(instance, Args[1]);
      mkFunction: Result := sourceProperty.GetValue(instance);
   end;
end;

{ TRttiIndexedPropertyInterfaceWrapper }

constructor TRttiIndexedPropertyInterfaceWrapper.Create(
  const sourceProperty: TRttiIndexedProperty; const instance: Pointer);
begin
   inherited Create();
   Self.sourceProperty := sourceProperty;
   Self.instance := instance;
end;

procedure TRttiIndexedPropertyInterfaceWrapper.OnInvoke(
  Method: TRttiMethod; const Args: System.TArray<System.Rtti.TValue>;
  out Result: TValue);
begin
   case Method.MethodKind of
      mkProcedure: sourceProperty.SetValue(instance, Copy(Args, 1, Length(Args) - 2), Args[Length(Args) - 1]);
      mkFunction: Result := sourceProperty.GetValue(instance, Copy(Args, 1, Length(Args) - 1));
   end;
end;

{ TRttiFieldInterfaceWrapper }

constructor TRttiFieldInterfaceWrapper.Create(
  const sourceField: TRttiField; const instance: Pointer);
begin
   inherited Create();
   Self.sourceField := sourceField;
   Self.instance := instance;
end;

procedure TRttiFieldInterfaceWrapper.OnInvoke(Method: TRttiMethod;
  const Args: System.TArray<System.Rtti.TValue>; out Result: TValue);
begin
   case Method.MethodKind of
      mkProcedure: sourceField.SetValue(instance, Args[1]);
      mkFunction: Result := sourceField.GetValue(instance);
   end;
end;

{ TRttiMethodInterfaceWrapper }

constructor TRttiMethodInterfaceWrapper.Create(const mth: TRttiMethod; const instance: TValue);
begin
   inherited Create();
   Self.mth := mth;
   Self.instance := instance;
end;

procedure TRttiMethodInterfaceWrapper.OnInvoke(Method: TRttiMethod;
  const Args: System.TArray<System.Rtti.TValue>; out Result: TValue);
begin
   Result := mth.Invoke(instance, Copy(Args, 1, Length(Args) - 1));
end;

{ TInterfaceInterfaceWrapper<S, D> }

constructor TInterfaceInterfaceWrapper<S, D>.Create(const source: S);
begin
   inherited Create(TypeInfo(D));
   Self.source := source;
   dicMethods := TDictionary<TRttiMethod, IInterfaceWrapper>.Create;
   Map;

   Self.OnInvoke := procedure(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue)
      begin
         var sourceMethod: IInterfaceWrapper := nil;

         if dicMethods.TryGetValue(Method, sourceMethod) then
         begin
            sourceMethod.OnInvoke(Method, Args, Result);
         end;
      end;
end;

destructor TInterfaceInterfaceWrapper<S, D>.Destroy;
begin
   if Assigned(dicMethods) then FreeAndNil(dicMethods);
   inherited Destroy;
end;

procedure TInterfaceInterfaceWrapper<S, D>.Map;
begin
   var ctx: TRttiContext := TRttiContext.Create;
   try
      var destinyCtxType: TRttiType := ctx.GetType(TypeInfo(D));
      var destinyMethods: TArray<TRttiMethod> := destinyCtxType.GetMethods;

      var sourceCtxType: TRttiType := ctx.GetType(TypeInfo(S));
      var sourceMethods: TArray<TRttiMethod> := sourceCtxType.GetMethods;

      for var i := Low(destinyMethods) to High(destinyMethods) do
      begin
         var destinyMethod: TRttiMethod := destinyMethods[i];
         var sourceMethod: TRttiMethod := nil;

         var mthWrapperAttribute: MethodWrapperAttribute := destinyMethod.GetAttribute<MethodWrapperAttribute>();
         if Assigned(mthWrapperAttribute) then
         begin
            var arrMethods: TArray<TRttiMethod> := sourceCtxType.GetMethods;
            for var im := Low(arrMethods) to High(arrMethods) do
            begin
               if not arrMethods[im].IsClassMethod then
               begin
                  if arrMethods[im].ToString.ToUpper().Replace(' ', '').Trim = mthWrapperAttribute.MethodSignature.ToUpper().Replace(' ', '').Trim then
                  begin
                     sourceMethod := arrMethods[im];
                     break;
                  end;
               end;
            end;

            if not Assigned(sourceMethod) then
               raise EMethodNotFound.CreateFmt('The method [%s] defined in interface [%s] in method [%s] was not found in type [%s]',
                  [mthWrapperAttribute.MethodSignature, destinyCtxType.Name, destinyMethod.ToString, sourceCtxType.Name]);
         end;

         if not Assigned(sourceMethod) then
         begin
            for var m := Low(sourceMethods) to High(sourceMethods) do
            begin
               if sourceMethods[m].ToString.ToUpper().Replace(' ', '').Trim = destinyMethod.ToString.ToUpper().Replace(' ', '').Trim then
               begin
                  sourceMethod := sourceMethods[m];
                  break;
               end;
            end;
         end;

         if Assigned(sourceMethod) then
         begin
            dicMethods.AddOrSetValue(destinyMethod, TRttiMethodInterfaceWrapper.Create(sourceMethod, TValue.From(IInvokable(source))));
            continue;
         end;

         if not Assigned(sourceMethod) then
            raise EMethodNotFound.CreateFmt('The method [%s] was not found in type [%s]', [destinyMethod.ToString, sourceCtxType.Name]);
      end;
   finally
      ctx.Free;
   end;
end;

{ TInterfaceRecordWrapper<S, D> }

constructor TInterfaceRecordWrapper<S, D>.Create(const source: PS);
begin
   inherited Create(TypeInfo(D));
   Self.source := source;
   Self.blnFree := False;
   dicMethods := TDictionary<TRttiMethod, IInterfaceWrapper>.Create;
   Map;
   SetOnInvoke;
end;

constructor TInterfaceRecordWrapper<S, D>.Create;
begin
   inherited Create(TypeInfo(D));
   New(Self.source);
   Self.blnFree := True;
   dicMethods := TDictionary<TRttiMethod, IInterfaceWrapper>.Create;
   Map;
   SetOnInvoke;
end;

constructor TInterfaceRecordWrapper<S, D>.Create(const source: S);
begin
   inherited Create(TypeInfo(D));
   New(Self.source);
   Self.source^ := source;
   Self.blnFree := True;
   dicMethods := TDictionary<TRttiMethod, IInterfaceWrapper>.Create;
   Map;
   SetOnInvoke;
end;

destructor TInterfaceRecordWrapper<S, D>.Destroy;
begin
   if Assigned(dicMethods) then FreeAndNil(dicMethods);

   if blnFree then
   begin
      Dispose(source);
   end;

   inherited Destroy;
end;

procedure TInterfaceRecordWrapper<S, D>.Map;
begin
   var ctx: TRttiContext := TRttiContext.Create;
   try
      var destinyCtxType: TRttiType := ctx.GetType(TypeInfo(D));
      var destinyMethods: TArray<TRttiMethod> := destinyCtxType.GetMethods;

      var sourceCtxType: TRttiType := ctx.GetType(TypeInfo(S));
      var sourceMethods: TArray<TRttiMethod> := sourceCtxType.GetMethods;

      for var i := Low(destinyMethods) to High(destinyMethods) do
      begin
         var destinyMethod: TRttiMethod := destinyMethods[i];
         var sourceMethod: TRttiMethod := nil;

         var fltWrapperAttribute: FieldWrapperAttribute := destinyMethod.GetAttribute<FieldWrapperAttribute>();
         if Assigned(fltWrapperAttribute) then
         begin
            var flt: TRttiField := sourceCtxType.GetField(fltWrapperAttribute.FieldName);
            if Assigned(flt) then
            begin
               dicMethods.AddOrSetValue(destinyMethod, TRttiFieldInterfaceWrapper.Create(flt, TObject(source)));
               continue;
            end;

            raise EFieldNotFound.CreateFmt('The field [%s] defined in interface [%s] in method [%s] was not found in type [%s]',
               [fltWrapperAttribute.FieldName, destinyCtxType.Name, destinyMethod.ToString, sourceCtxType.Name]);
         end;

         var clsMethodWrapperAttribute: ClassMethodWrapperAttribute := destinyMethod.GetAttribute<ClassMethodWrapperAttribute>();
         if Assigned(clsMethodWrapperAttribute) then
         begin
            var arrMethods: TArray<TRttiMethod> := sourceCtxType.GetMethods;
            for var im := Low(arrMethods) to High(arrMethods) do
            begin
               if arrMethods[im].IsClassMethod then
               begin
                  if arrMethods[im].ToString.ToUpper().Replace(' ', '').Trim = clsMethodWrapperAttribute.MethodSignature.ToUpper().Replace(' ', '').Trim then
                  begin
                     sourceMethod := arrMethods[im];
                     break;
                  end;
               end;
            end;

            if not Assigned(sourceMethod) then
               raise EClassMethodNotFound.CreateFmt('The class method [%s] defined in interface [%s] in method [%s] was not found in type [%s]',
                  [clsMethodWrapperAttribute.MethodSignature, destinyCtxType.Name, destinyMethod.ToString, sourceCtxType.Name]);
         end;

         if not Assigned(sourceMethod) then
         begin
            var mthWrapperAttribute: MethodWrapperAttribute := destinyMethod.GetAttribute<MethodWrapperAttribute>();
            if Assigned(mthWrapperAttribute) then
            begin
               var arrMethods: TArray<TRttiMethod> := sourceCtxType.GetMethods;
               for var im := Low(arrMethods) to High(arrMethods) do
               begin
                  if not arrMethods[im].IsClassMethod then
                  begin
                     if arrMethods[im].ToString.ToUpper().Replace(' ', '').Trim = mthWrapperAttribute.MethodSignature.ToUpper().Replace(' ', '').Trim then
                     begin
                        sourceMethod := arrMethods[im];
                        break;
                     end;
                  end;
               end;

               if not Assigned(sourceMethod) then
                  raise EMethodNotFound.CreateFmt('The method [%s] defined in interface [%s] in method [%s] was not found in type [%s]',
                     [mthWrapperAttribute.MethodSignature, destinyCtxType.Name, destinyMethod.ToString, sourceCtxType.Name]);
            end;
         end;

         if not Assigned(sourceMethod) then
         begin
            for var m := Low(sourceMethods) to High(sourceMethods) do
            begin
               if sourceMethods[m].ToString.ToUpper().Replace(' ', '').Trim = destinyMethod.ToString.ToUpper().Replace(' ', '').Trim then
               begin
                  sourceMethod := sourceMethods[m];
                  break;
               end;
            end;
         end;

         if Assigned(sourceMethod) then
         begin
            dicMethods.AddOrSetValue(destinyMethod, TRttiMethodInterfaceWrapper.Create(sourceMethod, TValue.From(source)));
            continue;
         end;

         if not Assigned(sourceMethod) then
            raise EMethodNotFound.CreateFmt('The method [%s] was not found in type [%s]', [destinyMethod.ToString, sourceCtxType.Name]);
      end;
   finally
      ctx.Free;
   end;
end;

procedure TInterfaceRecordWrapper<S, D>.SetOnInvoke;
begin
   Self.OnInvoke := procedure(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue)
      begin
         var sourceMethod: IInterfaceWrapper := nil;

         if dicMethods.TryGetValue(Method, sourceMethod) then
         begin
            sourceMethod.OnInvoke(Method, Args, Result);
         end;
      end;
end;

end.
