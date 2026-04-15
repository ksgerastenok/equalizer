unit
  WMPFRM;

interface

uses
  WMPDCL,
  Forms,
  Classes,
  Dialogs,
  Controls,
  Graphics,
  ComCtrls,
  StdCtrls,
  SysUtils;

type
  PFilter = ^TFilter;
  TFilter = record
    var Amp: Double;
    var Freq: Double;
    var Width: Double;
  end;

type
  TWMPFRM = class(TForm)
  published
    var AMPGroupBox: TGroupBox;
    var AMPLimitLabel: TLabel;
    var AMPLimitTrackBar: TTrackBar;
    var AMPValueLabel: TLabel;
    var AMPValueTrackBar: TTrackBar;
    var HRMGroupBox: TGroupBox;
    var HRMAmpLabel: TLabel;
    var HRMAmpTrackBar: TTrackBar;
    var HRMFreqLabel: TLabel;
    var HRMFreqTrackBar: TTrackBar;
    var HRMWidthLabel: TLabel;
    var HRMWidthTrackBar: TTrackBar;
    var DRMGroupBox: TGroupBox;
    var DRMAmpLabel: TLabel;
    var DRMAmpTrackBar: TTrackBar;
    var DRMFreqLabel: TLabel;
    var DRMFreqTrackBar: TTrackBar;
    var DRMWidthLabel: TLabel;
    var DRMWidthTrackBar: TTrackBar;
    var TRBGroupBox: TGroupBox;
    var TRBAmpLabel: TLabel;
    var TRBAmpTrackBar: TTrackBar;
    var TRBFreqLabel: TLabel;
    var TRBFreqTrackBar: TTrackBar;
    var TRBWidthLabel: TLabel;
    var TRBWidthTrackBar: TTrackBar;
    procedure FormShow(const Sender: TObject);
    procedure FormHide(const Sender: TObject);
    procedure FormCreate(const Sender: TObject);
    procedure FormDestroy(const Sender: TObject);
    procedure TrackBarLoad(const Sender: TObject);
    procedure TrackBarSave(const Sender: TObject);
  private
    var finfo: TInfo;
    var fconfig: array[0..2] of TFilter;
    function getInfo(): PInfo;
    function getConfig(const Index: LongWord): PFilter;
  public
    constructor Create(); reintroduce;
    destructor Destroy(); override;
    procedure Refresh();
    property Info: PInfo read getInfo;
    property Config[const Index: LongWord]: PFilter read getConfig;
  end;

implementation

{$R *.lfm}

uses
  Interfaces;

constructor TWMPFRM.Create();
begin
  Application.Initialize();
  inherited Create(Application);
end;

destructor TWMPFRM.Destroy();
begin
  inherited Destroy();
  Application.Terminate();
end;

procedure TWMPFRM.FormCreate(const Sender: TObject);
var
  f: file;
begin
  if (Sender is TForm) then begin
    with (Sender as TForm) do begin
      try
        System.Assign(f, 'enhancer.cfg');
        System.ReSet(f, 1);
        System.BlockRead(f, self.finfo, SizeOf(TInfo) * 1);
        System.BlockRead(f, self.fconfig, SizeOf(TFilter) * 3);
        System.Close(f)
      except
      end;
      self.finfo.Enabled := True;
    end;
  end;
end;

procedure TWMPFRM.FormDestroy(const Sender: TObject);
var
  f: file;
begin
  if (Sender is TForm) then begin
    with (Sender as TForm) do begin
      self.finfo.Enabled := True;
      try
        System.Assign(f, 'enhancer.cfg');
        System.ReWrite(f, 1);
        System.BlockWrite(f, self.finfo, SizeOf(TInfo) * 1);
        System.BlockWrite(f, self.fconfig, SizeOf(TFilter) * 3);
        System.Close(f);
      except
      end;
    end;
  end;
end;

procedure TWMPFRM.FormShow(const Sender: TObject);
begin
  if (Sender is TForm) then begin
    with (Sender as TForm) do begin
      self.TrackBarLoad(self.AMPLimitTrackBar);
      self.TrackBarLoad(self.AMPValueTrackBar);
      self.TrackBarLoad(self.HRMAmpTrackBar);
      self.TrackBarLoad(self.HRMFreqTrackBar);
      self.TrackBarLoad(self.HRMWidthTrackBar);
      self.TrackBarLoad(self.DRMAmpTrackBar);
      self.TrackBarLoad(self.DRMFreqTrackBar);
      self.TrackBarLoad(self.DRMWidthTrackBar);
      self.TrackBarLoad(self.TRBAmpTrackBar);
      self.TrackBarLoad(self.TRBFreqTrackBar);
      self.TrackBarLoad(self.TRBWidthTrackBar);
    end;
  end;
end;

