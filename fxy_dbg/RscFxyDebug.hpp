#include "idc.h"

#define FXY_DBG_FONT EtelkaMonospaceProBold

#define FXY_DBG_TRANSPARENT {0,0,0,0}

#define FXY_DBG_SOUND_NONE {"", 0, 0}


class RscFxyDebugText
{
	idc = -1;
	access = ReadWrite;
	type = CT_STATIC;
	style = ST_LEFT;
	
	x = 0; y = 0; w = 0; h = 0;
	
	text = "";
	fixedWidth = true;
	font = FXY_DBG_FONT;
	sizeEx = FXY_DBG_GUI_GRID_H;
	colorText[] = {1,1,1,1};
	
	colorBackground[] = FXY_DBG_TRANSPARENT;
	
	shadow = 0;
	colorShadow[] = FXY_DBG_TRANSPARENT;
};

class RscFxyDebugButton
{
	access = ReadWrite;
	type = CT_BUTTON;
	style = ST_CENTER;
	
	x = 0; y = 0; w = 0; h = 0;
	
	text = "";
	fixedWidth = true;
	font = FXY_DBG_FONT;
	sizeEx = 0.9 * FXY_DBG_GUI_GRID_H;
	colorText[] = {1,1,1,1};
	colorActive[] = {0,0,0,1};
	colorDisabled[] = {0.6,0.6,0.6,1};
	
	colorBackground[] = {0,0,0,0.7};
	colorBackgroundActive[] = {1,1,1,0.9};
	colorBackgroundDisabled[] = {0,0,0,0.7};
	
	offsetX = 0;
	offsetY = 0;
	offsetPressedX = 0;
	offsetPressedY = 0;
	colorFocused[] = {0,0,0,0.7};
	
	shadow = 0;
	colorShadow[] = FXY_DBG_TRANSPARENT;
	
	borderSize = 0;
	colorBorder[] = FXY_DBG_TRANSPARENT;
	
	soundPush[] = FXY_DBG_SOUND_NONE;
	soundClick[] = FXY_DBG_SOUND_NONE;
	soundEnter[] = FXY_DBG_SOUND_NONE;
	soundEscape[] = FXY_DBG_SOUND_NONE;
	
	onMouseEnter = "_this call fxy_dbg_eh_button_onMouseEnter";
	onMouseExit = "_this call fxy_dbg_eh_button_onMouseExit";
	onSetFocus = "ctrlSetFocus controlNull";
};

class RscFxyDebugEdit
{
	access = ReadWrite;
	type = CT_EDIT;
	style = ST_LEFT;
	
	x = 0; y = 0; w = 0; h = 0;
	
	text = "";
	size = 0.2;
	fixedWidth = true;
	font = FXY_DBG_FONT;
	sizeEx = FXY_DBG_GUI_GRID_H;
	colorText[] = {1,1,1,1};
	
	colorBackground[] = FXY_DBG_TRANSPARENT;
	colorSelection[] = {1,1,1,0.25};
	
	autocomplete = "";
	
	shadow = 0;
};

class RscFxyDebugListBox
{
	access = ReadWrite;
	type = CT_LISTBOX;
	style = 0;
	
	x = 0; y = 0; w = 0; h = 0;
	
	fixedWidth = true;
	font = FXY_DBG_FONT;
	sizeEx = FXY_DBG_GUI_GRID_H;
	colorText[] = {1,1,1,1};
	
	rowHeight = 0;
	
	colorBackground[] = FXY_DBG_TRANSPARENT;
	
	colorSelect[] = {0,0,0,1};
	colorSelect2[] = {0,0,0,1};
	
	colorSelectBackground[] = {1,1,1,1};
	colorSelectBackground2[] = {1,1,1,1};
	
	shadow = 0;
	
	arrowFull[] = FXY_DBG_TRANSPARENT;
	arrowEmpty[] = FXY_DBG_TRANSPARENT;
	
	autoScrollSpeed = -1;
	autoScrollDelay = 0;
	autoScrollRewind = false;
	
	colorScrollbar[] = {1,1,1,1};
	
