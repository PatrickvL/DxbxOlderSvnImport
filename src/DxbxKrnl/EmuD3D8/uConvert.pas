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

unit uConvert;

{$INCLUDE Dxbx.inc}

interface

uses
  // Delphi
  Windows
  , SysUtils
  // DirectX
{$IFDEF DXBX_USE_D3D9}
  , Direct3D9
{$ELSE}
  , Direct3D8
{$ENDIF}
  // Dxbx
  , uTypes
  , uDxbxKrnlUtils
  , uEmuD3D8Types
  , uEmu;

function EmuXBFormatIsSwizzled(Format: X_D3DFORMAT; pBPP: PDWord = nil): BOOL_;
function EmuXBFormatIsYUV(Format: X_D3DFORMAT): BOOL_;
function EmuXBFormatIsCompressed(Format: X_D3DFORMAT): BOOL_;
function EmuXBFormatIsLinear(Format: X_D3DFORMAT; pBPP: PDWord = nil): BOOL_;

function EmuXB2PC_D3DFormat(aFormat: X_D3DFORMAT): D3DFORMAT;
function EmuPC2XB_D3DFormat(aFormat: D3DFORMAT): X_D3DFORMAT;

function EmuXB2PC_D3DLock(Flags: DWORD): DWORD;

function EmuXB2PC_D3DMULTISAMPLE_TYPE(aType: X_D3DMULTISAMPLE_TYPE): D3DMULTISAMPLE_TYPE;
function EmuPC2XB_D3DMULTISAMPLE_TYPE(aType: D3DMULTISAMPLE_TYPE): X_D3DMULTISAMPLE_TYPE;

function EmuXB2PC_D3DTS(State: X_D3DTRANSFORMSTATETYPE): D3DTRANSFORMSTATETYPE;
function EmuXB2PC_D3DBLENDOP(Value: X_D3DBLENDOP): D3DBLENDOP;
function EmuXB2PC_D3DBLEND(Value: X_D3DBLEND): D3DBLEND;
function EmuXB2PC_D3DCMPFUNC(Value: X_D3DCMPFUNC): D3DCMPFUNC;
function EmuXB2PC_D3DFILLMODE(Value: X_D3DFILLMODE): D3DFILLMODE;
function EmuXB2PC_D3DSTENCILOP(Value: X_D3DSTENCILOP): D3DSTENCILOP;
function EmuXB2PC_D3DSHADEMODE(Value: X_D3DSHADEMODE): D3DSHADEMODE;
function EmuXB2PC_D3DVERTEXBLENDFLAGS(Value: X_D3DVERTEXBLENDFLAGS): D3DVERTEXBLENDFLAGS;
function EmuXB2PC_D3DCOLORWRITEENABLE(Value: X_D3DCOLORWRITEENABLE): DWORD;
function EmuXB2PC_D3DTEXTUREOP(Value: X_D3DTEXTUREOP): DWORD;
function EmuXB2PC_D3DCLEAR_FLAGS(Value: DWORD): DWORD;
function EmuXB2PC_D3DWRAP(Value: DWORD): DWORD;
function EmuXB2PC_D3DCULL(Value: X_D3DCULL): D3DCULL;

function EmuD3DVertex2PrimitiveCount(PrimitiveType: X_D3DPRIMITIVETYPE; VertexCount: int): INT;
function EmuD3DPrimitive2VertexCount(PrimitiveType: X_D3DPRIMITIVETYPE; PrimitiveCount: int): int;
function EmuPrimitiveType(PrimitiveType: X_D3DPRIMITIVETYPE): D3DPRIMITIVETYPE;
function EmuXB2PC_PSConstant(Value: X_D3DRenderStateType): DWORD;


// simple render state encoding lookup table
const X_D3DRSSE_UNK = $7fffffff;

// Code translated from Convert.cpp :

const
// lookup table for converting vertex count to primitive count
EmuD3DVertexToPrimitive: array [0..Ord(X_D3DPT_POLYGON)] of array [0..2-1] of {U}INT = (
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
    (0, 0), // NULL
    (1, 0), // X_D3DPT_POINTLIST
    (2, 0), // X_D3DPT_LINELIST
    (1, 1), // X_D3DPT_LINELOOP
    (1, 1), // X_D3DPT_LINESTRIP
    (3, 0), // X_D3DPT_TRIANGLELIST
    (1, 2), // X_D3DPT_TRIANGLESTRIP
    (1, 2), // X_D3DPT_TRIANGLEFAN
    (4, 0), // X_D3DPT_QUADLIST
    (2, 2), // X_D3DPT_QUADSTRIP
    (1, 0)  // X_D3DPT_POLYGON
);

