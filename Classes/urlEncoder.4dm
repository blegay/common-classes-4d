//================================================================================
//@xdoc-start : en
//@description : This class will generate urlEncoded data
//@notes : There are two settings 
//   - encodeSlash (default True)
//   - rawUrlEncoding (default True)
//@example : 
//@see : 
//@version : 1.00.00
//@author : Bruno LEGAY (BLE) - Copyrights A&C Consulting 2024
//@history : 
//  CREATION : Bruno LEGAY (BLE) - 01/02/2024, 14:00:00 - v1.00.00
//@xdoc-end
//================================================================================

property encodeSlash : Boolean
property rawUrlEncoding : Boolean

Class constructor()
	
	This:C1470.encodeSlash:=True:C214
	This:C1470.rawUrlEncoding:=True:C214
	
Function encode($url : Text)->$urlEncoded : Text
	
	ASSERT:C1129(Count parameters:C259>0; "1 parameter is required")
	
	var $i; $unicode : Integer
	For ($i; 1; Length:C16($url))
		$unicode:=Character code:C91($url[[$i]])
		
		Case of 
			: ((($unicode>=0x0041) & ($unicode<=0x005A)) | \
				(($unicode>=0x0061) & ($unicode<=0x007A)) | \
				(($unicode>=0x0030) & ($unicode<=0x0039)) | \
				($unicode=0x005F) | \
				($unicode=0x002D) | \
				($unicode=0x007E) | \
				($unicode=0x002E))
				
				$urlEncoded:=$urlEncoded+$url[[$i]]
				//  "A" 65 0x41
				//  "Z" 90 0x5A
				//  "a" 97 0x61
				//  "z" 122 0x7A
				//  "0" 48 0x30
				//  "9" 57 0x39
				//  "_" 95 0x5F
				//  "-" 45 0x2D
				//  "~" 126 0x7E
				//  "." 46 0x2E
				
			: ($unicode=0x002F)
				//  "/" 47 0x2F
				$urlEncoded:=$urlEncoded+Choose:C955(This:C1470.encodeSlash; "%2F"; "/")
				
			: ($unicode=0x0020)
				//  " " 32 0x20
				$urlEncoded:=$urlEncoded+Choose:C955(This:C1470.rawUrlEncoding; "%20"; "+")
				
			Else 
				$urlEncoded:=$urlEncoded+This:C1470._urlEscapeUnicode($unicode)
		End case 
	End for 
	
Function _urlEscapeUnicode($unicode : Integer)->$unicodeEscaped : Text
	
	ASSERT:C1129(Count parameters:C259>0; "1 parameter is required")
	
	var $blob : Blob
	SET BLOB SIZE:C606($blob; 0)
	CONVERT FROM TEXT:C1011(Char:C90($unicode); "utf-8"; $blob)
	
	var $offset : Integer
	For ($offset; 0; BLOB size:C605($blob)-1)
		$unicodeEscaped:=$unicodeEscaped+"%"+Substring:C12(String:C10($blob{$offset}; "&x"); 5)
	End for 
	
	SET BLOB SIZE:C606($blob; 0)
	