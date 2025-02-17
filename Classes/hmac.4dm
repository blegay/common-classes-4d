
property _alg : Text
property _outputBase64UrlEncoded : Boolean
property _algCode : Integer
property _blockSize : Integer

Class constructor($alg : Text)
	// $alg : "SHA1" "SHA256" or "SHA512" (default "SHA256")
	
	This:C1470.alg:=(($alg="SHA1") || ($alg="SHA256") || ($alg="SHA512")) ? $alg : "SHA256"
	This:C1470._outputBase64UrlEncoded:=True:C214
	
Function set alg($alg : Text)
	If (($alg="SHA1") || ($alg="SHA256") || ($alg="SHA512"))
		
		This:C1470._alg:=Uppercase:C13($alg)
		
		Case of 
			: (This:C1470._alg="SHA1")
				This:C1470._algCode:=SHA1 digest:K66:2
				This:C1470._blockSize:=64
				
			: (This:C1470._alg="SHA512")
				This:C1470._algCode:=SHA512 digest:K66:5
				This:C1470._blockSize:=128
				
			Else 
				//: (This._alg="SHA256")
				This:C1470._algCode:=SHA256 digest:K66:4
				This:C1470._blockSize:=64
				
		End case 
		
	Else 
		ASSERT:C1129(False:C215; "invalid alg \""+$alg+"\"")
	End if 
	
Function get alg()->$alg : Text
	$alg:=This:C1470._alg
	
Function set outputBase64UrlEncoded($outputBase64UrlEncoded : Boolean)
	This:C1470._outputBase64UrlEncoded:=$outputBase64UrlEncoded
	
Function get outputBase64UrlEncoded()->$outputBase64UrlEncoded : Boolean
	$outputBase64UrlEncoded:=This:C1470._outputBase64UrlEncoded
	
Function hmac($key : Variant; $message : Variant)->$hmac : Variant
	// accept blob or text for key and message, return $hmac blob or $hmac text (base64UrlEncoded)
	
	var $keyBlob; $messageBlob : Blob
	$keyBlob:=This:C1470._variantToBlob($key)
	$messageBlob:=This:C1470._variantToBlob($message)
	
	// keys longer than blocksize are shortened
	If (BLOB size:C605($keyBlob)>This:C1470._blockSize)
		$keyBlob:=This:C1470._generateDigestBlob($keyBlob)
	End if 
	
	// keys shorter than blocksize are padded
	If (BLOB size:C605($keyBlob)<This:C1470._blockSize)
		SET BLOB SIZE:C606($keyBlob; This:C1470._blockSize; 0x0000)
	End if 
	
	ASSERT:C1129(BLOB size:C605($keyBlob)=This:C1470._blockSize)
	
	var $outerPadBlob; $innerPadBlob : Blob
	SET BLOB SIZE:C606($outerPadBlob; This:C1470._blockSize; 0x0000)
	SET BLOB SIZE:C606($innerPadBlob; This:C1470._blockSize; 0x0000)
	
	var $offset; $byte : Integer
	
	//%R-
	For ($offset; 0; This:C1470._blockSize-1)
		$byte:=$keyBlob{$offset}
		$outerPadBlob{$offset}:=$byte ^| 0x005C
		$innerPadBlob{$offset}:=$byte ^| 0x0036
	End for 
	//%R+
	
	var $tempBlob : Blob
	
	// append $message to $innerPad
	This:C1470._appendBlob(->$innerPadBlob; $message)
	$tempBlob:=This:C1470._generateDigestBlob($innerPadBlob)
	
	// append hash(innerPad + message) to outerPad
	This:C1470._appendBlob(->$outerPadBlob; $tempBlob)
	$hmac:=This:C1470._outputBase64UrlEncoded ? This:C1470._generateDigestBase64UrlEncoded($outerPadBlob) : This:C1470._generateDigestBlob($outerPadBlob)
	
Function _variantToBlob($variant : Variant)->$blob : Blob
	
	Case of 
		: (Value type:C1509($variant)=Is BLOB:K8:12)
			$blob:=$variant
			
		: (Value type:C1509($variant)=Is text:K8:3)
			TEXT TO BLOB:C554($variant; $blob; UTF8 text without length:K22:17)
			
		Else 
			ASSERT:C1129(False:C215; "unssuported parameter type")
	End case 
	
Function _appendBlob($blobPointer : Pointer; $blob : Blob)
	ASSERT:C1129(Type:C295($blobPointer->)=Is BLOB:K8:12)
	COPY BLOB:C558($blob; $blobPointer->; 0; BLOB size:C605($blobPointer->); BLOB size:C605($blob))
	
Function _generateDigestBase64UrlEncoded($data : Blob)->$digestBase64UrlEncoded : Text
	$digestBase64UrlEncoded:=Generate digest:C1147($data; This:C1470._algCode; *)
	
Function _generateDigestBlob($data : Blob)->$digestBlob : Blob
	BASE64 DECODE:C896(Generate digest:C1147($data; This:C1470._algCode; *); $digestBlob; *)
	