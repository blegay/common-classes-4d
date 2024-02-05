//================================================================================
//@xdoc-start : en
//@description : This class will generate a blob "multipart/form-data" htttp request
//@notes : 
//@example : 
// var $blob1; $blob2 : Blob
// 
// CONVERT FROM TEXT("hello"; "UTF-8"; $blob1)
// CONVERT FROM TEXT("world"; "UTF-8"; $blob2)
// 
// var $multipart : cs.httpMultipart
// $multipart:=cs.httpMultipart.new()
// $multipart.appendBlob($blob1; $multipart.contentDispositionHeaderColl("part1"))
// $multipart.appendBlob($blob2; $multipart.contentDispositionHeaderColl("part2"))
//
// var $multipartBlob : Blob
// $multipartBlob:=$multipart.finalize()
// 
// // --------------------------041f9c8caa2d40698657b339fad3b6f2<CR><LF>
// // Content-Disposition: form-data; name="part1"<CR><LF>
// // Content-Length: 5<CR><LF>
// // <CR><LF>
// // hello<CR><LF>
// // --------------------------041f9c8caa2d40698657b339fad3b6f2<CR><LF>
// // Content-Disposition: form-data; name="part2"<CR><LF>
// // Content-Length: 5<CR><LF>
// // <CR><LF>
// // world<CR><LF>
// // --------------------------041f9c8caa2d40698657b339fad3b6f2--
// 
// var $headers : Object
// $headers:=New object
// $headers["Content-Type"]:=$multipart.getContentType()
// 
// // {"Content-Type":"multipart/form-data; boundary=\"------------------------041f9c8caa2d40698657b339fad3b6f2\""}
//@see : 
//@version : 1.00.00
//@author : Bruno LEGAY (BLE) - Copyrights A&C Consulting 2024
//@history : 
//  CREATION : Bruno LEGAY (BLE) - 01/02/2024, 14:05:10 - v1.00.00
//@xdoc-end
//================================================================================

property data : Blob
property boundary : Text

Class constructor()
	var $blob : Blob
	
	This:C1470.data:=$blob
	This:C1470.boundary:="------------------------"+Lowercase:C14(Generate UUID:C1066)
	
	// private data
	This:C1470._finalized:=False:C215
	This:C1470._parts:=New collection:C1472
	This:C1470._startMs:=Milliseconds:C459
	This:C1470._duration:=0
	
	If (False:C215)
		// --========================24ac34429b3448d88e578c0ca77680cc
		// Content-Disposition: form-data; name="sampleText"; filename="sampleText.txt"
		// Content-Type: text/plain
		// Content-Length: 425
		//
		// -----BEGIN RSA PUBLIC KEY-----
		// MIIBCgKCAQEA6S4eWohhYutT6WNUU5zexmSkUfG4zgEMcSJM65qdzup900FweTLS
		// ...
		// 5EnPInqdOMSzlDpw9yh2OXYbsStiI5vGbjkrcTYI5Shm4VC4d7jOAxeCa3X/SJ+j
		// I1U/6+5+wrpiH9HCa3+Eyxq2M8gOOhhgRQIDAQAB
		// -----END RSA PUBLIC KEY-----
		// --========================24ac34429b3448d88e578c0ca77680cc
		// Content-Disposition: form-data; name="sampleText2"; filename="sampleText.txt2"
		// Content-Type: text/plain
		// Content-Length: 425
		//
		// -----BEGIN RSA PUBLIC KEY-----
		// MIIBCgKCAQEA6S4eWohhYutT6WNUU5zexmSkUfG4zgEMcSJM65qdzup900FweTLS
		// ...
		// 5EnPInqdOMSzlDpw9yh2OXYbsStiI5vGbjkrcTYI5Shm4VC4d7jOAxeCa3X/SJ+j
		// I1U/6+5+wrpiH9HCa3+Eyxq2M8gOOhhgRQIDAQAB
		// -----END RSA PUBLIC KEY-----
		// --========================24ac34429b3448d88e578c0ca77680cc--
	End if 
	
Function appendBlob($blob : Blob; $headers : Variant)
	ASSERT:C1129(Count parameters:C259>1; "requires 2 parameters")
	
	If (Not:C34(This:C1470._finalized))
		This:C1470._appendHeaders($headers; BLOB size:C605($blob))
		This:C1470._appendBlob($blob)
	End if 
	
Function appendText($text : Text; $charset : Text; $headers : Variant)
	ASSERT:C1129(Count parameters:C259>2; "requires 3 parameters")
	
	If (Not:C34(This:C1470._finalized))
		var $blob : Blob
		SET BLOB SIZE:C606($blob; 0)
		CONVERT FROM TEXT:C1011($text; $charset; $blob)
		This:C1470.appendBlob($blob; $headers)
		SET BLOB SIZE:C606($blob; 0)
	End if 
	
