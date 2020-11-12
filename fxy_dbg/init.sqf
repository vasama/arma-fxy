#include "idc.h"
#include "dik.h"
#include "ascii.h"

#define Struct_Get(s, i) ((s) select (i))
#define Struct_Set(s, i, v) ((s) set [i, v])

if (!isnil "fxy_dbg_init") exitWith {};
fxy_dbg_init = true;

// [string, int]
fxy_dbg_fn_padRight =
{
	local _str = toarray (_this select 0);
	local _len = _this select 1;
	local _cnt = count _str;

	if (_cnt > _len) exitWith { _this select 0 };

	_str resize _len;

	for "_i" from _cnt to _len - 1 do
	{
		_str set [_i, ASCII_SPACE];
	};

	tostring _str
};

// [array, index]
fxy_dbg_fn_array_delete =
{
	local _array = _this select 0;
	local _index = _this select 1;
	local _size = count _array;

	if (_index < 0 || _index >= _size || _size == 0) exitWith { _array };

	for "_i" from _index to _size - 1 do
	{
		_array set [_i, _array select (_i + 1)];
	};

	_array resize (_size - 1);
	_array
};

// [value, minCount] -> bool
local _fn_arrayCheck =
{
	local _value = _this select 0;
	!isnil "_value" && { typename _value == "ARRAY" && { count _value >= (_this select 1) } }
};

// [array, index, type, default] -> type
local _fn_safeSelect =
{
	local _array = _this select 0;
	local _index = _this select 1;

	if (_index >= count _array) exitWith { _this select 3 };

	local _value = _array select _index;
	if (isnil "_value" || { typename _value != (_this select 2) }) exitWith { _this select 3 };

	_value
};

// [rgba, rgba]
fxy_dbg_fn_combineColors =
{
	local _a = _this select 0;
	local _b = _this select 1;

	[
		((_a select 0) + (_b select 0) / 2),
		((_a select 1) + (_b select 1) / 2),
		((_a select 2) + (_b select 2) / 2),
		((_a select 3) + (_b select 3) / 2)
	]
};

// [code, any] -> [float time, int cycles]
fxy_dbg_fn_perf =
{
	local _code = _this select 0;
	_this = _this select 1;

	local _ta = diag_ticktime;
	for "_i" from 1 to 100 do _code;
	_ta = diag_ticktime - _ta;

	if (_ta > 1) exitWith { [_ta * 10, 100] };

	local _c = (99900) min round (((1 - _ta) * 100) / (_ta max 0.00001));

	local _tb = diag_ticktime;
	for "_i" from 1 to _c do _code;
	_tb = diag_ticktime - _tb;

	[(_ta + _tb) / (100 + _c) * 1000, 100 + _c]
};

fxy_dbg_beautify_whitespace = [ASCII_SPACE, ASCII_CARRIAGE_RETURN, ASCII_NEWLINE, ASCII_TAB];
fxy_dbg_beautify_braces = toarray "{}";
fxy_dbg_beautify_defnows = toarray "{};";
fxy_dbg_beautify_defnolf = toarray "{}[]();";

#define BEAUTIFY_INDENT_SIZE 2

// string -> string
fxy_dbg_fn_beautify =
{
	local _in = toarray _this;

	local _out = [];
//	_out resize count _in;

	local _indent = 0;

	local _ch = ASCII_CTRL_NUL;
	local _ws = false;
	local _lf = false;
	local _br = 0;

#define BEAUTIFY_WRITE(x) (_out set [count _out, x])
#define BEAUTIFY_INDENT() (for "_i" from 1 to (_indent * BEAUTIFY_INDENT_SIZE) do { BEAUTIFY_WRITE(ASCII_SPACE); })

	for "_i" from 0 to count _in - 1 do
	{
		local _char = _in select _i;

		switch (true) do
		{
			case (_char in fxy_dbg_beautify_whitespace):
			{
				if (_br == 0) then { _ws = true; };
			};

			case (_char == ASCII_LEFT_BRACE):
			{
				_br = _br + 1;
			};

			case (_char == ASCII_RIGHT_BRACE):
			{
				if (_br > 0) then
				{
					if (_ws) then { BEAUTIFY_WRITE(ASCII_SPACE) };
					for "_i" from 1 to _br do { BEAUTIFY_WRITE(ASCII_LEFT_BRACE); };
					_ch = ASCII_LEFT_BRACE;
					_br = 0;
				};

				_indent = _indent - 1;

				if (_lf && { !(_ch in fxy_dbg_beautify_braces) }) then
				{
					BEAUTIFY_WRITE(ASCII_NEWLINE);
					BEAUTIFY_INDENT();
				}
				else
				{
					_lf = false;
				};

				if (_ch in fxy_dbg_beautify_braces) then
				{
					BEAUTIFY_WRITE(ASCII_RIGHT_BRACE);
				}
				else
				{
					if (!_lf) then
					{
						BEAUTIFY_WRITE(ASCII_NEWLINE);
						BEAUTIFY_INDENT();
					};

					BEAUTIFY_WRITE(ASCII_RIGHT_BRACE);
					_lf = true;
				};

				_ch = ASCII_RIGHT_BRACE;
				_ws = false;
			};

			case (_char == ASCII_SEMICOLON):
			{
				if (_br > 0) then
				{
					if (_ws) then { BEAUTIFY_WRITE(ASCII_SPACE) };

					for "_i" from 1 to _br do
					{
						BEAUTIFY_WRITE(ASCII_NEWLINE);
						BEAUTIFY_INDENT();
						BEAUTIFY_WRITE(ASCII_LEFT_BRACE);
						BEAUTIFY_WRITE(ASCII_NEWLINE);
						_indent = _indent + 1;
						BEAUTIFY_INDENT();
					};

					_br = 0;
				};

				BEAUTIFY_WRITE(ASCII_SEMICOLON);
				_ch = ASCII_SEMICOLON;
				_ws = false;
				_lf = true;

				/*BEAUTIFY_WRITE(ASCII_NEWLINE);
				BEAUTIFY_INDENT();
				_lf = false;*/
			};

			default
			{
				if (_br > 0) then
				{
					if (_ws) then { BEAUTIFY_WRITE(ASCII_SPACE) };

					for "_i" from 1 to _br do
					{
						BEAUTIFY_WRITE(ASCII_NEWLINE);
						BEAUTIFY_INDENT();
						BEAUTIFY_WRITE(ASCII_LEFT_BRACE);
						BEAUTIFY_WRITE(ASCII_NEWLINE);
						_indent = _indent + 1;
						BEAUTIFY_INDENT();
					};

					_br = 0;
				};

				if (_lf && { !(_char in fxy_dbg_beautify_defnolf) }) then
				{
					BEAUTIFY_WRITE(ASCII_NEWLINE);
					BEAUTIFY_INDENT();
					_lf = false;
					_ws = false;
				};

				if (_ws && { !(_ch in fxy_dbg_beautify_defnows) }) then
				{
					BEAUTIFY_WRITE(ASCII_SPACE);
				};

				BEAUTIFY_WRITE(_char);
				_ch = _char;
				_ws = false;
			};
		};
	};

#undef BEAUTIFY_INDENT
#undef BEAUTIFY_WRITE

	tostring _out
};


fxy_dbg_enterKeys = [DIK_RETURN, DIK_NUMPADENTER];


/* SAVE DIALOG */

// [display]
fxy_dbg_eh_save_onLoad =
{
	_this select 0 displayCtrl IDC_FXY_DBG_SAVE_HEADER ctrlSetText fxy_dbg_save_head;
	_this select 0 displayCtrl IDC_FXY_DBG_SAVE_PATH ctrlSetText fxy_dbg_save_path;
};

// [display]
fxy_dbg_eh_save_onUnload =
{
	fxy_dbg_save_dispatch set [0, [fxy_dbg_save_code, fxy_dbg_save_result, fxy_dbg_save_path, fxy_dbg_save_args]];
};

