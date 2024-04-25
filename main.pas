program HelloWorld(output);
const
    TileLen = 9;
    TileStride = 3;
var
    I: Longint;
type
    TileIndex = 1..TileLen;
    Tile = array[TileIndex] of Byte;

procedure GeneratedTile();
begin
    for I:=Low(TileIndex) to High(TileIndex) do
    begin
        WriteLn('hello');
    end;
end;

begin
    GeneratedTile();
end.
