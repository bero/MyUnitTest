unit ShortCutHandler;

// Handler to prevent conflicts between shortcuts

interface

uses
  // VCL
  ActnList,
  Classes,
  Contnrs,
  Generics.Collections,
  SysUtils;

type
  ShortCutException = class(Exception);

  TShortCutHandler = class
  private
    fContext: String;
    fShortCutActions: TObjectList<TAction>;
    function FindActionByShortCut(aShortCut: TShortCut): TAction;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterShortCut(aAction: TAction);
    procedure ValidateShortCut(aAction: TAction; aShortCut: TShortCut);
    property Context: String read FContext write fContext;
  end;

  TShortCutHandlerList = class(TObjectList<TShortCutHandler>)
  private
    fGlobalShortCuts: TShortCutHandler;
    function FindLocalShortCuts(aAction: TAction): TShortCutHandler;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterShortCut(aAction: TAction);
    procedure ValidateShortCut(aAction: TAction; aShortCut: TShortCut);
  end;

function SCInstance: TShortCutHandlerList;

implementation

uses
  Menus,
  Windows;

const
  StrGlobalCategory = 'Global';

var
  G_ShortCutHandlerList: TShortCutHandlerList;

function SCInstance: TShortCutHandlerList;
begin
  Result := G_ShortCutHandlerList;
end;

constructor TShortCutHandler.Create;
begin
  inherited;
  fShortCutActions := TObjectList<TAction>.Create;
  fShortCutActions.OwnsObjects := False;
end;

destructor TShortCutHandler.Destroy;
begin
  fShortCutActions.Free;
  inherited;
end;

function TShortCutHandler.FindActionByShortCut(aShortCut: TShortCut): TAction;
var
  OldAction: TAction;
begin
  for OldAction in fShortCutActions do
    if OldAction.ShortCut = aShortCut then
      Exit(OldAction);

  Result := nil;
end;

procedure TShortCutHandler.ValidateShortCut(aAction: TAction; aShortCut: TShortCut);
var
  OldAction: TAction;
begin
  for OldAction in fShortCutActions do
    if (OldAction.ShortCut = aShortCut) and (OldAction.Name <> aAction.Name) then
      raise ShortCutException.CreateFmt('Shortcut from action %s (%s) %s already taken by %s (%s)',
               [aAction.Name, aAction.Caption, ShortCutToText(aShortCut), OldAction.Name, OldAction.Caption]);
end;

procedure TShortCutHandler.RegisterShortCut(aAction: TAction);
var
  OldAction: TAction;
begin
  OldAction := FindActionByShortCut(aAction.ShortCut);

  if not Assigned(OldAction) then
    fShortCutActions.Add(aAction)
  else if OldAction.Name <> aAction.Name then
    raise ShortCutException.CreateFmt('Shortcut %s already taken by %s (%s) when add %s (%s)',
      [ShortCutToText(aAction.ShortCut), OldAction.Name, OldAction.Caption, aAction.Name, aAction.Caption]);
end;

procedure TShortCutHandlerList.RegisterShortCut(aAction: TAction);
begin
  if aAction.ShortCut > 0 then
  begin                                                // May raise exception if conflict detected
    if aAction.Category = StrGlobalCategory then
      fGlobalShortCuts.RegisterShortCut(aAction)
    else
      fGlobalShortCuts.ValidateShortCut(aAction, aAction.ShortCut);

    FindLocalShortCuts(aAction).RegisterShortCut(aAction);
  end;
end;

procedure TShortCutHandlerList.ValidateShortCut(aAction: TAction; aShortCut: TShortCut);
begin
  if aShortCut > 0 then
  begin
    fGlobalShortCuts.ValidateShortCut(aAction, aShortCut);      // May raise exception if conflict detected
    FindLocalShortCuts(aAction).ValidateShortCut(aAction, aShortCut);
  end;
end;

function TShortCutHandlerList.FindLocalShortCuts(aAction: TAction): TShortCutHandler;
var
  vLoopHandle: TShortCutHandler;
begin
  for vLoopHandle in Self do
    if vLoopHandle.Context = aAction.Category then
      Exit(vLoopHandle);

  Result := TShortCutHandler.Create;
  Result.Context := aAction.Category;
  Add(Result);
end;

constructor TShortCutHandlerList.Create;
begin
  inherited;
  fGlobalShortCuts := TShortCutHandler.Create;
  fGlobalShortCuts.Context := StrGlobalCategory;
end;

destructor TShortCutHandlerList.Destroy;
begin
  fGlobalShortCuts.Free;
  inherited;
end;

initialization
  G_ShortCutHandlerList := TShortCutHandlerList.Create;

finalization
  G_ShortCutHandlerList.Free;

end.

