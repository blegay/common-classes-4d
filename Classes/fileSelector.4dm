// Class fileSelector
// displays a file/folder selector dialog
// wrapper on "Select document" command 
// using 4D.File and 4D.Folder objects
// Bruno LEGAY - 2025-11-29

/*
// short style 
var $selectorOptions : Object
$selectorOptions:={\
folder: Folder(fk desktop folder); \
title: "select your files"; \
extensionFilter: [".jpg"; ".png"; ".tif"]; \
multipleFiles: True; \
useSheetWindow: True}

var $result : Object
$result:=cs.fileSelector.new($selectorOptions).selectDialog()
If ($result.success && ($result.fileList.length>0))

var $file : 4D.File
$file:=$result.fileList[0]

End if 


// long style
var $selector : cs.fileSelector
$selector:=cs.fileSelector.new()

$selector.folder:=Folder(fk desktop folder)
$selector.title:="select your file"
$selector.extensionFilter:=[".jpg"; ".png"; ".tif"]

$selector.multipleFiles:=True
//$selector.packageOpen:=False
//$selector.packageSelection:=False
//$selector.aliasSelection:=False
$selector.useSheetWindow:=True
//$selector.fileNameEntry:=False

//$selector.selectFile:=True
$selector.selectFolder:=False

var $result : Object
$result:=$selector.selectDialog()
If ($result.success && ($result.fileList.length>0))

var $file : 4D.File
$file:=$result.fileList[0]

End if 
*/

property folder : 4D:C1709.Folder
property title : Text
property extensionFilter : Collection
property options : Integer

property selectFile : Boolean
property selectFolder : Boolean

property _multipleFilesBit : Integer
property _packageOpenBit : Integer
property _packageSelectionBit : Integer
property _aliasSelectionBit : Integer
property _useSheetWindowBit : Integer
property _fileNameEntryBit : Integer

Class constructor($params : Object)
	
	// class "constants"
	This:C1470._multipleFilesBit:=0
	This:C1470._packageOpenBit:=1
	This:C1470._packageSelectionBit:=2
	This:C1470._aliasSelectionBit:=3
	This:C1470._useSheetWindowBit:=4
	This:C1470._fileNameEntryBit:=5
	
	This:C1470.reset()
	
	If ((Count parameters:C259>0) && ($params#Null:C1517))
		For each ($property; $params)
			This:C1470[$property]:=$params[$property]
		End for each 
	End if 
	
	
	
Function reset()
	This:C1470.folder:=Null:C1517
	This:C1470.title:=""
	This:C1470.extensionFilter:=Null:C1517
	This:C1470.options:=0
	This:C1470.selectFile:=True:C214
	This:C1470.selectFolder:=True:C214
	
Function get multipleFiles()->$multipleFiles : Boolean
	$multipleFiles:=This:C1470._bitGet(This:C1470._multipleFilesBit)
	
Function set multipleFiles($multipleFiles : Boolean)
	$multipleFiles:=This:C1470._bitSet(This:C1470._multipleFilesBit; $multipleFiles)
	
Function get packageOpen()->$packageOpen : Boolean
	$multipleFiles:=This:C1470._bitGet(This:C1470._packageOpenBit)
	
Function set packageOpen($packageOpen : Boolean)
	$multipleFiles:=This:C1470._bitSet(This:C1470._packageOpenBit; $packageOpen)
	
Function get packageSelection()->$packageSelection : Boolean
	$multipleFiles:=This:C1470._bitGet(This:C1470._packageSelectionBit)
	
Function set packageSelection($packageSelection : Boolean)
	$multipleFiles:=This:C1470._bitSet(This:C1470._packageSelectionBit; $packageSelection)
	
Function get aliasSelection()->$aliasSelection : Boolean
	$multipleFiles:=This:C1470._bitGet(This:C1470._aliasSelectionBit)
	
Function set aliasSelection($aliasSelection : Boolean)
	$multipleFiles:=This:C1470._bitSet(This:C1470._aliasSelectionBit; $aliasSelection)
	
Function get useSheetWindow()->$useSheetWindow : Boolean
	$multipleFiles:=This:C1470._bitGet(This:C1470._useSheetWindowBit)
	
Function set useSheetWindow($useSheetWindow : Boolean)
	$multipleFiles:=This:C1470._bitSet(This:C1470._useSheetWindowBit; $useSheetWindow)
	
Function get fileNameEntry()->$fileNameEntry : Boolean
	$multipleFiles:=This:C1470._bitGet(This:C1470._fileNameEntryBit)
	
Function set fileNameEntry($fileNameEntry : Boolean)
	$multipleFiles:=This:C1470._bitSet(This:C1470._fileNameEntryBit; $fileNameEntry)
	
	
Function selectDialog()->$result : Object
	$result:={success: False:C215; fileList: []; folderList: []; errors: []}
	
	If (This:C1470.selectFile)
		$result.fileList:=[]
	End if 
	
	If (This:C1470.selectFolder)
		$result.folderList:=[]
	End if 
	
	var $folderPlatformPath : Text
	If ((This:C1470.folder#Null:C1517) && (This:C1470.folder.exists))
		$folderPlatformPath:=This:C1470.folder.platformPath
	End if 
	
	var $fileTypes : Text
	If (This:C1470.extensionFilter#Null:C1517)
		$fileTypes:=This:C1470.extensionFilter.join(";")
	End if 
	
	ARRAY TEXT:C222($tt_selected; 0)
	
	Try
		
		var $selectedPlatformPath : Text
		$selectedPlatformPath:=Select document:C905($folderPlatformPath; $fileTypes; This:C1470.title; This:C1470.options; $tt_selected)
		If (ok=1)
			$result.success:=True:C214
			
			var $platformPathList : Collection
			$platformPathList:=[]
			ARRAY TO COLLECTION:C1563($platformPathList; $tt_selected)
			
			This:C1470._platformPathListToResult($platformPathList; $result)
			
		End if 
		
	Catch
		$result.errors:=Last errors:C1799
	End try
	
	ARRAY TEXT:C222($tt_selected; 0)
	
	
Function _platformPathListToResult($platformPathList : Collection; $result : Object)
	
	var $platformPath : Text
	For each ($platformPath; $platformPathList)
		
		var $isFile : Boolean
		$isFile:=False:C215
		
		If (This:C1470.selectFile)
			var $selectedFile : 4D:C1709.File
			$selectedFile:=File:C1566($platformPath; fk platform path:K87:2)
			If ($selectedFile.exists)
				$isFile:=True:C214
				$result.fileList.push($selectedFile)
			End if 
		End if 
		
		If (This:C1470.selectFolder && Not:C34($isFile))  // test Not($isFile) for optimization
			var $selectedFolder : 4D:C1709.Folder
			$selectedFolder:=Folder:C1567($platformPath; fk platform path:K87:2)
			If ($selectedFolder.exists)
				$result.folderList.push($selectedFolder)
			End if 
		End if 
		
	End for each 
	
Function _bitGet($bit : Integer)->$bitValue : Boolean
	$bitValue:=This:C1470.options ?? $bit
	
Function _bitSet($bit : Integer; $bitValue : Boolean)
	This:C1470.options:=$bitValue ? This:C1470.options ?+ $bit : This:C1470.options ?- $bit
	
