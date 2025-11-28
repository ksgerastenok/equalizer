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
    var BSSGroupBox: TGroupBox;
    var BSSAmpLabel: TLabel;
    var BSSAmpTrackBar: TTrackBar;
    var BSSFreqLabel: TLabel;
    var BSSFreqTrackBar: TTrackBar;
    var BSSWidthLabel: TLabel;
    var BSSWidthTrackBar: TTrackBar;
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
    var fbass: TFilter;
    var ftrbl: TFilter;
    function getInfo(): TInfo;
    function getBass(): TFilter;
    function getTreble(): TFilter;
  public
    constructor Create(); reintroduce;
    destructor Destroy(); override;
    procedure Refresh(const Value: LongWord);
    property Info: TInfo read getInfo;
    property Bass: TFilter read getBass;
    property Treble: TFilter read getTreble;
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
        System.BlockRead(f, self.fbass, SizeOf(TFilter) * 1);
        System.BlockRead(f, self.ftrbl, SizeOf(TFilter) * 1);
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
        System.BlockWrite(f, self.fbass, SizeOf(TFilter) * 1);
        System.BlockWrite(f, self.ftrbl, SizeOf(TFilter) * 1);
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
      self.TrackBarLoad(self.BSSAmpTrackBar);
      self.TrackBarLoad(self.BSSFreqTrackBar);
      self.TrackBarLoad(self.BSSWidthTrackBar);
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
      self.TrackBarSave(self.BSSAmpTrackBar);
      self.TrackBarSave(self.BSSFreqTrackBar);
      self.TrackBarSave(self.BSSWidthTrackBar);
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
          Position := Round(self.fbass.Amp * 10.0);
          Hint := Format('Amp: %f dB', [self.fbass.Amp]);
        end;
        22: begin
          Position := Round(self.fbass.Freq / 10.0);
          Hint := Format('Freq: %f Hz', [self.fbass.Freq]);
        end;
        23: begin
          Position := Round(self.fbass.Width * 10.0);
          Hint := Format('Width: %f Octave', [self.fbass.Width]);
        end;
        31: begin
          Position := Round(self.ftrbl.Amp * 10.0);
          Hint := Format('Amp: %f dB', [self.ftrbl.Amp]);
        end;
        32: begin
          Position := Round(self.ftrbl.Freq / 100.0);
          Hint := Format('Freq: %f Hz', [self.ftrbl.Freq]);
        end;
        33: begin
          Position := Round(self.ftrbl.Width * 10.0);
          Hint := Format('Width: %f Octave', [self.ftrbl.Width]);
        end;
        else begin
          Position := 0;
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
          self.fbass.Amp := Position / 10.0;
          Hint := Format('Amp: %f dB', [self.fbass.Amp]);
        end;
        22: begin
          self.fbass.Freq := Position * 10.0;
          Hint := Format('Freq: %f Hz', [self.fbass.Freq]);
        end;
        23: begin
          self.fbass.Width := Position / 10.0;
          Hint := Format('Width: %f Octave', [self.fbass.Width]);
        end;
        31: begin
          self.ftrbl.Amp := Position / 10.0;
          Hint := Format('Amp: %f dB', [self.ftrbl.Amp]);
        end;
        32: begin
          self.ftrbl.Freq := Position * 100.0;
          Hint := Format('Freq: %f Hz', [self.ftrbl.Freq]);
        end;
        33: begin
          self.ftrbl.Width := Position / 10.0;
          Hint := Format('Width: %f Octave', [self.ftrbl.Width]);
        end;
        else begin
          self.finfo.Preamp := 0;
          self.finfo.Size := 0;
          self.fbass.Amp := 0.0;
          self.fbass.Freq := 0.0;
          self.fbass.Width := 0.0;
          self.ftrbl.Amp := 0.0;
          self.ftrbl.Freq := 0.0;
          self.ftrbl.Width := 0.0;
          Hint := Format('Unknown: %f None', [0.0]);
        end;
      end;
    end;
  end;
end;

procedure TWMPFRM.Refresh(const Value: LongWord);
begin
  self.finfo.Size := Value;
  self.FormShow(self);
end;

function TWMPFRM.getInfo(): TInfo;
begin
  Result := self.finfo;
end;

function TWMPFRM.getBass(): TFilter;
begin
  Result := self.fbass;
end;

function TWMPFRM.getTreble(): TFilter;
begin
  Result := self.ftrbl;
end;

begin
end.