// display
fxy_dbg_fn_save_save =
{
	fxy_dbg_save_path = ctrlText (_this displayCtrl IDC_FXY_DBG_SAVE_PATH);
	fxy_dbg_save_result = true;

	_this closeDisplay 0;
};

// [control, int key, bool shift, bool ctrl, bool alt]
fxy_dbg_eh_save_path_onKeyDown =
{
	if (_this select 1 in fxy_dbg_enterKeys) then
	{
		ctrlParent (_this select 0) call fxy_dbg_fn_save_save;
	};
};

// [control]
fxy_dbg_eh_save_save_onButtonClick =
{
	ctrlParent (_this select 0) call fxy_dbg_fn_save_save;
};

// [control]
fxy_dbg_eh_save_cancel_onButtonClick =
{
	fxy_dbg_save_path = "";
	ctrlParent (_this select 0) closeDisplay 0;
};

// [display, dispatch&, string, string, code, any args]
fxy_dbg_fn_save_create =
{
	fxy_dbg_save_result = false;
	fxy_dbg_save_head = _this select 2;
	fxy_dbg_save_path = _this select 3;
	fxy_dbg_save_code = _this select 4;
	fxy_dbg_save_args = _this select 5;
	fxy_dbg_save_dispatch = _this select 1;
	_this select 0 createDisplay "RscFxyDebugSave";
};



/* YES/NO/CANCEL DIALOG */

// [display]
fxy_dbg_eh_ync_onLoad =
{
	_this select 0 displayCtrl IDC_FXY_DBG_YNC_HEADER ctrlSetText fxy_dbg_ync_head;
	_this select 0 displayCtrl IDC_FXY_DBG_YNC_TEXT ctrlSetText fxy_dbg_ync_text;
};

// [display]
fxy_dbg_eh_ync_onUnload =
{
	fxy_dbg_ync_dispatch set [0, [fxy_dbg_ync_code, fxy_dbg_ync_result, fxy_dbg_ync_args]];
};

// [control]
fxy_dbg_eh_ync_yes_onButtonClick =
{
	fxy_dbg_ync_result = 1;
	ctrlParent (_this select 0) closeDisplay 0;
};

// [control]
fxy_dbg_eh_ync_no_onButtonClick =
{
	fxy_dbg_ync_result = 0;
	ctrlParent (_this select 0) closeDisplay 0;
};

// [control]
fxy_dbg_eh_ync_cancel_onButtonClick =
{
	fxy_dbg_ync_result = -1;
	ctrlParent (_this select 0) closeDisplay 0;
};

// [display, dispatch&, string, string, code]
fxy_dbg_fn_ync_create =
{
	fxy_dbg_ync_result = -1;
	fxy_dbg_ync_head = _this select 2;
	fxy_dbg_ync_text = _this select 3;
	fxy_dbg_ync_code = _this select 4;
	fxy_dbg_ync_args = _this select 5;
	fxy_dbg_ync_dispatch = _this select 1;
	_this select 0 createDisplay "RscFxyDebugYnc";
};



/* FILESYSTEM */

// [string, string] -> bool
fxy_dbg_fn_fs_compare =
{
	_this find (_this select 1) == 0
};

// [T[] (node/file), string name] -> int
fxy_dbg_fn_fs_find_index =
{
	local _name = _this select 1;
	local _index = -1;

	{
		//if _x.name == _name
		if ([_x select 0, _name] call fxy_dbg_fn_fs_compare) exitWith
		{
			_index = _foreachIndex;
		};
	} foreach (_this select 0);

	_index
};

// [T[] (T = node/file), string name] -> T
fxy_dbg_fn_fs_find =
{
	local _index = _this call fxy_dbg_fn_fs_find_index;
	if (_index == -1) then { nil } else { _this select 0 select _index }
};

// [T[] (T = node/file), string name] -> bool
fxy_dbg_fn_fs_remove =
{
	local _index = _this call fxy_dbg_fn_fs_find_index;
	[_this select 0, _index] call fxy_dbg_fn_array_delete;
	_index != -1
};

fxy_dbg_path_separator = ASCII_FORWARD_SLASH;
fxy_dbg_path_chars = toarray "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

// string -> path
fxy_dbg_fn_path_parse =
{
	scopename "path_parse";
	local _fail = false;
	local _src = toarray _this;
	local _path = [];
	local _str = [];

	for "_i" from 0 to count _src - 1 do
	{
		local _char = _src select _i;

		if (_char == fxy_dbg_path_separator) then
		{
			if (count _str > 0) then
			{
				_path set [count _path, tostring _str];
				_str = [];
			};
		}
		else
		{
			if (_char in fxy_dbg_path_chars) then
			{
				_str set [count _str, _char];
			}
			else
			{
				_fail = true;
				breakto "path_parse";
			};
		};
	};

	if (_fail || { count _path == 0 && { count _str == 0 } }) exitWith { [] };

	if (count _str > 0) then
	{
		_path set [count _path, tostring _str];
	};

	_path
};

// path -> string
fxy_dbg_fn_path_format =
{
	local _count = count _this;
	if (_count == 0) exitWith { "" };

	local _string = "";

	if (_count > 1) then
	{
		for "_i" from 0 to _count - 2 do
		{
			_string = _string + (_this select _i) + "/";
		};
	};

	_string = _string + (_this select (_count - 1));

	_string
};

/*
struct file
{
	string      name
	path        path
	string      data
	string      args
	int         tab
}

struct node
{
	string      name
	path        path
	node[]      nodes
	file[]      files
	bool        open
}

node[] filesystem
*/
#define File_New(path, name) [name, path, (path) call fxy_dbg_fn_path_format, "", "", -1]

#define File_GetName(f)		Struct_Get(f, 0)
#define File_GetPath(f)		Struct_Get(f, 1)
#define File_GetPathF(f)	Struct_Get(f, 2)
#define File_GetData(f)		Struct_Get(f, 3)
#define File_SetData(f, d)	Struct_Set(f, 3, d)
#define File_GetArgs(f)		Struct_Get(f, 4)
#define File_SetArgs(f, d)	Struct_Set(f, 4, d)
#define File_GetTab(f)		Struct_Get(f, 5)
#define File_SetTab(f, t)	Struct_Set(f, 5, t)

#define Node_New(path, name) [name, path, [], [], true]

#define Node_GetName(n)		Struct_Get(n, 0)
#define Node_GetPath(n)		Struct_Get(n, 1)
#define Node_GetNodes(n)	Struct_Get(n, 2)
#define Node_GetFiles(n)	Struct_Get(n, 3)
#define Node_GetOpen(n)		Struct_Get(n, 4)
#define Node_SetOpen(n, o)	Struct_Set(n, 4, o)

fxy_dbg_filesystem = Node_New([], "");

// [node[] result, node, path, index, length, bool create] -> node[]
fxy_dbg_fn_node_open_i =
{
	//append node to result
	_this select 0 set [count (_this select 0), _this select 1];

	//base case: if index >= length
	if (_this select 3 >= _this select 4) exitWith
	{
		//return result
		_this select 0
	};

	//_name = path[index]
	local _name = _this select 2 select (_this select 3);

	local _nodes = Node_GetNodes(_this select 1);
	local _node = [_nodes, _name] call fxy_dbg_fn_fs_find;

	//if node not found and create then create new node
	if (isnil "_node" && { _this select 5 }) then
	{
		local _path = +Node_GetPath(_this select 1);
		_path set [count _path, _name];

		_node = Node_New(_path, _name);
		_nodes set [count _nodes, _node];

		fxy_dbg_filesystem_modified = true;
	};

	if (isnil "_node") exitWith
	{
		nil
	};

	//search again in _node
	_this set [1, _node];
	_this set [3, (_this select 3) + 1];
	_this call fxy_dbg_fn_node_open_i
};