	class ScrollBar
	{
		color[] = {1,1,1,0.6};
		colorActive[] = {1,1,1,0.6};
		colorDisabled[] = {1,1,1,0.6};
		
		thumb = "#(argb,8,8,3)color(0,0,0,1)";
		border = "#(argb,8,8,3)color(0,0,0,1)";
		arrowFull = "#(argb,8,8,3)color(0,0,0,1)";
		arrowEmpty = "#(argb,8,8,3)color(0,0,0,1)";
		
		shadow = 0;
	};
	
	period = 0;
	maxHistoryDelay = 1.0;
	soundSelect[] = FXY_DBG_SOUND_NONE;
};


class RscFxyDebug
{
	idd = -1;
	movingEnable = true;
	
	onLoad = "if (isnil 'fxy_dbg_init') then { call compile preprocessFileLineNumbers 'fxy_dbg\init.sqf' }; _this call fxy_dbg_eh_onLoad";
	onUnload = "_this call fxy_dbg_eh_onUnload";
	onKeyDown = "_this call fxy_dbg_eh_onKeyDown";
	onChildDestroyed = "_this call fxy_dbg_eh_onChildDestroyed";
	
	class Controls
	{
		class Background : RscFxyDebugText
		{
			idc = IDC_FXY_DBG_BACKGROUND;
			x = -9.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = -4 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 45.5 * FXY_DBG_GUI_GRID_W;
			h = 30.5 * FXY_DBG_GUI_GRID_H;
			
			d = 13.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			colorBackground[] = {0.25,0.25,0.25,0.9};
		};
		
		class Error : Background
		{
			idc = IDC_FXY_DBG_ERROR;
			h = 1.5 * FXY_DBG_GUI_GRID_H;
			
			style = ST_LEFT;
			colorText[] = {1,0,0,1};
			colorBackground[] = {0,0,0,0.8};
			
			moving = true;
		};
		
		/*class Header : Error
		{
			idc = IDC_FXY_DBG_HEADER;
			
			style = ST_RIGHT;
			text = "DEBUG CONSOLE";
			colorText[] = {1,1,1,1};
			colorBackground[] = FXY_DBG_TRANSPARENT;
			
			moving = true;
		};*/
		
		
		class EditorBackground : RscFxyDebugText
		{
			x = 4.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 11.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 31 * FXY_DBG_GUI_GRID_W;
			h = 12.5 * FXY_DBG_GUI_GRID_H;
			
			colorBackground[] = {0,0,0,0.5};
		};
		
		class Editor : RscFxyDebugEdit
		{
			idc = IDC_FXY_DBG_EDITOR;
			x = 4.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 11.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 31 * FXY_DBG_GUI_GRID_W;
			h = 12.5 * FXY_DBG_GUI_GRID_H;
			
			style = ST_MULTI;
			autocomplete = scripting;
			default = true;
			
			onSetFocus = "_this call fxy_dbg_eh_editor_onSetFocus";
			onKillFocus = "_this call fxy_dbg_eh_editor_onKillFocus";
		//	onKeyDown = "_this call fxy_dbg_eh_editor_onKeyDown";
			onKeyUp = "_this call fxy_dbg_eh_editor_onKeyUp";
		};
		
		
		class WatchBackground0 : RscFxyDebugText
		{
			x = 4.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = -2 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 31 * FXY_DBG_GUI_GRID_W;
			h = 2 * FXY_DBG_GUI_GRID_H;
			
			colorBackground[] = {0,0,0,0.5};
		};
		class WatchInput0 : RscFxyDebugEdit
		{
			idc = IDC_FXY_DBG_WATCH0;
			x = 4.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = -2 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 31 * FXY_DBG_GUI_GRID_W;
			h = 1 * FXY_DBG_GUI_GRID_H;
			
			colorBackground[] = {0,0,0,0.3};
			
