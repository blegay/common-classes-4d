
property options : Object
property _encoding : Text
property _standalone : Boolean
property _isOpen : Boolean
//property _rootDomRef : Text

Class constructor()
	
	This:C1470._encoding:="UTF-8"
	This:C1470._standalone:=True:C214
	
	This:C1470._isOpen:=False:C215
	
	// https://doc.4d.com/4Dv20/4D/20.5/XML-SET-OPTIONS.301-7389189.fe.html
	This:C1470.options:=New object:C1471
	// writer options
	This:C1470.options.indentation:=XML with indentation:K45:35
	This:C1470.options.binaryEncoding:=XML base64:K45:38
	This:C1470.options.dateEncoding:=XML ISO:K45:25
	This:C1470.options.timeEncoding:=XML datetime local absolute:K45:31
	This:C1470.options.stringEncoding:=XML with escaping:K45:22
	This:C1470.options.pictureEncoding:=XML convert to PNG:K45:41
	
	// parser options
	This:C1470.options.caseSensitivity:=XML case sensitive:K45:47
	This:C1470.options.externalEntityResolution:=XML disabled:K45:45
	
	// new (4D v19 R3 ?) writer options
	// v20+ features (4D v19 R3 ?), do not use 4D default values, 
	This:C1470.options.bom:=XML enabled:K45:44
	This:C1470.options.lineEnding:=XML LF:K45:52
	
	
	// MARK:- create/parse/save/close functions
Function create($rootElementName : Text; $rootAttributes : Object)->$result : Object
	$result:=New object:C1471
	
	Case of 
		: ((This:C1470._encoding="UTF-8") | (This:C1470._encoding="UTF-16") | (This:C1470._encoding="UCS4"))
		: ((This:C1470._encoding="ASCII") | (This:C1470._encoding="ISO-8859-1") | (This:C1470._encoding="Windows-1252"))
			//This.options.bom:=XML disabled
			
		Else 
			This:C1470._encoding:="UTF-8"
	End case 
	
	//var $tmp : Text
	//$tmp:=DOM Create XML Ref("a")
	//If (ok=1)
	//DOM SET XML DECLARATION($tmp; This._encoding; This._standalone)
	//XML SET OPTIONS($tmp; XML indentation; This.options.indentation)
	
	//DOM CLOSE XML
	//End if 
	
	This:C1470.close()  // if we had one opened xml dom, close it (and free memory)
	
	This:C1470._rootDomRef:=DOM Create XML Ref:C861($rootElementName)
	$result.success:=(ok=1)
	
	If ($result.success)
		This:C1470._isOpen:=True:C214
		
		DOM SET XML DECLARATION:C859(This:C1470._rootDomRef; This:C1470._encoding; This:C1470._standalone)
		
		This:C1470._optionsApply()
	End if 
	
	If ($result.success & (Count parameters:C259>1))
		var $attrName : Text
		var $attrValue : Variant
		For each ($attrName; $rootAttributes)
			$attrValue:=$rootAttributes[$attrName]
			DOM SET XML ATTRIBUTE:C866(This:C1470._rootDomRef; $attrName; $attrValue)
		End for each 
	End if 
	
