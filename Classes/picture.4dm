// This class handles pictures
// It does wrap native commands in a class and functions
// It is a 4D v20 class
// dependencies : SVG component
// Bruno LEGAY

// todo :
//  - read/write from pasteboard 
//  - add try/catch blocks

property _picture : Picture
property _width : Integer
property _height : Integer
property _size : Integer
property _type : Text
property _filename : Text

Class constructor($picture : Picture)
	This:C1470.picture:=$picture
	
	
	//MARK:- getter/setter functions
	
Function get picture()->$picture : Picture
	$picture:=This:C1470._picture
	
Function set picture($picture : Picture)
	If ($picture#Null:C1517)
		This:C1470._picture:=$picture
		
		var $width; $height : Integer
		PICTURE PROPERTIES:C457($picture; $width; $height)
		This:C1470._width:=$width
		This:C1470._height:=$height
		//PICTURE PROPERTIES($picture; This._width; This._height) // does not work 4D 4D 20 R7
		
		This:C1470._size:=Picture size:C356($picture)
		This:C1470._type:=This:C1470.getPartType()
		This:C1470._filename:=Get picture file name:C1171($picture)
	Else 
		This:C1470._picture:=This:C1470.getEmptyPicture()
		This:C1470._width:=0
		This:C1470._height:=0
		This:C1470._size:=0
		This:C1470._type:=""
		This:C1470._filename:=""
	End if 
	
Function get width()->$width : Integer
	$width:=This:C1470._width
	
Function get height()->$height : Integer
	$height:=This:C1470._height
	
Function get size()->$size : Integer
	$size:=This:C1470._size
	
Function get filename()->$filename : Text
	$filename:=This:C1470._filename
	
Function set filename($filename : Text)
	If (Not:C34(This:C1470.isEmpty()))
		var $picture : Picture
		$picture:=This:C1470.picture
		SET PICTURE FILE NAME:C1172($picture; $filename)
		This:C1470.picture:=$picture
	End if 
	
Function get keywords()->$keywords : Collection
	$keywords:=[]
	If (Not:C34(This:C1470.isEmpty()))
		ARRAY TEXT:C222($tt_keywords; 0)
		GET PICTURE KEYWORDS:C1142(This:C1470.picture; $tt_keywords)  //; *)
		ARRAY TO COLLECTION:C1563($keywords; $tt_keywords)
		ARRAY TEXT:C222($tt_keywords; 0)
	End if 
	
Function set keywords($keywords : Collection)
	
	If (Not:C34(This:C1470.isEmpty()) && ($keywords#Null:C1517))
		ARRAY TEXT:C222($tt_keywords; 0)
		COLLECTION TO ARRAY:C1562($keywords; $tt_keywords)
		SET PICTURE METADATA:C1121(This:C1470.picture; IPTC keywords:K68:118; $tt_keywords)
		ARRAY TEXT:C222($tt_keywords; 0)
	End if 
	
Function get type()->$type : Text
	$type:=This:C1470.typeToExtension(This:C1470._type)
	
Function get extension()->$extension : Text
	$extension:=This:C1470.typeToExtension(This:C1470._type)
	
Function get mime()->$mime : Text
	$mime:=This:C1470.typeToMime(This:C1470._type)
	
Function get infos()->$infos : Object
	$infos:={\
		width: This:C1470.width; \
		height: This:C1470.height; \
		size: This:C1470.size; \
		filename: This:C1470._filename; \
		type: This:C1470._type; \
		isEmpty: This:C1470.isEmpty()\
		}
	
	
	//MARK:- basic functions
	
Function clear()
	This:C1470.picture:=Null:C1517
	
Function isEmpty()->$isEmpty : Boolean
	//var $width;$height:Integer
	//PICTURE PROPERTIES(This._picture;$width;$height)
	$isEmpty:=This:C1470._size=0  //Picture size(This.picture)=0
	
Function getEmptyPicture()->$emptyPicture : Picture
	// volontarily left empty
	
	
	//MARK:- file functions
	
Function isPictureFile($file : 4D:C1709.File)->$isPictureFile : Boolean
	ASSERT:C1129($file#Null:C1517)
	
	$isPictureFile:=False:C215
	If ($file.exists)
		$isPictureFile:=Is picture file:C1113($file.platformPath)
	End if 
	
Function readPictureFile($file : 4D:C1709.File)->$result : Object
	ASSERT:C1129($file#Null:C1517)
	
	$result:={success: False:C215}
	If ($file.exists)
		var $picture : Picture
		READ PICTURE FILE:C678($file.platformPath; $picture)
		If (ok=1)
			This:C1470.picture:=$picture
			$result.success:=True:C214
		End if 
	End if 
	
Function writePictureFile($file : 4D:C1709.File; $codec : Text)->$result : Object
	ASSERT:C1129($file#Null:C1517)
	
	$result:={success: False:C215}
	If (Not:C34(This:C1470.isEmpty()))
		If (($codec=Null:C1517) || ($codec=""))
			WRITE PICTURE FILE:C680($file.platformPath; This:C1470.picture)
		Else 
			WRITE PICTURE FILE:C680($file.platformPath; This:C1470.picture; $codec)
		End if 
		If (ok=1)
			$result.success:=True:C214
		End if 
	End if 
	
	
	//MARK:- pasteboard functions
	
Function setPictureToPasteboard()
	var $picture : Picture
	If (This:C1470.picture#Null:C1517)
		$picture:=This:C1470.picture
	End if 
	SET PICTURE TO PASTEBOARD:C521($picture)
	
Function getPictureToPasteboard()
	var $picture : Picture
	GET PICTURE FROM PASTEBOARD:C522($picture)
	This:C1470.picture:=$picture
	
	
	//MARK:- native functions
	
Function compare($picture : Picture)->$result : Object
	ASSERT:C1129(Count parameters:C259>0)
	
	$result:={isEqual: False:C215; mask: Null:C1517}
	
	var $mask : Picture
	$result.isEqual:=Equal pictures:C1196(This:C1470.picture; $picture; $mask)
	$result.mask:=$mask
	
Function convert($codec : Text; $compression : Real)->$picture
	ASSERT:C1129(($codec#Null:C1517) && ($codec#""))
	ASSERT:C1129(($compression=Null:C1517) || (($compression>=0) & ($compression<=1)))
	
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture
		If ((Count parameters:C259=1) || ($compression=Null:C1517))
			CONVERT PICTURE:C1002($picture; $codec)
		Else 
			CONVERT PICTURE:C1002($picture; $codec; $compression)
		End if 
	End if 
	
Function combine($picture : Picture; $operation : Integer; $horOffset : Integer; $vertOffset : Integer)->$pictureRes : Picture
	ASSERT:C1129(Count parameters:C259>0)
	ASSERT:C1129([Horizontal concatenation:K61:8; Superimposition:K61:10; Vertical concatenation:K61:9].indexOf($operation)#-1)
	
	COMBINE PICTURES:C987($pictureRes; This:C1470.picture; $operation; $picture; $horOffset; $vertOffset)
	
Function thumbnail($param : Object)->$thumbnail : Picture
	ASSERT:C1129($param#Null:C1517)
	ASSERT:C1129((Value type:C1509($param.width)=Is real:K8:4) && ($param.width>0))
	ASSERT:C1129((Value type:C1509($param.height)=Is real:K8:4) && ($param.height>0))
	ASSERT:C1129(($param.mode=Null:C1517) || ([Scaled to fit:K6:2; Scaled to fit proportional:K6:5; Scaled to fit prop centered:K6:6].indexOf($param.mode)#-1))
	
	If (Not:C34(This:C1470.isEmpty()))
		CREATE THUMBNAIL:C679(This:C1470.picture; \
			$thumbnail; \
			$param.width; \
			$param.height; \
			$param.mode=Null:C1517 ? Scaled to fit prop centered:K6:6 : $param.mode)
		
		// $param.width=Null ? 48 : $param.width;
		// $param.height=Null ? 48 : $param.height;
		
	End if 
	
	
	//MARK:- svg functions
	
Function rotate($angle : Real)->$rotatedPicture : Picture
	ASSERT:C1129($angle#Null:C1517)
	
	If ((Not:C34(This:C1470.isEmpty()) && (($angle%360)#0)))
		
		var $partList : Object
		$partList:=This:C1470.partsList()
		
		//If (($angle%90)=0)
		//// does not work well for rotation of 45° for instance...
		//// also, the with and height are not correct after a rotation...
		//// so this code is desactivated...
		
		//// https://github.com/miyako/4d-component-rotate-picture#4d-component-rotate-picture
		//$svg:=SVG_New
		//$groupRef:=SVG_New_group($svg)
		//$image:=SVG_New_embedded_image($groupRef; This.picture)
		//SVG_ROTATION_CENTERED($image; $angle)
		//$rotatedPicture:=SVG_Export_to_picture($svg)
		//SVG_CLEAR($svg)
		
		//Else 
		
		var $width; $height : Integer
		PICTURE PROPERTIES:C457(This:C1470.picture; $width; $height)
		
		var $sin; $cos : Real
		$sin:=Abs:C99(Sin:C17($angle*Degree:K30:2))
		$cos:=Abs:C99(Cos:C18($angle*Degree:K30:2))
		
		var $newWidth; $newHeight : Integer
		$newWidth:=Round:C94(($width*$cos)+($height*$sin); 0)
		$newHeight:=Round:C94(($width*$sin)+($height*$cos); 0)
		
		var $svg; $groupRef; $imageRef : Text
		$svg:=SVG_New($newWidth; $newHeight)
		$groupRef:=SVG_New_group($svg)
		$imageRef:=SVG_New_embedded_image($groupRef; This:C1470.picture; ($newWidth/2)-($width/2); ($newHeight/2)-($height/2))
		SVG_SET_TRANSFORM_ROTATE($groupRef; $angle; $newWidth/2; $newHeight/2)
		
		$rotatedPicture:=SVG_Export_to_picture($svg)
		
		SVG_CLEAR($svg)
		
		//End if 
		
		// The resulting image is in svg format...
		// Lets convert it back to "original" format
		If ($partList.success)
			var $codec : Text
			$codec:=$partList.parts[0].type
			If ([".jpg"; ".png"; ".bmp"; ".gif"; ".tif"].indexOf($codec)#-1)
				CONVERT PICTURE:C1002($rotatedPicture; $codec)
			End if 
		End if 
		
	End if 
	
	
	//MARK:- transform functions
	
Function crop($param : Object)->$croppedPicture : Picture
	ASSERT:C1129($param#Null:C1517)
	ASSERT:C1129(Value type:C1509($param.originX)=Is real:K8:4)
	ASSERT:C1129(Value type:C1509($param.originY)=Is real:K8:4)
	ASSERT:C1129(Value type:C1509($param.width)=Is real:K8:4)
	ASSERT:C1129(Value type:C1509($param.height)=Is real:K8:4)
	
	If (Not:C34(This:C1470.isEmpty()))
		$croppedPicture:=This:C1470.picture
		TRANSFORM PICTURE:C988($croppedPicture; Crop:K61:7; $param.originX; $param.originY; $param.width; $param.height)
	End if 
	
Function reset()->$picture : Picture
	
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture
		TRANSFORM PICTURE:C988($picture; Reset:K61:1)
	End if 
	
Function scale($param : Object)->$picture : Picture
	ASSERT:C1129($param#Null:C1517)
	ASSERT:C1129(Value type:C1509($param.width)=Is real:K8:4)
	ASSERT:C1129(Value type:C1509($param.height)=Is real:K8:4)
	
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture
		TRANSFORM PICTURE:C988($picture; Scale:K61:2; $param.width; $param.height)
	End if 
	
Function translate($param : Object)->$picture : Picture
	ASSERT:C1129($param#Null:C1517)
	ASSERT:C1129(Value type:C1509($param.x)=Is real:K8:4)
	ASSERT:C1129(Value type:C1509($param.y)=Is real:K8:4)
	
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture
		TRANSFORM PICTURE:C988($picture; Translate:K61:3; $param.x; $param.y)
	End if 
	
Function flipHorizontally()->$picture : Picture
	
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture
		TRANSFORM PICTURE:C988($picture; Flip horizontally:K61:4)
	End if 
	
Function flipVertically()->$picture : Picture
	
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture
		TRANSFORM PICTURE:C988($picture; Flip vertically:K61:5)
	End if 
	
Function fadeToGreyScale()->$picture : Picture
	
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture
		TRANSFORM PICTURE:C988($picture; Fade to grey scale:K61:6)
	End if 
	
Function transparency($rgb : Integer)->$picture : Picture
	ASSERT:C1129($rgb#Null:C1517)
	
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture
		TRANSFORM PICTURE:C988($picture; Transparency:K61:11; $rgb)
	End if 
	
	
	//MARK:- picture operator functions
	
Function horizontalConcatenate($picture : Integer)->$newPicture : Picture
	$newPicture:=This:C1470.picture+$pixels
	
Function verticalConcatenate($pixels : Integer)->$newPicture : Picture
	$newPicture:=This:C1470.picture/$pixels
	
	"Function horizontalMove($pixels : Integer)->$picture : Picture"
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture+$pixels
	End if 
	
Function verticalMove($pixels : Integer)->$picture : Picture
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture/$pixels
	End if 
	
Function resize($ratio : Real)->$picture : Picture
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture*Abs:C99($ratio)
	End if 
	
Function horizontalScaling($ratio : Real)->$picture : Picture
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture*+Abs:C99($ratio)
	End if 
	
Function verticalScaling($ratio : Real)->$picture : Picture
	If (Not:C34(This:C1470.isEmpty()))
		$picture:=This:C1470.picture*|Abs:C99($ratio)
	End if 
	
Function containsKeyword($keyword : Text)->$containsKeyword : Boolean
	If (Not:C34(This:C1470.isEmpty()))
		$containsKeyword:=This:C1470.picture%$keyword
	End if 
	
	
	//MARK:- base64 functions
	
Function fromBase64($base64 : Text; $codec : Text)
	ASSERT:C1129(Count parameters:C259>0)
	
	var $picture : Picture
	If ($base64#"")
		var $blob : Blob
		BASE64 DECODE:C896($base64; $blob)
		BLOB TO PICTURE:C682($blob; $picture; $codec="" ? "image/jpg" : $codec)
	End if 
	This:C1470.picture:=$picture
	
Function toBase64($codec : Text)->$base64 : Text
	$base64:=""
	If (Not:C34(This:C1470.isEmpty()))
		var $blob : Blob
		PICTURE TO BLOB:C692(This:C1470.picture; $blob; $codec="" ? "image/jpg" : $codec)
		BASE64 ENCODE:C895($blob; $base64)
	End if 
	
	
	//MARK:- blob functions
	
Function fromBlob($blob : Blob; $codec : Text)
	ASSERT:C1129(Count parameters:C259>0)
	
	var $picture : Picture
	If (BLOB size:C605($blob)>0)
		BLOB TO PICTURE:C682($blob; $picture; $codec="" ? "image/jpg" : $codec)
	End if 
	This:C1470.picture:=$picture
	
Function toBlob($codec : Text)->$blob : Blob
	If (Not:C34(This:C1470.isEmpty()))
		PICTURE TO BLOB:C692(This:C1470.picture; $blob; $codec="" ? "image/jpg" : $codec)
	End if 
	
	
	//MARK:- codecs/parts functions
	
Function getCodecs()->$codecs : Collection
	$codecs:=[]
	
/*
4D v20 R7 - MacOS Sonoma 14.6 (23G80)
[
    {
        "codec": ".4pct",
        "name": "4D Picture"
    },
    {
        "codec": ".jpg",
        "name": "Jpeg"
    },
    {
        "codec": ".png",
        "name": "Png"
    },
    {
        "codec": ".bmp",
        "name": "Bmp"
    },
    {
        "codec": ".gif",
        "name": "Gif"
    },
    {
        "codec": ".tif",
        "name": "Tiff"
    },
    {
        "codec": ".pdf",
        "name": "Pdf"
    },
    {
        "codec": ".svg",
        "name": "Scalable Vector Graphics"
    },
    {
        "codec": ".jp2",
        "name": "Jpeg-2000"
    },
    {
        "codec": ".astc",
        "name": "Astc"
    },
    {
        "codec": ".ktx",
        "name": "Ktx"
    },
    {
        "codec": ".heic",
        "name": "Heic"
    },
    {
        "codec": ".heics",
        "name": "Heics"
    },
    {
        "codec": ".ico",
        "name": "Ico"
    },
    {
        "codec": ".icns",
        "name": "Icns"
    },
    {
        "codec": ".psd",
        "name": "Photoshop"
    },
    {
        "codec": ".tga",
        "name": "Tga"
    },
    {
        "codec": ".exr",
        "name": "Openexr"
    },
    {
        "codec": ".pbm",
        "name": "Pbm"
    },
    {
        "codec": ".pvr",
        "name": "Pvr"
    },
    {
        "codec": ".dds",
        "name": "Dds"
    }
]
*/
	
	ARRAY TEXT:C222($tt_codec; 0)
	ARRAY TEXT:C222($tt_codec; 0)
	PICTURE CODEC LIST:C992($tt_codec; $tt_codecName)
	ARRAY TO COLLECTION:C1563($codecs; $tt_codec; "codec"; $tt_codecName; "name")
	
Function partsList()->$result : Object
	$result:={success: False:C215; parts: []}
/*
 4D picture format is not public. So I have reverse engineered it. It is for curiosity purpose only
 I am only trying to read and document the format.
 on Mac OS X, a picture from the clipboard will have several formats. They are all preserved/ imported in 4D.
 on Windows, I did a screenshot with "nircmd savescreenshot *clipboard*" and I got only a".bmp" format...
 tested with 4D v12 on Mac OS X Intel with(very) few images
 tested on:
  4D v12 OS X 10.8.5 Intel=> OK
  4D v13 Widnows 7 Intel=> OK
  4D v14 OS X 10.8.5 Intel=> OK
  4D v20 OS X 14.6 arm64 => OK
 Bruno LEGAY
*/
	
	var $blob : Blob
	SET BLOB SIZE:C606($blob; 0)
	
	ARRAY TEXT:C222($tt_containerPartTypeList; 0)
	ARRAY LONGINT:C221($tl_offset; 0)
	ARRAY LONGINT:C221($tl_size; 0)
	
	var $blobToVarOffset : Integer
	
	If (Picture size:C356(This:C1470.picture)>0)
		PICTURE TO BLOB:C692(This:C1470.picture; $blob; ".4PCT")  // get 4D raw format(same as VARIABLE TO BLOB without the 9 extra byte headers)
	End if 
	$blobToVarOffset:=0x0000
	
	If (BLOB size:C605($blob)>=0x001C)
		var $offset; $formatVersion; $nbParts; $payloadSize : Integer
		
		
		//==============================================
		// 4D picture format header
		//==============================================
		If (True:C214)
			// offset 0x00, size 0x1C(28 bytes):
			// 54 43 50 34 08 00 00 00 05 00 00 00 9F 27 02 00 3E 00 00 00 48 00 00 00 00 00 00 00
			// guess:
			// 54 43 50 34="TCP4"=> looks like a signature'4PCT' in reverse(signature+ byte order infos?)
			// 08 00 00 00= little endian longint format version?
			// 05 00 00 00= little endian longint number of parts?
			// 9F 27 02 00= little endian longint payload size(00 02 27 9F) starting at the first payload byte
			// 3E 00 00 00= little endian longint container type list size(starting after this block)
			// 48 00 00 00= little endian longint metadata size
			// 00 00 00 00=???
			$offset:=0x0000+$blobToVarOffset
			
			var $signature : Integer
			$signature:=BLOB to longint:C551($blob; PC byte ordering:K22:3; $offset)
			Case of 
				: ($signature=0x34504354)  ////'4PCT'(byteswap of'TCP4' 0x54435034)
					ASSERT:C1129($offset=($blobToVarOffset+0x0004))  // 0x04/ 4
					$formatVersion:=BLOB to longint:C551($blob; PC byte ordering:K22:3; $offset)
					ASSERT:C1129($formatVersion=8; "unknown format version : "+String:C10($formatVersion))
					$result.success:=($formatVersion=8)
				Else 
					ASSERT:C1129(False:C215; "unexpected signature "+String:C10($signature; "&x"))
			End case 
			
			If ($result.success)
				Case of 
					: ($formatVersion=8)
						
						ASSERT:C1129($offset=($blobToVarOffset+0x0008))  // 0x08/ 8
						$nbParts:=BLOB to longint:C551($blob; PC byte ordering:K22:3; $offset)
						ASSERT:C1129($nbParts>0; "no parts : "+String:C10($nbParts)+", at offset "+String:C10($offset; "&x"))
						
						ASSERT:C1129($offset=($blobToVarOffset+0x000C))  // 0x0C/ 12
						$payloadSize:=BLOB to longint:C551($blob; PC byte ordering:K22:3; $offset)
						ASSERT:C1129($payloadSize>0; "empty paylod size : "+String:C10($payloadSize)+", at offset "+String:C10($offset; "&x"))
						
						// get the container information size in bytes at offset 0x09
						// which starts at offset 0x10
						//$vl_offset:=(0x0010)+$vl_blobToVarOffset
						ASSERT:C1129($offset=($blobToVarOffset+0x0010))  // 0x10/ 16
						var $containerListSize : Integer
						$containerListSize:=BLOB to longint:C551($blob; PC byte ordering:K22:3; $offset)
						ASSERT:C1129($containerListSize>0; "empty container list size : "+String:C10($containerListSize)+", at offset "+String:C10($offset; "&x"))
						
						// offset 0x14, size 0x8(8 bytes):
						// 48 00 00 00 00 00 00 00
						// guess:
						// 48 00 00 00=> 72(metadata size?)
						// 00 00 00 00=>???
						ASSERT:C1129($offset=($blobToVarOffset+0x0014))  // 0x14/ 20
						var $metadataSize : Integer
						$metadataSize:=BLOB to longint:C551($blob; PC byte ordering:K22:3; $offset)  // 0x48=> 72
						ASSERT:C1129($metadataSize>0; "empty metadata size : "+String:C10($metadataSize)+", at offset "+String:C10($offset; "&x"))
						
				End case 
			End if 
		End if 
		
		
		//==============================================
		// get the list of part types
		//==============================================
		If ($result.success)
			Case of 
				: ($formatVersion=8)
					
					// offset 0x1C, variable size$vl_containerListSize
					// size of string+ string in UTF-16LE""
					// FC FF FF FF 2E 00 67 00 69 00 66 00=>".gif"
					// FC FF FF FF 2E 00 6A 00 70 00 67 00=>".jpg"
					// FB FF FF FF 2E 00 70 00 69 00 63 00 74 00=>".pict"
					// FC FF FF FF 2E 00 70 00 6E 00 67 00=>".png"
					// FC FF FF FF 2E 00 74 00 69 00 66 00=>".tif"
					
					// copy the bloc which contains the part types
					var $containerListBlob : Blob
					COPY BLOB:C558($blob; $containerListBlob; 0x001C+$blobToVarOffset; 0; $containerListSize)
					ASSERT:C1129(BLOB size:C605($containerListBlob)=$containerListSize)
					
					ARRAY TEXT:C222($tt_containerPartTypeList; 0)
					
					var $containerListOffset : Integer
					$containerListOffset:=0x0000  // start at the begining of that container list block
					Repeat 
						
						ASSERT:C1129($containerListOffset<(BLOB size:C605($containerListBlob)-4); "blob size : "+String:C10(BLOB size:C605($containerListBlob))+", offset : "+String:C10($containerListOffset))
						$partSize:=BLOB to longint:C551($containerListBlob; PC byte ordering:K22:3; $containerListOffset)
						//$vl_partSize:=((($vl_partSize ^| 0xFFFFFFFF)+1)<< 1)// Ones' complement x 2 stange
						$partSize:=(-$partSize)*2  // Ones' complement<=>-value
						
						var $containerPartTypeBlob : Blob
						SET BLOB SIZE:C606($containerPartTypeBlob; 0)
						COPY BLOB:C558($containerListBlob; $containerPartTypeBlob; $containerListOffset; 0; $partSize)
						$containerListOffset:=$containerListOffset+$partSize
						
						APPEND TO ARRAY:C911($tt_containerPartTypeList; Convert to text:C1012($containerPartTypeBlob; "UTF-16LE"))
					Until ($containerListOffset>=BLOB size:C605($containerListBlob))
			End case 
		End if 
		
		//==============================================
		// read the metadata(???) todo:
		//==============================================
		If ($result.success)
			Case of 
				: ($formatVersion=8)
					// offset 0x1C+$vl_containerListSize, variable size$vl_metadataSize
					// 47 41 42 56 01 00 00 00 01 04 00 00 00 1A 00 00 00 05 66 72 43 6F 6C 06 66 72 4C 69 6E 65 07 66 72 53 70 6C 69 74 04 76 65 72 73 00 0C 00 00 00 04 00 01 00 00 00 04 00 01 00 00 00 04 00 00 00 00 00 04 00 01 00 00 00
					//"GABV frCol frLine frSplit vers "
					
					// guess:
					// 47 41 42 56=>"GABV" metadata signature?
					// 01 00 00 00=> longint 1 version???
					// 01=> octet 1??? byte order?
					// 04 00 00 00=> longint 4 metadata number of properties(pascal strings)
					// 1A 00 00 00=> longint 26 metadata data size
					// 05=> octet 5???(size of coming string)
					// 66 72 43 6F 6C=>"frCol"
					// 06=> octet 6???(size of coming string)
					// 66 72 4C 69 6E 65=>"frLine"
					// 07=> octet 7???(size of coming string)
					// 66 72 53 70 6C 69 74=>"frSplit"
					// 04=> octet 4???(size of coming string)
					// 76 65 72 73=>"vers"
					// get the part"types"
					
					// guess 0x1A/ 26 bytes(metadata data size)
					// 00 0C 00 00 00 04 00 01 00 00 00 04 00 01 00 00 00 04 00 00 00 00 00 04 00 01 00 00 00
					// 00 0C// 0xC=> 12???
					// 00 00 00 04 00 01// 1"frCol"?
					// 00 00 00 04 00 01// 1"frLine"?
					// 00 00 00 04 00 00// 0"frSplit"?
					// 00 00 00 04 00 01// 1"vers"?
					
					// guess 0x03/ 3 bytes(padding to make multiple of 4 metadata size)
					// 00 00 00
			End case 
			
		End if 
		
		//==============================================
		// get the address and size of each part
		//==============================================
		If ($result.success)
			Case of 
				: ($formatVersion=8)
					// offset 0x1C+$vl_containerListSize+$vl_metadataSize, size 0x20/32 bytes x number of parts(?)
					// each address block has a 0x18 unknown data
					// followed by 2 little endian longints which are the part data offset and the part data size
					// the offset is an absolute offset(from 0x00) of the 4PCT" blob
					// 32 bytes 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 42 01 00 00 00 12 00 00
					// 32 bytes 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 42 13 00 00 45 45 00 00
					// 32 bytes 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 87 58 00 00 D8 DD 00 00
					// 32 bytes 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 5F 36 01 00 50 15 00 00
					// 32 bytes 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 AF 4B 01 00 32 DD 00 00
					
					// gif 0x00000142('GIF89'
					// jpg 0x00001342(0xFF 0xD8 0xFF 0xE0 0x00 0x10'JFIF'
					// pict 0x00005887(pict format starts with the size of the data)
					// PNG 0x0001365F('PNG',13,10,26,10")
					// tiff 0x00014BAF('MM')
					
					
					var $partOffset; $partSize : Integer
					$offset:=0x001C+$containerListSize+$metadataSize+$blobToVarOffset
					
					var $i : Integer
					For ($i; 1; Size of array:C274($tt_containerPartTypeList))
						$offset:=$offset+0x0018  // 0x1B/ 24 relative offset in the addres table block
						
						$partOffset:=BLOB to longint:C551($blob; PC byte ordering:K22:3; $offset)
						$partSize:=BLOB to longint:C551($blob; PC byte ordering:K22:3; $offset)
						
						APPEND TO ARRAY:C911($tl_offset; $partOffset)
						APPEND TO ARRAY:C911($tl_size; $partSize)
					End for 
			End case 
		End if 
		
		//==============================================
		// container payload data(all the image data)
		//==============================================
		If ($result.success)
			// offset 0x1C+$vl_containerListSize+$vl_metadataSize+(0x20x$vl_nbParts), size $vl_payloadSize
			
			ARRAY TO COLLECTION:C1563($result.parts; $tt_containerPartTypeList; "type"; $tl_offset; "offset"; $tl_size; "size")
		End if 
		
		
	End if 
	
Function getPartType()->$partType : Text
	$partType:=""
	
	If (Not:C34(This:C1470.isEmpty()))
		
		var $partList : Object
		$partList:=This:C1470.partsList()
		
		If ($partList.success)
			$partType:=$partList.parts[0].type
		End if 
		
	End if 
	
	
	//MARK:- metadata functions
	
Function addKeyword($keyword : Text)
	If (Not:C34(This:C1470.isEmpty()) & ($keyword#""))
		
		var $picture : Picture
		$picture:=This:C1470.picture
		
		ARRAY TEXT:C222($tt_keywords; 0)
		GET PICTURE KEYWORDS:C1142($picture; $tt_keywords)  //; *)
		
		APPEND TO ARRAY:C911($tt_keywords; $keyword)
		SET PICTURE METADATA:C1121($picture; IPTC keywords:K68:118; $tt_keywords)
		
		This:C1470.picture:=$picture
		
		ARRAY TEXT:C222($tt_keywords; 0)
	End if 
	
Function getMetadata()->$metadata : Object
	$metadata:={}
	
/*
{
    "tiff": {
        "Orientation": "1",
        "ResolutionUnit": "2",
        "XResolution": "72",
        "YResolution": "72"
    },
    "exif": {
        "ColorSpace": "1",
        "ComponentsConfiguration": "1;2;3;0",
        "ExifVersion": "0221",
        "FlashPixVersion": "0100",
        "PixelXDimension": "1295",
        "PixelYDimension": "1749",
        "SceneCaptureType": "0"
    }
}
*/
	
	var $domXmlRoot : Text
	$domXmlRoot:=DOM Create XML Ref:C861("metadata")  //Creation of an XML DOM tree
	If (ok=1)
		
		GET PICTURE METADATA:C1122(This:C1470.picture; ""; $domXmlRoot)
		
		var $domElementRef : Text
		$domElementRef:=DOM Get first child XML element:C723($domXmlRoot)
		While (ok=1)
			
			var $themeName : Text
			DOM GET XML ELEMENT NAME:C730($domElementRef; $themeName)
			
			var $theme : Object
			$theme:={}
			
			var $attributeIndex; $attributeCount : Integer
			$attributeCount:=DOM Count XML attributes:C727($domElementRef)
			For ($attributeIndex; 1; $attributeCount)
				var $attributeName; $attributeValue : Text
				DOM GET XML ATTRIBUTE BY INDEX:C729($domElementRef; $attributeIndex; $attributeName; $attributeValue)
				$theme[$attributeName]:=$attributeValue
			End for 
			
			$metadata[Lowercase:C14($themeName)]:=$theme
			
			$domElementRef:=DOM Get next sibling XML element:C724($domElementRef)
		End while 
		
		DOM CLOSE XML:C722($domXmlRoot)
	End if 
	
Function getMetadataAsXml()->$xml : Text
	$xml:=""
	
/*
<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<metadata>
    
    <TIFF Orientation="3" ResolutionUnit="2" XResolution="72" YResolution="72"/>
    
    <EXIF ColorSpace="1" ComponentsConfiguration="1;2;3;0" ExifVersion="0221" FlashPixVersion="0100" PixelXDimension="1295" PixelYDimension="1749" SceneCaptureType="0"/>
    
</metadata>
	
*/
	
	var $domXmlRoot : Text
	$domXmlRoot:=DOM Create XML Ref:C861("metadata")  //Creation of an XML DOM tree
	If (ok=1)
		GET PICTURE METADATA:C1122(This:C1470.picture; ""; $domXmlRoot)
		DOM EXPORT TO VAR:C863($domXmlRoot; $xml)
		DOM CLOSE XML:C722($domXmlRoot)
	End if 
	
	
Function typeToExtension($type : Text)->$extension
	$extension:=$type
	
/*
Case of 
: ($type=".4pct")
$extension:=$type
	
: ($type=".jpg")
$extension:=$type
	
: ($type=".png")
$extension:=$type
	
: ($type=".bmp")
$extension:=$type
	
: ($type=".gif")
$extension:=$type
	
: ($type=".tif")
$extension:=$type
	
: ($type=".pdf")
$extension:=$type
	
: ($type=".svg")
$extension:=$type
	
: ($type=".jp2")
$extension:=$type
	
: ($type=".astc")
$extension:=$type
	
: ($type=".ktx")
$extension:=$type
	
: ($type=".heic")
$extension:=$type
	
: ($type=".heics")
$extension:=$type
	
: ($type=".ico")
$extension:=$type
	
: ($type=".icns")
$extension:=$type
	
: ($type=".psd")
$extension:=$type
	
: ($type=".tga")
$extension:=$type
	
: ($type=".exr")
$extension:=$type
	
: ($type=".pbm")
$extension:=$type
	
: ($type=".dds")
$extension:=$type
	
: ($type=".pvr")
$extension:=$type
	
Else 
$extension:=$type
End case 
*/
	
	
Function typeToMime($type : Text)->$mime : Text
	
	Case of 
		: ($type=".4pct")
			$mime:="image/x-pict"
			
		: ($type=".jpg")  // ou .jpeg
			$mime:="image/jpeg"
			
		: ($type=".png")
			$mime:="image/png"
			
		: ($type=".bmp")
			$mime:="image/bmp"
			
		: ($type=".gif")
			$mime:="image/gif"
			
		: ($type=".tif")  // ou .tiff
			$mime:="image/tiff"
			
		: ($type=".pdf")
			$mime:="application/pdf"
			
		: ($type=".svg")
			$mime:="image/svg+xml"
			
		: ($type=".jp2")
			$mime:="image/jp2"
			
		: ($type=".astc")
			$mime:="image/astc"
			
		: ($type=".ktx")
			$mime:="image/ktx"
			
		: ($type=".heic")
			$mime:="image/heic"
			
		: ($type=".heics")
			$mime:="image/heics"
			
		: ($type=".ico")
			$mime:="image/x-icon"
			
		: ($type=".icns")
			$mime:="image/icns"
			
		: ($type=".psd")
			$mime:="image/vnd.adobe.photoshop"
			
		: ($type=".tga")
			$mime:="image/x-tga"
			
		: ($type=".exr")
			$mime:="image/x-exr"
			
		: ($type=".pbm")
			$mime:="image/x-portable-bitmap"
			
		: ($type=".dds")
			$mime:="image/vnd.ms-dds"
			
		: ($type=".pvr")
			$mime:="image/x-pvr"
			
	End case 
	
	
	