			onSetFocus = "[_this select 0, 0] call fxy_dbg_eh_watch_onSetFocus";
			onKillFocus = "[_this select 0, 0] call fxy_dbg_eh_watch_onKillFocus";
			onKeyDown = "[_this select 0, 0, _this select 1] call fxy_dbg_eh_watch_onKeyDown";
		};
		class WatchOutput0 : RscFxyDebugEdit
		{
			idc = IDC_FXY_DBG_WATCH_RESULT0;
			x = 4.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = -1 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 31 * FXY_DBG_GUI_GRID_W;
			h = 1 * FXY_DBG_GUI_GRID_H;
			
			style = ST_NO_RECT;
			colorBackground[] = {0,0,0,0.8};
			
			onSetFocus = "_this call fxy_dbg_eh_watchOutput_onSetFocus";
			onKillFocus = "_this call fxy_dbg_eh_watchOutput_onKillFocus";
		};
		
		class WatchBackground1 : WatchBackground0
		{
			y = 0.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
		};
		class WatchInput1 : WatchInput0
		{
			idc = IDC_FXY_DBG_WATCH1;
			y = 0.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			
			onSetFocus = "[_this select 0, 1] call fxy_dbg_eh_watch_onSetFocus";
			onKillFocus = "[_this select 0, 1] call fxy_dbg_eh_watch_onKillFocus";
			onKeyDown = "[_this select 0, 1, _this select 1] call fxy_dbg_eh_watch_onKeyDown";
		};
		class WatchOutput1 : WatchOutput0
		{
			idc = IDC_FXY_DBG_WATCH_RESULT1;
			y = 1.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
		};
		
		class WatchBackground2 : WatchBackground0
		{
			y = 3 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
		};
		class WatchInput2 : WatchInput0
		{
			idc = IDC_FXY_DBG_WATCH2;
			y = 3 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			
			onSetFocus = "[_this select 0, 2] call fxy_dbg_eh_watch_onSetFocus";
			onKillFocus = "[_this select 0, 2] call fxy_dbg_eh_watch_onKillFocus";
			onKeyDown = "[_this select 0, 2, _this select 1] call fxy_dbg_eh_watch_onKeyDown";
		};
		class WatchOutput2 : WatchOutput0
		{
			idc = IDC_FXY_DBG_WATCH_RESULT2;
			y = 4 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
		};
		
		class WatchBackground3 : WatchBackground0
		{
			y = 5.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
		};
		class WatchInput3 : WatchInput0
		{
			idc = IDC_FXY_DBG_WATCH3;
			y = 5.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			
			onSetFocus = "[_this select 0, 3] call fxy_dbg_eh_watch_onSetFocus";
			onKillFocus = "[_this select 0, 3] call fxy_dbg_eh_watch_onKillFocus";
			onKeyDown = "[_this select 0, 3, _this select 1] call fxy_dbg_eh_watch_onKeyDown";
		};
		class WatchOutput3 : WatchOutput0
		{
			idc = IDC_FXY_DBG_WATCH_RESULT3;
			y = 6.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
		};
		
		class WatchBackground4 : WatchBackground0
		{
			y = 8 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
		};
		class WatchInput4 : WatchInput0
		{
			idc = IDC_FXY_DBG_WATCH4;
			y = 8 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			
			onSetFocus = "[_this select 0, 4] call fxy_dbg_eh_watch_onSetFocus";
			onKillFocus = "[_this select 0, 4] call fxy_dbg_eh_watch_onKillFocus";
			onKeyDown = "[_this select 0, 4, _this select 1] call fxy_dbg_eh_watch_onKeyDown";
		};
		class WatchOutput4 : WatchOutput0
		{
			idc = IDC_FXY_DBG_WATCH_RESULT4;
			y = 9 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
		};
		
		
		class TabBackground0 : RscFxyDebugText
		{
			idc = IDC_FXY_DBG_TAB_BACKGROUND0;
			x = 4.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 10.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 3 * FXY_DBG_GUI_GRID_W;
			h = 0.95 * FXY_DBG_GUI_GRID_H;
			
			colorBackground[] = {0,0,0,0.8};
			colorBackgroundSel[] = {0.1,0.1,0.1,0.8};
			colorBackgroundMod[] = {0.5,0,0,0.8};
			colorBackgroundSelMod[] = {0.5,0.1,0.1,0.8};
		};
		class Tab0 : RscFxyDebugButton
		{
			idc = IDC_FXY_DBG_TAB0;
			x = 4.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 10.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 3 * FXY_DBG_GUI_GRID_W;
			h = 0.95 * FXY_DBG_GUI_GRID_H;
			
