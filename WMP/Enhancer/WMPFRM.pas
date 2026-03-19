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
    var fbass: TFilter;
    var fdrum: TFilter;
    var ftrbl: TFilter;
    function getInfo(): PInfo;
    function getBass(): PFilter;
    function getDrum(): PFilter;
    function getTreble(): PFilter;
  public
    constructor Create(); reintroduce;
    destructor Destroy(); override;
    procedure Refresh();
    property Info: PInfo read getInfo;
    property Bass: PFilter read getBass;
    property Drum: PFilter read getDrum;
    property Treble: PFilter read getTreble;
  end;

implementation

{$R *.lfm}

uses
  Interfaces;

constructor TWMPFRM.Create();
begin
  Application.Initialize();
  self.FormCreate(self);
  inherited Create(Application);
  self.FormShow(self);
end;

destructor TWMPFRM.Destroy();
begin
  self.FormHide(self);
  inherited Destroy();
  self.FormDestroy(self);
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
        System.BlockRead(f, self.fdrum, SizeOf(TFilter) * 1);
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
        System.BlockWrite(f, self.fdrum, SizeOf(TFilter) * 1);
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
          Position := Round(self.fbass.Amp * 10.0);
          Hint := Format('Amp: %f dB', [self.fbass.Amp]);
        end;
        22: begin
          Position := Round(self.fbass.Freq / 10.0);
          Hint := Format('Freq: %f Hz', [self.fbass.Freq]);
        end;
        23: begin
          Position := Round(self.fbass.Width * 10.0);
          Hint := Format('Width: %f Slope', [self.fbass.Width]);
        end;
        31: begin
          Position := Round(self.fdrum.Amp * 10.0);
          Hint := Format('Amp: %f dB', [self.fdrum.Amp]);
        end;
        32: begin
          Position := Round(self.fdrum.Freq / 10.0);
          Hint := Format('Freq: %f Hz', [self.fdrum.Freq]);
        end;
        33: begin
          Position := Round(self.fdrum.Width * 10.0);
          Hint := Format('Width: %f Slope', [self.fdrum.Width]);
        end;
        41: begin
          Position := Round(self.ftrbl.Amp * 10.0);
          Hint := Format('Amp: %f dB', [self.ftrbl.Amp]);
        end;
        42: begin
          Position := Round(self.ftrbl.Freq / 100.0);
          Hint := Format('Freq: %f Hz', [self.ftrbl.Freq]);
        end;
        43: begin
          Position := Round(self.ftrbl.Width * 10.0);
          Hint := Format('Width: %f Slope', [self.ftrbl.Width]);
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
          Hint := Format('Width: %f Slope', [self.fbass.Width]);
        end;
        31: begin
          self.fdrum.Amp := Position / 10.0;
          Hint := Format('Amp: %f dB', [self.fdrum.Amp]);
        end;
        32: begin
          self.fdrum.Freq := Position * 10.0;
          Hint := Format('Freq: %f Hz', [self.fdrum.Freq]);
        end;
        33: begin
          self.fdrum.Width := Position / 10.0;
          Hint := Format('Width: %f Slope', [self.fdrum.Width]);
        end;
        41: begin
          self.ftrbl.Amp := Position / 10.0;
          Hint := Format('Amp: %f dB', [self.ftrbl.Amp]);
        end;
        42: begin
          self.ftrbl.Freq := Position * 100.0;
          Hint := Format('Freq: %f Hz', [self.ftrbl.Freq]);
        end;
        43: begin
          self.ftrbl.Width := Position / 10.0;
          Hint := Format('Width: %f Slope', [self.ftrbl.Width]);
        end;
        else begin
          self.finfo.Preamp := 0;
          self.finfo.Size := 0;
          self.fbass.Amp := 0.0;
          self.fbass.Freq := 0.0;
          self.fbass.Width := 0.0;
          self.fdrum.Amp := 0.0;
          self.fdrum.Freq := 0.0;
          self.fdrum.Width := 0.0;
          self.ftrbl.Amp := 0.0;
          self.ftrbl.Freq := 0.0;
          self.ftrbl.Width := 0.0;
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

function TWMPFRM.getBass(): PFilter;
begin
  Result := Addr(self.fbass);
end;

function TWMPFRM.getDrum(): PFilter;
begin
  Result := Addr(self.fdrum);
end;

function TWMPFRM.getTreble(): PFilter;
begin
  Result := Addr(self.ftrbl);
end;

begin
end.