const
// conversion table for xbox->pc primitive types
EmuPrimitiveTypeLookup: array [0..Ord(X_D3DPT_POLYGON)] of D3DPRIMITIVETYPE = (
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
    D3DPRIMITIVETYPE(0),   // NULL                 = 0
    D3DPT_POINTLIST,       // X_D3DPT_POINTLIST      = 1,
    D3DPT_LINELIST,        // X_D3DPT_LINELIST       = 2,
    D3DPT_LINESTRIP,       // X_D3DPT_LINELOOP       = 3,  Xbox
    D3DPT_LINESTRIP,       // X_D3DPT_LINESTRIP      = 4,
    D3DPT_TRIANGLELIST,    // X_D3DPT_TRIANGLELIST   = 5,
    D3DPT_TRIANGLESTRIP,   // X_D3DPT_TRIANGLESTRIP  = 6,
    D3DPT_TRIANGLEFAN,     // X_D3DPT_TRIANGLEFAN    = 7,
    D3DPT_TRIANGLELIST,    // X_D3DPT_QUADLIST       = 8,  Xbox
    D3DPT_TRIANGLESTRIP,   // X_D3DPT_QUADSTRIP      = 9,  Xbox
    D3DPT_TRIANGLEFAN      // X_D3DPT_POLYGON        = 10, Xbox
);

implementation

// is this format swizzled, and if so - how many BPP?
function EmuXBFormatIsSwizzled(Format: X_D3DFORMAT; pBPP: PDWord = nil): BOOL_;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  Result := TRUE;
  case Format of

    X_D3DFMT_L8,       // 0x00
    X_D3DFMT_AL8,      // 0x01
    X_D3DFMT_P8,       // 0x0B
    X_D3DFMT_A8:       // 0x19
      if Assigned(pBPP) then
        pBPP^ := 1;

    X_D3DFMT_A1R5G5B5, // 0x02
    X_D3DFMT_X1R5G5B5, // 0x03
    X_D3DFMT_A4R4G4B4, // 0x04
    X_D3DFMT_R5G6B5,   // 0x05
    X_D3DFMT_A8L8,     // 0x1A
    X_D3DFMT_R6G5B5,   // 0x27 Added by Dxbx
    X_D3DFMT_G8B8,     // 0x28
    X_D3DFMT_R8B8,     // 0x29 Added by Dxbx
    X_D3DFMT_D16,      // 0x2C Added by Dxbx
    X_D3DFMT_F16,      // 0x2D Added by Dxbx
    X_D3DFMT_L16,      // 0x32 Added by Dxbx
    X_D3DFMT_R5G5B5A1, // 0x38 Added by Dxbx
    X_D3DFMT_R4G4B4A4: // 0x39 Added by Dxbx
      if Assigned(pBPP) then
        pBPP^ := 2;

    X_D3DFMT_A8R8G8B8, // 0x06
    X_D3DFMT_X8R8G8B8, // 0x07
    X_D3DFMT_D24S8,    // 0x2A Added by Dxbx
    X_D3DFMT_F24S8,    // 0x2B Added by Dxbx
    X_D3DFMT_V16U16,   // 0x33 Added by Dxbx
    X_D3DFMT_A8B8G8R8, // 0x3A Added by Dxbx
    X_D3DFMT_B8G8R8A8, // 0x3B Added by Dxbx
    X_D3DFMT_R8G8B8A8: // 0x3C Added by Dxbx
      if Assigned(pBPP) then
        pBPP^ := 4;

  else
    Result := FALSE;
  end;
end;

// is this format yuv?
function EmuXBFormatIsYUV(Format: X_D3DFORMAT): BOOL_;
// Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  case Format of
    X_D3DFMT_YUY2,     // 0x24
    X_D3DFMT_UYVY:     // 0x25
      Result := TRUE;
  else
    Result := FALSE;
  end;
end;

// is this format compressed?
function EmuXBFormatIsCompressed(Format: X_D3DFORMAT): BOOL_;
// Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  case Format of
    X_D3DFMT_DXT1,     // 0x0C
    X_D3DFMT_DXT3,     // 0x0E
    X_D3DFMT_DXT5:     // 0x0F
      Result := TRUE;
  else
    Result := FALSE;
  end;
end;

// is this format linear?
function EmuXBFormatIsLinear(Format: X_D3DFORMAT; pBPP: PDWord = nil): BOOL_;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  Result := TRUE;
  case (Format) of
    X_D3DFMT_LIN_L8,       // 0x13 Added by Dxbx
    X_D3DFMT_LIN_A8:       // 0x1F Added by Dxbx
      if Assigned(pBPP) then
        pBPP^ := 1;

    X_D3DFMT_LIN_A1R5G5B5, // 0x10
    X_D3DFMT_LIN_R5G6B5,   // 0x11
    X_D3DFMT_LIN_R8B8,     // 0x16
    X_D3DFMT_LIN_G8B8,     // 0x17
    X_D3DFMT_LIN_AL8,      // 0x1B Added by Dxbx
    X_D3DFMT_LIN_X1R5G5B5, // 0x1C Added by Dxbx
    X_D3DFMT_LIN_A4R4G4B4, // 0x1D
    X_D3DFMT_LIN_A8L8,     // 0x20 Added by Dxbx
    X_D3DFMT_LIN_D16,      // 0x30
    X_D3DFMT_LIN_F16,      // 0x31 Added by Dxbx
    X_D3DFMT_LIN_L16,      // 0x35 Added by Dxbx
    X_D3DFMT_LIN_R6G5B5,   // 0x37 Added by Dxbx
    X_D3DFMT_LIN_R5G5B5A1, // 0x3D Added by Dxbx
    X_D3DFMT_LIN_R4G4B4A4, // 0x3E Added by Dxbx
    X_D3DFMT_INDEX16:      // 101 Added by Dxbx
      if Assigned(pBPP) then
        pBPP^ := 2;

    X_D3DFMT_LIN_A8R8G8B8, // 0x12
    X_D3DFMT_LIN_X8R8G8B8, // 0x1E
    X_D3DFMT_LIN_D24S8,    // 0x2E
    X_D3DFMT_LIN_F24S8,    // 0x2F Added by Dxbx
    X_D3DFMT_LIN_V16U16,   // 0x36 Added by Dxbx
    X_D3DFMT_LIN_A8B8G8R8, // 0x3F
    X_D3DFMT_LIN_B8G8R8A8, // 0x40 Added by Dxbx
    X_D3DFMT_LIN_R8G8B8A8: // 0x41 Added by Dxbx
      if Assigned(pBPP) then
        pBPP^ := 4;

    X_D3DFMT_VERTEXDATA:   // 100 Added by Dxbx
      ; // pBPP?
  else
    Result := FALSE;
  end;
