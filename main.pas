program HelloWorld(output);

const
    TileLen = 9;
    TileStride = 3;
    TableLen = TileLen;
    TableStride = TileStride;

type
    TileIndex = 1..TileLen;
    Tile = array[TileIndex] of Byte;
    TableIndex = 1..TableLen;
    Table = array[TableIndex] of Tile;

var
    Clear:  Tile = (0,0,0,0,0,0,0,0,0);
    Dot:    Tile = (0,0,0,0,1,0,0,0,0);
    Tee:    Tile = (0,0,0,1,1,1,0,1,0);
    Plus:   Tile = (0,1,0,1,1,1,0,1,0);
    Stick:  Tile = (0,1,0,0,1,0,0,1,0);
    Corner: Tile = (0,1,0,0,1,1,0,0,0);

    MyTable: Table;

function ByteToParticle(Value: Byte): Char;
begin
    Case Value of
    0: ByteToParticle := Char(46);
    1: ByteToParticle := Char(35);
    end;
end;

procedure PrintTile(MyTile: Tile);
var
    I: Longint;
begin
    for I:=Low(TileIndex) to High(TileIndex) do
    begin
        Write(ByteToParticle(MyTile[I]));
        if I mod TileStride = 0 then
        begin
            Write(#10);
        end;
    end;
end;

begin
    PrintTile(Clear);
    WriteLn();
    PrintTile(Dot);
    WriteLn();
    PrintTile(Tee);
    WriteLn();
    PrintTile(Plus);
    WriteLn();
    PrintTile(Stick);
    WriteLn();
    PrintTile(Corner);
end.
