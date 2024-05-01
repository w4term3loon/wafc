Program ReadConfig(Output);

Const AsciiDelta=48;
Background=#46;
Pipe=#35;

Type TPattern = Array Of Byte;
HPattern=^TPattern;
TPatterns=Array Of HPattern;
HPatterns=^TPatterns;

TRotation=(No, Right, Twice, Left);
TOption=Record
  MPattern:HPattern;
  MRotations:Set Of TRotation;
End;

TOptions=Array Of TOption;
HOptions=^TOptions;
TState=(Stable, Instable);
TTile=Record
  Case MState:TState Of
    Stable: (MPattern:HPattern; MRotation:TRotation);
    Instable: (MOptions:HOptions);
End;

HGrid=^TGrid;
TGrid=Record
  MStride: Byte;
  MRow:Byte;
  MTiles:Array Of TTile;
  MOrder:Array Of Byte;
End;

Var SPatterns: Byte;
Patterns:HPatterns;
Grid:HGrid;

Procedure ReadConfig(Path:String; Patterns:HPatterns);
Var Config:Text;
Next:Char;
Iter, NewLength:Longint;
Begin
  Iter:=0;
  Assign(Config, Path);
  Reset(Config);
  While Not EOF(Config) Do
  Begin
    NewLength:=Length(Patterns^)+1;
    SetLength(Patterns^, NewLength);
    New(Patterns^[Iter]);
    While Not EOLn(Config) Do
    Begin
      SetLength(Patterns^[Iter]^, Length(Patterns^[Iter]^)+1);
      Read(Config, Next);
      Patterns^[Iter]^[Length(Patterns^[Iter]^)-1]:=Byte(Next)-AsciiDelta;
    End;
    Iter:=Iter+1;
    Read(Config, Next);
  End;
  Close(Config);
End;

Procedure PrintParticle(Particle:Byte);
Var Symbol:Char;
Begin
  Case Particle Of
    0: Symbol:=Background;
    1: Symbol:=Pipe;
  End;
  Write(Output, Symbol);
End;

Function GetStride(Patterns:TPatterns):Byte;
Var Pattern:HPattern;
Last, Next:Longint;
Begin
  Last:=0;Next:=0;
  For Pattern In Patterns Do
  Begin
    If Last = 0 Then
    Begin
      Last:=Length(Pattern^);
    End
    Else
    Begin
      Next:=Length(Pattern^);
      Assert(Next=Last);
      Last:=Next;
    End;
  End;
  GetStride:=Trunc(Sqrt(Next));
  If GetStride <> Sqrt(Next) Then
  Begin
    GetStride:=0;
  End
End;

Procedure WritePatterns(Patterns:TPatterns);
Var Pattern:HPattern;
Iter:Byte;
Begin
  For Pattern In Patterns Do
  Begin
    For Iter:=Low(Pattern^) To High(Pattern^) Do
    Begin
      PrintParticle(Pattern^[Iter]);
      If Iter Mod SPatterns=2 Then
      Begin
        Write(Output, #10);
      End;
    End;
    Write(Output, #10);
  End;
End;

Procedure InitGrid(Grid:HGrid; Patterns:TPatterns;
  Stride:Byte; Row:Byte);
Var TIter:Longint;
OIter:Longint;
Begin
  Grid^.MStride:=Stride;
  Grid^.MRow:=Row;
  SetLength(Grid^.MTiles, Stride*Row);
  SetLength(Grid^.MOrder, Stride*Row);
  With Grid^ Do
  Begin
    For TIter:=Low(MTiles) To High(MTiles) Do
    Begin
      With MTiles[TIter] Do
      Begin
        MState:=Instable;
        New(MOptions);
        SetLength(MOptions^, Length(Patterns));
        For OIter:=Low(MOptions^) To High(MOptions^) Do
        Begin
          With MOptions^[OIter] Do
          Begin
            MPattern:=Patterns[0];
            MRotations:=[No, Right, Twice, Left];
          End;
        End;
      End;
    End;
  End;
End;

Procedure WriteGrid(Grid:TGrid);
Var Row, Col, PRow, PCol:Longint;
Begin
  With Grid Do
  Begin
    Col:=Low(MTiles);
    For Row:=Low(MTiles) To Round(High(MTiles)/MStride) Do
    Begin
      //For PRow:=Low(MTiles[Row*Col].MPattern^) To
    End;
  End;
End;

Begin
    New(Patterns);
    ReadConfig('patterns', Patterns);
    SPatterns:=GetStride(Patterns^);
    New(Grid);
    InitGrid(Grid, Patterns^, 5, 3);
    WriteGrid(Grid^);
End.
