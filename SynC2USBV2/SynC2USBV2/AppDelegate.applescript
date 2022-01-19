--
--  AppDelegate.applescript
--  SynC2USB
--
--  Created by Rediwed on 10/13/11.
--  This program is not reserved by any rights.
--  but please dont copy my work without asking me about it.
--
--
--     This synchronisation tool is built by Rediwed.
--     
--     This is the synchronisation engine of SynC2USB.
--     I am trying to make this a effecient engine so that it doesnt have to copy a entire folder, instead it 
--     will only copy files that do not excist in the destination folder.
--     
--     I will probably integrate scripts and codes made by other people and credit them for it,
--     if I can find their (User)name(s).
--
--     Special thanks to: dj wazzie bazzie from OMT and Macscripter!
--
--     You are allowed to copy/use code of this program, Please credit me (Rediwed) for you using my code.

    property NSNotificationCenter : class "NSNotificationCenter"
    property NSPipe : class "NSPipe"
    property NSTask : class "NSTask"
    property NSString : class "NSString"

script AppDelegate
    
    ---- Begin declaring objects ----
    
	property parent : class "NSObject"
    property NSImage : class "NSImage" 

	property SourcePathLabel : missing value
	property OnChangeSourceInput : missing value
	property DestinationPathLabel : missing value
	property OnChangeDestinationInput : missing value
	property VersionNumber : missing value
	property openWindow : missing value
	property Workingmessage : missing value
	property Onsync : missing value
	property OnSettings : missing value
	property StatusBar : missing value
	property StatusBarText : missing value
	property syncPanel : missing value
	property ProgressBar : missing value
	property ConfrimresetWindow : missing value
    property setsourcepathusingprompt :missing value
	property continueReset : missing value
	property CancelReset : missing value
	property rundebugmode : "0"
    property sourcefolder :missing value
    property OnResetInput :missing value
    property destfolder :missing value
    property debugmodebox : missing value
    property sArchive : missing value
    property sHL : missing value
    property sGroup : missing value
    property sPermissions : missing value
    property sTimes : missing value
    property sUpdate : missing value
    property settingspanel : missing value
    property SaveSettings : missing value
    property rssettings : missing value
    property rssettingstemp : missing value
    property CustomMode : missing value
    property StandardMode : missing value
    property SettingsMode : missing value
    property EnableSettings : missing value
    property rssettingsenabled : missing value
    property rssettingsenabledtemp : missing value
    property UseStandardSettings : missing value
    property Mode : missing value
    property CustomModeField : missing value
    property PrepSettingsSheet : missing value
    property sourcepath : missing value
    property destpath : missing value
    property rsstandardsettings : missing value
    property rsyncpathdest : missing value
    property rsyncpathsource : missing value
    property newstring1 : missing value
    property ProgressMessage : missing value
    property destpathold : missing value
    property sourcefolderold : missing value
    ---- End declaring objects ----

	---- Begin launch routines (before rendering window's) ----
    
	on applicationWillFinishLaunching_(aNotification)
        OnResetInput's setEnabled_(false)
		set apptitle to "I2USB"
		set syncnow to "Now syncing.."
		VersionNumber's setStringValue_("Version: " & "1.0 (Beta)")
		DestinationPathLabel's setStringValue_(Workingmessage as text)
		SourcePathLabel's setStringvalue_(Workingmessage as text)
		OnChangeDestinationInput's setTitle_("Destination")
		OnChangeSourceInput's setTitle_("Source")
		--Onsync's setTitle_("Synchronize")
		OnSettings's setTitle_("Advanced")
        debugmodebox's setState_(0)
		checkdestpath_()
		checksourcepath_()
        set rssettingsenabled to (do shell script "defaults read com.dpe.sync2usbengine rssettingsenabled")
        if rssettingsenabled = "missing value" then
            debugmode_("rssettingsenabled doesnt contain any value, Setting value '0'")
            set rssettingsenabled to "0"
            do shell script "defaults write com.dpe.sync2usbengine rssettingsenabled 0"
            debugmode_("value of rssettingsenabbled should be set")
            end
        set rssettings to (do shell script "defaults read com.dpe.sync2usbengine rssettings")
        set rssettingstemp to (do shell script "defaults read com.dpe.sync2usbengine rssettings")
        if rssettingsenabled = "1" then
            (*try
                set rssettings to (do shell script "defaults read com.dpe.sync2usbengine rssettings")
                CustomModeField's setStringValue_(rssettings)
            on Error
                do shell script "defaults write com.dpe.sync2usbengine rssettings -a"
                set rssettings to (do shell script "defaults read com.dpe.sync2usbengine rssettings")
                CustomModeField's setStringValue_(rssettings)
            end*)
            sGroup's setState_(0)
            sHL's setState_(0)
            sPermissions's setState_(0)
            sTimes's setState_(0)
            sUpdate's setState_(0)
            sArchive's setState_(0)
        else
        
            set UseStandardSettings to "1"
            EnableSettings's setState_(0)
            sArchive's setEnabled_(false)
            sGroup's setEnabled_(false)
            sHL's setEnabled_(false)
            sPermissions's setEnabled_(false)
            sTimes's setEnabled_(false)
            sUpdate's setEnabled_(false)
            sArchive's setEnabled_(false)
            --CustomModeField's setEnabled_(false)
            sGroup's setState_(0)
            sHL's setState_(0)
            sPermissions's setState_(0)
            sTimes's setState_(0)
            sUpdate's setState_(0)
            sArchive's setState_(1)
        end
        set Mode to "0"
	end applicationWillFinishLaunching_
    
    ---- End launch routines ----
	
	---- Begin checking plist for source and dest folder, on error prompt to set new ones ----
	
	on checkdestpath_()
		try
			debugmode_("Trying to read destination folder")
			set destfolder to (do shell script "defaults read com.dpe.sync2usbengine destfolder" as text)
			
			debugmode_("Trying to set DestinationPathLabel")
			DestinationPathLabel's setStringValue_(destfolder)
			debugmode_("Succesfully set DestinationPathLabel")
            on error
			
			debugmode_("Error on setting DestinationPathLabel, .plist probably doesnt contain information")
			
			debugmode_("Running setdestpathusingprompt")
			setdestpathusingprompt_()
			
		end try
        
	end checkdestpath_
	
	on checksourcepath_()
		try
			set SourcePath to (do shell script "defaults read com.dpe.sync2usbengine sourcefolder" as text)
			SourcePathLabel's setStringValue_(SourcePath)
            on Error
            setsourcepathusingprompt_()
		end try
	end checksourcepath_
    
    ---- Begin checking plist for source and dest folder ----
    
    ---- Begin set label's of dest and source ----
    
	on setdestpathusingprompt_()
		debugmode_("Choose Destination folder")
		set destpath to (choose folder with prompt "Choose the destination folder.") as text
		debugmode_("Trying to save destination folder " & destpath)
		do shell script "defaults write com.dpe.sync2usbengine destfolder " & destpath
		debugmode_("Succesfully saved destination folder")
		debugmode_("Running checkdestpath")
		checkdestpath_()
	end setdestpathusingprompt_
    
	on setsourcepathusingprompt_()
        set sourcefolder to (choose folder with prompt "Choose the source folder.") as text
        do shell script "defaults write com.dpe.sync2usbengine sourcefolder " & sourcefolder
        checksourcepath_()
    end setsourcepathusingprompt_
    
    ---- End set label's of dest and source ----
	
    ---- Begin Actions received from xib ----
    
	on applicationShouldTerminate_(sender)
		return current application's NSTerminateNow
	end applicationShouldTerminate_
    
    on debugmodebox_(sender)
        log "Subroutine: Debugmodebox"
        set debugmodeboxState to debugmodebox's state() as text
        if debugmodeboxState is "1" then
            set rundebugmode to "1"
            log "Debug mode's state is: " & rundebugmode
        else 
            set rundebugmode to "0"
            log "Debug mode's state is: " & rundebugmode
        end
    end debugmodebox_
        
    (*on CustomMode_(sender)
            set Mode to "1"
            sArchive's setEnabled_(false)
            sGroup's setEnabled_(false)
            sHL's setEnabled_(false)
            sPermissions's setEnabled_(false)
            sTimes's setEnabled_(false)
            sUpdate's setEnabled_(false)
            sArchive's setEnabled_(false)
        if EnableSettings's state() as text ="1"
        CustomModeField's setEnabled_(true)
        end
    end CustomMode_*)
        
    (*on StandardMode_(sender)
        if EnableSettings's state() as text = "1" then
            set Mode to "0"
            sArchive's setEnabled_(true)
            sGroup's setEnabled_(true)
            sHL's setEnabled_(true)
            sPermissions's setEnabled_(true)
            sTimes's setEnabled_(true)
            sUpdate's setEnabled_(true)
            sArchive's setEnabled_(true)
            CustomModeField's setEnabled_(false)
            else
            debugmode_("Not enabled Standard Mode")
            end
            
    end StandardMode_*)
        
        on OnSettings_(sender)
            debugmode_("On settings routine")
            if sender = EnableSettings() then
            debugmode_("Prepare sheet and dont open sheet")
            PrepSettingsSheet_()
            else
            debugmode_("Prepare sheet and open sheet")
            PrepSettingsSheet_()
            current application's NSApp's beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo_(settingspanel, openWindow, me, settingspanel, missing value)
            end
        end OnSettings_
    
    on OnChangeDestinationInput_(sender)
        set destpathold to destpath
        set destpath to (choose folder with prompt "Choose the destination folder.") as text
        if destpath contains " " then
            SpaceInName_()
            set destpath to destpathold
            else
        do shell script "defaults write com.dpe.sync2usbengine destfolder " & destpath
                    
        checkdestpath_()
        end
    end OnChangeDestinationInput_
        
        on OnChangeSourceInput_(sender)
            set sourcefolderold to sourcefolder
            set sourcefolder to (choose folder with prompt "Choose the source folder.") as text
            if sourcefolder contains " " then
                SpaceInName_()
                set destpath to destpathold
                set sourcefolder to sourcefolderold
                else
            do shell script "defaults write com.dpe.sync2usbengine sourcefolder " & sourcefolder
            
            checksourcepath_()
            end
        end OnChangeSourceInput_
    
    on SaveSettings_(sender)
        debugmode_("Save settings subroutine")
        try
        set rssettings to rssettingstemp
            if rssettings = "" then
                
                do shell script "defaults delete com.dpe.sync2usbengine rssettings"
                else
            do shell script "defaults write com.dpe.sync2usbengine rssettings " & rssettings
                debugmode_("Saved " & rssettings)
                end
        on error
           debugmode_("Settings unchanged")
        end
        try
        
            set rssettingsenabled to rssettingsenabledtemp as text
            do shell script "defaults write com.dpe.sync2usbengine rssettingsenabled " & rssettingsenabled
            on error
            debugmode_("Settings enabled unchanged")
            end
        
        settingspanel's orderOut_(me)
        current application's NSApp's endSheet_(settingspanel)
        debugmode_("Settings should be saved")
    end
    ---- Begin sync SUBroutine('s) ----
    
	on onsync_(sender)
		debugmode_("Start Syncing to " & sourcefolder)
		debugmode_("Opening and preparing panel")
        
		Loadsheet_()
        ProgressBar's startAnimation_(me)
        
        (*
         set sourcefolderm to SaR(sourcePath, ":", "/")
        set destfolderm to SaR(destfolder, ":", "/")
        --display dialog destfolderm
        
        tell application "Finder"
            set bootDisk to (get name of startup disk) as text
        end tell
        
        if rssettingsenabled = "0" then
            set rssettings to "a"
        end
            try
                set rsyncpaths to "/volumes/" & sourcefolderm & " /volumes/" & destfolderm
                do shell script " rsync -" & rssettings & rsyncpaths
            on error ern
                log ern
                error_(ern)
            end
         *)
        set sourcefolderm to SaR(sourcePath, ":", "/")
        set destfolderm to SaR(destfolder, ":", "/")
        
        set rsyncpathsource to ("/volumes/" & sourcefolderm as text)
        set rsyncpathdest to ("/volumes/" & destfolderm as text)
        set rsstandardsettings to ("--progress")
        set arraylist to {ref rssettings, ref rsstandardsettings, ref rsyncpathsource, ref rsyncpathdest}
        log arraylist
		set currentTask to NSTask's alloc's init()
		set outputpipe to NSPipe's pipe()
		currentTask's setStandardOutput_(outputpipe)
		currentTask's setStandardError_(outputpipe)
		currentTask's setLaunchPath_("/usr/bin/rsync")
		currentTask's setArguments_(arraylist)
		
        
		NSNotificationCenter's defaultCenter()'s addObserver_selector_name_object_(me, "readPipe:", "NSFileHandleReadCompletionNotification", currentTask's standardOutput()'s fileHandleForReading())
        NSNotificationCenter's defaultCenter()'s addObserver_selector_name_object_(me, "endPipe:", "NSTaskDidTerminateNotification", currentTask)
		currentTask's standardOutput()'s fileHandleForReading()'s readInBackgroundAndNotify()
		
        currentTask's |launch|()
        StatusBarText's setStringValue_("Working..." as text)
	end onsync_
    
    ---- End sync SUBroutine('s)
    
    ---- End Actions received from xib ----

    
    on SaR(sourceText, findText, replaceText)
        try
        set {atid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, findText}
        set tempText to text items of sourceText
        set AppleScript's text item delimiters to replaceText
        set sourceText to tempText as string
        set AppleScript's text item delimiters to atid
        on error error_string number error_number
        debugmode_({error_string} & {error_number})
        return sourceText
        end
        return sourceText as text
    end SaR
	
    
	on Loadsheet_()
		debugmode_("preparing sheet")
		
		debugmode_("Opening sheet")
		current application's NSApp's beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo_(syncPanel, openWindow, me, syncPanel, missing value)
        
        ProgressBar's stopAnimation_(me)
		debugmode_("Opened and prepared sheet, returning to subroutine startsync.")
        
        
	end Loadsheet_
        
        ---- Begin settings routine ----
        on setSettings_(sender)
            debugmode_("-----------------")
            debugmode_("Checking settings")
            debugmode_("-----------------")
            set rssettingstemp to ""
            set ArchiveState to sArchive's state() as text
            if ArchiveState is "1" then
                set A to "1"
                debugmode_("Checked; A")
                else 
                debugmode_("Unchecked; A")
                set A to "0"
            end
            set HLState to sHL's state() as text
            if HLState is "1" then
                set HL to "1"
                debugmode_("Checked; HL")
                else 
                debugmode_("Unchecked; HL")
                set HL to "0"
            end
            set GroupState to sGroup's state() as text
            if GroupState is "1" then
                set G to "1"
                debugmode_("Checked; G")
                else 
                debugmode_("Unchecked; G")
                set G to "0"
            end
            set PermissionsState to sPermissions's state() as text
            if PermissionsState is "1" then
                set P to "1"
                debugmode_("Checked; P")
                else 
                debugmode_("Unchecked; P")
                set P to "0"
            end
            set TimesState to sTimes's state() as text
            if TimesState is "1" then
                set T to "1"
                debugmode_("Checked; T")
                else 
                debugmode_("Unchecked; T")
                set T to "0"
            end
            set UpdateState to sUpdate's state() as text
            if UpdateState is "1" then
                set U to "1"
                debugmode_("Checked; U")
                else 
                debugmode_("Unchecked; U")
                set U to "0"
            end
            if A ="1" then
                set rssettingstemp to rssettingstemp & "a"
                end
            if HL ="1" then
                set rssettingstemp to rssettingstemp & "H"
            end
            if G ="1" then
                set rssettingstemp to rssettingstemp & "g"
            end
            if P ="1" then
                set rssettingstemp to rssettingstemp & "p"
            end
            if T ="1" then
                set rssettingstemp to rssettingstemp & "t"
            end
            if U ="1" then
                set rssettingstemp to rssettingstemp & "u"
            end
            debugmode_("-----------------")
            end setSettings_
        
        on checkSettings_()
            end checkSettings_
            
	---- End settings routines ----
    ---- Begin Sheet prep routine ----
        on PrepSettingsSheet_()
            --sGroup
            --sHL
            --sPermissions
            --sTimes
            --sUpdate
            --sArchive
            if rssettings contains "A" then
                sArchive's setState_(1)
            end
            if rssettings contains "H" then
                sHL's setState_(1)
            end
            if rssettings contains "G" then
                sGroup's setState_(1)
            end
            if rssettings contains "P" then
                sPermissions's setState_(1)
            end
            if rssettings contains "t" then
                sTimes's setState_(1)
            end
            if rssettings contains "U" then
                sUpdate's setState_(1)
            end
            end PrepSettingsSheet_
    ---- Begin debug routines (for developer only) ----
    
	on debugmode_(inputdata)
        set data2log to (inputdata as text)
		if rundebugmode = "1" then
			log (data2log)
		end if
	end debugmode_ 
    
    on errorx_(x)
        
        end error_
    
    ---- End debug routines ----
    
    ---- Begin Notifitacion routines ----
    on readPipe_(aNotification)
        debugmode_("Reading pipe notification")
		set dataString to aNotification's userInfo's objectForKey_("NSFileHandleNotificationDataItem")
		set newstring to ((NSString's alloc()'s initWithData_encoding_(dataString, current application's NSUTF8StringEncoding)))
        debugmode_(newstring as text)
        set newstring to newstring as text
        if newstring contains "building file list" then
        set ProgressMessage to "Scanning files..."
        else if newstring contains "files..." then
            set applescript's text item delimiters to " "
            set ProgressMessage to text item 1 of newstring
        else if newstring contains "to-check=" then
        ProgressBar's setIndeterminate_(0)
        set olddelim to applescript's text item delimiters
        set AppleScript's text item delimiters to "to-check="
        set delimited to text item 2 of newstring
        set AppleScript's text item delimiters to "/"
        set current to text item 1 of delimited
        set total to text item 2 of delimited
        set AppleScript's text item delimiters to ")"
        set total to text item 1 of total
        set percentage to current / total as text
        set percentageBy100 to percentage * 100 as text
        set relativePercentage to character 1 of (percentageBy100 as text)
        set relativePercentage to relativePercentage & character 2 of (percentageBy100 as text)
        log "Relative percentage: " & 100 - relativePercentage
        set CorrectPercentage to 100 -relativePercentage
        
        ProgressBar's setIndeterminate_(0)
        ProgressBar's setDoubleValue_(CorrectPercentage as text)
            Set ProgressMessage to "Copying files..."
        end
        debugmode_("Checking ProgressMessage")
        if ProgressMessage is "" then
            set ProgressMessage to "Working..."
            end
        debugmode_("Setting Message")
		StatusBarText's setStringValue_(ProgressMessage as text)
        --currentTask's resume(yes)
		aNotification's object()'s readInBackgroundAndNotify()
	end readPipe_
	
	on endPipe_(aNotification)
        debugmode_("Ending pipe")
		NSNotificationCenter's defaultCenter()'s removeObserver_(me)
        --delay 1
        syncPanel's orderOut_(me)
        current application's NSApp's endSheet_(syncPanel)
	end endPipe_
    ---- End notification routines ----
    
    on EnableSettings_(sender)
        debugmode_("Setting box's should be enabled")
        set enabledradioboxstate to EnableSettings's state() as text
        if enabledradioboxstate is  "1" then
            --if Mode = "1" then
            --else
            set rssettingsenabledtemp to "1"
            debugmode_("Enabled state is: 1")
            sArchive's setEnabled_(true)
            sGroup's setEnabled_(true)
            sHL's setEnabled_(true)
            sPermissions's setEnabled_(true)
            sTimes's setEnabled_(true)
            sUpdate's setEnabled_(true)
            sArchive's setEnabled_(true)
            onSettings_(sender)
            debugmode_("Setting box's should be enabled")
            --end
            else
            
            set rssettingsenabledtemp to "0"
            debugmode_("Enabled state is: 0")
            sArchive's setEnabled_(false)
            sGroup's setEnabled_(false)
            sHL's setEnabled_(false)
            sPermissions's setEnabled_(false)
            sTimes's setEnabled_(false)
            sUpdate's setEnabled_(false)
            sArchive's setEnabled_(false)
            debugmode_("Settings box's should be disabled")
            --if Mode ="0" then
            --CustomModeField's setEnabled_(false)
            --end
            
            sGroup's setState_(0)
            sHL's setState_(0)
            sPermissions's setState_(0)
            sTimes's setState_(0)
            sUpdate's setState_(0)
            sArchive's setState_(1)
        end
        End EnableSettings_

    On SpaceInName_()
        Display dialog "SynC2USB currently doesn't support folders with a space in its name" buttons {"Ok"}
    End SpaceInName_
        
    end script