// [path, bool create] -> node[]
fxy_dbg_fn_node_open =
{
	[[], fxy_dbg_filesystem, _this select 0, 0, count (_this select 0), _this select 1] call fxy_dbg_fn_node_open_i
};

// [path (file), bool create] -> node[]
fxy_dbg_fn_node_open_ex =
{
	if (count (_this select 0) == 0) exitWith { nil };
	[[], fxy_dbg_filesystem, _this select 0, 0, count (_this select 0) - 1, _this select 1] call fxy_dbg_fn_node_open_i
};

// node[]
fxy_dbg_fn_tree_clean =
{
	local _name = "";

	for "_i" from count _this - 1 to 0 step -1 do
	{
		local _node = _this select _i;
		if (_name != "") then { [Node_GetNodes(_node), _name] call fxy_dbg_fn_fs_remove; };
		if (count Node_GetFiles(_node) > 0 || { count Node_GetNodes(_node) > 0 }) exitWith {};
		_name = Node_GetName(_node);
	};
};

// path
fxy_dbg_fn_node_delete =
{
	local _tree = [_this, false] call fxy_dbg_fn_node_open_ex;
	if (isnil "_tree") exitWith {};

	local _name = _this select (count _this - 1);

	local _nodes = Node_GetNodes(_tree select (count _tree - 1));
	if !([_nodes, _name] call fxy_dbg_fn_fs_remove) exitWith {};
	fxy_dbg_filesystem_modified = true;

	_tree call fxy_dbg_fn_tree_clean;
};

// [path, bool create] -> file
fxy_dbg_fn_file_open =
{
	local _path = _this select 0;
	if (count _path == 0) exitWith { nil };

	local _name = _path select (count _path - 1);

	local _node = [_path, _this select 1] call fxy_dbg_fn_node_open_ex;
	if (isnil "_node") exitWith	{ nil };
	_node = _node select (count _node - 1);

	local _files = Node_GetFiles(_node);
	local _file = [_files, _name] call fxy_dbg_fn_fs_find;

	// if file not found
	if (isnil "_file") then
	{
		// if create
		if (_this select 1) then
		{
			// create new file
			local _path = +Node_GetPath(_node);
			_path set [count _path, _name];

			_file = File_New(_path, _name);
			_files set [count _files, _file];

			fxy_dbg_filesystem_modified = true;

			_file
		}
		else
		{
			nil
		};
	}
	else
	{
		_file
	};
};

// path
fxy_dbg_fn_file_delete =
{
	local _tree = [_this, false] call fxy_dbg_fn_node_open_ex;
	if (isnil "_tree") exitWith {};

	local _name = _this select (count _this - 1);

	local _files = Node_GetFiles(_tree select (count _tree - 1));
	if !([_files, _name] call fxy_dbg_fn_fs_remove) exitWith {};
	fxy_dbg_filesystem_modified = true;

	_tree call fxy_dbg_fn_tree_clean;
};

// [file, string, string]
fxy_dbg_fn_file_write =
{
	File_SetData(_this select 0, _this select 1);
	File_SetArgs(_this select 0, _this select 2);
	fxy_dbg_filesystem_modified = true;
};

// node
fxy_dbg_fn_node_toggle =
{
	Node_SetOpen(_this, !Node_GetOpen(_this));
};

// [node, code, args, bool recursive]
fxy_dbg_fn_node_foreachFile =
{
	local _code = _this select 1;
	local _args = _this select 2;

	{
		[_x, _args] call _code;
	} foreach Node_GetFiles(_this select 0);

	if (_this select 3) then
	{
		{
			[_x, _code, _args, true] call fxy_dbg_fn_node_foreachFile;
		} foreach Node_GetNodes(_this select 0);
	};
};

// [file[] result, node, string path] -> file[]
fxy_dbg_fn_filesystem_serialize_i =
{
	local _result = _this select 0;
	local _path = _this select 2;

	// foreach file
	{
		_result set [count _result, [_path + File_GetName(_x), File_GetData(_x), File_GetArgs(_x)]];
	} foreach Node_GetFiles(_this select 1);

	// foreach node
	{
		[_result, _x, _path + Node_GetName(_x) + "/"] call fxy_dbg_fn_filesystem_serialize_i;
	} foreach Node_GetNodes(_this select 1);

	_result
};

fxy_dbg_fn_filesystem_serialize =
{
	if (fxy_dbg_filesystem_modified) then
	{
		local _files = [[], fxy_dbg_filesystem, ""] call fxy_dbg_fn_filesystem_serialize_i;
		profileNamespace setVariable ["fxy_dbg_files", _files];
		fxy_dbg_filesystem_modified = false;
	};
};


// load files
local _files = profileNamespace getVariable ["fxy_dbg_files", []];

if ([_files, 0] call _fn_arrayCheck) then
{
	{
		if ([_x, 1] call _fn_arrayCheck) then
		{
			local _path = [_x, 0, "STRING", ""] call _fn_safeSelect;
			_path = _path call fxy_dbg_fn_path_parse;
			if (count _path == 0) exitWith {};

			local _data = [_x, 1, "STRING", ""] call _fn_safeSelect;
			local _args = [_x, 2, "STRING", ""] call _fn_safeSelect;

			local _file = [_path, true] call fxy_dbg_fn_file_open;
			[_file, _data, _args] call fxy_dbg_fn_file_write;
		};
	} foreach _files;
};

fxy_dbg_filesystem_modified = false;


fxy_dbg_button_colorText = getArray (configFile >> "RscFxyDebugButton" >> "colorText");
fxy_dbg_button_colorActive = getArray (configFile >> "RscFxyDebugButton" >> "colorActive");

// [control]
fxy_dbg_eh_button_onMouseEnter =
{
	(_this select 0) ctrlSetTextColor fxy_dbg_button_colorActive;
};

// [control]
fxy_dbg_eh_button_onMouseExit =
{
	(_this select 0) ctrlSetTextColor fxy_dbg_button_colorText;
};



/* MAIN */

fxy_dbg_error_timer = -1;

// [display, string]
fxy_dbg_fn_setError =
{
	_this select 0 displayCtrl IDC_FXY_DBG_ERROR ctrlSetText (_this select 1);
	fxy_dbg_error_timer = diag_ticktime + 5;
};

// display
fxy_dbg_fn_clearError =
{
	_this displayCtrl IDC_FXY_DBG_ERROR ctrlSetText "";
	fxy_dbg_error_timer = -1;
};


/* FILE LIST
struct element
{
	bool file
	union {
		node
		file
	} data
	string formatted
}

element[] fxy_dbg_file_list
*/


fxy_dbg_files_expanded = profileNamespace getVariable ["fxy_dbg_files_expanded", false];
if (typename fxy_dbg_files_expanded != "BOOL") then { fxy_dbg_files_expanded = false; };

//fxy_dbg_files_selected = profileNamespace getVariable ["fxy_dbg_files_selected", -1];
//if (typename fxy_dbg_files_selected != "SCALAR") then { fxy_dbg_files_selected = -1};

fxy_dbg_file_list = [];
fxy_dbg_files_needUpdate = false;

// [node, string indent]
fxy_dbg_fn_file_list_format_i =
{
	local _indent = _this select 1;

	// foreach files
	{
		fxy_dbg_file_list set [count fxy_dbg_file_list, [true, _x, format ["%1%2", _indent, _x select 0]]];
	} foreach Node_GetFiles(_this select 0);

	// foreach nodes
	{
		if (Node_GetOpen(_x)) then
		{
			fxy_dbg_file_list set [count fxy_dbg_file_list, [false, _x, format ["%1+ %2", _indent, _x select 0]]];
			[_x, _indent + " "] call fxy_dbg_fn_file_list_format_i;
		}
		else
		{
			fxy_dbg_file_list set [count fxy_dbg_file_list, [false, _x, format ["%1- %2", _indent, _x select 0]]];
		};
	} foreach Node_GetNodes(_this select 0);
};

