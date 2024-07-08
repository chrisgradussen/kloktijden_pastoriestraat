unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, openssl, fphttpclient, opensslsockets, fpjson, jsonparser, eventlog,
  strutils
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button_Laadbestand: TButton;
    InDirectory: TDirectoryEdit;
    GoodDirectory: TDirectoryEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Timer1: TTimer;
    ToggleBox1: TToggleBox;
    WrongDirectory: TDirectoryEdit;
    Edit1: TEdit;
    EventLog1: TEventLog;
    Memo1: TMemo;
    OpenDialog: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button_LaadbestandClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure InDirectoryChange(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Timer1StartTimer(Sender: TObject);
    procedure Timer1StopTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ToggleBox1Change(Sender: TObject);
    procedure ToggleBox1Click(Sender: TObject);
  private
    function FPHTTPClientDownload(URL: string; SaveToFile: boolean=false;      Filename: string=''): string;
    function readresult(s  : string) : boolean;
    procedure verstuurbestand(filename : string);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

function tform1.readresult(s  : string) : boolean;
var
  jObject : TJSONObject;
begin
  result := false;
  try
    try
      if length(s) = 0 then
        raise Exception.Create('No data in json object');
      jObject := getjson(s) as TJSONObject;
      if (strtoint(jobject.get('succes'))) <> 1 then
      begin
        eventlog1.Warning(jobject.get('error'));
        if pos('No valid contract for personnel number or badge id',jobject.get('error')) = 1 then
          result := true;
      end
      else
      begin
        result := true;
      end
    except
      on E: Exception do
        eventlog1.error(E.Message);
    end;
  finally
    jobject.free;
  end;
end;

procedure TForm1.verstuurbestand(filename : string);
var
txt : textfile;
s,e,url : string;
L:TStringlist;
personnel_number, date, time, status : string;
begin
  assignfile(txt,filename);
  try
    try
     // Open the file for reading
      reset(txt);
      if eof(txt) then
      begin
        raise Exception.Create('leeg bestand ');
      end;
      readln(txt,s);
      memo1.Append('Pastoriestraat ' + inttostr(pos(':TRANSACTIONS: SN=0741133800020    IP=172.16.2.4	TIME',s)));
      memo1.Append('eilandplein ' + inttostr(pos(':TRANSACTIONS: SN=0741133800083	IP=172.16.1.4	TIME',s)));
{pastoriestraat}     if pos(':TRANSACTIONS: SN=0741133800020    IP=172.16.2.4	TIME',s) <> 0 then
{eilandplein}    //  if pos(':TRANSACTIONS: SN=0741133800083	IP=172.16.1.4	TIME',s) <> 0 then
        raise Exception.Create('geen transactbestand ' + OpenDialog.filename);
      while not eof(txt) do
      begin
        readln(txt, s);
        eventlog1.Debug(s);
        if length(s) <8 then
        begin
          eventlog1.Warning('Lege of bijna lege regel' );
          break;
        end;
        try
          try
          L:=TStringlist.Create;
          L.Delimiter := #9;
          L.QuoteChar := '"';
          L.StrictDelimiter := false;  // set this to false and the second 'test me' will be separate items! Try it.
          L.DelimitedText := S;
          if not l.Count = 8 then
              raise Exception.Create('Geen 8 velden in badgedata');
          date := delchars(l.strings[1],'-');
          time := l.strings[2];
          personnel_number := l.strings[0];
          if comparestr(l.strings[3],'0') = 0 then status := 'start'
             else
              if comparestr(l.strings[3],'1') = 0 then status := 'stop'
              else
                raise Exception.Create('status is not 0 or 1 (start or stop)');
{pastoriestraat}url := 'https://jumbo3448.personeelstool.nl/external/setTimerStatus?username=tenso&password=k6Rp8z1Xk6&date=' + date +
                      '&time=' + time + '&status=' + status + '&personnel_number='+ personnel_number;
{eilandplein}
{url := 'https://jumbo6418.personeelstool.nl/external/setTimerStatus?username=tenso&password=k6Rp8z1Xk6&date=' + date +
            '&time=' + time + '&status=' + status + '&personnel_number='+ personnel_number;
}
          eventlog1.debug('url : ' + url);
          if not readresult( FPHTTPClientDownload(url, false) ) then
            raise Exception.Create('PMT server gave error');
          except
            on E: Exception do   begin
              eventlog1.error(E.Message);
              raise Exception.Create('RERAISE PMT server gave error');
            end;
          end;
        finally
          l.free;
        end;
      end;
      if renamefile(FileName,GoodDirectory.Directory+'/'+extractfilename(filename)) = false then
        raise Exception.Create('Kan file niet verplaatsen naar good ' + filename)
      else
         eventlog1.Debug('Bestand verplaatst naar good');
    except
      on E: Exception do
      begin
        eventlog1.error(E.Message);
        if renamefile(FileName,WrongDirectory.Directory+'/'+extractfilename(filename)) = false then
        eventlog1.Error('Kan file niet verplaatsen naar wrong ' + filename)
         else
         eventlog1.Debug('Bestand verplaatst naar false');

      end;
      on E: EInOutError do
      begin
       eventlog1.error(E.Message);
       if renamefile(FileName,WrongDirectory.Directory+'/'+extractfilename(filename)) = false then
        eventlog1.Error('Kan file niet verplaatsen naar wrong ' + filename)
        else
         eventlog1.Debug('Bestand verplaatst naar wrong');
      end;
    end;
  finally
    try
        closefile(txt);
    except
      on E: EInOutError do
        eventlog1.error(E.Message);
    end;
  end;
end;

function TForm1.FPHTTPClientDownload(URL: string; SaveToFile: boolean = false; Filename: string = ''): string;
begin
  // Result will be:
  // - empty ('') when it has failed
  // - filename when the file has been downloaded successfully
  // - content when the content SaveToFile is set to False
  Result := '';
  With TFPHttpClient.Create(Nil) do
  try
    try
      if SaveToFile then begin
        Get(URL, Filename);
        Result := Filename;
      end else begin
          //TFPHttpClient.
        Result := Get(URL);
      end;
    except
      on E: Exception do
      begin
        eventlog1.error(E.Message);
      end;
    end;
  finally
    Free;
  end;
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  memo1.Text := FPHTTPClientDownload(Edit1.Text, false);
end;

procedure TForm1.Button_LaadbestandClick(Sender: TObject);
begin
   if not OpenDialog.Execute then exit;
     eventlog1.Debug('Bestandsnaam : ' + OpenDialog.filename);
     verstuurbestand(OpenDialog.filename);
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  eventlog1.Debug('Program stopped');
  eventlog1.active := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  eventlog1.Debug('Program started');
  opendialog.InitialDir:= indirectory.Directory;

end;

procedure TForm1.InDirectoryChange(Sender: TObject);
begin

end;

procedure TForm1.Label3Click(Sender: TObject);
begin

end;

procedure TForm1.Timer1StartTimer(Sender: TObject);
begin
  eventlog1.Debug('Timer autoupload started');
end;

procedure TForm1.Timer1StopTimer(Sender: TObject);
begin
  eventlog1.Debug('Timer autupload stopped');
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  Info : TSearchRec;
begin
    try
    If FindFirst (Indirectory.Directory+ '/*.txt',faAnyFile,Info)=0 then
    begin
      eventlog1.Debug('Bestandsnaam : ' + Indirectory.directory + '/' +info.Name);
      verstuurbestand(Indirectory.directory + '/' +info.Name);
    end
  finally
    FindClose(Info);
  end;
end;

procedure TForm1.ToggleBox1Change(Sender: TObject);
begin
   if togglebox1.checked = true then
   begin
    togglebox1.caption := 'ACTIVE';
    togglebox1.Color := clgreen;
    timer1.enabled := true;
   end
  else
  begin
    togglebox1.caption := 'STOPPED';
    togglebox1.color := clred;
    timer1.enabled := false;
  end;
end;

procedure TForm1.ToggleBox1Click(Sender: TObject);
begin

end;






end.

