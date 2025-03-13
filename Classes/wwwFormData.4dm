// This class helps build www-form-urlencoded data

Class constructor()
	
	If (False:C215)
		
		//var $data : Object
		//$data:=New object
		//$data.param1:="hello world"
		//$data.param2:="A&C"
		
		//var $formData : cs.wwwFormData
		//$formData:=cs.wwwFormData.new()
		
		//var $headers : Object
		//$headers:=New object
		//$headers["content-type"]:=$formData.contentType // "application/x-www-form-urlencoded"
		
		//var $options : Object
		//$options:=New object
		//$options.method:=HTTP POST method
		//$options.headers:=$headers
		//$options.dataType:="blob"
		//$options.body:=$formData.encodeBlob($data) // "param1=hello+world&param2=A%26C"
		
		//var $url : Text
		//$url:="https://example.com/api/v1/test"
		
		//var $request : 4D.HTTPRequest
		//$request:=4D.HTTPRequest.new($url; $options)
		//$request.wait(60)
		
		//Case of 
		//: ($request.terminated && ($request.response.status=200))  // terminated and expected status 
		
		//: ($request.terminated)  // terminated but unexpected status (handle error)
		
		//Else   // timeout (handle error)
		
		//End case 
	End if 
	
	This:C1470.urlEncoder:=cs:C1710.urlEncoder.new()
	This:C1470.urlEncoder.encodeSlash:=False:C215  // no need to escape "/"
	This:C1470.urlEncoder.rawUrlEncoding:=False:C215  // send " " (space) as "+", not "%20"
	
Function encode($data : Object)->$formData : Text
	
	$formData:=""
	var $property : Text
	For each ($property; $data)
		If (Value type:C1509($data[$property])=Is text:K8:3)
			$formData:=$formData+Choose:C955(Length:C16($formData)=0; ""; "&")+This:C1470.urlEncoder.encode($property)+"="+This:C1470.urlEncoder.encode($data[$property])
		End if 
	End for each 
	
Function encodeBlob($data : Object; $charset : Text)->$formDataBlob : Blob
	var $encoded : Text
	$encoded:=This:C1470.urlEncode($data)
	
	var $charsetConv : Text
	If (Count parameters:C259>1)
		$charsetConv:=$charset
	Else 
		$charsetConv:="UTF-8"
	End if 
	
	CONVERT FROM TEXT:C1011($encoded; $charsetConv; $formDataBlob)
	
Function get contentType()->$contentType : Text
	$contentType:="application/x-www-form-urlencoded"
	
Function decode($formData : Text)->$data : Object
	$data:=New object:C1471
	
	var $urlDecoder : cs:C1710.urlDecoder
	$urlDecoder:=cs:C1710.urlDecoder.new()
	
	var $params : Collection
	$params:=Split string:C1554($formData; "&")
	var $param : Text
	For each ($param; $params)
		var $pos : Integer
		$pos:=Position:C15("="; $param; *)
		If ($pos>0)
			$data[$urlDecoder.decode(Substring:C12($param; 1; $pos-1))]:=$urlDecoder.decode(Substring:C12($param; $pos+1))
		Else 
			$data[$urlDecoder.decode(Substring:C12($param; 1; $pos-1))]:=Null:C1517
		End if 
	End for each 