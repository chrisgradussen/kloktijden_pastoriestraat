program kloktijden_sync_pastoriestraat;


{$mode objfpc}{$H+}

uses
  cthreads,fphttpapp, httpdefs, httproute, sysutils,inifiles, leesparameters;

var
  inifile : tinifile;
  stamp : integer;
  writedir, gooddir, wrongdir : string;
  port : word;

procedure route1(aReq: TRequest; aResp: TResponse);
begin
  aResp.content:='<html><body><h1>ERROR 404</h1></body></html>';
  aResp.Code:= 404;
  writeln(datetimetostr(now) +'Hier moeten we niet komen. ERROR');
end;

procedure write_areq(aReq: TRequest);
begin
  writeln('QueryString : ' +aReq.QueryString);
  writeln('Content :' +aReq.Content);
  writeln('Command : ' +aReq.Command);
  writeln('Commandline : ' +aReq.CommandLine);
  writeln('ContentRange : ' +aReq.ContentRange);
  writeln('HeaderLine : ' +aReq.HeaderLine);
  writeln('URI : ' + aReq.URI);
  writeln('Accept : ' +aReq.Accept);
end;

procedure Initialiseer_verbinding(aReq: TRequest; aResp: TResponse);
var
  s : string;
  serial : string;
begin
  aResp.Contents.add('GET OPTION FROM: 0741133800083');
//  aResp.Contents.add('ATTLOGStamp=715692273');
  //aResp.Contents.add('ATTLOGStamp=705092272');
 //aResp.Contents.add('ATTLOGStamp=715943434');
  aResp.Contents.add('ATTLOGStamp='+inttostr(stamp));
  aResp.Contents.add('OPERLOGStamp=637062088');
  aResp.Contents.add('ATTPHOTOStamp=0');
  aResp.Contents.add('ErrorDelay=30');
  aResp.Contents.add('Delay=30');
  aResp.Contents.add('TransTimes=00:00;14:05');
  aResp.Contents.add('TransInterval=10');
  aResp.Contents.add('TransFlag=TransData AttLog');
  aResp.Contents.add('TimeZone=1');
  aResp.Contents.add('Realtime=1');
  aResp.Contents.add('Encrypt=0');
  aResp.Contents.add('ServerVer=0.0.2 2010-07-22');
  aResp.Contents.add('TableNameStamp');
  aResp.Server := 'Own Server';
  aResp.Connection:= 'close';
  aResp.ContentType:='text/plain';

  writeln(datetimetostr(now) +'initialisatie');
  serial := leftstr(areq.QueryString,16);
  writeln('serial number is : '+serial);
end;

procedure get_timestamps(aReq: TRequest; aResp: TResponse);
var
  i,p : integer;
  txt : TextFile;
  s : string;
  z : string;
  serial : string; //the serial number of the clock
begin
  aResp.Server := 'Own Server';
  aResp.Connection:= 'close';
  aResp.ContentType:='text/plain';
  aResp.contents.Clear;
  aResp.Contents.add('OK:1');
  aResp.Contents.add('POST FROM 0741133800083'); //not important this serialnummer

  serial := leftstr(areq.QueryString,16);
  writeln(datetimetostr(now) +' ontvang timestamps : serial number is : '+serial);
  s := 'TRANS'+formatdatetime('YYYYMMDDhhnnsszzz',now)+'.txt'   ;

  s := writedir +'/' + s;
  writeln('Filename is ' +s);

  assignfile(txt,s);
  try
    rewrite(txt);
    writeln(txt,':TRANSACTIONS: ' +serial);
    writeln(txt,AReq.content);
  finally
    CloseFile(txt);
  end;
  p :=pos('Stamp=',areq.querystring);
  if p = 0 then
    aResp.Code:= 500
  else
  begin
    z := copy(areq.querystring,p+6,length(areq.querystring)-(p+5));
    writeln('Last stamp is ' +z);
    stamp := strtoint(z);
    inifile.WriteInteger('MAIN','stamp',stamp);
    inifile.updatefile;
  end;
end;

procedure Lees_status(aReq: TRequest; aResp: TResponse);
var
  s,serial  : string;
begin
 aResp.Server := 'Own Server';
  aResp.Connection:= 'close';
  aResp.ContentType:='text/plain';
  aResp.Content := ('OK');
  serial := leftstr(areq.QueryString,16);
  writeln(datetimetostr(now) +' status : serial number is : '+serial);
end;

begin
  try
     if not leesparameters then exit;
  HTTPRouter.registerRoute('/', @route1,true);
  HTTPRouter.registerRoute('/iclock/cdata',TrouteMethod.rmget, @Initialiseer_verbinding);
    HTTPRouter.registerRoute('/iclock/cdata',TrouteMethod.rmPost,@get_timestamps);
//  HTTPRouter.registerRoute('/iclock/getrequest?SN=0741133800083&INFO=Ver*',@Lees_status);
  HTTPRouter.registerRoute('/iclock/getrequest',@Lees_status);

  Application.Title:='iclock sync';
  Application.Port:=port;
  writeln(datetimetostr(now) +' server started');
  Application.Initialize;
  Application.Run;
  finally
   inifile.free;
  end;
end.

