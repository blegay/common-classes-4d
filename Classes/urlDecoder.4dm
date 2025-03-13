//================================================================================
//@xdoc-start : en
//@description : This class will decode an urlEncoded data
//@notes : 
//@example : 
//
// var $urlDecoder : cs.urlDecoder
// $urlDecoder:=cs.urlDecoder.new()
// var $url: Text
// $url:=$urlDecoder.decode($urlEncoded)
//
//@see : 
//@version : 1.00.00
//@author : Bruno LEGAY (BLE) - Copyrights A&C Consulting 2024
//@history : 
//  CREATION : Bruno LEGAY (BLE) - 26/11/2024, 10:00:00 - v1.00.00
//@xdoc-end
//================================================================================

Class constructor()
	
Function decode($urlEncoded : Text)->$url : Text
	
	ASSERT:C1129(Count parameters:C259>0; "1 parameter is required")
	
	If (Length:C16($urlEncoded)>0)
		$url:=$urlEncoded
		
		// hard coded : replace "+" in Url which is a substribtute to space
		$url:=Replace string:C233($url; "+"; " "; *)
		
		// get a group of consecutive "%xx" where "xx" are hexadecimal characters
		var $regex : Text
		$regex:="(?:%[[:xdigit:]][[:xdigit:]])+"  // this is a non-capturing group made of "%" followed by two hexadecimal characters, repeated one or more times
		
		var $escaped; $unescaped : Text
		var $start; $pos; $length : Integer
		$start:=1
		While (Match regex:C1019($regex; $url; $start; $pos; $length))
			
			$escaped:=Substring:C12($url; $pos; $length)  // e.g. "%e2%82%ac"
			$escaped:=Replace string:C233($escaped; "%"; "")  // e.g. "e282ac"
			
			// remove the encoded string from the url
			$url:=Delete string:C232($url; $pos; $length)
			
			var $blob : Blob
			SET BLOB SIZE:C606($blob; 0)
			This:C1470._hexTextToBlob($escaped; ->$blob)
			$unescaped:=Convert to text:C1012($blob; "UTF-8")
			SET BLOB SIZE:C606($blob; 0)
			
			// insert the decoded string in the url
			$url:=Insert string:C231($url; $unescaped; $pos)
			
			$start:=$pos+Length:C16($unescaped)  //start after the inserted decoded string
		End while 
		
	End if 
	
Function _hexTextToBlob($hex : Text; $blobPtr : Pointer)
	
	ASSERT:C1129(Count parameters:C259>1; "2 parameters are required")
	ASSERT:C1129(Type:C295($blobPtr->)=Is BLOB:K8:12; "$2 shoudl be a blob pointer")
	
	$hex:=Replace string:C233($hex; " "; ""; *)
	$hex:=Replace string:C233($hex; "-"; ""; *)
	$hex:=Replace string:C233($hex; "%"; ""; *)
	$hex:=Replace string:C233($hex; "\r"; ""; *)
	$hex:=Replace string:C233($hex; "\n"; ""; *)
	$hex:=Replace string:C233($hex; "\t"; ""; *)
	
	var $textLength : Integer
	$textLength:=Length:C16($hex)
	
	SET BLOB SIZE:C606($blobPtr->; 0)
	SET BLOB SIZE:C606($blobPtr->; $textLength\2; 0x00FF)
	
	If (Not:C34($textLength ?? 0))  //is evenLONG_isEven($vl_textLength))
		
		var $i; $offset : Integer
		
		$offset:=0
		For ($i; 1; $textLength; 2)
			$hex:=Substring:C12($hex; $i; 2)
			
			$blobPtr->{$offset}:=This:C1470._hexByteStrToByteInteger($hex)
			
			$offset:=$offset+1
		End for 
		
	End if 
	
Function _hexByteStrToByteInteger($hex : Text)->$byte : Integer
	
	ASSERT:C1129(Count parameters:C259>0; "1 parameter is required")
	
	If (Length:C16($hex)>1)
		
		$byte:=(This:C1470._hexCharToInt($hex[[1]]) << 4) | This:C1470._hexCharToInt($hex[[2]])
		
	End if 
	
Function _hexCharToInt($hex : Text)->$nibble : Integer
	
	ASSERT:C1129(Count parameters:C259>0; "1 parameter is required")
	
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
				
		End case 
		
	End if 
	
	
	