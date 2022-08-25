unit main;

interface

uses
  // Delphi
  System.Classes,
  System.Rtti,
  System.SysUtils,
  System.Types,
  // FireMonkey
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  // web3
  web3,
  web3.eth.nodelist;

type
  INodeEx = interface
  ['{51880ECB-A0C8-4C16-BF06-572001666983}']
    function Checked: Boolean;
    function SetChecked(Value: Boolean): INodeEx;
    function Online: TOnline;
    function SetOnline(Value: TOnline): INodeEx;
    function Censored: Boolean;
    function SetCensored(Value: Boolean): INodeEx;
  end;

  TfrmMain = class(TForm)
    btnStart: TButton;
    Grid: TGrid;
    colCheck: TCheckColumn;
    colName: TStringColumn;
    colStatus: TStringColumn;
    procedure btnStartClick(Sender: TObject);
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridSetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure GridDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
  private
    FNodes: TNodes;
    class function Chain: TChain;
    function GetNodeEx(Index: Integer): INodeEx;
    procedure Refresh(callback: TProc = nil);
    procedure Repaint;
    procedure SetNodes(Value: TNodes);
  public
    constructor Create(aOwner: TComponent); override;
    property Nodes: TNodes read FNodes write SetNodes;
    property NodeEx[Index: Integer]: INodeEx read GetNodeEx;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  // Delphi
  System.UITypes,
  // FireMonkey
  FMX.Dialogs,
  // Velthuis' BigNumbers
  Velthuis.BigIntegers,
  // web3
  web3.eth.tx,
  web3.eth.types;

type
  TNodeEx = class(TInterfacedObject, INodeEx)
  private
    FChecked : Boolean;
    FOnline  : TOnline;
    FCensored: Boolean;
  public
    function Checked: Boolean;
    function SetChecked(Value: Boolean): INodeEx;
    function Online: TOnline;
    function SetOnline(Value: TOnline): INodeEx;
    function Censored: Boolean;
    function SetCensored(Value: Boolean): INodeEx;
    constructor Create(aChecked: Boolean);
  end;

{ TNodeEx }

constructor TNodeEx.Create(aChecked: Boolean);
begin
  inherited Create;
  FChecked := aChecked;
end;

function TNodeEx.Checked: Boolean;
begin
  Result := FChecked;
end;

function TNodeEx.SetChecked(Value: Boolean): INodeEx;
begin
  FChecked := Value;
  Result := Self;
end;

function TNodeEx.Online: TOnline;
begin
  Result := FOnline;
end;

function TNodeEx.SetOnline(Value: TOnline): INodeEx;
begin
  FOnline := Value;
  Result := Self;
end;

function TNodeEx.Censored: Boolean;
begin
  Result := FCensored;
end;

function TNodeEx.SetCensored(Value: Boolean): INodeEx;
begin
  FCensored := Value;
  Result := Self;
end;

{ TfrmMain }

constructor TfrmMain.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  Self.Refresh;
end;

class function TfrmMain.Chain: TChain;
begin
  Result := web3.Ethereum;
end;

function TfrmMain.GetNodeEx(Index: Integer): INodeEx;
begin
  Result := nil;
  if (Index > -1) and (Index < Self.Nodes.Length) then
    Supports(Self.Nodes[Index].Tag, INodeEx, Result);
end;

