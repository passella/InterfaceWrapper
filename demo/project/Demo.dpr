program Demo;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  untPrincipal in '..\src\untPrincipal.pas' {frmPrincipal},
  untInterfaceWrapper in '..\..\lib\untInterfaceWrapper.pas',
  untTypes in '..\src\untTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
