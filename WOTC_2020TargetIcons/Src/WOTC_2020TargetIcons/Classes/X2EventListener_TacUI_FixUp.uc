//*******************************************************************************************
//  FILE:   X2EventListener_TacUI_FixUp
//  
//	File created by RustyDios	28/01/20	12:00	
//	LAST UPDATED				08/02/20	15:00
//
//	ELR to change the colours of eTeamOne and eTeamTwo based on values in the config
//
//*******************************************************************************************

class X2EventListener_TacUI_FixUp extends X2EventListener config (New2020Icons);

//grab config vars
var config bool bFixUpTeamOneIconColour;
var config EUIState e_TeamOneColour;

var config bool bFixUpTeamTwoIconColour;
var config EUIState e_TeamTwoColour;

var config bool bEnableColourLog;

//add the CHEventListener
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(EnemyUIAlterationRUSTY());

	return Templates;
}

//register the CHEventListener
static function CHEventListenerTemplate EnemyUIAlterationRUSTY()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'TheHive_UIColor');

	//do this in tactical games .... CHEvent ('event_TO_watchfor', function to fire, when?)
	Template.RegisterInTactical = true;
	Template.AddCHEvent('OverrideEnemyHudColors', ChangeUIColorRUSTY, ELD_Immediate);

	return Template;
}

//do stuff on hearing the call
static protected function EventListenerReturn ChangeUIColorRUSTY(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;
	//local XComGameState_BattleData BattleState;
	local EUIState uiState1, uiState2;

	//grab the tuple data from the CHEvent
	Tuple = XComLWTuple(EventData);

	//if tuple data is missing, abort
	if(Tuple == none)
	{
		return ELR_NoInterrupt;
	}

	//get the current colours
	uiState1 = EUIState(Tuple.Data[0].i); 
	uiState2 = EUIState(Tuple.Data[1].i); 

	//report to the log
	`LOG("Original eTeamOne colour :: " @ uiState1,default.bEnableColourLog,'Rusty_WOTC_2020Targeticons');
	`LOG("Original eTeamTwo colour :: " @ uiState2,default.bEnableColourLog,'Rusty_WOTC_2020Targeticons');

	//if the current colour has been changed from the default value, assume another mod is effect and abort for this mission
	if(uiState1 != eUIState_Warning2)
	{
		return ELR_NoInterrupt; 
	}

	//get the current state of the battle, this lets us check for active sitreps that ADD an extra team
	//BattleState = XComGameState_BattleData(`XCOMHistory.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	// change the colours.. I don't have anything else on eTeamOne (In my mod setup) and I don't like the default yellow colour
	if (default.bFixUpTeamOneIconColour)
	{
		uiState1 = default.e_TeamOneColour; //eUIState_Warning2;
		Tuple.Data[0].i = uiState1;
	}

	//report to the log
	`LOG("Changed eTeamOne colour :: " @ uiState1,default.bEnableColourLog,'Rusty_WOTC_2020Targeticons');

	//if the current colour has been changed from the default value, assume another mod is effect and abort for this mission
	if(uiState2 != eUIState_Cash)
	{
		return ELR_NoInterrupt; 
	}

	// change the colours.. might as well include team two just in case :)
	if (default.bFixUpTeamTwoIconColour)
	{
		uiState2 = default.e_TeamTwoColour; //eUIState_Cash;
		Tuple.Data[1].i = uiState2;
	}

	//report to the log
	`LOG("Changed eTeamTwo colour :: " @ uiState2,default.bEnableColourLog,'Rusty_WOTC_2020Targeticons');

	//finish listening and go back, these are not the events you are looking for...
	return ELR_NoInterrupt;
}

//////////////////////////////////////
//	Reference to the Tuple Shout Out
//////////////////////////////////////

