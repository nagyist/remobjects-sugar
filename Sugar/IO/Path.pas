﻿namespace Sugar.IO;

interface

uses
  Sugar;

type
  Path = public static class
  public
    method ChangeExtension(FileName: not nullable String; NewExtension: nullable String): not nullable String;
    method Combine(BasePath: not nullable String; Path: not nullable String): not nullable String;
    method Combine(BasePath: not nullable String; Path1: not nullable String; Path2: not nullable String): not nullable String;
    method GetParentDirectory(FileName: not nullable String): nullable String;
    method GetExtension(FileName: not nullable String): not nullable String;
    method GetFileName(FileName: not nullable String): not nullable String;
    method GetFileNameWithoutExtension(FileName: not nullable String): not nullable String;
    method GetFullPath(RelativePath: not nullable String): not nullable String;

    property DirectorySeparatorChar: Char read Folder.Separator;
  end;

implementation

method Path.ChangeExtension(FileName: not nullable String; NewExtension: nullable String): not nullable String;
begin
  if length(NewExtension) = 0 then
    exit GetFileNameWithoutExtension(FileName);

  var lIndex := FileName.LastIndexOf(".");

  if lIndex <> -1 then
    FileName := FileName.Substring(0, lIndex);

  if NewExtension[0] = '.' then
    result := FileName + NewExtension
  else
    result := FileName + "." + NewExtension as not nullable;
end;

method Path.Combine(BasePath: not nullable String; Path: not nullable String): not nullable String;
begin
  if String.IsNullOrEmpty(BasePath) and String.IsNullOrEmpty(Path) then
    raise new SugarArgumentException("Invalid arguments");

  if String.IsNullOrEmpty(BasePath) then
    exit Path;

  if String.IsNullOrEmpty(Path) then
    exit BasePath;

  var LastChar := BasePath[BasePath.Length - 1];

  if LastChar = Folder.Separator then
    result := BasePath + Path
  else
    result := BasePath + Folder.Separator + Path; // 74540: Bogus nullability wanring, Nougat only
end;

method Path.Combine(BasePath: not nullable String; Path1: not nullable String; Path2: not nullable String): not nullable String;
begin
  exit Combine(Combine(BasePath, Path1), Path2);
end;

method Path.GetParentDirectory(FileName: not nullable String): nullable String;
begin
  if length(FileName) = 0 then
    raise new SugarArgumentException("Invalid arguments");

  var LastChar := FileName[FileName.Length - 1];

  if LastChar = Folder.Separator then
    FileName := FileName.Substring(0, FileName.Length - 1);

  if (FileName = Folder.Separator) or ((length(FileName) = 2) and (FileName[1] = ':')) then
    exit nil; // root folder has no parent

  var lIndex := FileName.LastIndexOf(Folder.Separator);

  if FileName.StartsWith('\\') then begin

    if lIndex > 1 then
      result := FileName.Substring(0, lIndex)
    else
      result := nil; // network share has no parent folder

  end
  else begin

    if lIndex > -1 then
      result := FileName.Substring(0, lIndex)
    else
      result := ""

  end;
end;

method Path.GetExtension(FileName: not nullable String): not nullable String;
begin
  FileName := GetFileName(FileName);
  var lIndex := FileName.LastIndexOf(".");

  if (lIndex <> -1) and (lIndex < FileName.Length - 1) then
    exit FileName.Substring(lIndex);

  exit "";
end;

method Path.GetFileName(FileName: not nullable String): not nullable String;
begin
  if FileName.Length = 0 then
    exit "";

  var LastChar: Char := FileName[FileName.Length - 1];

  if LastChar = Folder.Separator then
    FileName := FileName.Substring(0, FileName.Length - 1);

  var lIndex := FileName.LastIndexOf(Folder.Separator);

  if (lIndex <> -1) and (lIndex < FileName.Length - 1) then
    exit FileName.Substring(lIndex + 1);

  exit FileName;
end;

method Path.GetFileNameWithoutExtension(FileName: not nullable String): not nullable String;
begin
  FileName := GetFileName(FileName);
  var lIndex := FileName.LastIndexOf(".");

  if lIndex <> -1 then
    exit FileName.Substring(0, lIndex);

  exit FileName;
end;

method Path.GetFullPath(RelativePath: not nullable String): not nullable String;
begin
  {$IF COOPER}
  exit new java.io.File(RelativePath).AbsolutePath as not nullable;
  {$ELSEIF NETFX_CORE}
  exit RelativePath; //api has no such function
  {$ELSEIF WINDOWS_PHONE}
  exit System.IO.Path.GetFullPath(RelativePath)  as not nullable;
  {$ELSEIF ECHOES}
  exit System.IO.Path.GetFullPath(RelativePath) as not nullable;
  {$ELSEIF TOFFEE}
  exit (RelativePath as NSString).stringByStandardizingPath;
  {$ENDIF}
end;

end.