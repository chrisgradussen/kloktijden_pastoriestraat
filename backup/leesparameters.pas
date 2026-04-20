unit leesparameters;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

implementation

function leesparameters : boolean;
var
  txt : file of text;
  tempfile : string;
begin
  result := false;
  if paramcount <> 1 then
  begin
    writeln('Wrong number of params. Only path to inifile allowed. Inifile must be writable');
    exit;
  end;
  if not sysutils.FileExists(paramstr(1)) then
  begin
    writeln('File : ' + paramstr(1) + 'does not exist');
     writeln('To start you need a file with at the following : ');
     writeln('[MAIN]');
     writeln('writedir=<pathtowritedir>');
     writeln('gooddir=<pathtogooddir>');
     writeln('wrongdir=<pathtowrongdir>');
     writeln('laststamp=<notset>');
     writeln('port=<server port number> (default 8081)');
     writeln('----------------------');
     writeln('writedir need to be writeable.');
     writeln('laststamp is 0 or higher.');
     exit;
  end;
  try
    try
      inifile := tinifile.create(paramstr(1));
      inifile.CacheUpdates := false;
      inifile.updatefile;
      writedir := inifile.ReadString('MAIN','writedir','<pathtowritedir>');
      try
        tempfile := GetTempFileName(writedir,'tmp');
        assignfile(txt, tempfile);
        rewrite(txt);
        closefile(txt);
        deletefile(tempfile);
        writeln('PARAMDIR writedir = ' + writedir);
      except
        on E : EInOutError do begin writeln('writedir must exist and  be writable');  exit; end
        else raise
      end;
       gooddir := inifile.ReadString('MAIN','gooddir','<pathtogooddir>');
      try
        tempfile := GetTempFileName(gooddir,'tmp');
        assignfile(txt, tempfile);
        rewrite(txt);
        closefile(txt);
        deletefile(tempfile);
        writeln('PARAM gooddir = ' + gooddir);
      except
        on E : EInOutError do begin writeln('gooddir must exist and  be writable');  exit; end
        else raise
      end;
      wrongdir := inifile.ReadString('MAIN','wrongdir','<pathtowrongdir>');
      try
        tempfile := GetTempFileName(wrongdir,'tmp');
        assignfile(txt, tempfile);
        rewrite(txt);
        closefile(txt);
        deletefile(tempfile);
        writeln('PARAM wrongdir = ' + wrongdir);
      except
        on E : EInOutError do begin writeln('wrongdir must exist and  be writable');  exit; end
        else raise
      end;
      try
        stamp := inifile.ReadInteger('MAIN','stamp',-1);
        if stamp = -1 then
        begin
          writeln('wrong value for stamp or no stamp with value -1, Found value : ' + inifile.ReadString('MAIN','stamp','-1'));
          exit;
        end;
        writeln('PARAM STAMP = ' +inttostr(stamp));
        result := true;
     finally
     end;
     try
        port := inifile.ReadInteger('MAIN','PORT',8081);
        writeln('PARAM PORT = ' + inttostr(port));
        result := true;
     finally
     end;
   Except
     on E : exception do
     begin writeln('inifile '+paramstr(1)+ ' must be writable');
     raise;
     end;
   end;
  finally
  end;
end;

end.

