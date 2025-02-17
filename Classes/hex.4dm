property _bigEndian : Boolean
property _hexTextSep : Text
property _hexTextLowercase : Boolean

Class constructor
	This:C1470._bigEndian:=True:C214
	This:C1470._hexTextSep:=" "
	This:C1470._hexTextLowercase:=True:C214
	
Function set bigEndian($bigEndian : Boolean)
	This:C1470._bigEndian:=$bigEndian
	
Function get bigEndian()->$bigEndian : Boolean
	$bigEndian:=This:C1470._bigEndian
	
Function set hexTextSep($hexTextSep : Text)
	This:C1470._hexTextSep:=$hexTextSep
	
Function get hexTextSep()->$hexTextSep : Text
	$hexTextSep:=This:C1470._hexTextSep
	
Function set hexTextLowercase($hexTextLowercase : Boolean)
	This:C1470._hexTextLowercase:=$hexTextLowercase
	
Function get hexTextLowercase()->$hexTextLowercase : Boolean
	$hexTextLowercase:=This:C1470._hexTextLowercase
	
Function hexTextToBinary($hexText : Text)->$binary : Blob
	
	$hexText:=Replace string:C233($hexText; " "; ""; *)
	$hexText:=Replace string:C233($hexText; "-"; ""; *)
	$hexText:=Replace string:C233($hexText; "%"; ""; *)
	$hexText:=Replace string:C233($hexText; "\r"; ""; *)
	$hexText:=Replace string:C233($hexText; "\n"; ""; *)
	$hexText:=Replace string:C233($hexText; "\t"; ""; *)
	
	SET BLOB SIZE:C606($binary; 0)
	
	var $textLength : Integer
	$textLength:=Length:C16($hexText)
	If (This:C1470._isEven($textLength))
		
		SET BLOB SIZE:C606($binary; $textLength\2; 0x00FF)
		
		var $i; $offset : Integer
		$offset:=0
		For ($i; 1; $textLength; 2)
			
			var $hex : Text
			If (This:C1470._bigEndian)
				$hex:=Substring:C12($hexText; $i; 2)
			Else 
				$hex:=Substring:C12($hexText; $i+1; 1)+Substring:C12($hexText; $i; 1)
			End if 
			
			$binary{$offset}:=This:C1470._hexByteStrToByteInteger($hex)
			
			$offset:=$offset+1
		End for 
		
	End if 
	
Function _hexByteStrToByteInteger($hex : Text)->$byte : Integer
	If (Length:C16($hex)=2)
		$byte:=(This:C1470._hexCharToInt($hex[[1]]) << 4) | This:C1470._hexCharToInt($hex[[2]])
	End if 
	
Function _hexCharToInt($hex : Text)->$nibble : Integer
	
	If (Length:C16($hex)>0)
		
		var $hexCharCode : Integer
		$hexCharCode:=Character code:C91($hex[[1]])
		
		Case of 
			: (($hexCharCode>=0x0030) & ($hexCharCode<=0x0039))  //0 => 9
				$nibble:=$hexCharCode-0x0030  //0 => 9
				
			: (($hexCharCode>=0x0041) & ($hexCharCode<=0x0046))  //A => F
				$nibble:=$hexCharCode-0x0037  //10 => 15
				
			: (($hexCharCode>=0x0061) & ($hexCharCode<=0x0066))  //a => f
				$nibble:=$hexCharCode-0x0057  //10 => 15
				
			Else 
				$nibble:=0
		End case 
		
	Else 
		$nibble:=0
	End if 
	
Function blobToHexText($blob : Blob)->$hexText : Text
	$hexText:=""
	
	var $offset : Integer
	For ($offset; 0; BLOB size:C605($blob)-1)
		$hexText+=(($offset=0) ? "" : This:C1470._hexTextSep)+Substring:C12(String:C10($blob{$offset}; "&x"); 5; 2)
	End for 
	
	If (This:C1470._hexTextLowercase)
		$hexText:=Lowercase:C14($hexText; *)
	End if 
	
Function _isEven($int : Integer)->$isEven : Boolean
	$isEven:=(($int%2)=0)