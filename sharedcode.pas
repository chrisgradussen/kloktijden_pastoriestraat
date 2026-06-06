unit sharedcode;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,inifiles;

var
   stamp : integer;
   writedir, gooddir, wrongdir : string;
   port : word;

function leesparameters(var aInifile : tInifile) : boolean;


implementation



function leesparameters(var aInifile : tInifile) : boolean;
var
  txt : file of text;
  tempfile : string;
begin
  result := false;
  if paramcount <> 1 then
  begin
    writeln(StdOut,'Wrong number of params. Only path to inifile allowed. Inifile must be writable');
    exit;
  end;
  if not sysutils.FileExists(paramstr(1)) then
  begin
    writeln(StdOut,'File : ' + paramstr(1) + 'does not exist');
     writeln(StdOut,'To start you need a file with at the following : ');
     writeln(StdOut,'[MAIN]');
     writeln(StdOut,'writedir=<pathtowritedir>');
     writeln(StdOut,'gooddir=<pathtogooddir>');
     writeln(StdOut,'wrongdir=<pathtowrongdir>');
     writeln(StdOut,'laststamp=<notset>');
     writeln(StdOut,'port=<server port number> (default 8081)');
     writeln(StdOut,'----------------------');
     writeln(StdOut,'writedir need to be writeable.');
     writeln(StdOut,'laststamp is 0 or higher.');
     exit;
  end;
  try
    try
      ainifile.CacheUpdates := false;
      ainifile.updatefile;
      writedir := ainifile.ReadString('MAIN','writedir','<pathtowritedir>');
      try
        tempfile := GetTempFileName(writedir,'tmp');
        assignfile(txt, tempfile);
        rewrite(txt);
        closefile(txt);
        deletefile(tempfile);
        writeln(StdOut,'PARAMDIR writedir = ' + writedir);
      except
        on E : EInOutError do begin writeln(StdOut,'writedir must exist and  be writable');  exit; end
        else raise
      end;
       gooddir := ainifile.ReadString('MAIN','gooddir','<pathtogooddir>');
      try
        tempfile := GetTempFileName(gooddir,'tmp');
        assignfile(txt, tempfile);
        rewrite(txt);
        closefile(txt);
        deletefile(tempfile);
        writeln(StdOut,'PARAM gooddir = ' + gooddir);
      except
        on E : EInOutError do begin writeln(StdOut,'gooddir must exist and  be writable');  exit; end
        else raise
      end;
      wrongdir := ainifile.ReadString('MAIN','wrongdir','<pathtowrongdir>');
      try
        tempfile := GetTempFileName(wrongdir,'tmp');
        assignfile(txt, tempfile);
        rewrite(txt);
        closefile(txt);
        deletefile(tempfile);
        writeln(StdOut,'PARAM wrongdir = ' + wrongdir);
      except
        on E : EInOutError do begin writeln(StdOut,'wrongdir must exist and  be writable');  exit; end
        else raise
      end;
      try
        stamp := ainifile.ReadInteger('MAIN','stamp',-1);
        if stamp = -1 then
        begin
          writeln(StdOut,'wrong value for stamp or no stamp with value -1, Found value : ' + ainifile.ReadString('MAIN','stamp','-1'));
          exit;
        end;
        writeln(StdOut,'PARAM STAMP = ' +inttostr(stamp));
        result := true;
     finally
     end;
     try
        port := ainifile.ReadInteger('MAIN','PORT',8081);
        writeln(StdOut,'PARAM PORT = ' + inttostr(port));
        result := true;
     finally
     end;
   Except
     on E : exception do
     begin writeln(StdOut,'inifile '+paramstr(1)+ ' must be writable');
     raise;
     end;
   end;
  finally
  end;
end;


end.