Function parse($xmlParam : Variant; $validateParam : Boolean; $schemaParam : 4D:C1709.File)->$result : Object
	$result:=New object:C1471
	$result.success:=False:C215
	$result.error:=""
	$result.errorDetail:=Null:C1517
	
	var $validate : Boolean
	var $schemaPath : Text
	Case of 
		: (Count parameters:C259>2)
			$validate:=$validateParam
			If ($validate)
				$schemaPath:=$schemaParam.platformPath
			End if 
			
		: (Count parameters:C259>1)
			$validate:=$validateParam
	End case 
	
	This:C1470.close()  // if we had one opened xml dom, close it (and free memory)
	
	Try
		
		Case of 
			: ((Value type:C1509($xmlParam)=Is text:K8:3) | (Value type:C1509($xmlParam)=Is BLOB:K8:12))
				This:C1470._rootDomRef:=DOM Parse XML variable:C720($xmlParam; $validate; $schemaPath)
				$result.success:=(ok=1)
				
			: ((Value type:C1509($xmlParam)=Is object:K8:27) & (OB Instance of:C1731($xmlParam; 4D:C1709.File)))
				This:C1470._rootDomRef:=DOM Parse XML source:C719($xmlParam.platformPath; $validate; $schemaPath)
				$result.success:=(ok=1)
				
			Else 
				$result.error:="invalid type"
		End case 
		
	Catch
		$result.error:="parsing error"
		$result.errorDetail:=Last errors:C1799
	End try
	
	If ($result.success)
		This:C1470._isOpen:=True:C214
		
		This:C1470._encoding:=DOM Get XML information:C721(This:C1470._rootDomRef; Encoding:K45:4)
		//This._standalone:=???
		
		If (Not:C34((This:C1470._encoding="UTF-8") | (This:C1470._encoding="UTF-16") | (This:C1470._encoding="UCS4")))
			This:C1470.options.bom:=XML disabled:K45:45
		End if 
		
		This:C1470._optionsApply()
	Else 
		// TODO: debug
	End if 
	