end;

// convert from xbox to pc color formats
function EmuXB2PC_D3DFormat(aFormat: X_D3DFORMAT): D3DFORMAT;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  case aFormat of
    X_D3DFMT_L8: // Swizzled
      Result := D3DFMT_L8;

    X_D3DFMT_AL8: // Swizzled    // Cxbx NOTE: Hack: Alpha ignored, basically
    begin
      EmuWarning('X_D3DFMT_AL8 -> D3DFMT_L8');
      Result := D3DFMT_L8;
    end;

    X_D3DFMT_LIN_A1R5G5B5, // Linear
    X_D3DFMT_A1R5G5B5: // Swizzled
      Result := D3DFMT_A1R5G5B5;

    X_D3DFMT_X1R5G5B5: // Swizzled
      Result := D3DFMT_X1R5G5B5;

    X_D3DFMT_A8L8: // Swizzled
    begin
      EmuWarning('X_D3DFMT_A8L8 -> D3DFMT_R5G6B5');
      Result := D3DFMT_R5G6B5; // Cxbx NOTE: HACK: Totally and utterly wrong :)
    end;

    X_D3DFMT_A8: // Swizzled
      Result := D3DFMT_A8;

    X_D3DFMT_LIN_A4R4G4B4, // Linear
    X_D3DFMT_A4R4G4B4: // Swizzled
      Result := D3DFMT_A4R4G4B4;

    X_D3DFMT_LIN_R5G6B5, // Linear
    X_D3DFMT_R5G6B5: // Swizzled
      Result := D3DFMT_R5G6B5;

    X_D3DFMT_LIN_A8R8G8B8, // Linear
    X_D3DFMT_A8R8G8B8: // Swizzled
      Result := D3DFMT_A8R8G8B8;

    X_D3DFMT_LIN_R8B8: // Linear
    begin
      EmuWarning('X_D3DFMT_LIN_R8B8 -> D3DFMT_R5G6B5');
      Result := D3DFMT_R5G6B5; // Cxbx NOTE: HACK: Totally and utterly wrong :)
    end;

    X_D3DFMT_LIN_G8B8: // Linear
    begin
      EmuWarning('X_D3DFMT_LIN_G8B8 -> D3DFMT_R5G6B5');
      Result := D3DFMT_R5G6B5; // Cxbx NOTE: HACK: Totally and utterly wrong :)
    end;

    X_D3DFMT_A8B8G8R8: // Swizzled
    begin
      EmuWarning('X_D3DFMT_A8B8G8R8 -> D3DFMT_A8R8G8B8');
      Result := D3DFMT_A8R8G8B8; // Cxbx NOTE: HACK: R<->B Swapped!
    end;

    X_D3DFMT_LIN_A8B8G8R8: // Linear
    begin
      EmuWarning('X_D3DFMT_LIN_A8B8G8R8 -> D3DFMT_A8R8G8B8');
      Result := D3DFMT_A8R8G8B8; // Cxbx NOTE: HACK: R<->B Swapped!
    end;

    X_D3DFMT_LIN_X8R8G8B8, // Linear
    X_D3DFMT_X8R8G8B8: // Swizzled
      Result := D3DFMT_X8R8G8B8;

    X_D3DFMT_P8: // Swizzled
      Result := D3DFMT_P8;

    X_D3DFMT_DXT1: // Compressed
      Result := D3DFMT_DXT1;

    //X_D3DFMT_DXT2,
    X_D3DFMT_DXT3: // Compressed
      Result := D3DFMT_DXT3;

    //X_D3DFMT_DXT4,
    X_D3DFMT_DXT5: // Compressed
      Result := D3DFMT_DXT5;

    X_D3DFMT_YUY2: // Swizzled
      Result := D3DFMT_YUY2;

    X_D3DFMT_UYVY: // Swizzled
      Result := D3DFMT_UYVY;

    X_D3DFMT_LIN_D24S8, // Linear
    X_D3DFMT_D24S8: // Swizzled
      Result := D3DFMT_D24S8;

    X_D3DFMT_LIN_F24S8, // Linear - Dxbx addition
    X_D3DFMT_F24S8: // Swizzled
    begin
      EmuWarning('X_D3DFMT_F24S8 -> D3DFMT_D24S8');
      Result := D3DFMT_D24S8; // NOTE: Hack!! PC does not have D3DFMT_F24S8 (Float vs Int)
    end;

    X_D3DFMT_LIN_F16, // Linear - Dxbx addition
    X_D3DFMT_F16: // Swizzled - Dxbx addition
    begin
      EmuWarning('X_D3DFMT_F16 -> D3DFMT_D16');
      Result := D3DFMT_D16; // NOTE: Hack!! PC does not have D3DFMT_F16 (Float vs Int)
    end;

    X_D3DFMT_LIN_D16, // Linear
    X_D3DFMT_D16: // Swizzled
      Result := D3DFMT_D16; // TODO -oCXBX: D3DFMT_D16 on Xbox is always lockable

    X_D3DFMT_L6V5U5: // Swizzled
      Result := D3DFMT_L6V5U5;

    X_D3DFMT_V8U8: // Swizzled
      Result := D3DFMT_V8U8;

    X_D3DFMT_V16U16: // Swizzled
      Result := D3DFMT_V16U16;

    X_D3DFMT_VERTEXDATA:
      Result := D3DFMT_VERTEXDATA;

    X_D3DFORMAT($FFFFFFFF):
      Result := D3DFMT_UNKNOWN; // TODO -oCXBX: Not sure if this counts as swizzled or not...

    X_D3DFMT_INDEX16: // Dxbx addition : Pass-through internal format that shouldn't raise a warning :
      Result := D3DFMT_INDEX16;
  else
    DxbxKrnlCleanup('EmuXB2PC_D3DFormat: Unknown Format (0x%.08X)', [aFormat]);
    Result := D3DFORMAT(aFormat);
  end;
