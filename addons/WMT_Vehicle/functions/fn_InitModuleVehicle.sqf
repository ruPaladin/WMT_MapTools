/*
 	Name: WMT_fnc_InitModuleVehicle
 	
 	Author(s):
		Zealot

 	Description:
		Initialize vehicle module
*/
#define PR(x) private ['x']; x

PR(_logic) = [_this,0,objNull,[objNull]] call BIS_fnc_param;
PR(_units) = [_this,1,[],[[]]] call BIS_fnc_param;
PR(_activated) = [_this,2,true,[true]] call BIS_fnc_param;


if(_activated) then {
	if(isNil "wmt_param_FullRepair") then {
		wmt_param_FullRepair = _logic getVariable "FullRepair";
	};	
	if(isNil "wmt_param_VehicleCrew") then {
		wmt_param_VehicleCrew = _logic getVariable "VehicleCrew";
	};
	if(isNil "wmt_param_LowGear") then {
		wmt_param_LowGear = _logic getVariable "LowGear";
	};	
	if(isNil "wmt_param_PushBoat") then {
		wmt_param_PushBoat = _logic getVariable "PushBoat";
	};
	if(isNil "wmt_param_Reammo") then {
		wmt_param_Reammo = _logic getVariable "Reammo";
	};	
	WMT_mutexAction = false;

	// ==================================== REPAIR =========================================================================
	if (isNil "wmt_param_FullRepair" or { wmt_param_FullRepair == 0}) then {
		WMT_fullRepairClasses = [];
		WMT_fullRepairEnabled = false;
		if (isServer) then {
			[] spawn {
				{ 
					if (getRepairCargo _x > 0) then {
						_x setRepairCargo 0;
						_x setVariable ["wmt_repair_cargo", 1, true]; 
					};
				} foreach vehicles;
			};
		};
		WMT_hardFieldRepairParts = ["HitEngine", "HitLTrack","HitRTrack"];
		WMT_fieldRepairHps = ["HitLFWheel","HitLBWheel","HitLMWheel","HitLF2Wheel","HitRFWheel","HitRBWheel","HitRMWheel","HitRF2Wheel"] + WMT_hardFieldRepairParts;
		if (isDedicated) exitWith {};
		waitUntil {sleep 0.23; player == player};
		_playerClass= toUpper (typeof player);
		switch ( true ) do {
			case (_playerClass in ["B_CREW_F","I_CREW_F","O_CREW_F"]) : {WMT_fullRepairClasses = ["Car","Tank","Ship"];WMT_fullRepairEnabled = true; };
			case (_playerClass in ["O_ENGINEER_F","B_ENGINEER_F","I_ENGINEER_F","B_SOLDIER_REPAIR_F","I_SOLDIER_REPAIR_F","O_SOLDIER_REPAIR_F","B_G_ENGINEER_F"]) : {WMT_fullRepairClasses = ["Car","Tank","Ship","Air"];WMT_fullRepairEnabled = true; };
			case (_playerClass in ["O_PILOT_F","B_PILOT_F","I_PILOT_F","O_HELICREW_F","I_HELICREW_F","B_HELICREW_F","O_HELIPILOT_F","B_HELIPILOT_F","I_HELIPILOT_F"]) : {WMT_fullRepairClasses = ["Car","Tank","Ship","Air"];WMT_fullRepairEnabled = true; };
			case (_playerClass in ["O_SOLDIER_UAV_F","I_SOLDIER_UAV_F","B_SOLDIER_UAV_F"]) : {WMT_fullRepairClasses = ["UGV_01_base_F","UAV_01_base_F","UAV_02_base_F"];WMT_fullRepairEnabled = true; };
		};
		
		player addAction["<t color='#0000ff'>"+localize("STR_CANCEL_ACTION")+"</t>", {WMT_mutexAction = false}, [], 10, false, true, '',' WMT_mutexAction  '];
		player addAction["<t color='#ff0000'>"+localize ("STR_FIELD_REPAIR")+"</t>", WMT_fnc_Fieldrepairvehicle, [], -1, false, true, '','(not isNull cursorTarget) and {alive player} and {(player distance cursortarget) <= 7} and {(vehicle player == player)} and {speed cursortarget < 3} and {not WMT_mutexAction} and {alive cursortarget} and {cursortarget call WMT_fnc_vehicleIsDamaged}'];
		if (WMT_fullRepairEnabled) then {
			player addAction["<t color='#ff0000'>"+localize ("STR_SERIOUS_REPAIR")+ "</t>", WMT_fnc_FullRepair, [], -1, false, true, '','(not isNull cursorTarget) and {vehicle player == player} and {player distance cursortarget <= 7 and damage cursortarget != 0} and {alive player and alive cursortarget} and {speed cursortarget < 3} and {not WMT_mutexAction}'];
		};

		player addEventHandler ["Respawn", {
			player addAction["<t color='#0000ff'>"+localize("STR_CANCEL_ACTION")+"</t>", {WMT_mutexAction = false}, [], 10, false, true, '',' WMT_mutexAction  '];
			player addAction["<t color='#ff0000'>"+localize ("STR_FIELD_REPAIR")+"</t>", WMT_fnc_Fieldrepairvehicle, [], -1, false, true, '','(not isNull cursorTarget) and {alive player} and {(player distance cursortarget) <= 7} and {(vehicle player == player)} and {speed cursortarget < 3} and {not WMT_mutexAction} and {alive cursortarget} and {cursortarget call WMT_fnc_vehicleIsDamaged}'];
			if (WMT_fullRepairEnabled) then {
				player addAction["<t color='#ff0000'>"+localize ("STR_SERIOUS_REPAIR")+ "</t>", WMT_fnc_FullRepair, [], -1, false, true, '','(not isNull cursorTarget) and {vehicle player == player} and {player distance cursortarget <= 7 and damage cursortarget != 0} and {alive player and alive cursortarget} and {speed cursortarget < 3} and {not WMT_mutexAction}'];
			};
		}];
	};
	// ================================================= REARM =============================================================
	if (isNil "wmt_param_Reammo" or { wmt_param_Reammo==0 }) then {
		if (isServer) then {
			if (isNil "wmt_ammoCargoVehs") then {
				wmt_ammoCargoVehs = [];
			};
			{
				_ammoCargo = getAmmoCargo _x ;
				if (_ammoCargo > 0 and _ammoCargo < 2) then {
					wmt_ammoCargoVehs set [count wmt_ammoCargoVehs, _x];
					_x setAmmoCargo 0;
				};
			} foreach vehicles;
		};
		if(isDedicated) exitWith {};
		waitUntil {sleep 0.23; player == player};
		if(true && (!(["engineer" ,str(typeOf player)] call BIS_fnc_inString) && !(["crew" ,str(typeOf player)] call BIS_fnc_inString) && !(["pilot",str(typeOf player)] call BIS_fnc_inString))) exitWith {};

		waitUntil {sleep 0.41;time > 0};
		player addAction[ format ["<t color='#ff0000'>%1</t>", (localize "STR_ACTION_REAMMO") ] , wmt_fnc_Reammo, [], 1, false, true, '','[] call wmt_fnc_ReammoCond'];
	};

	// ================================================= ELSE ==============================================================

	if (isDedicated) exitWith {};
	waitUntil {sleep 0.39; player == player};

	if (isNil "wmt_param_PushBoat" or {wmt_param_PushBoat==0}) then {
		player addAction ["<t color='#FF9900'>"+localize('STR_PUSH_BOAT')+"</t>",WMT_fnc_pushboat,[],-1,false,true,"",'vehicle player == player and {not isNull cursorTarget} and {cursorTarget isKindOf "Ship"} and {player distance cursorTarget < 8} and {not WMT_mutexAction}'];  
		player addEventHandler ["Respawn", {
			player addAction ["<t color='#FF9900'>"+localize('STR_PUSH_BOAT')+"</t>",WMT_fnc_pushboat,[],-1,false,true,"",'vehicle player == player and {not isNull cursorTarget} and {cursorTarget isKindOf "Ship"} and {player distance cursorTarget < 8} and {not WMT_mutexAction}'];  
		}];
	};

	if (isNil "WMT_flagDisableStaticWeaponDrag" or {WMT_flagDisableStaticWeaponDrag ==0}) then {
		player addAction ["<t color='#ff0000'>"+localize("STR_DRAG_STATIC")+"</t>", WMT_fnc_StaticWpnDrag, [], -1, false, true, '','not isNull cursorTarget and {cursorTarget isKindOf "StaticWeapon"} and {cursorTarget distance player < 3} and {not (cursorTarget getVariable ["WMT_drag", false])} and {count crew cursorTarget == 0};'];
		player addEventHandler ["Respawn", {
			player addAction["<t color='#ff0000'>"+localize("STR_DRAG_STATIC")+"</t>", WMT_fnc_StaticWpnDrag, [], -1, false, true, '','not isNull cursorTarget and {cursorTarget isKindOf "StaticWeapon"} and {cursorTarget distance player < 3} and {not (cursorTarget getVariable ["WMT_drag", false])} and {count crew cursorTarget == 0};'];
		}];
	};	

	waitUntil{sleep 0.36; !(isNull (findDisplay 46))};
	if (isNil "wmt_param_VehicleCrew" or {wmt_param_VehicleCrew ==0}) then {
		(findDisplay 46) displayAddEventHandler ["MouseZChanged","_this call WMT_fnc_KeyHandlerShowCrew;"];
	};

	if (isNil "wmt_param_LowGear" or {wmt_param_LowGear==0}) then {

		WMT_LowGear_mutex = diag_tickTime;
		WMT_lowGearOn = false;
		(findDisplay 46) displayAddEventHandler ["KeyDown", {
			_key =_this select 1;
			if(_key in actionKeys "carForward" or _key in actionKeys "carForward" or _key in actionKeys "carFastForward" or _key in actionKeys "carSlowForward")  then {wmt_carforward = true;
		};}];
		(findDisplay 46) displayAddEventHandler ["KeyUp"  , {
			_key =_this select 1;
			if(_key in actionKeys "carForward" or _key in actionKeys "carForward" or _key in actionKeys "carFastForward" or _key in actionKeys "carSlowForward")  then {wmt_carforward = false;
		};}];
		player addAction[ format ["<t color='#ff0000'>%1</t>", (localize "STR_ACTION_LOWGEARON") ], WMT_fnc_LowGear, [], 1, false, true, '','[] call WMT_fnc_LowGearCond'];
		player addAction[ format ["<t color='#ff0000'>%1</t>", (localize "STR_ACTION_LOWGEAROFF")], {WMT_lowGearOn=false;}, [], 1, false, true, '','WMT_lowGearOn'];
	};

};