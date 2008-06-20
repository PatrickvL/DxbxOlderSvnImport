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
unit uEmuKrnlXe;

{$INCLUDE ..\Dxbx.inc}

interface

uses
  // Delphi
  SysUtils,
  // Jedi
  JwaWinType,
  JwaWinBase,
  JwaWinNT,
  JwaNative,
  JwaNTStatus,
  // OpenXDK
  XboxKrnl,
  // Dxbx
  uLog,
  uXbe,
  uEmuFS,
  uEmuFile,
  uEmuXapi,
  uEmuKrnl,
  uDxbxKrnl;

function {326}xboxkrnl_XeImageFileName(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE
function {327}xboxkrnl_XeLoadSection(
  Section: PXBE_SECTION // In, out
  ): NTSTATUS; stdcall; // Source: XBMC
function {328}xboxkrnl_XeUnloadSection(
  Section: PXBE_SECTION // In, out
  ): NTSTATUS; stdcall; // Source: XBMC
function {355}xboxkrnl_XePublicKeyData(): NTSTATUS; stdcall; // UNKNOWN_SIGNATURE

implementation

function xboxkrnl_XeImageFileName(): NTSTATUS; stdcall;
begin
  EmuSwapFS(); // Win2k/XP FS
  Result := Unimplemented('XeImageFileName');
  EmuSwapFS(); // Xbox FS
end;

// XeLoadSection:
// Adds one to the reference count of the specified section and loads if the
// count is now above zero.
//
// New to the XBOX.
function {327}xboxkrnl_XeLoadSection(
  Section: PXBE_SECTION // In, out
  ): NTSTATUS; stdcall; // Source: XBMC
begin
  EmuSwapFS(); // Win2k/XP FS
  Result := Unimplemented('XeLoadSection');
  EmuSwapFS(); // Xbox FS
end;

// XeUnloadSection:
// Subtracts one from the reference count of the specified section and loads
// if the count is now below zero.
//
// New to the XBOX.
function {328}xboxkrnl_XeUnloadSection(
  Section: PXBE_SECTION // In, out
  ): NTSTATUS; stdcall; // Source: XBMC
begin
  EmuSwapFS(); // Win2k/XP FS
  Result := Unimplemented('XeUnloadSection');
  EmuSwapFS(); // Xbox FS
end;

function xboxkrnl_XePublicKeyData(): NTSTATUS; stdcall;
begin
  EmuSwapFS(); // Win2k/XP FS
  Result := Unimplemented('XePublicKeyData');
  EmuSwapFS(); // Xbox FS
end;

end.