end;

// convert from pc to xbox color formats
function EmuPC2XB_D3DFormat(aFormat: D3DFORMAT): X_D3DFORMAT;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  // TODO -oDxbx: Complete this, and add a switch to prefer swizzled over linear formats (could be relevant)
  case aFormat of
    D3DFMT_YUY2:
      Result := X_D3DFMT_YUY2;
    D3DFMT_UYVY:
      Result := X_D3DFMT_UYVY;
    D3DFMT_R5G6B5:
      Result := X_D3DFMT_LIN_R5G6B5; // Linear
//      Result := X_D3DFMT_R5G6B5; // Swizzled
    D3DFMT_D24S8:
      Result := X_D3DFMT_D24S8; // Swizzled
    D3DFMT_DXT5:
      Result := X_D3DFMT_DXT5; // Compressed
    D3DFMT_DXT4:
      Result := X_D3DFMT_DXT4;
    D3DFMT_DXT3:
      Result := X_D3DFMT_DXT3; // Compressed
    D3DFMT_DXT2:
      Result := X_D3DFMT_DXT2;
    D3DFMT_DXT1:
      Result := X_D3DFMT_DXT1; // Compressed
    D3DFMT_A1R5G5B5:
      Result := X_D3DFMT_LIN_A1R5G5B5; // Linear
    D3DFMT_X8R8G8B8:
      Result := X_D3DFMT_LIN_X8R8G8B8; // Linear
//      Result := X_D3DFMT_X8R8G8B8; // Swizzled
    D3DFMT_A8R8G8B8:
//      Result := X_D3DFMT_LIN_A8R8G8B8; // Linear
      Result := X_D3DFMT_A8R8G8B8;

    D3DFMT_A4R4G4B4:
      Result := X_D3DFMT_LIN_A4R4G4B4; // Linear
//      Result := X_D3DFMT_A4R4G4B4; // Swizzled
    D3DFMT_L8:
        Result := X_D3DFMT_LIN_L8; // Linear
//        Result := X_D3DFMT_L8; // Swizzled
    D3DFMT_D16,
    D3DFMT_D16_LOCKABLE:
      Result := X_D3DFMT_D16_LOCKABLE; // Swizzled

    D3DFMT_UNKNOWN:
      Result := X_D3DFORMAT($FFFFFFFF);

// Dxbx additions :
    D3DFMT_L6V5U5:
      Result := X_D3DFMT_L6V5U5; // Swizzled

    D3DFMT_V8U8:
      Result := X_D3DFMT_V8U8; // Swizzled

    D3DFMT_V16U16:
      Result := X_D3DFMT_V16U16; // Swizzled

    D3DFMT_VERTEXDATA:
      Result := X_D3DFMT_VERTEXDATA;

    D3DFMT_INDEX16:
      Result := X_D3DFMT_INDEX16;

  else
    DxbxKrnlCleanup('EmuPC2XB_D3DFormat: Unknown Format (0x%.08X)', [Ord(aFormat)]);
    Result := X_D3DFORMAT(aFormat);
  end;
end;

// convert from xbox to pc d3d lock flags
function EmuXB2PC_D3DLock(Flags: DWORD): DWORD;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
var
  NewFlags: DWORD;