fxy_dbg_fn_file_list_format =
{
	if (fxy_dbg_files_expanded) then
	{
		fxy_dbg_file_list = [];
		[fxy_dbg_filesystem, ""] call fxy_dbg_fn_file_list_format_i;
	}
	else
	{
		fxy_dbg_files_needUpdate = true;
	};
};

// initial file list format
call fxy_dbg_fn_file_list_format;

// display
fxy_dbg_fn_file_list_update =
{
	if (fxy_dbg_files_expanded) then
	{
		local _ctrl = _this displayCtrl IDC_FXY_DBG_FILES;

		lbClear _ctrl;

		{
			_ctrl lbAdd (_x select 2);
		} foreach fxy_dbg_file_list;

		local _size = lbSize _ctrl;

		if (lbCurSel _ctrl >= _size) then
		{
			_ctrl lbSetCurSel (_size - 1);
		};
	};
};

// display -> [bool, file/node]
fxy_dbg_fn_file_list_get =
{
	local _index = lbCurSel (_this displayCtrl IDC_FXY_DBG_FILES);
	if (_index == -1) exitWith { nil };
	local _info = fxy_dbg_file_list select _index;
	[_info select 0, _info select 1]
};

// display -> path
fxy_dbg_fn_file_list_getPath =
{
	local _info = _this call fxy_dbg_fn_file_list_get;

	if (isnil "_info") exitWith { "" };

	if (_info select 0) then
	{
		File_GetPathF(_info select 1)
	}
	else
	{
		Node_GetPath(_info select 1) call fxy_dbg_fn_path_format
	};
};

fxy_dbg_background_d = getNumber (configFile >> "RscFxyDebug" >> "Controls" >> "Background" >> "d");
fxy_dbg_background_d = [-fxy_dbg_background_d, fxy_dbg_background_d];

fxy_dbg_toggleFiles_text = [
	getText (configFile >> "RscFxyDebug" >> "Controls" >> "ToggleFiles" >> "text2"),
	getText (configFile >> "RscFxyDebug" >> "Controls" >> "ToggleFiles" >> "text")
];

// display
fxy_dbg_fn_files_toggle_i =
{
	local _d = fxy_dbg_background_d select fxy_dbg_files_expanded;

	local _ctrl = _this displayCtrl IDC_FXY_DBG_BACKGROUND;
	local _pos = ctrlPosition _ctrl;
	_pos set [0, (_pos select 0) - _d];
	_pos set [2, (_pos select 2) + _d];
	_ctrl ctrlSetPosition _pos;
	_ctrl ctrlCommit 0;

	_ctrl = _this displayCtrl IDC_FXY_DBG_ERROR;
	_pos = ctrlPosition _ctrl;
	_pos set [0, (_pos select 0) - _d];
	_pos set [2, (_pos select 2) + _d];
	_ctrl ctrlSetPosition _pos;
	_ctrl ctrlCommit 0;

	_ctrl = _this displayCtrl IDC_FXY_DBG_FILES;
	_ctrl ctrlEnable fxy_dbg_files_expanded;
	_ctrl ctrlShow fxy_dbg_files_expanded;
	_ctrl ctrlCommit 0;

	_ctrl = _this displayCtrl IDC_FXY_DBG_FILES_BG;
	_ctrl ctrlEnable fxy_dbg_files_expanded;
	_ctrl ctrlShow fxy_dbg_files_expanded;
	_ctrl ctrlCommit 0;

	_ctrl = _this displayCtrl IDC_FXY_DBG_IMPORT;
	_ctrl ctrlEnable fxy_dbg_files_expanded;
	_ctrl ctrlShow fxy_dbg_files_expanded;
	_ctrl ctrlCommit 0;

	_ctrl = _this displayCtrl IDC_FXY_DBG_EXPORT;
	_ctrl ctrlEnable fxy_dbg_files_expanded;
	_ctrl ctrlShow fxy_dbg_files_expanded;
	_ctrl ctrlCommit 0;

	_ctrl = _this displayCtrl IDC_FXY_DBG_TOGGLE_FILES;
	_ctrl ctrlSetText (fxy_dbg_toggleFiles_text select fxy_dbg_files_expanded);

	if (fxy_dbg_files_expanded && fxy_dbg_files_needUpdate) then
	{
		call fxy_dbg_fn_file_list_format;
		_this call fxy_dbg_fn_file_list_update;
		fxy_dbg_files_needUpdate = false;
	};
};

// display
fxy_dbg_fn_files_toggle =
{
	fxy_dbg_files_expanded = !fxy_dbg_files_expanded;
	_this call fxy_dbg_fn_files_toggle_i;
};

// display
fxy_dbg_fn_files_init =
{
	if (!fxy_dbg_files_expanded) then
	{
		_this call fxy_dbg_fn_files_toggle_i;
	}
	else
	{
		_this call fxy_dbg_fn_file_list_update;
	};
};

// [control, int index]
fxy_dbg_eh_file_list_onSelChanged =
{
//	fxy_dbg_files_selected = _this select 1;
};

// [control, int index]
fxy_dbg_eh_file_list_onDblClick =
{
	local _ctrl = _this select 0;
	local _index = _this select 1;

	local _info = fxy_dbg_file_list select _index;

	// if file
	if (_info select 0) then
	{
		[ctrlParent _ctrl, _info select 1] call fxy_dbg_fn_tabs_current_load;
	}
	else
	{
		// Toggle the node state
		_info select 1 call fxy_dbg_fn_node_toggle;

		// Reformat the list
		call fxy_dbg_fn_file_list_format;

		// Update the list
		ctrlParent (_this select 0) call fxy_dbg_fn_file_list_update;
	};
};

// [control, int key, bool shift, bool ctrl, bool alt]
fxy_dbg_eh_file_list_onKeyDown =
{
	local _index = lbCurSel (_this select 0);

	if (_index == -1) exitWith {};

	local _info = fxy_dbg_file_list select _index;

	if (_this select 1 == DIK_DELETE) exitWith
	{
		local _disp = ctrlParent (_this select 0);

		if (_info select 0) then
		{
			[_disp, _info select 1] call fxy_dbg_fn_tabs_closeFile;
			File_GetPath(_info select 1) call fxy_dbg_fn_file_delete;
		}
		else
		{
			[_disp, _info select 1] call fxy_dbg_fn_tabs_closeNode;
			Node_GetPath(_info select 1) call fxy_dbg_fn_node_delete;
		};

		call fxy_dbg_fn_file_list_format;
		_disp call fxy_dbg_fn_file_list_update;
	};
};


/* TABS
struct tab
{
	file        file
	string      data
	string      args
	bool        modified
	bool        selected
}
*/
#define Tab_New(file, data, args) [file, data, args, false, false]

#define Tab_GetFile(t)		Struct_Get(t, 0)
#define Tab_SetFile(t, f)	Struct_Set(t, 0, f)
#define Tab_GetData(t)		Struct_Get(t, 1)
#define Tab_SetData(t, d)	Struct_Set(t, 1, d)
#define Tab_GetArgs(t)		Struct_Get(t, 2)
#define Tab_SetArgs(t, d)	Struct_Set(t, 2, d)
#define Tab_GetMod(t)		Struct_Get(t, 3)
#define Tab_SetMod(t, m)	Struct_Set(t, 3, m)
#define Tab_GetCur(t)		Struct_Get(t, 4)
#define Tab_SetCur(t, s)	Struct_Set(t, 4, s)

fxy_dbg_tabs_idc = [
	IDC_FXY_DBG_TAB0,
	IDC_FXY_DBG_TAB1,
	IDC_FXY_DBG_TAB2,
	IDC_FXY_DBG_TAB3,
	IDC_FXY_DBG_TAB4,
	IDC_FXY_DBG_TAB5,
	IDC_FXY_DBG_TAB6,
	IDC_FXY_DBG_TAB7,
	IDC_FXY_DBG_TAB8
];

