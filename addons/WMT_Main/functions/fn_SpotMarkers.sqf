/*
 	Name: WMT_fnc_SpotMarkers
 	
 	Author(s):
		Ezhuk

 	Description:
		Add local markers on vehicles and squads

	Parameters:
 		Nothing
 	Returns:
		ARRAY: Marker pool 
*/

#include "defines.sqf"

PR(_side) = side player;
PR(_markersPool) = [];

// Vehicles
{
	if(!(_x isKindOf "Strategic") && !(_x isKindOf "Thing")) then
	{
		PR(_show) = false;
		if(_x getVariable ["WMT_side",sideLogic] == _side) then {
			_show = true;
		}else{
			PR(_nearestUnit) = nearestObject [_x, "Man"];
			if(!(isNil "_nearestUnit") ) then {
				if( side player == side _nearestUnit) then {
					_show = true;
				};
			};
		};

		if(_show) then {
			PR(_text) = format ["%1", getText (configFile >> "CfgVehicles" >> (typeOf (_x)) >> "displayName") ];
			PR(_markerName) = format ["WMT_PrepareTime_%1_%2",_text,count _markersPool];
			PR(_marker) = [_markerName,getPos _x,_text,"ColorYellow","mil_box",[1, 1],"ICON",0,"Solid"] call WMT_fnc_CreateLocalMarker;

			_markersPool set [count _markersPool, _marker];
		};
	};
}forEach vehicles;

// Squads
{
	PR(_leader) = leader _x;
	PR(_pos) = getPos _leader;

	if( (side _leader) == _side) then {
		PR(_text) = format ["%1 %2", groupID _x , if(isPLayer _leader)then{name _leader}else {""}];
		PR(_markerName) = format ["WMT_PrepareTime_%1_%2",_text,count _markersPool];
		PR(_marker) = [_markerName,getPos _leader,_text,([side _leader, true] call BIS_fnc_sidecolor),"mil_dot",[1, 1],"ICON",0,"Solid"] call WMT_fnc_CreateLocalMarker;

		_markersPool set [count _markersPool, _marker];
	};
}forEach allGroups;

_markersPool