(*
    This file is part of Dxbx - a XBox emulator written in Delphi (ported over from cxbx)
    Copyright (C) 2007 Shadow_tj and other members of the development team.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)
unit uDxbxUtils;

interface

uses
  // Delphi
  Windows,
  SysUtils,
  Classes,
  Graphics,
  ShlObj, // SHGetSpecialFolderPath
  // Jedi
  JwaWinType,
  JwaNative, // NtQueryTimerResolution
  // 3rd Party
  JclWin32, // UNDNAME_COMPLETE
  JclPeImage, // UndecorateSymbolName
  // Dxbx
  uTypes;

const // instead of using uEmuD3D8Types :
  X_D3DFMT_A8R8G8B8 = $06; // 6, Swizzled
//  X_D3DFMT_X8R8G8B8 = $07; // 7, Swizzled
//  X_D3DFMT_P8 = $0B; // 11, Swizzled, 8-bit Palletized
  X_D3DFMT_DXT1 = $0C; // 12, Compressed, opaque/one-bit alpha
  X_D3DFMT_DXT2 = $0E;
  X_D3DFMT_DXT3 = $0E; // 14, Compressed, linear alpha
  X_D3DFMT_DXT4 = $0F;
  X_D3DFMT_DXT5 = $0F; // 15, Compressed, interpolated alpha

const
  NUMBER_OF_THUNKS = 379;

  DXBX_CONSOLE_DEBUG_FILENAME = 'DxbxDebug.txt';
  DXBX_KERNEL_DEBUG_FILENAME = 'KrnlDebug.txt';

  // Thread access rights
  THREAD_SET_CONTEXT = $0010; // See http://msdn.microsoft.com/en-us/library/ms686769(VS.85).aspx

  // Trick to check validity of GetFileAttributes - this bit should be off :
  FILE_ATTRIBUTE_INVALID = $10000000;

type
  EMU_STATE = (esNone, esFileOpen, esInvalidFile, esRunning);

  TDebugInfoType = (ditConsole, ditFile);
  EnumAutoConvert = (CONVERT_TO_MANUAL, CONVERT_TO_XBEPATH, CONVERT_TO_WINDOWSTEMP);

  TDebugMode = (dmNone, dmConsole, dmFile);

  TEntryProc = procedure();
  PEntryProc = ^TEntryProc;

  TSetXbePath = procedure(const Path: PAnsiChar); cdecl;

  TKernelThunkTable = array [0..NUMBER_OF_THUNKS - 1] of UIntPtr;
  PKernelThunkTable = ^TKernelThunkTable;

  TGetKernelThunkTable = function: PKernelThunkTable; cdecl;

  TLineCallback = function (aLinePtr: PAnsiChar; aLength: Integer; aData: Pointer): Boolean;

  TGenericCompare = function (const List: Pointer; const Index: Integer; const SearchData: Pointer): Integer;

  function GenericBinarySearch(const List: Pointer; const Count: Integer; const SearchData: Pointer; const Compare: TGenericCompare; out Index: Integer): Boolean;

type
  TListHelper = class helper for TList
  public
    function BinarySearch(const SearchData: Pointer; out Index: Integer; const Compare: TListSortCompare = nil): Boolean;
  end;

  TStreamHelper = class helper for TStream
  public
    procedure WriteString(const aString: AnsiString);
  end;

  TCustomMemoryStreamHelper = class helper for TCustomMemoryStream
  public
    function DataString: AnsiString;
  end;

  TPreallocatedMemoryStream = class(TCustomMemoryStream)
  public
    constructor Create(const aAddress: Pointer; aSize: Integer);
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

  TDxbxBits = class(TBits)
  public
    procedure ClearRange(aOffset, Range: Integer);
    procedure SetRange(aOffset, Range: Integer);
    function IsRangeClear(aOffset, Range: Integer): Boolean;
  end;

const
  BitsPerInt = SizeOf(Integer) * 8;
  BitsPerIntShift = 5;

type
  TBitEnum = 0..BitsPerInt - 1;
  TBitSet = set of TBitEnum;
  TBitArray = array[0..(MaxInt div BitsPerInt)-1] of TBitSet;
  PBitArray = ^TBitArray;

function SvnRevision: Integer;

procedure SetFS(const aNewFS: WORD);
function GetFS(): WORD;
function GetTIBEntry(const aOffset: DWORD): Pointer;
function GetTIBEntryWord(const aOffset: DWORD): WORD;
function GetTIB(): Pointer;

procedure ScanPCharLines(const aPChar: PAnsiChar; const aLineCallback: TLineCallback; const aCallbackData: Pointer);

function ScanHexByte(aLine: PAnsiChar; var Value: Integer): Boolean;
function ScanHexWord(aLine: PAnsiChar; var Value: Integer): Boolean;
function ScanHexDWord(aLine: PChar; var Value: Integer): Boolean;
function HexToIntDef(const aLine: string; const aDefault: Integer): Integer;

function Sscanf(const s: AnsiString; const fmt: AnsiString; const Pointers: array of Pointer): Integer;

function BytesToString(const aSize: Integer): string;

function TryReadLiteralString(const Ptr: PAnsiChar; const MaxStrLen: Integer = 260): UnicodeString;

function StrLenLimit(Src: PAnsiChar; MaxLen: Cardinal): Cardinal;
function StrLPas(const aPChar: PAnsiChar; const aMaxLength: Integer): AnsiString;

function iif(aTest: Boolean; const aTrue, aFalse: Integer): Integer; overload;
function iif(aTest: Boolean; const aTrue, aFalse: string): string; overload;

function GetEnvVarValue(const VarName: string; Dequote: Boolean = False): string;

function LocateExecutablePath(const aFileName: string): string;

function IsFile(const aFilePath: string): Boolean;
function IsFolder(const aFilePath: string): Boolean;

function FindFiles(const aFolder, aFileMask: TFileName; aFileNames: TStrings): Integer;

function StartsWithString(const aString, aPrefix: AnsiString): Boolean;
function StartsWithText(const aString, aPrefix: AnsiString): Boolean; overload;
function StartsWithText(const aString, aPrefix: UnicodeString): Boolean; overload;

function PAnsiCharMaxLenToString(Source: PAnsiChar; MaxLen: Integer): AnsiString;
function PWideCharMaxLenToString(Source: PWideChar; MaxLen: Integer): UnicodeString;

procedure Swap(var aElement1, aElement2); overload;
function RoundUp(dwValue, dwMult: DWord): DWord;

function FixInvalidFilePath(const aFilePath: string): string;

function RecapitalizeString(const aString: string): string;

function DebugModeToString(const aDebugMode: TDebugMode): string;

function IsValidHandle(const aHandle: LongWord): Boolean;
function IsValidLibraryHandle(const aHandle: LongWord): Boolean;

function GetLastErrorString: string;
function GetErrorString(const aError: DWord): string;

