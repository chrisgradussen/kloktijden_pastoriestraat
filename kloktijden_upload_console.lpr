program kloktijden_upload_console;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp,crt
  { you can add units after this };

type

  { TMyUploadkloktijden }

  TMyUploadkloktijden = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;

  end;

{ TMyUploadkloktijden }

procedure TMyUploadkloktijden.DoRun;
var
  ErrorMsg: String;
  ch : string;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;
   { add your program here }
  until ;

  // stop program loop
  Terminate;
end;

constructor TMyUploadkloktijden.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TMyUploadkloktijden.Destroy;
begin
  inherited Destroy;
end;

procedure TMyUploadkloktijden.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Application: TMyUploadkloktijden;
begin
  Application:=TMyUploadkloktijden.Create(nil);
  Application.Title:='Uploadkloktijden Console';
  Application.Run;
  Application.Free;
end.

