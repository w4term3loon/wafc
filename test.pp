Program Testies;
Uses Wafc;

Var Passed, Failed:Byte;

Procedure FAIL(Message:String);
Begin
  Failed:=Failed+1;
  Write('[FAIL] ');
  WriteLn(Message);
End;

Procedure OK(Message:String);
Begin
  Passed:=Passed+1;
  Write('[ OK ] ');
  WriteLn(Message);
End;

Procedure SCENARIO(Message:String);
Begin
  Write('SCENARIO: ');
  WriteLn(Message);
End;

Procedure EXPECT(Expression:Boolean; Message:String);
Begin
  If Expression Then
  Begin OK(Message) End
  Else Begin FAIL(Message); End;
End;

Procedure Summarize();
Begin
  WriteLn('Overview:');
  Write('Passed: ');
  Write(Passed);
  Write(' Failed: ');
  WriteLn(Failed);
End;

Procedure TestRandomPattern();
Var Patterns:TPatternA;
FakePattern, Pattern:HPattern;
Begin
  SCENARIO('RandomPattern() should return a valid pattern handle.');
  FakePattern:=NIL;
  SetLength(Patterns, 1);
  Patterns[0]:=FakePattern;
  Pattern:=RandomPattern(Patterns);
  EXPECT(Pattern=FakePattern, 'Returned value should be valid Pattern.');
End;

Procedure TestRandomRotation();
Var Rotation:TRotation;
Begin
  SCENARIO('RandomRotation() should return a valid rotation.');
  Rotation:=RandomRotation();
  EXPECT(Rotation In [Low(TRotation)..High(TRotation)],
  'Returned value should be valid Rotation.')
End;

Procedure TestRotate();
Var Pattern:TPattern;
Iter:Longint;
Begin
  SCENARIO('Rotate() should return the appropriate value.');
  SetLength(Pattern, 9);
  For Iter:=Low(Pattern) To High(Pattern) Do
  Begin Pattern[Iter]:=Iter; End;

  EXPECT(Rotate(Length(Pattern),0,No)=0,
  'No rotation should return 0 when input 0.');
  EXPECT(Rotate(Length(Pattern),3,No)=3,
  'No rotation should return 3 when input 3.');
  EXPECT(Rotate(Length(Pattern),6,No)=6,
  'No rotation should return 6 when input 6.');

  EXPECT(Rotate(Length(Pattern),0,Right)=6,
  'Right rotation should return 6 when input 0.');
  EXPECT(Rotate(Length(Pattern),3,Right)=7,
  'Right rotation should return 7 when input 3.');
  EXPECT(Rotate(Length(Pattern),6,Right)=8,
  'Right rotation should return 8 when input 6.');

  EXPECT(Rotate(Length(Pattern),0,Left)=2,
  'Left rotation should return 2 when input 0.');
  EXPECT(Rotate(Length(Pattern),3,Left)=1,
  'Left rotation should return 1 when input 3.');
  EXPECT(Rotate(Length(Pattern),6,Left)=0,
  'Left rotation should return 0 when input 6.');

  EXPECT(Rotate(Length(Pattern),0,Twice)=8,
  'Twice rotation should return 8 when input 0.');
  EXPECT(Rotate(Length(Pattern),3,Twice)=5,
  'Twice rotation should return 5 when input 3.');
  EXPECT(Rotate(Length(Pattern),6,Twice)=2,
  'Twice rotation should return 2 when input 6.');
End;

Procedure TestUpdateEntropy();
Var Patterns:HPatternA;
Grid:HGrid;
Collapsed:Longint;
Begin
  SCENARIO('Test entropy update after a collapse.');
  Randomize;
  New(Patterns);
  ReadConfig('testpatterns', Patterns);
  New(Grid);
  Collapsed:=InitGrid(Grid, Patterns^, 5, 3);
  UpdateEntropy(Grid, Collapsed);
  (* TODO *)
  WriteGrid(Grid^);
End;

Begin
  TestRandomPattern();
  TestRandomRotation();
  TestRotate();
  TestUpdateEntropy();
  Summarize();
End.