begin
  NewFlags := 0;

  // Need to convert the flags,
  //TODO -oCXBX: fix the xbox extensions
  // Dxbx note : Cxbx uses XOR here, that can't be right! We'll be using OR.
  if (Flags and X_D3DLOCK_NOFLUSH) > 0 then
    NewFlags := NewFlags or 0;

  if (Flags and X_D3DLOCK_NOOVERWRITE) > 0 then
    NewFlags := NewFlags or D3DLOCK_NOOVERWRITE;

  if (Flags and X_D3DLOCK_TILED) > 0 then
    NewFlags := NewFlags or 0;

  if (Flags and X_D3DLOCK_READONLY) > 0 then
    NewFlags := NewFlags or D3DLOCK_READONLY;

  Result := NewFlags;
end;

// Code translated from Convert.h :

// convert from xbox to pc multisample formats
function EmuXB2PC_D3DMULTISAMPLE_TYPE(aType: X_D3DMULTISAMPLE_TYPE): D3DMULTISAMPLE_TYPE;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  case aType and $FFFF of
    X_D3DMULTISAMPLE_NONE:
      Result := D3DMULTISAMPLE_NONE;

    X_D3DMULTISAMPLE_2_SAMPLES_MULTISAMPLE_LINEAR,
    X_D3DMULTISAMPLE_2_SAMPLES_MULTISAMPLE_QUINCUNX,
    X_D3DMULTISAMPLE_2_SAMPLES_SUPERSAMPLE_HORIZONTAL_LINEAR,
    X_D3DMULTISAMPLE_2_SAMPLES_SUPERSAMPLE_VERTICAL_LINEAR:
      Result := D3DMULTISAMPLE_2_SAMPLES;

    X_D3DMULTISAMPLE_4_SAMPLES_MULTISAMPLE_LINEAR,
    X_D3DMULTISAMPLE_4_SAMPLES_MULTISAMPLE_GAUSSIAN,
    X_D3DMULTISAMPLE_4_SAMPLES_SUPERSAMPLE_LINEAR,
    X_D3DMULTISAMPLE_4_SAMPLES_SUPERSAMPLE_GAUSSIAN:
      Result := D3DMULTISAMPLE_4_SAMPLES;

    X_D3DMULTISAMPLE_9_SAMPLES_MULTISAMPLE_GAUSSIAN,
    X_D3DMULTISAMPLE_9_SAMPLES_SUPERSAMPLE_GAUSSIAN:
      Result := D3DMULTISAMPLE_9_SAMPLES;
  else
    EmuWarning('Unknown Multisample Type (0x%X)!'#13#10 +
               'If this value is greater than 0xFFFF contact blueshogun!', [aType] );

    Result := D3DMULTISAMPLE_NONE;
  end;
end;

// convert from pc to xbox multisample formats
function EmuPC2XB_D3DMULTISAMPLE_TYPE(aType: D3DMULTISAMPLE_TYPE): X_D3DMULTISAMPLE_TYPE;
// Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  case aType of
    D3DMULTISAMPLE_NONE:
      Result := X_D3DMULTISAMPLE_NONE;

    D3DMULTISAMPLE_2_SAMPLES:
      Result := X_D3DMULTISAMPLE_2_SAMPLES_MULTISAMPLE_QUINCUNX;

    D3DMULTISAMPLE_4_SAMPLES:
      Result := X_D3DMULTISAMPLE_4_SAMPLES_MULTISAMPLE_GAUSSIAN;

    D3DMULTISAMPLE_9_SAMPLES:
      Result := X_D3DMULTISAMPLE_9_SAMPLES_SUPERSAMPLE_GAUSSIAN;
  else
    EmuWarning('Unknown Multisample Type (0x%X)!', [Ord(aType)] );

    Result := $0011;
  end;
end;

// convert from xbox to pc texture transform state types
function EmuXB2PC_D3DTS(State: X_D3DTRANSFORMSTATETYPE): D3DTRANSFORMSTATETYPE;
// Branch:Dxxb  Translator:PatrickvL  Done:100
begin
  case State of
    X_D3DTS_VIEW:
      Result := D3DTS_VIEW;
    X_D3DTS_PROJECTION:
      Result := D3DTS_PROJECTION;
    X_D3DTS_TEXTURE0:
      Result := D3DTS_TEXTURE0;
    X_D3DTS_TEXTURE1:
      Result := D3DTS_TEXTURE1;
    X_D3DTS_TEXTURE2:
      Result := D3DTS_TEXTURE2;
    X_D3DTS_TEXTURE3:
      Result := D3DTS_TEXTURE3;
    X_D3DTS_WORLD:
      Result := D3DTS_WORLD;
    X_D3DTS_WORLD1:
      Result := D3DTS_WORLD1;
    X_D3DTS_WORLD2:
      Result := D3DTS_WORLD2;
    X_D3DTS_WORLD3:
      Result := D3DTS_WORLD3;
  else
    DxbxKrnlCleanup('Unknown Transform State Type (%d)', [Ord(State)]);

    Result := Low(Result); // Never reached
  end;
