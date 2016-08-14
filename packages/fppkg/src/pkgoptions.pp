{
    This file is part of the Free Pascal Utilities
    Copyright (c) 1999-2000 by the Free Pascal development team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$mode objfpc}
{$h+}
unit pkgoptions;

interface

// pkgglobals must be AFTER fpmkunit
uses Classes, Sysutils, Inifiles, fprepos, fpTemplate, fpmkunit, pkgglobals, fgl;

Const
  UnitConfigFileName   = 'fpunits.cfg';
  ManifestFileName     = 'manifest.xml';
  MirrorsFileName      = 'mirrors.xml';
  PackagesFileName     = 'packages.xml';
  MinSupportedConfigVersion = 4;
  CurrentConfigVersion = 5;

Type

  { TFppkgOptionSection }

  TFppkgOptionSection = class(TPersistent)
  private
    FName: string;
  public
    procedure AddKeyValue(const AKey, AValue: string); virtual;
    procedure SaveToStrings(AStrings: TStrings); virtual;
    procedure LogValues(ALogLevel: TLogLevel); virtual;
    function AllowDuplicate: Boolean; virtual;

    property Name: string read FName write FName;
  end;
  TFppkgOptionSectionList = specialize TFPGObjectList<TFppkgOptionSection>;

  { TFppkgGLobalOptionSection }

  TFppkgGlobalOptionSection = class(TFppkgOptionSection)
  private
    FCustomFPMakeOptions: string;
    FOptionParser: TTemplateParser;

    FBuildDir: string;
    FCompilerConfigDir: string;
    FConfigVersion: integer;
    FCompilerConfig: string;
    FDownloader: string;
    FFPMakeCompilerConfig: string;
    FLocalRepository: string;
    FRemoteMirrorsURL: string;
    FRemoteRepository: string;
    FArchivesDir: string;
    function GetArchivesDir: string;
    function GetBuildDir: string;
    function GetCompilerConfigDir: string;
    function GetLocalRepository: string;
    procedure SetArchivesDir(AValue: string);
    procedure SetBuildDir(AValue: string);
    procedure SetCompilerConfigDir(AValue: string);
    procedure SetConfigVersion(AValue: integer);
    procedure SetCompilerConfig(AValue: string);
    procedure SetCustomFPMakeOptions(AValue: string);
    procedure SetDownloader(AValue: string);
    procedure SetFPMakeCompilerConfig(AValue: string);
    procedure SetLocalRepository(AValue: string);
    procedure SetRemoteMirrorsURL(AValue: string);
    procedure SetRemoteRepository(AValue: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddKeyValue(const AKey, AValue: string); override;
    procedure SaveToStrings(AStrings: TStrings); override;
    procedure LogValues(ALogLevel: TLogLevel); override;

    function LocalMirrorsFile:string;
    function LocalPackagesFile:string;

    property ConfigVersion: integer read FConfigVersion write SetConfigVersion;
    property LocalRepository: string read GetLocalRepository write SetLocalRepository;
    property BuildDir: string read GetBuildDir write SetBuildDir;
    property CompilerConfigDir: string read GetCompilerConfigDir write SetCompilerConfigDir;
    property ArchivesDir: string read GetArchivesDir write SetArchivesDir;
    property Downloader: string read FDownloader write SetDownloader;
    property CompilerConfig: string read FCompilerConfig write SetCompilerConfig;
    property FPMakeCompilerConfig: string read FFPMakeCompilerConfig write SetFPMakeCompilerConfig;
    property RemoteRepository: string read FRemoteRepository write SetRemoteRepository;
    property RemoteMirrorsURL: string read FRemoteMirrorsURL write SetRemoteMirrorsURL;
    Property CustomFPMakeOptions: string read FCustomFPMakeOptions Write SetCustomFPMakeOptions;
  end;

  { TFppkgCustomOptionSection }

  TFppkgCustomOptionSection = class(TFppkgOptionSection);

  { TFppkgCommandLineOptionSection }

  TFppkgCommandLineOptionSection = class(TFppkgOptionSection)
  private
    FAllowBroken: Boolean;
    FCompilerConfig: string;
    FInstallGlobal: Boolean;
    FRecoveryMode: Boolean;
    FShowLocation: Boolean;
    FSkipConfigurationFiles: Boolean;
    FSkipFixBrokenAfterInstall: Boolean;
  public
    constructor Create;
    property RecoveryMode: Boolean read FRecoveryMode write FRecoveryMode;
    property InstallGlobal: Boolean read FInstallGlobal write FInstallGlobal;
    property ShowLocation: Boolean read FShowLocation write FShowLocation;
    property CompilerConfig : string read FCompilerConfig write FCompilerConfig;
    property SkipConfigurationFiles: Boolean read FSkipConfigurationFiles write FSkipConfigurationFiles;
    property AllowBroken : Boolean read FAllowBroken write FAllowBroken;
    property SkipFixBrokenAfterInstall: Boolean read FSkipFixBrokenAfterInstall write FSkipFixBrokenAfterInstall;
  end;


  { TFppkgOptions }

  TFppkgOptions = class(TPersistent)
  private
    FSectionList: TFppkgOptionSectionList;
    function GetCommandLineSection: TFppkgCommandLineOptionSection;
    function GetGlobalSection: TFppkgGLobalOptionSection;
    function GetSectionList: TFppkgOptionSectionList;
  public
    constructor Create();
    destructor Destroy; override;

    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    function GetSectionByName(const SectionName: string): TFppkgOptionSection;
    procedure LogValues(ALogLevel: TLogLevel);

    property SectionList: TFppkgOptionSectionList read GetSectionList;
    property GlobalSection: TFppkgGLobalOptionSection read GetGlobalSection;
    property CommandLineSection: TFppkgCommandLineOptionSection read GetCommandLineSection;
  end;

  { TCompilerOptions }

  TCompilerOptions = Class(TPersistent)
  private
    FConfigFilename: string;
    FSaveInifileChanges: Boolean;
    FConfigVersion : Integer;
    FCompiler,
    FCompilerVersion,
    FLocalInstallDir,
    FGlobalInstallDir,
    FLocalPrefix,
    FGlobalPrefix: String;
    FCompilerCPU: TCPU;
    FCompilerOS: TOS;
    FOptionParser: TTemplateParser;
    FOptions: TStrings;
    function GetOptions: TStrings;
    function GetOptString(Index: integer): String;
    procedure SetOptString(Index: integer; const AValue: String);
    procedure SetCompilerCPU(const AValue: TCPU);
    procedure SetCompilerOS(const AValue: TOS);
  Public
    Constructor Create;
    Destructor Destroy; override;
    Procedure InitCompilerDefaults;
    Procedure LoadCompilerFromFile(const AFileName : String);
    Procedure SaveCompilerToFile(const AFileName : String);
    procedure LogValues(ALogLevel: TLogLevel; const ACfgName:string);
    procedure UpdateLocalRepositoryOption;
    procedure CheckCompilerValues;
    Function LocalUnitDir:string;
    Function GlobalUnitDir:string;
    Function HasOptions: boolean;
    // Is set when the inifile has an old version number (which is also the case when a new file is generated)
    Property SaveInifileChanges : Boolean Read FSaveInifileChanges;
    Property ConfigVersion : Integer read FConfigVersion;
  Published
    Property Compiler : String Index 1 Read GetOptString Write SetOptString;
    Property CompilerTarget : String Index 2 Read GetOptString Write SetOptString;
    Property CompilerVersion : String Index 3 Read GetOptString Write SetOptString;
    Property GlobalInstallDir : String Index 4 Read GetOptString Write SetOptString;
    Property LocalInstallDir : String Index 5 Read GetOptString Write SetOptString;
    Property GlobalPrefix : String Index 6 Read GetOptString Write SetOptString;
    Property LocalPrefix : String Index 7 Read GetOptString Write SetOptString;
    Property Options : TStrings read GetOptions;
    Property CompilerOS : TOS Read FCompilerOS Write SetCompilerOS;
    Property CompilerCPU : TCPU Read FCompilerCPU Write SetCompilerCPU;
  end;

var
  GlobalOptions : TFppkgOptions;

  CompilerOptions : TCompilerOptions;
  FPMakeCompilerOptions : TCompilerOptions;

procedure LoadGlobalDefaults(CfgFile: string);
procedure ClearCompilerDefaults;
procedure LoadCompilerDefaults;

Implementation

uses
  pkgmessages;

Const
  DefaultMirrorsURL  = 'http://www.freepascal.org/repository/'+MirrorsFileName;
{$ifdef localrepository}
  DefaultRemoteRepository = 'file://'+{$I %HOME%}+'/repository/';
{$else}
  DefaultRemoteRepository = 'auto';
{$endif}

  // ini file keys
  SDefaults = 'Defaults';

  // All configs
  KeyConfigVersion         = 'ConfigVersion';

  // Global config
  KeyDeprGlobalSection     = 'Defaults';
  KeyGlobalSection         = 'Global';
  KeyRemoteMirrorsURL      = 'RemoteMirrors';
  KeyRemoteRepository      = 'RemoteRepository';
  KeyLocalRepository       = 'LocalRepository';
  KeyArchivesDir           = 'ArchivesDir';
  KeyBuildDir              = 'BuildDir';
  KeyCompilerConfigDir     = 'CompilerConfigDir';
  KeyCompilerConfig        = 'CompilerConfig';
  KeyFPMakeCompilerConfig  = 'FPMakeCompilerConfig';
  KeyDownloader            = 'Downloader';
  KeyCustomFPMakeOptions   = 'FPMakeOptions';

  // Compiler dependent config
  KeyGlobalPrefix          = 'GlobalPrefix';
  KeyLocalPrefix           = 'LocalPrefix';
  KeyGlobalInstallDir      = 'GlobalInstallDir';
  KeyLocalInstallDir       = 'LocalInstallDir';
  KeyCompiler              = 'Compiler' ;
  KeyCompilerOS            = 'OS';
  KeyCompilerCPU           = 'CPU';
  KeyCompilerVersion       = 'Version';


procedure LoadGlobalDefaults(CfgFile: string);
var
  i : integer;
  GeneratedConfig,
  UseGlobalConfig : boolean;
begin
  GeneratedConfig:=false;
  UseGlobalConfig:=false;
  // First try specified config file
  if (CfgFile<>'') then
    begin
      if not FileExists(cfgfile) then
        Error(SErrNoSuchFile,[cfgfile]);
    end
  else
    begin
      // Now try if a local config-file exists
      cfgfile:=GetAppConfigFile(False,False);
      if not FileExists(cfgfile) then
        begin
          // If not, try to find a global configuration file
          cfgfile:=GetAppConfigFile(True,False);
          if FileExists(cfgfile) then
            UseGlobalConfig := true
          else
            begin
              // Create a new configuration file
              if not IsSuperUser then // Make a local, not global, configuration file
                cfgfile:=GetAppConfigFile(False,False);
              ForceDirectories(ExtractFilePath(cfgfile));
              GlobalOptions.SaveToFile(cfgfile);
              GeneratedConfig:=true;
            end;
        end;
    end;
  // Load file or create new default configuration
  if not GeneratedConfig then
    begin
      GlobalOptions.LoadFromFile(cfgfile);
    end;
  GlobalOptions.CommandLineSection.CompilerConfig:=GlobalOptions.GlobalSection.CompilerConfig;
  // Tracing of what we've done above, need to be done after the verbosity is set
  if GeneratedConfig then
    pkgglobals.Log(llDebug,SLogGeneratingGlobalConfig,[cfgfile])
  else
    pkgglobals.Log(llDebug,SLogLoadingGlobalConfig,[cfgfile]);
  // Log configuration
  GlobalOptions.LogValues(llDebug);
end;

procedure ClearCompilerDefaults;
begin
  CompilerOptions.Free;
  FPMakeCompilerOptions.Free;
  CompilerOptions:=TCompilerOptions.Create;
  FPMakeCompilerOptions:=TCompilerOptions.Create;
end;

procedure LoadCompilerDefaults;
var
  S : String;
begin
  // Load default compiler config
  S:=GlobalOptions.GlobalSection.CompilerConfigDir+GlobalOptions.GlobalSection.CompilerConfig;
  CompilerOptions.UpdateLocalRepositoryOption;
  if FileExists(S) then
    begin
      pkgglobals.Log(llDebug,SLogLoadingCompilerConfig,[S]);
      CompilerOptions.LoadCompilerFromFile(S)
    end
  else
    begin
      // Generate a default configuration if it doesn't exists
      if GlobalOptions.GlobalSection.CompilerConfig='default' then
        begin
          pkgglobals.Log(llDebug,SLogGeneratingCompilerConfig,[S]);
          CompilerOptions.InitCompilerDefaults;
          CompilerOptions.SaveCompilerToFile(S);
          if CompilerOptions.SaveInifileChanges then
            CompilerOptions.SaveCompilerToFile(S);
        end
      else
        Error(SErrMissingCompilerConfig,[S]);
    end;
  // Log compiler configuration
  CompilerOptions.LogValues(llDebug,'');
  // Load FPMake compiler config, this is normally the same config as above
  S:=GlobalOptions.GlobalSection.CompilerConfigDir+GlobalOptions.GlobalSection.FPMakeCompilerConfig;
  FPMakeCompilerOptions.UpdateLocalRepositoryOption;
  if FileExists(S) then
    begin
      pkgglobals.Log(llDebug,SLogLoadingFPMakeCompilerConfig,[S]);
      FPMakeCompilerOptions.LoadCompilerFromFile(S);
      if FPMakeCompilerOptions.SaveInifileChanges then
        FPMakeCompilerOptions.SaveCompilerToFile(S);
    end
  else
    Error(SErrMissingCompilerConfig,[S]);
  // Log compiler configuration
  FPMakeCompilerOptions.LogValues(llDebug,'fpmake-building ');
end;

{ TFppkgCommandLineOptionSection }

constructor TFppkgCommandLineOptionSection.Create;
begin
  // Parameter defaults
  FInstallGlobal:=False;
  FRecoveryMode:=False;
  FAllowBroken:=False;
end;

{ TFppkgOptionSection }

procedure TFppkgOptionSection.AddKeyValue(const AKey, AValue: string);
begin
  // Do nothing
end;

procedure TFppkgOptionSection.SaveToStrings(AStrings: TStrings);
begin
  // Do nothing
end;

procedure TFppkgOptionSection.LogValues(ALogLevel: TLogLevel);
begin
  log(ALogLevel,SLogCfgSectionHeader, [Trim(Name)]);
end;

function TFppkgOptionSection.AllowDuplicate: Boolean;
begin
  Result:=False;
end;

{*****************************************************************************
                      TFppkgGlobalOptionSection
*****************************************************************************}

procedure TFppkgGlobalOptionSection.SetBuildDir(AValue: string);
begin
  if FBuildDir = AValue then Exit;
  FBuildDir := fpmkunit.FixPath(AValue, True);
end;

function TFppkgGlobalOptionSection.GetCompilerConfigDir: string;
begin
  Result := FOptionParser.ParseString(FCompilerConfigDir);
end;

function TFppkgGlobalOptionSection.GetLocalRepository: string;
begin
  Result := FOptionParser.ParseString(FLocalRepository);
end;

procedure TFppkgGlobalOptionSection.SetArchivesDir(AValue: string);
begin
  if FArchivesDir = AValue then Exit;
  FArchivesDir := fpmkunit.FixPath(AValue, True);
end;

function TFppkgGlobalOptionSection.GetBuildDir: string;
begin
  Result := FOptionParser.ParseString(FBuildDir);
end;

function TFppkgGlobalOptionSection.GetArchivesDir: string;
begin
  Result := FOptionParser.ParseString(FArchivesDir);
end;

procedure TFppkgGlobalOptionSection.SetCompilerConfigDir(AValue: string);
begin
  if FCompilerConfigDir = AValue then Exit;
  FCompilerConfigDir := fpmkunit.FixPath(AValue, True);
end;

procedure TFppkgGlobalOptionSection.SetConfigVersion(AValue: integer);
begin
  if FConfigVersion = AValue then Exit;
  FConfigVersion := AValue;
end;

procedure TFppkgGlobalOptionSection.SetCompilerConfig(AValue: string);
begin
  if FCompilerConfig = AValue then Exit;
  FCompilerConfig := AValue;
end;

procedure TFppkgGlobalOptionSection.SetCustomFPMakeOptions(AValue: string);
begin
  if FCustomFPMakeOptions = AValue then Exit;
  FCustomFPMakeOptions := AValue;
end;

procedure TFppkgGlobalOptionSection.SetDownloader(AValue: string);
begin
  if FDownloader = AValue then Exit;
  FDownloader := AValue;
end;

procedure TFppkgGlobalOptionSection.SetFPMakeCompilerConfig(AValue: string);
begin
  if FFPMakeCompilerConfig = AValue then Exit;
  FFPMakeCompilerConfig := AValue;
end;

procedure TFppkgGlobalOptionSection.SetLocalRepository(AValue: string);
begin
  if FLocalRepository = AValue then Exit;
  FLocalRepository := AValue;
  FOptionParser.Values['LocalRepository'] := LocalRepository;
end;

procedure TFppkgGlobalOptionSection.SetRemoteMirrorsURL(AValue: string);
begin
  if FRemoteMirrorsURL = AValue then Exit;
  FRemoteMirrorsURL := AValue;
end;

procedure TFppkgGlobalOptionSection.SetRemoteRepository(AValue: string);
begin
  if FRemoteRepository = AValue then Exit;
  FRemoteRepository := AValue;
end;

constructor TFppkgGlobalOptionSection.Create;
begin
  FOptionParser := TTemplateParser.Create;
  FOptionParser.Values['AppConfigDir'] := GetAppConfigDir(false);
  FOptionParser.Values['UserDir'] := GetUserDir;

  // Retrieve Local fppkg directory
{$ifdef unix}
  if IsSuperUser then
    begin
      if DirectoryExists('/usr/local/lib/fpc') then
        LocalRepository:='/usr/local/lib/fpc/fppkg/'
      else
        LocalRepository:='/usr/lib/fpc/fppkg/';
    end
  else
    LocalRepository:='{UserDir}.fppkg/';
{$else}
  if IsSuperUser then
    LocalRepository:=IncludeTrailingPathDelimiter(GetAppConfigDir(true))
  else
    LocalRepository:='{AppConfigDir}';
{$endif}

  ConfigVersion := CurrentConfigVersion;
  CompilerConfig := 'default';
  FPMakeCompilerConfig := 'default';
  RemoteRepository := DefaultRemoteRepository;
  FRemoteMirrorsURL:=DefaultMirrorsURL;

  // Directories
  BuildDir:='{LocalRepository}build'+PathDelim;
  ArchivesDir:='{LocalRepository}archives'+PathDelim;
  CompilerConfigDir:='{LocalRepository}config'+PathDelim;
{$if defined(unix) or defined(windows)}
  Downloader:='lnet';
{$else}
  Downloader:='base';
{$endif}
end;

destructor TFppkgGlobalOptionSection.Destroy;
begin
  FOptionParser.Free;
  inherited Destroy;
end;

procedure TFppkgGlobalOptionSection.AddKeyValue(const AKey, AValue: string);
begin
  if SameText(AKey,KeyBuildDir) then
    BuildDir := AValue
  else if SameText(AKey,KeyDownloader) then
    Downloader := AValue
  else if SameText(AKey,KeyConfigVersion) then
    begin
      ConfigVersion := StrToIntDef(AValue,-1);
      if (FConfigVersion<>CurrentConfigVersion) then
        begin
          if (FConfigVersion<MinSupportedConfigVersion) or (FConfigVersion>CurrentConfigVersion) then
            Error(SErrUnsupportedConfigVersion);
          log(llWarning,SLogOldConfigFileFormat);
        end;
    end
  else if SameText(AKey,KeyCompilerConfig) then
    CompilerConfig := AValue
  else if SameText(AKey,KeyFPMakeCompilerConfig) then
    FPMakeCompilerConfig := AValue
  else if SameText(AKey,KeyCompilerConfigDir) then
    CompilerConfigDir := AValue
  else if SameText(AKey,KeyRemoteMirrorsURL) then
    RemoteMirrorsURL := AValue
  else if SameText(AKey,KeyRemoteRepository) then
    RemoteRepository := AValue
  else if SameText(AKey,KeyLocalRepository) then
    LocalRepository := AValue
  else if SameText(AKey,KeyArchivesDir) then
    ArchivesDir := AValue
  else if SameText(AKey,KeyCustomFPMakeOptions) then
    CustomFPMakeOptions := AValue
end;

procedure TFppkgGlobalOptionSection.SaveToStrings(AStrings: TStrings);
begin
  AStrings.Add('['+KeyGlobalSection+']');
  AStrings.Add(KeyConfigVersion+'='+IntToStr(CurrentConfigVersion));
  AStrings.Add(KeyBuildDir+'='+BuildDir);
  AStrings.Add(KeyDownloader+'='+Downloader);
  AStrings.Add(KeyCompilerConfig+'='+CompilerConfig);
  AStrings.Add(KeyFPMakeCompilerConfig+'='+FPMakeCompilerConfig);
  AStrings.Add(KeyCompilerConfigDir+'='+CompilerConfigDir);
  AStrings.Add(KeyRemoteMirrorsURL+'='+RemoteMirrorsURL);
  AStrings.Add(KeyRemoteRepository+'='+RemoteRepository);
  AStrings.Add(KeyLocalRepository+'='+LocalRepository);
  AStrings.Add(KeyArchivesDir+'='+ArchivesDir);
end;

procedure TFppkgGlobalOptionSection.LogValues(ALogLevel: TLogLevel);
begin
  inherited LogValues(ALogLevel);
  log(ALogLevel,SLogGlobalCfgRemoteMirrorsURL,[FRemoteMirrorsURL]);
  log(ALogLevel,SLogGlobalCfgRemoteRepository,[FRemoteRepository]);
  log(ALogLevel,SLogGlobalCfgLocalRepository,[FLocalRepository,LocalRepository]);
  log(ALogLevel,SLogGlobalCfgBuildDir,[FBuildDir,BuildDir]);
  log(ALogLevel,SLogGlobalCfgArchivesDir,[FArchivesDir,ArchivesDir]);
  log(ALogLevel,SLogGlobalCfgCompilerConfigDir,[FCompilerConfigDir,CompilerConfigDir]);
  log(ALogLevel,SLogGlobalCfgDefaultCompilerConfig,[FCompilerConfig]);
  log(ALogLevel,SLogGlobalCfgFPMakeCompilerConfig,[FPMakeCompilerConfig]);
  log(ALogLevel,SLogGlobalCfgDownloader,[FDownloader]);
end;

function TFppkgGlobalOptionSection.LocalMirrorsFile: string;
begin
  Result:=LocalRepository+MirrorsFileName;
end;

function TFppkgGlobalOptionSection.LocalPackagesFile: string;
begin
  Result:=LocalRepository+PackagesFileName;
end;

{*****************************************************************************
                            TFppkgOptions
*****************************************************************************}

function TFppkgOptions.GetSectionList: TFppkgOptionSectionList;
begin
  Result := FSectionList;
end;

function TFppkgOptions.GetGlobalSection: TFppkgGLobalOptionSection;
begin
  Result := GetSectionByName(KeyGlobalSection) as TFppkgGlobalOptionSection;
  // Below version 5 the glolbal-section was called 'Defaults'
  if not Assigned(Result) then
    Result := GetSectionByName(KeyDeprGlobalSection) as TFppkgGlobalOptionSection;

  if not Assigned(Result) then
    begin
      Result := TFppkgGlobalOptionSection.Create;
      Result.Name := KeyGlobalSection;
      FSectionList.Add(Result);
    end;
end;

function TFppkgOptions.GetCommandLineSection: TFppkgCommandLineOptionSection;
begin
  Result := GetSectionByName(' Commandline ') as TFppkgCommandLineOptionSection;
  if not Assigned(Result) then
    begin
      Result := TFppkgCommandLineOptionSection.Create;
      Result.Name := ' Commandline ';
      FSectionList.Add(Result);
    end;
end;

constructor TFppkgOptions.Create;
begin
  FSectionList := TFppkgOptionSectionList.Create;
end;

destructor TFppkgOptions.Destroy;
begin
  FSectionList.Free;
  inherited Destroy;
end;

procedure TFppkgOptions.LoadFromFile(const AFileName: string);
var
  IniFile: TStringList;
  CurrentSection: TFppkgOptionSection;
  s: String;
  i: Integer;
  j: SizeInt;
begin
  log(llInfo, SLogStartLoadingConfFile, [AFileName]);
  IniFile:=TStringList.Create;
  try
    Inifile.LoadFromFile(AFileName);
    for i := 0 to Inifile.Count-1 do
      begin
        s := Trim(IniFile[i]);
        if s = '' then
          Continue;
        if (Copy(s, 1, 1) = '[') and (Copy(s, length(s), 1) = ']') then
          begin
            s := Trim(Copy(s, 2, Length(s) - 2));
            CurrentSection := GetSectionByName(s);
            if not Assigned(CurrentSection) or CurrentSection.AllowDuplicate then
              begin
                if SameText(s, KeyGlobalSection) or SameText(s, KeyDeprGlobalSection) then
                  CurrentSection := TFppkgGlobalOptionSection.Create
                else
                  CurrentSection := TFppkgCustomOptionSection.Create;
                FSectionList.Add(CurrentSection);
                CurrentSection.Name := s;
              end
          end
        else if copy(s,1,1)<>';' then // comment
          begin
            // regular key
            j:=Pos('=', s);
            if j>0 then
              CurrentSection.AddKeyValue(Trim(Copy(s, 1,  j - 1)), Trim(Copy(s, j + 1, Length(s) - j)));
          end;
      end;
  finally
    Inifile.Free;
  end;
end;

procedure TFppkgOptions.SaveToFile(const AFileName: string);
var
  IniFile: TStringList;
  CurrentSection: TFppkgOptionSection;
  s: String;
  i: Integer;
  j: SizeInt;
begin
  IniFile:=TStringList.Create;
  try
    // Only the Global-section is being written, with some default values
    CurrentSection := GlobalSection;
    CurrentSection.SaveToStrings(IniFile);
    Inifile.SaveToFile(AFileName);
  finally
    Inifile.Free;
  end;
end;

function TFppkgOptions.GetSectionByName(const SectionName: string): TFppkgOptionSection;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to SectionList.Count-1 do
    begin
      if SectionList[i].Name=SectionName then
        begin
          Result:=SectionList[i];
          Break;
        end;
    end;
end;

procedure TFppkgOptions.LogValues(ALogLevel: TLogLevel);
var
  i: Integer;
begin
  log(ALogLevel,SLogCfgHeader);
  for i := 0 to SectionList.Count-1 do
    begin
      SectionList[i].LogValues(ALogLevel);
    end;
end;

{*****************************************************************************
                           TCompilerOptions
*****************************************************************************}

constructor TCompilerOptions.Create;
begin
  FOptionParser := TTemplateParser.Create;
  FOptionParser.Values['AppConfigDir'] := GetAppConfigDir(false);
  FOptionParser.Values['UserDir'] := GetUserDir;
  {$ifdef unix}
  FLocalInstallDir:='{LocalPrefix}'+'lib'+PathDelim+'fpc'+PathDelim+'{CompilerVersion}'+PathDelim;
  FGlobalInstallDir:='{GlobalPrefix}'+'lib'+PathDelim+'fpc'+PathDelim+'{CompilerVersion}'+PathDelim;
  {$else unix}
  FLocalInstallDir:='{LocalPrefix}';
  FGlobalInstallDir:='{GlobalPrefix}';
  {$endif}
end;

destructor TCompilerOptions.Destroy;
begin
  FOptionParser.Free;
  if assigned(FOptions) then
    FreeAndNil(FOptions);
  inherited Destroy;
end;


function TCompilerOptions.GetOptString(Index: integer): String;
begin
  Case Index of
    1 : Result:=FCompiler;
    2 : Result:=MakeTargetString(CompilerCPU,CompilerOS);
    3 : Result:=FCompilerVersion;
    4 : Result:=FOptionParser.ParseString(FGlobalInstallDir);
    5 : Result:=FOptionParser.ParseString(FLocalInstallDir);
    6 : Result:=fpmkunit.FixPath(FOptionParser.ParseString(FGlobalPrefix), True);
    7 : Result:=fpmkunit.FixPath(FOptionParser.ParseString(FLocalPrefix), True);
    else
      Error('Unknown option');
  end;
end;

function TCompilerOptions.GetOptions: TStrings;
begin
  if not assigned(FOptions) then
    begin
      FOptions := TStringList.Create;
      FOptions.Delimiter:=' ';
    end;
  Result := FOptions;
end;


procedure TCompilerOptions.SetOptString(Index: integer; const AValue: String);
begin
  If AValue=GetOptString(Index) then
    Exit;
  Case Index of
    1 : FCompiler:=AValue;
    2 : StringToCPUOS(AValue,FCompilerCPU,FCompilerOS);
    3 : begin
          FCompilerVersion:=AValue;
          FOptionParser.Values['CompilerVersion'] := FCompilerVersion;
        end;
    4 : FGlobalInstallDir:=fpmkunit.FixPath(AValue, True);
    5 : FLocalInstallDir:=fpmkunit.FixPath(AValue, True);
    6 : begin
          FGlobalPrefix:=AValue;
          FOptionParser.Values['GlobalPrefix'] := GlobalPrefix;
        end;
    7 : begin
          FLocalPrefix:=AValue;
          FOptionParser.Values['LocalPrefix'] := LocalPrefix;
        end
    else
      Error('Unknown option');
  end;
end;


procedure TCompilerOptions.SetCompilerCPU(const AValue: TCPU);
begin
  if FCompilerCPU=AValue then
    exit;
  FCompilerCPU:=AValue;
end;


procedure TCompilerOptions.UpdateLocalRepositoryOption;
begin
  FOptionParser.Values['LocalRepository'] := GlobalOptions.GlobalSection.LocalRepository;
end;

procedure TCompilerOptions.CheckCompilerValues;
var
  AVersion : string;
  ACpu     : TCpu;
  AOs      : TOS;
begin
  if Compiler='' then
    Exit;
  if (CompilerCPU=cpuNone) or
   (CompilerOS=osNone) or
   (CompilerVersion='') then
  begin
    GetCompilerInfo(Compiler,'-iVTPTO',AVersion,ACpu,AOs);
    if CompilerCPU=cpuNone then
      CompilerCPU := ACpu;
    if CompilerOS=osNone then
      CompilerOS:=AOs;
    if CompilerVersion='' then
      CompilerVersion:=AVersion;
  end;
end;


procedure TCompilerOptions.SetCompilerOS(const AValue: TOS);
begin
  if FCompilerOS=AValue then
    exit;
  FCompilerOS:=AValue;
end;


function TCompilerOptions.LocalUnitDir:string;
var ALocalInstallDir: string;
begin
  ALocalInstallDir:=LocalInstallDir;

  if ALocalInstallDir<>'' then
    result:=ALocalInstallDir+'units'+PathDelim+CompilerTarget+PathDelim
  else
    result:='';
end;


function TCompilerOptions.GlobalUnitDir:string;
var AGlobalInstallDir: string;
begin
  AGlobalInstallDir:=GlobalInstallDir;

  if AGlobalInstallDir<>'' then
    result:=AGlobalInstallDir+'units'+PathDelim+CompilerTarget+PathDelim
  else
    result:='';
end;


function TCompilerOptions.HasOptions: boolean;
begin
  result := assigned(FOptions);
end;


procedure TCompilerOptions.InitCompilerDefaults;
var
  ACompilerVersion: string;
  fpcdir: string;
begin
  FConfigVersion:=CurrentConfigVersion;
  if fcompiler = '' then
    FCompiler:=ExeSearch('fpc'+ExeExt,GetEnvironmentVariable('PATH'));
  if FCompiler='' then
    Raise EPackagerError.Create(SErrMissingFPC);
  // Detect compiler version/target from -i option
  GetCompilerInfo(FCompiler,'-iVTPTO',ACompilerVersion,FCompilerCPU,FCompilerOS);
  CompilerVersion := ACompilerVersion;
  // Temporary hack to workaround bug in fpc.exe that doesn't support spaces
  // We retrieve the real binary
  if FCompilerVersion='2.2.0' then
    FCompiler:=GetCompilerInfo(FCompiler,'-PB');
  log(llDebug,SLogDetectedCompiler,[FCompiler,FCompilerVersion,MakeTargetString(FCompilerCPU,FCompilerOS)]);

  // Use the same algorithm as the compiler, see options.pas
  // Except that the prefix is extracted and GlobalInstallDir is set using
  // that prefix
{$ifdef Unix}
  FGlobalPrefix:='/usr/local/';
  if not DirectoryExists(FGlobalPrefix+'lib/fpc/'+FCompilerVersion+'/') and
     DirectoryExists('/usr/lib/fpc/'+FCompilerVersion+'/') then
    FGlobalPrefix:='/usr/';
{$else unix}
  FGlobalPrefix:=ExtractFilePath(FCompiler)+'..'+PathDelim;
  if not(DirectoryExists(FGlobalPrefix+PathDelim+'units')) and
     not(DirectoryExists(FGlobalPrefix+PathDelim+'rtl')) then
    FGlobalPrefix:=FGlobalPrefix+'..'+PathDelim;
  FGlobalPrefix:=ExpandFileName(FGlobalPrefix);
{$endif unix}

  log(llDebug,SLogDetectedPrefix,['global',FGlobalPrefix]);
  // User writable install directory
  if not IsSuperUser then
    begin
      FLocalPrefix:= '{LocalRepository}';
      log(llDebug,SLogDetectedPrefix,['local',FLocalPrefix]);
    end;

  fpcdir:=fpmkunit.FixPath(GetEnvironmentVariable('FPCDIR'), True);
  if fpcdir<>'' then
    begin
    {$ifndef Unix}
    fpcdir:=ExpandFileName(fpcdir);
    {$endif unix}
    log(llDebug,SLogFPCDirEnv,[fpcdir]);
    FGlobalInstallDir:=fpcdir;
    end;
end;


procedure TCompilerOptions.LoadCompilerFromFile(const AFileName: String);
Var
  Ini : TMemIniFile;
begin
  Ini:=TMemIniFile.Create(AFileName);
  try
    FConfigFilename:=AFileName;
    With Ini do
      begin
        FConfigVersion:=ReadInteger(SDefaults,KeyConfigVersion,0);
        if (FConfigVersion<>CurrentConfigVersion) then
          begin
            log(llDebug,SLogUpgradingConfig,[AFileName]);
            FSaveInifileChanges:=true;
            if (FConfigVersion>CurrentConfigVersion) then
              Error(SErrUnsupportedConfigVersion,[AFileName]);
          end;
        GlobalPrefix:=ReadString(SDefaults,KeyGlobalPrefix,FGlobalPrefix);
        LocalPrefix:=ReadString(SDefaults,KeyLocalPrefix,FLocalPrefix);
        FGlobalInstallDir:=fpmkunit.FixPath(ReadString(SDefaults,KeyGlobalInstallDir,FGlobalInstallDir), True);
        FLocalInstallDir:=fpmkunit.FixPath(ReadString(SDefaults,KeyLocalInstallDir,FLocalInstallDir), True);
        FCompiler:=ReadString(SDefaults,KeyCompiler,FCompiler);
        FCompilerOS:=StringToOS(ReadString(SDefaults,KeyCompilerOS,OSToString(CompilerOS)));
        FCompilerCPU:=StringToCPU(ReadString(SDefaults,KeyCompilerCPU,CPUtoString(CompilerCPU)));
        CompilerVersion:=ReadString(SDefaults,KeyCompilerVersion,FCompilerVersion);
      end;
  finally
    Ini.Free;
  end;
end;


procedure TCompilerOptions.SaveCompilerToFile(const AFileName: String);
Var
  Ini : TIniFile;
begin
  if FileExists(AFileName) then
    BackupFile(AFileName);
  Ini:=TIniFile.Create(AFileName);
  try
    With Ini do
      begin
        WriteInteger(SDefaults,KeyConfigVersion,CurrentConfigVersion);
        WriteString(SDefaults,KeyGlobalPrefix,FGlobalPrefix);
        WriteString(SDefaults,KeyLocalPrefix,FLocalPrefix);
        WriteString(SDefaults,KeyGlobalInstallDir,FGlobalInstallDir);
        WriteString(SDefaults,KeyLocalInstallDir,FLocalInstallDir);
        WriteString(SDefaults,KeyCompiler,FCompiler);
        WriteString(SDefaults,KeyCompilerOS,OSToString(CompilerOS));
        WriteString(SDefaults,KeyCompilerCPU,CPUtoString(CompilerCPU));
        WriteString(SDefaults,KeyCompilerVersion,FCompilerVersion);
        FSaveInifileChanges:=False;
      end;
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;


procedure TCompilerOptions.LogValues(ALogLevel: TLogLevel; const ACfgName:string);
begin
  log(ALogLevel,SLogCompilerCfgHeader,[ACfgName,FConfigFilename]);
  log(ALogLevel,SLogCompilerCfgCompiler,[FCompiler]);
  log(ALogLevel,SLogCompilerCfgTarget,[MakeTargetString(CompilerCPU,CompilerOS)]);
  log(ALogLevel,SLogCompilerCfgVersion,[FCompilerVersion]);
  log(ALogLevel,SLogCompilerCfgGlobalPrefix,[FGlobalPrefix,GlobalPrefix]);
  log(ALogLevel,SLogCompilerCfgLocalPrefix,[FLocalPrefix,LocalPrefix]);
  log(ALogLevel,SLogCompilerCfgGlobalInstallDir,[FGlobalInstallDir,GlobalInstallDir]);
  log(ALogLevel,SLogCompilerCfgLocalInstallDir,[FLocalInstallDir,LocalInstallDir]);
  log(ALogLevel,SLogCompilerCfgOptions,[Options.DelimitedText]);
end;


initialization
  GlobalOptions:=TFppkgOptions.Create;
  CompilerOptions:=TCompilerOptions.Create;
  FPMakeCompilerOptions:=TCompilerOptions.Create;
finalization
  FreeAndNil(GlobalOptions);
  FreeAndNil(CompilerOptions);
  FreeAndNil(FPMakeCompilerOptions);
end.