fxy_dbg_tabs_bg_idc = [
	IDC_FXY_DBG_TAB_BACKGROUND0,
	IDC_FXY_DBG_TAB_BACKGROUND1,
	IDC_FXY_DBG_TAB_BACKGROUND2,
	IDC_FXY_DBG_TAB_BACKGROUND3,
	IDC_FXY_DBG_TAB_BACKGROUND4,
	IDC_FXY_DBG_TAB_BACKGROUND5,
	IDC_FXY_DBG_TAB_BACKGROUND6,
	IDC_FXY_DBG_TAB_BACKGROUND7,
	IDC_FXY_DBG_TAB_BACKGROUND8
];

fxy_dbg_tabs = [];
fxy_dbg_tabs resize count fxy_dbg_tabs_idc;

// load tabs
local _tabs = profileNamespace getVariable ["fxy_dbg_tabs", []];

if ([_tabs, 0] call _fn_arrayCheck) then
{
	for "_i" from 0 to count _tabs - 1 do
	{
		local _tab = _tabs select _i;
		local _file = [_tab, 0, "STRING", ""] call _fn_safeSelect call fxy_dbg_fn_path_parse;
		_file = [_file, false] call fxy_dbg_fn_file_open;

		local _data = [_tab, 1, "STRING", ""] call _fn_safeSelect;
		local _args = [_tab, 2, "STRING", ""] call _fn_safeSelect;

		local _mod = false;
		if (isnil "_file") then
		{
			_mod = _data != "" || { _args != "" };
			_file = [nil];
		}
		else
		{
			File_SetTab(_file, _i);
			_mod = 
				!([_data, File_GetData(_file)] call fxy_dbg_fn_fs_compare) || {
				!([_args, File_GetArgs(_file)] call fxy_dbg_fn_fs_compare) };
			_file = [_file];
		};

		_tab = Tab_New(_file select 0, _data, _args);
		Tab_SetMod(_tab, _mod);

		fxy_dbg_tabs set [_i, _tab];
	};
};

fxy_dbg_tabs_current = profileNamespace getVariable ["fxy_dbg_tabs_cur", 0];
if (typename fxy_dbg_tabs_current != "SCALAR" ) then { fxy_dbg_tabs_current = 0 };
fxy_dbg_tabs_current = (fxy_dbg_tabs_current max 0) min count fxy_dbg_tabs;

fxy_dbg_tabs_modified = false;

Tab_SetCur(fxy_dbg_tabs select fxy_dbg_tabs_current, true);

// int index -> string
fxy_dbg_fn_tabs_getName =
{
	local _file = Tab_GetFile(fxy_dbg_tabs select _this);

	if (isnil "_file") then
	{
		format ["(%1)", _this + 1];
	}
	else
	{
		File_GetName(_file)
	};
};

// int index -> string
fxy_dbg_fn_tabs_getPath =
{
	local _file = Tab_GetFile(fxy_dbg_tabs select _this);

	if (isnil "_file") then
	{
		""
	}
	else
	{
		File_GetPathF(_file)
	};
};

fxy_dbg_tabs_colors = [
	[
		[0.1,0.1,0.1,0.8],
	//	getArray (configFile >> "RscFxyDebug" >> "Controls" >> "TabBackground0" >> "colorBackgroundSel"),
		[0.4,0.1,0.1,0.8]
	//	getArray (configFile >> "RscFxyDebug" >> "Controls" >> "TabBackground0" >> "colorBackgroundSelMod")
	],
	[
		[0,0,0,0.8],
	//	getArray (configFile >> "RscFxyDebug" >> "Controls" >> "TabBackground0" >> "colorBackground"),
		[0.2,0,0,0.8]
	//	getArray (configFile >> "RscFxyDebug" >> "Controls" >> "TabBackground0" >> "colorBackgroundMod")
	]
];

// [display, int index]
fxy_dbg_fn_tabs_update =
{
	local _tab = fxy_dbg_tabs select (_this select 1);

	local _ctrl = _this select 0 displayCtrl (fxy_dbg_tabs_idc select (_this select 1));
	local _name = ((_this select 1) call fxy_dbg_fn_tabs_getName);
	_ctrl ctrlSetText _name;

	local _path = ((_this select 1) call fxy_dbg_fn_tabs_getPath);
	_ctrl ctrlSetTooltip _path;

	_ctrl = _this select 0 displayCtrl (fxy_dbg_tabs_bg_idc select (_this select 1));
	_ctrl ctrlSetBackgroundColor (fxy_dbg_tabs_colors select Tab_GetCur(_tab) select Tab_GetMod(_tab));
};

// display
fxy_dbg_fn_tabs_update_all =
{
	{
		[_this, _foreachIndex] call fxy_dbg_fn_tabs_update;
	} foreach fxy_dbg_tabs;
};

// [display, int index]
fxy_dbg_fn_tabs_select =
{
	if (_this select 1 == fxy_dbg_tabs_current) exitWith {};

	local _tab = fxy_dbg_tabs select fxy_dbg_tabs_current;
	Tab_SetCur(_tab, false);

	[_this select 0, fxy_dbg_tabs_current] call fxy_dbg_fn_tabs_update;

	fxy_dbg_tabs_current = _this select 1;

	_tab = fxy_dbg_tabs select fxy_dbg_tabs_current;
	Tab_SetCur(_tab, true);

	[_this select 0, fxy_dbg_tabs_current] call fxy_dbg_fn_tabs_update;

	_this select 0 call fxy_dbg_fn_editor_update;
};

// display
fxy_dbg_fn_tabs_cycleForward =
{
	local _index = fxy_dbg_tabs_current + 1;
	if (_index >= count fxy_dbg_tabs) then { _index = 0; };
	[_this, _index] call fxy_dbg_fn_tabs_select;
};

// display
fxy_dbg_fn_tabs_cycleBackward =
{
	local _index = fxy_dbg_tabs_current - 1;
	if (_index < 0) then { _index = count fxy_dbg_tabs - 1; };
	[_this, _index] call fxy_dbg_fn_tabs_select;
};

// -> [string, string]
fxy_dbg_fn_tabs_read =
{
	local _tab = fxy_dbg_tabs select fxy_dbg_tabs_current;
	[Tab_GetData(_tab), Tab_GetArgs(_tab)]
};

// [string, string] -> nil
fxy_dbg_fn_tabs_write =
{
	local _tab = fxy_dbg_tabs select fxy_dbg_tabs_current;
	Tab_SetData(_tab, _this select 0);
	Tab_SetArgs(_tab, _this select 1);
};

fxy_dbg_tabs_checkModifiedIndex = -1;
fxy_dbg_tabs_checkModifiedTime = 0;

// display
fxy_dbg_fn_tabs_modify =
{
	fxy_dbg_tabs_checkModifiedIndex = fxy_dbg_tabs_current;
	fxy_dbg_tabs_checkModifiedTime = diag_ticktime + 0.2;
};

// display
fxy_dbg_fn_tabs_checkModified =
{
	local _tab = fxy_dbg_tabs select fxy_dbg_tabs_checkModifiedIndex;

	local _data = Tab_GetData(_tab);
	local _args = Tab_GetArgs(_tab);

	if (fxy_dbg_tabs_checkModifiedIndex == fxy_dbg_tabs_current) then
	{
		_data = _this call fxy_dbg_fn_editor_getText;
		_args = _this call fxy_dbg_fn_editor_getArgsText;
	};

	local _file = Tab_GetFile(_tab);

	local _mod =
		if (isnil "_file") then
		{
			_data != "" || { _args != "" }
		}
		else
		{
			!([_data, File_GetData(_file)] call fxy_dbg_fn_fs_compare) || {
			!([_args, File_GetArgs(_file)] call fxy_dbg_fn_fs_compare) }
		};

	if (!(_mod in [Tab_GetMod(_tab)])) then
	{
		Tab_SetMod(_tab, _mod);
		[_this, fxy_dbg_tabs_checkModifiedIndex] call fxy_dbg_fn_tabs_update;
	};

	fxy_dbg_tabs_checkModifiedIndex = -1;
	fxy_dbg_tabs_checkModifiedTime = 0;
};