end;

// convert from xbox to pc blend ops
function EmuXB2PC_D3DBLENDOP(Value: X_D3DBLENDOP): D3DBLENDOP;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  case(Value) of
    X_D3DBLENDOP_ADD:
      Result := D3DBLENDOP_ADD;
    X_D3DBLENDOP_SUBTRACT:
      Result := D3DBLENDOP_SUBTRACT;
    X_D3DBLENDOP_REVSUBTRACT:
      Result := D3DBLENDOP_REVSUBTRACT;
    X_D3DBLENDOP_MIN:
      Result := D3DBLENDOP_MIN;
    X_D3DBLENDOP_MAX:
      Result := D3DBLENDOP_MAX;
    X_D3DBLENDOP_ADDSIGNED:
    begin
      DxbxKrnlCleanup('D3DBLENDOP_ADDSIGNED is not supported!');
      Result := D3DBLENDOP_ADD;
    end;
    X_D3DBLENDOP_REVSUBTRACTSIGNED:
    begin
      DxbxKrnlCleanup('D3DBLENDOP_REVSUBTRACTSIGNED is not supported!');
      Result := D3DBLENDOP_REVSUBTRACT;
    end;
  else

    DxbxKrnlCleanup('Unknown D3DBLENDOP (0x%.08X)', [Ord(Value)]);

    Result := D3DBLENDOP(Value);
  end;
end;

// convert from xbox to pc blend types
function EmuXB2PC_D3DBLEND(Value: X_D3DBLEND): D3DBLEND;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  case Value of
    X_D3DBLEND_ZERO               : Result := D3DBLEND_ZERO;
    X_D3DBLEND_ONE                : Result := D3DBLEND_ONE;
    X_D3DBLEND_SRCCOLOR           : Result := D3DBLEND_SRCCOLOR;
    X_D3DBLEND_INVSRCCOLOR        : Result := D3DBLEND_INVSRCCOLOR;
    X_D3DBLEND_SRCALPHA           : Result := D3DBLEND_SRCALPHA;
    X_D3DBLEND_INVSRCALPHA        : Result := D3DBLEND_INVSRCALPHA;
    X_D3DBLEND_DESTALPHA          : Result := D3DBLEND_DESTALPHA;
    X_D3DBLEND_INVDESTALPHA       : Result := D3DBLEND_INVDESTALPHA;
    X_D3DBLEND_DESTCOLOR          : Result := D3DBLEND_DESTCOLOR;
    X_D3DBLEND_INVDESTCOLOR       : Result := D3DBLEND_INVDESTCOLOR;
    X_D3DBLEND_SRCALPHASAT        : Result := D3DBLEND_SRCALPHASAT;
(* Xbox only :
    X_D3DBLEND_CONSTANTCOLOR      : Result := ; // $8001,
    X_D3DBLEND_INVCONSTANTCOLOR   : Result := ; // $8002,
    X_D3DBLEND_CONSTANTALPHA      : Result := ; // $8003,
    X_D3DBLEND_INVCONSTANTALPHA   : Result := ; // $8004,
   Xbox doesn't support :
    // D3DBLEND_BOTHSRCALPHA       = 12,
    // D3DBLEND_BOTHINVSRCALPHA    = 13,
*)
  else
    DxbxKrnlCleanup('Unknown Xbox D3DBLEND Extension (0x%.08X)', [Ord(Value)]);

    Result := D3DBLEND(Value);
  end;
end;

// convert from xbox to pc comparison functions
function EmuXB2PC_D3DCMPFUNC(Value: X_D3DCMPFUNC): D3DCMPFUNC;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  Result := D3DCMPFUNC((Ord(Value) and $F) + 1);
end;

// convert from xbox to pc fill modes
function EmuXB2PC_D3DFILLMODE(Value: X_D3DFILLMODE): D3DFILLMODE;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  case Value of
    X_D3DFILL_POINT:
      Result := D3DFILL_POINT;
    X_D3DFILL_WIREFRAME:
      Result := D3DFILL_WIREFRAME;
  else // X_D3DFILL_SOLID:
    Result := D3DFILL_SOLID;
  end;
end;

// convert from xbox to pc shade modes
function EmuXB2PC_D3DSHADEMODE(Value: X_D3DSHADEMODE): D3DSHADEMODE;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  Result := D3DSHADEMODE((Ord(Value) and $3) + 1);
end;

// convert from xbox to pc stencilop modes
function EmuXB2PC_D3DSTENCILOP(Value: X_D3DSTENCILOP): D3DSTENCILOP;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  case(Value)of
    X_D3DSTENCILOP_KEEP:
      Result := D3DSTENCILOP_KEEP;
    X_D3DSTENCILOP_ZERO:
      Result := D3DSTENCILOP_ZERO;
    X_D3DSTENCILOP_REPLACE:
      Result := D3DSTENCILOP_REPLACE;
    X_D3DSTENCILOP_INCRSAT:
      Result := D3DSTENCILOP_INCRSAT;
    X_D3DSTENCILOP_DECRSAT:
      Result := D3DSTENCILOP_DECRSAT;
    X_D3DSTENCILOP_INVERT:
      Result := D3DSTENCILOP_INVERT;
    X_D3DSTENCILOP_INCR:
      Result := D3DSTENCILOP_INCR;
    X_D3DSTENCILOP_DECR:
      Result := D3DSTENCILOP_DECR;

  else //default:
    DxbxKrnlCleanup('Unknown D3DSTENCILOP (0x%.08X)', [Ord(Value)]);
    Result := D3DSTENCILOP(Value);
  end;
