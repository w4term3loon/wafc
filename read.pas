Program ReadConfig;

Const AsciiDelta=48;
Background=#46;
Pipe=#35;

Type TPattern = Array Of Byte;
TPatterns = Array Of TPattern;
HPatterns = ^TPatterns;

Var SPatterns: Byte;
Patterns: HPatterns;

Procedure ReadConfig(Path: String; Patterns: HPatterns);
Var Config: Text;
Next: Char;
Iter, NewLength: Longint;
Begin
  Iter:=0;
  Assign(Config, Path);
  Reset(Config);
  While Not EOF(Config) Do
  Begin
    NewLength:=Length(Patterns^)+1;
    SetLength(Patterns^, NewLength);
    While Not EOLn(Config) Do
    Begin
      SetLength(Patterns^[Iter], Length(Patterns^[Iter])+1);
      Read(Config, Next);
      Patterns^[Iter][Length(Patterns^[Iter])-1]:=Byte(Next)-AsciiDelta;
    End;
    Iter:=Iter+1;
    Read(Config, Next);
  End;
  Close(Config);
End;

Procedure PrintParticle(Particle: Byte);
Var Symbol: Char;
Begin
  Case Particle Of
    0: Symbol:=Background;
    1: Symbol:=Pipe;
  End;
  Write(Symbol);
End;

Procedure PrintPatterns(Patterns: TPatterns);
Var Pattern: TPattern;
Iter: Byte;
Begin
  For Pattern In Patterns Do
  Begin
    For Iter:=Low(Pattern) To High(Pattern) Do
    Begin
      PrintParticle(Pattern[Iter]);
      If Iter Mod SPatterns = 2 Then
      Begin
        Write(#10);
      End;
    End;
    Write(#10);
  End;
End;

Begin
    SPatterns:=3;
    New(Patterns);
    ReadConfig('patterns', Patterns);
    PrintPatterns(Patterns^);
End.