function PointerToString(const aPointer: Pointer): string;
function FloatToString(const aValue: float): string;

function QuadPart(const aValue: PLARGE_INTEGER): Int64;

type
  // Free interpretation of http://edn.embarcadero.com/article/29173
  TRGB32 = packed record
    B, G, R, A: Byte;
  end;
  PRGB32 = ^TRGB32;

  TRGB32Array = array [0..MaxInt div SizeOf(TRGB32)-1] of TRGB32;
  PRGB32Array = ^TRGB32Array;

  RGB32Scanlines = record
  private
    FScanLines: array of PRGB32Array;
    FWidth: Cardinal;
    function GetScanline(Row: Integer): PRGB32Array;
    function GetPixel(Col, Row: Integer): PRGB32;
    function GetHeight: Cardinal;
  public
    procedure Initialize(const aBitmap: TBitmap);

    property Scanlines[Row: Integer]: PRGB32Array read GetScanline; default;
    property Pixels[Col, Row: Integer]: PRGB32 read GetPixel;

    property Height: Cardinal read GetHeight;
    property Width: Cardinal read FWidth;
  end;
  PRGB32Scanlines = ^RGB32Scanlines;

type
  TRGB16 = WORD;
  PRGB16 = ^TRGB16;

  TRGB16Array = array [0..MaxInt div SizeOf(TRGB16)-1] of TRGB16;
  PRGB16Array = ^TRGB16Array;

  RGB16Scanlines = record
  private
    FScanLines: array of PRGB16Array;
    FWidth: Cardinal;
    function GetScanline(Row: Integer): PRGB16Array;
    function GetPixel(Col, Row: Integer): PRGB16;
    function GetHeight: Cardinal;
  public
    procedure Initialize(const aBitmap: TBitmap);

    property Scanlines[Row: Integer]: PRGB16Array read GetScanline; default;
    property Pixels[Col, Row: Integer]: PRGB16 read GetPixel;

    property Height: Cardinal read GetHeight;
    property Width: Cardinal read FWidth;
  end;
  PRGB16Scanlines = ^RGB16Scanlines;


function ReadS3TCFormatIntoBitmap(const aFormat: Byte; const aData: PBytes; const aDataSize: Cardinal; const aOutput: PRGB32Scanlines): Boolean;
function ReadSwizzledFormatIntoBitmap(const aFormat: Byte; const aData: PBytes; const aDataSize: Cardinal; const aOutput: PRGB32Scanlines): Boolean;
function ReadD3DTextureFormatIntoBitmap(const aFormat: Byte; const aData: PBytes; const aDataSize: Cardinal; const aOutput: PRGB32Scanlines): Boolean;

function GetDxbxBasePath: string;
function SymbolCacheFolder: string;

function SortObjects(List: TStringList; Index1, Index2: Integer): Integer;

function DxbxUnmangleSymbolName(const aStr: string): string;

type
  // Helper type to get access to cdecl varargs, code published by Barry Kelly on :
  // http://stackoverflow.com/questions/298373/how-can-a-function-with-varargs-retrieve-the-contents-of-the-stack\
  // For usage, see comments in implementation.
  RVarArgsReader = record
  private
    FArgPtr: IntPtr;
    class function Align(Ptr: IntPtr; Align: Integer): IntPtr; static;
  public
    constructor Create(LastArg: Pointer; Size: Integer);
    // Read bytes, signed words etc. using Int32
    // Make an unsigned version if necessary.
    function ReadInt32: Integer;
    // Exact floating-point semantics depend on C compiler.
    // Delphi compiler passes Extended as 10-byte float; most C
    // compilers pass all floating-point values as 8-byte floats.
    function ReadDouble: Double;
    function ReadExtended: Extended;
    function ReadPAnsiChar: PAnsiChar;
    procedure ReadArg(var Arg; Size: Integer);
  end;

const
  SymbolCacheFileExt = '.sym';

var
  DxbxBasePath: string;
  DxbxBasePathHandle: Handle;

  // Native folder for debug output files.
  DxbxDebugFolder: string = 'C:\'; // TODO -oDxbx : Make this configurable (and put something more sane in here)

const
  // Here we define the addresses of the native Windows timers :
  DxbxNtInterruptTime: PKSYSTEM_TIME = PKSYSTEM_TIME(MM_SHARED_USER_DATA_VA + USER_SHARED_DATA_INTERRUPT_TIME);
  DxbxNtSystemTime: PKSYSTEM_TIME = PKSYSTEM_TIME(MM_SHARED_USER_DATA_VA + USER_SHARED_DATA_SYSTEM_TIME);
  DxbxNtTickCountLowDeprecated: PDWORD = PDWORD(MM_SHARED_USER_DATA_VA + USER_SHARED_DATA_TICK_COUNT_LOW_DEPRECATED);
  DxbxNtTickCount: PKSYSTEM_TIME = PKSYSTEM_TIME(MM_SHARED_USER_DATA_VA + USER_SHARED_DATA_TICK_COUNT);

var
   // These two variables should stay constant, so they are determined just once
   // by calling DxbxGetTimerResultions() during unit initialization :
   DxbxMinimumResolution: ULONG;
   DxbxMaximumResolution: ULONG;
procedure ReadSystemTimeIntoLargeInteger(const aSystemTime: PKSYSTEM_TIME; const aLargeInteger: PLARGE_INTEGER);

implementation

var
  _SvnRevision: Integer = 0;

function SvnRevision: Integer;
var
  ResourceStream: TResourceStream;
  VerPtr: PAnsiChar;
begin
  Result := _SvnRevision;
  if Result > 0 then
    Exit;

  ResourceStream := TResourceStream.Create(LibModuleList.ResInstance, 'SvnRevision', RT_RCDATA);
  try
    VerPtr := PAnsiChar(ResourceStream.Memory);
    while VerPtr^ <> #0 do
    begin
      if VerPtr^ = #10 then
      begin
        Inc(Result);
        if (Result > 3) then
          Break;
      end
      else
        if  (Result = 3)
        and (VerPtr^ in ['0'..'9'])
        and (_SvnRevision < 100000) then
          _SvnRevision := _SvnRevision * 10 + Ord(VerPtr^) - Ord('0');

      Inc(VerPtr);
    end;

  finally
    // Unlock the resource :
    FreeAndNil(ResourceStream);
    Result := _SvnRevision;
  end;
end;

{$STACKFRAMES OFF}

procedure SetFS(const aNewFS: WORD);
asm
  MOV FS, aNewFS
end;

function GetFS(): WORD;
asm
  XOR EAX, EAX
  MOV AX, FS
end;

function GetTIBEntry(const aOffset: DWORD): Pointer;
asm
  MOV EAX, FS:[aOffset]
end;

function GetTIBEntryWord(const aOffset: DWORD): WORD;
asm
  MOV AX, FS:[aOffset]