// [display, int index]
fxy_dbg_fn_tabs_close_i =
{
	local _tab = fxy_dbg_tabs select (_this select 1);
	local _file = Tab_GetFile(_tab);

	if (!isnil "_file") then
	{
		File_SetTab(_file, -1);
		Tab_SetFile(_tab, nil);
	};

	Tab_SetData(_tab, "");
	Tab_SetArgs(_tab, "");
	Tab_SetMod(_tab, false);

	_this call fxy_dbg_fn_tabs_update;

	if (_this select 1 == fxy_dbg_tabs_current) then
	{
		_this select 0 call fxy_dbg_fn_editor_update;
	};

	fxy_dbg_tabs_modified = true;
};

// [display, bool, string, int index]
fxy_dbg_eh_tabs_close_onPathSelected =
{
	if (!(_this select 1)) exitWith {};

	local _path = _this select 2 call fxy_dbg_fn_path_parse;

	if (count _path == 0) exitWith
	{
		[_this select 0, "Invalid file path."] call fxy_dbg_fn_setError;
	};

	local _file = [_path, true] call fxy_dbg_fn_file_open;

	if (File_GetTab(_file) != -1) exitWith
	{
		[_this select 0, "File is already open."] call fxy_dbg_fn_setError;
	};

	local _tab = fxy_dbg_tabs select (_this select 2);

	[_file, Tab_GetData(_tab), Tab_GetArgs(_tab)] call fxy_dbg_fn_file_write;

	call fxy_dbg_fn_file_list_format;
	_this select 0 call fxy_dbg_fn_file_list_update;

	[_this select 0, _this select 3] call fxy_dbg_fn_tabs_close_i;
};

// [display, int result, int index]
fxy_dbg_eh_tabs_close_onConfirmed =
{
	switch (_this select 1) do
	{
		case 1: // yes
		{
			local _tab = fxy_dbg_tabs select (_this select 2);

			local _file = Tab_GetFile(_tab);

			if (isnil "_file") then
			{
				[_this select 0, fxy_dbg_dispatch, "Save", "", fxy_dbg_eh_tabs_close_onPathSelected, _this select 2] spawn fxy_dbg_fn_save_create;
			}
			else
			{
				[_file, Tab_GetData(_tab), Tab_GetArgs(_tab)] call fxy_dbg_fn_file_write;
				[_this select 0, _this select 1] call fxy_dbg_fn_tabs_close_i;
			};
		};

		case 0: // no
		{
			[_this select 0, _this select 2] call fxy_dbg_fn_tabs_close_i;
		};
	};
};

// [display, int index]
fxy_dbg_fn_tabs_close =
{
	local _tab = fxy_dbg_tabs select (_this select 1);

	if (Tab_GetMod(_tab)) then
	{
		local _file = Tab_GetFile(_tab);

		local _text = format ['Save changes to "%1"?', (_this select 1) call fxy_dbg_fn_tabs_getName];
		[_this select 0, fxy_dbg_dispatch, "Save", _text, fxy_dbg_eh_tabs_close_onConfirmed, _this select 1] spawn fxy_dbg_fn_ync_create;
	}
	else
	{
		_this call fxy_dbg_fn_tabs_close_i;
	};
};

// display
fxy_dbg_fn_tabs_current_close =
{
	[_this, fxy_dbg_tabs_current] call fxy_dbg_fn_tabs_close;
};

// [display, node]
fxy_dbg_fn_tabs_closeNode =
{
	[_this select 1, {[_this select 1, _this select 0] call fxy_dbg_fn_tabs_closeFile}, _this select 0, true] call fxy_dbg_fn_node_foreachFile;
};

// [display, file]
fxy_dbg_fn_tabs_closeFile =
{
	local _index = File_GetTab(_this select 1);

	if (_index != -1) then
	{
		[_this select 0, _index] call fxy_dbg_fn_tabs_close_i;
	};
};

// [display, bool, string, int index]
fxy_dbg_eh_tabs_save_as_onPathSelected =
{
	if (!(_this select 1)) exitWith {};

	local _path = _this select 2 call fxy_dbg_fn_path_parse;

	if (count _path == 0) exitWith
	{
		[_this select 0, "Invalid file path."] call fxy_dbg_fn_setError;
	};

	local _index = _this select 3;
	local _tab = fxy_dbg_tabs select _index;

	local _prev = Tab_GetFile(_tab);
	local _file = [_path, true] call fxy_dbg_fn_file_open;

	if (File_GetTab(_file) != -1) exitWith
	{
		[_this select 0, "File is already open."] call fxy_dbg_fn_setError;
	};

	if (!isnil "_prevfile") then
	{
		File_SetTab(_prevfile, -1);
	};

	File_SetTab(_file, _index);
	Tab_SetFile(_tab, _file);

	[Tab_GetFile(_tab), Tab_GetData(_tab), Tab_GetArgs(_tab)] call fxy_dbg_fn_file_write;
	Tab_SetMod(_tab, false);

	call fxy_dbg_fn_file_list_format;
	_this select 0 call fxy_dbg_fn_file_list_update;

	[_this select 0, _index] call fxy_dbg_fn_tabs_update;
};

// [display, int index]
fxy_dbg_fn_tabs_save_as =
{
	if (_this select 1 != -1) then
	{
		local _path = _this select 0 call fxy_dbg_fn_file_list_getPath;
		[_this select 0, fxy_dbg_dispatch, "Save as", _path, fxy_dbg_eh_tabs_save_as_onPathSelected, _this select 1] spawn fxy_dbg_fn_save_create;
	};
};

// display
fxy_dbg_fn_tabs_current_save_as =
{
	[_this, fxy_dbg_tabs_current] call fxy_dbg_fn_tabs_save_as;
};

// [display, int index]
fxy_dbg_fn_tabs_save =
{
	local _tab = fxy_dbg_tabs select (_this select 1);

	local _file = Tab_GetFile(_tab);

	if (isnil "_file") exitWith { _this call fxy_dbg_fn_tabs_save_as };

	[Tab_GetFile(_tab), Tab_GetData(_tab), Tab_GetArgs(_tab)] call fxy_dbg_fn_file_write;
	Tab_SetMod(_tab, false);

	_this call fxy_dbg_fn_tabs_update;
};

// display
fxy_dbg_fn_tabs_current_save =
{
	[_this, fxy_dbg_tabs_current] call fxy_dbg_fn_tabs_save;
};

// [display, int index, file]
fxy_dbg_fn_tabs_load_i =
{
	local _index = _this select 1;
	local _file = _this select 2;

	local _tab = fxy_dbg_tabs select _index;

	File_SetTab(_file, _index);
	Tab_SetFile(_tab, _file);
	Tab_SetData(_tab, File_GetData(_file));
	Tab_SetArgs(_tab, File_GetArgs(_file));
	Tab_SetMod(_tab, false);

	fxy_dbg_tabs_modified = true;

	_this call fxy_dbg_fn_tabs_update;

	if (_index == fxy_dbg_tabs_current) then
	{
		_this select 0 call fxy_dbg_fn_editor_update;
	};
};

