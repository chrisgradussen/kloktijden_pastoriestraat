program kloktijden_upload_console;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp,crt
  { you can add units after this },openssl, opensslsockets,StrUtils,inifiles,fphttpclient,jsonparser,fpjson,sharedcode;

type

  { TMyUploadkloktijden }

  TMyUploadkloktijden = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    inifile : tinifile;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure verstuurbestand(filename : string);
    function readresult(s  : string) : boolean;
    function FPHTTPClientDownload(URL: string; SaveToFile: boolean = false; Filename: string = ''): string;

  end;

{ TMyUploadkloktijden }

function TMyUploadkloktijden.readresult(s  : string) : boolean;
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
        //eventlog1.Warning(jobject.get('error'));
        writeln(jobject.get('error'));
        if pos('No valid contract for personnel number or badge id',jobject.get('error')) = 1 then
          result := true;
      end
      else
      begin
        result := true;
      end
    except
      on E: Exception do
        writeln(E.Message);
        //eventlog1.error(E.Message);
    end;
  finally
    jobject.free;
  end;
end;


function TMyUploadkloktijden.FPHTTPClientDownload(URL: string; SaveToFile: boolean = false; Filename: string = ''): string;
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
        writeln(E.Message);
        //eventlog1.error(E.Message);
      end;
    end;
  finally
    Free;
  end;
end;

procedure TMyUploadkloktijden.verstuurbestand(filename : string);
var
txt : textfile;
s,e,url : string;
L:TStringlist;
r : integer;
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
  //    memo1.Append('Pastoriestraat ' + inttostr(pos(':TRANSACTIONS: SN=0741133800020    IP=172.16.2.4	TIME',s)));
   //   memo1.Append('eilandplein ' + inttostr(pos(':TRANSACTIONS: SN=0741133800083	IP=172.16.1.4	TIME',s)));
   {eilandplein}    //  if pos(':TRANSACTIONS: SN=0741133800083	IP=172.16.1.4	TIME',s) <> 0 then
{pastoriestraat}     r :=pos(':TRANSACTIONS: SN=0741133800020',s);
         if r = 0 then

        raise Exception.Create('geen transactbestand ' + filename);
      while not eof(txt) do
      begin
        readln(txt, s);
        //eventlog1.Debug(s)
        writeln(s);
        if length(s) <8 then
        begin
          writeln('Lege of bijna lege regel');
          //eventlog1.Warning('Lege of bijna lege regel' );
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
           writeln('url : '+ url);
          //eventlog1.debug('url : ' + url);
          //if  false = true then
          if not readresult( FPHTTPClientDownload(url, false) ) then
            raise Exception.Create('PMT server gave error');
          except
            on E: Exception do   begin
              //eventlog1.error(E.Message);
              writeln(E.Message);
              raise Exception.Create('RERAISE PMT server gave error');
            end;
          end;
        finally
          l.free;
        end;
      end;
      if renamefile(FileName,GoodDir+'/'+extractfilename(filename)) = false then
        raise Exception.Create('Kan file niet verplaatsen naar good ' + filename)
      else
         writeln('Bestand verplaatst naar good');
         //eventlog1.Debug('Bestand verplaatst naar good');
    except
      on E: Exception do
      begin
        writeln(E.Message);
        //eventlog1.error(E.Message);
        if renamefile(FileName,WrongDir+'/'+extractfilename(filename)) = false then
         writeln('Kan file niet verplaatsen naar wrong ' + filename)
        //eventlog1.Error('Kan file niet verplaatsen naar wrong ' + filename)
         else
           writeln('Bestand verplaatst naar wrong' + filename);
         //eventlog1.Debug('Bestand verplaatst naar wrong'' + filename);

      end;
      on E: EInOutError do
      begin
       writeln(E.Message);
       //eventlog1.error(E.Message);
       if renamefile(FileName,WrongDir+'/'+extractfilename(filename)) = false then
          writeln('Kan file niet verplaatsen naar wrong ' + filename)
        //eventlog1.Error('Kan file niet verplaatsen naar wrong ' + filename)
        else
         writeln('Bestand verplaatst naar wrong');
         //eventlog1.Debug('Bestand verplaatst naar wrong');
      end;
    end;
  finally
    try
        closefile(txt);
    except
      on E: EInOutError do
      writeln(E.Message);
        //eventlog1.error(E.Message);
    end;
  end;
end;

procedure TMyUploadkloktijden.DoRun;
var
  ErrorMsg: String;
  ch : string;
  Info : TSearchRec;
begin
  // quick check parameters
    writeln(datetimetostr(date));
    sleep(1000);
 // ErrorMsg:=CheckOptions('h', 'help');
  if not leesparameters(inifile) then begin
 // if ErrorMsg<>'' then begin
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
   repeat
      try
         If FindFirst (writedir+ '/*.txt',faAnyFile,Info)=0 then
         begin
            writeln('Bestandsnaam : ' + writedir + '/' +info.Name);
            verstuurbestand(writedir + '/' +info.Name);
         end
      finally
         FindClose(Info);
      end;
      writeln(datetimetostr(date));
      sleep(1000);
   until   1 = 2;

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