end;

function GetTIB(): Pointer;
begin
  Result := GetTIBEntry({FS_Self=}$18);
end;

procedure ReadSystemTimeIntoLargeInteger(const aSystemTime: PKSYSTEM_TIME; const aLargeInteger: PLARGE_INTEGER);
begin
  repeat
    aLargeInteger.HighPart := aSystemTime.High1Time;
    aLargeInteger.LowPart := aSystemTime.LowPart;
  until aLargeInteger.HighPart = aSystemTime.High2Time;
end;

procedure DxbxGetTimerResultions;
// See http://www.digiater.nl/openvms/decus/vmslt97a/ntstuff/timer.txt
var
  CurrentResolution: ULONG;
begin
  NtQueryTimerResolution(@DxbxMinimumResolution, @DxbxMaximumResolution, @CurrentResolution);
end;

 {$STACKFRAMES ON}

function FixInvalidFilePath(const aFilePath: string): string;
var
  i: Integer;
begin
  Result := aFilePath;
  for i := 1 to Length(Result) do
  begin
    case AnsiChar(Result[i]) of
      #0..#31, #127:
        Result[i] := ' ';
      '/', '\':
        Result[i] := '_';
      ':':
        Result[i] := ';';
      '*':
        Result[i] := '�';
      '?':
        Result[i] := '�';
      '"':
        Result[i] := '�';
      '<':
        Result[i] := '�';
      '>':
        Result[i] := '�';
      '|':
        Result[i] := '�';
    end;
  end;
end;

function RecapitalizeString(const aString: string): string;

  procedure _ToUpper(aIndex: Integer);
  begin
    if CharInSet(Result[aIndex], ['a'..'z']) then
      Result[aIndex] := Char(Ord(Result[aIndex]) - $20);
  end;

  procedure _ToLower(aIndex, aEndIndex: Integer);
  begin
    while aIndex <= aEndIndex do
    begin
      if CharInSet(Result[aIndex], ['A'..'Z']) then
        Result[aIndex] := Char(Ord(Result[aIndex]) + $20);

      Inc(aIndex);
    end;
  end;

var
  i, j: Integer;
  NrOfChars: Integer;
  NrOfUppercase: Integer;
  DoOutput: Boolean;
begin
  // Start with input :
  Result := Trim(aString);

  // Insert spaces everywhere a uppercase follows a lowercase character :
  i := Length(Result);
  while i > 1 do
  begin
    if ( CharInSet(Result[i], ['A'..'Z']) and CharInSet(Result[i - 1], ['a'..'z']))
    or ( CharInSet(Result[i], ['0'..'9']) and CharInSet(Result[i - 1], [':'..'z']))
    or ( CharInSet(Result[i], [':'..'z']) and CharInSet(Result[i - 1], ['0'..'9'])) then
      Insert(' ', Result, i);

    Dec(i);
  end;

  // Count all characters (uppercase separately) :
  j := 1;
  NrOfChars := 0;
  NrOfUppercase := 0;
  for i := 1 to Length(Result) do
  begin
    DoOutput := (i = Length(Result));
    case AnsiChar(Result[i]) of
      '''':
        ; // Do nothing - ' can be part of a word

      'a'..'z':
        Inc(NrOfChars);

      'A'..'Z':
      begin
        Inc(NrOfChars);
        Inc(NrOfUppercase);
      end;
    else
      DoOutput := True;
    end;

    if DoOutput then
    begin
      while Result[j] = ' ' do
        Inc(j);
      
      // Very small words go to all-lowercase:
      if NrOfChars <= 2 then
        _ToLower(j, i)
      else
        // All-uppercase, up to 3 characters, stays that way :
        if (NrOfUpperCase = NrOfChars) and (NrOfChars <= 3) then
          // do nothing
        else
        begin
          // The rest goes to Camel Caps :
          _ToUpper(j);
          _ToLower(j + 1, i);
        end;

      j := i + 1;
      NrOfChars := 0;
      NrOfUppercase := 0;
    end;
  end; // for
end;

procedure Swap(var aElement1, aElement2);
var
  Tmp: Pointer;
begin
  Tmp := Pointer(aElement1);
  Pointer(aElement1) := Pointer(aElement2);
  Pointer(aElement2) := Tmp;
end;

// Round dwValue to the nearest multiple of dwMult
function RoundUp(dwValue, dwMult: DWord): DWord;
begin
  if dwMult = 0 then
    Result := dwValue
  else
    Result := dwValue - ((dwValue - 1) mod dwMult) + (dwMult - 1);
end;

function StartsWithString(const aString, aPrefix: AnsiString): Boolean;
begin
  Result := strncmp(PAnsiChar(aString), PAnsiChar(aPrefix), Length(aPrefix)) = 0;
end;

function StartsWithText(const aString, aPrefix: AnsiString): Boolean; // overload
begin
  Result := AnsiStrLIComp(PAnsiChar(aString), PAnsiChar(aPrefix), Length(aPrefix)) = 0;
end;

function StartsWithText(const aString, aPrefix: UnicodeString): Boolean; // overload
begin
  Result := AnsiStrLIComp(PWideChar(aString), PWideChar(aPrefix), Length(aPrefix)) = 0;
end;

// TODO : Other solutions are PCharToString(), StrLPas(), but definately not PAnsiChar()!
function PAnsiCharMaxLenToString(Source: PAnsiChar; MaxLen: Integer): AnsiString;
var
  ActualLen: Integer;
begin
  ActualLen := 0;
  if Assigned(Source) then
    while (ActualLen < MaxLen)
      and (Source[ActualLen] > #9) do // Anything below tab will be treated as end of string
        Inc(ActualLen);

  SetLength(Result, ActualLen);
  if ActualLen > 0 then
    memcpy(@Result[1], Source, ActualLen * SizeOf(AnsiChar));
end;

function PWideCharMaxLenToString(Source: PWideChar; MaxLen: Integer): UnicodeString;
var
  ActualLen: Integer;
begin
  ActualLen := 0;
  if Assigned(Source) then
    while (ActualLen < MaxLen)
      and (Source[ActualLen] > #9) do // Anything below tab will be treated as end of string
        Inc(ActualLen);

  SetLength(Result, ActualLen);
  if ActualLen > 0 then
    memcpy(@Result[1], Source, ActualLen * SizeOf(WideChar));
end;

function GetEnvVarValue(const VarName: string; Dequote: Boolean = False): string;
var
  BufSize: Integer;
begin
  // Get required buffer size (inc. terminal #0)
  BufSize := GetEnvironmentVariable(PChar(VarName), nil, 0);
  if BufSize > 0 then
  begin
    // Read env var value into result string
    SetLength(Result, BufSize - 1);
    GetEnvironmentVariable(PChar(VarName), PChar(Result), BufSize);

    if Dequote and CharInSet(Result[1], ['''', '"']) then
      Result := AnsiDequotedStr(Result, Result[1]);
  end
  else
    Result := '';