			style = ST_LEFT + ST_DOWN;
			font = "LucidaConsoleB";
			sizeEx = 0.6 * FXY_DBG_GUI_GRID_H;
			
			colorBackground[] = {0,0,0,0};
			colorFocused[] = {0,0,0,0};
			
			onButtonClick = "[_this select 0, 0] call fxy_dbg_eh_tabs_onButtonClick";
		//	onSetFocus = "ctrlParent (_this select 0) call fxy_dbg_fn_returnFocus";
		};
		
		class TabBackground1 : TabBackground0
		{
			idc = IDC_FXY_DBG_TAB_BACKGROUND1;
			x = 8 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
		};
		class Tab1 : Tab0
		{
			idc = IDC_FXY_DBG_TAB1;
			x = 8 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			onButtonClick = "[_this select 0, 1] call fxy_dbg_eh_tabs_onButtonClick";
		};
		
		class TabBackground2 : TabBackground0
		{
			idc = IDC_FXY_DBG_TAB_BACKGROUND2;
			x = 11.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
		};
		class Tab2 : Tab0
		{
			idc = IDC_FXY_DBG_TAB2;
			x = 11.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			onButtonClick = "[_this select 0, 2] call fxy_dbg_eh_tabs_onButtonClick";
		};
		
		class TabBackground3 : TabBackground0
		{
			idc = IDC_FXY_DBG_TAB_BACKGROUND3;
			x = 15 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
		};
		class Tab3 : Tab0
		{
			idc = IDC_FXY_DBG_TAB3;
			x = 15 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			onButtonClick = "[_this select 0, 3] call fxy_dbg_eh_tabs_onButtonClick";
		};
		
		class TabBackground4 : TabBackground0
		{
			idc = IDC_FXY_DBG_TAB_BACKGROUND4;
			x = 18.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
		};
		class Tab4 : Tab0
		{
			idc = IDC_FXY_DBG_TAB4;
			x = 18.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			onButtonClick = "[_this select 0, 4] call fxy_dbg_eh_tabs_onButtonClick";
		};
		
		class TabBackground5 : TabBackground0
		{
			idc = IDC_FXY_DBG_TAB_BACKGROUND5;
			x = 22 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
		};
		class Tab5 : Tab0
		{
			idc = IDC_FXY_DBG_TAB5;
			x = 22 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			onButtonClick = "[_this select 0, 5] call fxy_dbg_eh_tabs_onButtonClick";
		};
		
		class TabBackground6 : TabBackground0
		{
			idc = IDC_FXY_DBG_TAB_BACKGROUND6;
			x = 25.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
		};
		class Tab6 : Tab0
		{
			idc = IDC_FXY_DBG_TAB6;
			x = 25.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			onButtonClick = "[_this select 0, 6] call fxy_dbg_eh_tabs_onButtonClick";
		};
		
		class TabBackground7 : TabBackground0
		{
			idc = IDC_FXY_DBG_TAB_BACKGROUND7;
			x = 29 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
		};
		class Tab7 : Tab0
		{
			idc = IDC_FXY_DBG_TAB7;
			x = 29 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			onButtonClick = "[_this select 0, 7] call fxy_dbg_eh_tabs_onButtonClick";
		};
		
		class TabBackground8 : TabBackground0
		{
			idc = IDC_FXY_DBG_TAB_BACKGROUND8;
			x = 32.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
		};
		class Tab8 : Tab0
		{
			idc = IDC_FXY_DBG_TAB8;
			x = 32.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			onButtonClick = "[_this select 0, 8] call fxy_dbg_eh_tabs_onButtonClick";
		};
		
		
		class ToggleFiles : RscFxyDebugButton
		{
			idc = IDC_FXY_DBG_TOGGLE_FILES;
			x = 4.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 24.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 2 * FXY_DBG_GUI_GRID_W;
			h = 1.5 * FXY_DBG_GUI_GRID_H;
			