Function contentDispositionHeaderColl($name : Text; $extra : Text)->$headers : Collection
	ASSERT:C1129(Count parameters:C259>0; "requires 1 parameter")
	
	var $contentDispExtra : Text
	If (Count parameters:C259>1)
		If ($extra#"")
			$contentDispExtra:="; "+$extra
		End if 
	End if 
	
	$headers:=New collection:C1472("Content-Disposition: form-data; name=\""+$name+"\""+$contentDispExtra)
	
Function finalize()->$blob : Blob
	
	If (Not:C34(This:C1470._finalized))
		This:C1470._finalized:=True:C214
		
		var $crlf; $boundaryDelim : Text
		$crlf:="\r\n"
		$boundaryDelim:="--"
		
		var $headerPart : Text
		$headerPart:=$crlf+$boundaryDelim+This:C1470.boundary+$boundaryDelim
		
		var $headerPartBlob : Blob
		SET BLOB SIZE:C606($headerPartBlob; 0)
		CONVERT FROM TEXT:C1011($headerPart; "us-ascii"; $headerPartBlob)
		This:C1470._appendBlob($headerPartBlob)
		SET BLOB SIZE:C606($headerPartBlob; 0)
		
		This:C1470._duration:=(Milliseconds:C459-This:C1470._startMs)
		
	End if 
	
	$blob:=This:C1470.data
	
Function getContentType()->$contentType : Text
	$contentType:="multipart/form-data; boundary=\""+This:C1470.boundary+"\""
	
Function _appendHeaders($headers : Variant; $blobSize : Integer)
	ASSERT:C1129(Count parameters:C259>1; "requires 2 parameters")
	
	If ($headers#Null:C1517)
		var $crlf; $boundaryDelim : Text
		$crlf:="\r\n"
		$boundaryDelim:="--"
		
		var $headerPart : Text
		$headerPart:=Choose:C955(BLOB size:C605(This:C1470.data)>0; $crlf; "")+\
			$boundaryDelim+This:C1470.boundary+$crlf+\
			This:C1470._appendHeadersSub($headers; $blobSize)+$crlf
		
		var $headerPartBlob : Blob
		SET BLOB SIZE:C606($headerPartBlob; 0)
		CONVERT FROM TEXT:C1011($headerPart; "us-ascii"; $headerPartBlob)
		
		This:C1470._appendBlob($headerPartBlob)
		
		SET BLOB SIZE:C606($headerPartBlob; 0)
	End if 
	
Function _appendHeadersSub($headers : Variant; $blobSize : Integer)->$headersText : Text
	ASSERT:C1129(Count parameters:C259>1; "requires 2 parameters")
	
	var $crlf : Text
	$crlf:="\r\n"
	
	$headersText:=""
	Case of 
		: (Value type:C1509($headers)=Is collection:K8:32)
			
			If (True:C214)  // check/force "Content-Length" value
				var $headerKey
				$headerKey:="Content-Length"
				
				var $index : Integer
				$index:=$headers.indexOf($headerKey+": @")
				Case of 
					: ($index=-1)  // not found => add one header line with "Content-Length"
						$headers.push($headerKey+": "+String:C10($blobSize))
						
					: ($headers[$index]=($headerKey+": "+String:C10($blobSize)))  // ok
						
					Else   // not ok =-> override "Content-Length" value
						$headers[$index]:=Substring:C12($headers[$index]; 1; Length:C16($headerKey)+2)+String:C10($blobSize)
				End case 
			End if 
			
			$headersText:=$headers.join($crlf)+$crlf
			
		: (Value type:C1509($headers)=Is object:K8:27)
			
			var $headersColl
			$headersColl:=New collection:C1472
			var $property : Text
			For each ($property; $headers)
				If (Value type:C1509($headers[$property])=Is text:K8:3)
					$headersColl.push($property+": "+$headers[$property])
				End if 
			End for each 
			$headersText:=This:C1470._appendHeadersSub($headersColl; $blobSize)
			
		Else 
			ASSERT:C1129(False:C215; "unsupported header type")
	End case 
	
Function _appendBlob($blob : Blob)
	ASSERT:C1129(Count parameters:C259>0; "requires 1 parameter")
	
	// for fun/debug
	This:C1470._parts.push(New object:C1471("offset"; BLOB size:C605(This:C1470.data); "size"; BLOB size:C605($blob)))
	
	// COPY BLOB($blob; This.data; 0; BLOB size(This.data); BLOB size($blob))
	
	var $dataBlob : Blob
	SET BLOB SIZE:C606($dataBlob; 0)
	$dataBlob:=This:C1470.data
	COPY BLOB:C558($blob; $dataBlob; 0; BLOB size:C605($dataBlob); BLOB size:C605($blob))
	This:C1470.data:=$dataBlob
	SET BLOB SIZE:C606($dataBlob; 0)
	