end;

function LocateExecutablePath(const aFileName: string): string;
var
  BufSize: Integer;
  FilePath: PChar;
begin
  // Get required buffer size (inc. terminal #0)
  BufSize := SearchPath(nil, PChar(aFileName), nil, 0, nil, {var}FilePath);
  if BufSize > 0 then
  begin
    SetLength(Result, BufSize - 1);
    SearchPath(nil, PChar(aFileName), nil, BufSize, PChar(Result), {var}FilePath);
  end
  else
    Result := '';
end;

function IsFile(const aFilePath: string): Boolean;
begin
  Result := (aFilePath <> '')
        and ((GetFileAttributes(PChar(aFilePath)) and (FILE_ATTRIBUTE_ARCHIVE or FILE_ATTRIBUTE_DIRECTORY)) = FILE_ATTRIBUTE_ARCHIVE);
end;

function IsFolder(const aFilePath: string): Boolean;
begin
  Result := (aFilePath <> '')
        and ((GetFileAttributes(PChar(aFilePath)) and (FILE_ATTRIBUTE_DIRECTORY or FILE_ATTRIBUTE_INVALID)) = FILE_ATTRIBUTE_DIRECTORY);
end;

function FindFiles(const aFolder, aFileMask: TFileName; aFileNames: TStrings): Integer;
var
  Status: Integer;
  SearchRec: TSearchRec;
begin
  with aFileNames do
  begin
    BeginUpdate;
    try
      Status := FindFirst(IncludeTrailingPathDelimiter(aFolder) + aFileMask, faAnyFile, SearchRec);
      while Status = 0 do
      begin
        if (SearchRec.Attr and faDirectory) = 0 then
          Add(IncludeTrailingPathDelimiter(aFolder) + SearchRec.Name);

        Status := FindNext(SearchRec);
      end;

      FindClose(SearchRec);
    finally
      EndUpdate;
    end;

    Result := Count;
  end;
end;

function _ScanAndAddHexDigit(var Value: Integer; const aHexDigit: AnsiChar): Boolean; overload;
begin
  Result := True;
  case aHexDigit of
    '0'..'9':
      Value := (Value * 16) + (Ord(aHexDigit) - Ord('0'));
    'A'..'F':
      Value := (Value * 16) + (Ord(aHexDigit) - Ord('A') + 10);
    'a'..'f':
      Value := (Value * 16) + (Ord(aHexDigit) - Ord('a') + 10);
  else
    Result := False;
  end;
end;

function _ScanAndAddHexDigit(var Value: Integer; const aHexDigit: WideChar): Boolean; overload;
begin
  Result := True;
  case aHexDigit of
    '0'..'9':
      Value := (Value * 16) + (Ord(aHexDigit) - Ord('0'));
    'A'..'F':
      Value := (Value * 16) + (Ord(aHexDigit) - Ord('A') + 10);
    'a'..'f':
      Value := (Value * 16) + (Ord(aHexDigit) - Ord('a') + 10);
  else
    Result := False;
  end;
end;

