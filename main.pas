program HelloWorld(output);

const
    Particle    = #46;
    Background  = #35;

    SPattern    = 3;
    LPattern    = SPattern * SPattern;

    SGrid       = SPattern * 5;
    LGrid       = SGrid * 6;

    LOptions    = 6;

type
    IPattern = 1..LPattern;
    TPattern = array[IPattern] of Byte;
    HPattern = ^TPattern;

    Rotation = (No, Right, Upside, Left);
    TOption = record
        MPattern: HPattern;
        MRotation: set of Rotation;
    end;

    IOptions = 1..LOptions;

    State = (Instable, Stable);
    TTile = record
        MPattern: HPattern;
        MRotation: Byte;
        case MState: State of
          Instable: (MOptions: array[IOptions] of TOption);
          Stable: ();
    end;

    IGrid = 1..LGrid;
    TGrid = array[IGrid] of TTile;
    HGrid = ^TGrid;

var
    Clear:  TPattern = (0,0,0,0,0,0,0,0,0);
    Dot:    TPattern = (0,0,0,0,1,0,0,0,0);
    Tee:    TPattern = (0,0,0,1,1,1,0,1,0);
    Plus:   TPattern = (0,1,0,1,1,1,0,1,0);
    Stick:  TPattern = (0,1,0,0,1,0,0,1,0);
    Corner: TPattern = (0,1,0,0,1,1,0,0,0);

    Patterns: array[IOptions] of HPattern =
        (@Clear, @Dot, @Tee, @Plus, @Stick, @Corner);

    MyGrid: TGrid;
    IMyGrid: Longint;
    IMyOptions: Longint;

function ByteToParticle(Value: Byte): Char;
begin
    case Value of
      0: ByteToParticle := Particle;
      1: ByteToParticle := Background;
    end;
end;

function RandomPattern(): HPattern;
begin
    RandomPattern := Patterns[Random(High(Patterns) - 1) + 1];
end;

function RandomRotation(): Byte;
begin
    RandomRotation:=0;
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
                        GridHandle^[(R-1)*SGrid+C]
                        .MPattern^[(RP-1)*SPattern+CP]));
                end;
            end;
            Write(output, #13#10);
        end;
    end;
end;


begin
    Randomize;

    (* set the grid all clear *)
    for IMyGrid:=Low(MyGrid) to High(MyGrid) do
    begin
        with MyGrid[IMyGrid] do
        begin
            if IMyGrid = 1 then
            begin
                MPattern:=RandomPattern();
                MRotation:=RandomRotation();
                MState:=Stable;
            end
            else
                MPattern:=@Clear;
                MRotation := 0;
                MState:=Instable;
                for IMyOptions:=Low(MOptions) to High(MOptions) do
                begin
                    MOptions[IMyOptions].MPattern := Patterns[IMyOptions];
                    MOptions[IMyOptions].MRotation := [No, Right, Upside, Left];
                end;
        end;
    end;

    PrintGrid(@MyGrid);
end.
