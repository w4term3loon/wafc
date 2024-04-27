program HelloWorld(output);

const
    Particle    = #46;
    Background  = #35;

    SPattern    = 3;
    LPattern    = SPattern * SPattern;

    SGrid       = 9;
    LGrid       = SGrid * SGrid;

    LOptions    = 6;

type
    IPattern = 1..LPattern;
    TPattern = array[IPattern] of Byte;
    HPattern = ^TPattern;

    TTile = record
        MPattern: HPattern;
        MRotation: Byte;
    end;

    IGrid = 1..LGrid;
    TGrid = array[IGrid] of TTile;
    HGrid = ^TGrid;

    IOptions = 1..LOptions;

var
    Clear:  TPattern = (0,0,0,0,0,0,0,0,0);
    Dot:    TPattern = (0,0,0,0,1,0,0,0,0);
    Tee:    TPattern = (0,0,0,1,1,1,0,1,0);
    Plus:   TPattern = (0,1,0,1,1,1,0,1,0);
    Stick:  TPattern = (0,1,0,0,1,0,0,1,0);
    Corner: TPattern = (0,1,0,0,1,1,0,0,0);

    Options: array[IOptions] of HPattern =
        (@Clear, @Dot, @Tee, @Plus, @Stick, @Corner);

    MyGrid: TGrid;
    IMyGrid: Longint;

function ByteToParticle(Value: Byte): Char;
begin
    Case Value of
      0: ByteToParticle := Particle;
      1: ByteToParticle := Background;
    end;
end;

function RandomPattern(): HPattern;
begin
    RandomPattern := Options[Random(High(Options) - 1) + 1];
end;

procedure PrintGrid(GridHandle: HGrid);
var
    R,RP,C,CP: Longint;
begin
    C:=Low(GridHandle^);
    for R:=Low(GridHandle^) to Round(High(GridHandle^)/SGrid) do
    begin
        for RP:=Low(GridHandle^[R*C].MPattern^) to
            Round(High(GridHandle^[R*C].MPattern^)/SPattern) do
        begin
            for C:=Low(GridHandle^) to SGrid do
            begin
                for CP:=Low(GridHandle^[R*C].MPattern^) to SPattern do
                begin
                    Write(output,
                        ByteToParticle(
                        GridHandle^[R*C].MPattern^[RP*CP]));
                end;
            end;
            Write(output, #13#10);
        end;
    end;
end;


begin
    Randomize;

    for IMyGrid:=Low(MyGrid) to High(MyGrid) do
    begin
        with MyGrid[IMyGrid] do
        begin
            MPattern:=@Plus;
            MRotation:=0;
        end;
    end;

    PrintGrid(@MyGrid);
end.
