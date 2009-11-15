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
unit uConsts;

{$INCLUDE Dxbx.inc}

interface

const
  DLL_IMAGE_BASE = $10000000;
  MAXIMUM_XBOX_THREADS = 256;

  CCXBXKRNLDLLNAME = 'CxbxKrnl.dll';
  CCXBXDLLNAME = 'Cxbx.dll';
  CDXBXKRNLDLLNAME = 'DxbxKrnl.dll';
  CDXBXDLLNAME = 'Dxbx.dll';

  // Application Versions
{$IFDEF DXBX_DEBUG}
  _DXBX_VERSION = '0.0.0.10 Debug';
{$ELSE}
  _DXBX_VERSION = '0.0.0.19';
{$ENDIF}
  _XDK_TRACKER_VERSION = '2.0.2.0';


  // Dialog Filters
  DIALOG_FILTER_TEXT = 'Text Documents (*.txt)|*.txt';
  DIALOG_FILTER_EXE = 'Windows Executables (*.exe)|*.exe';
  DIALOG_FILTER_XBE = 'Xbox Executables (*.xbe)|*.xbe';

  // XOR keys
  XOR_EP_DEBUG = $94859D4B; // Entry Point (Debug)
  XOR_EP_RETAIL = $A8FC57AB; // Entry Point (Retail)
  XOR_KT_DEBUG = $EFB1F152; // Kernel Thunk (Debug)
  XOR_KT_RETAIL = $5B6D40B6; // Kernel Thunk (Retail)

  XOR_ENTRY_POINT_CHIHIRO = $40B5C16E; // Thanks to martin_sw
  XOR_KERNEL_THUNK_CHIHIRO = $2290059D; // Thanks to martin_sw

  // game region flags for Xbe certificate
  XBEIMAGE_GAME_REGION_NA = $00000001;
  XBEIMAGE_GAME_REGION_JAPAN = $00000002;
  XBEIMAGE_GAME_REGION_RESTOFWORLD = $00000004;
  XBEIMAGE_GAME_REGION_MANUFACTURING = $80000000;

  XBEIMAGE_GAME_REGION_ALL = XBEIMAGE_GAME_REGION_NA + XBEIMAGE_GAME_REGION_JAPAN + XBEIMAGE_GAME_REGION_RESTOFWORLD;

  // media type flags for Xbe certificate
  XBEIMAGE_MEDIA_TYPE_HARD_DISK = $00000001;
  XBEIMAGE_MEDIA_TYPE_DVD_X2 = $00000002;
  XBEIMAGE_MEDIA_TYPE_DVD_CD = $00000004;
  XBEIMAGE_MEDIA_TYPE_CD = $00000008;
  XBEIMAGE_MEDIA_TYPE_DVD_5_RO = $00000010;
  XBEIMAGE_MEDIA_TYPE_DVD_9_RO = $00000020;
  XBEIMAGE_MEDIA_TYPE_DVD_5_RW = $00000040;
  XBEIMAGE_MEDIA_TYPE_DVD_9_RW = $00000080;
  XBEIMAGE_MEDIA_TYPE_DONGLE = $00000100;
  XBEIMAGE_MEDIA_TYPE_MEDIA_BOARD = $00000200;
  XBEIMAGE_MEDIA_TYPE_NONSECURE_HARD_DISK = $40000000;
  XBEIMAGE_MEDIA_TYPE_NONSECURE_MODE  = $80000000;
  XBEIMAGE_MEDIA_TYPE_MEDIA_MASK = $00FFFFFF;

  PE_FILE_ALIGN = $00000020; // File alignment
  PE_SEGM_ALIGN = $00000020; // Segment alignment

  // Copied from System.pas :
  EXCEPTION_CONTINUE_SEARCH    = 0;
  EXCEPTION_EXECUTE_HANDLER    = 1;
  EXCEPTION_CONTINUE_EXECUTION = -1;

  cXDK_TRACKER_DATA_FILE = 'GameData.dat';
  cXDk_TRACKER_XML_VERSION = '1.1';

  // Websites
  cWEBSITE_CXBX = 'http://www.caustik.com/cxbx/';
  cWEBSITE_SHADOWTJ = 'http://www.shadowtj.org';
  cWEBSITE_FORUM = 'http://forums.ngemu.com/dxbx-official-discussion/';

  cOpen = 'open';

  // Xbe File Format
  _MagicNumber = 'XBEH';

  CCXBXKRNLINIT = 'CxbxKrnlInit';
  CXBXKRNL_KERNELTHUNKTABLE = 'CxbxKrnl_KernelThunkTable';
  CSETXBEPATHMANGLEDNAME = '?SetXbePath@EmuShared@@QAEXPBD@Z';

  // Limits
  _RecentXbeLimit: Integer = 10;
  _RecentExeLimit: Integer = 10;

implementation

end.
