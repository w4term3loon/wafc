Program Testies;
Uses Wafc;

Procedure FAIL(Message:String);
Begin
  Write('[FAIL] ');
  WriteLn(Message);
End;

Procedure OK(Message:String);
Begin
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
End;

Begin
  TestRandomPattern();
  TestRandomRotation();
  TestRotate();
End.