end;

// convert from Xbox direct3d to PC direct3d enumeration
function EmuXB2PC_D3DVERTEXBLENDFLAGS(Value: X_D3DVERTEXBLENDFLAGS): D3DVERTEXBLENDFLAGS;
// Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  case(Value)of
    X_D3DVBF_DISABLE           : Result := D3DVBF_DISABLE;
    X_D3DVBF_1WEIGHTS          : Result := D3DVBF_1WEIGHTS;
    X_D3DVBF_2WEIGHTS          : Result := D3DVBF_2WEIGHTS;
    X_D3DVBF_3WEIGHTS          : Result := D3DVBF_3WEIGHTS;
(* Xbox only :
    X_D3DVBF_2WEIGHTS2MATRICES : Result := ;
    X_D3DVBF_3WEIGHTS3MATRICES : Result := ;
    X_D3DVBF_4WEIGHTS4MATRICES : Result := ;
   Xbox doesn't support :
    D3DVBF_TWEENING = 255,
    D3DVBF_0WEIGHTS = 256
*)
  else //default:
    DxbxKrnlCleanup('Unsupported D3DVERTEXBLENDFLAGS (%d)', [Ord(Value)]);
    Result := D3DVERTEXBLENDFLAGS(Value);
  end;
end;

function EmuXB2PC_D3DCOLORWRITEENABLE(Value: X_D3DCOLORWRITEENABLE): DWORD;
// Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  Result := 0;
  if (Value and X_D3DCOLORWRITEENABLE_RED) > 0 then
    Result := Result or D3DCOLORWRITEENABLE_RED;
  if (Value and X_D3DCOLORWRITEENABLE_GREEN) > 0 then
    Result := Result or D3DCOLORWRITEENABLE_GREEN;
  if (Value and X_D3DCOLORWRITEENABLE_BLUE) > 0 then
    Result := Result or D3DCOLORWRITEENABLE_BLUE;
  if (Value and X_D3DCOLORWRITEENABLE_ALPHA) > 0 then
    Result := Result or D3DCOLORWRITEENABLE_ALPHA;
end;

function EmuXB2PC_D3DTEXTUREOP(Value: X_D3DTEXTUREOP): DWORD;
// Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  case Value of
    X_D3DTOP_DISABLE: Result := D3DTOP_DISABLE;
    X_D3DTOP_SELECTARG1: Result := D3DTOP_SELECTARG1;
    X_D3DTOP_SELECTARG2: Result := D3DTOP_SELECTARG2;
    X_D3DTOP_MODULATE: Result := D3DTOP_MODULATE;
    X_D3DTOP_MODULATE2X: Result := D3DTOP_MODULATE2X;
    X_D3DTOP_MODULATE4X: Result := D3DTOP_MODULATE4X;
    X_D3DTOP_ADD: Result := D3DTOP_ADD;
    X_D3DTOP_ADDSIGNED: Result := D3DTOP_ADDSIGNED;
    X_D3DTOP_ADDSIGNED2X: Result := D3DTOP_ADDSIGNED2X;
    X_D3DTOP_SUBTRACT: Result := D3DTOP_SUBTRACT;
    X_D3DTOP_ADDSMOOTH: Result := D3DTOP_ADDSMOOTH;
    X_D3DTOP_BLENDDIFFUSEALPHA: Result := D3DTOP_BLENDDIFFUSEALPHA;
    X_D3DTOP_BLENDCURRENTALPHA: Result := D3DTOP_BLENDCURRENTALPHA;
    X_D3DTOP_BLENDTEXTUREALPHA: Result := D3DTOP_BLENDTEXTUREALPHA;
    X_D3DTOP_BLENDFACTORALPHA: Result := D3DTOP_BLENDFACTORALPHA;
    X_D3DTOP_BLENDTEXTUREALPHAPM: Result := D3DTOP_BLENDTEXTUREALPHAPM;
    X_D3DTOP_PREMODULATE: Result := D3DTOP_PREMODULATE;
    X_D3DTOP_MODULATEALPHA_ADDCOLOR: Result := D3DTOP_MODULATEALPHA_ADDCOLOR;
    X_D3DTOP_MODULATECOLOR_ADDALPHA: Result := D3DTOP_MODULATECOLOR_ADDALPHA;
    X_D3DTOP_MODULATEINVALPHA_ADDCOLOR: Result := D3DTOP_MODULATEINVALPHA_ADDCOLOR;
    X_D3DTOP_MODULATEINVCOLOR_ADDALPHA: Result := D3DTOP_MODULATEINVCOLOR_ADDALPHA;
    X_D3DTOP_DOTPRODUCT3: Result := D3DTOP_DOTPRODUCT3;
    X_D3DTOP_MULTIPLYADD: Result := D3DTOP_MULTIPLYADD;
    X_D3DTOP_LERP: Result := D3DTOP_LERP;
    X_D3DTOP_BUMPENVMAP: Result := D3DTOP_BUMPENVMAP;
    X_D3DTOP_BUMPENVMAPLUMINANCE: Result := D3DTOP_BUMPENVMAPLUMINANCE;
  else
    Result := 0;
  end;