			text = "<";
			text2 = ">";
			sizeEx = 1.5 * FXY_DBG_GUI_GRID_H;
			
			onButtonClick = "_this call fxy_dbg_eh_toggleFiles_onButtonClick";
		//	onSetFocus = "ctrlParent (_this select 0) call fxy_dbg_fn_returnFocus";
		};
		
		class ExecLocal : RscFxyDebugButton
		{
			idc = IDC_FXY_DBG_EXEC_LOCAL;
			x = 7 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 24.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 5.3 * FXY_DBG_GUI_GRID_W;
			h = 1.5 * FXY_DBG_GUI_GRID_H;
			
			text = "LOCAL";
			
			onButtonClick = "_this call fxy_dbg_eh_execLocal_onButtonClick";
		};
		
		class ExecServer : ExecLocal
		{
			idc = IDC_FXY_DBG_EXEC_SERVER;
			x = 12.8 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			text = "SERVER";
			
			onButtonClick = "_this call fxy_dbg_eh_execServer_onButtonClick";
		};
		
		class ExecGlobal : ExecLocal
		{
			idc = IDC_FXY_DBG_EXEC_GLOBAL;
			x = 18.6 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			text = "GLOBAL";
			
			onButtonClick = "_this call fxy_dbg_eh_execGlobal_onButtonClick";
		};
		
		class Performance : ExecLocal
		{
			idc = IDC_FXY_DBG_PERFORMANCE;
			x = 24.4 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			text = "PROFILE";
			
			onButtonClick = "_this call fxy_dbg_eh_performance_onButtonClick";
		};
		
		class Options : ExecLocal
		{
			idc = IDC_FXY_DBG_OPTIONS;
			x = 30.2 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			text = "OPTIONS";
			
			onButtonClick = "_this call fxy_dbg_eh_options_onButtonClick";
		};
		
		
		class FilesBackground : RscFxyDebugText
		{
			idc = IDC_FXY_DBG_FILES_BG;
			
			x = -9 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = -2 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 13 * FXY_DBG_GUI_GRID_W;
			h = 26 * FXY_DBG_GUI_GRID_H;
			
			colorBackground[] = {0,0,0,0.5};
		};
		
		class Files : RscFxyDebugListBox
		{
			idc = IDC_FXY_DBG_FILES;
			x = -9 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = -2 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 13 * FXY_DBG_GUI_GRID_W;
			h = 26 * FXY_DBG_GUI_GRID_H;
			
			onLBSelChanged = "_this call fxy_dbg_eh_file_list_onSelChanged";
			onLBDblClick = "_this call fxy_dbg_eh_file_list_onDblClick";
			onKeyDown = "_this call fxy_dbg_eh_file_list_onKeyDown";
		//	onSetFocus = "ctrlParent (_this select 0) call fxy_dbg_fn_returnFocus";
		};
		
		class Import : ExecLocal
		{
			idc = IDC_FXY_DBG_IMPORT;
			x = -9 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			w = 6.25 * FXY_DBG_GUI_GRID_W;
			
			text = "IMPORT";
			
			onButtonClick = "_this call fxy_dbg_eh_import_onButtonClick";
		};
		
		class Export : Import
		{
			idc = IDC_FXY_DBG_EXPORT;
			x = -2.25 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			text = "EXPORT";
			
			onButtonClick = "_this call fxy_dbg_eh_export_onButtonClick";
		};
	};
};

class RscFxyDebugSave
{
	idd = -1;
	movingEnable = true;
	
	onLoad = "_this call fxy_dbg_eh_save_onLoad";
	onUnload = "_this call fxy_dbg_eh_save_onUnload";
	
	class Controls
	{
		class Background : RscFxyDebugText
		{
		//	idc = IDC_FXY_DBG_SAVE_BACKGROUND;
			x = 6 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 9 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 28 * FXY_DBG_GUI_GRID_W;
			h = 5.5 * FXY_DBG_GUI_GRID_H;
			
			colorBackground[] = {0.25,0.25,0.25,0.9};
		};
		
