/* Public API:

// Remote execute on all machines.
fxy_re_fn_g: callable

// Remote execute on the machine which owns the object.
fxy_re_fn_c: [object, callable]

// Remote execute on the machine which owns the object and wait for the result.
fxy_re_fns_cw: [object, callable] -> result

// Remote execute on the machine which owns the object and invoke a callback with [context, result].
fxy_re_fn_ca: [object, callable, [code, context]]

// Remote execute on the server.
fxy_re_fn_s: callable

// Remote execute on the server and wait for the result.
fxy_re_fns_sw: callable -> result

// Remote execute on the server and invoke a callback with [context, result].
fxy_re_fn_sa: [object, callable, [code, context]]
*/


//#define DEBUG_PRINT

// callable
fxy_re_fn_call =
{
	local _code = _this;
	local _args = [];

	if (typename _this == "ARRAY") then
	{
		if (count _this > 0) then
		{
			_code = _this select 0;

			if (count _this > 1) then
			{
				_args = _this select 1;
				if (isnil "_args") then
				{
					_args = [];
				};
			};
		}
	};

	if (typename _code == "STRING") then
	{
		_code = compile _code;
	};

	if (typename _code != "CODE") then
	{
		_code = {};
	};

	_args call _code
};


// callable
"fxy_re_pv_g" addPublicVariableEventHandler
{
#ifdef DEBUG_PRINT
	diag_log format ["fxy_re_pv_g: %1", _this];
#endif // DEBUG_PRINT

	_this select 1 call fxy_re_fn_call;
};

// callable
fxy_re_fn_g =
{
	isnil {
		fxy_re_pv_g = _this;
		publicVariable "fxy_re_pv_g";

		nil
	};
};


fxy_re_list = [];

fxy_re_free = [];
fxy_re_freeCount = 0;

// any -> id
fxy_re_fn_acq =
{
	local _i = 0;
	if (fxy_re_freeCount > 0) then
	{
		fxy_re_freeCount = fxy_re_freeCount - 1;
		_i = fxy_re_free select fxy_re_freeCount;
	}
	else
	{
		_i = count fxy_re_list;
	};

	fxy_re_list set [_i, _this];

	_i
};

// id
fxy_re_fn_rel =
{
	local _re = fxy_re_list select _this;

	fxy_re_list set [_this, nil];
	fxy_re_free set [fxy_re_freeCount, _this];
	fxy_re_freeCount = fxy_re_freeCount + 1;

	_re
};

fxy_re_fn_check =
{
	local _i = [0, 1] select _expectObject;

	if (isnil "_this") exitWith { diag_log "_this is nil"; false };
	if (typename _this != "ARRAY") exitWith { diag_log "_this is not an array"; false };
	if (count _this < (1 + _i)) exitWith { diag_log "too few arguments"; false };

	if (_expectObject && {
		if (isnil { _this select 0 }) exitWith { diag_log "target is nil"; true };
		if (typename (_this select 0) != "OBJECT") exitWith { diag_log "target is not an object"; true };
		if (isNull (_this select 0)) exitWith { diag_log "object is null"; true };
		false
	}) exitWith { false };

	if (isnil { _this select _i }) exitWith { diag_log "callable is nil"; false };

	if (count _this == (1 + _i)) exitWith { true };

	if (isnil { _this select (1 + _i) }) exitWith { diag_log "callback is nil"; false };

	local _c = _this select (1 + _i);
	if (typename _c != "ARRAY") exitWith { diag_log "callback is not an array"; false };
	if (count _c < 2) exitWith { diag_log "too few elements in callback"; false };

	if (isnil { _c select 0 }) exitWith { diag_log "callback handler is nil"; false };
	if (typename (_c select 0) != "CODE") exitWith { diag_log "callback handler is not code"; false };

	true
};

