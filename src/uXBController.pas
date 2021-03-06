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

unit uXBController;

interface

{$INCLUDE Dxbx.inc}

uses
  // Delphi
    Windows
  , SysUtils
  , Classes
  // Jedi Win32API
  , JwaWinType
  // DirectX
  , DirectInput
  , Direct3D
  , XInput
  // Dxbx
  , uTypes
  , uError
  , uDxbxUtils
  , uLog
  , uEmuD3D8Types
  ;

type
  LPCDIDEVICEOBJECTINSTANCE = TDIDeviceObjectInstanceA;
  LPCDIDEVICEINSTANCE = TDIDeviceInstanceA;


// Moved from uEmuXapi.pas, to prevent circular references :
type _XINPUT_GAMEPAD = record
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
    wButtons: Word;
    bAnalogButtons: array [0..8-1] of Byte;
    sThumbLX: SHORT;
    sThumbLY: SHORT;
    sThumbRX: SHORT;
    sThumbRY: SHORT;
  end; // size = 18 (as in Cxbx)
  XINPUT_GAMEPAD = _XINPUT_GAMEPAD;
  PXINPUT_GAMEPAD = ^XINPUT_GAMEPAD;

type _XINPUT_STATE = record
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
    dwPacketNumber: DWord;
    Gamepad: XINPUT_GAMEPAD;
  end; // size = 24 (as in Cxbx)
  XINPUT_STATE = _XINPUT_STATE;
  PXINPUT_STATE = ^XINPUT_STATE;


type // Declared before usage
  // DirectInput Enumeration Types
  XBCtrlState = (
    XBCTRL_STATE_NONE, // = 0,
    XBCTRL_STATE_CONFIG,
    XBCTRL_STATE_LISTEN
  );


// Xbox Controller Object IDs
type XBCtrlObject = (
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
    // Analog Axis
    XBCTRL_OBJECT_LTHUMBPOSX, // = 0
    XBCTRL_OBJECT_LTHUMBNEGX,
    XBCTRL_OBJECT_LTHUMBPOSY,
    XBCTRL_OBJECT_LTHUMBNEGY,
    XBCTRL_OBJECT_RTHUMBPOSX,
    XBCTRL_OBJECT_RTHUMBNEGX,
    XBCTRL_OBJECT_RTHUMBPOSY,
    XBCTRL_OBJECT_RTHUMBNEGY,
    // Analog Buttons
    XBCTRL_OBJECT_A,
    XBCTRL_OBJECT_B,
    XBCTRL_OBJECT_X,
    XBCTRL_OBJECT_Y,
    XBCTRL_OBJECT_BLACK,
    XBCTRL_OBJECT_WHITE,
    XBCTRL_OBJECT_LTRIGGER,
    XBCTRL_OBJECT_RTRIGGER,
    // Digital Buttons
    XBCTRL_OBJECT_DPADUP,
    XBCTRL_OBJECT_DPADDOWN,
    XBCTRL_OBJECT_DPADLEFT,
    XBCTRL_OBJECT_DPADRIGHT,
    XBCTRL_OBJECT_BACK,
    XBCTRL_OBJECT_START,
    XBCTRL_OBJECT_LTHUMB,
    XBCTRL_OBJECT_RTHUMB);

const
  // Total number of components
  XBCTRL_OBJECT_COUNT = (Ord(High(XBCtrlObject)) - Ord(Low(XBCtrlObject)) + 1);

// Maximum number of devices allowed
const XBCTRL_MAX_DEVICES = XBCTRL_OBJECT_COUNT;


// Xbox Controller Object Config
type XBCtrlObjectCfg = record
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
  dwDevice: int; // offset into m_InputDevice
  dwInfo: int; // extended information, depending on dwFlags
  dwFlags: int; // flags explaining the data format
end; // size = 12 (as in Cxbx)

// class: XBController
type XBController = object(Error)
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
  public
    procedure Initialize();
    procedure Finalize();
    // Registry Load/Save
    procedure Load(szRegistryKey: P_char);
    procedure Save(szRegistryKey: P_char);
    // Configuration
    procedure ConfigBegin(ahwnd: HWND; object_: XBCtrlObject);
    function ConfigPoll(var szStatus: string): _bool; // true if polling detected a change
    procedure ConfigEnd();
    // Listening
    procedure ListenBegin(hwnd: HWND);
    procedure ListenPoll(Controller: PXINPUT_STATE);
    procedure ListenEnd();
    // DirectInput Init / Cleanup
    procedure DInputInit(ahwnd: HWND);
    procedure DInputCleanup();
    // Check if a device is currently in the configuration
    function DeviceIsUsed(szDeviceName: P_char): _bool;
  private
    // Object Mapping
    procedure Map(aobject: XBCtrlObject; szDeviceName: P_char; dwInfo: int; dwFlags: int);
    // Find the look-up value for a DeviceName (creating if needed)
    function Insert(szDeviceName: P_char): int;
    // Update the object lookup offsets for a device
    procedure ReorderObjects(szDeviceName: P_char; pos: int);
    // Controller and Objects Enumeration
    function EnumGameCtrlCallback(var lpddi: TDIDeviceInstanceA): BOOL;
    function EnumObjectsCallback(lpddoi: LPCDIDEVICEOBJECTINSTANCE): BOOL;
  private
    // Device Names
    m_DeviceName: array [0..XBCTRL_MAX_DEVICES - 1] of array [0..260-1] of _char;
    // Object Configuration
    m_ObjectConfig: array [XBCtrlObject] of XBCtrlObjectCfg;
    // DirectInput
    m_pDirectInput8: IDIRECTINPUT8;
    // DirectInput Devices
    m_InputDevice: array [0..XBCTRL_MAX_DEVICES - 1] of record
      m_Device: IDIRECTINPUTDEVICE8;
      m_Flags: int;
    end;

    // Current State
    m_CurrentState: XBCtrlState;
    // Config State Variables
    lPrevMouseX, lPrevMouseY, lPrevMouseZ: LONG;
    CurConfigObject: XBCtrlObject;
    // Etc State Variables
    m_dwInputDeviceCount: int;
    m_dwCurObject: int;
  end; // size = 6760 (as in Cxbx)
  PXBController = ^XBController;

// Offsets into analog button array
const
  XINPUT_GAMEPAD_A = 0;
  XINPUT_GAMEPAD_B = 1;
  XINPUT_GAMEPAD_X = 2;
  XINPUT_GAMEPAD_Y = 3;
  XINPUT_GAMEPAD_BLACK = 4;
  XINPUT_GAMEPAD_WHITE = 5;
  XINPUT_GAMEPAD_LEFT_TRIGGER = 6;
  XINPUT_GAMEPAD_RIGHT_TRIGGER = 7;

