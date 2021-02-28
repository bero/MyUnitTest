unit TestShortCutHandler;

interface

uses
  TestFramework,
  Classes,
  ShortCutHandler,
  Generics.Collections,
  ActnList,
  Contnrs;

type
  TestTShortCutHandler = class(TTestCase)
  strict private
    FShortCutHandler: TShortCutHandler;
    fAction1: TAction;
    fAction2: TAction;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRegisterShortCutShouldFail;
    procedure TestRegisterShortCutShouldWork;
    procedure TestIsValidShortCutShouldFail;
    procedure TestIsValidShortCutShouldWork;
  end;

  TestTShortCutHandlerList = class(TTestCase)
  strict private
    FShortCutHandlerList: TShortCutHandlerList;
    fAction1: TAction;
    fAction2: TAction;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRegisterShortCut;
    procedure TestRegisterShortCutException;
    procedure TestValidateShortCut;
    procedure TestValidateShortCutException;
    procedure TestValidateAndRgisterException;
  end;

implementation

uses
  Menus,
  SysUtils;

const
  CTRL_A = 'CTRL+A';
  CTRL_B = 'CTRL+B';

function MakeAction(const aName, aShortCut: String): TAction;
begin
  Result := TAction.Create(nil);
  Result.Name := aName;
  Result.Category := 'Edit';
  Result.ShortCut := TextToShortCut(aShortCut);
end;

procedure TestTShortCutHandler.SetUp;
begin
  FShortCutHandler := TShortCutHandler.Create;
  fAction1 := MakeAction('actEx1', CTRL_A);
  fAction2 := MakeAction('actEx2', CTRL_A);
end;

procedure TestTShortCutHandler.TearDown;
begin
  FreeAndNil(FShortCutHandler);
end;

procedure TestTShortCutHandler.TestRegisterShortCutShouldFail;
begin
  ExpectedException := ShortCutException;
  FShortCutHandler.RegisterShortCut(fAction1);
  FShortCutHandler.RegisterShortCut(fAction2);
end;

procedure TestTShortCutHandler.TestRegisterShortCutShouldWork;
begin
  FShortCutHandler.RegisterShortCut(fAction1);
  fAction2.ShortCut := TextToShortCut(CTRL_B);
  FShortCutHandler.RegisterShortCut(fAction2);
end;

procedure TestTShortCutHandler.TestIsValidShortCutShouldFail;
var
  vShortCut: TShortCut;
begin
  ExpectedException := Exception;
  vShortCut := TextToShortCut(CTRL_A);
  FShortCutHandler.RegisterShortCut(fAction1);
  FShortCutHandler.ValidateShortCut(fAction2, vShortCut);
end;

procedure TestTShortCutHandler.TestIsValidShortCutShouldWork;
var
  vShortCut: TShortCut;
begin
  vShortCut := TextToShortCut(CTRL_B);
  FShortCutHandler.RegisterShortCut(fAction1);
  FShortCutHandler.ValidateShortCut(fAction1, vShortCut);
end;

procedure TestTShortCutHandlerList.SetUp;
begin
  FShortCutHandlerList := TShortCutHandlerList.Create;
  fAction1 := MakeAction('actEx1', CTRL_A);
  fAction2 := MakeAction('actEx2', CTRL_A);
end;

procedure TestTShortCutHandlerList.TearDown;
begin
  FreeAndNil(fAction1);
  FreeAndNil(fAction2);
  FreeAndNil(FShortCutHandlerList);
end;

procedure TestTShortCutHandlerList.TestRegisterShortCutException;
begin
  ExpectedException := Exception;
  FShortCutHandlerList.RegisterShortCut(fAction1);
  FShortCutHandlerList.RegisterShortCut(fAction2);
end;

procedure TestTShortCutHandlerList.TestRegisterShortCut;
begin
  FShortCutHandlerList.RegisterShortCut(fAction1);
  fAction2.ShortCut := TextToShortCut(CTRL_B);
  FShortCutHandlerList.RegisterShortCut(fAction2);
end;

procedure TestTShortCutHandlerList.TestValidateShortCut;
begin
  fAction2.ShortCut := 0;
  FShortCutHandlerList.RegisterShortCut(fAction1);
  FShortCutHandlerList.RegisterShortCut(fAction2);
end;

procedure TestTShortCutHandlerList.TestValidateShortCutException;
var
  vShortCut: TShortCut;
begin
  ExpectedException := ShortCutException;
  vShortCut := TextToShortCut(CTRL_A);
  fAction2.ShortCut := 0;
  FShortCutHandlerList.RegisterShortCut(fAction1);
  FShortCutHandlerList.ValidateShortCut(fAction2, vShortCut);
end;

procedure TestTShortCutHandlerList.TestValidateAndRgisterException;
var
  vShortCut: TShortCut;
begin
  ExpectedException := ShortCutException;

  fAction1.ShortCut := 0;
  vShortCut := TextToShortCut(CTRL_A);
  FShortCutHandlerList.ValidateShortCut(fAction1, vShortCut);
  fAction1.ShortCut := vShortCut;
  FShortCutHandlerList.RegisterShortCut(fAction1);

  fAction2.ShortCut := 0;
  FShortCutHandlerList.ValidateShortCut(fAction2, vShortCut);
  fAction2.ShortCut := vShortCut;
  FShortCutHandlerList.RegisterShortCut(fAction2);
end;

initialization
  RegisterTest(TestTShortCutHandler.Suite);
  RegisterTest(TestTShortCutHandlerList.Suite);

end.

