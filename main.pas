program HelloWorld(output);

const
    PatternLen = 9;
    PatternStride = 3;

type
    PatternIndex = 1..PatternLen;
    Pattern = array[PatternIndex] of Byte;
    TilePtr = ^Tile;
    Tile = record
        MPattern: Pattern;
        MRotation: Byte;
    end;

var
    Clear:  Pattern = (0,0,0,0,0,0,0,0,0);
    Dot:    Pattern = (0,0,0,0,1,0,0,0,0);
    Tee:    Pattern = (0,0,0,1,1,1,0,1,0);
    Plus:   Pattern = (0,1,0,1,1,1,0,1,0);
    Stick:  Pattern = (0,1,0,0,1,0,0,1,0);
    Corner: Pattern = (0,1,0,0,1,1,0,0,0);

    MyTile: Tile;

function ByteToParticle(Value: Byte): Char;
begin
    Case Value of
    0: ByteToParticle := Char(46);
    1: ByteToParticle := Char(35);
    end;
end;

procedure RotateTile(MyTile: Tile);
begin
end;

procedure PrintTile(MyTile: Tile);
var
    I: Longint;
    MyPattern: Pattern;
begin
    MyPattern := MyTile.MPattern;
    for I:=Low(MyPattern) to High(MyPattern) do
    begin
        Write(ByteToParticle(MyPattern[I]));
        if I mod PatternStride = 0 then
        begin
            Write(#10);
        end;
    end;
end;

begin
    with MyTile do
    begin
        MPattern := Corner;
        MRotation := 0;
    end;

    PrintTile(MyTile);
end.