end;

function EmuXB2PC_D3DCLEAR_FLAGS(Value: DWORD): DWORD;
// Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  Result := 0;

  // TODO -oCXBX: D3DCLEAR_TARGET_A, *R, *G, *B don't exist on windows
  if (Value and (not X_D3DCLEAR_ALL_SUPPORTED)) > 0 then
    EmuWarning('Unsupported Flag(s) for IDirect3DDevice_Clear: 0x%.08X', [Value and (not X_D3DCLEAR_ALL_SUPPORTED)]);

  if (Value and X_D3DCLEAR_TARGET) > 0 then
    Result := Result or D3DCLEAR_TARGET;
  if (Value and X_D3DCLEAR_ZBUFFER) > 0 then
    Result := Result or D3DCLEAR_ZBUFFER;
  if (Value and X_D3DCLEAR_STENCIL) > 0 then
    Result := Result or D3DCLEAR_STENCIL;
end;

function EmuXB2PC_D3DWRAP(Value: DWORD): DWORD;
// Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  Result := 0;
  if (Value and X_D3DWRAP_U) > 0 then Result := Result or D3DWRAP_U;
  if (Value and X_D3DWRAP_V) > 0 then Result := Result or D3DWRAP_V;
  if (Value and X_D3DWRAP_W) > 0 then Result := Result or D3DWRAP_W;
end;

function EmuXB2PC_D3DCULL(Value: X_D3DCULL): D3DCULL;
// Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  case (Value) of
    X_D3DCULL_NONE: // 0
      Result := D3DCULL_NONE;
    X_D3DCULL_CW: // $900
      Result := D3DCULL_CW;
    X_D3DCULL_CCW: // $901
      Result := D3DCULL_CCW;
  else
    DxbxKrnlCleanup('Unknown Cullmode (%d)', [Ord(Value)]);
    Result := D3DCULL(Value);
  end;
end;

// convert from vertex count to primitive count (Xbox)
function EmuD3DVertex2PrimitiveCount(PrimitiveType: X_D3DPRIMITIVETYPE; VertexCount: int): INT;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  Result := ((VertexCount - EmuD3DVertexToPrimitive[Ord(PrimitiveType)][1]) div EmuD3DVertexToPrimitive[Ord(PrimitiveType)][0]);
end;

// convert from primitive count to vertex count (Xbox)
function EmuD3DPrimitive2VertexCount(PrimitiveType: X_D3DPRIMITIVETYPE; PrimitiveCount: int): int;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  Result := (((PrimitiveCount)*EmuD3DVertexToPrimitive[Ord(PrimitiveType)][0]) + EmuD3DVertexToPrimitive[Ord(PrimitiveType)][1]);
end;

// convert xbox->pc primitive type
function EmuPrimitiveType(PrimitiveType: X_D3DPRIMITIVETYPE): D3DPRIMITIVETYPE;
// Branch:shogun  Revision:162  Translator:PatrickvL  Done:100
begin
  if Ord(PrimitiveType) >= Ord(X_D3DPT_MAX) then
    Result := D3DPRIMITIVETYPE($7FFFFFFF)
  else
    Result := EmuPrimitiveTypeLookup[Ord(PrimitiveType)];
end;

function EmuXB2PC_PSConstant(Value: X_D3DRenderStateType): DWORD;
// Branch:Dxbx  Translator:PatrickvL  Done:100
begin
  case Value of
    X_D3DRS_PSCONSTANT0_0: Result := 0;
    X_D3DRS_PSCONSTANT0_1: Result := 2;
    X_D3DRS_PSCONSTANT0_2: Result := 4;
    X_D3DRS_PSCONSTANT0_3: Result := 6;
    X_D3DRS_PSCONSTANT0_4: Result := 8;
    X_D3DRS_PSCONSTANT0_5: Result := 10;
    X_D3DRS_PSCONSTANT0_6: Result := 12;
    X_D3DRS_PSCONSTANT0_7: Result := 14;

    X_D3DRS_PSCONSTANT1_0: Result := 1;
    X_D3DRS_PSCONSTANT1_1: Result := 3;
    X_D3DRS_PSCONSTANT1_2: Result := 5;
    X_D3DRS_PSCONSTANT1_3: Result := 7;
    X_D3DRS_PSCONSTANT1_4: Result := 9;
    X_D3DRS_PSCONSTANT1_5: Result := 11;
    X_D3DRS_PSCONSTANT1_6: Result := 13;
    X_D3DRS_PSCONSTANT1_7: Result := 15;
  else
    Result := 0;
    EmuWarning('Unsupported Value for EmuXB2PC_PSConstant: 0x%.08X', [Value]);
  end;
end;

end.