Function save($xmlFile : 4D:C1709.File)->$result : Object
	$result:=New object:C1471
	$result.success:=False:C215
	$result.errors:=Null:C1517
	If ($xmlFile#Null:C1517)
		Try
			
			DOM EXPORT TO FILE:C862(This:C1470._rootDomRef; $xmlFile.platformPath)
			$result.success:=(ok=1)
			
			//If (Not($xmlFile.exists))
			//$xmlFile.create()
			//End if 
			//var $blob : Blob
			//$blob:=This.toBlob()
			//$xmlFile.setContent($blob)
			//SET BLOB SIZE($blob; 0)
			
		Catch
			$result.errors:=Last errors:C1799
		End try
	End if 
	
Function close()
	If (This:C1470._isOpen)
		DOM CLOSE XML:C722(This:C1470._rootDomRef)
		This:C1470._rootDomRef:=Null:C1517
		This:C1470._isOpen:=False:C215
	End if 
	
Function get isOpen->$isOpen : Boolean
	$isOpen:=This:C1470._isOpen
	
	
	//MARK:- option functions
	
Function set encoding($encoding : Text)
	// use before calling .create()
	If (Not:C34(This:C1470._isOpen))
		If ($encoding#"")
			This:C1470._encoding:=$encoding
		End if 
	End if 
	
Function get encoding->$encoding : Text
	$encoding:=This:C1470._encoding
	
Function set standalone($standalone : Boolean)
	// use before calling .create()
	If (Not:C34(This:C1470._isOpen))
		This:C1470._standalone:=$standalone
	End if 
	
Function get standalone->$standalone : Boolean
	$standalone:=This:C1470._standalone
	
Function optionDebug($optionsParam : Object)->$optionsDebug : Object
	
	var $options : Object
	If (Count parameters:C259>0)
		$options:=$optionsParam
	Else 
		$options:=This:C1470.options
	End if 
	
	$optionsDebug:=New object:C1471
	
	// indentation
	Case of 
		: ($options.indentation=Null:C1517)
		: ($options.indentation=XML with indentation:K45:35)
			$optionsDebug.indentation:="XML with indentation"
			
		: ($options.indentation=XML no indentation:K45:36)
			$optionsDebug.indentation:="XML no indentation"
	End case 
	
	// binaryEncoding
	Case of 
		: ($options.binaryEncoding=Null:C1517)
		: ($options.binaryEncoding=XML base64:K45:38)
			$optionsDebug.binaryEncoding:="XML base64"
			
		: ($options.binaryEncoding=XML data URI scheme:K45:39)
			$optionsDebug.binaryEncoding:="XML data URI scheme"
	End case 
	
	// dateEncoding
	Case of 
		: ($options.dateEncoding=Null:C1517)
		: ($options.dateEncoding=XML ISO:K45:25)
			$optionsDebug.dateEncoding:="XML ISO"
			
		: ($options.dateEncoding=XML local:K45:26)
			$optionsDebug.dateEncoding:="XML local"
			
		: ($options.dateEncoding=XML datetime local:K45:27)
			$optionsDebug.dateEncoding:="XML datetime local"
			
		: ($options.dateEncoding=XML UTC:K45:28)
			$optionsDebug.dateEncoding:="XML UTC"
			
		: ($options.dateEncoding=XML datetime UTC:K45:29)
			$optionsDebug.dateEncoding:="XML datetime UTC"
			
	End case 
	
	// timeEncoding
	Case of 
		: ($options.timeEncoding=Null:C1517)
		: ($options.timeEncoding=XML datetime UTC:K45:29)
			$optionsDebug.timeEncoding:="XML datetime UTC"
			
		: ($options.timeEncoding=XML datetime local:K45:27)
			$optionsDebug.timeEncoding:="XML datetime local"
			
		: ($options.timeEncoding=XML datetime local absolute:K45:31)
			$optionsDebug.timeEncoding:="XML datetime local absolute"
			
		: ($options.timeEncoding=XML seconds:K45:32)
			$optionsDebug.timeEncoding:="XML seconds"
			
		: ($options.timeEncoding=XML duration:K45:33)
			$optionsDebug.timeEncoding:="XML duration"
			
	End case 
	
	// stringEncoding
	Case of 
		: ($options.stringEncoding=Null:C1517)
		: ($options.stringEncoding=XML with escaping:K45:22)
			$optionsDebug.stringEncoding:="XML with escaping"
			
		: ($options.stringEncoding=XML raw data:K45:23)
			$optionsDebug.stringEncoding:="XML raw data"
	End case 
	
	// pictureEncoding
	Case of 
		: ($options.pictureEncoding=Null:C1517)
		: ($options.pictureEncoding=XML convert to PNG:K45:41)
			$optionsDebug.pictureEncoding:="XML convert to PNG"
			
		: ($options.pictureEncoding=XML native codec:K45:42)
			$optionsDebug.pictureEncoding:="XML native codec"
	End case 
	
	// caseSensitivity
	Case of 
		: ($options.caseSensitivity=Null:C1517)
		: ($options.caseSensitivity=XML case sensitive:K45:47)
			$optionsDebug.caseSensitivity:="XML case sensitive"
			
		: ($options.caseSensitivity=XML case insensitive:K45:48)
			$optionsDebug.caseSensitivity:="XML case insensitive"
	End case 
	
	// externalEntityResolution
	Case of 
		: ($options.externalEntityResolution=Null:C1517)
		: ($options.externalEntityResolution=XML enabled:K45:44)
			$optionsDebug.externalEntityResolution:="XML enabled"
			
		: ($options.externalEntityResolution=XML disabled:K45:45)
			$optionsDebug.externalEntityResolution:="XML disabled"
	End case 
	
	// bom
	Case of 
		: ($options.bom=Null:C1517)
		: ($options.bom=XML default:K45:49)
			$optionsDebug.bom:="XML default"
			
		: ($options.bom=XML enabled:K45:44)
			$optionsDebug.bom:="XML enabled"
			
		: ($options.bom=XML disabled:K45:45)
			$optionsDebug.bom:="XML disabled"
	End case 
	
	// lineEnding
	Case of 
		: ($options.lineEnding=Null:C1517)
		: ($options.lineEnding=XML default:K45:49)
			$optionsDebug.lineEnding:="XML default"
			
		: ($options.lineEnding=XML LF:K45:52)
			$optionsDebug.lineEnding:="XML LF"
			
		: ($options.lineEnding=XML CR:K45:54)
			$optionsDebug.lineEnding:="XML CR"
			
		: ($options.lineEnding=XML CRLF:K45:53)
			$optionsDebug.lineEnding:="XML CRLF"
	End case 
	
	
	//MARK:- root functions
	
Function get rootDomRef->$rootDomRef : Text
	If (This:C1470._isOpen)
		$rootDomRef:=This:C1470._rootDomRef
	End if 
	
Function get rootDomElement->$rootDomElement : cs:C1710.domXmlElement
	If (This:C1470._isOpen)
		$rootDomElement:=cs:C1710.domXmlElement.new(This:C1470._rootDomRef)
	End if 
	
	
	//MARK:- export functions
	
Function toText()->$xml : Text
	$xml:=""
	If (This:C1470._isOpen)
		DOM EXPORT TO VAR:C863(This:C1470._rootDomRef; $xml)
	End if 
	
Function toBlob()->$xmlBlob : Blob
	SET BLOB SIZE:C606($xmlBlob; 0)
	If (This:C1470._isOpen)
		DOM EXPORT TO VAR:C863(This:C1470._rootDomRef; $xmlBlob)
	End if 
	
	
	//MARK:- misc functions
	
Function get infos()->$infos : Object
	If (This:C1470._isOpen)
		$infos:=New object:C1471
		$infos.publicID:=DOM Get XML information:C721(This:C1470._rootDomRef; PUBLIC ID:K45:1)  //1 
		$infos.systemID:=DOM Get XML information:C721(This:C1470._rootDomRef; SYSTEM ID:K45:2)  //2
		$infos.doctypeName:=DOM Get XML information:C721(This:C1470._rootDomRef; DOCTYPE Name:K45:3)  //3
		$infos.encoding:=DOM Get XML information:C721(This:C1470._rootDomRef; Encoding:K45:4)  //4
		$infos.version:=DOM Get XML information:C721(This:C1470._rootDomRef; Version:K45:5)  //5
		$infos.documentUri:=DOM Get XML information:C721(This:C1470._rootDomRef; Document URI:K45:6)  //6
	End if 
	
	
	//MARK:- find/search functions
	
Function findElement($xpath : Text)->$domElement : cs:C1710.domXmlElement
	
	var $rootDomElement : cs:C1710.domXmlElement
	$rootDomElement:=This:C1470.rootDomElement
	If ($rootDomElement#Null:C1517)
		$domElement:=$rootDomElement.findElement($xpath)
	End if 
	
Function findElements($xpath : Text)->$domElementColl : Collection
	
	var $rootDomElement : cs:C1710.domXmlElement
	$rootDomElement:=This:C1470.rootDomElement
	If ($rootDomElement#Null:C1517)
		$domElementColl:=$rootDomElement.findElements($xpath)
	End if 
	
	
	//MARK:- private functions
	
Function _optionsApply()
	If (This:C1470._isOpen)
		XML SET OPTIONS:C1090(This:C1470._rootDomRef; XML binary encoding:K45:37; This:C1470.options.binaryEncoding)
		XML SET OPTIONS:C1090(This:C1470._rootDomRef; XML date encoding:K45:24; This:C1470.options.dateEncoding)
		XML SET OPTIONS:C1090(This:C1470._rootDomRef; XML indentation:K45:34; This:C1470.options.indentation)
		XML SET OPTIONS:C1090(This:C1470._rootDomRef; XML picture encoding:K45:40; This:C1470.options.pictureEncoding)
		XML SET OPTIONS:C1090(This:C1470._rootDomRef; XML String encoding:K45:21; This:C1470.options.stringEncoding)
		XML SET OPTIONS:C1090(This:C1470._rootDomRef; XML time encoding:K45:30; This:C1470.options.timeEncoding)
		
		XML SET OPTIONS:C1090(This:C1470._rootDomRef; XML DOM case sensitivity:K45:46; This:C1470.options.caseSensitivity)
		XML SET OPTIONS:C1090(This:C1470._rootDomRef; XML external entity resolution:K45:43; This:C1470.options.externalEntityResolution)
		
		XML SET OPTIONS:C1090(This:C1470._rootDomRef; XML BOM:K45:50; This:C1470.options.bom)
		XML SET OPTIONS:C1090(This:C1470._rootDomRef; XML line ending:K45:51; This:C1470.options.lineEnding)
	End if 