// Masks for digital buttons
const
  XINPUT_GAMEPAD_DPAD_UP = $00000001;
  XINPUT_GAMEPAD_DPAD_DOWN = $00000002;
  XINPUT_GAMEPAD_DPAD_LEFT = $00000004;
  XINPUT_GAMEPAD_DPAD_RIGHT = $00000008;
  XINPUT_GAMEPAD_START = $00000010;
  XINPUT_GAMEPAD_BACK = $00000020;
  XINPUT_GAMEPAD_LEFT_THUMB = $00000040;
  XINPUT_GAMEPAD_RIGHT_THUMB = $00000080;

// Device Flags
const
  DEVICE_FLAG_JOYSTICK = (1 shl 0);
  DEVICE_FLAG_KEYBOARD = (1 shl 1);
  DEVICE_FLAG_MOUSE = (1 shl 2);
  DEVICE_FLAG_AXIS = (1 shl 3);
  DEVICE_FLAG_BUTTON = (1 shl 4);
  DEVICE_FLAG_POSITIVE = (1 shl 5);
  DEVICE_FLAG_NEGATIVE = (1 shl 6);
  DEVICE_FLAG_MOUSE_CLICK = (1 shl 7);
  DEVICE_FLAG_MOUSE_LX = (1 shl 8);
  DEVICE_FLAG_MOUSE_LY = (1 shl 9);
  DEVICE_FLAG_MOUSE_LZ = (1 shl 10);

// Detection Sensitivity
const
  DETECT_SENSITIVITY_JOYSTICK = 25000;
  DETECT_SENSITIVITY_BUTTON = 0;
  DETECT_SENSITIVITY_MOUSE = 5;
  DETECT_SENSITIVITY_POV = 50000;

// Input Device Name Lookup Table
const m_DeviceNameLookup: array [XBCtrlObject] of string = (
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100

  // Analog Axis
  'LThumbPosX', 'LThumbNegX', 'LThumbPosY', 'LThumbNegY',
  'RThumbPosX', 'RThumbNegX', 'RThumbPosY', 'RThumbNegY',

  // Analog Buttons
  'A', 'B', 'X', 'Y', 'Black', 'White', 'LTrigger', 'RTrigger',

  // Digital Buttons
  'DPadUp', 'DPadDown', 'DPadLeft', 'DPadRight',
  'Back', 'Start', 'LThumb', 'RThumb');

var
  g_XBController: XBController;

implementation

function WrapEnumGameCtrlCallback(var lpddi: TDIDeviceInstanceA; pvRef: Pointer): BOOL; stdcall;
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
begin
  Result := PXBController(pvRef).EnumGameCtrlCallback(lpddi);
end;

function WrapEnumObjectsCallback(var lpddoi: TDIDeviceObjectInstanceA; pvRef: Pointer): BOOL; stdcall;
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
begin
  Result := PXBController(pvRef).EnumObjectsCallback(lpddoi);
end;

procedure XBController.Initialize; // was XBController::XBController
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  v: int;
begin
  inherited Initialize;

  m_CurrentState := XBCTRL_STATE_NONE;

  for v := 0 to XBCTRL_MAX_DEVICES-1 do
  begin
    m_DeviceName[v][0] := #0;

    m_InputDevice[v].m_Device := NULL;
    m_InputDevice[v].m_Flags := 0;
  end;

  for v := 0 to XBCTRL_OBJECT_COUNT-1 do
  begin
    m_ObjectConfig[XBCtrlObject(v)].dwDevice := -1;
    m_ObjectConfig[XBCtrlObject(v)].dwInfo := -1;
    m_ObjectConfig[XBCtrlObject(v)].dwFlags := 0;
  end;

  m_pDirectInput8 := NULL;

  m_dwInputDeviceCount := 0;
end;

procedure XBController.Finalize; // was XBController::~XBController
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
begin
  if m_CurrentState = XBCTRL_STATE_CONFIG then
    ConfigEnd()
  else
    if m_CurrentState = XBCTRL_STATE_LISTEN then
      ListenEnd();

  inherited Finalize;
end;

procedure XBController.Load(szRegistryKey: P_char);
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  dwType, dwSize: DWORD;
  dwDisposition: DWORD;
  hKey: Windows.HKEY;
  v: int;
  szValueName: AnsiString;
begin
  if m_CurrentState <> XBCTRL_STATE_NONE then
  begin
    Self{:Error}.SetError('Invalid State', false);
    Exit;
  end;

  // Load Configuration from Registry
  if (RegCreateKeyExA(HKEY_CURRENT_USER, szRegistryKey, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_QUERY_VALUE, NULL, {var}hKey, @dwDisposition) = ERROR_SUCCESS) then
  begin
    // Load Device Names
    for v := 0 to XBCTRL_MAX_DEVICES-1 do
    begin
      // default is a null string
      m_DeviceName[v][0] := #0;
      szValueName := AnsiString(Format('DeviceName 0x%.02X', [v]));

      dwType := REG_SZ; dwSize := 260;
      RegQueryValueExA(hKey, PAnsiChar(szValueName), NULL, @dwType, PByte(@(m_DeviceName[v])), @dwSize);
    end;

    // Load Object Configuration
    for v := 0 to XBCTRL_OBJECT_COUNT-1 do
    begin
      // default object configuration
      m_ObjectConfig[XBCtrlObject(v)].dwDevice := -1;
      m_ObjectConfig[XBCtrlObject(v)].dwInfo := -1;
      m_ObjectConfig[XBCtrlObject(v)].dwFlags := 0;

      szValueName := AnsiString(Format('Object : "%s"', [m_DeviceNameLookup[XBCtrlObject(v)]]));

      dwType := REG_BINARY; dwSize := sizeof(XBCtrlObjectCfg);

      RegQueryValueExA(hKey, PAnsiChar(szValueName), NULL, @dwType, @m_ObjectConfig[XBCtrlObject(v)], @dwSize);
    end;

    RegCloseKey(hKey);
  end;
end;

procedure XBController.Save(szRegistryKey: P_char);
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  dwType, dwSize: DWORD;
  dwDisposition: DWORD;
  hKey: Windows.HKEY;
  v: int;
  szValueName: AnsiString;