// [display, bool, string, [file, int index]]
fxy_dbg_eh_tabs_load_onPathSelected =
{
	if (!(_this select 1)) exitWith {};

	local _args = _this select 3;
	local _index = _args select 1;

	local _tab = fxy_dbg_tabs select _index;

	local _path = _this select 2 call fxy_dbg_fn_path_parse;

	if (count _path == 0) exitWith
	{
		[_this select 0, "Invalid file path."] call fxy_dbg_fn_setError;
	};

	local _prevfile = [_path, true] call fxy_dbg_fn_file_open;

	//TODO: ask to overwrite

	if (File_GetTab(_prevfile) != -1) exitWith
	{
		[_this select 0, "File is already open."] call fxy_dbg_fn_setError;
	};

	[_prevfile, Tab_GetData(_tab), Tab_GetArgs(_tab)] call fxy_dbg_fn_file_write;

	call fxy_dbg_fn_file_list_format;
	_this select 0 call fxy_dbg_fn_file_list_update;

	[_this select 0, _index, _args select 0] call fxy_dbg_fn_tabs_load_i;
};

// [display, int result, [file, int index]]
fxy_dbg_eh_tabs_load_onConfirmed =
{
	switch (_this select 1) do
	{
		case 1: // yes
		{
			local _args = _this select 2;
			local _index = _args select 1;
			local _tab = fxy_dbg_tabs select _index;

			local _prevfile = Tab_GetFile(_tab);

			if (isnil "_prevfile") then
			{
				[_this select 0, fxy_dbg_dispatch, "Save as", "", fxy_dbg_eh_tabs_load_onPathSelected, _args] spawn fxy_dbg_fn_save_create;
			}
			else
			{
				[_prevfile, Tab_GetData(_tab), Tab_GetArgs(_tab)] call fxy_dbg_fn_file_write;
				File_SetTab(_prevfile, -1);

				[_this select 0, _index, _args select 0] call fxy_dbg_fn_tabs_load_i;
			};
		};

		case 0: // no
		{
			local _args = _this select 2;
			local _index = _args select 1;
			local _tab = fxy_dbg_tabs select _index;

			local _prevfile = Tab_GetFile(_tab);

			if (!isnil "_prevfile") then
			{
				File_SetTab(_prevfile, -1);
			};

			[_this select 0, _index, _args select 0] call fxy_dbg_fn_tabs_load_i;
		};
	};
};

// [display, int index, file]
fxy_dbg_fn_tabs_load =
{
	local _file = _this select 2;

	if (File_GetTab(_file) != -1) exitWith
	{
		[_this select 0, "File is already open."] call fxy_dbg_fn_setError;
	};

	local _index = _this select 1;
	local _tab = fxy_dbg_tabs select _index;

	if (Tab_GetMod(_tab)) exitWith
	{
		local _text = format ['Save changes to "%1"?', _index call fxy_dbg_fn_tabs_getName];
		[_this select 0, fxy_dbg_dispatch, "Save", _text, fxy_dbg_eh_tabs_load_onConfirmed, [_file, _index]] spawn fxy_dbg_fn_ync_create;
	};

	local _prevfile = Tab_GetFile(_tab);

	if (!isnil "_prevfile") then
	{
		File_SetTab(_prevfile, -1);
	};

	_this call fxy_dbg_fn_tabs_load_i;
};

// [display, file]
fxy_dbg_fn_tabs_current_load =
{
	[_this select 0, fxy_dbg_tabs_current, _this select 1] call fxy_dbg_fn_tabs_load;
};

fxy_dbg_fn_tabs_serialize =
{
//	if (fxy_dbg_tabs_modified) then
//	{
		local _tabs = [];
		_tabs resize count fxy_dbg_tabs;

		{
			local _file = Tab_GetFile(_x);
			local _path = "";

			if (!isnil "_file") then
			{
				_path = File_GetPathF(_file);
			};

			_tabs set [_foreachIndex, [_path, Tab_GetData(_x), Tab_GetArgs(_x)]];
		} foreach fxy_dbg_tabs;

		profileNamespace setVariable ["fxy_dbg_tabs", _tabs];

		fxy_dbg_tabs_modified = false;
//	};

	profileNamespace setVariable ["fxy_dbg_tabs_cur", fxy_dbg_tabs_current];
};

// [control, int index]
fxy_dbg_eh_tabs_onButtonClick =
{
	[ctrlParent (_this select 0), _this select 1] call fxy_dbg_fn_tabs_select;
};


/* EDITOR */

// display
fxy_dbg_fn_editor_update =
{
	local _data = call fxy_dbg_fn_tabs_read;
	_this displayCtrl IDC_FXY_DBG_EDITOR ctrlSetText (_data select 0);
	_this displayCtrl IDC_FXY_DBG_EDITOR_ARGS ctrlSetText (_data select 1);
};

// display
fxy_dbg_fn_editor_getText =
{
	ctrlText (_this displayCtrl IDC_FXY_DBG_EDITOR)
};

// display
fxy_dbg_fn_editor_getArgsText =
{
	ctrlText (_this displayCtrl IDC_FXY_DBG_EDITOR_ARGS)
};

// display
fxy_dbg_fn_editor_compile =
{
	compile ctrlText (_this displayCtrl IDC_FXY_DBG_EDITOR)
};

// display
fxy_dbg_fn_editor_getArgs =
{
	local _args = call compile ctrlText (_this displayCtrl IDC_FXY_DBG_EDITOR_ARGS);
	if (isnil "_args") then { _args = []; };
	_args
};

// display
fxy_dbg_fn_editor_commit =
{
	[
		ctrlText (_this displayCtrl IDC_FXY_DBG_EDITOR),
		ctrlText (_this displayCtrl IDC_FXY_DBG_EDITOR_ARGS)
	] call fxy_dbg_fn_tabs_write;
};

// [control]
fxy_dbg_eh_editor_onKillFocus =
{
	ctrlParent (_this select 0) call fxy_dbg_fn_editor_commit;
};

// [control, int key, bool shift, bool ctrl, bool alt]
fxy_dbg_eh_editor_onKeyUp =
{
	local _disp = ctrlParent (_this select 0);
	local _key = _this select 1;

	if (_key in fxy_dbg_enterKeys) exitWith
	{
		(_disp call fxy_dbg_fn_editor_getArgs) call (_disp call fxy_dbg_fn_editor_compile);
		true
	};

	if (fxy_dbg_tabs_checkModifiedTime == 0) then
	{
		_disp call fxy_dbg_fn_tabs_modify;
		false
	};
};


/* BUTTONS */

// [control]
fxy_dbg_eh_toggleFiles_onButtonClick =
{
	ctrlParent (_this select 0) call fxy_dbg_fn_files_toggle;
};

// [control]
fxy_dbg_eh_execLocal_onButtonClick =
{
	local _disp = ctrlParent (_this select 0);
	(_disp call fxy_dbg_fn_editor_getArgs) call (_disp call fxy_dbg_fn_editor_compile);
};

// [control]
fxy_dbg_eh_execServer_onButtonClick =
{
	local _disp = ctrlParent (_this select 0);
	[_disp call fxy_dbg_fn_editor_getText, _disp call fxy_dbg_fn_editor_getArgs] call fxy_dbg_fn_serverExec;
};

// [control]
fxy_dbg_eh_execGlobal_onButtonClick =
{
	local _disp = ctrlParent (_this select 0);
	[_disp call fxy_dbg_fn_editor_getText, _disp call fxy_dbg_fn_editor_getArgs] call fxy_dbg_fn_globalExec;
};

// [control]
fxy_dbg_eh_performance_onButtonClick =
{
	local _disp = ctrlParent (_this select 0);
	local _code = _disp call fxy_dbg_fn_editor_compile;
	local _args = _disp call fxy_dbg_fn_editor_getArgs;
	local _result = [_code, _args] call fxy_dbg_fn_perf;

	systemChat format ["%1 cycles @ %2 ms", [str (_result select 1), 6] call fxy_dbg_fn_padRight, [str (_result select 0), 12] call fxy_dbg_fn_padRight];
};

// [control]
fxy_dbg_eh_options_onButtonClick =
{

};

if (isnil "fxy_dbg_fn_serverExec") then
{
	fxy_dbg_fn_serverExec = {};
};

