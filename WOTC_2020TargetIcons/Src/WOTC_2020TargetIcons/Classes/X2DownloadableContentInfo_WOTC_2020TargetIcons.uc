//*******************************************************************************************
//  FILE:   X2DownloadableContentInfo_2020TargetIcons
//  
//	File created by RustyDios	28/01/20	12:00	
//	LAST UPDATED				20/07/20	06:15
//
//	OPTC script to add the new icons based on the config entries
//	Console Command to aid debugging icons for units I don't personally Own !
//
//*******************************************************************************************

class X2DownloadableContentInfo_WOTC_2020TargetIcons extends X2DownloadableContentInfo within XComTacticalController config (New2020Icons);

//create the config structure
struct TISwitch
{
	var name	template;
	var string	icon;
};

// grab config stuffs
var config bool				bLogAllCharacters;

var config array<TISwitch>	TISwitches;
	
///////////////////////////
//	OPTC
//////////////////////////

static event OnPostTemplatesCreated()
{
	SwapAllTargetIconsOPTC();
}

static function SwapAllTargetIconsOPTC()
{
	local X2CharacterTemplate			CharTemplate;
	local X2CharacterTemplateManager	AllChars;

	local XComContentManager			AllContent;

	local X2DataTemplate				Template;
	local int i;

	AllChars = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	AllContent = `CONTENT;

	///////////////////////
	//	Add Some new Icons
	///////////////////////

    for (i =0; i <= default.TISwitches.Length; i++)
	{
		CharTemplate = AllChars.FindCharacterTemplate(default.TISwitches[i].template);
		if (CharTemplate != none)
		{
			//check to see if the image file if available and change it ... method coded with help from CX Iridar and RoboJumper
			//if (DynamicLoadObject(Repl(default.TISwitches[i].icon, "img:///", "", false), class'Texture2D') != none) ... was another method suggested by RoboJumper
			if (AllContent.RequestGameArchetype(default.TISwitches[i].icon) != none)
			{
				CharTemplate.strTargetIconImage = default.TISwitches[i].icon;
			}
		}
	}

	///////////////////////
	//	Logging - Check ALL Icons
	///////////////////////
	if (default.bLogAllCharacters)
	{
		foreach AllChars.IterateTemplates(Template, None)
		{
			CharTemplate = X2CharacterTemplate(Template);
            
			`Log("Template :: " @CharTemplate.DataName @" :: InGameName :: " @CharTemplate.strCharacterName @" :: Group :: " @CharTemplate.CharacterGroupName @" :: IconString :: " @CharTemplate.StrTargetIconImage @" :: HackIconString :: " @CharTemplate.strHackIconImage,default.bLogAllCharacters,'Rusty_WOTC_2020Targeticons');
		}
	}
}

///////////////////////
//	Console Commands -- Swap the target icon of any template mid play, after getting control
///////////////////////

exec function SwapTargetIconOfActiveUnit (string ImagePath) 
{
	local XComGameState					NewGameState;
	local XComGameState_Unit			Unit;
	local XGUnit						ActiveUnit;

	local X2CharacterTemplate			CharTemplate;
	local string						OldPath;

	//create a gamestate for this change
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Swap Target Icon");

	//grab the current active unit
	ActiveUnit = XComTacticalController(GetALocalPlayerController()).GetActiveUnit();

	//check it exists and we found a unit
	if (ActiveUnit == none)
	{
		`log("ERROR :: Could not get a unit for object ID :: ABORT " ,, 'Rusty_WOTC_2020Targeticons');
		return;
	}
	
    if(ActiveUnit != none)
	{
		//find the template
		Unit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ActiveUnit.ObjectID));
		CharTemplate = Unit.GetMyTemplate();

		//store the old path, set the new
		OldPath = CharTemplate.strTargetIconImage;
		CharTemplate.strTargetIconImage = ImagePath;

		//LOG everything.. console command we want to ensure it logs, so no bool toggle
		`log("===== Target Icon Swap ",,'Rusty_WOTC_2020Targeticons');
        `log("===== "@CharTemplate.DataName @" :: "@CharTemplate.strCharacterName ,,'Rusty_WOTC_2020Targeticons');
        `log("===== "@OldPath @" >> "@ImagePath ,,'Rusty_WOTC_2020Targeticons');
	}

	//ensure to submit the new gamestate
	SubmitNewGameState(NewGameState);

}

//***************
//	HELPER Funcs
//***************

//helper function to submit new game states        
protected static function SubmitNewGameState(out XComGameState NewGameState)
{
    local X2TacticalGameRuleset		TacticalRules;
    local XComGameStateHistory		History;
 
    if (NewGameState.GetNumGameStateObjects() > 0)
    {
        TacticalRules = `TACTICALRULES;
        TacticalRules.SubmitGameState(NewGameState);
    }
    else
    {
        History = `XCOMHISTORY;
        History.CleanupPendingGameState(NewGameState);
    }
}

//************************
//	End of file
//************************