begin
  if (m_CurrentState <> XBCTRL_STATE_NONE) then
  begin
    Self{:Error}.SetError('Invalid State', False);
    Exit;
  end;

  // Save Configuration to Registry
  if (RegCreateKeyExA(HKEY_CURRENT_USER, szRegistryKey, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, hKey, @dwDisposition) = ERROR_SUCCESS) then
  begin
    // Save Device Names
    for v := 0 to XBCTRL_MAX_DEVICES-1 do
    begin
      szValueName := AnsiString(Format('DeviceName 0x%.02X', [v]));

      dwType := REG_SZ; dwSize := 260;

      if (m_DeviceName[v][0] = #0) then
        RegDeleteValueA(hKey, PAnsiChar(szValueName))
      else
        RegSetValueExA(hKey, PAnsiChar(szValueName), 0, dwType, PBYTE(@m_DeviceName[v]), dwSize);
    end;

    // Save Object Configuration
    for v := 0 to XBCTRL_OBJECT_COUNT-1 do
    begin
      szValueName := AnsiString(Format('Object : "%s"', [m_DeviceNameLookup[XBCtrlObject(v)]]));

      dwType := REG_BINARY; dwSize := sizeof(XBCtrlObjectCfg);

      if (m_ObjectConfig[XBCtrlObject(v)].dwDevice <> -1) then
        RegSetValueExA(hKey, PAnsiChar(szValueName), 0, dwType, PBYTE(@m_ObjectConfig[XBCtrlObject(v)]), dwSize);
    end;

    RegCloseKey(hKey);
  end;
end;

procedure XBController.ConfigBegin(ahwnd: HWND; object_: XBCtrlObject);
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
begin
  if m_CurrentState <> XBCTRL_STATE_NONE then
  begin
    Self{:Error}.SetError('Invalid State', false);
    Exit;
  end;

  m_CurrentState := XBCTRL_STATE_CONFIG;

  DInputInit(ahwnd);

  if Self{:Error}.GetError() <> '' then
    Exit;

  lPrevMouseX := -1;
  lPrevMouseY := -1;
  lPrevMouseZ := -1;

  CurConfigObject := object_;
end;

function XBController.ConfigPoll(var szStatus: string): _bool;
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  DeviceInstance: DIDEVICEINSTANCE;
  ObjectInstance: DIDEVICEOBJECTINSTANCE;
  v: Integer;
  hRet: HRESULT;
  dwHow: Int32; // was DWord but needed to be signed !
  dwFlags: Int32; // was DWord but needed to be signed !
  JoyState: DIJOYSTATE;
  KeyState: DIKEYSTATE;
  b: int;
  szDirection: string;
  r: int;
  MouseState: DIMOUSESTATE2;
  lAbsDeltaX, lAbsDeltaY, lAbsDeltaZ: LONG;
  lDeltaX, lDeltaY, lDeltaZ: LONG;
  lMax: LONG;
  szObjName: P_char;
begin
  if (m_CurrentState <> XBCTRL_STATE_CONFIG) then
  begin
    Self{:Error}.SetError('Invalid State', false);
    Result := False;
    Exit;
  end;

  DeviceInstance.dwSize := sizeof(DIDEVICEINSTANCE);
  ObjectInstance.dwSize := sizeof(DIDEVICEOBJECTINSTANCE);

  // Monitor for significant device state changes
  if m_dwInputDeviceCount > 0 then // Dxbx addition, to prevent underflow
  for v := m_dwInputDeviceCount - 1 downto 0 do
  begin
    // Poll the current device
    begin
      hRet := IDirectInputDevice8(m_InputDevice[v].m_Device).Poll();

      if (FAILED(hRet)) then
      begin
        hRet := IDirectInputDevice8(m_InputDevice[v].m_Device).Acquire();

        while (hRet = DIERR_INPUTLOST) do
          hRet := IDirectInputDevice8(m_InputDevice[v].m_Device).Acquire();
      end;
    end;

    dwHow := -1; // {unused:}dwFlags := m_InputDevice[v].m_Flags;

    // Detect Joystick Input
    if (m_InputDevice[v].m_Flags and DEVICE_FLAG_JOYSTICK) > 0 then
    begin
      ZeroMemory(@JoyState, sizeof(DIJOYSTATE));

      // Get Joystick State
      begin
        hRet := IDirectInputDevice8(m_InputDevice[v].m_Device).GetDeviceState(sizeof(DIJOYSTATE), @JoyState);
        if FAILED(hRet) then
          continue;
      end;

      dwFlags := DEVICE_FLAG_JOYSTICK;

      if (abs(JoyState.lX) > DETECT_SENSITIVITY_JOYSTICK) then
      begin
        dwHow := FIELD_OFFSET(PDIJOYSTATE(nil).lX);
        dwFlags := dwFlags or iif(JoyState.lX > 0, (DEVICE_FLAG_AXIS or DEVICE_FLAG_POSITIVE), (DEVICE_FLAG_AXIS or DEVICE_FLAG_NEGATIVE));
      end
      else if (abs(JoyState.lY) > DETECT_SENSITIVITY_JOYSTICK) then
      begin
        dwHow := FIELD_OFFSET(PDIJOYSTATE(nil).lY);
        dwFlags := dwFlags or iif(JoyState.lY > 0, (DEVICE_FLAG_AXIS or DEVICE_FLAG_POSITIVE), (DEVICE_FLAG_AXIS or DEVICE_FLAG_NEGATIVE));
      end
      else if (abs(JoyState.lZ) > DETECT_SENSITIVITY_JOYSTICK) then
      begin
        dwHow := FIELD_OFFSET(PDIJOYSTATE(nil).lZ);
        dwFlags := dwFlags or iif(JoyState.lZ > 0, (DEVICE_FLAG_AXIS or DEVICE_FLAG_POSITIVE), (DEVICE_FLAG_AXIS or DEVICE_FLAG_NEGATIVE));
      end
      else if (abs(JoyState.lRx) > DETECT_SENSITIVITY_JOYSTICK) then
      begin
        dwHow := FIELD_OFFSET(PDIJOYSTATE(nil).lRx);
        dwFlags := dwFlags or iif(JoyState.lRx > 0, (DEVICE_FLAG_AXIS or DEVICE_FLAG_POSITIVE), (DEVICE_FLAG_AXIS or DEVICE_FLAG_NEGATIVE));
      end
      else if (abs(JoyState.lRy) > DETECT_SENSITIVITY_JOYSTICK) then
      begin
        dwHow := FIELD_OFFSET(PDIJOYSTATE(nil).lRy);
        dwFlags := dwFlags or iif(JoyState.lRy > 0, (DEVICE_FLAG_AXIS or DEVICE_FLAG_POSITIVE), (DEVICE_FLAG_AXIS or DEVICE_FLAG_NEGATIVE));
      end
      else if (abs(JoyState.lRz) > DETECT_SENSITIVITY_JOYSTICK) then
      begin
        dwHow := FIELD_OFFSET(PDIJOYSTATE(nil).lRz);
        dwFlags := dwFlags or iif(JoyState.lRz > 0, (DEVICE_FLAG_AXIS or DEVICE_FLAG_POSITIVE), (DEVICE_FLAG_AXIS or DEVICE_FLAG_NEGATIVE));
      end
      else
      begin
        for b := 0 to 2-1 do
        begin
          if (abs(JoyState.rglSlider[b]) > DETECT_SENSITIVITY_JOYSTICK) then
          begin
            dwHow := FIELD_OFFSET(PDIJOYSTATE(nil).rglSlider[b]);
            dwFlags := dwFlags or iif(JoyState.rglSlider[b] > 0, (DEVICE_FLAG_AXIS or DEVICE_FLAG_POSITIVE), (DEVICE_FLAG_AXIS or DEVICE_FLAG_NEGATIVE));
          end;
        end;
      end;

      (* Cxbx : temporarily disabled
      if (dwHow = DWord(-1)) then
      begin
        for {int}b := 0 to 4-1 do
        begin
          if (Abs(JoyState.rgdwPOV[b]) > DETECT_SENSITIVITY_POV) then
          begin
            dwHow := FIELD_OFFSET(PDIJOYSTATE(nil).rgdwPOV[b]);
          end;
        end;
      end;
      *)

      if (dwHow = -1) then
      begin
        for b := 0 to 32-1 do
        begin
          if (JoyState.rgbButtons[b] > DETECT_SENSITIVITY_BUTTON) then
          begin
            dwHow := FIELD_OFFSET(PDIJOYSTATE(nil).rgbButtons[b]);
            dwFlags := dwFlags or DEVICE_FLAG_BUTTON;
          end;
        end;
      end;

      // Retrieve Object Info
      if (dwHow <> -1) then
      begin
        szDirection := iif((dwFlags and DEVICE_FLAG_AXIS) > 0, iif((dwFlags and DEVICE_FLAG_POSITIVE) > 0, 'Positive ', 'Negative '), '');

        IDirectInputDevice8(m_InputDevice[v].m_Device).GetDeviceInfo({var}DeviceInstance);

        IDirectInputDevice8(m_InputDevice[v].m_Device).GetObjectInfo({var}ObjectInstance, dwHow, DIPH_BYOFFSET);

        Map(CurConfigObject, DeviceInstance.tszInstanceName, dwHow, dwFlags);

{$IFDEF DEBUG}
        DbgPrintf('Dxbx: Detected %s%s on %s', [szDirection, ObjectInstance.tszName, DeviceInstance.tszInstanceName, ObjectInstance.dwType]);
{$ENDIF}
        szStatus := Format('Success: %s Mapped to "%s%s" on "%s"!', [m_DeviceNameLookup[CurConfigObject], szDirection, ObjectInstance.tszName, DeviceInstance.tszInstanceName]);

        Result := true;
        Exit;
      end;
    end

    // Detect Keyboard Input
    else if (m_InputDevice[v].m_Flags and DEVICE_FLAG_KEYBOARD) > 0 then
    begin
      ZeroMemory(@KeyState, sizeof(DIKEYSTATE));

      IDirectInputDevice8(m_InputDevice[v].m_Device).GetDeviceState(sizeof(DIKEYSTATE), @KeyState);

      dwFlags := DEVICE_FLAG_KEYBOARD;

      // Check for Keyboard State Change
      for r := 0 to 256-1 do
      begin
        if (KeyState[r] <> 0) then
        begin
          dwHow := r;
          break;
        end;
      end;

      // Check for Success
      if (dwHow <> -1) then
      begin
        Map(CurConfigObject, 'SysKeyboard', dwHow, dwFlags);

{$IFDEF DEBUG}
        DbgPrintf('Dxbx: Detected Key %d on SysKeyboard', [dwHow]);
{$ENDIF}
        szStatus := Format('Success: %s Mapped to Key %d on SysKeyboard', [m_DeviceNameLookup[CurConfigObject], dwHow]);

        Result := true;
        Exit;
      end;
    end

    // Detect Mouse Input
    else if (m_InputDevice[v].m_Flags and DEVICE_FLAG_MOUSE) > 0 then
    begin
      ZeroMemory(@MouseState, sizeof(MouseState));

      IDirectInputDevice8(m_InputDevice[v].m_Device).GetDeviceState(sizeof(MouseState), @MouseState);

      dwFlags := DEVICE_FLAG_MOUSE;

      // Detect Button State Change
      for r := 0 to 4-1 do
      begin
        // 0x80 is the mask for button push
        if (MouseState.rgbButtons[r] and $80) > 0 then
        begin
          dwHow := r;
          dwFlags := dwFlags or DEVICE_FLAG_MOUSE_CLICK;
          break;
        end;
      end;

      // Check for Success
      if (dwHow <> -1) then
      begin
        Map(CurConfigObject, 'SysMouse', dwHow, dwFlags);

{$IFDEF DEBUG}
        DbgPrintf('Dxbx: Detected Button %d on SysMouse', [dwHow]);
{$ENDIF}
        szStatus := Format('Success: %s Mapped to Button %d on SysMouse', [m_DeviceNameLookup[CurConfigObject], dwHow]);

        Result := true;
        Exit;
      end
      // Check for Mouse Movement
      else
      begin
        lAbsDeltaX := 0; lAbsDeltaY := 0; lAbsDeltaZ := 0;
        // Never used : lDeltaX := 0; lDeltaY := 0; lDeltaZ := 0;

        if (lPrevMouseX = -1) or (lPrevMouseY = -1) or (lPrevMouseZ = -1) then
        begin
          lDeltaX := 0; lDeltaY := 0; lDeltaZ := 0;
        end
        else
        begin
          lDeltaX := MouseState.lX - lPrevMouseX;
          lDeltaY := MouseState.lY - lPrevMouseY;
          lDeltaZ := MouseState.lZ - lPrevMouseZ;

          lAbsDeltaX := abs(lDeltaX);
          lAbsDeltaY := abs(lDeltaY);
          lAbsDeltaZ := abs(lDeltaZ);
        end;

        lMax := iif(lAbsDeltaX > lAbsDeltaY, lAbsDeltaX, lAbsDeltaY);

        if (lAbsDeltaZ > lMax) then
          lMax := lAbsDeltaZ;

        lPrevMouseX := MouseState.lX;
        lPrevMouseY := MouseState.lY;
        lPrevMouseZ := MouseState.lZ;

        if (lMax > DETECT_SENSITIVITY_MOUSE) then
        begin
          dwFlags := dwFlags or DEVICE_FLAG_AXIS;

          if (lMax = lAbsDeltaX) then
          begin
            dwHow := FIELD_OFFSET(PDIMOUSESTATE(nil).lX);
            dwFlags := dwFlags or iif(lDeltaX > 0, DEVICE_FLAG_POSITIVE, DEVICE_FLAG_NEGATIVE);
          end
          else if (lMax = lAbsDeltaY) then
          begin
            dwHow := FIELD_OFFSET(PDIMOUSESTATE(nil).lY);
            dwFlags := dwFlags or iif(lDeltaY > 0, DEVICE_FLAG_POSITIVE, DEVICE_FLAG_NEGATIVE);
          end
          else if (lMax = lAbsDeltaZ) then
          begin
            dwHow := FIELD_OFFSET(PDIMOUSESTATE(nil).lZ);
            dwFlags := dwFlags or iif(lDeltaZ > 0, DEVICE_FLAG_POSITIVE, DEVICE_FLAG_NEGATIVE);
          end;
        end;

        // Check for Success
        if (dwHow <> -1) then
        begin
          szDirection := iif((dwFlags and DEVICE_FLAG_POSITIVE) > 0, 'Positive', 'Negative');
          szObjName := 'Unknown';

          ObjectInstance.dwSize := sizeof(ObjectInstance);

          if (IDirectInputDevice8(m_InputDevice[v].m_Device).GetObjectInfo({var}ObjectInstance, dwHow, DIPH_BYOFFSET) = DI_OK) then
            szObjName := ObjectInstance.tszName;

          Map(CurConfigObject, 'SysMouse', dwHow, dwFlags);

{$IFDEF DEBUG}
          DbgPrintf('Dxbx: Detected Movement on the %s%s on SysMouse', [szDirection, szObjName]);
{$ENDIF}
          szStatus := Format('Success: %s Mapped to %s%s on SysMouse', [m_DeviceNameLookup[CurConfigObject], szDirection, szObjName]);

          Result := true;
          Exit;
        end;
      end;
    end;
  end;

  Result := false;
end;

procedure XBController.ConfigEnd;
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
begin
  if m_CurrentState <> XBCTRL_STATE_CONFIG then
  begin
    Self{:Error}.SetError('Invalid State', false);
    Exit;
  end;

  DInputCleanup();
  m_CurrentState := XBCTRL_STATE_NONE;
end;

procedure XBController.ListenBegin(hwnd: HWND);
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  v: int;
begin
  if m_CurrentState <> XBCTRL_STATE_NONE then
  begin
    Self{:Error}.SetError('Invalid State', false);
    Exit;
  end;

  m_CurrentState := XBCTRL_STATE_LISTEN;

  DInputInit(hwnd);

  for v := XBCTRL_MAX_DEVICES-1 downto m_dwInputDeviceCount do
    m_DeviceName[v][0] := #0;

  for v := 0 to XBCTRL_OBJECT_COUNT-1 do
  begin
    if m_ObjectConfig[XBCtrlObject(v)].dwDevice >= m_dwInputDeviceCount then
    begin
{$IFDEF DEBUG}
      DbgPrintf('Warning: Device Mapped to %s was not found!', [m_DeviceNameLookup[XBCtrlObject(v)]]);
{$ENDIF}
      m_ObjectConfig[XBCtrlObject(v)].dwDevice := -1;
    end;
  end;
end;

function IsAnalog(v: XBCtrlObject): boolean;
begin
  Result := (v <= XBCTRL_OBJECT_RTRIGGER);
end;

{static}var lAccumX: LongInt = 0;
{static}var lAccumY: LongInt = 0;
{static}var lAccumZ: LongInt = 0;
{static}var lKeyPressure: array [XBCtrlObject] of LongInt;
procedure XBController.ListenPoll(Controller: PXINPUT_STATE);
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  hRet: HRESULT;
  v: XBCtrlObject;

  dwDevice: DWORD;
  dwFlags: DWORD;
  dwInfo: DWORD;

  wValue: SmallInt;
  pDevice: IDIRECTINPUTDEVICE8;
  JoyState: DIJOYSTATE;
  pdwAxis: PLONG;
  pbButton: PByte;
  KeyboardState: array [0..256-1] of BYTE;
  bKey: BYTE;
  MouseState: DIMOUSESTATE2;
begin
  if(Controller = NULL) then
    Exit;

  pDevice := NULL;

  // Never used : hRet := 0;
  // Never used : dwFlags := 0;

  // Default values necessary for axis
  Controller.Gamepad.sThumbLX := 0;
  Controller.Gamepad.sThumbLY := 0;
  Controller.Gamepad.sThumbRX := 0;
  Controller.Gamepad.sThumbRY := 0;

  // Poll all devices
  for v := Low(XBCtrlObject) to High(XBCtrlObject) do
  begin
    dwDevice := m_ObjectConfig[v].dwDevice;
    dwFlags := m_ObjectConfig[v].dwFlags;
    dwInfo := m_ObjectConfig[v].dwInfo;

    if (dwDevice = DWord(-1)) then
      continue;

    pDevice := m_InputDevice[dwDevice].m_Device;

    hRet := IDirectInputDevice8(pDevice).Poll();

    if FAILED(hRet) then
    begin
      hRet := IDirectInputDevice8(pDevice).Acquire();

      while hRet = DIERR_INPUTLOST do
        hRet := IDirectInputDevice8(pDevice).Acquire();
    end;

    wValue := 0;

    // Interpret PC Joystick Input
    if (dwFlags and DEVICE_FLAG_JOYSTICK) > 0 then
    begin
      ZeroMemory(@JoyState, SizeOf(JoyState));

      if (IDirectInputDevice8(pDevice).GetDeviceState(sizeof(JoyState), @JoyState) <> DI_OK) then
        continue;

      if (dwFlags and DEVICE_FLAG_AXIS) > 0 then
      begin
        pdwAxis := PLONG(UIntPtr(@JoyState) + dwInfo);
        wValue := SHORT(pdwAxis^);

        if (dwFlags and DEVICE_FLAG_NEGATIVE) > 0 then
        begin
          if (wValue < 0) then
            wValue := abs(wValue+1)
          else
            wValue := 0;
        end
        else if (dwFlags and DEVICE_FLAG_POSITIVE) > 0 then
        begin
          if (wValue < 0) then
            wValue := 0;
        end;
      end
      else if (dwFlags and DEVICE_FLAG_BUTTON) > 0 then
      begin
        pbButton := PBYTE(UIntPtr(@JoyState) + dwInfo);

        if (pbButton^ and $80) > 0 then
          wValue := 32767
        else
          wValue := 0;
      end;
    end
    // Interpret PC KeyBoard Input
    else if (dwFlags and DEVICE_FLAG_KEYBOARD) > 0 then
    begin
      ZeroMemory(@KeyboardState, SizeOf(KeyboardState));

      if (IDirectInputDevice8(pDevice).GetDeviceState(sizeof(KeyboardState), @KeyboardState) <> DI_OK) then
        continue;

      bKey := KeyboardState[dwInfo];

      if (bKey and $80) > 0 then
      begin
        // Dxbx addition : For analog controls, key presses build up pressure when being (de)pressed longer.
        // The following code uses a power increase of 5000, which reaches max pressure in about 6 measurements,
        // which is fast enough for most applications, but still allows for a little accuracy when needed.
        // TODO : Make the press & release power configurable per XBCtrlObject.

        Inc(lKeyPressure[v], 5000);
        if (not IsAnalog(v))
        or (lKeyPressure[v] > 32767) then
          lKeyPressure[v] := 32767;
      end
      else
      begin
        Dec(lKeyPressure[v], 7500);
        if (not IsAnalog(v))
        or (lKeyPressure[v] < 0) then
          lKeyPressure[v] := 0;
      end;

      wValue := lKeyPressure[v];
    end
    // Interpret PC Mouse Input
    else if (dwFlags and DEVICE_FLAG_MOUSE) > 0 then
    begin
      ZeroMemory(@MouseState, SizeOf(MouseState));

      if (IDirectInputDevice8(pDevice).GetDeviceState(sizeof(MouseState), @MouseState) <> DI_OK) then
        continue;

      if (dwFlags and DEVICE_FLAG_MOUSE_CLICK) > 0 then
      begin
        if (MouseState.rgbButtons[dwInfo] and $80) > 0 then
          wValue := 32767
        else
          wValue := 0;
      end
      else if (dwFlags and DEVICE_FLAG_AXIS) > 0 then
      begin
        // static LONG lAccumX = 0;
        // static LONG lAccumY = 0;
        // static LONG lAccumZ = 0;

        Inc(lAccumX, MouseState.lX * 300);
        Inc(lAccumY, MouseState.lY * 300);
        Inc(lAccumZ, MouseState.lZ * 300);

        if (lAccumX > 32767) then
          lAccumX := 32767
        else if (lAccumX < -32768) then
          lAccumX := -32768;

        if (lAccumY > 32767) then
          lAccumY := 32767
        else if (lAccumY < -32768) then
          lAccumY := -32768;

        if (lAccumZ > 32767) then
          lAccumZ := 32767
        else if (lAccumZ < -32768) then
          lAccumZ := -32768;

        if (dwInfo = FIELD_OFFSET(PDIMOUSESTATE(nil).lX)) then
          wValue := WORD(lAccumX)
        else if (dwInfo = FIELD_OFFSET(PDIMOUSESTATE(nil).lY)) then
          wValue := WORD(lAccumY)
        else if (dwInfo = FIELD_OFFSET(PDIMOUSESTATE(nil).lZ)) then
          wValue := WORD(lAccumZ);

        if (dwFlags and DEVICE_FLAG_NEGATIVE) > 0 then
        begin
          if (wValue < 0) then
            wValue := abs(wValue + 1)
          else
            wValue := 0;
        end
        else if (dwFlags and DEVICE_FLAG_POSITIVE) > 0 then
        begin
          if (wValue < 0) then
            wValue := 0;
        end;
      end;
    end;

    // Map Xbox Joystick Input
    if (v >= XBCTRL_OBJECT_LTHUMBPOSX) and (v <= XBCTRL_OBJECT_RTHUMB) then
    begin
      case (v)
      of
        XBCTRL_OBJECT_LTHUMBPOSY:
          Inc(Controller.Gamepad.sThumbLY, wValue);

        XBCTRL_OBJECT_LTHUMBNEGY:
          Dec(Controller.Gamepad.sThumbLY, wValue);

        XBCTRL_OBJECT_RTHUMBPOSY:
          Inc(Controller.Gamepad.sThumbRY, wValue);

        XBCTRL_OBJECT_RTHUMBNEGY:
          Dec(Controller.Gamepad.sThumbRY, wValue);

        XBCTRL_OBJECT_LTHUMBPOSX:
          Inc(Controller.Gamepad.sThumbLX, wValue);

        XBCTRL_OBJECT_LTHUMBNEGX:
          Dec(Controller.Gamepad.sThumbLX, wValue);

        XBCTRL_OBJECT_RTHUMBPOSX:
          Inc(Controller.Gamepad.sThumbRX, wValue);

        XBCTRL_OBJECT_RTHUMBNEGX:
          Dec(Controller.Gamepad.sThumbRX, wValue);

        XBCTRL_OBJECT_A:
          Controller.Gamepad.bAnalogButtons[XINPUT_GAMEPAD_A] := (wValue div 128);

        XBCTRL_OBJECT_B:
          Controller.Gamepad.bAnalogButtons[XINPUT_GAMEPAD_B] := (wValue div 128);

        XBCTRL_OBJECT_X:
          Controller.Gamepad.bAnalogButtons[XINPUT_GAMEPAD_X] := (wValue div 128);

        XBCTRL_OBJECT_Y:
          Controller.Gamepad.bAnalogButtons[XINPUT_GAMEPAD_Y] := (wValue div 128);

        XBCTRL_OBJECT_WHITE:
          Controller.Gamepad.bAnalogButtons[XINPUT_GAMEPAD_WHITE] := (wValue div 128);

        XBCTRL_OBJECT_BLACK:
          Controller.Gamepad.bAnalogButtons[XINPUT_GAMEPAD_BLACK] := (wValue div 128);

        XBCTRL_OBJECT_LTRIGGER:
          Controller.Gamepad.bAnalogButtons[XINPUT_GAMEPAD_LEFT_TRIGGER] := (wValue div 128);

        XBCTRL_OBJECT_RTRIGGER:
          Controller.Gamepad.bAnalogButtons[XINPUT_GAMEPAD_RIGHT_TRIGGER] := (wValue div 128);

        XBCTRL_OBJECT_DPADUP:
          if (wValue > 0) then
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons or XINPUT_GAMEPAD_DPAD_UP
          else
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons and not XINPUT_GAMEPAD_DPAD_UP;

        XBCTRL_OBJECT_DPADDOWN:
          if (wValue > 0) then
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons or XINPUT_GAMEPAD_DPAD_DOWN
          else
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons and not XINPUT_GAMEPAD_DPAD_DOWN;

        XBCTRL_OBJECT_DPADLEFT:
          if (wValue > 0) then
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons or XINPUT_GAMEPAD_DPAD_LEFT
          else
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons and not XINPUT_GAMEPAD_DPAD_LEFT;

        XBCTRL_OBJECT_DPADRIGHT:
          if (wValue > 0) then
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons or XINPUT_GAMEPAD_DPAD_RIGHT
          else
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons and not XINPUT_GAMEPAD_DPAD_RIGHT;

        XBCTRL_OBJECT_BACK:
          if (wValue > 0) then
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons or XINPUT_GAMEPAD_BACK
          else
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons and not XINPUT_GAMEPAD_BACK;

        XBCTRL_OBJECT_START:
          if (wValue > 0) then
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons or XINPUT_GAMEPAD_START
          else
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons and not XINPUT_GAMEPAD_START;

        XBCTRL_OBJECT_LTHUMB:
          if (wValue > 0) then
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons or XINPUT_GAMEPAD_LEFT_THUMB
          else
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons and not XINPUT_GAMEPAD_LEFT_THUMB;

        XBCTRL_OBJECT_RTHUMB:
          if (wValue > 0) then
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons or XINPUT_GAMEPAD_RIGHT_THUMB
          else
            Controller.Gamepad.wButtons := Controller.Gamepad.wButtons and not XINPUT_GAMEPAD_RIGHT_THUMB;

      end; // case
    end; // if Joystick Input
  end; // for all devices
end;


procedure XBController.ListenEnd;
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
begin
  if m_CurrentState <> XBCTRL_STATE_LISTEN then
  begin
    Self{:Error}.SetError('Invalid State', false);
    Exit;
  end;

  DInputCleanup();
  m_CurrentState := XBCTRL_STATE_NONE;
end;

function XBController.DeviceIsUsed(szDeviceName: P_char): _bool;
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  v: Integer;
begin
  for v := 0 to XBCTRL_MAX_DEVICES-1 do
  begin
    if (strncmp(m_DeviceName[v], szDeviceName, 255) = 0) then
    begin
      Result := true;
      Exit;
    end;
  end;

  Result := false;
end;

procedure XBController.DInputInit(ahwnd: HWND);
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  hRet: HResult;
  v: int;
begin
  m_dwInputDeviceCount := 0;

  // Create DirectInput Object
  begin
    hRet := DirectInput8Create
    (
      GetModuleHandle(NULL),
      DIRECTINPUT_VERSION,
      IID_IDirectInput8,
      {out}m_pDirectInput8,
      NULL
    );

    if (FAILED(hRet)) then
    begin
      Self{:Error}.SetError('Could not initialized DirectInput8', true);
      Exit;
    end;
  end;

  // Create all the devices available (well...most of them)
  if (m_pDirectInput8 <> nil) then
  begin
    {ahRet :=} IDirectInput8(m_pDirectInput8).EnumDevices
    (
        DI8DEVCLASS_GAMECTRL,
        TDIEnumDevicesCallbackA(@WrapEnumGameCtrlCallback),
        Addr(Self),
        DIEDFL_ATTACHEDONLY
    );
    // TODO -oDxbx: Add : if FAILED(hret) then what?

    if (m_CurrentState = XBCTRL_STATE_CONFIG) or DeviceIsUsed('SysKeyboard') then
    begin
      hRet := IDirectInput8(m_pDirectInput8).CreateDevice(
        {rguid}GUID_SysKeyboard,
        @(m_InputDevice[m_dwInputDeviceCount].m_Device),
        {pUnkOuter=}NULL);

      if (not FAILED(hRet)) then
      begin
        m_InputDevice[m_dwInputDeviceCount].m_Flags := DEVICE_FLAG_KEYBOARD;
        IDirectInputDevice8(m_InputDevice[m_dwInputDeviceCount].m_Device).SetDataFormat(c_dfDIKeyboard);
        Inc(m_dwInputDeviceCount);
      end;

      if (m_CurrentState = XBCTRL_STATE_LISTEN) then
        ReorderObjects('SysKeyboard', m_dwInputDeviceCount - 1);
    end;

    if (m_CurrentState = XBCTRL_STATE_CONFIG) or DeviceIsUsed('SysMouse') then
    begin
      hRet := IDirectInput8(m_pDirectInput8).CreateDevice(
        GUID_SysMouse,
        @(m_InputDevice[m_dwInputDeviceCount].m_Device),
        NULL);

      if (not FAILED(hRet)) then
      begin
        m_InputDevice[m_dwInputDeviceCount].m_Flags := DEVICE_FLAG_MOUSE;
        IDirectInputDevice8(m_InputDevice[m_dwInputDeviceCount].m_Device).SetDataFormat(c_dfDIMouse2);
        Inc(m_dwInputDeviceCount);
      end;

      if (m_CurrentState = XBCTRL_STATE_LISTEN) then
        ReorderObjects('SysMouse', m_dwInputDeviceCount - 1);
    end;
  end;

  // Enumerate Controller objects
  // Dxbx note : While instead of for, as loop variable is not a 'simple local variable' :
  m_dwCurObject := 0; while m_dwCurObject < m_dwInputDeviceCount do
  begin
    IDirectInputDevice8(m_InputDevice[m_dwCurObject].m_Device).EnumObjects(TDIEnumDeviceObjectsCallbackA(@WrapEnumObjectsCallback), Addr(Self), DIDFT_ALL);
    Inc(m_dwCurObject);
  end;


  // Set cooperative level and acquire
  begin
    if m_dwInputDeviceCount > 0 then // Dxbx addition, to prevent underflow
    for v := m_dwInputDeviceCount - 1 downto 0 do
    begin
      IDirectInputDevice8(m_InputDevice[v].m_Device).SetCooperativeLevel(ahwnd, DISCL_NONEXCLUSIVE or DISCL_FOREGROUND);
      IDirectInputDevice8(m_InputDevice[v].m_Device).Acquire();

      hRet := IDirectInputDevice8(m_InputDevice[v].m_Device).Poll();

      if (FAILED(hRet)) then
      begin
        hRet := IDirectInputDevice8(m_InputDevice[v].m_Device).Acquire();

        while (hRet = DIERR_INPUTLOST) do
          hRet := IDirectInputDevice8(m_InputDevice[v].m_Device).Acquire();

        if (hRet <> DIERR_INPUTLOST) then
          break;
      end;
    end;
  end;
end;

procedure XBController.DInputCleanup;
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  v: int;
begin
  if m_dwInputDeviceCount > 0 then // Dxbx addition, to prevent underflow
  for v := m_dwInputDeviceCount - 1 downto 0 do
  begin
    IDirectInputDevice8(m_InputDevice[v].m_Device).Unacquire();
    IDirectInputDevice8(m_InputDevice[v].m_Device)._Release();
    m_InputDevice[v].m_Device := nil;
  end;

  m_dwInputDeviceCount := 0;
  if (m_pDirectInput8 <> nil) then
  begin
    IDirectInput8(m_pDirectInput8)._Release();
    m_pDirectInput8 := nil;
  end;
end;

procedure XBController.Map(aobject: XBCtrlObject; szDeviceName: P_char; dwInfo, dwFlags: Integer);
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  v: int;
  r: XBCtrlObject;
  InUse: _bool;
begin
  // Initialize InputMapping instance
  m_ObjectConfig[aobject].dwDevice := Insert(szDeviceName);
  m_ObjectConfig[aobject].dwInfo := dwInfo;
  m_ObjectConfig[aobject].dwFlags := dwFlags;

  // Purge unused device slots
  for v := 0 to XBCTRL_MAX_DEVICES-1 do
  begin
    InUse := false;

    for r := Low(XBCtrlObject) to High(XBCtrlObject) do
      if m_ObjectConfig[r].dwDevice = v then
        InUse := true;

    if not InUse then
      m_DeviceName[v][0] := #0;
  end;
end;

function XBController.Insert(szDeviceName: P_char): int;
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  v: int;
begin
  for v := 0 to XBCTRL_MAX_DEVICES-1 do
    if (strcmp(@m_DeviceName[v], szDeviceName) = 0) then
    begin
      Result := v;
      Exit;
    end;

  for v := 0 to XBCTRL_MAX_DEVICES-1 do
  begin
    if (m_DeviceName[v][0] = #0) then
    begin
      strncpy(@m_DeviceName[v], szDeviceName, 255);
      Result := v;
      Exit;
    end;
  end;

  MessageBox(0, 'Unexpected Circumstance (Too Many Controller Devices)! Please contact caustik!', 'Dxbx', MB_OK or MB_ICONEXCLAMATION);

  ExitProcess(1);
  Result := 0;
end;

procedure XBController.ReorderObjects(szDeviceName: P_char; pos: int);
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  old: int;
  v: int;
begin
  Old := -1;

  // locate old device name position
  for v := 0 to XBCTRL_MAX_DEVICES-1 do
  begin
    if (strcmp(m_DeviceName[v], szDeviceName) = 0) then
    begin
      old := v;
      break;
    end;
  end;

  // Swap names, if necessary
  if old <> pos then
  begin
    strcpy(m_DeviceName[old], m_DeviceName[pos]);
    strcpy(m_DeviceName[pos], szDeviceName);
  end;

  // Update all Old values
  for v := 0 to XBCTRL_OBJECT_COUNT-1 do
  begin
    if m_ObjectConfig[XBCtrlObject(v)].dwDevice = old then
      m_ObjectConfig[XBCtrlObject(v)].dwDevice := pos
    else if m_ObjectConfig[XBCtrlObject(v)].dwDevice = pos then
        m_ObjectConfig[XBCtrlObject(v)].dwDevice := old;
  end;
end;

function XBController.EnumGameCtrlCallback(var lpddi: LPCDIDEVICEINSTANCE): BOOL;
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  hRet: HRESULT;
begin
  if (m_CurrentState = XBCTRL_STATE_LISTEN) and not DeviceIsUsed(lpddi.tszInstanceName) then
  begin
    Result := BOOL(DIENUM_CONTINUE);
    Exit;
  end;

  hRet := IDirectInput8(m_pDirectInput8).CreateDevice(lpddi.guidInstance, @(m_InputDevice[m_dwInputDeviceCount].m_Device), nil);

  if (not FAILED(hRet)) then
  begin
    m_InputDevice[m_dwInputDeviceCount].m_Flags := DEVICE_FLAG_JOYSTICK;
    IDirectInputDevice8(m_InputDevice[m_dwInputDeviceCount].m_Device).SetDataFormat(c_dfDIJoystick);
    Inc(m_dwInputDeviceCount);

    if (m_CurrentState = XBCTRL_STATE_LISTEN) then
      ReorderObjects(lpddi.tszInstanceName, m_dwInputDeviceCount - 1);
  end;

  Result := BOOL(DIENUM_CONTINUE);
end;

function XBController.EnumObjectsCallback(lpddoi: LPCDIDEVICEOBJECTINSTANCE): BOOL;
// Branch:shogun  Revision:161  Translator:Shadow_Tj  Done:100
var
  diprg: DIPROPRANGE;
  hRet: HRESULT;
begin
  if (lpddoi.dwType and DIDFT_AXIS) > 0 then
  begin
    diprg.diph.dwSize := sizeof(DIPROPRANGE);
    diprg.diph.dwHeaderSize := sizeof(DIPROPHEADER);
    diprg.diph.dwHow := DIPH_BYID;
    diprg.diph.dwObj := lpddoi.dwType;
    diprg.lMin := 0 - 32768;
    diprg.lMax := 0 + 32767;

    hRet := IDirectInputDevice8(m_InputDevice[m_dwCurObject].m_Device).SetProperty(DIPROP_RANGE, diprg.diph);

    if FAILED(hRet) then
    begin
      if hRet = E_NOTIMPL then
        Result := BOOL(DIENUM_CONTINUE)
      else
        Result := BOOL(DIENUM_STOP);

      Exit;
    end;
  end
  else if (lpddoi.dwType and DIDFT_BUTTON) > 0 then
  begin
    diprg.diph.dwSize := sizeof(DIPROPRANGE);
    diprg.diph.dwHeaderSize := sizeof(DIPROPHEADER);
    diprg.diph.dwHow := DIPH_BYID;
    diprg.diph.dwObj := lpddoi.dwType;
    diprg.lMin := 0;
    diprg.lMax := 255;

    hRet := IDirectInputDevice8(m_InputDevice[m_dwCurObject].m_Device).SetProperty(DIPROP_RANGE, diprg.diph);

    if (FAILED(hRet)) then
    begin
      if (hRet = E_NOTIMPL) then
        Result := BOOL(DIENUM_CONTINUE)
      else
        Result := BOOL(DIENUM_STOP);

      Exit;
    end;
  end;

  Result := BOOL(DIENUM_CONTINUE);
end;

{.$MESSAGE 'PatrickvL reviewed up to here'}

end.

