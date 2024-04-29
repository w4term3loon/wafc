program wafc(output);

const
    Particle=#46;
    Background=#35;

    SPattern=3; (* don't change *)
    LPattern=SPattern*SPattern;

    SGrid=SPattern*5;
    LGrid=SGrid*6;

    LPatterns=6;

type
    RPattern=1..LPattern;
    TPattern=array[RPattern] of Byte;
    HPattern=^TPattern;

    TRotation=(No, Right, Twice, Left);
    TOption=record
        MPattern: HPattern;
        MRotation: set of TRotation;
    end;

    RPatterns=1..LPatterns;

    State=(Instable, Stable);
    TOptions=array of TOption;
    HOptions=^TOptions;
    TTile=record
        MPattern: HPattern;
        MRotation: TRotation;
        MState: State;
        MOptions: TOptions;
    end;

    TRandomOption=record
        MPattern: HPattern;
        MRotation: TRotation;
    end;

    RGrid=1..LGrid;
    TGrid=array[RGrid] of TTile;
    HGrid=^TGrid;

var
    Clear:  TPattern=(0,0,0,0,0,0,0,0,0);
    Dot:    TPattern=(0,0,0,0,1,0,0,0,0);
    Tee:    TPattern=(0,0,0,1,1,1,0,1,0);
    Plus:   TPattern=(0,1,0,1,1,1,0,1,0);
    Stick:  TPattern=(0,1,0,0,1,0,0,1,0);
    Corner: TPattern=(0,1,0,0,1,1,0,0,0);

    Patterns: array[RPatterns] of HPattern =
        (@Clear, @Dot, @Tee, @Plus, @Stick, @Corner);

    MyGrid: TGrid;
    IMyGrid: Longint;
    IMyOptions: Longint;
    ILastTile: Longint;

function ByteToParticle(Value: Byte): Char;
begin
    case Value of
      0: ByteToParticle:=Particle;
      1: ByteToParticle:=Background;
    end;
end;

function RandomOption(Options: HOptions): TRandomOption;
var
    Target, Count: Longint;
    IOption: TOption;
    IRotation: TRotation;
begin
    Count:=0;
    for IOption in Options^ do
    begin
        for IRotation in IOption.MRotation do
        begin
            Count:=Count+1;
        end;
    end;
    Target:=Random(Count);
    Count:=0;
    for IOption in Options^ do
    begin
        for IRotation in IOption.MRotation do
        begin
            if Count=Target then
            begin
                with RandomOption do
                begin
                    MPattern:=IOption.MPattern;
                    MRotation:=IRotation;
                end;
            end;
            Count:=Count+1;
        end;
    end;
end;

function RandomPattern(): HPattern;
begin
    RandomPattern:=Patterns[Random(High(Patterns) - 1) + 1];
end;

function RandomRotation(): TRotation;
begin
    RandomRotation:=TRotation(Random(Ord(High(TRotation)) + 1));
end;

function Rotate(PIndex: Byte; PRotation: TRotation): Byte;
begin
    case PRotation of
      No: Rotate:=PIndex;
      Right:
        case PIndex of
          1..3: Rotate:=SPattern * (SPattern - PIndex) + 1;
          4:    Rotate:=PIndex + SPattern + 1;
          5:    Rotate:=PIndex;
          6:    Rotate:=PIndex - SPattern - 1;
          7..9: Rotate:=(PIndex - 2 * SPattern) * SPattern;
        end;
      Twice:
        case PIndex of
          1..4: Rotate:=LPattern-(PIndex-1);
          5:    Rotate:=PIndex;
          6..9: Rotate:=LPattern-(PIndex-1);
        end;
      Left:
        case PIndex of
          1..3: Rotate:=PIndex * SPattern;
          4:    Rotate:=PIndex - SPattern + 1;
          5:    Rotate:=PIndex;
          6:    Rotate:=PIndex + SPattern - 1;
          7..9: Rotate:=(SPattern - PIndex + 2 * SPattern + 1) * SPattern;
        end;
    end;
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
                        .MPattern^[Rotate((RP-1)*SPattern+CP,
                            GridHandle^[(R-1)*SGrid+C].MRotation)]));
                end;
            end;
            Write(output, #13#10);
        end;
    end;
end;

(*TODO:generalize*)
procedure UpdateGrid(GridHandle: HGrid; Target: Longint);
var
    Left, Right, Up, Down, IParticle, IOption : Longint;
    DeleteCount: Integer;
    Rot: TRotation;
begin
    Left:=Target-1;
    Right:=Target+1;
    Up:=Target-SGrid;
    Down:=Target+SGrid;

    DeleteCount:=0;
    if Left in [Low(GridHandle^)..High(GridHandle^)] then
    begin
      with GridHandle^[Left] do
      begin
        if MState <> Stable then
        begin
          for IOption:=Low(MOptions) to High(MOptions) do
          begin
            with MOptions[IOption-DeleteCount] do
            begin
              for Rot in MRotation do
              begin
                for IParticle:=Low(MPattern^) to Round(High(MPattern^)/SPattern) do
                begin
                  if MPattern^[Rotate(IParticle*SPattern, Rot)] <>
                    GridHandle^[Target].MPattern^[Rotate((IParticle-1)*SPattern+1,
                        GridHandle^[Target].MRotation)] then
                  begin
                    MRotation:=MRotation-[Rot];
                    if MRotation=[] then
                    begin
                      Delete(MOptions, IOption-DeleteCount, 1);
                      DeleteCount:=DeleteCount+1;
                    end;
                    break;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    DeleteCount:=0;
    if Right in [Low(GridHandle^)..High(GridHandle^)] then
    begin
      with GridHandle^[Right] do
      begin
        if MState <> Stable then
        begin
          for IOption:=Low(MOptions) to High(MOptions) do
          begin
            with MOptions[IOption-DeleteCount] do
            begin
              for Rot in MRotation do
              begin
                for IParticle:=Low(MPattern^) to Round(High(MPattern^)/SPattern) do
                begin
                  if MPattern^[Rotate((IParticle-1)*SPattern+1, Rot)] <>
                    GridHandle^[Target].MPattern^[
                      Rotate(IParticle*SPattern, GridHandle^[Target].MRotation)] then
                  begin
                    MRotation:=MRotation-[Rot];
                    if MRotation=[] then
                    begin
                      Delete(MOptions, IOption-DeleteCount, 1);
                      DeleteCount:=DeleteCount+1;
                    end;
                    break;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    DeleteCount:=0;
    if Up in [Low(GridHandle^)..High(GridHandle^)] then
    begin
      with GridHandle^[Up] do
      begin
        if MState <> Stable then
        begin
          for IOption:=Low(MOptions) to High(MOptions) do
          begin
            with MOptions[IOption-DeleteCount] do
            begin
              for Rot in MRotation do
              begin
                for IParticle:=Low(MPattern^) to Round(High(MPattern^)/SPattern) do
                begin
                  if MPattern^[Rotate(2*SPattern+IParticle, Rot)] <>
                    GridHandle^[Target].MPattern^[
                      Rotate(IParticle, GridHandle^[Target].MRotation)] then
                  begin
                    MRotation:=MRotation-[Rot];
                    if MRotation=[] then
                    begin
                      Delete(MOptions, IOption-DeleteCount, 1);
                      DeleteCount:=DeleteCount+1;
                    end;
                    break;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    DeleteCount:=0;
    if Down in [Low(GridHandle^)..High(GridHandle^)] then
    begin
      with GridHandle^[Down] do
      begin
        if MState <> Stable then
        begin
          for IOption:=Low(MOptions) to High(MOptions) do
          begin
            with MOptions[IOption-DeleteCount] do
            begin
              for Rot in MRotation do
              begin
                for IParticle:=Low(MPattern^) to Round(High(MPattern^)/SPattern) do
                begin
                  if MPattern^[Rotate(IParticle, Rot)] <>
                    GridHandle^[Target].MPattern^[
                      Rotate(2*SPattern+IParticle, GridHandle^[Target].MRotation)] then
                  begin
                    MRotation:=MRotation-[Rot];
                    if MRotation=[] then
                    begin
                      Delete(MOptions, IOption-DeleteCount, 1);
                      DeleteCount:=DeleteCount+1;
                    end;
                    break;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
end;

procedure Collapse(GridHandle: HGrid);
var
    Min, Temp: Integer;
    IOption: TOption;
    IRotation: TRotation;
    Entropy: array[RGrid] of Integer;
    Collapsed: TRandomOption;
begin
    Min:=High(RPatterns)*Succ(Ord(High(TRotation)));
    for Temp in RGrid do Entropy[Temp]:=0;
    for Temp in RGrid do
    begin
        with GridHandle^[Temp] do
        begin
            if MState <> Stable then
            begin
                for IOption in MOptions do
                begin
                    for IRotation in IOption.MRotation do
                    begin
                        Entropy[Temp]:=Entropy[Temp]+1;
                    end;
                end;
                if Entropy[Temp] < Min then Min:=Entropy[Temp];
            end;
        end;
    end;

    (* choose the first occurance*)
    (*TODO: don't*)
    for Temp in RGrid do
    begin
        if Entropy[Temp]=Min then
        begin
            with GridHandle^[Temp] do
            begin
                Collapsed:=RandomOption(@MOptions);
                MPattern:=Collapsed.MPattern;
                MRotation:=Collapsed.MRotation;
                MState:=Stable;
                MOptions:=MOptions;
            end;
            break;
        end;
    end;
end;

procedure PrintDebug(GridHandle: HGrid; Target: Longint);
var
    I, IT: Longint;
    R: TRotation;
begin
    with GridHandle^[Target] do
    begin
        Write('Pattern options: ');
        WriteLn(Length(MOptions));
        for I:=Low(MOptions) to High(MOptions) do
        begin
            for IT:=Low(MOptions[I].MPattern^) to High(MOptions[I].MPattern^) do
            begin
                Write(ByteToParticle(MOptions[I].MPattern^[IT]));
                if IT mod SPattern = 0 then
                begin
                    Write(#10);
                end;
            end;
            for R in MOptions[I].MRotation do
            begin
                Write(R);
                Write(' ');
            end;
            Write(#10);
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
            if IMyGrid=SGrid+2 then
            begin
                MPattern:=RandomPattern();
                MRotation:=RandomRotation();
                MState:=Stable;
                SetLength(MOptions, 0);
            end
            else
            begin
                MPattern:=@Clear;
                MRotation:=No;
                MState:=Instable;
                SetLength(MOptions, Length(Patterns));
                for IMyOptions:=Low(MOptions) to High(MOptions) do
                begin
                    with MOptions[IMyOptions] do
                    begin
                        MPattern:=Patterns[IMyOptions+1];
                        MRotation:=[No, Right, Twice, Left];
                    end;
                end;
            end;
        end;
    end;
    ILastTile:=SGrid+2;
    UpdateGrid(@MyGrid, ILastTile);
    PrintDebug(@MyGrid, SGrid+1);
    Collapse(@MyGrid);
    PrintGrid(@MyGrid);
end.