		class Header : Background
		{
			idc = IDC_FXY_DBG_SAVE_HEADER;
			h = 1.5 * FXY_DBG_GUI_GRID_H;
			
			style = ST_LEFT;
			colorBackground[] = {0,0,0,0.8};
			
			moving = true;
		};
		
		class PathBackground : RscFxyDebugText
		{
			x = 6.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 11 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 27 * FXY_DBG_GUI_GRID_W;
			h = 1 * FXY_DBG_GUI_GRID_H;
			
			colorBackground[] = {0,0,0,0.5};
		};
		
		class Path : RscFxyDebugEdit
		{
			idc = IDC_FXY_DBG_SAVE_PATH;
			x = 6.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 11 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 27 * FXY_DBG_GUI_GRID_W;
			h = 1 * FXY_DBG_GUI_GRID_H;
			
		//	onSetFocus = "_this call fxy_dbg_eh_save_path_onSetFocus";
		//	onKillFocus = "_this call fxy_dbg_eh_save_path_onKillFocus";
			onKeyDown = "_this call fxy_dbg_eh_save_path_onKeyDown";
		};
		
		class Save : RscFxyDebugButton
		{
			idc = IDC_FXY_DBG_SAVE_SAVE;
			x = 23 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 12.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 5 * FXY_DBG_GUI_GRID_W;
			h = 1.5 * FXY_DBG_GUI_GRID_H;
			
			text = "SAVE";
			
			onButtonClick = "_this call fxy_dbg_eh_save_save_onButtonClick";
		};
		
		class Cancel : Save
		{
			idc = IDC_FXY_DBG_SAVE_CANCEL;
			x = 28.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			text = "CANCEL";
			
			onButtonClick = "_this call fxy_dbg_eh_save_cancel_onButtonClick";
		};
	};
};

class RscFxyDebugYnc
{
	idd = -1;
	movingEnable = true;
	
	onLoad = "_this call fxy_dbg_eh_ync_onLoad";
	onUnload = "_this call fxy_dbg_eh_ync_onUnload";
	
	class Controls
	{
		class Background : RscFxyDebugText
		{
		//	idc = IDC_FXY_DBG_YNC_BACKGROUND;
			x = 4 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 8.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 32 * FXY_DBG_GUI_GRID_W;
			h = 7 * FXY_DBG_GUI_GRID_H;
			
			colorBackground[] = {0.25,0.25,0.25,0.9};
		};
		
		class Header : Background
		{
			idc = IDC_FXY_DBG_YNC_HEADER;
			h = 1.5 * FXY_DBG_GUI_GRID_H;
			
			style = ST_LEFT;
			colorBackground[] = {0,0,0,0.8};
			
			moving = true;
		};
		
		class Text : RscFxyDebugText
		{
			idc = IDC_FXY_DBG_YNC_TEXT;
			x = 6 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 10.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 28 * FXY_DBG_GUI_GRID_W;
			h = 2.5 * FXY_DBG_GUI_GRID_H;
			
			style = ST_CENTER;
		};
		
		class Yes : RscFxyDebugButton
		{
			idc = IDC_FXY_DBG_YNC_YES;
			x = 11.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			y = 13.5 * FXY_DBG_GUI_GRID_H + FXY_DBG_GUI_GRID_Y;
			w = 5 * FXY_DBG_GUI_GRID_W;
			h = 1.5 * FXY_DBG_GUI_GRID_H;
			
			text = "YES";
			
			onButtonClick = "_this call fxy_dbg_eh_ync_yes_onButtonClick";
		};
		
		class No : Yes
		{
			idc = IDC_FXY_DBG_YNC_NO;
			x = 17.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			text = "NO";
			
			onButtonClick = "_this call fxy_dbg_eh_ync_no_onButtonClick";
		};
		
		class Cancel : Yes
		{
			idc = IDC_FXY_DBG_YNC_CANCEL;
			x = 23.5 * FXY_DBG_GUI_GRID_W + FXY_DBG_GUI_GRID_X;
			
			text = "CANCEL";
			
			onButtonClick = "_this call fxy_dbg_eh_ync_cancel_onButtonClick";
		};
	};
};
