// Class fileSelector
// displays a file/folder selector dialog
// wrapper on "Select document" command 
// using 4D.File and 4D.Folder objects
// Bruno LEGAY - 2025-11-29

/*

var $selector : cs.fileSelector
$selector:=cs.fileSelector.new({folder: Folder(fk desktop folder); title: "select your files"; multipleFiles:True})

var $resutlt : Object
$resutlt:=$selector.selectDialog()
If ($resutlt.success && ($resutlt.fileList.length>0))

var $file : 4D.File
$file:=$resutlt.fileList[0]

End if 


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

var $resutlt : Object
$resutlt:=$selector.selectDialog()
If ($resutlt.success && ($resutlt.fileList.length>0))

var $file : 4D.File
$file:=$resutlt.fileList[0]

End if 
*/

property folder : 4D:C1709.Folder
property title : Text
property extensionFilter : Collection
property options : Integer

property selectFile : Boolean
property selectFolder : Boolean

Class constructor($params : Object)
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
	// multiple files 1
	$multipleFiles:=This:C1470.options ?? 0
	
Function set multipleFiles($multipleFiles : Boolean)
	// multiple files 1
	If ($multipleFiles)
		This:C1470.options:=This:C1470.options ?+ 0
	Else 
		This:C1470.options:=This:C1470.options ?- 0
	End if 
	
Function get packageOpen()->$packageOpen : Boolean
	// package open 2
	$packageOpen:=This:C1470.options ?? 1
	
Function set packageOpen($packageOpen : Boolean)
	// package open 2
	If ($packageOpen)
		This:C1470.options:=This:C1470.options ?+ 1
	Else 
		This:C1470.options:=This:C1470.options ?- 1
	End if 
	
Function get packageSelection()->$packageSelection : Boolean
	// package selection 4
	$packageSelection:=This:C1470.options ?? 2
	
Function set packageSelection($packageSelection : Boolean)
	// package selection 2
	If ($packageSelection)
		This:C1470.options:=This:C1470.options ?+ 2
	Else 
		This:C1470.options:=This:C1470.options ?- 2
	End if 
	
Function get aliasSelection()->$aliasSelection : Boolean
	// Alias selection 8
	$aliasSelection:=This:C1470.options ?? 3
	
Function set aliasSelection($aliasSelection : Boolean)
	// Alias selection 8
	If ($aliasSelection)
		This:C1470.options:=This:C1470.options ?+ 3
	Else 
		This:C1470.options:=This:C1470.options ?- 3
	End if 
	
Function get useSheetWindow()->$useSheetWindow : Boolean
	// use sheet window 16
	$useSheetWindow:=This:C1470.options ?? 4
	
Function set useSheetWindow($useSheetWindow : Boolean)
	// use sheet window 16
	If ($useSheetWindow)
		This:C1470.options:=This:C1470.options ?+ 4
	Else 
		This:C1470.options:=This:C1470.options ?- 4
	End if 
	
Function get fileNameEntry()->$fileNameEntry : Boolean
	// file name entry 32
	$fileNameEntry:=This:C1470.options ?? 5
	
Function set fileNameEntry($fileNameEntry : Boolean)
	// file name entry 32
	If ($fileNameEntry)
		This:C1470.options:=This:C1470.options ?+ 5
	Else 
		This:C1470.options:=This:C1470.options ?- 5
	End if 
	
	
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
	
	