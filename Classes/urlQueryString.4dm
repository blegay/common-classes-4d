Class constructor()
	
	This:C1470.urlEncoder:=cs:C1710.urlEncoder.new()
	This:C1470.urlEncoder.encodeSlash:=True:C214  // escape "/" to "%2F"
	This:C1470.urlEncoder.rawUrlEncoding:=True:C214  // send " " (space) as "%20", not "+"
	
Function encode($params : Object)->$queryString : Text
	If (Not:C34(OB Is empty:C1297($params)))
		
		$queryString:="?"
		
		var $property : Text
		For each ($property; $params)
			
			$queryString:=$queryString+Choose:C955(Length:C16($queryString)=1; ""; "&")+This:C1470.urlEncoder.encode($property)
			
			Case of 
				: (Value type:C1509($params[$property])=Is text:K8:3)
					$queryString:=$queryString+"="+This:C1470.urlEncoder.encode($params[$property])
					
				: (Value type:C1509($params[$property])=Is longint:K8:6)
					$queryString:=$queryString+"="+String:C10($params[$property])
					
				: (Value type:C1509($params[$property])=Is real:K8:4)
					$queryString:=$queryString+"="+String:C10($params[$property]; "&xml")
					
				: (Value type:C1509($params[$property])=Is boolean:K8:9)
					$queryString:=$queryString+"="+Choose:C955($params[$property]; "true"; "false")
					
			End case 
			
		End for each 
	End if 
	