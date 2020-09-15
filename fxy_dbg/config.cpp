class CfgPatches
{
	class fxy_dbg
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {CAUI};
	};
};

#include "basic.hpp"
#include "type.hpp"
#include "style.hpp"

class RscStandardDisplay;
class RscShortcutButton;

#include "grid.h"

#include "RscFxyDebug.hpp"

class RscDisplayInterrupt : RscStandardDisplay
{
	class controls
	{
		class BFxyDebug : RscShortcutButton
		{
			idc = 123800;
			x = 0; y = 0; w = 0; h = 0;
			
			text = "";
			
			default = true;
			action = "createDialog 'RscFxyDebug'";
		};
	};
};

class RscDisplayInterruptEditorPreview : RscStandardDisplay
{
	class controls
	{
		class BFxyDebug : RscShortcutButton
		{
			idc = 123800;
			x = 0; y = 0; w = 0; h = 0;
			
			text = "";
			
			default = true;
			action = "createDialog 'RscFxyDebug'";
		};
	};
};

class RscDisplayMPInterrupt : RscStandardDisplay
{
	class controls
	{
		class BFxyDebug : RscShortcutButton
		{
			idc = 123800;
			x = 0; y = 0; w = 0; h = 0;
			
			text = "";
			
			default = true;
			action = "createDialog 'RscFxyDebug'";
		};
	};
};