/*
function EUIState GetMyHUDIconColor()
{
    local XComGameState_Unit StateObject;
    local EUIState TeamOneColor, TeamTwoColor;
    local XComLWTuple OverrideTuple;

    TeamOneColor = eUIState_Warning2;
    TeamTwoColor = eUIState_Cash;

    // issue #188: let mods override default hud colours for these teams
    // Instead of a boolean, we use the Enum instead
    //set up a Tuple for return value

    OverrideTuple = new class'XComLWTuple';
    OverrideTuple.Id = 'OverrideEnemyHudColors';
    OverrideTuple.Data.Add(2);

    // XComLWTuple does not have a Byte kind
    OverrideTuple.Data[0].kind = XComLWTVInt;
    OverrideTuple.Data[0].i = TeamOneColor;
    OverrideTuple.Data[1].kind = XComLWTVInt;
    OverrideTuple.Data[1].i = TeamTwoColor;

    `XEVENTMGR.TriggerEvent('OverrideEnemyHudColors', OverrideTuple, OverrideTuple);
    TeamOneColor = EUIState(OverrideTuple.Data[0].i);
    TeamTwoColor = EUIState(OverrideTuple.Data[1].i);
    StateObject = GetVisualizedGameState();

    //TODO: @gameplay
    //if( IsVIP() )
    //    return eUIState_Bad; 

    //TODO: @gameplay : you may want to move this door check to an override function somewhere else, if not here in XGUnitNativeBase.
    //if( IsADoor() )
    //    return eUIState_Bad; 
    
    if( IsCivilian() ) // TODO: civilian factions? Pro-, neutral, or anti- XCom? 
        return eUIState_Warning; 
    if( StateObject.GetTeam() == eTeam_XCom || StateObject.GetTeam() == eTeam_Resistance)
        return eUIState_Normal; 
    if( StateObject.GetTeam() == eTeam_Alien )
        return eUIState_Bad;
    if( StateObject.GetTeam() == eTeam_TheLost )
        return eUIState_TheLost;
    if(StateObject.GetTeam() == eTeam_One) //issue #188 - support for added team colours
        return EUIState(TeamOneColor);
    if(StateObject.GetTeam() == eTeam_Two)
        return EUIState(TeamTwoColor);
    //end issue #188
    
    //Default to show something is wrong: 
    return eUIState_Disabled;
}
*/

//////////////////////////////////////
//	Reference to the eUIState colours that can be used
//////////////////////////////////////

/*
static function string GetHexColorFromState( int iState )
{
    local string strColor;

    switch( iState )
    {
    case eUIState_Normal:   strColor = NORMAL_HTML_COLOR;   break; //    = "9acbcb"; // Cyan
    case eUIState_Bad:      strColor = BAD_HTML_COLOR;      break; //    = "bf1e2e"; // Red
    case eUIState_Warning:  strColor = WARNING_HTML_COLOR;  break; //    = "fdce2b"; // Yellow
    case eUIState_Warning2: strColor = WARNING2_HTML_COLOR; break; //    = "e69831"; // Orange
    case eUIState_Good:     strColor = GOOD_HTML_COLOR;     break; //    = "53b45e"; // Green
    case eUIState_Disabled: strColor = DISABLED_HTML_COLOR; break; //    = "828282"; // Gray
    case eUIState_Psyonic:  strColor = PSIONIC_HTML_COLOR;  break; //    = "b6b3e3"; // Purple
    case eUIState_Highlight:strColor = NORMAL_HTML_COLOR;   break; //    = "9acbcb"; // Cyan
    case eUIState_Header:    strColor = HEADER_HTML_COLOR;  break; //    = "aca68a"; // Faded Yellow
    case eUIState_Cash:      strColor = CASH_HTML_COLOR;    break; //    = "5CD16C"; // Green
    case eUIState_Faded:    strColor = FADED_HTML_COLOR;    break; //    = "546f6f"; // Faded Cyan
    case eUIState_TheLost:  strColor = THELOST_HTML_COLOR;  break; //    = "acd373"; // nasty green color
    default:
        `warn("UI ERROR: GetHexColorFromState - Unsupported UI state '"$iState$"'");
        strColor = BLACK_HTML_COLOR; break; //    = "000000"; // Black
    }

    return "0x" $ strColor;
}
*/

//////////////////////////////////////
//	Reference to the DropUnit Teams
//////////////////////////////////////

/*
DropUnit Commands/Team;
0	eTeam_None			??
1	eTeam_Neutral		dropunit 4 < this is the 'civilian' team
2	eTeam_One			dropunit 5 < FERAL HIVE, Renegade Rulers
4	eTeam_Two			dropunit 6 < Black Legion, Dark Eldars, most raider factions
8	eTeam_XCom			dropunit 0
16	eTeam_Alien			dropunit 1 < ADVENT, Aliens, ADVENT HIVE
32	eTeam_Lost			dropunit 2 < Lost
64	eTeam_Resistance	dropunit 3 < Resistance, Resistance Hero Incursions
128	eTeam_All			??
??	eTeam_Chosen		??
						dropunit 7+ places on last team, ie 4-6
						dropunit 5/6 places on team 4 in skirmish+ :(
*/