procedure TWMPFRM.FormHide(const Sender: TObject);
begin
  if (Sender is TForm) then begin
    with (Sender as TForm) do begin
      self.TrackBarSave(self.AMPLimitTrackBar);
      self.TrackBarSave(self.AMPValueTrackBar);
      self.TrackBarSave(self.HRMAmpTrackBar);
      self.TrackBarSave(self.HRMFreqTrackBar);
      self.TrackBarSave(self.HRMWidthTrackBar);
      self.TrackBarSave(self.DRMAmpTrackBar);
      self.TrackBarSave(self.DRMFreqTrackBar);
      self.TrackBarSave(self.DRMWidthTrackBar);
      self.TrackBarSave(self.TRBAmpTrackBar);
      self.TrackBarSave(self.TRBFreqTrackBar);
      self.TrackBarSave(self.TRBWidthTrackBar);
    end;
  end;
end;

procedure TWMPFRM.TrackBarLoad(const Sender: TObject);
begin
  if (Sender is TTrackBar) then begin
    with (Sender as TTrackBar) do begin
      case (Tag) of
        11: begin
          Position := self.finfo.Preamp;
          Hint := Format('Limit: %f dB', [self.finfo.Preamp / 10]);
        end;
        12: begin
          Position := self.finfo.Size;
          Hint := Format('Value: %f dB', [self.finfo.Size / 10]);
        end;
        21: begin
          Position := Round(self.fconfig[0].Amp * 10.0);
          Hint := Format('Amp: %f dB', [self.fconfig[0].Amp]);
        end;
        22: begin
          Position := Round(self.fconfig[0].Freq / 10.0);
          Hint := Format('Freq: %f Hz', [self.fconfig[0].Freq]);
        end;
        23: begin
          Position := Round(self.fconfig[0].Width * 10.0);
          Hint := Format('Width: %f Slope', [self.fconfig[0].Width]);
        end;
        31: begin
          Position := Round(self.fconfig[1].Amp * 10.0);
          Hint := Format('Amp: %f dB', [self.fconfig[1].Amp]);
        end;
        32: begin
          Position := Round(self.fconfig[1].Freq / 10.0);
          Hint := Format('Freq: %f Hz', [self.fconfig[1].Freq]);
        end;
        33: begin
          Position := Round(self.fconfig[1].Width * 10.0);
          Hint := Format('Width: %f Slope', [self.fconfig[1].Width]);
        end;
        41: begin
          Position := Round(self.fconfig[2].Amp * 10.0);
          Hint := Format('Amp: %f dB', [self.fconfig[2].Amp]);
        end;
        42: begin
          Position := Round(self.fconfig[2].Freq / 100.0);
          Hint := Format('Freq: %f Hz', [self.fconfig[2].Freq]);
        end;
        43: begin
          Position := Round(self.fconfig[2].Width * 10.0);
          Hint := Format('Width: %f Slope', [self.fconfig[2].Width]);
        end;
        else begin
          Hint := Format('Unknown: %f None', [0.0]);
        end;
      end;
    end;
  end;
end;

procedure TWMPFRM.TrackBarSave(const Sender: TObject);
begin
  if (Sender is TTrackBar) then begin
    with (Sender as TTrackBar) do begin
      case (Tag) of
        11: begin
          self.finfo.Preamp := Position;
          Hint := Format('Limit: %f dB', [self.finfo.Preamp / 10]);
        end;
        12: begin
          self.finfo.Size := Position;
          Hint := Format('Value: %f dB', [self.finfo.Size / 10]);
        end;
        21: begin
          self.fconfig[0].Amp := Position / 10.0;
          Hint := Format('Amp: %f dB', [self.fconfig[0].Amp]);
        end;
        22: begin
          self.fconfig[0].Freq := Position * 10.0;
          Hint := Format('Freq: %f Hz', [self.fconfig[0].Freq]);
        end;
        23: begin
          self.fconfig[0].Width := Position / 10.0;
          Hint := Format('Width: %f Slope', [self.fconfig[0].Width]);
        end;
        31: begin
          self.fconfig[1].Amp := Position / 10.0;
          Hint := Format('Amp: %f dB', [self.fconfig[1].Amp]);
        end;
        32: begin
          self.fconfig[1].Freq := Position * 10.0;
          Hint := Format('Freq: %f Hz', [self.fconfig[1].Freq]);
        end;
        33: begin
          self.fconfig[1].Width := Position / 10.0;
          Hint := Format('Width: %f Slope', [self.fconfig[1].Width]);
        end;
        41: begin
          self.fconfig[2].Amp := Position / 10.0;
          Hint := Format('Amp: %f dB', [self.fconfig[2].Amp]);
        end;
        42: begin
          self.fconfig[2].Freq := Position * 100.0;
          Hint := Format('Freq: %f Hz', [self.fconfig[2].Freq]);
        end;
        43: begin
          self.fconfig[2].Width := Position / 10.0;
          Hint := Format('Width: %f Slope', [self.fconfig[2].Width]);
        end;
        else begin
          Hint := Format('Unknown: %f None', [0.0]);
        end;
      end;
    end;
  end;
end;

procedure TWMPFRM.Refresh();
begin
  self.FormShow(self);
end;

function TWMPFRM.getInfo(): PInfo;
begin
  Result := Addr(self.finfo);
end;

function TWMPFRM.getConfig(const Index: LongWord): PFilter;
begin
  Result := Addr(self.fconfig[Index]);
end;

begin
end.

