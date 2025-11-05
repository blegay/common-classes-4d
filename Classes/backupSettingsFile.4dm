// Class backupSettingsFile
// This class can read and write properties from the
// backup settings file
// Bruno LEGAY - 2025-11-05

/*
var $backupSettingsFile : cs.backupSettingsFile
$backupSettingsFile:=cs.backupSettingsFile.new()

$backupSettingsFile.load()

If ($backupSettingsFile.schedulerFrequency#"Daily")
  $backupSettingsFile.schedulerFrequency:="Daily"
  $backupSettingsFile.schedulerDaily:={every: 1; hour: "21:00:00"}

  $backupSettingsFile.save()
End if 

$backupSettingsFile.release()
*/

property _possible : Boolean
property _settingsFile : 4D:C1709.File
property _domRootRef : Text
property _modified : Boolean
//property _logger : cs.logFactory

Class constructor()
	
	This:C1470._possible:=(Application type:C494#4D Remote mode:K5:5)
	If (This:C1470._possible)
		This:C1470._settingsFile:=File:C1566(Current backup settings file:K5:29)
		//This._settingsFile:=File(Backup settings file)
	End if 
	//This._logger:=cs.logFactory.me
	
	
Function load()
	
	If (This:C1470._possible)
		If (This:C1470._settingsFile.exists)
			
			Try
				
				var $xml : Text
				$xml:=This:C1470._settingsFile.getText()
				This:C1470._domRootRef:=DOM Parse XML variable:C720($xml)
				
				This:C1470._modified:=False:C215
				
				This:C1470._log("load file \""+This:C1470._settingsFile.path+"\" success (root ref \""+Lowercase:C14(This:C1470._domRootRef)+"\"), stamp : "+String:C10($stamp); "info")
			Catch
				This:C1470._log("load file \""+This:C1470._settingsFile.path+"\" error : "+JSON Stringify:C1217(Last errors:C1799); "error")
			End try
			
		Else 
			This:C1470.reset()
		End if 
	End if 
	
	
Function reset()
	
	If (This:C1470._possible)
		var $backupFodler : 4D:C1709.Folder
		$backupFodler:=Folder:C1567(fk data folder:K87:12).folder("Backups")
		If (Not:C34($backupFodler.exists))
			$backupFodler.create()
		End if 
		
		This:C1470._domRootRef:=DOM Create XML Ref:C861("Preferences4D"; "http://www.4d.com/namespace/reserved/2004/backup")
		
		This:C1470.tryBackupAtTheNextScheduledDate:=True:C214
		This:C1470.tryToBackupAfter:=Time:C179("00:05:00")
		This:C1470.abortIfBackupFail:=True:C214
		This:C1470.retryCountBeforeAbort:=1
		This:C1470.automaticRestore:=True:C214
		This:C1470.automaticLogIntegration:=True:C214
		This:C1470.automaticRestart:=True:C214
		This:C1470.backupIfDataChange:=False:C215
		This:C1470.setNumberEnabled:=True:C214
		This:C1470.setNumberValue:=2
		This:C1470.compressionRate:="None"
		This:C1470.redundancy:="None"
		This:C1470.interlacing:="None"
		This:C1470.automaticLogIntegrationStrictness:="strict"
		This:C1470.fileSegmentationDefaultSize:=0
		This:C1470.eraseOldBackupBefore:=True:C214
		This:C1470.checkArchiveFileDuringBackup:=True:C214
		This:C1470.backupJournalVerboseMode:=True:C214
		This:C1470.includeStructureFile:=False:C215
		This:C1470.includeDataFile:=True:C214
		This:C1470.includeAltStructFile:=False:C215
		This:C1470.destinationFolder:=$backupFodler
		This:C1470.includedFiles:=[]
		This:C1470.schedulerFrequency:="Never"
		This:C1470.schedulerHourly:={\
			every: 12; \
			startingAt: "00:00:00"}
		This:C1470.schedulerDaily:={\
			every: 1; \
			hour: "00:00:00"}
		This:C1470.schedulerWeekly:={\
			every: 1; \
			monday: {save: False:C215; hour: "00:00:00"}; \
			tuesday: {save: False:C215; hour: "00:00:00"}; \
			wednesday: {save: False:C215; hour: "00:00:00"}; \
			thursday: {save: False:C215; hour: "00:00:00"}; \
			friday: {save: False:C215; hour: "00:00:00"}; \
			saturday: {save: False:C215; hour: "00:00:00"}; \
			sunday: {save: True:C214; hour: "00:00:00"}\
			}
		This:C1470.schedulerMonthly:={\
			every: 1; \
			hour: "00:00:00"; \
			day: 1}
		
		This:C1470._modified:=True:C214
		
		This:C1470._log("reset default values : "+JSON Stringify:C1217(This:C1470.toObject()); "info")
	End if 
	
	
Function release()
	
	If (This:C1470._domRootRef#"")
		DOM CLOSE XML:C722(This:C1470._domRootRef)
		
		This:C1470._log("xml released (root ref \""+Lowercase:C14(This:C1470._domRootRef)+"\")"; "info")
		
		This:C1470._domRootRef:=""
		This:C1470._modified:=False:C215
		
	End if 
	
	
Function save()
	
	If (This:C1470._possible && This:C1470.loaded)
		
		If (This:C1470._modified)
			
			Try
				
				DOM EXPORT TO FILE:C862(This:C1470._domRootRef; This:C1470._settingsFile.platformPath)
				This:C1470._log("save to file \""+This:C1470._settingsFile.path+"\" success"; "info")
				
			Catch
				This:C1470._log("save to file \""+This:C1470._settingsFile.path+"\" error : "+JSON Stringify:C1217(Last errors:C1799); "error")
			End try
			
		Else 
			This:C1470._log("save to file \""+This:C1470._settingsFile.path+"\" unneccessary (no modification)"; "info")
		End if 
		
	End if 
	
	
Function getXmlText()->$xml : Text
	
	If (This:C1470._possible && This:C1470.loaded)
		DOM EXPORT TO VAR:C863(This:C1470._domRootRef; $xml)
	End if 
	
	
Function showOnDisk()
	
	If (This:C1470._possible && This:C1470._settingsFile.exists)
		SHOW ON DISK:C922(This:C1470._settingsFile.platformPath)
	End if 
	
	
Function toObject()->$object : Object
	$object:={version: "1.0"; advanced: {}; general: {}; scheduler: {}}
	
	$object.advanced.backupFailure:={}
	$object.advanced.backupFailure.tryBackupAtTheNextScheduledDate:=This:C1470.tryBackupAtTheNextScheduledDate
	$object.advanced.backupFailure.tryToBackupAfter:=Time string:C180(This:C1470.tryToBackupAfter)
	$object.advanced.backupFailure.abortIfBackupFail:=This:C1470.abortIfBackupFail
	$object.advanced.backupFailure.retryCountBeforeAbort:=This:C1470.retryCountBeforeAbort
	$object.advanced.automaticRestore:=This:C1470.automaticRestore
	$object.advanced.automaticLogIntegration:=This:C1470.automaticLogIntegration
	$object.advanced.automaticRestart:=This:C1470.automaticRestart
	$object.advanced.backupIfDataChange:=This:C1470.backupIfDataChange
	$object.advanced.setNumberEnabled:=This:C1470.setNumberEnabled
	$object.advanced.setNumberValue:=This:C1470.setNumberValue
	$object.advanced.compressionRate:=This:C1470.compressionRate
	$object.advanced.redundancy:=This:C1470.redundancy
	$object.advanced.interlacing:=This:C1470.interlacing
	$object.advanced.automaticLogIntegrationStrictness:=This:C1470.automaticLogIntegrationStrictness
	$object.advanced.fileSegmentationDefaultSize:=This:C1470.fileSegmentationDefaultSize
	$object.advanced.eraseOldBackupBefore:=This:C1470.eraseOldBackupBefore
	$object.advanced.checkArchiveFileDuringBackup:=This:C1470.checkArchiveFileDuringBackup
	$object.advanced.backupJournalVerboseMode:=This:C1470.backupJournalVerboseMode
	
	$object.general.includeStructureFile:=This:C1470.includeStructureFile
	$object.general.includeDataFile:=This:C1470.includeDataFile
	$object.general.includeAltStructFile:=This:C1470.includeAltStructFile
	$object.general.destinationFolder:=This:C1470.destinationFolder.path
	$object.general.includedFiles:=This:C1470.includedFiles
	
	$object.scheduler.frequency:=This:C1470.schedulerFrequency
	$object.scheduler.hourly:=This:C1470.schedulerHourly
	$object.scheduler.daily:=This:C1470.schedulerDaily
	$object.scheduler.weekly:=This:C1470.schedulerWeekly
	$object.scheduler.monthly:=This:C1470.schedulerMonthly
	
	
Function fomObject()->$object : Object
	
	Case of 
		: ($object.version="1.0")
			This:C1470.tryBackupAtTheNextScheduledDate:=$object.advanced.backupFailure.tryBackupAtTheNextScheduledDate
			This:C1470.tryToBackupAfter:=Time:C179($object.advanced.backupFailure.tryToBackupAfter)
			This:C1470.abortIfBackupFail:=$object.advanced.backupFailure.abortIfBackupFail
			This:C1470.retryCountBeforeAbort:=$object.advanced.backupFailure.retryCountBeforeAbort
			This:C1470.automaticRestore:=$object.advanced.automaticRestore
			This:C1470.automaticLogIntegration:=$object.advanced.automaticLogIntegration
			This:C1470.automaticRestart:=$object.advanced.automaticRestart
			This:C1470.backupIfDataChange:=$object.advanced.backupIfDataChange
			This:C1470.setNumberEnabled:=$object.advanced.setNumberEnabled
			This:C1470.setNumberValue:=$object.advanced.setNumberValue
			This:C1470.compressionRate:=$object.advanced.compressionRate
			This:C1470.redundancy:=$object.advanced.redundancy
			This:C1470.interlacing:=$object.advanced.interlacing
			This:C1470.automaticLogIntegrationStrictness:=$object.advanced.automaticLogIntegrationStrictness
			This:C1470.fileSegmentationDefaultSize:=$object.advanced.fileSegmentationDefaultSize
			This:C1470.eraseOldBackupBefore:=$object.advanced.eraseOldBackupBefore
			This:C1470.checkArchiveFileDuringBackup:=$object.advanced.checkArchiveFileDuringBackup
			This:C1470.backupJournalVerboseMode:=$object.advanced.backupJournalVerboseMode
			
			This:C1470.includeStructureFile:=$object.general.includeStructureFile
			This:C1470.includeDataFile:=$object.general.includeDataFile
			This:C1470.includeAltStructFile:=$object.general.includeAltStructFile
			This:C1470.destinationFolder:=Folder:C1567($object.general.destinationFolder)
			This:C1470.includedFiles:=$object.general.includedFiles
			
			This:C1470.schedulerFrequency:=$object.scheduler.frequency
			This:C1470.schedulerHourly:=$object.scheduler.hourly
			This:C1470.schedulerDaily:=$object.scheduler.daily
			This:C1470.schedulerWeekly:=$object.scheduler.weekly
			This:C1470.schedulerMonthly:=$object.scheduler.monthly
			
	End case 
	
	//MARK:- getter/setters
	
Function get backupJournalVerboseMode()->$backupJournalVerboseMode : Boolean
	$backupJournalVerboseMode:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupJournalVerboseMode[1]")="True")
	
Function set backupJournalVerboseMode($backupJournalVerboseMode : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupJournalVerboseMode[1]"; $backupJournalVerboseMode)
	
Function get checkArchiveFileDuringBackup()->$checkArchiveFileDuringBackup : Boolean
	$checkArchiveFileDuringBackup:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/CheckArchiveFileDuringBackup[1]")="True")
	
Function set checkArchiveFileDuringBackup($checkArchiveFileDuringBackup : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/CheckArchiveFileDuringBackup[1]"; $checkArchiveFileDuringBackup)
	
Function get eraseOldBackupBefore()->$eraseOldBackupBefore : Boolean
	$eraseOldBackupBefore:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/EraseOldBackupBefore[1]")="True")
	
Function set eraseOldBackupBefore($eraseOldBackupBefore : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/EraseOldBackupBefore[1]"; $eraseOldBackupBefore)
	
Function get automaticRestore()->$automaticRestore : Boolean
	$automaticRestore:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/AutomaticRestore[1]")="True")
	
Function set automaticRestore($automaticRestore : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/AutomaticRestore[1]"; $automaticRestore)
	
Function get automaticLogIntegration()->$automaticLogIntegration : Boolean
	$automaticLogIntegration:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/AutomaticRestore[1]")="True")
	
Function set automaticLogIntegration($automaticLogIntegration : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/AutomaticRestore[1]"; $automaticLogIntegration)
	
Function get automaticRestart()->$automaticRestart : Boolean
	$automaticRestart:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/AutomaticRestart[1]")="True")
	
Function set automaticRestart($automaticRestart : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/AutomaticRestart[1]"; $automaticRestart)
	
Function get backupIfDataChange()->$backupIfDataChange : Boolean
	$backupIfDataChange:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupIfDataChange[1]")="True")
	
Function set backupIfDataChange($backupIfDataChange : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupIfDataChange[1]"; $backupIfDataChange)
	
Function get compressionRate()->$compressionRate : Text
	$compressionRate:=This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/CompressionRate[1]")
	
Function set compressionRate($compressionRate : Text)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/CompressionRate[1]"; $compressionRate)
	
Function get redundancy()->$redundancy : Text
	$redundancy:=This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/Redundancy[1]")
	
Function set redundancy($redundancy : Text)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/Redundancy[1]"; $redundancy)
	
Function get interlacing()->$interlacing : Text
	$interlacing:=This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/Interlacing[1]")
	
Function set interlacing($interlacing : Text)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/Interlacing[1]"; $interlacing)
	
Function get automaticLogIntegrationStrictness()->$automaticLogIntegrationStrictne : Text
	$automaticLogIntegrationStrictne:=This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/AutomaticLogIntegrationStrictness[1]")
	
Function set automaticLogIntegrationStrictness($automaticLogIntegrationStrictne : Text)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/AutomaticLogIntegrationStrictness[1]"; $automaticLogIntegrationStrictne)
	
Function get tryBackupAtTheNextScheduledDate()->$tryBackupAtTheNextScheduledDate : Boolean
	$tryBackupAtTheNextScheduledDate:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupFailure[1]/TryBackupAtTheNextScheduledDate[1]")="True")
	
Function set tryBackupAtTheNextScheduledDate($tryBackupAtTheNextScheduledDate : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupFailure[1]/TryBackupAtTheNextScheduledDate[1]"; $tryBackupAtTheNextScheduledDate)
	
Function get abortIfBackupFail()->$abortIfBackupFail : Boolean
	$abortIfBackupFail:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupFailure[1]/AbortIfBackupFail[1]")="True")
	
Function set abortIfBackupFail($abortIfBackupFail : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupFailure[1]/AbortIfBackupFail[1]"; $abortIfBackupFail)
	
Function get retryCountBeforeAbort()->$retryCountBeforeAbort : Integer
	$retryCountBeforeAbort:=Num:C11(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupFailure[1]/RetryCountBeforeAbort[1]"))
	
Function set retryCountBeforeAbort($retryCountBeforeAbort : Integer)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupFailure[1]/RetryCountBeforeAbort[1]"; $retryCountBeforeAbort)
	
Function get tryToBackupAfter()->$tryToBackupAfter : Time
	$tryToBackupAfter:=Time:C179(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupFailure[1]/TryToBackupAfter[1]"))
	
Function set tryToBackupAfter($tryToBackupAfter : Time)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/BackupFailure[1]/TryToBackupAfter[1]"; Time string:C180($tryToBackupAfter))
	
Function get setNumberEnabled()->$setNumberEnabled : Boolean
	$setNumberEnabled:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/SetNumber[1]/Enable[1]")="True")
	
Function set setNumberEnabled($setNumberEnabled : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/SetNumber[1]/Enable[1]"; $setNumberEnabled)
	
Function get setNumberValue()->$setNumberValue : Integer
	$setNumberValue:=Num:C11(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/SetNumber[1]/Value[1]"))
	
Function set setNumberValue($setNumberValue : Integer)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/SetNumber[1]/Value[1]"; $setNumberValue)
	
Function get fileSegmentationDefaultSize()->$fileSegmentationDefaultSize : Integer
	$fileSegmentationDefaultSize:=Num:C11(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/FileSegmentation[1]/DefaultSize[1]"))
	
Function set fileSegmentationDefaultSize($fileSegmentationDefaultSize : Integer)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Advanced[1]/FileSegmentation[1]/DefaultSize[1]"; $fileSegmentationDefaultSize)
	
Function get includeStructureFile()->$includeStructureFile : Boolean
	$includeStructureFile:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludeStructureFile[1]")="True")
	
Function set includeStructureFile($includeStructureFile : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludeStructureFile[1]"; $includeStructureFile)
	
Function get includeDataFile()->$includeDataFile : Boolean
	$includeDataFile:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludeDataFile[1]")="True")
	
Function set includeDataFile($includeDataFile : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludeDataFile[1]"; $includeDataFile)
	
Function get includeAltStructFile()->$includeAltStructFile : Boolean
	$includeAltStructFile:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludeAltStructFile[1]")="True")
	
Function set includeAltStructFile($includeAltStructFile : Boolean)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludeAltStructFile[1]"; $includeAltStructFile)
	
Function get destinationFolder()->$destinationFolder : 4D:C1709.Folder
	var $destinationFolderPath : Text
	$destinationFolderPath:=This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/DestinationFolder[1]")
	$destinationFolder:=Folder:C1567($destinationFolderPath; fk platform path:K87:2)
	
Function set destinationFolder($destinationFolder : 4D:C1709.Folder)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/DestinationFolder[1]"; $destinationFolder.platformPath)
	
Function get includedFiles()->$includedFiles : Collection
	$includedFiles:=[]
	
	var $count; $index : Integer
	$count:=This:C1470._countChildren("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludesFiles[1]")
	For ($index; 1; $count-1)
		$includedFiles.push(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludesFiles[1]/Item"+String:C10($index)+"[1]"))
	End for 
	
Function set includedFiles($includedFiles : Collection)
	
	var $includedFilesFiltered : Collection
	$includedFilesFiltered:=[]
	
	var $platformPath : Text
	var $includedFile : Variant
	For each ($includedFile; $includedFiles)
		Case of 
			: (Value type:C1509($includedFile)=Is text:K8:3)
				Case of 
					: ($includedFile="./")
						$platformPath:=$includedFile
						
					: (($includedFile="@\\") | ($includedFile="@:"))
						$platformPath:=Folder:C1567($includedFile).platformPath
						
					Else 
						$platformPath:=File:C1566($includedFile).platformPath
				End case 
				$includedFilesFiltered.push($platformPath)
				
			: (Value type:C1509($includedFile)=Is object:K8:27)
				If (OB Instance of:C1731($includedFile; 4D:C1709.File) || OB Instance of:C1731($includedFile; 4D:C1709.Folder))
					$platformPath:=$includedFile.platformPath
					$includedFilesFiltered.push($platformPath)
				End if 
				
		End case 
		
	End for each 
	
	This:C1470._removeElement("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludesFiles[1]")
	
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludesFiles[1]/ItemsCount[1]"; $includedFilesFiltered.length)
	
	var $index : Integer
	$index:=0
	
	var $includedFileValue : Text
	For each ($includedFileValue; $includedFilesFiltered)
		$index+=1
		This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/General[1]/IncludesFiles[1]/Item"+String:C10($index)+"[1]"; $includedFileValue)
	End for each 
/*
  <IncludesFiles>
    <ItemsCount>2</ItemsCount>
    <Item1>Macintosh HD:Users:ble:Documents:sample.txt</Item1>
    <Item2>./WebFolder/</Item2>
  </IncludesFiles>
*/
	
Function get schedulerHourly()->$schedulerHourly : Object
	$schedulerHourly:={every: 1; startingAt: "00:00:00"}
	
	$schedulerHourly.every:=Num:C11(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Hourly[1]/Every[1]"))
	$schedulerHourly.startingAt:=Time string:C180(Time:C179(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Hourly[1]/StartingAt[1]")))
	
Function set schedulerHourly($schedulerHourly : Object)
	
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Hourly[1]/Every[1]"; $schedulerHourly.every)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Hourly[1]/StartingAt[1]"; Time:C179($schedulerHourly.startingAt))
	
Function get schedulerDaily()->$schedulerDaily : Object
	$schedulerDaily:={every: 1; hour: "00:00:00"}
	
	$schedulerDaily.every:=Num:C11(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Daily[1]/Every[1]"))
	$schedulerDaily.hour:=Time string:C180(Time:C179(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Daily[1]/Hour[1]")))
	
Function set schedulerDaily($schedulerDaily : Object)
	
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Daily[1]/Every[1]"; $schedulerDaily.every)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Daily[1]/Hour[1]"; Time:C179($schedulerDaily.hour))
	
Function get schedulerWeekly()->$schedulerWeekly : Object
	$schedulerWeekly:={every: 1; \
		monday: {save: False:C215; hour: "00:00:00"}; \
		tuesday: {save: False:C215; hour: "00:00:00"}; \
		wednesday: {save: False:C215; hour: "00:00:00"}; \
		thursday: {save: False:C215; hour: "00:00:00"}; \
		friday: {save: False:C215; hour: "00:00:00"}; \
		saturday: {save: False:C215; hour: "00:00:00"}; \
		sunday: {save: False:C215; hour: "00:00:00"}\
		}
	
	$schedulerWeekly.every:=Num:C11(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Weekly[1]/Every[1]"))
	
	var $dayList : Collection
	$dayList:=["Monday"; "Tuesday"; "Wednesday"; "Thursday"; "Friday"; "Saturday"; "Sunday"]
	
	var $dayStr; $dayStrLower : Text
	For each ($dayStr; $dayList)
		$dayStrLower:=Lowercase:C14($dayStr)
		$schedulerWeekly[$dayStrLower].save:=(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Weekly[1]/"+$dayStr+"[1]/Save[1]")="True")
		$schedulerWeekly[$dayStrLower].hour:=Time string:C180(Time:C179(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Weekly[1]/"+$dayStr+"[1]/Hour[1]")))
	End for each 
	
Function set schedulerWeekly()->$schedulerWeekly : Object
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Weekly[1]/Every[1]"; $schedulerWeekly.every)
	
	var $dayList : Collection
	$dayList:=["Monday"; "Tuesday"; "Wednesday"; "Thursday"; "Friday"; "Saturday"; "Sunday"]
	
	var $dayStr; $dayStrLower : Text
	For each ($dayStr; $dayList)
		$dayStrLower:=Lowercase:C14($dayStr)
		This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Weekly[1]/"+$dayStr+"[1]/Save[1]"; $schedulerWeekly[$dayStrLower].save)
		This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Weekly[1]/"+$dayStr+"[1]/Hour[1]"; Time:C179($schedulerWeekly[$dayStrLower].hour))
	End for each 
	
Function get schedulerMonthly()->$schedulerMonthly : Object
	$schedulerMonthly:={every: 1; hour: "00:00:00"; day: 1}
	
	$schedulerMonthly.every:=Num:C11(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Monthly[1]/Every[1]"))
	$schedulerMonthly.hour:=Time string:C180(Time:C179(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Monthly[1]/Hour[1]")))
	$schedulerMonthly.day:=Num:C11(This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Monthly[1]/Day[1]"))
	
Function set schedulerMonthly($schedulerMonthly : Object)
	
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Monthly[1]/Every[1]"; $schedulerMonthly.every)
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Monthly[1]/Hour[1]"; Time:C179($schedulerMonthly.hour))
	This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Monthly[1]/Day[1]"; $schedulerMonthly.day)
	
Function get schedulerFrequency()->$frequency : Text
	$frequency:=This:C1470._getElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Frequency[1]")
	
Function set schedulerFrequency($frequency : Text)
	// "" never
	// "Hourly"
	// "Daily"
	// "Weekly"
	// "Monthly"
	var $allowedValues : Collection
	$allowedValues:=[""; "Hourly"; "Daily"; "Weekly"; "Monthly"]
	var $indexOf : Integer
	$indexOf:=$allowedValues.indexOf($frequency)
	If ($indexOf#-1)
		$frequency:=$allowedValues[$indexOf]
		This:C1470._setElementValue("/Preferences4D/Backup[1]/Settings[1]/Scheduler[1]/Frequency[1]"; $frequency)
	End if 
	
Function get loaded()->$loaded : Boolean
	$loaded:=(This:C1470._domRootRef#"")
	
	//MARK:- Private Functions
	
Function _removeElement($xpath : Text)
	
	var $domRef : Text
	$domRef:=DOM Find XML element:C864(This:C1470._domRootRef; $xpath)
	If ((ok=1) && This:C1470._domRefIsValid($domRef))
		DOM REMOVE XML ELEMENT:C869($domRef)
	End if 
	
Function _countChildren($xpath : Text)->$childrenCount : Integer
	
	var $domRef : Text
	$domRef:=DOM Find XML element:C864(This:C1470._domRootRef; $xpath)
	If ((ok=1) && This:C1470._domRefIsValid($domRef))
		
		ARRAY TEXT:C222($tl_type; 0)
		ARRAY TEXT:C222($tt_nodeRef; 0)
		
		DOM GET XML CHILD NODES:C1081($domRef; $tl_type; $tt_nodeRef)
		
		$childrenCount:=Count in array:C907($tl_type; XML ELEMENT:K45:20)
		
		ARRAY TEXT:C222($tl_type; 0)
		ARRAY TEXT:C222($tt_nodeRef; 0)
		
	End if 
	
Function _getElementValue($xpath : Text)->$elementValue : Text
	
	If (This:C1470._possible && This:C1470.loaded)
		
		//"/Preferences4D/Backup/DataBase/DatabaseName/Item1"
		
		var $domRef : Text
		$domRef:=DOM Find XML element:C864(This:C1470._domRootRef; $xpath)
		If ((ok=1) && This:C1470._domRefIsValid($domRef))
			var $elementValueCDATA : Text
			DOM GET XML ELEMENT VALUE:C731($domRef; $elementValue; $elementValueCDATA)
			
			This:C1470._log("element \""+$xpath+"\" read element value : \""+$elementValue+"\""; "info")
		Else 
			This:C1470._log("element \""+$xpath+"\" not found"; "info")
		End if 
		
	End if 
	
Function _setElementValue($xpath : Text; $elementValue : Variant)
	
	If (This:C1470._possible && This:C1470.loaded)
		
		//"/Preferences4D/Backup/DataBase/DatabaseName/Item1"
		
		var $needUpdate : Boolean
		
		var $valueType : Integer
		$valueType:=Value type:C1509($elementValue)
		Case of 
			: ($valueType=Is boolean:K8:9)
				$valueNew:=$elementValue ? "True" : "False"
				
			: ($valueType=Is text:K8:3)
				$valueNew:=$elementValue
				
			: ($valueType=Is time:K8:8)
				$valueNew:=String:C10($elementValue; ISO time:K7:8)
				// ?21:00:00? => "0000-00-00T21:00:00"
				
			: ($valueType=Is real:K8:4)
				$valueNew:=String:C10($elementValue; "&xml")
				
			Else 
				$valueNew:=String:C10($elementValue)
		End case 
		
		var $domRef : Text
		$domRef:=DOM Find XML element:C864(This:C1470._domRootRef; $xpath)
		// if not found, ok=0 and $domRef = "00000000000000000000000000000000"
		If (ok=1)
			var $valueNew; $valueOld : Text
			
			$valueOld:=This:C1470._readValue($domRef)
			
			$needUpdate:=(Compare strings:C1756($valueOld; $valueNew; sk char codes:K86:5)#0)
			
			If ($needUpdate)
				This:C1470._log("element \""+$xpath+"\" old value : \""+$valueOld+"\", new value : \""+$valueNew+"\""; "info")
			End if 
			
		Else 
			//If (Not(This._domRefIsValid($domRef)))
			$needUpdate:=True:C214
			$domRef:=DOM Create XML element:C865(This:C1470._domRootRef; $xpath)
			This:C1470._log("create element \""+$xpath+"\""; "info")
			//End if 
		End if 
		
		If ($needUpdate)
			This:C1470._modified:=True:C214
			
			DOM SET XML ELEMENT VALUE:C868($domRef; $valueNew)
			
			This:C1470._log("element \""+$xpath+"\" write value : \""+String:C10($valueNew)+"\""; "info")
		Else 
			This:C1470._log("element \""+$xpath+"\" value : \""+String:C10($valueNew)+"\" already set"; "info")
		End if 
	End if 
	
Function _readValue($domRef : Text)->$elementValue : Text
	var $elementValueCDATA : Text
	DOM GET XML ELEMENT VALUE:C731($domRef; $elementValue; $elementValueCDATA)
	
Function _domRefIsValid($domRef : Text)->$isValid : Boolean
	$isValid:=($domRef#"") && ($domRef#"00000000000000000000000000000000")
	
Function _log($message : Text; $level : Text)
	//This._logger.log("backupSettings"; $message; $level)