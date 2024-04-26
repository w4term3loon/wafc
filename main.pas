program HelloWorld(output);

const
    PatternLen    = 8;
    PatternStride = 3;
    Particle      = #46;
    Background    = #35;
    GridLen       = 8;
    OptionsLen    = 5;

type
    PatternIndex = 0..PatternLen;
    Pattern = array[PatternIndex] of Byte;

    PatternHandle = ^Pattern;

    Tile = record
        MPattern: PatternHandle;
        MRotation: Byte;
        PosX, PosY: Byte;
    end;

    TileHandle = ^Tile;

    GridIndex = 0..GridLen;
    Grid = record
        MList: array[GridIndex] of Tile;
        MCheckpoint: Byte;
    end;

    OptionsIndex = 0..OptionsLen;

var
    Clear:  Pattern = (0,0,0,0,0,0,0,0,0);
    Dot:    Pattern = (0,0,0,0,1,0,0,0,0);
    Tee:    Pattern = (0,0,0,1,1,1,0,1,0);
    Plus:   Pattern = (0,1,0,1,1,1,0,1,0);
    Stick:  Pattern = (0,1,0,0,1,0,0,1,0);
    Corner: Pattern = (0,1,0,0,1,1,0,0,0);

    Options: array[OptionsIndex] of PatternHandle =
        (@Clear, @Dot, @Tee, @Plus, @Stick, @Corner);

    MyTile: Tile;

function ByteToParticle(Value: Byte): Char;
begin
    Case Value of
      0: ByteToParticle := Particle;
      1: ByteToParticle := Background;
    end;
end;

function RandomPattern(): PatternHandle;
begin
    RandomPattern := Options[Random(High(Options))];
end;

procedure PossibleNeighbours(RetTile: TileHandle; MyTile: Tile);
begin
end;

procedure PrintTile(MyTile: Tile);
var
    I: Longint;
    MyPattern: PatternHandle;
begin
    MyPattern := MyTile.MPattern;
    for I:=Low(MyPattern^) to High(MyPattern^) do
    begin
        Write(output, ByteToParticle(MyPattern^[I]));
        if I mod PatternStride = 2 then
        begin
            Write(output, #13#10);
        end;
    end;
end;

begin
    Randomize;
    with MyTile do
    begin
        MPattern := RandomPattern();
        MRotation := 0;
    end;

    PrintTile(MyTile);
end.
