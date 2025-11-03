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
  TWMPFRM = class(TForm)
  published
    var PreampLabel: TLabel;
    var Band01Label: TLabel;
    var Band04Label: TLabel;
    var Band02Label: TLabel;
    var Band03Label: TLabel;
    var Band06Label: TLabel;
    var Band05Label: TLabel;
    var Band13Label: TLabel;
    var Band10Label: TLabel;
    var Band11Label: TLabel;
    var Band12Label: TLabel;
    var Band07Label: TLabel;
    var Band08Label: TLabel;
    var Band09Label: TLabel;
    var Band14Label: TLabel;
    var Band15Label: TLabel;
    var Band16Label: TLabel;
    var Band17Label: TLabel;
    var Band18Label: TLabel;
    var Band19Label: TLabel;
    var Band20Label: TLabel;
    var Band21Label: TLabel;
    var PreampGroupBox: TGroupBox;
    var PreampTrackBar: TTrackBar;
    var MinLabel: TLabel;
    var ZeroLabel: TLabel;
    var MaxLabel: TLabel;
    var BandGroupBox: TGroupBox;
    var Band01TrackBar: TTrackBar;
    var Band02TrackBar: TTrackBar;
    var Band03TrackBar: TTrackBar;
    var Band04TrackBar: TTrackBar;
    var Band05TrackBar: TTrackBar;
    var Band06TrackBar: TTrackBar;
    var Band07TrackBar: TTrackBar;
    var Band08TrackBar: TTrackBar;
    var Band09TrackBar: TTrackBar;
    var Band10TrackBar: TTrackBar;
    var Band11TrackBar: TTrackBar;
    var Band12TrackBar: TTrackBar;
    var Band13TrackBar: TTrackBar;
    var Band14TrackBar: TTrackBar;
    var Band15TrackBar: TTrackBar;
    var Band16TrackBar: TTrackBar;
    var Band17TrackBar: TTrackBar;
    var Band18TrackBar: TTrackBar;
    var Band19TrackBar: TTrackBar;
    var Band21TrackBar: TTrackBar;
    var Band20TrackBar: TTrackBar;
    procedure FormCreate(const Sender: TObject);
    procedure FormDestroy(const Sender: TObject);
    procedure FormShow(const Sender: TObject);
    procedure FormHide(const Sender: TObject);
    procedure TrackBarLoad(const Sender: TObject);
    procedure TrackBarSave(const Sender: TObject);
  private
    var finfo: TInfo;
    function getInfo(): TInfo;
  public
    constructor Create(); reintroduce;
    destructor Destroy(); override;
    property Info: TInfo read getInfo;
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
        System.Assign(f, 'equalizer.cfg');
        System.ReSet(f, 1);
        System.BlockRead(f, self.finfo, SizeOf(TInfo) * 1);
        System.Close(f);
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
        System.Assign(f, 'equalizer.cfg');
        System.ReWrite(f, 1);
        System.BlockWrite(f, self.finfo, SizeOf(TInfo) * 1);
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
      self.TrackBarLoad(self.PreampTrackBar);
      self.TrackBarLoad(self.Band01TrackBar);
      self.TrackBarLoad(self.Band02TrackBar);
      self.TrackBarLoad(self.Band03TrackBar);
      self.TrackBarLoad(self.Band04TrackBar);
      self.TrackBarLoad(self.Band05TrackBar);
      self.TrackBarLoad(self.Band06TrackBar);
      self.TrackBarLoad(self.Band07TrackBar);
      self.TrackBarLoad(self.Band08TrackBar);
      self.TrackBarLoad(self.Band09TrackBar);
      self.TrackBarLoad(self.Band10TrackBar);
      self.TrackBarLoad(self.Band11TrackBar);
      self.TrackBarLoad(self.Band12TrackBar);
      self.TrackBarLoad(self.Band13TrackBar);
      self.TrackBarLoad(self.Band14TrackBar);
      self.TrackBarLoad(self.Band15TrackBar);
      self.TrackBarLoad(self.Band16TrackBar);
      self.TrackBarLoad(self.Band17TrackBar);
      self.TrackBarLoad(self.Band18TrackBar);
      self.TrackBarLoad(self.Band19TrackBar);
      self.TrackBarLoad(self.Band20TrackBar);
      self.TrackBarLoad(self.Band21TrackBar);
    end;
  end;
end;

procedure TWMPFRM.FormHide(const Sender: TObject);
begin
  if (Sender is TForm) then begin
    with (Sender as TForm) do begin
      self.TrackBarSave(self.PreampTrackBar);
      self.TrackBarSave(self.Band01TrackBar);
      self.TrackBarSave(self.Band02TrackBar);
      self.TrackBarSave(self.Band03TrackBar);
      self.TrackBarSave(self.Band04TrackBar);
      self.TrackBarSave(self.Band05TrackBar);
      self.TrackBarSave(self.Band06TrackBar);
      self.TrackBarSave(self.Band07TrackBar);
      self.TrackBarSave(self.Band08TrackBar);
      self.TrackBarSave(self.Band09TrackBar);
      self.TrackBarSave(self.Band10TrackBar);
      self.TrackBarSave(self.Band11TrackBar);
      self.TrackBarSave(self.Band12TrackBar);
      self.TrackBarSave(self.Band13TrackBar);
      self.TrackBarSave(self.Band14TrackBar);
      self.TrackBarSave(self.Band15TrackBar);
      self.TrackBarSave(self.Band16TrackBar);
      self.TrackBarSave(self.Band17TrackBar);
      self.TrackBarSave(self.Band18TrackBar);
      self.TrackBarSave(self.Band19TrackBar);
      self.TrackBarSave(self.Band20TrackBar);
      self.TrackBarSave(self.Band21TrackBar);
    end;
  end;
end;

procedure TWMPFRM.TrackBarLoad(const Sender: TObject);
begin
  if (Sender is TTrackBar) then begin
    with (Sender as TTrackBar) do begin
      case (Tag) of
        100: begin
          Position := self.finfo.Preamp;
          Hint := Format('Preamp: %f dB', [self.finfo.Preamp / 10]);
        end;
        else begin
          Position := self.finfo.Bands[Tag];
          Hint := Format('Band %d: %f dB', [Tag + 1, self.finfo.Bands[Tag] / 10]);
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
        100: begin
          self.finfo.Preamp := Position;
          Hint := Format('Preamp: %f dB', [self.finfo.Preamp / 10]);
        end;
        else begin
          self.finfo.Bands[Tag] := Position;
          Hint := Format('Band %d: %f dB', [Tag + 1, self.finfo.Bands[Tag] / 10]);
        end;
      end;
    end;
  end;
end;

function TWMPFRM.getInfo(): TInfo;
begin
  Result := self.finfo;
end;

begin
end.

