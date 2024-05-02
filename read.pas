(*
  TODO:= encaplusate pattern stride in TPattern
*)

Program ReadConfig(Output);

Const AsciiDelta=48;
Background=#46;
Pipe=#35;

Type HPattern=^TPattern;
TPattern=Array Of Byte;

HPatternA=^TPatternA;
TPatternA=Array Of HPattern;

TRotation=(No, Right, Twice, Left);
TOption=Record
  MPatternH:HPattern;
  MRotationS:Set Of TRotation;
End;

HOptionA=^TOptionA;
TOptionA=Array Of TOption;

TState=(Stable, Instable);
TTile=Record
  MPatternH:HPattern;
  Case MState:TState Of
    Stable: (MRotation:TRotation);
    Instable: (MOptionAH:HOptionA);
End;

HGrid=^TGrid;
TGrid=Record
  MStride: Byte;
  MRow:Byte;
  MTileA:Array Of TTile;
  MOrderA:Array Of Byte;
End;

Var SPatterns: Byte;
Patterns:HPatternA;
Grid:HGrid;

Procedure ReadConfig(Path:String; Patterns:HPatternA);
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

Procedure WriteParticle(Particle:Byte);
Var Symbol:Char;
Begin
  Case Particle Of
    0: Symbol:=Background;
    1: Symbol:=Pipe;
  End;
  Write(Output, Symbol);
End;

Function GetStride(Patterns:TPatternA):Byte;
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

Procedure WritePatterns(Patterns:TPatternA);
Var Pattern:HPattern;
Iter:Byte;
Begin
  For Pattern In Patterns Do
  Begin
    For Iter:=Low(Pattern^) To High(Pattern^) Do
    Begin
      WriteParticle(Pattern^[Iter]);
      If Iter Mod SPatterns=2 Then
      Begin
        Write(Output, #10);
      End;
    End;
    Write(Output, #10);
  End;
End;

Procedure InitGrid(Grid:HGrid; Patterns:TPatternA;
  Stride:Byte; Row:Byte);
Var TIter:Longint;
OIter:Longint;
Begin
  Grid^.MStride:=Stride;
  Grid^.MRow:=Row;
  SetLength(Grid^.MTileA, Stride*Row);
  SetLength(Grid^.MOrderA, Stride*Row);
  With Grid^ Do
  Begin
    For TIter:=Low(MTileA) To High(MTileA) Do
    Begin
      With MTileA[TIter] Do
      Begin
        MPatternH:=Patterns[0];
        MState:=Instable;
        New(MOptionAH);
        SetLength(MOptionAH^, Length(Patterns));
        For OIter:=Low(MOptionAH^) To High(MOptionAH^) Do
        Begin
          With MOptionAH^[OIter] Do
          Begin
            MPatternH:=Patterns[OIter];
            MRotationS:=[No, Right, Twice, Left];
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
    Col:=Low(MTileA);
    For Row:=Low(MTileA) To Trunc(High(MTileA)/MStride) Do
    Begin
      For PRow:=Low(MTileA[Row*Col].MPatternH^)
      To Trunc(High(MTileA[Row*Col].MPatternH^)/SPatterns) Do
      Begin
        For Col:=Low(MTileA) To MStride-1 Do
        Begin
          For PCol:=Low(MTileA[Row*Col].MPatternH^) To SPatterns-1 Do
          Begin
            WriteParticle(MTileA[(Row)*MStride+Col]
            .MPatternH^[(*Rotate(*)(PRow)*SPatterns+PCol]
            (*, MTileA[(R-1)*MStride+Col].MRotation)*));
          End;
        End;
        Write(Output, #13#10);
      End;
    End;
  End;
End;

Begin
    New(Patterns);
    ReadConfig('patterns', Patterns);
    SPatterns:=GetStride(Patterns^);
    //WritePatterns(Patterns^);

    New(Grid);
    InitGrid(Grid, Patterns^, 2, 1);
    WriteGrid(Grid^);
End.
