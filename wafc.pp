(*
  TODO:= encaplusate pattern stride in TPattern
  TODO:= backtracting
  TODO:= write patterns next to each other in list
  TODO:= eliminate collapse from init function
*)

Unit Wafc;

Interface

Const AsciiDelta=48;
Background=#46;
Pipe=#35;
SPatterns=3;

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

Procedure ReadConfig(Path:String; Patterns:HPatternA);
Procedure WriteParticle(Particle:Byte);
Function GetStride(Patterns:TPatternA):Byte;
Procedure WritePatterns(Patterns:TPatternA);
Function RandomPattern(Patterns:TPatternA):HPattern;
Function RandomRotation():TRotation;
Function InitGrid(Grid:HGrid; Patterns:TPatternA; Stride:Byte; Row:Byte):Longint;
Function Rotate(LPattern:Byte; PIndex:Byte; PRotation:TRotation):Byte;
Procedure WriteGrid(Grid:TGrid);
Procedure UpdateEntropy(Grid:HGrid; Target:Longint);

Implementation

Function RandomPattern(Patterns:TPatternA):HPattern;
Begin
    RandomPattern:=Patterns[Trunc(Random(High(Patterns)+1))];
End;

Function RandomRotation():TRotation;
Begin
    RandomRotation:=TRotation(Random(Ord(High(TRotation))+1));
End;

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

Function InitGrid(Grid:HGrid; Patterns:TPatternA;
  Stride:Byte; Row:Byte):Longint;
Var TIter:Longint;
OIter:Longint;
Begin
  Grid^.MStride:=Stride;
  Grid^.MRow:=Row;
  SetLength(Grid^.MTileA, Stride*Row);
  SetLength(Grid^.MOrderA, Stride*Row);
  InitGrid:=Round(Random(High(Grid^.MTileA)));
  With Grid^ Do
  Begin
    For TIter:=Low(MTileA) To High(MTileA) Do
    Begin
      If TIter=InitGrid Then
      Begin
        MTileA[TIter].MPatternH:=RandomPattern(Patterns);
        MTileA[TIter].MState:=Stable;
        MTileA[TIter].MRotation:=RandomRotation();
      End
      Else
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
End;

Function Rotate(LPattern:Byte; PIndex:Byte; PRotation:TRotation):Byte;
Begin
  Case PRotation Of
    No: Rotate:=PIndex;
    Right:
      Case PIndex Of
        0..2: Rotate:=SPatterns*(SPatterns-PIndex-1);
        3:    Rotate:=PIndex+SPatterns+1;
        4:    Rotate:=PIndex;
        5:    Rotate:=PIndex-SPatterns-1;
        6..8: Rotate:=LPattern-(PIndex-2*SPatterns)-1;
      End;
    Twice:
      Case PIndex Of
        0..3: Rotate:=LPattern-(PIndex)-1;
        4:    Rotate:=PIndex;
        5..8: Rotate:=LPattern-(PIndex)-1;
      End;
    Left:
      Case PIndex Of
        0..2: Rotate:=(PIndex+1)*SPatterns-1;
        3:    Rotate:=PIndex-SPatterns+1;
        4:    Rotate:=PIndex;
        5:    Rotate:=PIndex+SPatterns-1;
        6..8: Rotate:=(PIndex-2*SPatterns)*SPatterns;
      End;
  End;
End;

Procedure WriteGrid(Grid:TGrid);
Var Row, Col, PRow, PCol:Longint;
Rotation:TRotation;
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
            With MTileA[(Row)*MStride+Col] Do
            Begin
              Case MState Of
                Stable: Rotation:=MRotation;
                Instable: Rotation:=No;
              End;
              WriteParticle(MPatternH^[Rotate(Length(MPatternH^),
              (PRow)*SPatterns+PCol, Rotation)]);
            End;
          End;
        End;
        Write(Output, #13#10);
      End;
    End;
  End;
End;

Procedure UpdateEntropy(Grid:HGrid; Target:Longint);
Var OIter, PIter, Left:Longint;
DeleteCount:Integer;
Rot:TRotation;
Begin
  Left:=Target-1;
  DeleteCount:=0;
  If Left In [Low(Grid^.MTileA)..High(Grid^.MTileA)] Then
  Begin
    If Grid^.MTileA[Left].MState <> Stable Then
    Begin
      For OIter:=Low(Grid^.MTileA[Left].MOptionAH^)
      To High(Grid^.MTileA[Left].MOptionAH^) Do
      Begin
        With Grid^.MTileA[Left].MOptionAH^[OIter-DeleteCount] Do
        Begin
          For Rot In MRotationS Do
          Begin
            For PIter:=Low(MPatternH^) To SPatterns-1 Do
            Begin
              If MPatternH^[Rotate(Length(MPatternH^),(PIter+1)*SPatterns-1,Rot)]
              <> Grid^.MTileA[Target].MPatternH^[
              Rotate(Length(Grid^.MTileA[Target].MPatternH^),
              PIter*SPatterns,Grid^.MTileA[Target].MRotation)]
              Then
              Begin
                MRotationS:=MRotationS-[Rot];
                If MRotationS=[] Then
                Begin
                  Delete(Grid^.MTileA[Left].MOptionAH^, OIter-DeleteCount, 1);
                  DeleteCount:=DeleteCount+1;
                End;
                Break;
              End;
            End;
          End;
        End;
      End;
    End;
  End;
End;

End.
