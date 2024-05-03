Program Main;
Uses Wafc;

Var Patterns:HPatternA;
Grid:HGrid;
Collapsed:Longint;

Begin
  Randomize;
  New(Patterns);
  ReadConfig('patterns', Patterns);

  New(Grid);
  Collapsed:=InitGrid(Grid, Patterns^, 5, 3);
  WriteGrid(Grid^);
End.