if isServer then
{
	// [object, callable, callable?]
	fxy_re_fn_ca =
	{
		local _expectObject = true;
		if (!(call fxy_re_fn_check)) exitWith
		{
			diag_log "Invalid arguments to fxy_re_fn_ca";
		};

		isnil {
			local _args = [_this select 1];

			if (count _this > 2) then
			{
				_args set [1, _this select 2 call fxy_re_fn_acq];
			};

			fxy_re_pvc_c = _args;
			owner (_this select 0) publicVariableClient "fxy_re_pvc_c";

			nil
		};
	};

	// [callable, id?, object?]
	"fxy_re_pvs_s" addPublicVariableEventHandler
	{
#ifdef DEBUG_PRINT
		diag_log format ["fxy_re_pvs_s: %1", _this];
#endif // DEBUG_PRINT

		local _data = _this select 1;
		local _r = _data select 0 call fxy_re_fn_call;

		if (count _data > 1) then
		{
			fxy_re_pvc_r = [_data select 1, _r];
			owner (_data select 2) publicVariableClient "fxy_re_pvc_r";
		};
	};

	// [[id, object], result]
	fxy_re_fn_f =
	{
		local _c = _this select 0;
		fxy_re_pvc_r = [_c select 0, _this select 1];
		owner (_c select 1) publicVariableClient "fxy_re_pvc_r";
	};

	// [object, callable, id?, object?]
	"fxy_re_pvs_c" addPublicVariableEventHandler
	{
#ifdef DEBUG_PRINT
		diag_log format ["fxy_re_pvs_c: %1", _this];
#endif // DEBUG_PRINT

		local _data = _this select 1;
		if (local (_data select 0)) then
		{
			local _r = _data select 1 call fxy_re_fn_call;

			if (count _data > 2) then
			{
				fxy_re_pvc_r = [_data select 2, _r];
				owner (_data select 3) publicVariableClient "fxy_re_pvc_r";
			};
		}
		else
		{
			local _args = [_data select 1];

			if (count _data > 2) then
			{
				_args set [1, [fxy_re_fn_f, [_data select 2, _data select 3]] call fxy_re_fn_acq];
			};

			fxy_re_pvc_c = _args;
			owner (_data select 0) publicVariableClient "fxy_re_pvc_c";
		};
	};

	// [id, result]
	"fxy_re_pvs_r" addPublicVariableEventHandler
	{
#ifdef DEBUG_PRINT
		diag_log format ["fxy_re_pvs_r: %1", _this];
#endif // DEBUG_PRINT

		local _data = _this select 1;
		local _re = _data select 0 call fxy_re_fn_rel;
		[_re select 1, _data select 1] call (_re select 0);
	};


	// callable
	fxy_re_fn_s =
	{
		_this call fxy_re_fn_call;
		nil
	};

	// callable -> result
	fxy_re_fns_sw =
	{
		_this call fxy_re_fn_call
	};
}
else
{
	// [callable, callable?]
	fxy_re_fn_sa =
	{
		local _expectObject = false;
		if (!(call fxy_re_fn_check)) exitWith
		{
			diag_log "Invalid arguments to fxy_re_fn_sa";
		};

		isnil {
			local _args = [_this select 0];

			if (count _this > 1) then
			{
				_args = _args + [_this select 1 call fxy_re_fn_acq, player];
			};

			fxy_re_pvs_s = _args;
			publicVariable "fxy_re_pvs_s";

			nil
		};
	};

	// [object, callable, callable?]
	fxy_re_fn_ca =
	{
		local _expectObject = true;
		if (!(call fxy_re_fn_check)) exitWith
		{
			diag_log "Invalid arguments to fxy_re_fn_ca";
		};

		isnil {
			local _args = [_this select 0, _this select 1];

			if (count _this > 2) then
			{
				_args = _args + [_this select 2 call fxy_re_fn_acq, player];
			};

			fxy_re_pvs_c = _args;
			publicVariableServer "fxy_re_pvs_c";

			nil
		};
	};

	// [callable, id?]
	"fxy_re_pvc_c" addPublicVariableEventHandler
	{
#ifdef DEBUG_PRINT
		diag_log format ["fxy_re_pvc_c: %1", _this];
#endif // DEBUG_PRINT

		local _data = _this select 1;
		local _r = _data select 0 call fxy_re_fn_call;

		if (count _data > 1) then
		{
			fxy_re_pvs_r = [_data select 1, _r];
			publicVariableServer "fxy_re_pvs_r";
		};
	};

	// [id, result]
	"fxy_re_pvc_r" addPublicVariableEventHandler
	{
#ifdef DEBUG_PRINT
		diag_log format ["fxy_re_pvc_r: %1", _this];
#endif // DEBUG_PRINT

		local _data = _this select 1;
		local _re = _data select 0 call fxy_re_fn_rel;
		[_re select 1, _data select 1] call (_re select 0);
	};


	// callable
	fxy_re_fn_s =
	{
		[_this] call fxy_re_fn_sa;
	};

	// callable -> result
	fxy_re_fns_sw =
	{
		local _ctx = [];
		[_this, [fxy_re_fn_w, _ctx]] call fxy_re_fn_sa;
		waitUntil { count _ctx > 0 };
		_ctx select 0
	};
};

// [context, result]
fxy_re_fn_w =
{
	_this select 0 set [0, _this select 1];
};

fxy_re_fn_c = fxy_re_fn_ca;

// [object, callable] -> result
fxy_re_fns_cw =
{
	local _ctx = [];
	_this + [[fxy_re_fn_w, _ctx]] call fxy_re_fn_ca;
	waitUntil { count _ctx > 0 };
	_ctx select 0
};

if hasInterface then
{
	fxy_dbg_fn_serverExec = fxy_re_fn_s;
	fxy_dbg_fn_globalExec = fxy_re_fn_g;
};