function _ScanHexDigits(aLine: PAnsiChar; var Value: Integer; Digits: Integer): Boolean; overload;
begin
  Value := 0;
  while (Digits > 0) and (aLine^ > #0) do
  begin
    Result := _ScanAndAddHexDigit(Value, aLine^);
    if not Result then
      Exit;

    Inc(aLine);
    Dec(Digits);
  end;

  Result := True;
end;

function _ScanHexDigits(aLine: PWideChar; var Value: Integer; Digits: Integer): Boolean; overload;
begin
  Value := 0;
  while (Digits > 0) and (aLine^ > #0) do
  begin
    Result := _ScanAndAddHexDigit(Value, aLine^);
    if not Result then
      Exit;

    Inc(aLine);
    Dec(Digits);
  end;

  Result := True;
end;

function ScanHexByte(aLine: PAnsiChar; var Value: Integer): Boolean;
begin
  Result := _ScanHexDigits(aLine, Value, 2);
end;

function ScanHexWord(aLine: PAnsiChar; var Value: Integer): Boolean;
begin
  Result := _ScanHexDigits(aLine, Value, 4);
end;

function ScanHexDWord(aLine: PChar; var Value: Integer): Boolean;
begin
  Result := _ScanHexDigits(aLine, Value, 8);
end;

function HexToIntDef(const aLine: string; const aDefault: Integer): Integer;
begin
  if not ScanHexDWord(PChar(aLine), Result) then
    Result := aDefault;
end;

procedure ScanPCharLines(const aPChar: PAnsiChar; const aLineCallback: TLineCallback; const aCallbackData: Pointer);
var
  p1, p2: PAnsiChar;
begin
  // Scan Lines:
  p1 := aPChar;
  while p1^ > #0 do
  begin
    // Scan this line until end of line (#0..#13) :
    p2 := p1;
    while p2^ > #13 do
      Inc(p2);

    // Handle this line :
    if not aLineCallback(p1, {Length=}p2-p1, aCallbackData) then
      Exit;

    // Step over to the start of the next line :
    p1 := p2 + 1;
    while p1^ in [#10, #13] do
      Inc(p1);
  end;
end;

function Sscanf(const s: AnsiString; const fmt: AnsiString; const Pointers: array of Pointer): Integer;
var
  i, j, n, m: Integer;
  s1: AnsiString;
  L: LongInt;
  X: Extended;

  function GetInt: Integer;
  begin
    s1 := '';
    while (n <= Length(s)) and (s[n] = ' ') do
      Inc(n);

    while (n <= Length(s))
      and (s[n] in ['0'..'9', '+', '-']) do
    begin
      s1 := s1 + s[n];
      Inc(n);
    end;

    Result := Length(s1); 
  end; 

  function GetFloat: Integer; 
  begin 
    s1 := ''; 
    while (n <= Length(s)) and (s[n] = ' ') do
      Inc(n);

    while (s[n] in ['0'..'9', '+', '-', '.', 'e', 'E'])
      and (Length(s) >= n) do
    begin
      s1 := s1 + s[n];
      Inc(n);
    end;

    Result := Length(s1);
  end;

  function GetString: Integer;
  begin
    s1 := '';
    while (n <= Length(s)) and (s[n] = ' ') do
      Inc(n);

    while (n <= Length(s)) and (s[n] <> ' ') do
    begin
      s1 := s1 + s[n];
      Inc(n);
    end;

    Result := Length(s1);
  end;

  function ScanStr(c: AnsiChar): Boolean;
  begin
    while (n <= Length(s)) and (s[n] <> c) do
      Inc(n);

    Inc(n);

    if (n <= Length(s)) then
      Result := True
    else
      Result := False;
  end; 

  function GetFmt: Integer; 
  begin 
    Result := -1; 

    while True do 
    begin
      while (m <= Length(fmt)) and (fmt[m] = ' ') do
        Inc(m);

      if m >= Length(fmt) then 
        break;

      if fmt[m] = '%' then
      begin 
        Inc(m); 
        case fmt[m] of
          'd': Result := vtInteger;
          'f': Result := vtExtended;
          's': Result := vtString;
        end;

        Inc(m);
        break;
      end;

      if (ScanStr(fmt[m]) = False) then
        break;

      Inc(m);
    end; 
  end; 

begin 
  n := 1; 
  m := 1; 
  Result := 0; 

  for i := 0 to High(Pointers) do 
  begin 
    j := GetFmt; 

    case j of 
      vtInteger: 
        begin 
          if GetInt > 0 then 
          begin 
            L := StrToInt(string(s1));
            Move(L, Pointers[i]^, SizeOf(LongInt));
            Inc(Result);
          end
          else
            break;
        end;

      vtExtended:
        begin
          if GetFloat > 0 then
          begin
            X := StrToFloat(string(s1));
            Move(X, Pointers[i]^, SizeOf(Extended));
            Inc(Result); 
          end 
          else 
            break;
        end; 

      vtString: 
        begin 
          if GetString > 0 then 
          begin 
            Move(s1, Pointers[i]^, Length(s1) + 1); 
            Inc(Result);
          end
          else
            break;
        end;
    else
      break;
    end;
  end;
end;

function BytesToString(const aSize: Integer): string;
begin
  Result := FormatFloat(',0', aSize) + ' bytes';
end;

function TryReadLiteralString(const Ptr: PAnsiChar; const MaxStrLen: Integer = 260): UnicodeString;
const
  // Here the (rather arbitrary) steering parameters :
  MinStrLen = 3;
  PrintableChars = [' '..#127];
var
  i: Integer;
  NrAnsiChars: Integer;
  NrWideZeros: Integer;
begin
  Result := '';

  NrAnsiChars := 0;
  NrWideZeros := 0;

  // Dected as much string-contents as we can :
  i := 0;
  while i < MaxStrLen do
  try
    if Ptr[i] = #0 then
    begin
      // Zero's on odd position could indicate an UTF-16LE string :
      if Odd(i) then
      begin
        Inc(NrWideZeros);
        Inc(i);
        continue;
      end;

      // The string ends on a #0 :
      break;
    end;

    // It's no longer a string when it contains non-printable characters :
    if not (Ptr[i] in PrintableChars) then
      if Ptr[i-1] = #0 then
        Break
      else
        Exit;

    Inc(NrAnsiChars);
    Inc(i);
  except
    // Save-guard against illegal memory-accesses :
    Exit;
  end;

  // It's no string when it's too short :
  if NrAnsiChars < MinStrLen then
    Exit;

  if Abs(NrAnsiChars - NrWideZeros) <= 1 then
    Result := '"' + Copy(PWideChar(Ptr), 0, NrAnsiChars) + '"'
  else
    Result := '"' + UnicodeString(Copy(Ptr, 0, NrAnsiChars)) + '"';
end;

// Stupid Delphi has this hidden in the implementation section of SysUtils;
// StrLenLimit:  Scan Src for a null terminator up to MaxLen bytes
function StrLenLimit(Src: PAnsiChar; MaxLen: Cardinal): Cardinal;
begin
  if Src = nil then
  begin
    Result := 0;
    Exit;
  end;
  Result := MaxLen;
  while (Src^ <> #0) and (Result > 0) do
  begin
    Inc(Src);
    Dec(Result);
  end;
  Result := MaxLen - Result;
end;

function StrLPas(const aPChar: PAnsiChar; const aMaxLength: Integer): AnsiString;
var
  Len: Integer;
begin
  Len := StrLenLimit(aPChar, aMaxLength);
  SetLength(Result, Len);
  if Len > 0 then
    Move(aPChar[0], Result[1], Len * SizeOf(AnsiChar));
end;

function iif(aTest: Boolean; const aTrue, aFalse: Integer): Integer; overload;
begin
  if aTest then
    Result := aTrue
  else
    Result := aFalse;
end;

function iif(aTest: Boolean; const aTrue, aFalse: string): string; overload;
begin
  if aTest then
    Result := aTrue
  else
    Result := aFalse;
end;

function PointerToString(const aPointer: Pointer): string;
begin
  Result := IntToHex(IntPtr(aPointer), SizeOf(IntPtr) * 2);
end;

function FloatToString(const aValue: float): string;
begin
  Result := FormatFloat('0.0', aValue); // TODO : Speed this up by avoiding Single>Extended cast & generic render code.
end;

function QuadPart(const aValue: PLARGE_INTEGER): Int64;
begin
  if Assigned(aValue) then
    Result := aValue.QuadPart
  else
    Result := 0;
end;

function DebugModeToString(const aDebugMode: TDebugMode): string;
begin
  case aDebugMode of
    dmNone: Result := 'DM_NONE';
    dmConsole: Result := 'DM_CONSOLE';
    dmFile: Result := 'DM_FILE';
  else
    Result := '?Unknown?';
  end;
end;

function IsValidHandle(const aHandle: LongWord): Boolean;
begin
  Result := (aHandle <> INVALID_HANDLE_VALUE);
end;

// (Safe)LoadLibrary returns 32 or greater on a succesfull call.
// See http://support.microsoft.com/kb/142814 for details.
function IsValidLibraryHandle(const aHandle: LongWord): Boolean;
begin
  Result := IsValidHandle(aHandle) and (aHandle >= 32);
end;

function GetLastErrorString: string;
begin
  Result := GetErrorString(GetLastError);
end;

function GetErrorString(const aError: DWord): string;
begin
  Result := SysErrorMessage(aError);
  if Result = '' then
    Result := 'No description for error #' + IntToStr(aError)
  else
    Result := Result + ' (#' + IntToStr(aError) + ')';
end;

// Note : This is a modified copy of TStringList.Find(), which is
// the only binary search method in the entire Delphi RTL+VCL.
function GenericBinarySearch(const List: Pointer; const Count: Integer; const SearchData: Pointer; const Compare: TGenericCompare; out Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := Compare(List, I, SearchData);
    if C < 0 then
      L := I + 1
    else
    begin
      if C = 0 then
      begin
        Result := True;
        L := I;
        Break;
      end;

      H := I - 1;
    end;
  end;

  {out}Index := L;
end; // GenericBinarySearch

{ TListHelper }

function InternalListCompare(const List: TList; const Index: Integer; const SearchData: Pointer): Integer;
begin
  Result := IntPtr(List[Index]) - IntPtr(SearchData);
end;

type
  PCompareList = ^RCompareList;
  RCompareList = record
    Compare: TListSortCompare;
    List: TList;
  end;

function ExternalListCompare(const State: PCompareList; const Index: Integer; const SearchData: Pointer): Integer;
begin
  Result := State.Compare(State.List[Index], SearchData);
end;

function TListHelper.BinarySearch(const SearchData: Pointer; out Index: Integer; const Compare: TListSortCompare = nil): Boolean;
var
  State: RCompareList;
begin
  if @Compare = nil then
    Result := GenericBinarySearch({List=}Self, Count, SearchData, @InternalListCompare, {out}Index)
  else
  begin
    State.Compare := Compare;
    State.List := Self;
    Result := GenericBinarySearch({List=}@State, Count, SearchData, @ExternalListCompare, {out}Index);
  end;
end;

{ TStreamHelper }

procedure TStreamHelper.WriteString(const aString: AnsiString);
begin
  if Length(aString) > 0 then
    Write(aString[1], Length(aString));
end;

{ TCustomMemoryStreamHelper }

function TCustomMemoryStreamHelper.DataString: AnsiString;
begin
  SetLength(Result, Size);
  Position := 0;
  Read(Result[1], Size);
end;

{ TPreallocatedMemoryStream }

constructor TPreallocatedMemoryStream.Create(const aAddress: Pointer; aSize: Integer);
begin
  inherited Create;

  SetPointer(aAddress, aSize);
end;

function TPreallocatedMemoryStream.Write(const Buffer; Count: Integer): Longint;
var
  Pos: Longint;
begin
  if (Position >= 0) and (Count >= 0) then
  begin
    Pos := Position + Count;
    if Pos > 0 then
    begin
      if Pos > Size then
      begin
        Pos := Size;
        Count := Pos - Position;
      end;
      System.Move(Buffer, Pointer(Longint(Memory) + Position)^, Count);
      Position := Pos;
      Result := Count;
      Exit;
    end;
  end;
  
  Result := 0;
end;

{ RGB32Scanlines }

procedure RGB32Scanlines.Initialize(const aBitmap: TBitmap);
var
  y: Integer;
begin
  Assert(Assigned(aBitmap) and (aBitmap.PixelFormat = pf32bit));

  FWidth := aBitmap.Width;
  SetLength(FScanLines, aBitmap.Height);
  for y := 0 to aBitmap.Height - 1 do
    FScanlines[y] := aBitmap.Scanline[y];
end;

function RGB32Scanlines.GetScanline(Row: Integer): PRGB32Array;
begin
  Result := FScanlines[Row];
end;

function RGB32Scanlines.GetPixel(Col, Row: Integer): PRGB32;
begin
  Result := @(FScanlines[Row][Col]);
end;

function RGB32Scanlines.GetHeight: Cardinal;
begin
  Result := Length(FScanlines);
end;

{ RGB16Scanlines }

procedure RGB16Scanlines.Initialize(const aBitmap: TBitmap);
var
  y: Integer;
begin
  Assert(Assigned(aBitmap) and (aBitmap.PixelFormat = pf16bit));

  FWidth := aBitmap.Width;
  SetLength(FScanLines, aBitmap.Height);
  for y := 0 to aBitmap.Height - 1 do
    FScanlines[y] := aBitmap.Scanline[y];
end;

function RGB16Scanlines.GetScanline(Row: Integer): PRGB16Array;
begin
  Result := FScanlines[Row];
end;

function RGB16Scanlines.GetPixel(Col, Row: Integer): PRGB16;
begin
  Result := @(FScanlines[Row][Col]);
end;

function RGB16Scanlines.GetHeight: Cardinal;
begin
  Result := Length(FScanlines);
end;

//

// Unswizzle a texture. (Only works for 32bit, with power of 2 width and height.)
// Code is loosly based on XBMC guilib\DirectXGraphics.cpp
// Delphi translation and speed improvements by PatrickvL
function ReadSwizzledFormatIntoBitmap(
  const aFormat: Byte;
  const aData: PBytes;
  const aDataSize: Cardinal;
  const aOutput: PRGB32Scanlines): Boolean;

  // Generic swizzle function, usable for both x and y dimensions.
  // When passing x, Max should be 2*height, and Shift should be 0
  // When passing y, Max should be width, and Shift should be 1
  function _Swizzle(const Value, Max, Shift: Cardinal): Cardinal;
  begin
    if Value < Max then
      Result := Value
    else
      Result := Value mod Max;

    // The following is based on http://graphics.stanford.edu/~seander/bithacks.html#InterleaveBMN :
                                                        // --------------------------------11111111111111111111111111111111
    Result := (Result or (Result shl 8)) and $00FF00FF; // 0000000000000000111111111111111100000000000000001111111111111111
    Result := (Result or (Result shl 4)) and $0F0F0F0F; // 0000111100001111000011110000111100001111000011110000111100001111
    Result := (Result or (Result shl 2)) and $33333333; // 0011001100110011001100110011001100110011001100110011001100110011
    Result := (Result or (Result shl 1)) and $55555555; // 0101010101010101010101010101010101010101010101010101010101010101

    Result := Result shl Shift; // y counts twice :        1010101010101010101010101010101010101010101010101010101010101010

    if Value >= Max then
      Inc(Result, (Value div Max) * Max * Max shr (1 - Shift)); // x halves this
  end;

var
  height, width: Cardinal;
  xswizzle: array of Cardinal;
  x, y, sy: Cardinal;
  yscanline: PRGB32Array;
begin
  // Sanity checks :
  Result := (aFormat in [X_D3DFMT_A8R8G8B8])
        and Assigned(aData)
        and (aDataSize > 0)
        and Assigned(aOutput)
        and (aOutput.Height > 0)
        and (aOutput.Width > 0);
  if not Result then
    Exit;

  height := aOutput.Height;
  width := aOutput.Width;

  // Precalculate x-swizzle :
  SetLength(xswizzle, width);
  if width > 0 then // Dxbx addition, to prevent underflow
  for x := 0 to width - 1 do
    xswizzle[x] := _Swizzle(x, {Max=}(height * 2), {Shift=}0);

  // Loop over all lines :
  if height > 0 then // Dxbx addition, to prevent underflow
  for y := 0 to height - 1 do
  begin
    // Calculate y-swizzle :
    sy := _Swizzle(y, {Max=}width, {Shift=}1);

    // Copy whole line in one go (using pre-calculated x-swizzle) :
    yscanline := aOutput.Scanlines[y];
    if width > 0 then // Dxbx addition, to prevent underflow
    for x := 0 to width - 1 do
      yscanline[x] := PRGB32Array(aData)[xswizzle[x] + sy];
  end; // for y
end; // ReadSwizzledFormatIntoBitmap

// Official spec : http://www.opengl.org/registry/specs/EXT/texture_compression_s3tc.txt
function ReadS3TCFormatIntoBitmap(
  const aFormat: Byte;
  const aData: PBytes;
  const aDataSize: Cardinal;
  const aOutput: PRGB32Scanlines): Boolean;
var
  color: array [0..3] of Word;
  color32b: array [0..4] of TRGB32;
  r, g, b, r1, g1, b1, pixelmap: DWord;
  j, k, p, x, y: Cardinal;
begin
  // Sanity checks :
  Result := (aFormat in [X_D3DFMT_DXT1, X_D3DFMT_DXT3, X_D3DFMT_DXT5])
        and Assigned(aData)
        and (aDataSize > 0)
        and Assigned(aOutput)
        and (aOutput.Height > 0)
        and (aOutput.Width > 0);
  if not Result then
    Exit;

  // Loop over all input data :
  j := 0;
  k := 0;
  while j < aDataSize do
  try
    // Skip X_D3DFMT_DXT3 and X_D3DFMT_DXT5 alpha data for now :
    if aFormat <> X_D3DFMT_DXT1 then
      Inc(j, 8);

    // Read two 16-bit pixels (let's call them A and B) :
    color[0] := (aData[j + 0] shl 0)
              + (aData[j + 1] shl 8);

    color[1] := (aData[j + 2] shl 0)
              + (aData[j + 3] shl 8);

    // Read 5+6+5 bit color channels and convert them to 8+8+8 bit :
    r := ((color[0] shr 11) and 31) * 255 div 31;
    g := ((color[0] shr  5) and 63) * 255 div 63;
    b := ((color[0]       ) and 31) * 255 div 31;

    r1 := ((color[1] shr 11) and 31) * 255 div 31;
    g1 := ((color[1] shr  5) and 63) * 255 div 63;
    b1 := ((color[1]       ) and 31) * 255 div 31;

    // Build first half of RGB32 color map :
    color32b[0].R := r;
    color32b[0].G := g;
    color32b[0].B := b;

    color32b[1].R := r1;
    color32b[1].G := g1;
    color32b[1].B := b1;

    // Build second half of RGB32 color map :
    if color[0] > color[1] then
    begin
      // Make up 2 new colors, 1/3 A + 2/3 B and 2/3 A + 1/3 B :
      color32b[2].R := (r + r + r1 + 2) div 3;
      color32b[2].G := (g + g + g1 + 2) div 3;
      color32b[2].B := (b + b + b1 + 2) div 3;

      color32b[3].R := (r + r1 + r1 + 2) div 3;
      color32b[3].G := (g + g1 + g1 + 2) div 3;
      color32b[3].B := (b + b1 + b1 + 2) div 3;
    end
    else
    begin
      // Make up one new color : 1/2 A + 1/2 B :
      color32b[2].R := (r + r1) div 2;
      color32b[2].G := (g + g1) div 2;
      color32b[2].B := (b + b1) div 2;

      color32b[3].R := 0;
      color32b[3].G := 0;
      color32b[3].B := 0;
    end;

    x := (k div 2) mod aOutput.Width;
    y := (k div 2) div aOutput.Width * 4;

    pixelmap := (aData[j + 4] shl 0)
              + (aData[j + 5] shl 8)
              + (aData[j + 6] shl 16)
              + (aData[j + 7] shl 24);

    for p := 0 to 16-1 do
    begin
      aOutput.Pixels[x + {xo=}(p and 3), y + {yo=}(p shr 2)]^ := color32b[pixelmap and 3];
      pixelmap := pixelmap shr 2;
    end;

    Inc(j, 8);
    Inc(k, 8); // Increase 4x4 pixel block offset
  except
    Exit; // ignore exception for now - has something to do with alpha-channel data being incorrectly skipped
  end; // while
end; // ReadS3TCFormatIntoBitmap

function ReadD3DTextureFormatIntoBitmap(
  const aFormat: Byte;
  const aData: PBytes;
  const aDataSize: Cardinal;
  const aOutput: PRGB32Scanlines): Boolean;
begin
  case aFormat of
    X_D3DFMT_DXT1,
    //X_D3DFMT_DXT2,
    X_D3DFMT_DXT3,
    //X_D3DFMT_DXT4,
    X_D3DFMT_DXT5:
      // Read the compressed texture into the bitmap :
      Result := ReadS3TCFormatIntoBitmap(aFormat, aData, aDataSize, aOutput);

    X_D3DFMT_A8R8G8B8:
      // Read the swizzled texture into the bitmap :
      Result := ReadSwizzledFormatIntoBitmap(aFormat, aData, aDataSize, aOutput);

  else
    Result := False;
  end;
end;

function GetDxbxBasePath: string;
begin
  SetLength(Result, MAX_PATH);
  SHGetSpecialFolderPath(0, @(Result[1]), CSIDL_APPDATA, True);
  SetLength(Result, StrLen(PChar(@Result[1])));
  Result := Result + '\Dxbx';
end;

function SymbolCacheFolder: string;
begin
  Result := GetDxbxBasePath + '\SymbolCache\';
end;

function SortObjects(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := IntPtr(List.Objects[Index1]) - IntPtr(List.Objects[Index2]);
  if Result = 0 then
    Result := StrComp(PChar(List.Strings[Index1]), PChar(List.Strings[Index2]));
end;

// Do our own demangling
function DxbxUnmangleSymbolName(const aStr: string): string;
var
  UnmangleFlags: DWord;
  i: Integer;
begin
  if aStr = '' then
    Exit;

  Result := aStr;

  // Check if the symbol starts with an underscore ('_') or '@':
  case Result[1] of
    '?':
      begin
        UnmangleFlags := 0
                      // UNDNAME_COMPLETE               // Enable full undecoration
                      or UNDNAME_NO_LEADING_UNDERSCORES // Remove leading underscores from MS extended keywords
                      or UNDNAME_NO_MS_KEYWORDS         // Disable expansion of MS extended keywords
                      or UNDNAME_NO_FUNCTION_RETURNS    // Disable expansion of return type for primary declaration
                      or UNDNAME_NO_ALLOCATION_MODEL    // Disable expansion of the declaration model
                      or UNDNAME_NO_ALLOCATION_LANGUAGE // Disable expansion of the declaration language specifier
                      or UNDNAME_NO_MS_THISTYPE         // NYI Disable expansion of MS keywords on the 'this' type for primary declaration
                      or UNDNAME_NO_CV_THISTYPE         // NYI Disable expansion of CV modifiers on the 'this' type for primary declaration
                      or UNDNAME_NO_THISTYPE            // Disable all modifiers on the 'this' type
                      or UNDNAME_NO_ACCESS_SPECIFIERS   // Disable expansion of access specifiers for members
                      or UNDNAME_NO_THROW_SIGNATURES    // Disable expansion of 'throw-signatures' for functions and pointers to functions
                      or UNDNAME_NO_MEMBER_TYPE         // Disable expansion of 'static' or 'virtual'ness of members
                      or UNDNAME_NO_RETURN_UDT_MODEL    // Disable expansion of MS model for UDT returns
                      or UNDNAME_32_BIT_DECODE          // Undecorate 32-bit decorated names
                      or UNDNAME_NAME_ONLY              // Crack only the name for primary declaration;
                      or UNDNAME_NO_ARGUMENTS           // Don't undecorate arguments to function
                      or UNDNAME_NO_SPECIAL_SYMS        // Don't undecorate special names (v-table, vcall, vector xxx, metatype, etc)
                      ;

        // Do Microsoft symbol demangling :
        if not UndecorateSymbolName(aStr, {var}Result, UnmangleFlags) then
          Result := aStr;
      end;
    '_', '@':
    begin
      // Remove this leading character :
      Delete(Result, 1, 1);
      // Replace all following underscores with a dot ('.') :
      Result := StringReplace(Result, '_', '.', [rfReplaceAll]);
    end;
  end;

  // Remove everything from '@' onward :
  i := Pos('@', Result);
  if i > 1 then
    Delete(Result, i, MaxInt);

  // Replace '::' with '.' :
  Result := StringReplace(Result, '::', '.', [rfReplaceAll]);
end; // DxbxUnmangleSymbolName

{ RVarArgsReader }

constructor RVarArgsReader.Create(LastArg: Pointer; Size: Integer);
begin
  FArgPtr := IntPtr(LastArg);
  // 32-bit x86 stack is generally 4-byte aligned
  FArgPtr := Align(FArgPtr + Size, 4);
end;

class function RVarArgsReader.Align(Ptr: IntPtr; Align: Integer): IntPtr;
begin
  Result := (Ptr + Align - 1) and not (Align - 1);
end;

function RVarArgsReader.ReadInt32: Integer;
begin
  ReadArg(Result, SizeOf(Integer));
end;

function RVarArgsReader.ReadDouble: Double;
begin
  ReadArg(Result, SizeOf(Double));
end;

function RVarArgsReader.ReadExtended: Extended;
begin
  ReadArg(Result, SizeOf(Extended));
end;

function RVarArgsReader.ReadPAnsiChar: PAnsiChar;
begin
  ReadArg(Result, SizeOf(PAnsiChar));
end;

procedure RVarArgsReader.ReadArg(var Arg; Size: Integer);
begin
  Move(PByte(FArgPtr)^, Arg, Size);
  FArgPtr := Align(FArgPtr + Size, 4);
end;

(*
// Usage of RVarArgsReader :

// Declare a function type with 'cdecl varargs' calling convention :
type
  PDump = procedure(const types: string) cdecl varargs;

// Define a variable that points to that special function type,
// and direct it to an actual implementation :
var
  MyDump: PDump = @Dump;

// Implement the function without the 'varargs' directive,
// and instead access the varargs with a 'RVarArgsReader' :
procedure Dump(const types: string); cdecl;
var
  ap: RVarArgsReader;
  cp: PChar;
begin
  cp := PChar(types);
  ap := RVarArgsReader.Create(@types, SizeOf(string));
  while True do
  begin
    case cp^ of
      #0:
      begin
        Writeln;
        Exit;
      end;

      'i': Write(ap.ReadInt32, ' ');
      'd': Write(ap.ReadDouble, ' ');
      'e': Write(ap.ReadExtended, ' ');
      's': Write(ap.ReadPChar, ' ');
    else
      Writeln('Unknown format');
      Exit;
    end;
    Inc(cp);
  end;
end;

procedure ExampleVarArgCalls;

  function AsDouble(e: Extended): Double;
  begin
    Result := e;
  end;

  function AsSingle(e: Extended): Single;
  begin
    Result := e;
  end;

begin
  MyDump('iii', 10, 20, 30);
  MyDump('sss', 'foo', 'bar', 'baz');

  // Looks like Delphi passes Extended in byte-aligned
  // stack offset, very strange; thus this doesn't work.
  MyDump('e', 2.0);
  // These two are more reliable.
  MyDump('d', AsDouble(2));
  // Singles passed as 8-byte floats.
  MyDump('d', AsSingle(2));
end;
*)

{ TDxbxBits }

type
  RBits_PrivateAccess = record
    ClassType: TClass;
    FSize: Integer;
    FBits: PDWORDs; // Originally declared as Pointer, but used as PBitArray
  end;
  TBits_PrivateAccess = ^RBits_PrivateAccess;

// TODO TDxbxBits : Split up our bit access in 3 stages; first handling the lead DWORD,
// then all full DWORDs and finally the trailing DWORD, to prevent many per-bit loops.

procedure TDxbxBits.ClearRange(aOffset, Range: Integer);
begin
  if aOffset + Range > Size then
    Bits[Size+1]; // Triggers Error();

  while Range > 0 do
  begin
    // Can we work with whole TBitSet's at a time?
    if  (Range >= BitsPerInt)
    and (aOffset and (BitsPerInt - 1) = 0) then
    begin
      TBits_PrivateAccess(Self).FBits[aOffset shr BitsPerIntShift] := 0;
      Dec(Range, BitsPerInt);
      Inc(aOffset, BitsPerInt);
    end
    else
    begin
      Bits[aOffset] := False;
      Dec(Range, 1);
      Inc(aOffset, 1);
    end;
  end;
end;

procedure TDxbxBits.SetRange(aOffset, Range: Integer);
begin
  if aOffset + Range > Size then
    Bits[Size+1]; // Triggers Error();

  while Range > 0 do
  begin
    // Can we work with whole TBitSet's at a time?
    if  (Range >= BitsPerInt)
    and (aOffset and (BitsPerInt - 1) = 0) then
    begin
      TBits_PrivateAccess(Self).FBits[aOffset shr BitsPerIntShift] := High(DWORD);
      Dec(Range, BitsPerInt);
      Inc(aOffset, BitsPerInt);
    end
    else
    begin
      Bits[aOffset] := True;
      Dec(Range, 1);
      Inc(aOffset, 1);
    end;
  end;
end;

function TDxbxBits.IsRangeClear(aOffset, Range: Integer): Boolean;
begin
  Result := False;
  if aOffset + Range > Size then
    Bits[Size+1]; // Triggers Error();

  while Range > 0 do
  begin
    // Can we work with whole TBitSet's at a time?
    if  (Range >= BitsPerInt)
    and (aOffset and (BitsPerInt - 1) = 0) then
    begin
      if TBits_PrivateAccess(Self).FBits[aOffset shr BitsPerIntShift] <> 0 then
        Exit;

      Dec(Range, BitsPerInt);
      Inc(aOffset, BitsPerInt);
    end
    else
    begin
      if Bits[aOffset] then
        Exit;

      Dec(Range, 1);
      Inc(aOffset, 1);
    end;
  end;

  Result := True;
end;

initialization

  DxbxGetTimerResultions;

end.

