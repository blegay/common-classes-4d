property _regex : Text

// This class is a wrapper on the "Match regex" function

Class constructor($regex : Text)
	This:C1470._regex:=$regex
	
Function set regex($regex : Text)
	This:C1470._regex:=$regex
	
Function get regex()->$regex : Text
	$regex:=This:C1470._regex
	
Function match($text : Text; $posParam : Integer; $searchAtPosOnlyParam : Boolean)->$result
	
	//var $regex : cs.regex
	//$regex:=cs.regex.new("(\\d+)€.*(\\d{4})-(\\d{1,2})-(\\d{1,2})")
	//
	//var $regexResult : Object
	//$regexResult:=$regex.match("This is a long sentence with an amount 13€ and a date 2025-04-21 ")
	//If ($regexResult.match)
	//
	//var $amount : Real
	//$amount:=Num($regexResult.matchList[1].text)
	//
	//var $date : Date
	//$date:=Add to date(!00-00-00!; \
		Num($regexResult.matchList[2].text); \
		Num($regexResult.matchList[3].text); \
		Num($regexResult.matchList[4].text))
	//
	//End if 
	
	$result:=New object:C1471
	$result.match:=False:C215
	$result.matchList:=New collection:C1472  // each element contains an object with the following propeties :
	// - "pos" : integer
	// - "length" : integer
	// - "text" : text
	//$result.start: Integer
	//$result.searchAtPosOnly:boolean
	$result.pos:=Null:C1517
	$result.length:=Null:C1517
	$result.text:=Null:C1517
	
	If ((Length:C16(This:C1470._regex)>0) && (Length:C16($text)>0))
		
		//var $pos : Integer
		$result.start:=(Count parameters:C259>1) ? $posParam : 1
		
		//var $searchAtPosOnly : Boolean
		$result.searchAtPosOnly:=(Count parameters:C259>2) ? $searchAtPosOnlyParam : False:C215
		
		ARRAY LONGINT:C221($tl_pos; 0)
		ARRAY LONGINT:C221($tl_length; 0)
		
		If ($result.searchAtPosOnly)
			$result.match:=Match regex:C1019(This:C1470._regex; $text; $result.start; $tl_pos; $tl_length; *)
		Else 
			$result.match:=Match regex:C1019(This:C1470._regex; $text; $result.start; $tl_pos; $tl_length)
		End if 
		
		If ($result.match)
			ARRAY TO COLLECTION:C1563($result.matchList; $tl_pos; "pos"; $tl_length; "length")
			
			var $matchItem : Object
			$matchItem:=New object:C1471("pos"; $tl_pos{0}; "length"; $tl_length{0})
			$result.matchList.insert(0; $matchItem)
			
			For each ($matchItem; $result.matchList)
				$matchItem.text:=Substring:C12($text; $matchItem.pos; $matchItem.length)
			End for each 
			
			$result.pos:=$result.matchList[0].pos
			$result.length:=$result.matchList[0].length
			$result.pos:=$result.matchList[0].text
		End if 
		
		ARRAY LONGINT:C221($tl_pos; 0)
		ARRAY LONGINT:C221($tl_length; 0)
		
	End if 
	