if (isnil "fxy_dbg_fn_globalExec") then
{
	fxy_dbg_fn_globalExec = {};
};


/* WATCHES */
fxy_dbg_watch_in_idc = [
	IDC_FXY_DBG_WATCH0,
	IDC_FXY_DBG_WATCH1,
	IDC_FXY_DBG_WATCH2,
	IDC_FXY_DBG_WATCH3,
	IDC_FXY_DBG_WATCH4
];

fxy_dbg_watch_out_idc = [
	IDC_FXY_DBG_WATCH_RESULT0,
	IDC_FXY_DBG_WATCH_RESULT1,
	IDC_FXY_DBG_WATCH_RESULT2,
	IDC_FXY_DBG_WATCH_RESULT3,
	IDC_FXY_DBG_WATCH_RESULT4
];

assert(count fxy_dbg_watch_in_idc == count fxy_dbg_watch_out_idc);

fxy_dbg_watch = [];
fxy_dbg_watch resize count fxy_dbg_watch_in_idc;
fxy_dbg_watch_code = +fxy_dbg_watch;

// load watches
local _watches = profileNamespace getVariable ["fxy_dbg_watch", []];
if (typename _watches != "ARRAY") then { _watches = []; };

for "_i" from 0 to count fxy_dbg_watch - 1 do
{
	local _watch = nil;

	if (_i < count _watches) then
	{
		_watch = _watches select _i;

		if (isnil "_watch" || { typename _watch != "STRING" }) exitWith
		{
			_watch = "";
		};

		if (_watch != "") then
		{
			fxy_dbg_watch_code set [_i, compile _watch];
		};
	}
	else
	{
		_watch = "";
	};

	fxy_dbg_watch set [_i, _watch];
};

fxy_dbg_watch_rate = profileNamespace getVariable ["fxy_dbg_watch_rate", 100];
if (typename fxy_dbg_watch_rate != "SCALAR") then { fxy_dbg_watch_rate = 100; };

fxy_dbg_watch_script = [] spawn {};

// [display]
fxy_dbg_pc_watch =
{
	disableSerialization;

	local _disp = _this select 0;

	for "_i" from 0 to 1 step 0 do
	{
		{
			if (!isnil "_x") then
			{
				local _result = nil;
				if (isnil { _result = call _x; _result }) then { _result = ""; };
				_disp displayCtrl (fxy_dbg_watch_out_idc select _foreachIndex) ctrlSetText format ["%1", _result];
			};
		} foreach fxy_dbg_watch_code;

		uisleep fxy_dbg_watch_delay;
	};
};

// float (ms)
fxy_dbg_fn_watch_setRate =
{
	fxy_dbg_watch_rate = _this;
	fxy_dbg_watch_delay = (_this max 10) / 1000;
};

fxy_dbg_watch_rate call fxy_dbg_fn_watch_setRate;

// display
fxy_dbg_fn_watch_start =
{
	terminate fxy_dbg_watch_script;
	fxy_dbg_watch_script = [_this] spawn fxy_dbg_pc_watch;
};

fxy_dbg_fn_watch_stop =
{
	terminate fxy_dbg_watch_script;
};

// display
fxy_dbg_fn_watches_update =
{
	{
		_this displayCtrl _x ctrlSetText (fxy_dbg_watch select _foreachIndex);
	} foreach fxy_dbg_watch_in_idc;
};

fxy_dbg_fn_watch_serialize =
{
	profileNamespace setVariable ["fxy_dbg_watch", fxy_dbg_watch];
	profileNamespace setVariable ["fxy_dbg_watch_rate", fxy_dbg_watch_rate];
};

// [control, int index]
fxy_dbg_eh_watch_onSetFocus =
{
	fxy_dbg_watch_code set [_this select 1, nil];
};

// [control, int index]
fxy_dbg_eh_watch_onKillFocus =
{
	local _text = ctrlText (_this select 0);
	fxy_dbg_watch set [_this select 1, _text];
	fxy_dbg_watch_code set [_this select 1, compile _text];
};

// [control, int index, int key]
fxy_dbg_eh_watch_onKeyDown =
{
	if (_this select 2 in fxy_dbg_enterKeys) then
	{
		local _text = ctrlText (_this select 0);
		fxy_dbg_watch set [_this select 1, _text];
		fxy_dbg_watch_code set [_this select 1, compile _text];
	}
	else
	{
		fxy_dbg_watch_code set [_this select 1, nil];
	};
};


// [display]
fxy_dbg_pc_controller =
{
	disableSerialization;

	local _disp = _this select 0;

	ctrlSetFocus (_disp displayCtrl IDC_FXY_DBG_EDITOR);

	for "_i" from 0 to 1 step 0 do
	{
		if (fxy_dbg_error_timer > 0 && { diag_ticktime > fxy_dbg_error_timer }) then
		{
			_disp call fxy_dbg_fn_clearError;
		};

		isnil {
			if (fxy_dbg_tabs_checkModifiedTime > 0 && { diag_ticktime > fxy_dbg_tabs_checkModifiedTime }) then
			{
				_disp call fxy_dbg_fn_tabs_checkModified;
			};
		};

		uisleep 0.1;
	};
};

// [display]
fxy_dbg_eh_onLoad =
{
	local _disp = _this select 0;

	// init file list
	_disp call fxy_dbg_fn_files_init;

	// update tabs
	_disp call fxy_dbg_fn_tabs_update_all;

	//update editor
	_disp call fxy_dbg_fn_editor_update;

	// update watches
	_disp call fxy_dbg_fn_watches_update;

	// start watches
	_disp call fxy_dbg_fn_watch_start;

	// start controller
	fxy_dbg_controller = [_disp] spawn fxy_dbg_pc_controller;
};

// [display]
fxy_dbg_eh_onUnload =
{
	terminate fxy_dbg_controller;
	call fxy_dbg_fn_watch_stop;

	_this select 0 call fxy_dbg_fn_editor_commit;

	call fxy_dbg_fn_filesystem_serialize;
	call fxy_dbg_fn_watch_serialize;
	call fxy_dbg_fn_tabs_serialize;

	profileNamespace setVariable ["fxy_dbg_files_expanded", fxy_dbg_files_expanded];

	saveProfileNamespace;
};

// [display, int key, bool shift, bool ctrl, bool alt]
fxy_dbg_eh_onKeydown =
{
	local _key = _this select 1;

	//if not ctrl
	if (!(_this select 3)) exitWith { false };

	if (_key == DIK_TAB) exitWith
	{
		_this select 0 call fxy_dbg_fn_editor_commit;

		//shift
		if (_this select 2) then
		{
			_this select 0 call fxy_dbg_fn_tabs_cycleBackward;
		}
		else
		{
			_this select 0 call fxy_dbg_fn_tabs_cycleForward;
		};

		true
	};

	//ctrl + s
	if (_key == DIK_S) exitWith
	{
		//shift
		if (_this select 2) exitWith {};

		_this select 0 call fxy_dbg_fn_editor_commit;

		//alt
		if (_this select 4) then
		{
			_this select 0 call fxy_dbg_fn_tabs_current_save_as;
		}
		else
		{
			_this select 0 call fxy_dbg_fn_tabs_current_save;
		};

		true
	};

	//ctrl + w
	if (_key == DIK_W) exitWith
	{
		if (!(_this select 2) && !(_this select 4)) then
		{
			_this select 0 call fxy_dbg_fn_editor_commit;
			_this select 0 call fxy_dbg_fn_tabs_current_close;
		};

		true
	};

	false
};

fxy_dbg_dispatch = [nil];

// [display, string, int]
fxy_dbg_eh_onChildDestroyed =
{
	local _dispatch = fxy_dbg_dispatch select 0;

	if (!isnil "_dispatch") then
	{
		fxy_dbg_dispatch set [0, nil];

		local _code = _dispatch select 0;
		_dispatch set [0, _this select 0];

		_dispatch call _code;
	};
};
