program UnitTest;

{$APPTYPE CONSOLE}


{$R *.res}

uses
  FastMM4 in 'FastMM4.pas',
  FastMM4Messages in 'FastMM4Messages.pas',
  DUnitTestRunner,
  System.SysUtils,
  ShortCutHandler in 'ShortCutHandler.pas',
  TestShortCutHandler in 'TestShortCutHandler.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  DUnitTestRunner.RunRegisteredTests;
  ReadLn;
end.