procedure TfrmMain.Refresh(callback: TProc);
begin
  web3.eth.nodelist.get(Self.Chain, procedure(nodes: TNodes; err: IError)
  begin
    if Assigned(err) then
    begin
      TThread.Synchronize(nil, procedure
      begin
        MessageDlg(err.Message, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      end);
      EXIT;
    end;
    Self.Nodes := nodes;
    if Assigned(callback) then callback;
  end);
end;

procedure TfrmMain.Repaint;
begin
  Grid.RowCount := 0;
  Grid.RowCount := Self.Nodes.Length;
  Self.Invalidate;
end;

procedure TfrmMain.SetNodes(Value: TNodes);
begin
  if Value <> FNodes then
  begin
    FNodes := Value;
    for var n in FNodes do n.SetTag(TNodeEx.Create(n.Free));
    Self.Repaint;
  end;
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
const
  REFRESH = 'Refresh';
begin
  btnStart.Enabled := False;

  if btnStart.Text = REFRESH  then
  begin
    Self.Refresh(procedure
    begin
      TThread.Synchronize(nil, procedure
      begin
        btnStart.Text := 'Start';
        btnStart.Enabled := True;
      end);
    end);
    EXIT;
  end;

  Self.Nodes.Enumerate(
    // foreach
    procedure(index: Integer; next: TProc)
    begin
      if not Self.NodeEx[Index].Checked then
      begin
        next;
        EXIT;
      end;
      Self.Nodes[index].Online(procedure(online: TOnline; err: IError)
      begin
        Self.NodeEx[Index].SetOnline(online);
        if online <> TOnline.Online then
        begin
          next;
          EXIT;
        end;
        const client = (function(n: INode): IWeb3
        begin
          var client := TWeb3.Create(n.Chain, n.Rpc);
          // do not prompt "do you approve of this signature request?"
          client.OnSignatureRequest := procedure(
            from, &to   : TAddress;
            gasPrice    : TWei;
            estimatedGas: BigInteger;
            callback    : TSignatureRequestResult)
          begin
            callback(True, nil);
          end;
          Result := client;
        end)(Self.Nodes[index]);
        // send zero ETH from newly generated EOA to Tornado Cash
        sendTransaction(client, TPrivateKey.Generate, '0x8589427373D6D84E98730D7795D8f6f8731FDA16', 0, procedure(hash: TTxHash; err: IError)
        begin
          Self.NodeEx[Index].SetCensored(Assigned(err) and (err.Message.IndexOf('insufficient funds') = -1));
          TThread.Synchronize(nil, procedure
          begin
            Self.Repaint;
          end);
          next;
        end);
      end);
    end,
    // done
    procedure
    begin
      TThread.Synchronize(nil, procedure
      begin
        btnStart.Text := REFRESH;
        btnStart.Enabled := True;
      end);
    end
  );
end;

procedure TfrmMain.GridGetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
begin
  const n = Self.NodeEx[ARow];
  case ACol of
    0: if Assigned(n) then Value := n.Checked;
    1: Value := Self.Nodes[ARow].Name;
    2: if Assigned(n) then
         if n.Censored then
           Value := 'BLOCKED'
         else
           case n.Online of
             TOnline.Online : Value := 'online';
             TOnline.Offline: Value := 'offline';
           end;
  end;
end;

procedure TfrmMain.GridSetValue(Sender: TObject; const ACol, ARow: Integer;
  const Value: TValue);
begin
  if ACol = 0 then
  begin
    const n = Self.NodeEx[ARow];
    if Assigned(n) then
      n.SetChecked(Value.AsBoolean);
  end;
end;

procedure TfrmMain.GridDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
  const Column: TColumn; const Bounds: TRectF; const Row: Integer;
  const Value: TValue; const State: TGridDrawStates);
begin
  const S = (function: string
  begin
    Result := '';
    if not Value.IsEmpty then
      if Column = colStatus then
        Result := Column.ValueToString(Value);
  end)();
  if S <> '' then
  begin
    const n = Self.NodeEx[Row];
    if Assigned(n) then
      if n.Censored or (n.Online = TOnline.Online) then
      begin
        if n.Censored then
          Canvas.Fill.Color := TAlphaColors.Red
        else if n.Online = TOnline.Online then
          Canvas.Fill.Color := TAlphaColors.Green;
        Canvas.FillText(Bounds, S, False, 1, [], Column.HorzAlign, TTextAlign.Center);
      end;
  end;
end;

end.
